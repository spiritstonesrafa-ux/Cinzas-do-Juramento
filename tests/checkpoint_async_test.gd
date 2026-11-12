extends SceneTree
const P = preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var isolate := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path().to_lower()
	var actual := OS.get_user_data_dir().replace("\\", "/").simplify_path().to_lower()
	var personal := OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path().to_lower()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual == personal: quit(2); return
	if not P.grant_guardian_reward() or not P.grant(): quit(1); return
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(P.PATH)
	for i in range(100):
		var f := FileAccess.open("user://" + P.BACKUP_PREFIX + "async-" + str(i), FileAccess.WRITE)
		f.store_buffer(bytes)
		f.close()
	var forest = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(forest)
	while forest.busy or forest.current_room < 0: await process_frame
	var cp: RespawnCheckpoint = forest.checkpoints[0]
	forest.hero.activate_checkpoint(cp)
	if forest.hero.active_checkpoint != cp or forest._checkpoint_writer == null:
		printerr("FAIL ativação ou gravação assíncrona")
		quit(1); return
	forest.queue_free()
	await process_frame
	await process_frame
	var saved := P.campaign_location()
	if saved.chapter != "forest" or saved.checkpoint != "ForestCheckpoint0" or not P.unlocked() or not P.guardian_reward_unlocked():
		printerr("FAIL saída imediata ou persistência: ", saved)
		quit(1); return
	print("PASS ativação assíncrona e saída imediata preservam checkpoint e recompensas")
	quit(0)
