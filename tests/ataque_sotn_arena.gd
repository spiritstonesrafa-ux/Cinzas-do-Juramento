class_name AtaqueSotnArena
extends Node2D
## Arena de treinamento e validação comparativa para ATAQUE-SOTN-01.
## Fornece piso contínuo, plataformas verticais, parede de bloqueio,
## alvos de teste estáticos e inimigos representativos (Esqueleto, Crawler, Corvo).

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const KNIGHT_VISUAL_SCRIPT: Script = preload("res://scripts/player/knight_visual.gd")
const TARGET_SCENE: PackedScene = preload("res://scenes/targets/training_target.tscn")
const SKELETON_SCENE: PackedScene = preload("res://scenes/enemies/skeleton_patrol.tscn")
const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/forest_crawler.tscn")
const RAVEN_SCENE: PackedScene = preload("res://scenes/enemies/cursed_raven.tscn")

const FLOOR_Y: float = 160.0
const AREN_SPAWN: Vector2 = Vector2(220.0, 160.0)

var knight: KnightController
var camera: Camera2D
var hud_layer: CanvasLayer
var hud_label: Label
var hud_sublabel: Label
var hud_bg: ColorRect

# Targets e inimigos para reset com F7
var target_rear: TrainingTarget
var target_front: TrainingTarget
var target_dual_1: TrainingTarget
var target_dual_2: TrainingTarget
var target_wall_blocked: TrainingTarget

var enemy_skeleton: SkeletonPatrol
var enemy_crawler: ForestCrawler
var enemy_raven: CursedRaven

var session_hits: int = 0
var mode_banner_time: float = 0.0

func _ready() -> void:
	process_physics_priority = 10
	_build_geometry()
	_spawn_knight()
	_spawn_targets_and_enemies()
	_build_camera()
	_build_hud()

func _build_geometry() -> void:
	# 1. Piso principal contínuo (x=0 a 1200, superfície y=160)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var floor_shape := CollisionShape2D.new()
	var floor_rect := RectangleShape2D.new()
	floor_rect.size = Vector2(1400.0, 80.0)
	floor_shape.shape = floor_rect
	floor_shape.position = Vector2(600.0, 200.0)
	floor_body.add_child(floor_shape)
	add_child(floor_body)

	# 2. Barreiras laterais
	var left_wall := StaticBody2D.new()
	left_wall.collision_layer = 1
	var left_shape := CollisionShape2D.new()
	var wall_rect := RectangleShape2D.new()
	wall_rect.size = Vector2(30.0, 300.0)
	left_shape.shape = wall_rect
	left_shape.position = Vector2(35.0, 80.0)
	left_wall.add_child(left_shape)
	add_child(left_wall)

	var right_wall := StaticBody2D.new()
	right_wall.collision_layer = 1
	var right_shape := CollisionShape2D.new()
	right_shape.shape = wall_rect
	right_shape.position = Vector2(1165.0, 80.0)
	right_wall.add_child(right_shape)
	add_child(right_wall)

	# 3. Plataformas em diferentes alturas
	# Plataforma Baixa (y=130)
	_create_platform(Vector2(530.0, 130.0), Vector2(70.0, 8.0))
	# Plataforma Média (y=95)
	_create_platform(Vector2(680.0, 95.0), Vector2(80.0, 8.0))
	# Plataforma Alta (y=60)
	_create_platform(Vector2(840.0, 60.0), Vector2(90.0, 8.0))

	# 4. Parede sólida de alvenaria para teste de bloqueio de corte (x=980, y=100 a 160)
	var mason_wall := StaticBody2D.new()
	mason_wall.collision_layer = 1
	var mason_shape := CollisionShape2D.new()
	var mason_rect := RectangleShape2D.new()
	mason_rect.size = Vector2(16.0, 64.0)
	mason_shape.shape = mason_rect
	mason_shape.position = Vector2(980.0, 128.0)
	mason_wall.add_child(mason_shape)
	add_child(mason_wall)

