extends SceneTree
const PROGRESS = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual == personal:
		printerr("FAIL isolamento")
		quit(2)
		return
	if not PROGRESS.grant_guardian_reward() or not PROGRESS.grant():
		printerr("FAIL preparar progresso isolado")
		quit(1)
		return
	PROGRESS.set_pending_entrance("from_abbey")
	change_scene_to_file("res://scenes/forest/forest_pilots.tscn")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "ForestPilots" and not current_scene.busy and current_scene.current_room == 0: break
	Input.action_press("move_left")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "AbbeyChapter" and not current_scene.busy and current_scene.current_room == 11: break
	Input.action_release("move_left")
	if current_scene == null or current_scene.name != "AbbeyChapter" or current_scene.current_room != 11:
		printerr("FAIL travessia física Floresta -> Abadia")
		quit(1)
		return
	print("PASS travessia física Floresta -> Abadia")
	Input.action_press("move_right")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "ForestPilots" and not current_scene.busy and current_scene.current_room == 0: break
	Input.action_release("move_right")
	if current_scene == null or current_scene.name != "ForestPilots":
		printerr("FAIL travessia física Abadia -> Floresta")
		quit(1)
		return
	print("PASS travessia física Abadia -> Floresta")
	# Set up the approved west entrance; crossings below use movement and physics.
	PROGRESS.set_pending_entrance("from_cemetery")
	change_scene_to_file("res://scenes/abbey/abbey_chapter.tscn")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "AbbeyChapter" and not current_scene.busy and current_scene.current_room == 0: break
	Input.action_press("move_left")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "Main": break
	Input.action_release("move_left")
	if current_scene == null or current_scene.name != "Main":
		printerr("FAIL travessia física Abadia -> Cemitério")
		quit(1)
		return
	print("PASS travessia física Abadia -> Cemitério")
	Input.action_press("move_right")
	for i in range(240):
		await physics_frame
		if current_scene != null and current_scene.name == "AbbeyChapter" and not current_scene.busy and current_scene.current_room == 0: break
	Input.action_release("move_right")
	if current_scene == null or current_scene.name != "AbbeyChapter":
		printerr("FAIL travessia física Cemitério -> Abadia")
		quit(1)
		return
	print("PASS travessia física Cemitério -> Abadia")
	await create_timer(1.0).timeout
	quit(0)
