extends SceneTree

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")

var _failures: int = 0
var _checks: int = 0

func _init() -> void:
	call_deferred("_run")

func check(condition: bool, label: String) -> void:
	_checks += 1
	if condition:
		print("PASS ", label)
	else:
		_failures += 1
		printerr("FAIL ", label)

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _build_floor(parent: Node2D, from_x: float, to_x: float, y: float) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(absf(to_x - from_x), 20.0)
	shape.shape = rect
	shape.position = Vector2((from_x + to_x) * 0.5, y + 10.0)
	body.add_child(shape)
	parent.add_child(body)
	return body

func _build_wall(parent: Node2D, x: float, y_top: float, y_bottom: float) -> StaticBody2D:
	var body: StaticBody2D = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var shape: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	rect.size = Vector2(20.0, absf(y_bottom - y_top))
	shape.shape = rect
	shape.position = Vector2(x, (y_top + y_bottom) * 0.5)
	body.add_child(shape)
	parent.add_child(body)
	return body

func _trigger_dash(hero: KnightController) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_SHIFT
	event.pressed = true
	event.echo = false
	hero._unhandled_key_input(event)

func _run() -> void:
	print("--- INICIANDO TESTES DO DASH VFX (PASSO DAS SOMBRAS) ---")

	var world: Node2D = Node2D.new()
	root.add_child(world)

	# Long floor for dashing
	_build_floor(world, -400.0, 800.0, 100.0)

	var hero: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	world.add_child(hero)
	hero.global_position = Vector2(0.0, 95.0)
	hero.dash_unlocked = true
	hero.dash_cooldown_remaining = 0.0

	await _frames(10)
	check(hero.is_on_floor(), "hero rests safely on floor")
	var visual: Node2D = hero.get_node("Visual")
	check(visual != null, "hero has Visual node")

	# ========================================================
	# TEST 1: DASH TO THE RIGHT (INÍCIO, MEIO, FIM)
	# ========================================================
	hero.facing = 1
	_trigger_dash(hero)
	await _frames(1)

	check(hero.dash_remaining > 0.0, "1.1: Right dash activated (dash_remaining > 0)")
	check(visual._dash_start_timer > 0.0, "1.2: Start timer activated")
	check(visual._dash_start_facing == 1, "1.3: Start facing recorded as +1")
	check(visual._dash_debris.size() >= 5, "1.4: Start stone pebbles spawned (>= 5)")
	check(visual._dash_debris[0].vel.x < 0.0, "1.5: Start pebbles kick backward (vel.x < 0 for right dash)")
	check(visual._dash_dust.size() >= 3, "1.6: Start dust puffs spawned")

	# Step into mid dash
	await _frames(4)
	check(hero.dash_remaining > 0.0, "1.7: Mid dash active")
	check(visual._dash_ghosts.size() > 0, "1.8: Afterimages (ghosts) spawned during motion")
	check(visual._dash_ghosts[0].facing == 1, "1.9: Afterimage facing is +1")
	check(visual._dash_wisps.size() > 0, "1.10: Trailing billowing smoke wisps active")

	# Wait for dash to finish
	await _frames(8)
	check(hero.dash_remaining == 0.0, "1.11: Dash travel completed")
	check(visual._dash_end_timer > 0.0, "1.12: End braking timer activated")
	check(visual._dash_end_facing == 1, "1.13: End braking facing recorded as +1")

	# Check braking debris kicked forward
	var found_forward_pebble: bool = false
	for deb: Dictionary in visual._dash_debris:
		if deb.vel.x > 0.0:
			found_forward_pebble = true
			break
	check(found_forward_pebble, "1.14: Braking pebbles kicked forward (vel.x > 0)")

	# Wait out braking and start timers
	await _frames(20)
	check(visual._dash_start_timer == 0.0, "1.15: Start sigil gracefully dissipated")
	check(visual._dash_end_timer == 0.0, "1.16: Braking sparks gracefully dissipated")

	# ========================================================
	# TEST 2: DASH TO THE LEFT (MIRRORED VFX)
	# ========================================================
	hero.dash_cooldown_remaining = 0.0
	hero.facing = -1
	hero.global_position = Vector2(200.0, 100.0)
	await _frames(10)
	check(hero.is_on_floor(), "hero rests safely on floor for left dash")

	_trigger_dash(hero)
	await _frames(1)

	check(hero.dash_remaining > 0.0, "2.1: Left dash activated")
	check(visual._dash_start_facing == -1, "2.2: Left dash start facing recorded as -1")
	check(visual._dash_debris[0].vel.x > 0.0, "2.3: Start pebbles kick backward (vel.x > 0 for left dash)")

	await _frames(4)
	check(visual._dash_ghosts.size() > 0, "2.4: Left afterimages spawned")
	check(visual._dash_ghosts[visual._dash_ghosts.size() - 1].facing == -1, "2.5: Left afterimage facing is -1")

	await _frames(8)
	check(hero.dash_remaining == 0.0, "2.6: Left dash completed")
	check(visual._dash_end_facing == -1, "2.7: Left braking facing recorded as -1")

	var found_left_forward_pebble: bool = false
	for deb: Dictionary in visual._dash_debris:
		if deb.vel.x < 0.0:
			found_left_forward_pebble = true
			break
	check(found_left_forward_pebble, "2.8: Left braking pebbles kicked forward to the left (vel.x < 0)")

	await _frames(20)

	# ========================================================
	# TEST 3: WALL COLLISION (CLEAN INTERRUPTION & IMPACT)
	# ========================================================
	# Build a solid wall at x = 120 (wall left edge at x = 110)
	_build_wall(world, 120.0, 40.0, 110.0)
	hero.global_position = Vector2(50.0, 100.0)
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	await _frames(10)
	check(hero.is_on_floor(), "hero rests on floor for wall dash")

	_trigger_dash(hero)
	await _frames(2)
	check(hero.dash_remaining > 0.0, "3.1: Dash toward wall initiated and in flight")

	# Dash moves toward wall at 260px/s, hits wall around frame 10
	await _frames(12)
	check(hero.dash_remaining == 0.0, "3.2: Wall collision cleanly stopped dash (dash_remaining == 0)")
	check(visual._dash_end_timer > 0.0, "3.3: Wall impact triggered braking VFX at contact point")

	await _frames(20)

	# ========================================================
	# TEST 4: PLAYER DEATH (IMMEDIATE CLEANUP OF VFX)
	# ========================================================
	hero.global_position = Vector2(-100.0, 100.0)
	hero.dash_cooldown_remaining = 0.0
	hero.facing = 1
	await _frames(10)
	check(hero.is_on_floor(), "hero rests on floor for death test")

	_trigger_dash(hero)
	await _frames(2)
	check(hero.dash_remaining > 0.0, "4.1: Dash in progress before lethal damage")
	check(visual._dash_ghosts.size() > 0 or visual._dash_debris.size() > 0, "4.2: VFX active before death")

	# Inflict lethal damage
	hero.survival.receive_damage(999)
	await _frames(2)

	check(hero.survival.is_dead, "4.3: Hero is dead")
	check(visual._dash_ghosts.is_empty(), "4.4: Afterimages cleared on death")
	check(visual._dash_wisps.is_empty(), "4.5: Smoke wisps cleared on death")
	check(visual._dash_debris.is_empty(), "4.6: Debris cleared on death")
	check(visual._dash_dust.is_empty(), "4.7: Dust cleared on death")
	check(visual._dash_start_timer == 0.0, "4.8: Start timer zeroed on death")
	check(visual._dash_end_timer == 0.0, "4.9: End timer zeroed on death")

	# ========================================================
	# TEST 5: COOLDOWN COMPLIANCE (NO FALSE EFFECTS)
	# ========================================================
	hero.survival.restore()
	hero.state = KnightController.MovementState.IDLE
	hero.global_position = Vector2(0.0, 100.0)
	hero.dash_cooldown_remaining = 0.60
	await _frames(10)
	check(hero.is_on_floor(), "hero rests on floor for cooldown test")

	var debris_count_before: int = visual._dash_debris.size()
	_trigger_dash(hero)
	await _frames(2)

	check(hero.dash_remaining == 0.0, "5.1: Shift ignored during cooldown")
	check(visual._dash_start_timer == 0.0, "5.2: No start sigil triggered during cooldown")
	check(visual._dash_debris.size() == debris_count_before, "5.3: No debris spawned during cooldown")

	# ========================================================
	# TEST 6: RESET / RESPAWN CLEANUP
	# ========================================================
	hero.dash_cooldown_remaining = 0.0
	_trigger_dash(hero)
	await _frames(2)
	check(hero.dash_remaining > 0.0, "6.1: Dash active before reset")

	hero.reset_to(Vector2(50.0, 95.0))
	await _frames(2)
	check(hero.dash_remaining == 0.0, "6.2: reset_to cancels dash_remaining")

	# Final cleanup
	world.queue_free()
	await _frames(3)

	print("\n--- RESULTADO FINAL DOS TESTES DO DASH VFX ---")
	print("TOTAL CHECKS: ", _checks, " | FALHAS: ", _failures)
	if _failures == 0:
		print("DASH VFX TEST SUITE: 100% PASS")
	else:
		printerr("DASH VFX TEST SUITE: FAILURES DETECTED")

	quit(0 if _failures == 0 else 1)
