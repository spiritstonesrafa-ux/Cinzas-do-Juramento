extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
	root.add_child(stage)
	stage.set_physics_process(false)
	stage.get_node("Knight").set_physics_process(false)
	var enemies: Array = []
	var start: Array = []
	var low: Array = []
	var high: Array = []
	var sector_bounds: Array = []
	for enemy in stage.get_node("Enemies").get_children():
		if enemy is SkeletonPatrol:
			enemy.target = null
			enemies.append(enemy)
			start.append(enemy.global_position)
			low.append(enemy.global_position.x)
			high.append(enemy.global_position.x)
			var sector := 0
			for i in range(stage.SECTOR_STARTS.size()):
				if enemy.position.x >= stage.SECTOR_STARTS[i]: sector = i
			var end: float = stage.SECTOR_STARTS[sector + 1] if sector + 1 < stage.SECTOR_STARTS.size() else 2340.0
			sector_bounds.append(Vector2(stage.SECTOR_STARTS[sector], end))
	var fallen: Array = []
	var escaped: Array = []
	for frame in range(480):
		await physics_frame
		for i in range(enemies.size()):
			var enemy: SkeletonPatrol = enemies[i]
			low[i] = minf(low[i], enemy.global_position.x)
			high[i] = maxf(high[i], enemy.global_position.x)
			if enemy.global_position.y > start[i].y + 12.0 and not fallen.has(enemy.name):
				fallen.append(enemy.name)
			if (enemy.position.x < sector_bounds[i].x or enemy.position.x > sector_bounds[i].y) and not escaped.has(enemy.name):
				escaped.append(enemy.name)
	for i in range(enemies.size()):
		print("cemetery patrol ", enemies[i].name, " distance=", high[i]-low[i], " bounds=", enemies[i].patrol_left, ",", enemies[i].patrol_right)
	print("ground enemies=", enemies.size(), " fallen=", fallen, " escaped=", escaped)
	stage.queue_free()
	quit(1 if not fallen.is_empty() or not escaped.is_empty() else 0)
