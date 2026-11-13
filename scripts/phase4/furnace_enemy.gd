class_name FurnaceEnemy
extends CharacterBody2D
## Shared combat and animation controller for the Fornalha's three enemy types.

enum Kind { SLAG_MINER, ASH_CRAWLER, SMOKE_CROW }
enum State { IDLE, PATROL, CHASE, WARNING, ATTACK, RECOVERY, HURT, DEAD }

const SWORD_RECEIVER: Script = preload("res://scripts/combat/sword_receiver.gd")
const ATTACK_SCRIPT: Script = preload("res://scripts/phase4/furnace_enemy_attack.gd")
const EMBER_SCRIPT: Script = preload("res://scripts/phase4/furnace_ember.gd")
const MINER_SHEET: Texture2D = preload("res://assets/art/m4a/furnace_enemies/slag_miner_16f.png")
const CRAWLER_SHEET: Texture2D = preload("res://assets/art/m4a/furnace_enemies/ash_crawler_16f.png")
const CROW_SHEET: Texture2D = preload("res://assets/art/m4a/furnace_enemies/smoke_crow_16f.png")
const CELL_SIZE := Vector2(313.5, 313.5)

var kind: Kind = Kind.SLAG_MINER
var state: State = State.PATROL
var health := 2
var damage := 1
var contact_damage_enabled := true
var target: KnightController
var facing := -1
var origin := Vector2.ZERO
var patrol_min := 0.0
var patrol_max := 0.0
var state_timer := 0.0
var cooldown := 0.0
var animation_clock := 0.0
var dead_clock := 0.0
var lost_target_time := 0.0
var reacquire_delay := 0.0
var patrol_pause := 0.0
var idle_duration := 0.28
var lost_target_delay := 0.55
var death_duration := 0.34
var death_start_rotation := 0.0
var _visual: Sprite2D
var _body_shape: CollisionShape2D
var _hurt_shape: CollisionShape2D
var _attack_source: Area2D

func configure(enemy_kind: int, player: KnightController, roam_left: float, roam_right: float) -> void:
	kind = enemy_kind
	target = player
	patrol_min = roam_left
	patrol_max = roam_right
	if kind == Kind.SLAG_MINER:
		health = 3
	elif kind == Kind.ASH_CRAWLER:
		health = 2
	else:
		health = 2

func _ready() -> void:
	process_physics_priority = -1
	collision_layer = 128
	collision_mask = 1
	floor_snap_length = 3.0
	origin = global_position
	if kind == Kind.SMOKE_CROW:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
		collision_mask = 0
	_build_body()
	_build_receiver()
	_build_visual()
	if kind != Kind.SMOKE_CROW:
		_build_attack_source()

func _build_body() -> void:
	var shape := RectangleShape2D.new()
	if kind == Kind.SLAG_MINER:
		shape.size = Vector2(13, 26)
	elif kind == Kind.ASH_CRAWLER:
		shape.size = Vector2(22, 11)
	else:
		var circle := CircleShape2D.new()
		circle.radius = 10.0
		_body_shape = CollisionShape2D.new()
		_body_shape.shape = circle
		_body_shape.position.y = -2.0
		add_child(_body_shape)
		return
	_body_shape = CollisionShape2D.new()
	_body_shape.shape = shape
	_body_shape.position.y = -shape.size.y * 0.5
	add_child(_body_shape)

func _build_receiver() -> void:
	var receiver := Area2D.new()
	receiver.name = "SwordReceiver"
	receiver.collision_layer = 8
	receiver.collision_mask = 4
	receiver.monitoring = false
	receiver.monitorable = true
	receiver.set_script(SWORD_RECEIVER)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(18, 27) if kind == Kind.SLAG_MINER else (Vector2(25, 16) if kind == Kind.ASH_CRAWLER else Vector2(20, 18))
	shape.shape = rect
	shape.position.y = -rect.size.y * 0.5 if kind != Kind.SMOKE_CROW else -2.0
	receiver.add_child(shape)
	add_child(receiver)
	receiver.hit_received.connect(receive_hit)
	_hurt_shape = shape

func _build_visual() -> void:
	_visual = Sprite2D.new()
	_visual.name = "AnimatedSprite"
	_visual.texture = MINER_SHEET if kind == Kind.SLAG_MINER else (CRAWLER_SHEET if kind == Kind.ASH_CRAWLER else CROW_SHEET)
	_visual.region_enabled = true
	_visual.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	if kind == Kind.SLAG_MINER:
		_visual.scale = Vector2(0.14, 0.14)
		_visual.position.y = -21.5
	elif kind == Kind.ASH_CRAWLER:
		_visual.scale = Vector2(0.14, 0.14)
		_visual.position.y = -13.0
	else:
		_visual.scale = Vector2(0.12, 0.12)
		_visual.position.y = -4.0
	add_child(_visual)

