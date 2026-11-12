extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func picture_hash() -> String:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update(img.get_data())
	return context.finish().hex_encode()

func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or DisplayServer.get_name() == "headless":
		quit(2)
		return
	root.size = Vector2i(960, 540)
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.position = Vector2(160, 90)
	world.add_child(camera)
	camera.make_current()
	var crow: ForestSpectralCrow = load("res://scenes/enemies/forest_spectral_crow.tscn").instantiate()
	crow.position = Vector2(160, 90)
	world.add_child(crow)
	crow.set_physics_process(false)
	crow.state = ForestSpectralCrow.State.RECOVER
	crow.velocity = Vector2(24, 0)
	var frames: Array[String] = []
	for step in range(4):
		crow.flight_time = float(step) * 0.125
		crow.visual.queue_redraw()
		await process_frame
		frames.append(await picture_hash())
	crow.velocity = Vector2.ZERO
	crow.flight_time = 0.0
	crow.visual.queue_redraw()
	await process_frame
	var pause_one := await picture_hash()
	crow.flight_time = 0.25
	crow.visual.queue_redraw()
	await process_frame
	var pause_two := await picture_hash()
	var unique: Dictionary = {}
	for frame in frames: unique[frame] = true
	var ok := unique.size() == 4 and pause_one == pause_two
	print("CROW_RECOVERY moving_frames=", unique.size(), " stationary_pose_stable=", pause_one == pause_two)
	world.queue_free()
	quit(0 if ok else 1)
