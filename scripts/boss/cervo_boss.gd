class_name CervoBoss
extends CharacterBody2D
## Entidade oficial de combate do Cervo Espectral (M6-CERVO-BOSS).
## Chefe obrigatório da Fase 3 — Floresta dos Ossos, Setor 10 (Clareira da Bruma Espectral).

const CervoBossAttackSource = preload("res://scripts/boss/cervo_boss_attack_source.gd")
const CervoBossEcho = preload("res://scripts/boss/cervo_boss_echo.gd")
const CervoBossConclusion = preload("res://scripts/boss/cervo_boss_conclusion.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const SwordReceiver = preload("res://scripts/combat/sword_receiver.gd")
const KnightController = preload("res://scripts/player/knight_controller.gd")

signal defeated
signal health_changed(current: int, maximum: int)
signal phase_changed(new_phase: int)
signal state_changed(new_state: int)
signal attack_started(attack_type: int)
signal attack_completed(attack_type: int)

enum State {
	DORMANT,
	INTRO,
	PURSUIT,
	TELEGRAPH,
	ATTACK_ACTIVE,
	RECOVERY,
	PHASE_TRANSITION,
	DEFEATED
}

enum BossAttack {
	NONE,
	CHARGE,
	ANTLER,
	STOMP,
	LEAP,
	ECHOES
}

@export var max_health: int = 14
@export var walk_speed: float = 45.0
@export var charge_speed: float = 195.0
@export var bounds_left: float = 180.0
@export var bounds_right: float = 780.0
@export var deterministic: bool = false

var health: int = 14
var phase: int = 1
var state: State = State.DORMANT
var current_attack: BossAttack = BossAttack.NONE
var facing: int = -1
var target: KnightController = null
var remaining_timer: float = 0.0
var attack_cycle: int = 0
var last_attack: BossAttack = BossAttack.NONE
var _phase_pending: bool = false
var flash: float = 0.0
var leap_target_pos: Vector2 = Vector2.ZERO
var leap_start_pos: Vector2 = Vector2.ZERO
var leap_timer: float = 0.0
var leap_duration: float = 1.0

# Gestão de ecos invocados
var active_echoes: Array[CervoBossEcho] = []
const ECHO_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss_echo.tscn")

@onready var visual: CervoVisual = get_node_or_null("Visual") as CervoVisual
@onready var attack_source: CervoBossAttackSource = get_node_or_null("AttackSource") as CervoBossAttackSource
@onready var receiver: SwordReceiver = get_node_or_null("SwordReceiver") as SwordReceiver
@onready var conclusion: CervoBossConclusion = get_node_or_null("Conclusion") as CervoBossConclusion

func _ready() -> void:
	process_physics_priority = -2
	health = max_health
	if receiver != null:
		receiver.hit_received.connect(receive_hit)
	_set_state(State.DORMANT, 0.0)

func get_arena_bound_left() -> float:
	var parent_node: Node = get_parent()
	if parent_node is Node2D:
		return parent_node.to_global(Vector2(bounds_left, 0.0)).x
	return bounds_left

func get_arena_bound_right() -> float:
	var parent_node: Node = get_parent()
	if parent_node is Node2D:
		return parent_node.to_global(Vector2(bounds_right, 0.0)).x
	return bounds_right

func reset_encounter() -> void:
	disarm()
	health = max_health
	phase = 1
	_phase_pending = false
	attack_cycle = 0
	last_attack = BossAttack.NONE
	facing = -1
	flash = 0.0
	var col: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col != null:
		col.set_deferred("disabled", false)
	if receiver != null:
		var r_col: CollisionShape2D = receiver.get_node_or_null("CollisionShape2D")
		if r_col != null:
			r_col.set_deferred("disabled", false)
	if visual != null:
		visual.visible = true
		visual.position = Vector2.ZERO
		visual.modulate = Color.WHITE
		visual.modulate_color = Color.WHITE
		visual.facing = facing
		visual.play_by_name("idle")
	if conclusion != null:
		conclusion.cancel()
	_set_state(State.DORMANT, 0.0)
	health_changed.emit(health, max_health)

func begin_fight(player: KnightController) -> void:
	target = player
	reset_encounter()
	target = player
	_set_state(State.INTRO, 2.2)

func _set_state(new_state: State, duration: float = 0.0) -> void:
	state = new_state
	remaining_timer = duration
	velocity = Vector2.ZERO
	state_changed.emit(state)
	
	match state:
		State.DORMANT:
			if visual != null: visual.play_by_name("idle")
			if attack_source != null: attack_source.set_active(false)
		State.INTRO:
			if visual != null: visual.play_by_name("idle")
			if attack_source != null: attack_source.set_active(false)
		State.PURSUIT:
			if visual != null: visual.play_by_name("walk")
			if attack_source != null: attack_source.set_active(false)
		State.TELEGRAPH:
			if attack_source != null: attack_source.set_active(false)
		State.ATTACK_ACTIVE:
			pass # Configurado especificamente em cada ataque
		State.RECOVERY:
			if attack_source != null: attack_source.set_active(false)
			if visual != null: visual.play_by_name("idle")
		State.PHASE_TRANSITION:
			if attack_source != null: attack_source.set_active(false)
			if visual != null: visual.play_by_name("idle")
		State.DEFEATED:
			if attack_source != null: attack_source.set_active(false)
			if receiver != null:
				var col: CollisionShape2D = receiver.get_node_or_null("CollisionShape2D")
				if col != null: col.set_deferred("disabled", true)

func receive_hit() -> void:
	if state in [State.DORMANT, State.INTRO, State.PHASE_TRANSITION, State.DEFEATED]:
		return
	if not is_instance_valid(target) or (target.survival != null and target.survival.is_dead):
		return
	
	health = maxi(0, health - 1)
	flash = 0.16
	health_changed.emit(health, max_health)
	
	if health == 0:
		_on_defeated()
	elif phase == 1 and health <= 9:
		_phase_pending = true
		if state in [State.PURSUIT, State.RECOVERY]:
			_begin_phase_transition(2)
	elif phase == 2 and health <= 4:
		_phase_pending = true
		if state in [State.PURSUIT, State.RECOVERY]:
			_begin_phase_transition(3)

func _begin_phase_transition(next_phase: int) -> void:
	phase = next_phase
	_phase_pending = false
	disarm()
	_set_state(State.PHASE_TRANSITION, 0.9)
	phase_changed.emit(phase)

func _on_defeated() -> void:
	disarm()
	_set_state(State.DEFEATED, 0.0)
	var col: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col != null:
		col.set_deferred("disabled", true)
	if receiver != null:
		var r_col: CollisionShape2D = receiver.get_node_or_null("CollisionShape2D")
		if r_col != null:
			r_col.set_deferred("disabled", true)
	defeated.emit()

func disarm() -> void:
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
	velocity = Vector2.ZERO
	# Dissipa todas as manifestações espectrais ativas
	for echo: CervoBossEcho in active_echoes:
		if is_instance_valid(echo):
			echo.dismiss()
	active_echoes.clear()

func _physics_process(delta: float) -> void:
	flash = maxf(0.0, flash - delta)
	if visual != null and state != State.DEFEATED:
		if flash > 0.0:
			visual.modulate = Color(1.8, 1.2, 1.2, 1.0)
		else:
			visual.modulate = Color.WHITE
	
	if state == State.DEFEATED or state == State.DORMANT:
		return
	
	if not is_instance_valid(target) or (target.survival != null and target.survival.is_dead):
		disarm()
		if state != State.DORMANT:
			_set_state(State.DORMANT, 0.0)
		return
	
	remaining_timer = maxf(0.0, remaining_timer - delta)
	
	match state:
		State.INTRO:
			_update_facing_towards_target()
			if remaining_timer <= 0.0:
				_set_state(State.PURSUIT, 0.0)
		
		State.PURSUIT:
			_update_facing_towards_target()
			var dx: float = target.global_position.x - global_position.x
			var dist: float = absf(dx)
			
			# Decide qual ataque iniciar
			var chosen: BossAttack = _select_attack(dist)
			if chosen != BossAttack.NONE:
				_start_attack(chosen)
			else:
				# Movimenta-se em direção ao jogador respeitando os limites da arena
				velocity.x = float(facing) * walk_speed
				velocity.y = 40.0 # Gravidade leve de chão
				move_and_slide()
				global_position.x = clampf(global_position.x, get_arena_bound_left(), get_arena_bound_right())
		
		State.TELEGRAPH:
			if remaining_timer <= 0.0:
				_execute_attack()
		
		State.ATTACK_ACTIVE:
			_process_attack_active(delta)
			if remaining_timer <= 0.0:
				_enter_recovery()
		
		State.RECOVERY:
			if remaining_timer <= 0.0:
				if _phase_pending:
					_begin_phase_transition(phase + 1)
				else:
					_set_state(State.PURSUIT, 0.0)
		
		State.PHASE_TRANSITION:
			if remaining_timer <= 0.0:
				_set_state(State.PURSUIT, 0.0)

func _update_facing_towards_target() -> void:
	if is_instance_valid(target):
		var dx: float = target.global_position.x - global_position.x
		if absf(dx) > 4.0:
			facing = 1 if dx > 0.0 else -1
			if visual != null:
				visual.facing = facing

func _select_attack(dist: float) -> BossAttack:
	# Seleção baseada em fase e distância com prevenção de repetição
	var options: Array[BossAttack] = []
	
	if phase == 1:
		# Fase 1: Investida, Corte das Galhadas e Pisada das Almas
		if dist <= 85.0:
			options.append(BossAttack.ANTLER)
			options.append(BossAttack.STOMP)
		elif dist > 85.0 and dist < 220.0:
			options.append(BossAttack.CHARGE)
			options.append(BossAttack.STOMP)
		else:
			options.append(BossAttack.CHARGE)
	elif phase == 2:
		# Fase 2: Adiciona Salto Predatório e Ecos da Floresta
		if dist <= 75.0:
			options.append(BossAttack.ANTLER)
			options.append(BossAttack.STOMP)
		elif dist > 75.0 and dist < 200.0:
			options.append(BossAttack.CHARGE)
			options.append(BossAttack.LEAP)
			options.append(BossAttack.ECHOES)
		else:
			options.append(BossAttack.LEAP)
			options.append(BossAttack.CHARGE)
			options.append(BossAttack.ECHOES)
	else:
		# Fase 3: Todos os 5 ataques com alternância tática
		if dist <= 80.0:
			options.append(BossAttack.ANTLER)
			options.append(BossAttack.STOMP)
		elif dist > 80.0 and dist < 180.0:
			options.append(BossAttack.CHARGE)
			options.append(BossAttack.LEAP)
			options.append(BossAttack.ECHOES)
		else:
			options.append(BossAttack.LEAP)
			options.append(BossAttack.CHARGE)
			options.append(BossAttack.ECHOES)
	
	# Filtra para evitar repetição contínua do mesmo ataque se houver alternativas
	var filtered: Array[BossAttack] = []
	for opt in options:
		if opt != last_attack or options.size() == 1:
			filtered.append(opt)
	if filtered.is_empty():
		filtered = options
	
	if filtered.is_empty():
		return BossAttack.NONE
	
	if deterministic:
		return filtered[attack_cycle % filtered.size()]
	return filtered[randi() % filtered.size()]

func _start_attack(atk: BossAttack) -> void:
	current_attack = atk
	last_attack = atk
	attack_cycle += 1
	_update_facing_towards_target()
	attack_started.emit(current_attack)
	
	match current_attack:
		BossAttack.CHARGE:
			_set_state(State.TELEGRAPH, 0.95)
			if visual != null: visual.start_charge_sequence()
		BossAttack.ANTLER:
			_set_state(State.TELEGRAPH, 0.90)
			if visual != null: visual.start_antler_sequence()
		BossAttack.STOMP:
			_set_state(State.TELEGRAPH, 0.95)
			if visual != null: visual.start_stomp_sequence()
		BossAttack.LEAP:
			_set_state(State.TELEGRAPH, 0.90)
			if visual != null: visual.start_leap_sequence()
			leap_start_pos = global_position
			var b_left: float = get_arena_bound_left()
			var b_right: float = get_arena_bound_right()
			var target_x: float = clampf(target.global_position.x, b_left + 40.0, b_right - 40.0)
			leap_target_pos = Vector2(target_x, global_position.y)
		BossAttack.ECHOES:
			_set_state(State.TELEGRAPH, 0.95)
			if visual != null: visual.start_echo_sequence()

func _execute_attack() -> void:
	_set_state(State.ATTACK_ACTIVE)
	
	match current_attack:
		BossAttack.CHARGE:
			remaining_timer = 0.90
			if attack_source != null:
				attack_source.configure(CervoBossAttackSource.AttackType.CHARGE, facing, attack_cycle)
				attack_source.set_active(true)
		
		BossAttack.ANTLER:
			remaining_timer = 0.85
			if attack_source != null:
				attack_source.configure(CervoBossAttackSource.AttackType.ANTLER, facing, attack_cycle)
				attack_source.set_active(true)
		
		BossAttack.STOMP:
			remaining_timer = 0.90
			if attack_source != null:
				attack_source.configure(CervoBossAttackSource.AttackType.STOMP, facing, attack_cycle)
				attack_source.set_active(true)
		
		BossAttack.LEAP:
			remaining_timer = leap_duration
			leap_timer = 0.0
			# O dano do salto ocorre no impacto da descida
			if attack_source != null:
				attack_source.configure(CervoBossAttackSource.AttackType.LEAP, facing, attack_cycle)
				attack_source.set_active(false)
		
		BossAttack.ECHOES:
			remaining_timer = 0.95
			# As manifestações são geradas exatamente no momento em que a invocação culmina
			_spawn_echoes()

func _process_attack_active(delta: float) -> void:
	match current_attack:
		BossAttack.CHARGE:
			velocity.x = float(facing) * charge_speed
			velocity.y = 40.0
			move_and_slide()
			# Para se atingir a parede lateral
			var b_left: float = get_arena_bound_left()
			var b_right: float = get_arena_bound_right()
			if (facing < 0 and global_position.x <= b_left) or (facing > 0 and global_position.x >= b_right):
				remaining_timer = 0.0
		
		BossAttack.LEAP:
			leap_timer += delta
			var t: float = clampf(leap_timer / leap_duration, 0.0, 1.0)
			# Trajetória parabólica fluida
			var current_x: float = lerpf(leap_start_pos.x, leap_target_pos.x, t)
			var arc_height: float = -75.0 * 4.0 * t * (1.0 - t) # pico de -75 px
			global_position = Vector2(current_x, leap_start_pos.y + arc_height)
			
			# No impacto final (t >= 0.85), ativa onda de impacto de aterrissagem
			if t >= 0.85 and attack_source != null and not attack_source.monitorable:
				attack_source.set_active(true)
		
		BossAttack.STOMP:
			# Onda de choque terrestre permanece ativa por 0.5s após o impacto
			if remaining_timer <= 0.4 and attack_source != null:
				attack_source.set_active(false)
		
		BossAttack.ANTLER:
			# Golpe das galhadas tem janela ativa de 0.4s
			if remaining_timer <= 0.45 and attack_source != null:
				attack_source.set_active(false)

func _spawn_echoes() -> void:
	if not is_inside_tree():
		return
	var parent_scene: Node = get_parent()
	if parent_scene == null:
		return
	
	# Cria exatamente duas manifestações independentes (Echo_A à esquerda, Echo_B à direita)
	var echo_a: CervoBossEcho = ECHO_SCENE.instantiate() as CervoBossEcho
	var echo_b: CervoBossEcho = ECHO_SCENE.instantiate() as CervoBossEcho
	
	parent_scene.add_child(echo_a)
	parent_scene.add_child(echo_b)
	
	active_echoes.append(echo_a)
	active_echoes.append(echo_b)
	
	var pos_a: Vector2 = global_position + Vector2(-60.0, 0.0)
	var pos_b: Vector2 = global_position + Vector2(60.0, 0.0)
	
	echo_a.launch(pos_a, -1, attack_cycle, bounds_left, bounds_right)
	echo_b.launch(pos_b, 1, attack_cycle, bounds_left, bounds_right)
	
	echo_a.dissolved.connect(func(): active_echoes.erase(echo_a))
	echo_b.dissolved.connect(func(): active_echoes.erase(echo_b))

func _enter_recovery() -> void:
	if attack_source != null:
		attack_source.set_active(false)
	var rec_time: float = 0.90 if phase == 1 else (0.75 if phase == 2 else 0.60)
	_set_state(State.RECOVERY, rec_time)
	attack_completed.emit(current_attack)