func _build_attack_source() -> void:
	_attack_source = ATTACK_SCRIPT.new() as Area2D
	_attack_source.name = "AttackSource"
	_attack_source.call("configure", self, Vector2(26, 18) if kind == Kind.SLAG_MINER else Vector2(26, 14))
	_attack_source.set("damage", damage)
	add_child(_attack_source)

func _physics_process(delta: float) -> void:
	animation_clock += delta
	cooldown = maxf(0.0, cooldown - delta)
	reacquire_delay = maxf(0.0, reacquire_delay - delta)
	patrol_pause = maxf(0.0, patrol_pause - delta)
	if state == State.DEAD:
		dead_clock += delta
		if not is_on_floor():
			velocity.y = minf(velocity.y + 680.0 * delta, 360.0)
			move_and_slide()
		else:
			velocity = Vector2.ZERO
		var death_t := clampf(dead_clock / death_duration, 0.0, 1.0)
		_visual.rotation = lerpf(death_start_rotation, -PI * 0.5, death_t)
		_visual.modulate = Color(0.48, 0.43, 0.38, 1.0).lerp(Color(0.35, 0.32, 0.30, 0.86), death_t)
		_update_frame()
		return
	if not is_instance_valid(target) or target.survival.is_dead:
		if _attack_source != null:
			_attack_source.call("set_active", false, facing)
		state = State.IDLE
		state_timer = idle_duration
		velocity.x = 0.0
		if kind == Kind.SMOKE_CROW:
			velocity.y = sin(animation_clock * 1.8) * 8.0
		else:
			velocity.y = minf(velocity.y + 680.0 * delta, 360.0)
			move_and_slide()
		_update_frame()
		return
	if kind == Kind.SMOKE_CROW:
		_tick_crow(delta)
	else:
		_tick_ground(delta)
	_update_frame()

func _tick_ground(delta: float) -> void:
	if state == State.HURT:
		velocity.x = move_toward(velocity.x, 0.0, 210.0 * delta)
	else:
		velocity.x = 0.0
	if state == State.PATROL or state == State.CHASE or state == State.IDLE:
		_tick_ground_navigation(delta)
	elif state == State.WARNING:
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.ATTACK
			state_timer = 0.20 if kind == Kind.SLAG_MINER else 0.24
			cooldown = 1.45 if kind == Kind.SLAG_MINER else 1.15
			if _attack_source != null:
				_attack_source.call("set_active", true, facing)
			if kind == Kind.ASH_CRAWLER:
				velocity.x = 82.0 * facing
				velocity.y = -48.0
	elif state == State.ATTACK:
		state_timer -= delta
		if kind == Kind.ASH_CRAWLER:
			velocity.x = move_toward(velocity.x, 0.0, 170.0 * delta)
		if state_timer <= 0.0:
			if _attack_source != null:
				_attack_source.call("set_active", false, facing)
			state = State.RECOVERY
			state_timer = 0.62 if kind == Kind.SLAG_MINER else 0.48
	elif state == State.RECOVERY or state == State.HURT:
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.PATROL
	velocity.y = minf(velocity.y + 680.0 * delta, 360.0)
	move_and_slide()

func _sees_target() -> bool:
	if not is_instance_valid(target) or target.survival.is_dead:
		return false
	var offset: Vector2 = target.global_position - global_position
	var vertical_limit := 42.0 if kind == Kind.SLAG_MINER else 52.0
	var detect := 170.0 if kind == Kind.SLAG_MINER else 150.0
	if absf(offset.x) > detect or absf(offset.y) > vertical_limit:
		return false
	var ray := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -12), target.global_position + Vector2(0, -12), 1)
	return get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _tick_ground_navigation(delta: float) -> void:
	var sees := _sees_target()
	if sees and reacquire_delay <= 0.0:
		lost_target_time = 0.0
		state = State.CHASE
	elif state == State.CHASE:
		lost_target_time += delta
		if lost_target_time >= lost_target_delay:
			state = State.IDLE
			state_timer = idle_duration
	if state == State.CHASE:
		var dx: float = target.global_position.x - global_position.x
		var attack_reach := 38.0 if kind == Kind.SLAG_MINER else 58.0
		if absf(dx) > 0.1:
			facing = 1 if dx > 0.0 else -1
		if sees and absf(dx) <= attack_reach and cooldown <= 0.0 and is_on_floor():
			state = State.WARNING
			state_timer = 0.52 if kind == Kind.SLAG_MINER else 0.34
			return
		if absf(dx) > attack_reach * 0.72:
			var speed := 28.0 if kind == Kind.SLAG_MINER else 48.0
			if not _walk_ground(speed, delta):
				state = State.IDLE
				state_timer = idle_duration
				reacquire_delay = 1.1
				facing *= -1
	elif state == State.IDLE:
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.PATROL
	elif state == State.PATROL and patrol_pause <= 0.0:
		var speed := 20.0 if kind == Kind.SLAG_MINER else 37.0
		if not _walk_ground(speed, delta):
			facing *= -1
			state = State.IDLE
			state_timer = idle_duration
			patrol_pause = 0.12

