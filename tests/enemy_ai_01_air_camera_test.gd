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
	floor_body.position = Vector2(1000, 10)
	var floor_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(300, 20)
	floor_shape.shape = rect
	floor_body.add_child(floor_shape)
	world.add_child(floor_body)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(1000, 0)
	world.add_child(hero)
	var birds: Array = []
	for path in ["res://scenes/enemies/cursed_raven.tscn", "res://scenes/enemies/forest_spectral_crow.tscn"]:
		var bird: CharacterBody2D = load(path).instantiate()
		bird.position = Vector2(1000, -30)
		world.add_child(bird)
		bird.set_physics_process(false)
		bird.target = hero
		birds.append(bird)
	for frame in range(12): await physics_frame
	var failed := not hero.is_on_floor()
	for bird in birds:
		var visible: bool = bird.visible_for_attack()
		var sees: bool = bird._perceives_target()
		var attacks: bool = bird._can_alert()
		print("offscreen ", bird.name, " grounded=", hero.is_on_floor(), " sees=", sees, " visible=", visible, " attack=", attacks)
		if not sees or visible or attacks: failed = true
	world.queue_free()
	quit(1 if failed else 0)
