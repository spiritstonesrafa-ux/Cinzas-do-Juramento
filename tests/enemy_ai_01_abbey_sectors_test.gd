extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var enemies: Array = []
	var starts: Array = []
	var low: Array = []
	var high: Array = []
	for id in range(12):
		var sector := Node2D.new()
		sector.set_script(load("res://scripts/abbey/chapter_sector.gd"))
		sector.set("sector_id", id)
		sector.position = AbbeyChapterLayout.origin(id)
		world.add_child(sector)
		sector.install_encounters(null)
		for enemy in sector.encounters.enemies:
			enemies.append(enemy)
		if is_instance_valid(sector.pilot) and is_instance_valid(sector.pilot.monk):
			enemies.append(sector.pilot.monk)
	for enemy in enemies:
		starts.append(enemy.global_position)
		low.append(enemy.global_position.x)
		high.append(enemy.global_position.x)
	var fallen: Array = []
	for frame in range(480):
		await physics_frame
		for i in range(enemies.size()):
			var enemy: ChainedMonk = enemies[i]
			low[i] = minf(low[i], enemy.global_position.x)
			high[i] = maxf(high[i], enemy.global_position.x)
			if enemy.global_position.y > starts[i].y + 12.0 and not fallen.has(i): fallen.append(i)
	for i in range(enemies.size()):
		print("abbey sector patrol index=", i, " distance=", high[i] - low[i], " start=", starts[i], " end=", enemies[i].global_position)
	print("abbey enemies=", enemies.size(), " fallen indices=", fallen)
	world.queue_free()
	quit(1 if not fallen.is_empty() else 0)
