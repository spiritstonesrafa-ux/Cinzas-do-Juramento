extends SceneTree
## Real physics/input regression for M1. Does not certify manual playtesting.

var _failures: int = 0
var _checks: int = 0
var _main: Node
var _stage: Node2D
var _knight: KnightController
var _attack: SwordAttack
var _target: TrainingTarget

func _initialize() -> void:
	_run.call_deferred()

func _frames(count: int) -> void:
	for frame: int in range(count):
		await physics_frame
		await process_frame

func _check(condition: bool, description: String) -> void:
	_checks += 1
	if condition:
		print("PASS: ", description)
	else:
		_failures += 1
		push_error("FAIL: " + description)

func _place(offset: float = 24.0, facing: int = 1) -> void:
	for action: String in ["attack", "jump", "move_left", "move_right"]:
		Input.action_release(action)
	_knight.reset_to(Vector2(450, 156))
	_knight.facing = facing
	_target.position = Vector2(450 + offset, 156)
	_target.hit_count = 0
	_target.flash_remaining = 0.0
	await _frames(3)

func _press_attack() -> void:
	Input.action_press("attack")
	await _frames(1)
	Input.action_release("attack")

func _swing() -> void:
	await _press_attack()
	await _frames(30)

func _run() -> void:
	_main = (load("res://tests/fixtures/baseline_main.tscn") as PackedScene).instantiate()
	root.add_child(_main)
	_stage = _main.get_node("PrototypeStage") as Node2D
	_knight = _stage.get_node("Knight") as KnightController
	_attack = _knight.sword_attack
	_target = _stage.get_node("TrainingTarget") as TrainingTarget
	await _place()
	_check(_attack.hit_shape.disabled, "Hitbox disabled at rest")
	_check(_target.collision_layer == 8 and _attack.hitbox.collision_mask == 8, "Explicit attack/target collision filtering")
	await _press_attack()
	_check(_attack.phase == SwordAttack.Phase.WINDUP, "Press starts windup")
	var saw_active: bool = false
	var saw_recovery: bool = false
	var gates_correct: bool = true
	var windup_safe: bool = true
	var active_hit: bool = false
	for frame: int in range(30):
		gates_correct = gates_correct and (_attack.hit_shape.disabled == (_attack.phase != SwordAttack.Phase.ACTIVE))
		if _attack.phase == SwordAttack.Phase.WINDUP:
			windup_safe = windup_safe and _target.hit_count == 0
		if _attack.phase == SwordAttack.Phase.ACTIVE:
			if not saw_active:
				active_hit = _target.hit_count == 1
			saw_active = true
		if _attack.phase == SwordAttack.Phase.RECOVERY:
			saw_recovery = true
		await _frames(1)
	_check(gates_correct and saw_active and saw_recovery, "Shape enabled only during active phase; full cycle completes")
	_check(windup_safe, "Windup cannot hit")
	_check(active_hit and _target.hit_count == 1, "Already-overlapping target hit on activation, exactly once per swing")
	_check(_attack.phase == SwordAttack.Phase.NEUTRAL, "Recovery returns to neutral")
	await _press_attack()
	await _frames(7)
	_check(_target.hit_count == 2 and _target.flash_remaining > 0.0, "Next swing hits again and restarts feedback")
	await _frames(25)

	await _place()
	Input.action_press("attack")
	await _frames(80)
	_check(_target.hit_count == 1 and _attack.phase == SwordAttack.Phase.NEUTRAL, "Held attack never auto-repeats")
	Input.action_release("attack")
	await _frames(2)
	await _swing()
	_check(_target.hit_count == 2, "Release and fresh press permit another swing")

	await _place()
	await _press_attack()
	await _press_attack() # Second press during preparation must be discarded.
	await _frames(13)
	_check(_attack.phase == SwordAttack.Phase.RECOVERY, "Repeated windup press did not restart the attack")
	await _press_attack() # No recovery queue.
	await _frames(40)
	_check(_target.hit_count == 1 and _attack.phase == SwordAttack.Phase.NEUTRAL, "Simultaneous/recovery presses neither restart nor queue attacks")
	await _place()
	await _press_attack()
	await _frames(7)
	await _press_attack()
	await _frames(30)
	_check(_target.hit_count == 1 and _attack.phase == SwordAttack.Phase.NEUTRAL, "Active-window press cannot restart or queue a swing")

	await _place(-24.0, -1)
	await _swing()
	_check(_target.hit_count == 1, "Left-facing sword hits target on left")
	await _place(-24.0, 1)
	await _swing()
	_check(_target.hit_count == 0, "Target behind player receives no hit")
	await _place(50.0)
	await _swing()
	_check(_target.hit_count == 0, "Target beyond reach receives no hit")

	await _place()
	await _press_attack()
	Input.action_press("move_left")
	await _frames(7)
	_check(_knight.facing == -1 and _attack.direction == 1 and _knight.visual.scale.x == 1.0, "Turning movement does not turn sword or attack pose")
	_check(_attack.hitbox.position.x > 0.0, "Hitbox retains starting side")
	Input.action_release("move_left")
	await _frames(30)

	await _place()
	var wall: StaticBody2D = StaticBody2D.new()
	wall.collision_layer = 1
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle: RectangleShape2D = RectangleShape2D.new()
	rectangle.size = Vector2(2, 40)
	shape.shape = rectangle
	wall.add_child(shape)
	wall.position = Vector2(460, 136)
	_stage.add_child(wall)
	await _frames(3)
	await _swing()
	_check(_target.hit_count == 0, "Thin solid wall blocks sword hits")
	rectangle.size = Vector2(2, 2)
	await _frames(3)
	await _swing()
	_check(_target.hit_count == 0, "Obstacle at blade edge blocks hits even off the center ray")
	wall.queue_free()
	await _frames(3)
	await _swing()
	_check(_target.hit_count == 1, "Same target is hittable after wall removal")

	await _place(50.0)
	await _press_attack()
	await _frames(13) # Recovery: move a fresh target into the hitbox.
	_target.position.x = 474
	await _frames(20)
	_check(_target.hit_count == 0, "Recovery overlap cannot produce a hit")
	await _place()
	_target.position.x = 510
	await _press_attack()
	await _frames(8)
	_target.position.x = 474
	await _frames(3)
	_check(_target.hit_count == 1, "Target entering during active window also receives one hit")

	await _place()
	_knight.reset_to(Vector2(450, 80))
	await _frames(3)
	await _press_attack()
	_check(_attack.aerial and _attack.phase != SwordAttack.Phase.NEUTRAL, "M5-H: airborne J starts an aerial attack")
	await _frames(50)
	_check(_attack.phase == SwordAttack.Phase.NEUTRAL, "Airborne press does not queue on landing")
	await _place()
	await _press_attack()
	Input.action_press("jump")
	await _frames(1)
	Input.action_release("jump")
	_check(_knight.velocity.y < 0.0 and _attack.phase != SwordAttack.Phase.NEUTRAL, "Jump is preserved and ground-started swing continues in air")
	await _frames(35)
	_check(_attack.phase == SwordAttack.Phase.NEUTRAL, "Airborne cycle finishes normally")

	for delay: int in [0, 7, 14]:
		await _place()
		await _press_attack()
		await _frames(delay)
		_knight.position.y = 225
		await _frames(1)
		_check(_attack.phase == SwordAttack.Phase.NEUTRAL and _attack.hit_shape.disabled, "Fall return cancels phase at delay %d" % delay)
		_check(_knight.position.distance_to(Vector2(48, 156)) < 0.1 and _knight.velocity == Vector2.ZERO, "Fall return restores safe spawn and zero velocity")
		_target.position = Vector2(72, 156)
		var hits_before: int = _target.hit_count
		await _frames(30)
		_check(_target.hit_count == hits_before, "No ghost hits after fall cancellation")
	_main.queue_free()
	await _frames(1)
	print("M1 checks: ", _checks, "; failures: ", _failures)
	quit(0 if _failures == 0 else 1)
