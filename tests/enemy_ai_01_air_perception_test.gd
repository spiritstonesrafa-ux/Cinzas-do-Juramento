extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(150, 14)
	world.add_child(hero)
	hero.set_physics_process(false)
	var birds: Array = []
	for path in ["res://scenes/enemies/cursed_raven.tscn", "res://scenes/enemies/forest_spectral_crow.tscn"]:
		var bird: CharacterBody2D = load(path).instantiate()
		bird.position = Vector2.ZERO
		world.add_child(bird)
		bird.set_physics_process(false)
		bird.target = hero
		birds.append(bird)
	await physics_frame
	var failed := false
	for bird in birds:
		var sees: bool = bird._perceives_target()
		var attacks: bool = bird._can_alert()
		print("air perception ", bird.name, " sees=", sees, " starts_attack=", attacks)
		if not sees or attacks: failed = true
		bird.facing = -1
		bird.state = bird.State.PATROL
		bird.set_physics_process(true)
	for i in range(12): await physics_frame
	for bird in birds:
		bird.set_physics_process(false)
		print("air approach ", bird.name, " x=", bird.global_position.x)
		if bird.global_position.x <= 0.0: failed = true
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 80)
	collision.shape = shape
	wall.add_child(collision)
	wall.position = Vector2(75, 0)
	world.add_child(wall)
	await physics_frame
	await physics_frame
	for bird in birds:
		var sees: bool = bird._perceives_target()
		print("air wall ", bird.name, " sees=", sees)
		if sees: failed = true
	world.queue_free()
	quit(1 if failed else 0)
