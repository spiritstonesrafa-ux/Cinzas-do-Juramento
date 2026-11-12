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
	change_scene_to_file("res://scenes/main.tscn")
	for i in range(180):
		await physics_frame
		if current_scene != null and current_scene.name == "Main": break
	if current_scene == null or current_scene.name != "Main":
		printerr("FAIL carregar Cemitério")
		quit(1)
		return
	var stage_node = current_scene.get_node("ForgottenCemetery")
	var hero = stage_node.knight
	if stage == "write":
		var cp: RespawnCheckpoint = stage_node.get_node("Mechanisms/Checkpoint2")
		hero.activate_checkpoint(cp)
		if hero.active_checkpoint != cp or P.campaign_location().checkpoint != str(cp.name):
			printerr("FAIL checkpoint Cemitério")
			quit(1)
			return
	else:
		await physics_frame
		if not is_instance_valid(hero.active_checkpoint) or not hero.dash_unlocked or not hero.spectral_jump_unlocked or hero.survival.max_health != 6 or P.campaign_location().highest_unlocked != 2:
			printerr("FAIL retomada Cemitério")
			quit(1)
			return
		var destination: Vector2 = hero.active_checkpoint.respawn_point.global_position
		if not hero.is_respawn_safe(destination):
			printerr("FAIL checkpoint inseguro")
			quit(1)
			return
		hero.respawn_at_checkpoint()
		if hero.global_position.distance_to(destination) > 1.0:
			printerr("FAIL respawn Cemitério")
			quit(1)
			return
		hero.survival.receive_damage(hero.survival.max_health)
		for i in range(120):
			await physics_frame
			if not hero.survival.is_dead: break
		if hero.survival.is_dead or hero.global_position.distance_to(destination) > 3.0 or not hero.dash_unlocked:
			printerr("FAIL morte e respawn Cemitério")
			quit(1)
			return
	print("PASS Cemitério ", stage)
	await create_timer(1.0).timeout
	quit(0)
