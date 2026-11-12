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
	var stage := OS.get_environment("RETORNO_PERSIST_STAGE")
	if stage == "write":
		if not PROGRESS.grant_guardian_reward() or not PROGRESS.grant():
			printerr("FAIL recompensas")
			quit(1)
			return
		PROGRESS.set_pending_entrance("from_cemetery")
		change_scene_to_file("res://scenes/abbey/abbey_chapter.tscn")
		for i in range(180):
			await process_frame
			if current_scene != null and current_scene.get("current_room") == 0 and not current_scene.busy:
				break
		if current_scene == null or PROGRESS.campaign_location().chapter != "abbey":
			printerr("FAIL chegada persistida")
			quit(1)
			return
		await current_scene.switch_room(1)
		if current_scene.room.encounters.enemies.is_empty():
			printerr("FAIL monge ausente")
			quit(1)
			return
		current_scene.room.encounters.enemies[0].current_health = 0
		current_scene.forward_completed[1] = true
		current_scene.unlocked_shortcuts[0] = true
		var cp: RespawnCheckpoint = current_scene.checkpoints[0]
		current_scene.hero.activate_checkpoint(cp)
		current_scene._finish_checkpoint_write()
		if current_scene.hero.active_checkpoint != cp or PROGRESS.campaign_location().checkpoint != str(cp.name):
			printerr("FAIL ativação do checkpoint")
			quit(1)
			return
		print("PASS chegada real à Abadia persistida")
	elif stage == "read":
		change_scene_to_file("res://scenes/main.tscn")
		for i in range(300):
			await process_frame
			if current_scene != null and current_scene.name == "AbbeyChapter" and not current_scene.busy:
				break
		if current_scene == null or not current_scene.name.begins_with("Abbey") or current_scene.current_room != 1 or not current_scene.hero.dash_unlocked or current_scene.hero.survival.max_health != 6 or not is_instance_valid(current_scene.hero.active_checkpoint):
			printerr("FAIL retomada real ", current_scene.name if current_scene else "null")
			quit(1)
			return
		var hero = current_scene.hero
		if current_scene.room.encounters.enemies.is_empty() or current_scene.room.encounters.enemies[0].current_health != 0:
			printerr("FAIL estado do encontro após reinício")
			quit(1)
			return
		if not current_scene.forward_completed.has(1) or not current_scene.unlocked_shortcuts.has(0):
			printerr("FAIL progresso de atalhos após reinício")
			quit(1)
			return
		var destination: Vector2 = hero.active_checkpoint.respawn_point.global_position
		if not hero.is_respawn_safe(destination):
			printerr("FAIL checkpoint sem espaço seguro")
			quit(1)
			return
		hero.respawn_at_checkpoint()
		if hero.global_position.distance_to(destination) > 1.0:
			printerr("FAIL respawn do checkpoint restaurado")
			quit(1)
			return
		hero.survival.receive_damage(hero.survival.max_health)
		for i in range(120):
			await physics_frame
			if not hero.survival.is_dead: break
		if hero.survival.is_dead or hero.global_position.distance_to(destination) > 3.0 or not hero.dash_unlocked:
			printerr("FAIL morte e respawn Abadia")
			quit(1)
			return
		print("PASS retomada real da Abadia, dash e HP")
	else:
		quit(2)
		return
	# Let asynchronous backdrop requests finish before shutting the SceneTree down.
	await create_timer(1.0).timeout
	quit(0)
