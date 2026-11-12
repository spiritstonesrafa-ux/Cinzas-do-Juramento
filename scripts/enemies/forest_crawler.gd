class_name ForestCrawler
extends CharacterBody2D
## Inimigo terrestre rastejante de baixo perfil para a Floresta dos Ossos (M6-C1).
## Altura 18 px garante sobreposição garantida de 11 px com o golpe de espada no solo.
## Possui esquiva de precipícios e telegrafia de 0.30s antes do bote.

const ForestCrawlerAttackSource = preload("res://scripts/enemies/forest_crawler_attack_source.gd")

signal defeated

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEAD }
enum AttackPhase { WINDUP, ACTIVE, RECOVERY }

@export var encounter_id: String = ""
@export_range(1, 99, 1) var max_health: int = 2
@export_range(1, 9, 1) var damage: int = 1
@export var patrol_speed: float = 45.0
@export var chase_speed: float = 55.0
@export var detection_distance: float = 155.0
@export var attack_distance: float = 24.0
@export var attack_interval: float = 1.0
@export var patrol_left: float = -40.0
@export var patrol_right: float = 40.0
@export var lost_target_delay: float = 0.5
@export var idle_duration: float = 0.3
@export var windup_duration: float = 0.30
@export var active_duration: float = 0.12
@export var recovery_duration: float = 0.35
@export var hurt_duration: float = 0.18

var state: State = State.IDLE
var attack_phase: AttackPhase = AttackPhase.WINDUP
var facing: int = 1
var current_health: int = 2
var target: KnightController
var origin: Vector2
var _timer: float = 0.0
var _cooldown: float = 0.0
var _lost_time: float = 0.0
var _reacquire_delay: float = 0.0
var _last_seen_x: float = 0.0

@onready var attack_source: ForestCrawlerAttackSource = $AttackSource
@onready var hurt_shape: CollisionShape2D = $SwordReceiver/CollisionShape2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

func _ready() -> void:
	process_physics_priority = -1
	origin = global_position
	if $SwordReceiver.has_signal("hit_received"):
		$SwordReceiver.hit_received.connect(receive_hit)
	reset_enemy()

func reset_enemy() -> void:
	global_position = origin
	velocity = Vector2.ZERO
	current_health = maxi(1, max_health)
	state = State.IDLE
	attack_phase = AttackPhase.WINDUP
	_timer = idle_duration
	_cooldown = 0.0
	_lost_time = 0.0
	_reacquire_delay = 0.0
	_last_seen_x = origin.x
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
		attack_source.position = Vector2(12 * facing, -7)
		attack_source.damage = damage
	if is_instance_valid(hurt_shape):
		hurt_shape.disabled = false
	if is_instance_valid(body_shape):
		body_shape.disabled = false
	_sync_visual()

func receive_hit() -> void:
	if state == State.DEAD:
		return
	current_health = maxi(0, current_health - 1)
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
	velocity = Vector2.ZERO
	if current_health == 0:
		state = State.DEAD
		if is_instance_valid(hurt_shape):
			hurt_shape.disabled = true
		if is_instance_valid(body_shape):
			body_shape.disabled = true
		defeated.emit()
	else:
		state = State.HURT
		_timer = hurt_duration
	_sync_visual()

func force_dead() -> void:
	current_health = 0
	state = State.DEAD
	if is_instance_valid(hurt_shape):
		hurt_shape.disabled = true
	if is_instance_valid(body_shape):
		body_shape.disabled = true
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
	velocity = Vector2.ZERO
	_sync_visual()

func disarm() -> void:
	if is_instance_valid(attack_source):
		attack_source.set_active(false)

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	_cooldown = maxf(0.0, _cooldown - delta)
	_reacquire_delay = maxf(0.0, _reacquire_delay - delta)
	if is_instance_valid(target) and target.survival.is_dead:
		if is_instance_valid(attack_source):
			attack_source.set_active(false)
		state = State.IDLE
		_timer = idle_duration
		velocity = Vector2.ZERO
		_sync_visual()
		return
	
	velocity.x = 0.0
	if state == State.ATTACK:
		_tick_attack(delta)
	elif state == State.HURT:
		_timer -= delta
		if _timer <= 0.0:
			state = State.IDLE
			_timer = idle_duration
	else:
		_tick_navigation(delta)
	
	velocity.y = minf(velocity.y + 680.0 * delta, 360.0)
	move_and_slide()
	_sync_visual()

