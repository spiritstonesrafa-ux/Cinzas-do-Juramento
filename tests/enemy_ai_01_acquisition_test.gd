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
	var shape := RectangleShape2D.new()
	shape.size = Vector2(1400, 20)
	collision.shape = shape
	collision.position = Vector2(300, 10)
	floor_body.add_child(collision)
	world.add_child(floor_body)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(150, 0)
	world.add_child(hero)
	hero.set_physics_process(false)
	var enemies: Array = []
	for path in ["res://scenes/enemies/skeleton_patrol.tscn", "res://scenes/enemies/forest_crawler.tscn", "res://scenes/enemies/forest_sentinel.tscn", "res://scenes/enemies/chained_monk.tscn"]:
		var enemy: CharacterBody2D = load(path).instantiate()
		world.add_child(enemy)
		enemy.target = hero
		enemies.append(enemy)
	var acquired := [-1, -1, -1, -1]
	var lost := [-1, -1, -1, -1]
	var resumed := [-1, -1, -1, -1]
	var positions_at_loss := [0.0, 0.0, 0.0, 0.0]
	var kept_direction := [false, false, false, false]
	for frame in range(240):
		if frame == 20:
			for i in range(enemies.size()): positions_at_loss[i] = enemies[i].global_position.x
			hero.global_position.x = -500
		await physics_frame
		for i in range(enemies.size()):
			var enemy = enemies[i]
			if frame == 21 and acquired[i] >= 0: kept_direction[i] = enemy.global_position.x >= positions_at_loss[i]
			if frame < 20 and enemy.state == enemy.State.CHASE and acquired[i] < 0: acquired[i] = frame
			if frame >= 20 and acquired[i] >= 0:
				if enemy.state != enemy.State.CHASE and lost[i] < 0: lost[i] = frame - 20
				if enemy.state == enemy.State.PATROL and resumed[i] < 0: resumed[i] = frame - 20
	var failed := false
	for i in range(enemies.size()):
		print("acquisition ", enemies[i].name, " acquired_frame=", acquired[i], " loss_frames=", lost[i], " patrol_frames=", resumed[i], " last_seen_direction=", kept_direction[i])
		if acquired[i] >= 0 and not kept_direction[i]: failed = true
	world.queue_free()
	quit(1 if failed else 0)
