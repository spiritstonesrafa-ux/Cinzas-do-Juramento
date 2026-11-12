extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	world.add_child(camera)
	camera.make_current()
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	world.add_child(hero)
	hero.set_physics_process(false)
	var enemies: Array = []
	for path in ["res://scenes/enemies/skeleton_patrol.tscn", "res://scenes/enemies/forest_crawler.tscn", "res://scenes/enemies/forest_sentinel.tscn", "res://scenes/enemies/chained_monk.tscn"]:
		var enemy: CharacterBody2D = load(path).instantiate()
		world.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.target = hero
		enemies.append(enemy)
	await physics_frame
	var ranges := [0, 0, 0, 0]
	for distance in range(10, 241, 10):
		hero.global_position = Vector2(distance, 0)
		for i in range(enemies.size()):
			var sees: bool = enemies[i].sees_target() if enemies[i] is ChainedMonk else enemies[i]._sees_target()
			if sees: ranges[i] = distance
	var wall := StaticBody2D.new()
	wall.collision_layer = 1
	var wall_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10, 80)
	wall_shape.shape = rect
	wall.add_child(wall_shape)
	wall.position = Vector2(45, -10)
	world.add_child(wall)
	hero.global_position = Vector2(90, 0)
	await physics_frame
	await physics_frame
	var failed := false
	for i in range(enemies.size()):
		var sees: bool = enemies[i].sees_target() if enemies[i] is ChainedMonk else enemies[i]._sees_target()
		print("ground perception ", enemies[i].name, " measured=", ranges[i], " through_wall=", sees)
		if sees: failed = true
	wall.queue_free()
	await physics_frame
	hero.global_position = Vector2(40, 100)
	for enemy in enemies:
		var sees: bool = enemy.sees_target() if enemy is ChainedMonk else enemy._sees_target()
		print("ground height ", enemy.name, " sees=", sees)
		if sees: failed = true
	world.queue_free()
	quit(1 if failed else 0)
