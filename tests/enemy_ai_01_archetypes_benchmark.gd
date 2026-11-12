extends SceneTree
## Comparação de percepção em 5 px. A baseline aérea usa a aquisição de
## mergulho; a candidata expõe percepção separada, portanto não são o mesmo estado.
func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.position = Vector2(70, 0)
	world.add_child(camera)
	camera.make_current()
	var floor_body := StaticBody2D.new()
	var floor_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(800, 20)
	floor_shape.shape = rectangle
	floor_shape.position = Vector2(250, 10)
	floor_body.add_child(floor_shape)
	world.add_child(floor_body)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(10, 0)
	world.add_child(hero)
	for frame in range(10): await physics_frame
	if not hero.is_on_floor():
		printerr("Fixture sem apoio no chão")
		quit(2)
		return
	hero.set_physics_process(false)
	var specs := [
		["esqueleto", "res://scenes/enemies/skeleton_patrol.tscn", -1],
		["corvo", "res://scenes/enemies/cursed_raven.tscn", -1],
		["monge", "res://scenes/enemies/chained_monk.tscn", -1],
		["acolito", "res://scenes/enemies/abbey_experimental_enemy.tscn", 0],
		["penitente", "res://scenes/enemies/abbey_experimental_enemy.tscn", 1],
		["vigia", "res://scenes/enemies/abbey_experimental_enemy.tscn", 2],
		["sentinela", "res://scenes/enemies/forest_sentinel.tscn", -1],
		["rastejante", "res://scenes/enemies/forest_crawler.tscn", -1],
		["corvo_espectral", "res://scenes/enemies/forest_spectral_crow.tscn", -1]
	]
	var enemies: Array = []
	for spec in specs:
		var enemy: CharacterBody2D = load(spec[1]).instantiate()
		if spec[2] >= 0: enemy.set("archetype", spec[2])
		if spec[0] in ["corvo", "corvo_espectral"]: enemy.position.y = -30
		world.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.target = hero
		enemies.append(enemy)
	await physics_frame
	for i in range(enemies.size()):
		var enemy = enemies[i]
		var maximum := 0
		var mode := "ground_sight"
		for distance in range(5, 241, 5):
			hero.global_position = Vector2(distance, 0)
			var sees := false
			if enemy is CursedRaven or enemy is ForestSpectralCrow:
				mode = "perception" if enemy.has_method("_perceives_target") else "legacy_dive_acquisition"
				sees = enemy._perceives_target() if enemy.has_method("_perceives_target") else enemy._can_alert()
			elif enemy is ChainedMonk:
				sees = enemy.sees_target()
			else:
				sees = enemy._sees_target()
			if sees: maximum = distance
		print("ARCHETYPE ", specs[i][0], " distance_px=", maximum, " mode=", mode)
	var wall := StaticBody2D.new()
	wall.position = Vector2(45, -10)
	var wall_shape := CollisionShape2D.new()
	var wall_rect := RectangleShape2D.new()
	wall_rect.size = Vector2(10, 100)
	wall_shape.shape = wall_rect
	wall.add_child(wall_shape)
	world.add_child(wall)
	hero.global_position = Vector2(90, 0)
	await physics_frame
	await physics_frame
	var blocked: Array[bool] = []
	for enemy in enemies:
		var sees := false
		if enemy is CursedRaven or enemy is ForestSpectralCrow:
			sees = enemy._perceives_target() if enemy.has_method("_perceives_target") else enemy._can_alert()
		elif enemy is ChainedMonk: sees = enemy.sees_target()
		else: sees = enemy._sees_target()
		blocked.append(not sees)
	wall.queue_free()
	await physics_frame
	hero.global_position = Vector2(30, 100)
	var failed := false
	for i in range(enemies.size()):
		var enemy = enemies[i]
		var sees := false
		if enemy is CursedRaven or enemy is ForestSpectralCrow:
			sees = enemy._perceives_target() if enemy.has_method("_perceives_target") else enemy._can_alert()
		elif enemy is ChainedMonk: sees = enemy.sees_target()
		else: sees = enemy._sees_target()
		print("ARCHETYPE_OBSTACLE ", specs[i][0], " wall_blocked=", blocked[i], " height_blocked=", not sees)
		if not blocked[i] or sees: failed = true
	world.queue_free()
	quit(1 if failed else 0)
