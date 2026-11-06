extends SceneTree
const P: Script = preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: run.call_deferred()
func run() -> void:
	var isolate: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\","/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual.to_lower() == personal.to_lower():
		printerr("Refusing non-isolated test")
		quit(2)
		return
	var mode: String = OS.get_environment("SAVE_SAFETY_STAGE")
	if mode == "write":
		var ok: bool = not FileAccess.file_exists(P.PATH) and P.grant() and P.grant_guardian_reward()
		print("RESTART WRITE=",ok)
		quit(0 if ok else 1)
		return
	var data: Dictionary = P.read_progress()
	var rev: int = int(data.get(P.REVISION,0))
	var ok: bool = P.unlocked() and P.guardian_reward_unlocked() and P.grant() and P.grant_guardian_reward() and int(P.read_progress().get(P.REVISION,0)) == rev
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	root.add_child(hero)
	await process_frame
	ok = ok and hero.dash_unlocked and hero.survival.max_health == 6
	print("RESTART READ=",ok," revision=",rev," dash=",hero.dash_unlocked," hp=",hero.survival.max_health)
	hero.queue_free()
	quit(0 if ok else 1)
