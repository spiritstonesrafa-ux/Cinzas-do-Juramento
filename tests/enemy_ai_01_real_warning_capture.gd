extends SceneTree
const PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var output := OS.get_environment("ENEMY_AI_WARNING_OUTPUT")
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or output.is_empty() or DisplayServer.get_name() == "headless":
		quit(2)
		return
	if not PROGRESS.grant_guardian_reward():
		quit(3)
		return
	root.size = Vector2i(1280, 720)
	var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(chapter)
	current_scene = chapter
	while chapter.busy: await process_frame
	var fixtures := [[0, 0, "monge"], [3, 0, "acolito"], [3, 1, "penitente"], [6, 0, "vigia"]]
	var failures := 0
	for fixture in fixtures:
		await chapter.switch_room(fixture[0], false, true)
		var enemy: ChainedMonk = chapter.room.encounters.enemies[fixture[1]]
		chapter.hero.survival.restore()
		chapter.hero.reset_to(enemy.global_position + Vector2(-40, 0))
		chapter.hero.set_physics_process(false)
		chapter.camera.position = chapter.camera_target()
		chapter.camera.force_update_scroll()
		var found := false
		for frame in range(120):
			await physics_frame
			if enemy.state == ChainedMonk.State.WARNING:
				found = true
				break
		if found:
			await RenderingServer.frame_post_draw
			var save_error := root.get_texture().get_image().save_png(output.path_join(str(fixture[2]) + "_aviso_real.png"))
			found = save_error == OK
		print("REAL_WARNING ", fixture[2], " state=", enemy.state, " captured=", found)
		if not found: failures += 1
		chapter.hero.set_physics_process(true)
	var wait_start := Time.get_ticks_msec()
	while not chapter.requested_backgrounds.is_empty() and Time.get_ticks_msec() - wait_start < 15000:
		await process_frame
	quit(0 if failures == 0 else 1)
