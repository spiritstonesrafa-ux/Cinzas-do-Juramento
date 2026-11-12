extends SceneTree

const PROGRESS = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolate.is_empty() or not actual.to_lower().begins_with(isolate.to_lower() + "/") or actual.to_lower() == personal.to_lower():
		printerr("Perfil isolado obrigatório")
		quit(2)
		return
	var stage := OS.get_environment("RETORNO_PERSIST_STAGE")
	if stage == "write":
		var legacy := PROGRESS.campaign_location()
		if legacy.chapter != "cemetery" or legacy.highest_unlocked != 0 or not PROGRESS.grant_guardian_reward() or not PROGRESS.grant() or not PROGRESS.save_campaign_location("abbey", "abbey_cp_7"):
			printerr("FAIL gravação")
			quit(1)
			return
		print("PASS gravação em perfil isolado")
	elif stage == "read":
		var state := PROGRESS.campaign_location()
		if state.chapter != "abbey" or state.highest_unlocked != 2 or state.checkpoint != "abbey_cp_7" or not PROGRESS.guardian_reward_unlocked() or not PROGRESS.unlocked():
			printerr("FAIL retomada de dados")
			quit(1)
			return
		if not PROGRESS.save_campaign_location("cemetery", "cemetery_cp_2") or PROGRESS.campaign_location().highest_unlocked != 2:
			printerr("FAIL progresso máximo")
			quit(1)
			return
		print("PASS leitura independente e progresso máximo")
	else:
		printerr("Etapa inválida")
		quit(2)
		return
	quit(0)
