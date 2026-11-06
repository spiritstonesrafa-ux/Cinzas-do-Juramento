extends SceneTree
## Capture visual evidence for Boss 1 reward (+1 Max HP) and Abbot cinematic victory sequence.
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	var isolated: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolated.is_empty() or not actual.begins_with(isolated + "/") or actual.to_lower() == personal.to_lower():
		printerr("Captura recusada: perfil isolado não confirmado.")
		quit(2)
		return
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func shot(filepath: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("HEADLESS: skipped frame draw for ", filepath)
		return
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var dir: String = filepath.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err: Error = img.save_png(filepath)
	print("CAPTURE ", filepath, " size=", img.get_size(), " err=", err)

func clear_test_save() -> void:
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))

func run() -> void:
	clear_test_save()
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/recompensas")

	# CAPTURE 1: Guardian victory with +1 Max HP presentation
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(5)
	var hero: KnightController = main.get_node("ForgottenCemetery/Knight")
	var enc: Node2D = main.get_node("GuardianEncounter")
	enc.enter()
	await frames(5)

	var guardian: OathGuardian = enc.arena.get_node("Guardian")
	guardian.awake = true
	guardian.current_health = 1
	guardian._set_state(OathGuardian.State.PUNISH, 0.5)
	await frames(3)
	guardian.receive_hit()
	await frames(10)

	# Wait for conclusion banner with RECOMPENSA CONQUISTADA · VIDA MÁXIMA +1
	for f in range(90):
		await frames(1)

	await shot(out_dir + "/guardiao_recompensa_1280x720.png")
	await shot(out_dir + "/hud_6_hp_1280x720.png")
	main.queue_free()
	await frames(5)

	# CAPTURE 2, 3, 4: Abbot defeat, assimilation, and reward presentation
	clear_test_save()
	var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(chapter)
	while chapter.busy or chapter.current_room < 0:
		await frames(1)
	hero = chapter.hero
	await chapter.switch_room(11)
	chapter._enter_abbot_arena()
	await frames(15)

	var abbot: CharacterBody2D = chapter.room.boss
	abbot.health = 1
	abbot._hit()
	await frames(10)

	# Capture Abbot defeat / broken chains (Stage 2 & 3)
	for f in range(25):
		await frames(1)
	await shot(out_dir + "/abade_queda_1280x720.png")

	# Capture energy assimilation towards Aren (Stage 4)
	for f in range(50):
		await frames(1)
	await shot(out_dir + "/abade_assimilacao_1280x720.png")

	# Capture reward banner (Stage 5)
	for f in range(60):
		await frames(1)
	await shot(out_dir + "/abade_recompensa_1280x720.png")

	# Capture Abbot defeat / broken chains (Stage 2 & 3)
	await frames(25)
	await shot(out_dir + "/abade_queda_1280x720.png")

	# Capture energy assimilation towards Aren (Stage 4)
	await frames(55)
	await shot(out_dir + "/abade_assimilacao_1280x720.png")

	# Capture reward banner (Stage 5)
	await frames(60)
	await shot(out_dir + "/abade_recompensa_1280x720.png")

	chapter.queue_free()
	await frames(3)
	clear_test_save()
	print("ALL VISUAL CAPTURES COMPLETED")
	quit(0)