func _create_platform(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = 1
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
	add_child(knight)
	knight.dash_unlocked = true
	# Modo SOTN ativo por padrão no harness comparativo
	knight.sword_attack.mode = SwordAttack.Mode.SOTN
	knight.set_default_respawn(AREN_SPAWN)
	knight.survival.respawn_requested.connect(func():
		knight.reset_to(AREN_SPAWN)
		knight.survival.current_health = knight.survival.max_health
	)

func _spawn_targets_and_enemies() -> void:
	# 1. Alvo atrás de Aren (x=185, Aren em 220 olhando para a direita)
	target_rear = TARGET_SCENE.instantiate() as TrainingTarget
	target_rear.position = Vector2(185.0, FLOOR_Y)
	target_rear.hit_received.connect(func(): _on_hit_registered("Alvo Traseiro (Falha se virado pra frente!)"))
	add_child(target_rear)

	# 2. Alvo frontal simples (x=290)
	target_front = TARGET_SCENE.instantiate() as TrainingTarget
	target_front.position = Vector2(290.0, FLOOR_Y)
	target_front.hit_received.connect(func(): _on_hit_registered("Alvo Frontal Padrão"))
	add_child(target_front)

	# 3. Dois alvos adjacentes lado a lado (x=380 e x=396) para corte múltiplo
	target_dual_1 = TARGET_SCENE.instantiate() as TrainingTarget
	target_dual_1.position = Vector2(380.0, FLOOR_Y)
	target_dual_1.hit_received.connect(func(): _on_hit_registered("Alvo Adjacente 1 (Corte Múltiplo)"))
	add_child(target_dual_1)

	target_dual_2 = TARGET_SCENE.instantiate() as TrainingTarget
	target_dual_2.position = Vector2(396.0, FLOOR_Y)
	target_dual_2.hit_received.connect(func(): _on_hit_registered("Alvo Adjacente 2 (Corte Múltiplo)"))
	add_child(target_dual_2)

	# 4. Esqueleto patrulheiro humanoide (x=490)
	enemy_skeleton = SKELETON_SCENE.instantiate() as SkeletonPatrol
	enemy_skeleton.position = Vector2(490.0, FLOOR_Y)
	enemy_skeleton.target = knight
	enemy_skeleton.patrol_left = -20.0
	enemy_skeleton.patrol_right = 20.0
	enemy_skeleton.defeated.connect(func(): _on_hit_registered("Esqueleto Derrotado!"))
	add_child(enemy_skeleton)

	# 5. Inimigo rastejante de baixo perfil (Floresta Crawler, x=610)
	enemy_crawler = CRAWLER_SCENE.instantiate() as ForestCrawler
	enemy_crawler.position = Vector2(610.0, FLOOR_Y)
	enemy_crawler.target = knight
	enemy_crawler.patrol_speed = 15.0
	enemy_crawler.chase_speed = 25.0
	enemy_crawler.defeated.connect(func(): _on_hit_registered("Crawler Rastejante Derrotado (Corte Baixo)!"))
	add_child(enemy_crawler)

	# 6. Corvo voador (CursedRaven, x=750, y=110)
	enemy_raven = RAVEN_SCENE.instantiate() as CursedRaven
	enemy_raven.position = Vector2(750.0, 110.0)
	enemy_raven.target = knight
	enemy_raven.defeated.connect(func(): _on_hit_registered("Corvo Voador Abatido (Corte Alto)!"))
	add_child(enemy_raven)

	# 7. Alvo atrás da parede de alvenaria (x=1010, parede em x=980)
	target_wall_blocked = TARGET_SCENE.instantiate() as TrainingTarget
	target_wall_blocked.position = Vector2(1010.0, FLOOR_Y)
	target_wall_blocked.hit_received.connect(func(): _on_hit_registered("Alvo Atrás da Parede (Falha de colisão se atingido!)"))
	add_child(target_wall_blocked)

func _build_camera() -> void:
	camera = Camera2D.new()
	camera.limit_left = 50
	camera.limit_right = 1150
	camera.limit_top = -40
	camera.limit_bottom = 220
	camera.position_smoothing_enabled = false
	add_child(camera)
	_update_camera()

func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 100

	hud_bg = ColorRect.new()
	hud_bg.color = Color(0.04, 0.05, 0.07, 0.88)
	hud_bg.size = Vector2(380.0, 36.0)
	hud_layer.add_child(hud_bg)

	hud_label = Label.new()
	hud_label.position = Vector2(6.0, 2.0)
	hud_label.size = Vector2(368.0, 16.0)
	hud_label.add_theme_font_size_override("font_size", 9)
	hud_label.add_theme_color_override("font_color", Color("f4ecc2"))
	hud_layer.add_child(hud_label)

	hud_sublabel = Label.new()
	hud_sublabel.position = Vector2(6.0, 18.0)
	hud_sublabel.size = Vector2(368.0, 16.0)
	hud_sublabel.add_theme_font_size_override("font_size", 8)
	hud_sublabel.add_theme_color_override("font_color", Color("94a0b2"))
	hud_layer.add_child(hud_sublabel)

	add_child(hud_layer)

func _on_hit_registered(source_name: String) -> void:
	session_hits += 1
	print("[ARENA] Impacto registrado: %s | Total: %d" % [source_name, session_hits])

func _physics_process(delta: float) -> void:
	if not is_instance_valid(knight):
		return
	_update_camera()
	_update_hud(delta)

func _update_camera() -> void:
	var cam_x: float = clampf(knight.position.x, 210.0, 990.0)
	camera.position = Vector2(roundf(cam_x), 90.0)

func _update_hud(delta: float) -> void:
	var attack: SwordAttack = knight.sword_attack
	var is_sotn: bool = attack.mode == SwordAttack.Mode.SOTN

	var mode_text: String = "SOTN" if is_sotn else "ORIGINAL"
	var mode_color: Color = Color("ffd152") if is_sotn else Color("a0b0c4")

	var v_str: String = ""
	var fb_str: String = ""
	if is_sotn and is_instance_valid(knight.visual):
		v_str = " | [F8] ART-FIX02 [HOMOLOGADO]" if knight.visual.sotn_visual_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02 else " | [F8] ARM-FIX01 [FALLBACK]"
		fb_str = " | [F9] FEEDBACK: %s" % ("ON (SOTN-03)" if attack.sotn_feedback_enabled else "OFF (SILENCIOSO)")

	var phase_name: String = "NEUTRO"
	match attack.phase:
		SwordAttack.Phase.WINDUP:
			phase_name = "PREPARACAO (0.05s)" if is_sotn else "PREPARACAO (0.10s)"
		SwordAttack.Phase.ACTIVE:
			var region_str: String = ""
			if is_sotn:
				match attack.get_current_arc_region():
					SwordAttack.ArcRegion.HIGH:
						region_str = " -> ALTA [Y:-25]"
					SwordAttack.ArcRegion.MID:
						region_str = " -> MEDIA [Y:-14]"
					SwordAttack.ArcRegion.LOW:
						region_str = " -> BAIXA [Y:-5]"
			phase_name = "ATIVO (%s)%s" % ["0.05s" if is_sotn else "0.10s", region_str]
		SwordAttack.Phase.RECOVERY:
			var buf_str: String = " [BUFFER OK]" if attack.is_buffered() else ""
			phase_name = "RECUPERACAO (%s)%s" % ["0.15s" if is_sotn else "0.20s", buf_str]

	hud_label.text = "[F6] MODO: %s%s%s | FASE: %s" % [mode_text, v_str, fb_str, phase_name]
	hud_label.add_theme_color_override("font_color", mode_color)

	hud_sublabel.text = "[A/D] Mover [Espaço] Pulo [J] Golpe [F6] Modo [F8] Visual [F9] Feedback [F7] Reset | Hits: %d" % session_hits

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F6:
			toggle_mode()
		elif event.keycode == KEY_F8:
			toggle_visual_mode()
		elif event.keycode == KEY_F9:
			toggle_feedback()
		elif event.keycode == KEY_F7:
			reset_arena()
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit(0)

func toggle_mode() -> void:
	var next_mode: SwordAttack.Mode = knight.sword_attack.toggle_mode()
	var mode_str: String = "SOTN (PROTÓTIPO)" if next_mode == SwordAttack.Mode.SOTN else "ORIGINAL (CANÔNICO)"
	print("==================================================================")
	print("MODO DE ATAQUE ALTERADO VIA F6: %s" % mode_str)
	print("==================================================================")

func toggle_feedback() -> void:
	if not is_instance_valid(knight) or not is_instance_valid(knight.sword_attack):
		return
	var attack: SwordAttack = knight.sword_attack
	attack.sotn_feedback_enabled = not attack.sotn_feedback_enabled
	var fb_str: String = "ATIVADO (SOTN-03: ÁUDIO + HITSTOP + FAÍSCAS)" if attack.sotn_feedback_enabled else "DESATIVADO (SILENCIOSO / SEM HITSTOP)"
	print("==================================================================")
	print("FEEDBACK AUDIOVISUAL ALTERADO VIA F9: %s" % fb_str)
	print("==================================================================")

func toggle_visual_mode() -> void:
	if not is_instance_valid(knight) or not is_instance_valid(knight.visual):
		return
	var v_mode = knight.visual.toggle_sotn_visual_mode()
	var v_str: String = "ART-FIX02 (HOMOLOGADO)" if v_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02 else "ARM-FIX01 (FALLBACK RECUPERÁVEL)"
	print("==================================================================")
	print("VISUAL SOTN ALTERADO VIA F8: %s" % v_str)
	print("==================================================================")

func reset_arena() -> void:
	print("==================================================================")
	print("RESET DA ARENA DE PLAYTEST SOLICITADO VIA F7")
	print("==================================================================")
	knight.reset_to(AREN_SPAWN)
	knight.velocity = Vector2.ZERO
	knight.survival.current_health = knight.survival.max_health

	if is_instance_valid(target_rear):
		target_rear.hit_count = 0
		target_rear.position = Vector2(185.0, FLOOR_Y)
	if is_instance_valid(target_front):
		target_front.hit_count = 0
		target_front.position = Vector2(290.0, FLOOR_Y)
	if is_instance_valid(target_dual_1):
		target_dual_1.hit_count = 0
		target_dual_1.position = Vector2(380.0, FLOOR_Y)
	if is_instance_valid(target_dual_2):
		target_dual_2.hit_count = 0
		target_dual_2.position = Vector2(396.0, FLOOR_Y)
	if is_instance_valid(target_wall_blocked):
		target_wall_blocked.hit_count = 0
		target_wall_blocked.position = Vector2(1010.0, FLOOR_Y)

	if is_instance_valid(enemy_skeleton):
		enemy_skeleton.reset_enemy()
		enemy_skeleton.position = Vector2(490.0, FLOOR_Y)
	if is_instance_valid(enemy_crawler):
		enemy_crawler.reset_enemy()
		enemy_crawler.position = Vector2(610.0, FLOOR_Y)
	if is_instance_valid(enemy_raven):
		enemy_raven.reset_enemy()
		enemy_raven.position = Vector2(750.0, 110.0)

	session_hits = 0

func _draw() -> void:
	# Fundo gótico atmosférico
	draw_rect(Rect2(0, -60, 1200, 300), Color("0d1117"))

	# Pilares de fundo estilizados
	for px in [120, 240, 360, 480, 600, 720, 840, 960, 1080]:
		draw_rect(Rect2(px - 10, -30, 20, 190), Color("161b26"))
		draw_rect(Rect2(px - 14, -40, 28, 12), Color("1f2636"))
		draw_rect(Rect2(px - 14, 150, 28, 10), Color("1f2636"))

	# Piso de pedra de alvenaria
	draw_rect(Rect2(0, FLOOR_Y, 1200, 60), Color("212631"))
	draw_line(Vector2(0, FLOOR_Y), Vector2(1200, FLOOR_Y), Color("434c5e"), 2.0)
	for tx in range(0, 1200, 32):
		draw_line(Vector2(tx, FLOOR_Y), Vector2(tx, FLOOR_Y + 16), Color("2e3545"), 1.0)
		draw_line(Vector2(tx + 16, FLOOR_Y + 16), Vector2(tx + 16, FLOOR_Y + 32), Color("2e3545"), 1.0)

	# Plataformas desenhadas
	_draw_styled_platform(Vector2(530, 130), Vector2(70, 8), "Plataforma Baixa")
	_draw_styled_platform(Vector2(680, 95), Vector2(80, 8), "Plataforma Média")
	_draw_styled_platform(Vector2(840, 60), Vector2(90, 8), "Plataforma Alta")

	# Parede de alvenaria maciça para teste de bloqueio
	draw_rect(Rect2(972, 96, 16, 64), Color("383f4f"))
	draw_rect(Rect2(970, 92, 20, 6), Color("505a6e"))
	draw_line(Vector2(972, 96), Vector2(972, 160), Color("556075"), 1.0)
	draw_line(Vector2(988, 96), Vector2(988, 160), Color("222733"), 1.0)

	# Indicadores de Zonas de Teste
	_draw_zone_sign(Vector2(185, 120), "[Retaguarda]")
	_draw_zone_sign(Vector2(290, 120), "[Alvo Frontal]")
	_draw_zone_sign(Vector2(388, 120), "[Corte Duplo]")
	_draw_zone_sign(Vector2(490, 120), "[Esqueleto]")
	_draw_zone_sign(Vector2(610, 120), "[Crawler Baixo]")
	_draw_zone_sign(Vector2(750, 70), "[Corvo Alto]")
	_draw_zone_sign(Vector2(980, 75), "[Parede Bloqueio]")

func _draw_styled_platform(pos: Vector2, size: Vector2, _label: String) -> void:
	var rect := Rect2(pos.x - size.x * 0.5, pos.y - size.y * 0.5, size.x, size.y)
	draw_rect(rect, Color("2d3545"))
	draw_line(Vector2(rect.position.x, rect.position.y), Vector2(rect.end.x, rect.position.y), Color("526078"), 1.5)
	draw_line(Vector2(rect.position.x, rect.end.y), Vector2(rect.end.x, rect.end.y), Color("171c26"), 1.0)

func _draw_zone_sign(pos: Vector2, text: String) -> void:
	draw_string(ThemeDB.fallback_font, pos + Vector2(-28, 0), text, HORIZONTAL_ALIGNMENT_CENTER, -1, 7, Color("6b7c96"))
