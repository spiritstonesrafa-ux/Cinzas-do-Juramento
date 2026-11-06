class_name KnightController
extends CharacterBody2D
## M0 movement with an independent local M1 sword cycle.

enum MovementState { IDLE, RUN, JUMP, FALL, DEAD }

@export var speed: float = 100.0
@export var acceleration: float = 1200.0
@export var deceleration: float = 1600.0
@export var gravity: float = 680.0
@export var jump_impulse: float = -230.0
@export var max_fall_speed: float = 360.0
@export_range(0.0, 0.3, 0.01) var coyote_time: float = 0.10
@export_range(0.0, 0.3, 0.01) var jump_buffer_time: float = 0.10

var state: MovementState = MovementState.IDLE
var facing: int = 1
var _coyote_remaining: float = 0.0
var _buffer_remaining: float = 0.0
var active_checkpoint: RespawnCheckpoint
var _default_respawn: Vector2
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
@export var dash_speed: float = 260.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.75
var dash_unlocked: bool = false
var dash_remaining: float = 0.0
var dash_cooldown_remaining: float = 0.0
var dash_direction: int = 1

@onready var visual: Node2D = $Visual
@onready var sword_attack: SwordAttack = $SwordAttack
@onready var survival: KnightSurvival = $Survival
@onready var hurtbox: KnightHurtbox = $Hurtbox

func _ready() -> void:
	survival.died.connect(_on_died)
	dash_unlocked = ABBEY_PROGRESS.unlocked()
	if ABBEY_PROGRESS.guardian_reward_unlocked():
		survival.max_health = 6
		survival.restore()

func _on_died() -> void:
	dash_remaining = 0.0
	state = MovementState.DEAD
	velocity = Vector2.ZERO
	_coyote_remaining = 0.0
	_buffer_remaining = 0.0
	sword_attack.cancel()
	_update_survival_visual()

func _physics_process(delta: float) -> void:
	if survival.is_dead:
		survival.tick(delta)
		_update_survival_visual()
		return
	survival.tick(delta)
	dash_cooldown_remaining = maxf(0.0, dash_cooldown_remaining - delta)
	if dash_remaining > 0.0:
		dash_remaining = maxf(0.0, dash_remaining - delta)
		velocity.x = dash_direction * dash_speed
		velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
		move_and_slide()
		if is_on_wall(): dash_remaining = 0.0
		sword_attack.tick(delta, is_on_floor(), facing)
		_update_state()
		visual.queue_redraw()
		var dash_contact: int = hurtbox.contact_damage()
		if dash_contact > 0: receive_damage(dash_contact)
		_update_survival_visual()
		return
	if is_on_floor():
		_coyote_remaining = coyote_time
	else:
		_coyote_remaining = maxf(0.0, _coyote_remaining - delta)
	_buffer_remaining = maxf(0.0, _buffer_remaining - delta)
	var jump_pressed: bool = Input.is_action_just_pressed("jump")
	if jump_pressed:
		_buffer_remaining = jump_buffer_time

	var direction: float = Input.get_axis("move_left", "move_right")
	var rate: float = acceleration if direction != 0.0 else deceleration
	velocity.x = move_toward(velocity.x, direction * speed, rate * delta)
	if direction != 0.0:
		facing = 1 if direction > 0.0 else -1
		visual.scale.x = float(facing)

	velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
	if (jump_pressed or _buffer_remaining > 0.0) and (is_on_floor() or _coyote_remaining > 0.0):
		velocity.y = jump_impulse
		_coyote_remaining = 0.0
		_buffer_remaining = 0.0

	move_and_slide()
	sword_attack.tick(delta, is_on_floor(), facing)
	visual.scale.x = float(facing if sword_attack.phase == SwordAttack.Phase.NEUTRAL else sword_attack.direction)
	_update_state()
	visual.queue_redraw()
	var contact_damage: int = hurtbox.contact_damage()
	if contact_damage > 0:
		receive_damage(contact_damage)
	_update_survival_visual()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_SHIFT:
		if dash_unlocked and not survival.is_dead and is_on_floor() and dash_cooldown_remaining <= 0.0 and not sword_attack.aerial:
			var axis: float = Input.get_axis("move_left", "move_right")
			dash_direction = (1 if axis > 0.0 else -1) if axis != 0.0 else facing
			facing = dash_direction
			dash_remaining = dash_duration
			dash_cooldown_remaining = dash_cooldown
			sword_attack.cancel()

func receive_damage(amount: int = 1) -> bool:
	var received: bool = survival.receive_damage(amount)
	if received and sword_attack.aerial:
		sword_attack.cancel()
	return received

func _update_survival_visual() -> void:
	visual.rotation = -PI / 2.0 if survival.is_dead else 0.0
	if survival.is_dead:
		visual.modulate = Color(0.5, 0.5, 0.6, 0.65)
	elif survival.invulnerability_remaining > 0.0:
		var bright: bool = int(survival.invulnerability_remaining * 16.0) % 2 == 0
		visual.modulate = Color(1.0, 0.55, 0.55, 1.0 if bright else 0.45)
	else:
		visual.modulate = Color.WHITE

func set_default_respawn(spawn_position: Vector2) -> void:
	_default_respawn = spawn_position

func activate_checkpoint(checkpoint: RespawnCheckpoint) -> void:
	if survival.is_dead or checkpoint == active_checkpoint:
		return
	if not is_respawn_safe(checkpoint.respawn_point.global_position):
		return
	if is_instance_valid(active_checkpoint):
		active_checkpoint.set_active(false)
	active_checkpoint = checkpoint
	checkpoint.set_active(true)

func is_respawn_safe(spawn_position: Vector2) -> bool:
	# Inset prevents mere contact with the floor from counting as penetration.
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = Vector2(11.8, 23.8)
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0.0, spawn_position + Vector2(0, -12))
	query.collision_mask = 1 | 32 # World and damage sources, never sword/targets.
	query.collide_with_areas = true
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	if not space.intersect_shape(query, 1).is_empty():
		return false
	var support: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		spawn_position + Vector2(0, -0.1), spawn_position + Vector2(0, 3), 1)
	var floor_hit: Dictionary = space.intersect_ray(support)
	return not floor_hit.is_empty() and (floor_hit["normal"] as Vector2).y < -0.5

func respawn_at_checkpoint() -> void:
	var destination: Vector2 = _default_respawn
	if is_instance_valid(active_checkpoint):
		var candidate: Vector2 = active_checkpoint.respawn_point.global_position
		if is_respawn_safe(candidate):
			destination = candidate
	if not is_respawn_safe(destination):
		push_warning("Respawn blocked: author a safe default spawn/checkpoint marker.")
		return
	reset_to(destination)
	survival.restore()
	_update_survival_visual()

func _update_state() -> void:
	if not is_on_floor():
		state = MovementState.JUMP if velocity.y < 0.0 else MovementState.FALL
	else:
		state = MovementState.RUN if absf(velocity.x) > 0.1 else MovementState.IDLE

func reset_to(spawn_position: Vector2) -> void:
	sword_attack.cancel()
	sword_attack.reset_air_cycle()
	dash_remaining = 0.0
	global_position = spawn_position
	velocity = Vector2.ZERO
	_coyote_remaining = 0.0
	_buffer_remaining = 0.0
	state = MovementState.IDLE
	facing = 1
	visual.scale.x = 1.0
	visual.queue_redraw()
