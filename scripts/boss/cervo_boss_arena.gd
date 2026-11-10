class_name CervoBossArena
extends Node2D
## Controlador da arena de combate do Cervo Espectral (M6-CERVO-BOSS).
## Gerencia barreiras dinâmicas, ativação do confronto, HUD e persistência em Setor 10.

signal battle_started
signal battle_ended(won: bool)

const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const CervoBossBar = preload("res://scripts/ui/cervo_boss_bar.gd")
const KnightController = preload("res://scripts/player/knight_controller.gd")

@export var arena_left: float = 160.0
@export var arena_right: float = 800.0

var hero: KnightController = null
var active: bool = false
var completed: bool = false

@onready var boss: CervoBoss = $CervoBoss
@onready var left_gate_col: CollisionShape2D = $LeftGate/CollisionShape2D
@onready var right_gate_col: CollisionShape2D = $RightGate/CollisionShape2D
@onready var trigger_area: Area2D = $TriggerArea
@onready var boss_hud: CanvasLayer = $BossHUD
@onready var hud_bar: CervoBossBar = $BossHUD/CervoBossBar

func _ready() -> void:
	# Verifica se o chefe já foi derrotado nesta campanha/save
	completed = ABBEY_PROGRESS.is_flag_set("cervo_defeated")
	
	if is_instance_valid(boss):
		boss.defeated.connect(_on_boss_defeated)
		if is_instance_valid(boss.conclusion):
			boss.conclusion.finished.connect(_on_conclusion_finished)
	
	if is_instance_valid(hud_bar) and is_instance_valid(boss):
		hud_bar.boss = boss
	
	if is_instance_valid(trigger_area):
		trigger_area.body_entered.connect(_on_trigger_entered)
	
	_set_gates_closed(false)
	
	if completed:
		_setup_pacified_state()
	else:
		if is_instance_valid(boss_hud):
			boss_hud.visible = false

func set_hero(p_hero: KnightController) -> void:
	hero = p_hero
	if is_instance_valid(hero):
		if not hero.survival.died.is_connected(_on_hero_died):
			hero.survival.died.connect(_on_hero_died)
		if not hero.survival.respawn_requested.is_connected(_on_hero_respawn):
			hero.survival.respawn_requested.connect(_on_hero_respawn)
		if completed:
			hero.spectral_jump_unlocked = true

func _physics_process(_delta: float) -> void:
	if completed or active:
		return
	
	if hero == null:
		var cur: Node = get_parent()
		while cur != null and hero == null:
			if "hero" in cur and cur.hero is KnightController:
				set_hero(cur.hero)
				break
			cur = cur.get_parent()
		if hero == null:
			var candidates: Array[Node] = get_tree().get_nodes_in_group("hero")
			if not candidates.is_empty() and candidates[0] is KnightController:
				set_hero(candidates[0] as KnightController)
	
	if is_instance_valid(hero) and not hero.survival.is_dead:
		var local_x: float = to_local(hero.global_position).x
		# Acionamento seguro se o herói já cruzou o portal e adentrou a arena
		if local_x >= 180.0 and local_x <= arena_right - 40.0:
			start_encounter.call_deferred()

func _setup_pacified_state() -> void:
	_set_gates_closed(false)
	if is_instance_valid(boss):
		boss.health = 0
		boss.disarm()
		boss._set_state(CervoBoss.State.DEFEATED, 0.0)
		var col: CollisionShape2D = boss.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col != null:
			col.set_deferred("disabled", true)
		if boss.receiver != null:
			var r_col: CollisionShape2D = boss.receiver.get_node_or_null("CollisionShape2D")
			if r_col != null:
				r_col.set_deferred("disabled", true)
		if is_instance_valid(boss.visual):
			boss.visual.visible = false
		if is_instance_valid(boss.conclusion):
			boss.conclusion.played = true
			boss.conclusion.settle(true)
	if is_instance_valid(boss_hud):
		boss_hud.visible = false

func _on_trigger_entered(body: Node2D) -> void:
	if completed or active:
		return
	if body is KnightController:
		if hero == null:
			set_hero(body)
		if is_instance_valid(hero) and not hero.survival.is_dead:
			start_encounter.call_deferred()

func start_encounter() -> void:
	if completed or active or not is_instance_valid(hero) or hero.survival.is_dead:
		return
	
	active = true
	_set_gates_closed(true)
	
	if is_instance_valid(boss_hud):
		boss_hud.visible = true
	
	if is_instance_valid(boss):
		boss.begin_fight(hero)
	
	battle_started.emit()

func _set_gates_closed(closed: bool) -> void:
	if is_instance_valid(left_gate_col):
		left_gate_col.disabled = not closed
	if is_instance_valid(right_gate_col):
		right_gate_col.disabled = not closed
	queue_redraw()

func _on_boss_defeated() -> void:
	active = false
	completed = true
	# As barreiras se dissipam imediatamente na queda do chefe
	_set_gates_closed(false)
	battle_ended.emit(true)

func _on_conclusion_finished() -> void:
	_set_gates_closed(false)
	if is_instance_valid(hero):
		hero.spectral_jump_unlocked = true

func _on_hero_died() -> void:
	if active:
		active = false
		_set_gates_closed(false)
		if is_instance_valid(boss):
			boss.disarm()
		if is_instance_valid(boss_hud):
			boss_hud.visible = false
		battle_ended.emit(false)

func _on_hero_respawn() -> void:
	if not completed:
		reset_encounter()

func reset_encounter() -> void:
	active = false
	_set_gates_closed(false)
	if is_instance_valid(boss_hud):
		boss_hud.visible = false
	if is_instance_valid(boss):
		boss.reset_encounter()

func disarm() -> void:
	if is_instance_valid(boss):
		boss.disarm()

func _draw() -> void:
	# Desenha barreiras espectrais quando os portões estão fechados
	if active and not completed:
		# Barreira Espectral Oeste (x = 160)
		_draw_spectral_barrier(arena_left)
		# Barreira Espectral Leste (x = 800)
		_draw_spectral_barrier(arena_right)

func _draw_spectral_barrier(x_pos: float) -> void:
	var top_y: float = 60.0
	var bot_y: float = 260.0
	var time: float = Time.get_ticks_msec() / 1000.0
	
	# Coluna base de névoa turquesa translúcida
	draw_rect(Rect2(x_pos - 4.0, top_y, 8.0, bot_y - top_y), Color(0.12, 0.65, 0.70, 0.35))
	draw_line(Vector2(x_pos, top_y), Vector2(x_pos, bot_y), Color(0.35, 0.95, 1.0, 0.75), 2.0)
	
	# Ondulações etéreas verticais
	for i in range(8):
		var y: float = top_y + float(i) * 25.0 + fmod(time * 30.0, 25.0)
		if y < bot_y:
			var w: float = 6.0 + 3.0 * sin(time * 4.0 + float(i))
			draw_circle(Vector2(x_pos, y), w * 0.4, Color(0.20, 0.90, 1.0, 0.45))
