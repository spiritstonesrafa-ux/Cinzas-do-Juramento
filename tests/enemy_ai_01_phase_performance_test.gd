extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var phase := OS.get_environment("ENEMY_AI_PERF_PHASE")
	var count := 0
	if phase == "cemiterio":
		var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
		world.add_child(stage)
		stage.set_physics_process(false)
		stage.knight.set_physics_process(false)
		count = stage.get_node("Enemies").get_child_count()
	elif phase == "abadia":
		var camera := Camera2D.new()
		camera.position = Vector2(410, 300)
		world.add_child(camera)
		camera.make_current()
		var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
		hero.position = Vector2(260, 300)
		world.add_child(hero)
		hero.set_physics_process(false)
		var sector := Node2D.new()
		sector.set_script(load("res://scripts/abbey/chapter_sector.gd"))
		sector.set("sector_id", 6)
		world.add_child(sector)
		sector.install_encounters(hero)
		count = sector.encounters.enemies.size()
	else:
		quit(2)
		return
	for frame in range(60): await physics_frame
	var total := 0.0
	var peak := 0.0
	for frame in range(300):
		await physics_frame
		var elapsed: float = Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
		total += elapsed
		peak = maxf(peak, elapsed)
	print("PHASE_PERFORMANCE phase=", phase, " enemies=", count, " samples=300 mean_ms=", total / 300.0 * 1000.0, " peak_ms=", peak * 1000.0)
	world.queue_free()
	quit()
