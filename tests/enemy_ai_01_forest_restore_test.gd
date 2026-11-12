extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var ground_sector := ForestSector.new()
	ground_sector.sector_id = 0
	world.add_child(ground_sector)
	var crow_sector := ForestSector.new()
	crow_sector.sector_id = 1
	crow_sector.position.x = 1200
	world.add_child(crow_sector)
	var crawler: ForestCrawler = ground_sector.enemies[0]
	var crow: ForestSpectralCrow = crow_sector.enemies[1]
	var ground_save := ground_sector.snapshot()
	var crow_save := crow_sector.snapshot()
	ground_save.enemies[crawler.encounter_id].pos_x = crawler.position.x + 125.0
	ground_save.enemies[crawler.encounter_id].facing = 1
	crow_save.enemies[crow.encounter_id].pos_x = crow.position.x + 70.0
	ground_sector.restore_state(ground_save)
	crow_sector.restore_state(crow_save)
	var ground_initial: float = absf(crawler.global_position.x - crawler.origin.x)
	var crow_initial: float = crow.global_position.distance_to(crow.origin)
	var correct_start := is_equal_approx(ground_initial, 125.0) and is_equal_approx(crow_initial, 70.0)
	for frame in range(180): await physics_frame
	var ground_returned := absf(crawler.global_position.x - crawler.origin.x) < ground_initial - 10.0
	var crow_returned := crow.global_position.distance_to(crow.origin) < crow_initial - 10.0
	print("forest restore initial=", correct_start, " ground_returned=", ground_returned, " crow_returned=", crow_returned, " ground=", crawler.global_position, " crow=", crow.global_position)
	world.queue_free()
	quit(0 if correct_start and ground_returned and crow_returned else 1)