func _walk_ground(speed: float, delta: float) -> bool:
	var next_x: float = global_position.x + facing * speed * delta
	if (next_x < patrol_min and facing < 0) or (next_x > patrol_max and facing > 0):
		return false
	var ahead := facing * (10.0 + speed * delta)
	var space := get_world_2d().direct_space_state
	var floor_ray := PhysicsRayQueryParameters2D.create(global_position + Vector2(ahead, -2), global_position + Vector2(ahead, 12), 1)
	var wall_ray := PhysicsRayQueryParameters2D.create(global_position + Vector2(0, -12), global_position + Vector2(ahead, -12), 1)
	if space.intersect_ray(floor_ray).is_empty() or not space.intersect_ray(wall_ray).is_empty():
		return false
	velocity.x = facing * speed
	return true

func _has_ground_ahead() -> bool:
	var ahead := facing * 11.0
	var ray := PhysicsRayQueryParameters2D.create(global_position + Vector2(ahead, -1), global_position + Vector2(ahead, 10), 1)
	return not get_world_2d().direct_space_state.intersect_ray(ray).is_empty()

func _tick_crow(delta: float) -> void:
	if state == State.IDLE:
		velocity = Vector2.ZERO
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.PATROL
	elif state == State.PATROL:
		var dx := target.global_position.x - global_position.x
		var dy := target.global_position.y - global_position.y
		velocity.x = facing * 24.0
		velocity.y = sin(animation_clock * 2.5) * 12.0
		if global_position.x <= patrol_min: facing = 1
		elif global_position.x >= patrol_max: facing = -1
		if absf(dx) < 150.0 and absf(dy) < 100.0 and cooldown <= 0.0:
			facing = 1 if dx > 0.0 else -1
			velocity = Vector2.ZERO
			state = State.WARNING
			state_timer = 0.55
	elif state == State.WARNING:
		velocity = Vector2.ZERO
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.ATTACK
			state_timer = 0.14
			cooldown = 1.75
			var ember := EMBER_SCRIPT.new() as Area2D
			get_tree().current_scene.add_child(ember)
			var aim := (target.global_position + Vector2(0, -12)) - (global_position + Vector2(10 * facing, 2))
			ember.call("configure", global_position + Vector2(10 * facing, 2), aim)
	elif state == State.ATTACK:
		velocity = Vector2.ZERO
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.RECOVERY
			state_timer = 0.72
	elif state == State.RECOVERY or state == State.HURT:
		velocity = Vector2(0, sin(animation_clock * 2.5) * 7.0)
		state_timer -= delta
		if state_timer <= 0.0:
			state = State.PATROL
		move_and_slide()
	if state in [State.PATROL, State.WARNING, State.ATTACK]:
		move_and_slide()

func _update_frame() -> void:
	if _visual == null:
		return
	_visual.flip_h = facing < 0
	if state != State.DEAD:
		_visual.modulate = Color(1.8, 1.5, 1.25, 1.0) if state == State.HURT else Color.WHITE
	var frame := 0
	match state:
		State.PATROL:
			frame = (int(animation_clock * (12.0 if kind == Kind.ASH_CRAWLER else 9.0)) % 8) if absf(velocity.x) > 1.0 else 0
		State.WARNING:
			frame = 8 if state_timer > 0.24 else 9
		State.ATTACK:
			frame = 10 if state_timer > 0.10 else 11
		State.RECOVERY:
			frame = 12 + mini(3, int((0.62 - minf(state_timer, 0.62)) / 0.16))
		State.HURT:
			frame = 11
		State.DEAD:
			frame = 12
	_visual.region_rect = Rect2(Vector2(frame % 4, int(frame / 4)) * CELL_SIZE, CELL_SIZE)

func receive_hit() -> void:
	if state == State.DEAD:
		return
	health -= 1
	if _attack_source != null:
		_attack_source.call("set_active", false, facing)
	if health <= 0:
		health = 0
		state = State.DEAD
		dead_clock = 0.0
		death_start_rotation = _visual.rotation if is_instance_valid(_visual) else 0.0
		contact_damage_enabled = false
		collision_layer = 0
		if kind == Kind.SMOKE_CROW:
			motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
			collision_mask = 1
			_visual.position.y = -24.0
		if is_instance_valid(_hurt_shape):
			_hurt_shape.set_deferred("disabled", true)
		if is_instance_valid(_visual):
			_visual.modulate = Color(0.48, 0.43, 0.38, 1.0)
	else:
		state = State.HURT
		state_timer = 0.22
		velocity.x = -facing * 42.0