func _sees_target() -> bool:
	if not is_instance_valid(target) or target.survival.is_dead:
		return false
	var offset: Vector2 = target.global_position - global_position
	if absf(offset.x) > detection_distance or absf(offset.y) > 24.0:
		return false
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -9), target.global_position + Vector2(0, -14), 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _visible_for_attack() -> bool:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return true
	var size: Vector2 = get_viewport_rect().size / camera.zoom
	var view := Rect2(camera.get_screen_center_position() - size * 0.5, size).grow(-4.0)
	return view.has_point(global_position + Vector2(0, -9))

func _tick_navigation(delta: float) -> void:
	var sees: bool = _sees_target()
	if sees and _reacquire_delay <= 0.0:
		_lost_time = 0.0
		_last_seen_x = target.global_position.x
		state = State.CHASE
	elif state == State.CHASE:
		_lost_time += delta
		if _lost_time >= lost_target_delay:
			state = State.IDLE
			_timer = idle_duration
	
	if state == State.CHASE:
		if not is_instance_valid(target):
			return
		var offset: float = _last_seen_x - global_position.x
		if absf(offset) > 0.1:
			facing = 1 if offset > 0.0 else -1
		if not sees and absf(offset) <= 1.0:
			return
		if sees and absf(offset) <= attack_distance and _visible_for_attack():
			if _cooldown == 0.0 and is_on_floor():
				state = State.ATTACK
				attack_phase = AttackPhase.WINDUP
				_timer = windup_duration
				_cooldown = attack_interval
				if is_instance_valid(attack_source):
					attack_source.position.x = 12.0 * facing
			return
		if not _walk(chase_speed, delta):
			state = State.IDLE
			_timer = idle_duration
			_reacquire_delay = 1.5
			facing *= -1
	elif state == State.IDLE:
		_timer -= delta
		if _timer <= 0.0:
			state = State.PATROL
	elif state == State.PATROL:
		if not _walk(patrol_speed, delta):
			facing *= -1
			state = State.IDLE
			_timer = idle_duration

func _walk(speed: float, delta: float) -> bool:
	var next_x: float = global_position.x + facing * speed * delta
	if (next_x < origin.x + patrol_left and facing < 0) or (next_x > origin.x + patrol_right and facing > 0):
		return false
	var ahead: float = facing * (12.0 + speed * delta)
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	# Raio do chão (precipício)
	var floor_ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(ahead, -2), global_position + Vector2(ahead, 10), 1)
	# Raio da parede
	var wall_ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position + Vector2(0, -6), global_position + Vector2(ahead, -6), 1)
	if space.intersect_ray(floor_ray).is_empty() or not space.intersect_ray(wall_ray).is_empty():
		return false
	velocity.x = facing * speed
	return true

func _tick_attack(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.00001:
		match attack_phase:
			AttackPhase.WINDUP:
				attack_phase = AttackPhase.ACTIVE
				_timer += active_duration
				if is_instance_valid(attack_source):
					attack_source.damage = damage
					attack_source.position.x = 12.0 * facing
					attack_source.set_active(true)
				velocity.x = facing * 60.0
			AttackPhase.ACTIVE:
				attack_phase = AttackPhase.RECOVERY
				_timer += recovery_duration
				if is_instance_valid(attack_source):
					attack_source.set_active(false)
				velocity.x = 0.0
			AttackPhase.RECOVERY:
				state = State.IDLE
				_timer = idle_duration

func _sync_visual() -> void:
	if is_instance_valid(visual):
		visual.scale.x = float(facing)
		visual.queue_redraw()
