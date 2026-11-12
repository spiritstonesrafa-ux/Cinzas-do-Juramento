extends SceneTree
## Abre cenas reais em um perfil isolado criado pelo launcher.
const PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	start.call_deferred()

func start() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual == personal:
		printerr("Playtest recusado: perfil isolado não confirmado.")
		quit(2)
		return
	if FileAccess.file_exists(PROGRESS.PATH):
		printerr("Playtest recusado: o perfil deve ser novo.")
		quit(2)
		return
	var phase := OS.get_environment("ENEMY_AI_PLAYTEST_PHASE")
	var scene_path := ""
	match phase:
		"cemiterio": scene_path = "res://scenes/main.tscn"
		"abadia":
			if not PROGRESS.grant_guardian_reward():
				quit(3)
				return
			scene_path = "res://scenes/abbey/abbey_chapter.tscn"
		"floresta":
			if not PROGRESS.grant_guardian_reward() or not PROGRESS.grant():
				quit(3)
				return
			scene_path = "res://scenes/forest/forest_pilots.tscn"
		_:
			printerr("Fase inválida: ", phase)
			quit(2)
			return
	var scene: Node = load(scene_path).instantiate()
	root.add_child(scene)
	current_scene = scene
	var load_started := Time.get_ticks_msec()
	while Time.get_ticks_msec() - load_started < 15000:
		await process_frame
		if phase == "cemiterio" or (scene.current_room >= 0 and not scene.busy): break
	if phase != "cemiterio" and (scene.current_room < 0 or scene.busy):
		printerr("A fase não terminou de carregar.")
		quit(4)
		return
	print("ENEMY_AI_PLAYTEST_READY fase=", phase, " cena=", scene_path, " perfil=", actual)
	if OS.get_environment("ENEMY_AI_PLAYTEST_SMOKE") == "1":
		for frame in range(10): await physics_frame
		if phase == "abadia":
			var started := Time.get_ticks_msec()
			while not scene.requested_backgrounds.is_empty() and Time.get_ticks_msec() - started < 15000:
				await process_frame
			if not scene.requested_backgrounds.is_empty():
				printerr("Carregamento de fundo da Abadia não terminou.")
				quit(5)
				return
		var ok: bool = scene.has_node("ForgottenCemetery/Enemies") if phase == "cemiterio" else is_instance_valid(scene.room) and is_instance_valid(scene.hero)
		print("ENEMY_AI_PLAYTEST_SMOKE fase=", phase, " ready=", ok)
		quit(0 if ok else 5)
