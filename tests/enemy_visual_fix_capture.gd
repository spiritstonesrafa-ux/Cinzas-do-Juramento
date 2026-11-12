extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var output := OS.get_environment("ENEMY_VISUAL_FIX_OUTPUT")
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or output.is_empty() or DisplayServer.get_name() == "headless":
		quit(2)
		return
	root.size = Vector2i(1280, 720)
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.position = Vector2(160, 90)
	world.add_child(camera)
	camera.make_current()
	var monk: ChainedMonk = load("res://scenes/enemies/chained_monk.tscn").instantiate()
	monk.position = Vector2(160, 100)
	world.add_child(monk)
	monk.set_physics_process(false)
	for fixture in [["active", ChainedMonk.State.ACTIVE, 1], ["recover", ChainedMonk.State.RECOVER, 1], ["warning", ChainedMonk.State.WARNING, 1], ["active_left", ChainedMonk.State.ACTIVE, -1], ["recover_left", ChainedMonk.State.RECOVER, -1]]:
		monk.facing = fixture[2]
		monk.set_state(fixture[1], 0.12)
		for frame in range(5): await process_frame
		await RenderingServer.frame_post_draw
		var result := root.get_texture().get_image().save_png(output.path_join(str(fixture[0]) + ".png"))
		if result != OK:
			quit(1)
			return
	world.queue_free()
	quit()
