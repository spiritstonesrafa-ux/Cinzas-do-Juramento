extends SceneTree
const P: Script = preload("res://scripts/abbey/abbey_progress.gd")
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
	checks += 1
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func reset_fixture() -> void:
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://"+name))
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(P.LOCK_PATH)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(P.LOCK_PATH))
func raw_write(path: String, value: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert(file != null)
	file.store_string(value)
	file.close()
func run() -> void:
	var isolate: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\","/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual.to_lower() == personal.to_lower():
		printerr("Refusing destructive test: user data is not the designated isolated profile: ",actual)
		quit(2)
		return
	print("ISOLATED_USER_DATA=",actual)
	reset_fixture()
	check(P.grant(),"create new save")
	check(P.unlocked() and not P.guardian_reward_unlocked(),"dash only after Abbot")
	check(P._has_valid_backup(),"new save has independently validated backup")
	var one: Dictionary = P.read_progress()
	check(int(one.get(P.REVISION,0)) == 1,"first revision")
	check(P.grant_guardian_reward(),"update existing with guardian reward")
	check(P.unlocked() and P.guardian_reward_unlocked(),"both rewards preserved")
	var two: Dictionary = P.read_progress()
	check(int(two.get(P.REVISION,0)) == 2,"revision increments")
	check(P._backup_names().size()==2,"last valid version retained")
	check(P.grant_guardian_reward() and P.read_progress()==two,"duplicate reward is idempotent")
	for stage: String in ["write","partial_write","after_temp","after_backup","replace","rename_error"]:
		var before: Dictionary = P._load_valid(P.PATH)
		check(not P._grant_fields({"new_unknown":stage},stage),"simulated failure " + stage)
		check(P._load_valid(P.PATH)==before and P.read_progress()==before,"primary preserved " + stage)
	var temp := P.PATH+".tmp-incomplete"
	raw_write(temp,"{broken")
	check(P.read_progress()==two,"incomplete temporary ignored")
	var path_abs: String = ProjectSettings.globalize_path(P.PATH)
	check(DirAccess.remove_absolute(path_abs)==OK,"isolated removal simulates missing primary")
	var backup: Dictionary = P.read_progress()
	check(backup==two,"recover newest valid backup when primary absent")
	check(P.grant() and P._load_valid(P.PATH).get("health_upgrade_unlocked")==true,"existing reward repairs missing primary from backup")
	check(P._grant_fields({"other_achievement":true}),"new reward after backup recovery")
	check(P.read_progress().get("other_achievement")==true and P.unlocked(),"recovery preserves rewards")
	var tampered: Dictionary = P._load_valid(P.PATH)
	tampered["dash_unlocked"] = false
	raw_write(P.PATH,JSON.stringify(tampered))
	check(P.unlocked(),"checksum rejects syntactically valid tampered primary and selects backup")
	reset_fixture()
	var legacy := '{"abbot_defeated":true,"dash_unlocked":true,"version":1}'
	raw_write(P.PATH,legacy)
	check(FileAccess.get_file_as_bytes(P.PATH).size()==56 and P.unlocked(),"legacy 56 bytes loads")
	check(P.grant_guardian_reward() and P.unlocked() and P.guardian_reward_unlocked(),"upgrade legacy without losing dash")
	reset_fixture()
	raw_write(P.PATH,"{broken")
	check(P.read_progress().is_empty() and not P.grant(),"invalid JSON cannot unlock or overwrite")
	check(FileAccess.get_file_as_string(P.PATH)=="{broken","invalid primary preserved")
	reset_fixture()
	check(P.grant(),"create fixture for corrupt primary recovery")
	check(P.grant_guardian_reward(),"produce valid backup")
	raw_write(P.PATH,"{broken")
	check(P.unlocked(),"valid backup readable when primary corrupt")
	check(P.grant_guardian_reward(),"recover from valid backup without losing it")
	check(P.unlocked() and P.guardian_reward_unlocked(),"both rewards after repair")
	var quarantined: bool = false
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json.invalid-"): quarantined = true
	check(quarantined,"corrupt primary quarantined")
	reset_fixture()
	raw_write(P.PATH,JSON.stringify({"version":1,"_save_revision":1,"abbot_defeated":true,"dash_unlocked":true}))
	raw_write("user://"+P.BACKUP_PREFIX+"newer",JSON.stringify({"version":1,"_save_revision":5,"abbot_defeated":true,"dash_unlocked":true,"future_achievement":"kept"}))
	check(int(P.read_progress().get(P.REVISION,0))==5,"higher verified backup revision preferred")
	check(P.grant_guardian_reward(),"update recovered higher revision")
	check(P.read_progress().get("future_achievement")=="kept" and int(P.read_progress().get(P.REVISION,0))==6,"unknown achievement preserved and revision advanced")
	reset_fixture()
	raw_write(P.PATH,JSON.stringify({"version":1,"_save_revision":2,"future":1}))
	raw_write("user://"+P.BACKUP_PREFIX+"conflict",JSON.stringify({"version":1,"_save_revision":2,"future":2}))
	check(P.read_progress().is_empty() and not P.grant(),"equal-revision conflict refuses unsafe choice")
	reset_fixture()
	check(DirAccess.make_dir_absolute(ProjectSettings.globalize_path(P.LOCK_PATH))==OK,"create competing lock")
	check(not P.grant() and not FileAccess.file_exists(P.PATH),"concurrent lock refuses write")
	reset_fixture()
	print("SAVE SAFETY checks=",checks," failures=",failures)
	quit(1 if failures else 0)
