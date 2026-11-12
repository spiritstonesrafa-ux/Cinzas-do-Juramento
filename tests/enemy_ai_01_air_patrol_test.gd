extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
	world.add_child(stage)
	stage.set_physics_process(false)
	stage.get_node("Knight").set_physics_process(false)
	var birds: Array = []
	for enemy in stage.get_node("Enemies").get_children():
		if enemy is CursedRaven:
			enemy.target = null
			birds.append(enemy)
	for id in range(10):
		var sector := ForestSector.new()
		sector.sector_id = id
		sector.position = Vector2(id * 1200.0, 1000)
		world.add_child(sector)
		for enemy in sector.enemies:
			if enemy is ForestSpectralCrow: birds.append(enemy)
	var starts: Array = []
	var low: Array = []
	var high: Array = []
	for bird in birds:
		starts.append(bird.global_position)
		low.append(bird.global_position.x)
		high.append(bird.global_position.x)
	var escaped: Array = []
	for frame in range(480):
		await physics_frame
		for i in range(birds.size()):
			var bird = birds[i]
			low[i] = minf(low[i], bird.global_position.x)
			high[i] = maxf(high[i], bird.global_position.x)
			if absf(bird.global_position.x - starts[i].x) > bird.patrol_half_width + 1.0 or absf(bird.global_position.y - starts[i].y) > 1.0:
				if not escaped.has(bird.name): escaped.append(bird.name)
	for i in range(birds.size()):
		print("air patrol ", birds[i].name, " distance=", high[i] - low[i], " half_width=", birds[i].patrol_half_width)
	print("birds=", birds.size(), " escaped=", escaped)
	world.queue_free()
	quit(1 if not escaped.is_empty() else 0)
