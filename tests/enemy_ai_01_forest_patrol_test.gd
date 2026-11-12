extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var grounded: Array = []
	var initial: Array = []
	var minimum: Array = []
	var maximum: Array = []
	for id in range(10):
		var sector := ForestSector.new()
		sector.sector_id = id
		sector.position.x = id * 1200.0
		world.add_child(sector)
		for enemy in sector.enemies:
			if enemy is ForestCrawler or enemy is ForestSentinel:
				grounded.append(enemy)
				initial.append(enemy.global_position)
				minimum.append(enemy.global_position.x)
				maximum.append(enemy.global_position.x)
	var fallen: Array = []
	for frame in range(480):
		await physics_frame
		for i in range(grounded.size()):
			var enemy = grounded[i]
			minimum[i] = minf(minimum[i], enemy.global_position.x)
			maximum[i] = maxf(maximum[i], enemy.global_position.x)
			if enemy.global_position.y > initial[i].y + 12.0 and not fallen.has(enemy.encounter_id):
				fallen.append(enemy.encounter_id)
	var failed := not fallen.is_empty()
	for i in range(grounded.size()):
		print("forest patrol ", grounded[i].encounter_id, " distance=", maximum[i] - minimum[i], " bounds=", grounded[i].patrol_left, ",", grounded[i].patrol_right)
	print("ground enemies=", grounded.size(), " fallen=", fallen)
	world.queue_free()
	quit(1 if failed else 0)
