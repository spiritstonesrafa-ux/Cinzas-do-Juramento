class_name ForestSpectralCrow
extends CharacterBody2D
## Inimigo aéreo espectral para a Floresta dos Ossos (M6-C1).
## Alvo ideal para o golpe aéreo ('J' no ar), telegrafia de mergulho (0.45s)
## e guarda de frustum de câmera para evitar ataques fora da tela.

const ForestCrowAttackSource = preload("res://scripts/enemies/forest_crow_attack_source.gd")

signal defeated

enum State { IDLE, PATROL, ALERT, DIVE, RECOVER, HURT, DEAD }

@export var encounter_id: String = ""
@export_range(1, 99, 1) var max_health: int = 2
@export_range(1, 9, 1) var damage: int = 1
@export var patrol_speed: float = 24.0
@export var dive_speed: float = 90.0
@export var detection_distance: float = 110.0
@export var perception_distance: float = 190.0
@export var alert_duration: float = 0.45
@export var attack_interval: float = 1.8
@export var recovery_duration: float = 0.50
@export var patrol_half_width: float = 25.0
@export var max_dive_distance: float = 110.0
@export var max_vertical_detection: float = 60.0
@export var idle_duration: float = 0.3
@export var hurt_duration: float = 0.18

var state: State = State.IDLE
var current_health: int = 2
var facing: int = 1
var target: KnightController
var origin: Vector2
var dive_direction: Vector2 = Vector2.ZERO
var dive_destination: Vector2 = Vector2.ZERO
var flight_time: float = 0.0
var _timer: float = 0.0
var _cooldown: float = 0.0
var _perception_pause: float = 0.0
var flight_scan_enabled: bool = false
var flight_min_x: float = -INF
var flight_max_x: float = INF
var _flight_scanned: bool = false

@onready var attack_source: ForestCrowAttackSource = $AttackSource
@onready var hurt_shape: CollisionShape2D = $SwordReceiver/CollisionShape2D
@onready var body_shape: CollisionShape2D = $CollisionShape2D
@onready var visual: Node2D = $Visual

func _ready() -> void:
	process_physics_priority = -1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	origin = global_position
	if $SwordReceiver.has_signal("hit_received"):
		$SwordReceiver.hit_received.connect(receive_hit)
	reset_enemy()

func reset_enemy() -> void:
	global_position = origin
	velocity = Vector2.ZERO
	current_health = maxi(1, max_health)
	state = State.IDLE
	facing = 1
	flight_time = 0.0
	dive_direction = Vector2.ZERO
	dive_destination = origin
	_timer = idle_duration
	_cooldown = 0.0
	_perception_pause = 0.0
	if is_instance_valid(attack_source):
		attack_source.damage = damage
		attack_source.set_active(false)
	if is_instance_valid(hurt_shape):
		hurt_shape.disabled = false
	if is_instance_valid(body_shape):
		body_shape.disabled = false
	_sync_visual()

func receive_hit() -> void:
	if state == State.DEAD:
		return
	current_health = maxi(0, current_health - 1)
	velocity = Vector2.ZERO
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
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

func visible_for_attack() -> bool:
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return true # Em testes sem câmera, permite execução determinística
	var size: Vector2 = get_viewport_rect().size / camera.zoom
	var view: Rect2 = Rect2(camera.get_screen_center_position() - size * 0.5, size).grow(-8.0)
	return view.encloses(Rect2(global_position - Vector2(12, 12), Vector2(24, 24)))

