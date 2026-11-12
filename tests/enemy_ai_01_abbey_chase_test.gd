extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	var floor_shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(400, 20)
	floor_shape.shape = rect
	floor_shape.position = Vector2(0, 10)
	floor_body.add_child(floor_shape)
	world.add_child(floor_body)
	var camera := Camera2D.new()
	world.add_child(camera)
	camera.make_current()
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(150, 0)
	world.add_child(hero)
	hero.set_physics_process(false)
	var enemies: Array = []
	for kind in range(4):
		var path := "res://scenes/enemies/chained_monk.tscn" if kind == 0 else "res://scenes/enemies/abbey_experimental_enemy.tscn"
		var enemy: ChainedMonk = load(path).instantiate()
		if kind > 0: enemy.set("archetype", kind - 1)
		enemy.patrol_min_x = -40.0
		enemy.patrol_max_x = 40.0
		world.add_child(enemy)
		enemy.target = hero
		enemies.append(enemy)
	var peaks := [0.0, 0.0, 0.0, 0.0]
	var returned := [false, false, false, false]
	for frame in range(360):
		await physics_frame
		for i in range(enemies.size()):
			var x: float = enemies[i].global_position.x
			peaks[i] = maxf(peaks[i], x)
			if peaks[i] > 30.0 and x < peaks[i] - 8.0: returned[i] = true
	var failed := false
	for i in range(enemies.size()):
		print("abbey blocked chase kind=", i, " peak=", peaks[i], " resumed=", returned[i])
		if not returned[i]: failed = true
	world.queue_free()
	quit(1 if failed else 0)
