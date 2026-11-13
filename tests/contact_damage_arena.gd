class_name ContactDamageArena
extends Node2D
## Arena de treinamento e validação comparativa para COMBATE-CONTACT-DAMAGE-01.
## Fornece piso contínuo, plataformas elevadas, pista de dash,
## inimigos vivos de teste (Esqueleto, Rastejante, Corvo, Sentinela, Grupo Múltiplo)
## e HUD diagnóstico com chaveamento F10 (Contato ON <-> OFF).

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const KNIGHT_VISUAL_SCRIPT: Script = preload("res://scripts/player/knight_visual.gd")
const SKELETON_SCENE: PackedScene = preload("res://scenes/enemies/skeleton_patrol.tscn")
const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/forest_crawler.tscn")
const CROW_SCENE: PackedScene = preload("res://scenes/enemies/forest_spectral_crow.tscn")
const SENTINEL_SCENE: PackedScene = preload("res://scenes/enemies/forest_sentinel.tscn")

const FLOOR_Y: float = 160.0
const AREN_SPAWN: Vector2 = Vector2(160.0, 160.0)

var knight: KnightController
var camera: Camera2D
var hud_layer: CanvasLayer
var hud_label: Label
var hud_sublabel: Label
var hud_extra: Label
var hud_bg: ColorRect

# Inimigos para reset com F7
var enemy_skeleton: SkeletonPatrol
var enemy_crawler: ForestCrawler
var enemy_crow: ForestSpectralCrow
var enemy_sentinel: ForestSentinel
var group_skel: SkeletonPatrol
var group_crawler: ForestCrawler

var total_hits_taken: int = 0
var last_damage_info: String = "Nenhum"
var last_damage_timer: float = 0.0
var prev_hp: int = 6

func _ready() -> void:
	process_physics_priority = 10
	_build_geometry()
	_spawn_knight()
	_spawn_enemies()
	_build_camera()
	_build_hud()

func _build_geometry() -> void:
	# 1. Piso principal contínuo (x=0 a 1400, superfície y=160)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(1600.0, 80.0)
	floor_shape.shape = floor_rect
	floor_shape.position = Vector2(700.0, 200.0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)

	# 2. Paredes de contenção
	var left_wall := StaticBody2D.new()
	left_wall.collision_layer = 1
	left_wall.collision_mask = 0
	var lw_shape := CollisionShape2D.new()
	var lw_rect := RectangleShape2D.new()
	lw_rect.size = Vector2(30.0, 300.0)
	lw_shape.shape = lw_rect
	lw_shape.position = Vector2(-15.0, 50.0)
	left_wall.add_child(lw_shape)
	add_child(left_wall)

	var right_wall := StaticBody2D.new()
	right_wall.collision_layer = 1
	right_wall.collision_mask = 0
	var rw_shape := CollisionShape2D.new()
	var rw_rect := RectangleShape2D.new()
	rw_rect.size = Vector2(30.0, 300.0)
	rw_shape.shape = rw_rect
	rw_shape.position = Vector2(1315.0, 50.0)
	right_wall.add_child(rw_shape)
	add_child(right_wall)

	# 3. Plataformas Elevadas para testes de salto sobre inimigos
	_create_platform(Vector2(440.0, 115.0), Vector2(90.0, 10.0))
	_create_platform(Vector2(620.0, 80.0), Vector2(100.0, 10.0))
	_create_platform(Vector2(840.0, 115.0), Vector2(90.0, 10.0))

