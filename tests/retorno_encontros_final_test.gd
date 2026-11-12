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
	var chapter := OS.get_environment("RETORNO_ENCOUNTER_CHAPTER")
	if phase == "write":
		if not P.grant_guardian_reward() or not P.grant():
			quit(1)
			return
		P.set_pending_entrance("from_cemetery" if chapter == "abbey" else "from_abbey")
	else:
		P.set_pending_entrance("resume")
	var path := "res://scenes/abbey/abbey_chapter.tscn" if chapter == "abbey" else "res://scenes/forest/forest_pilots.tscn"
	change_scene_to_file(path)
	for i in range(300):
		await process_frame
		if current_scene != null and current_scene.get("current_room") >= 0 and not current_scene.busy: break
	var controller = current_scene
	if controller == null:
		quit(1)
		return
	controller.hero.survival.invulnerability_remaining = 99999.0
	var checked := 0
	var hazards_checked := 0
	var sectors := 12 if chapter == "abbey" else 9
	for id in range(sectors):
		if controller.current_room != id: await controller.switch_room(id)
		if chapter == "abbey" and id == 5:
			var pilot = controller.room.pilot
			if not is_instance_valid(pilot) or not is_instance_valid(pilot.monk):
				printerr("FAIL monge da galeria ausente")
				quit(1)
				return
			if phase == "write": pilot.monk.current_health = 0
			elif pilot.monk.current_health != 0:
				printerr("FAIL monge da galeria")
				quit(1)
				return
		var enemies: Array = controller.room.encounters.enemies if chapter == "abbey" else controller.room.enemies
		if chapter == "forest":
			for hazard in controller.room.hazards:
				if phase == "write": hazard.remaining = 10000.0
				elif hazard.remaining < 9000.0:
					printerr("FAIL perigo após reinício ", hazard.name)
					quit(1)
					return
				hazards_checked += 1
		for enemy in enemies:
			if phase == "write":
				if chapter == "abbey": enemy.current_health = 0
				else: enemy.force_dead()
			else:
				if int(enemy.current_health) != 0:
					printerr("FAIL ", chapter, " setor ", id, " ", enemy.name, " hp=", enemy.current_health)
					quit(1)
					return
			checked += 1
	controller._save_resident_states()
	if phase == "write":
		P.set_pending_entrance("from_abbey" if chapter == "abbey" else "from_forest")
		var other := "res://scenes/forest/forest_pilots.tscn" if chapter == "abbey" else "res://scenes/abbey/abbey_chapter.tscn"
		change_scene_to_file(other)
		for i in range(300):
			await process_frame
			if current_scene != null and current_scene.scene_file_path == other and not current_scene.busy: break
		if current_scene == null or current_scene.scene_file_path != other:
			printerr("FAIL saída de capítulo ", chapter)
			quit(1)
			return
		P.set_pending_entrance("resume")
		change_scene_to_file(path)
		for i in range(300):
			await process_frame
			if current_scene != null and current_scene.scene_file_path == path and current_scene.get("current_room") >= 0 and not current_scene.busy: break
		controller = current_scene
		controller.hero.survival.invulnerability_remaining = 99999.0
		var revisited := 0
		for id in range(sectors):
			if controller.current_room != id: await controller.switch_room(id)
			if chapter == "abbey" and id == 5:
				if not is_instance_valid(controller.room.pilot.monk) or controller.room.pilot.monk.current_health != 0:
					printerr("FAIL revisita monge da galeria")
					quit(1)
					return
			var enemies: Array = controller.room.encounters.enemies if chapter == "abbey" else controller.room.enemies
			if chapter == "forest":
				for hazard in controller.room.hazards:
					if hazard.remaining < 9000.0:
						printerr("FAIL perigo em revisita ", hazard.name)
						quit(1)
						return
			for enemy in enemies:
				if int(enemy.current_health) != 0:
					printerr("FAIL revisita ", chapter, " setor ", id, " ", enemy.name)
					quit(1)
					return
				revisited += 1
		print("PASS ", chapter, " retorno entre capítulos encontros=", revisited)
	print("PASS ", chapter, " ", phase, " encontros=", checked, " perigos=", hazards_checked)
	await create_timer(1.0).timeout
	quit(0)
