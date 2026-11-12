extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var wall := StaticBody2D.new()
	wall.position = Vector2(42, 0)
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(8, 100)
	collision.shape = rect
	wall.add_child(collision)
	world.add_child(wall)
	var birds: Array = []
	for path in ["res://scenes/enemies/cursed_raven.tscn", "res://scenes/enemies/forest_spectral_crow.tscn"]:
		var bird: CharacterBody2D = load(path).instantiate()
		bird.flight_scan_enabled = true
		bird.flight_min_x = -100.0
		bird.flight_max_x = 100.0
		world.add_child(bird)
		birds.append(bird)
	var peaks := [0.0, 0.0]
	var returned := [false, false]
	for frame in range(240):
		await physics_frame
		for i in range(birds.size()):
			var x: float = birds[i].global_position.x
			peaks[i] = maxf(peaks[i], x)
			if peaks[i] > 8.0 and x < peaks[i] - 8.0: returned[i] = true
	var failed := false
	for i in range(birds.size()):
		print("air obstacle ", birds[i].name, " peak=", peaks[i], " half_width=", birds[i].patrol_half_width, " returned=", returned[i])
		if peaks[i] >= 38.0 or not returned[i]: failed = true
	world.queue_free()
	quit(1 if failed else 0)