func _create_platform(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = size
	shape.shape = rect
	shape.position = pos
	body.add_child(shape)
	add_child(body)

func _spawn_knight() -> void:
	knight = KNIGHT_SCENE.instantiate() as KnightController
	knight.position = AREN_SPAWN
	knight.dash_unlocked = true
	knight.spectral_jump_unlocked = true
	add_child(knight)
	# Modo SOTN padrão com ART-FIX02 congelado
	knight.sword_attack.mode = SwordAttack.Mode.SOTN
	knight.visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	knight.hurtbox.contact_damage_enabled = true
	prev_hp = knight.survival.current_health

func _spawn_enemies() -> void:
	# Estação 1: Esqueleto (Caminhada / Patrulha básica)
	enemy_skeleton = SKELETON_SCENE.instantiate() as SkeletonPatrol
	enemy_skeleton.position = Vector2(320.0, FLOOR_Y)
	enemy_skeleton.target = knight
	add_child(enemy_skeleton)

	# Estação 2: Rastejante Fossilizado (Inimigo baixo no chão)
	enemy_crawler = CRAWLER_SCENE.instantiate() as ForestCrawler
	enemy_crawler.position = Vector2(510.0, FLOOR_Y)
	enemy_crawler.target = knight
	add_child(enemy_crawler)

	# Estação 3: Corvo Espectral (Inimigo voador)
	enemy_crow = CROW_SCENE.instantiate() as ForestSpectralCrow
	enemy_crow.position = Vector2(670.0, FLOOR_Y - 45.0)
	enemy_crow.target = knight
	add_child(enemy_crow)

	# Estação 4: Sentinela Ossífera (Inimigo alto)
	enemy_sentinel = SENTINEL_SCENE.instantiate() as ForestSentinel
	enemy_sentinel.position = Vector2(920.0, FLOOR_Y)
	enemy_sentinel.target = knight
	add_child(enemy_sentinel)

	# Estação 5: Grupo de Múltiplos Inimigos Agrupados
	group_skel = SKELETON_SCENE.instantiate() as SkeletonPatrol
	group_skel.position = Vector2(1130.0, FLOOR_Y)
	group_skel.target = knight
	add_child(group_skel)

	group_crawler = CRAWLER_SCENE.instantiate() as ForestCrawler
	group_crawler.position = Vector2(1165.0, FLOOR_Y)
	group_crawler.target = knight
	add_child(group_crawler)

func _build_camera() -> void:
	camera = Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 8.0
	camera.position = Vector2(AREN_SPAWN.x, 90.0)
	add_child(camera)
	camera.make_current()

func _build_hud() -> void:
	hud_layer = CanvasLayer.new()

	hud_bg = ColorRect.new()
	hud_bg.position = Vector2(0.0, 0.0)
	hud_bg.size = Vector2(380.0, 48.0)
	hud_bg.color = Color(0.03, 0.04, 0.08, 0.88)
	hud_layer.add_child(hud_bg)

	hud_label = Label.new()
	hud_label.position = Vector2(6.0, 2.0)
	hud_label.size = Vector2(368.0, 14.0)
	hud_label.add_theme_font_size_override("font_size", 9)
	hud_label.add_theme_color_override("font_color", Color("ffd152"))
	hud_layer.add_child(hud_label)

	hud_sublabel = Label.new()
	hud_sublabel.position = Vector2(6.0, 16.0)
	hud_sublabel.size = Vector2(368.0, 14.0)
	hud_sublabel.add_theme_font_size_override("font_size", 8)
	hud_sublabel.add_theme_color_override("font_color", Color("94a0b2"))
	hud_layer.add_child(hud_sublabel)

	hud_extra = Label.new()
	hud_extra.position = Vector2(6.0, 30.0)
	hud_extra.size = Vector2(368.0, 14.0)
	hud_extra.add_theme_font_size_override("font_size", 7)
	hud_extra.add_theme_color_override("font_color", Color("7a889b"))
	hud_layer.add_child(hud_extra)

	add_child(hud_layer)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(knight):
		return
	_track_damage_events(delta)
	_update_camera()
	_update_hud(delta)

func _track_damage_events(delta: float) -> void:
	var curr_hp: int = knight.survival.current_health
	if curr_hp < prev_hp:
		var loss: int = prev_hp - curr_hp
		total_hits_taken += loss
		var dmg_type: String = knight.hurtbox.last_damage_type
		var type_desc: String = "Corporal" if dmg_type == "body" else ("Golpe/Armadilha" if dmg_type == "hazard" else "Direto")
		last_damage_info = "-%d HP (%s)" % [loss, type_desc]
		last_damage_timer = 2.0
		print("[ARENA] Dano sofrido por Aren: %s | HP atual: %d/%d" % [last_damage_info, curr_hp, knight.survival.max_health])
	prev_hp = curr_hp

	if last_damage_timer > 0.0:
		last_damage_timer = maxf(0.0, last_damage_timer - delta)

func _update_camera() -> void:
	var cam_x: float = clampf(knight.position.x, 160.0, 1140.0)
	camera.position = Vector2(roundf(cam_x), 90.0)

func _update_hud(_delta: float) -> void:
	var contact_on: bool = knight.hurtbox.contact_damage_enabled
	var iframes: float = knight.survival.invulnerability_remaining
	var hp_cur: int = knight.survival.current_health
	var hp_max: int = knight.survival.max_health

	var hearts: String = ""
	for i in range(hp_max):
		hearts += "♥" if i < hp_cur else "♡"

	var contact_status: String = "[CONTATO ON]" if contact_on else "[CONTATO OFF]"
	var contact_color: Color = Color("4ade80") if contact_on else Color("f87171")

	var iframe_str: String = "PROTEGIDO (%.2fs)" % iframes if iframes > 0.0 else "VULNERÁVEL"
	var kb_str: String = "KNOCKBACK: %d px/s" % int(knight.knockback_speed) if knight.knockback_enabled else "OFF"

	hud_label.text = "HP: %s (%d/%d) | [F10] %s | %s" % [hearts, hp_cur, hp_max, contact_status, iframe_str]
	hud_label.add_theme_color_override("font_color", contact_color if iframes == 0.0 else Color("facc15"))

	hud_sublabel.text = "Último dano: %s | Total danos: %d | %s | Modo: %s" % [
		last_damage_info,
		total_hits_taken,
		kb_str,
		"SOTN" if knight.sword_attack.mode == SwordAttack.Mode.SOTN else "ORIGINAL"
	]

	hud_extra.text = "[A/D] Mover [Espaço] Pular [J] Espada [Shift] Dash | [F10] Contato ON/OFF | [F6] Modo [F7] Reset [ESC] Sair"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F10 or event.keycode == KEY_F5:
			toggle_contact_damage()
		elif event.keycode == KEY_F6:
			toggle_sword_mode()
		elif event.keycode == KEY_F8:
			toggle_visual_mode()
		elif event.keycode == KEY_F9:
			toggle_feedback()
		elif event.keycode == KEY_F7:
			reset_arena()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit(0)

func toggle_contact_damage() -> void:
	knight.hurtbox.contact_damage_enabled = not knight.hurtbox.contact_damage_enabled
	var status_str: String = "ATIVO (ON)" if knight.hurtbox.contact_damage_enabled else "INATIVO (OFF - LEGADO)"
	print("==================================================================")
	print("DANO POR CONTATO CORPORAL ALTERADO VIA F10: %s" % status_str)
	print("==================================================================")

func toggle_sword_mode() -> void:
	var next_mode: SwordAttack.Mode = knight.sword_attack.toggle_mode()
	var mode_str: String = "SOTN (PROTÓTIPO)" if next_mode == SwordAttack.Mode.SOTN else "ORIGINAL (CANÔNICO)"
	print("==================================================================")
	print("MODO DE ESPADA ALTERADO VIA F6: %s" % mode_str)
	print("==================================================================")

func toggle_visual_mode() -> void:
	var next_v: KnightVisual.SotnVisualMode = knight.visual.toggle_sotn_visual_mode()
	var v_str: String = "ART-FIX02 (HOMOLOGADO)" if next_v == KnightVisual.SotnVisualMode.ART_FIX02 else "ARM-FIX01 (FALLBACK)"
	print("==================================================================")
	print("APRESENTAÇÃO VISUAL SOTN ALTERADA VIA F8: %s" % v_str)
	print("==================================================================")

func toggle_feedback() -> void:
	knight.sword_attack.sotn_feedback_enabled = not knight.sword_attack.sotn_feedback_enabled
	var fb_str: String = "ON (HITSTOP + SFX SOTN-03)" if knight.sword_attack.sotn_feedback_enabled else "OFF (SILENCIOSO)"
	print("==================================================================")
	print("FEEDBACK AUDIOVISUAL ALTERADO VIA F9: %s" % fb_str)
	print("==================================================================")

func reset_arena() -> void:
	print("==================================================================")
	print("RESET DA ARENA DE DANO POR CONTATO SOLICITADO VIA F7")
	print("==================================================================")
	knight.position = AREN_SPAWN
	knight.velocity = Vector2.ZERO
	knight.survival.restore()
	prev_hp = knight.survival.current_health
	last_damage_info = "Arena Resetada"
	total_hits_taken = 0

	# Reset dos inimigos
	if is_instance_valid(enemy_skeleton):
		enemy_skeleton.reset_enemy()
		enemy_skeleton.position = Vector2(320.0, FLOOR_Y)
	if is_instance_valid(enemy_crawler):
		enemy_crawler.reset_enemy()
		enemy_crawler.position = Vector2(510.0, FLOOR_Y)
	if is_instance_valid(enemy_crow):
		enemy_crow.reset_enemy()
		enemy_crow.position = Vector2(670.0, FLOOR_Y - 45.0)
	if is_instance_valid(enemy_sentinel):
		enemy_sentinel.reset_enemy()
		enemy_sentinel.position = Vector2(920.0, FLOOR_Y)
	if is_instance_valid(group_skel):
		group_skel.reset_enemy()
		group_skel.position = Vector2(1130.0, FLOOR_Y)
	if is_instance_valid(group_crawler):
		group_crawler.reset_enemy()
		group_crawler.position = Vector2(1165.0, FLOOR_Y)

	camera.position = Vector2(AREN_SPAWN.x, 90.0)