func _can_alert() -> bool:
	if _cooldown > 0.0 or not is_instance_valid(target) or target.survival.is_dead:
		return false
	if not target.is_on_floor() or not visible_for_attack():
		return false
	var aim: Vector2 = target.global_position + Vector2(0, -14)
	var offset: Vector2 = aim - global_position
	if offset.length() > detection_distance or absf(aim.y - origin.y) > max_vertical_detection:
		return false
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, aim, 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _perceives_target() -> bool:
	if not is_instance_valid(target) or target.survival.is_dead:
		return false
	var aim: Vector2 = target.global_position + Vector2(0, -14)
	if global_position.distance_to(aim) > maxf(perception_distance, detection_distance) or absf(aim.y - origin.y) > max_vertical_detection:
		return false
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(global_position, aim, 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _begin_alert() -> void:
	var offset: Vector2 = target.global_position + Vector2(0, -14) - global_position
	dive_direction = offset.normalized()
	dive_destination = global_position + dive_direction * minf(offset.length(), max_dive_distance)
	if absf(dive_direction.x) > 0.01:
		facing = 1 if dive_direction.x > 0.0 else -1
	state = State.ALERT
	_timer = alert_duration
	_cooldown = attack_interval
	velocity = Vector2.ZERO

func _begin_recover() -> void:
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
	state = State.RECOVER
	_timer = recovery_duration
	velocity = Vector2.ZERO

func _scan_flight_patrol() -> void:
	_flight_scanned = true
	var safe_width := 0.0
	var spawn_transform: Transform2D = global_transform
	spawn_transform.origin = origin
	for step in range(1, 16):
		var distance: float = float(step) * 4.0
		if origin.x - distance < flight_min_x or origin.x + distance > flight_max_x:
			break
		if test_move(spawn_transform, Vector2(-distance, 0)) or test_move(spawn_transform, Vector2(distance, 0)):
			break
		safe_width = distance
	patrol_half_width = safe_width

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return
	if flight_scan_enabled and not _flight_scanned:
		_scan_flight_patrol()
	flight_time += delta
	_cooldown = maxf(0.0, _cooldown - delta)
	_perception_pause = maxf(0.0, _perception_pause - delta)
	velocity = Vector2.ZERO
	if is_instance_valid(target) and target.survival.is_dead:
		if is_instance_valid(attack_source):
			attack_source.set_active(false)
		state = State.IDLE
		_timer = idle_duration
		_sync_visual()
		return
	
	match state:
		State.IDLE:
			_timer -= delta
			if _can_alert():
				_begin_alert()
			elif _timer <= 0.0:
				state = State.PATROL
		State.PATROL:
			if _can_alert():
				_begin_alert()
			else:
				# Keep the dive's shorter attack gate and camera telegraph intact.
				if _perception_pause <= 0.0 and _perceives_target():
					var dx: float = target.global_position.x - global_position.x
					if absf(dx) > 4.0:
						facing = 1 if dx > 0.0 else -1
				var motion: Vector2 = Vector2(facing * patrol_speed * delta, 0)
				if absf(global_position.x + motion.x - origin.x) > patrol_half_width:
					facing *= -1
					_perception_pause = 1.5
				elif move_and_collide(motion) != null:
					facing *= -1
					_perception_pause = 1.5
				else:
					velocity = motion / delta
		State.ALERT:
			_timer -= delta
			if _timer <= 0.00001:
				if visible_for_attack():
					state = State.DIVE
					if is_instance_valid(attack_source):
						attack_source.damage = damage
						attack_source.set_active(true)
				else:
					_begin_recover()
		State.DIVE:
			var distance: float = global_position.distance_to(dive_destination)
			var motion: Vector2 = dive_direction * minf(dive_speed * delta, distance)
			velocity = motion / delta
			var collision: KinematicCollision2D = move_and_collide(motion)
			if collision != null or distance <= dive_speed * delta + 0.01:
				_begin_recover()
		State.HURT:
			_timer -= delta
			if _timer <= 0.00001:
				_begin_recover()
		State.RECOVER:
			_timer -= delta
			if _timer <= 0.00001:
				var offset: Vector2 = origin - global_position
				if offset.length() <= 0.1:
					state = State.PATROL
				else:
					velocity = offset.normalized() * patrol_speed
					move_and_collide(offset.limit_length(patrol_speed * delta))
					if absf(velocity.x) > 0.1:
						facing = 1 if velocity.x > 0.0 else -1
	_sync_visual()

func _sync_visual() -> void:
	if is_instance_valid(visual):
		visual.scale.x = float(facing)
		visual.queue_redraw()
