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
	var stage := OS.get_environment("RETORNO_PERSIST_STAGE")
	if stage == "write":
		if not P.grant_guardian_reward() or not P.grant() or not P.grant_cervo_reward():
			quit(1)
			return
		P.set_pending_entrance("from_abbey")
		change_scene_to_file("res://scenes/forest/forest_pilots.tscn")
	else:
		change_scene_to_file("res://scenes/main.tscn")
	for i in range(300):
		await process_frame
		if current_scene != null and current_scene.name == "ForestPilots" and not current_scene.busy and current_scene.current_room == 0: break
	if current_scene == null or current_scene.name != "ForestPilots":
		printerr("FAIL carregar Floresta")
		quit(1)
		return
	var hero = current_scene.hero
	if stage == "write":
		var cp: RespawnCheckpoint = current_scene.checkpoints[0]
		hero.activate_checkpoint(cp)
		current_scene._finish_checkpoint_write()
		if hero.active_checkpoint != cp or P.campaign_location().checkpoint != str(cp.name):
			printerr("FAIL ativar checkpoint Floresta")
			quit(1)
			return
	else:
		if not is_instance_valid(hero.active_checkpoint) or not hero.dash_unlocked or not hero.spectral_jump_unlocked or hero.survival.max_health != 6:
			printerr("FAIL retomada da Floresta")
			quit(1)
			return
		var destination: Vector2 = hero.active_checkpoint.respawn_point.global_position
		if not hero.is_respawn_safe(destination):
			printerr("FAIL segurança do checkpoint")
			quit(1)
			return
		hero.respawn_at_checkpoint()
		if hero.global_position.distance_to(destination) > 1.0:
			printerr("FAIL respawn")
			quit(1)
			return
		hero.survival.receive_damage(hero.survival.max_health)
		for i in range(120):
			await physics_frame
			if not hero.survival.is_dead: break
		if hero.survival.is_dead or hero.global_position.distance_to(destination) > 3.0 or not hero.spectral_jump_unlocked:
			printerr("FAIL morte e respawn Floresta")
			quit(1)
			return
	print("PASS Floresta ", stage)
	await create_timer(1.0).timeout
	quit(0)
