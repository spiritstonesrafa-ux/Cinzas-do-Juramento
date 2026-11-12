extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	world.add_child(camera)
	camera.make_current()
	var floor_body := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(700, 20)
	collision.shape = rect
	collision.position = Vector2(0, 10)
	floor_body.add_child(collision)
	world.add_child(floor_body)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(35, 0)
	world.add_child(hero)
	var failed := false
	for path in ["res://scenes/enemies/cursed_raven.tscn", "res://scenes/enemies/forest_spectral_crow.tscn"]:
		hero.survival.restore()
		hero.reset_to(Vector2(35, 0))
		var bird: CharacterBody2D = load(path).instantiate()
		bird.position = Vector2(0, -30)
		world.add_child(bird)
		bird.target = hero
		var warned := false
		for frame in range(90):
			await physics_frame
			if bird.state == bird.State.ALERT:
				warned = true
				break
		var locked: Vector2 = bird.dive_direction
		var saw_dive := false
		var recover := false
		var stayed_locked := true
		var hp := hero.survival.current_health
		Input.action_press("move_right")
		for frame in range(120):
			await physics_frame
			if bird.state == bird.State.DIVE:
				saw_dive = true
				stayed_locked = stayed_locked and bird.dive_direction == locked
			if saw_dive and bird.state == bird.State.RECOVER:
				recover = true
				break
		Input.action_release("move_right")
		var evaded := hero.survival.current_health == hp
		print("AIR_EVASION ", bird.name, " warned=", warned, " dive=", saw_dive, " fixed=", stayed_locked, " recover=", recover, " evaded=", evaded)
		if not (warned and saw_dive and stayed_locked and recover and evaded): failed = true
		bird.queue_free()
		for frame in range(5): await physics_frame
	world.queue_free()
	quit(1 if failed else 0)
