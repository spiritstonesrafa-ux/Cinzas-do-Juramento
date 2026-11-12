extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var count := 0
	var targeted := OS.get_environment("ENEMY_AI_PERF_TARGETED") == "1"
	for id in range(9):
		var sector := ForestSector.new()
		sector.sector_id = id
		sector.position = Vector2(id * 1200.0, 0)
		world.add_child(sector)
		count += sector.enemies.size()
		if targeted and not sector.enemies.is_empty():
			var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
			hero.position = sector.enemies[0].global_position + Vector2(150, 0)
			world.add_child(hero)
			hero.set_physics_process(false)
			sector.set_hero(hero)
	for frame in range(60): await physics_frame
	var total := 0.0
	var peak := 0.0
	for frame in range(300):
		await physics_frame
		var elapsed: float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		total += elapsed
		peak = maxf(peak, elapsed)
	print("AI_PERFORMANCE enemies=", count, " targeted=", targeted, " samples=300 mean_ms=", total / 300.0 * 1000.0, " peak_ms=", peak * 1000.0)
	world.queue_free()
	quit()
