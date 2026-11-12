extends SceneTree
## Cenários isolados idênticos, um inimigo por vez; valores em quadros a 60 Hz.
func _initialize() -> void:
	run.call_deferred()

func perceive(enemy: CharacterBody2D) -> bool:
	if enemy is CursedRaven or enemy is ForestSpectralCrow:
		return enemy._perceives_target() if enemy.has_method("_perceives_target") else enemy._can_alert()
	if enemy is ChainedMonk: return enemy.sees_target()
	return enemy._sees_target()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.position = Vector2(60, 0)
	world.add_child(camera)
	camera.make_current()
	var ground := StaticBody2D.new()
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(1000, 20)
	collider.shape = shape
	collider.position = Vector2(200, 10)
	ground.add_child(collider)
	world.add_child(ground)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	hero.position = Vector2(150, 0)
	world.add_child(hero)
	for frame in range(10): await physics_frame
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
	for spec in specs:
		hero.global_position = Vector2(-500, 0)
		var enemy: CharacterBody2D = load(spec[1]).instantiate()
		if spec[2] >= 0: enemy.set("archetype", spec[2])
		if spec[0] in ["corvo", "corvo_espectral"]: enemy.position.y = -30
		world.add_child(enemy)
		enemy.target = hero
		var start: Vector2 = enemy.global_position
		var previous: Vector2 = start
		var travelled := 0.0
		var low := start.x
		var high := start.x
		var idle := 0
		var turns := 0
		var last_sign := 0
		var falls := 0
		for frame in range(300):
			await physics_frame
			var step: Vector2 = enemy.global_position - previous
			travelled += step.length()
			low = minf(low, enemy.global_position.x)
			high = maxf(high, enemy.global_position.x)
			if step.length() < 0.01: idle += 1
			var direction := int(signf(step.x))
			if direction != 0:
				if last_sign != 0 and direction != last_sign: turns += 1
				last_sign = direction
			if enemy.global_position.y > start.y + 12.0: falls += 1
			previous = enemy.global_position
		enemy.reset_enemy()
		hero.global_position = Vector2(150, 0)
		enemy.target = hero
		var acquired := -1
		var chase := 0
		var max_distance := 0.0
		for frame in range(180):
			await physics_frame
			if acquired < 0 and perceive(enemy): acquired = frame
			if enemy is not CursedRaven and enemy is not ForestSpectralCrow and enemy.state == enemy.State.CHASE: chase += 1
			max_distance = maxf(max_distance, absf(enemy.global_position.x - start.x))
		hero.global_position = Vector2(-500, 0)
		var lost := -1
		var patrol := -1
		for frame in range(120):
			await physics_frame
			if lost < 0 and not perceive(enemy): lost = frame
			if patrol < 0 and enemy.state == enemy.State.PATROL: patrol = frame
		print("BEHAVIOR ", spec[0], " extent=", snappedf(high-low,0.01), " travelled=", snappedf(travelled,0.01), " idle_frames=", idle, " turns=", turns, " fall_frames=", falls, " acquire_frame=", acquired, " chase_frames=", chase, " max_offset=", snappedf(max_distance,0.01), " lost_frame=", lost, " patrol_frame=", patrol)
		enemy.queue_free()
		await physics_frame
	world.queue_free()
	quit()
