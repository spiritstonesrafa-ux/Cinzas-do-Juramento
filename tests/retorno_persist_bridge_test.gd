extends SceneTree
const P = preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual == personal:
		quit(2)
		return
	var phase := OS.get_environment("RETORNO_PERSIST_STAGE")
	if phase == "write":
		if not P.grant_guardian_reward() or not P.grant():
			quit(1)
			return
		P.set_pending_entrance("from_abbey")
		change_scene_to_file("res://scenes/forest/forest_pilots.tscn")
		for i in range(240):
			await physics_frame
			if current_scene != null and current_scene.name == "ForestPilots" and not current_scene.busy: break
		Input.action_press("move_left")
	else:
		change_scene_to_file("res://scenes/main.tscn")
	for i in range(300):
		await physics_frame
		if current_scene != null and current_scene.name == "AbbeyChapter" and not current_scene.busy and current_scene.current_room == 11: break
	Input.action_release("move_left")
	if current_scene == null or current_scene.name != "AbbeyChapter" or current_scene.current_room != 11:
		printerr("FAIL chegada ou retomada Abadia")
		quit(1)
		return
	var hero = current_scene.hero
	if phase == "write":
		var cp: RespawnCheckpoint = current_scene.checkpoints[6]
		hero.activate_checkpoint(cp)
		current_scene._finish_checkpoint_write()
		if hero.active_checkpoint != cp:
			printerr("FAIL checkpoint 7")
			quit(1)
			return
	else:
		if not is_instance_valid(hero.active_checkpoint) or str(hero.active_checkpoint.name) != "AbbeyCP7" or not hero.dash_unlocked or hero.survival.max_health != 6 or P.campaign_location().highest_unlocked != 2 or not P.unlocked():
			printerr("FAIL progresso ou checkpoint")
			quit(1)
			return
	print("PASS ponte de persistência ", phase)
	await create_timer(1.0).timeout
	quit(0)
