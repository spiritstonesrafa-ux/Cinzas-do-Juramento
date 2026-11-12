extends SceneTree
const P = preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual == personal: quit(2); return
	if P.save_chapter_checkpoint("forest", "ForestCheckpoint0", {}) or FileAccess.file_exists(P.PATH):
		printerr("FAIL fase bloqueada")
		quit(1); return
	if not P.grant_guardian_reward() or not P.grant(): quit(1); return
	var before: Dictionary = P.read_progress()
	if DirAccess.make_dir_absolute(ProjectSettings.globalize_path(P.LOCK_PATH)) != OK: quit(1); return
	if P.save_chapter_checkpoint("forest", "ForestCheckpoint0", {0:{"enemy":0}}):
		printerr("FAIL trava concorrente")
		quit(1); return
	if P.read_progress() != before: printerr("FAIL preservação sob trava"); quit(1); return
	if DirAccess.remove_absolute(ProjectSettings.globalize_path(P.LOCK_PATH)) != OK: quit(1); return
	if not P.save_chapter_checkpoint("forest", "ForestCheckpoint0", {0:{"enemy":0}}): quit(1); return
	var result: Dictionary = P.read_progress()
	if result.get("current_chapter") != "forest" or result.get("campaign_checkpoint") != "ForestCheckpoint0" or not P.unlocked() or not P.guardian_reward_unlocked():
		printerr("FAIL checkpoint atômico")
		quit(1); return
	if int(result.get(P.REVISION, 0)) != int(before.get(P.REVISION, 0)) + 1:
		printerr("FAIL revisão única")
		quit(1); return
	print("PASS checkpoint atômico, trava, progresso e fase bloqueada")
	quit(0)
