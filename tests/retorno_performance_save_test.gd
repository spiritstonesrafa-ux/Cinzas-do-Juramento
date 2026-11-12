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
	if not P.grant_guardian_reward() or not P.grant(): quit(1); return
	var source: PackedByteArray = FileAccess.get_file_as_bytes(P.PATH)
	for i in range(100):
		var out := FileAccess.open("user://" + P.BACKUP_PREFIX + "perf-" + str(i), FileAccess.WRITE)
		out.store_buffer(source)
		out.close()
	var elapsed := Time.get_ticks_usec()
	for i in range(30):
		if not P.unlocked(): quit(1); return
	print("BENCH_CHECKS=30 BACKUPS=102 TOTAL_MS=", (Time.get_ticks_usec()-elapsed)/1000.0)
	var cp_start := Time.get_ticks_usec()
	if not P.save_chapter_states("forest", {"0": {"sample": 1}}) or not P.save_campaign_location("forest", "ForestCheckpoint0"):
		quit(1)
		return
	print("BENCH_CHECKPOINT_OLD_TWO_WRITES_MS=", (Time.get_ticks_usec()-cp_start)/1000.0)
	cp_start = Time.get_ticks_usec()
	if not P.save_chapter_checkpoint("forest", "ForestCheckpoint1", {"0": {"sample": 2}}):
		quit(1)
		return
	print("BENCH_CHECKPOINT_NEW_ONE_WRITE_MS=", (Time.get_ticks_usec()-cp_start)/1000.0)
	var abbey = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(abbey)
	while abbey.busy or abbey.current_room < 0: await process_frame
	await abbey.switch_room(11)
	abbey.hero.global_position = AbbeyChapterLayout.origin(11) + Vector2(1305, 300)
	var begin := Time.get_ticks_usec()
	for i in range(10): abbey._physics_process(1.0/60.0)
	print("BENCH_ABBEY_FRAMES=10 TOTAL_MS=", (Time.get_ticks_usec()-begin)/1000.0)
	abbey.queue_free()
	await process_frame
	var forest = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(forest)
	while forest.busy or forest.current_room < 0: await process_frame
	await forest.switch_room(9)
	begin = Time.get_ticks_usec()
	for i in range(10): forest._physics_process(1.0/60.0)
	print("BENCH_CERVO_FRAMES=10 TOTAL_MS=", (Time.get_ticks_usec()-begin)/1000.0)
	var cp: RespawnCheckpoint = forest.checkpoints[9]
	begin = Time.get_ticks_usec()
	forest.hero.activate_checkpoint(cp)
	print("BENCH_CHECKPOINT_ACTIVATION_MS=", (Time.get_ticks_usec()-begin)/1000.0, " ACTIVE=", forest.hero.active_checkpoint == cp)
	forest._finish_checkpoint_write()
	forest.queue_free()
	await process_frame
	quit(0)
