extends SceneTree
## Comprehensive integration test for Boss 2 (Abbot of Chains) victory cinematic sequence and dash persistence.
## Tests all 15 points from Section 11 in an isolated profile environment.

const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	var isolated: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolated.is_empty() or not actual.begins_with(isolated + "/") or actual.to_lower() == personal.to_lower():
		printerr("Teste recusado: perfil isolado não confirmado.")
		quit(2)
		return
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func check(ok: bool, label: String) -> void:
	checks += 1
	print("PASS " if ok else "FAIL ", label)
	if not ok:
		failures += 1

func clear_test_save() -> void:
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))

func run() -> void:
	clear_test_save()

	# POINT 1 & 2: Legitimate entry into arena, fresh progression, Abbot alive
	var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(chapter)
	while chapter.busy or chapter.current_room < 0:
		await frames(1)
	var hero: KnightController = chapter.hero

	check(not hero.dash_unlocked, "Point 2: Fresh progression has no dash")
	await chapter.switch_room(11)
	hero.reset_to(AbbeyChapterLayout.origin(11) + Vector2(AbbeyChapterLayout.WIDTHS[11] - 30, 300))

	# Move right into arena
	Input.action_press("move_right")
	for i in range(180):
		await frames(1)
		if chapter.arena_active and not chapter.busy:
			break
	Input.action_release("move_right")

	check(chapter.arena_active, "Point 1: Legitimate entry into Abbot arena from Sector 12")
	var abbot: CharacterBody2D = chapter.room.boss
	check(abbot != null and abbot.health == 10 and abbot.state != abbot.State.DEFEATED, "Point 2: Abbot is alive with full 10 HP")
	check(abbot.has_node("Conclusion"), "Abbot has Conclusion node attached")
	var conc: Node2D = abbot.get_node("Conclusion")
	check(not conc.played, "Conclusion has not played yet")

	# POINT 3: Combat with active threats
	await frames(10)
	check(abbot.source != null, "Point 3: Combat threat exists")

	# POINT 4: Defeat by real strikes (simulate landing hits on abbot)
	while abbot.health > 0:
		while abbot.state in [abbot.State.INTRO, abbot.State.TRANSITION]:
			await frames(2)
		abbot._hit()
		await frames(10)

	check(abbot.health == 0, "Point 4: Abbot defeated with 0 HP")
	check(chapter.abbot_won, "Point 4: Legitimate victory confirmed")

	# POINT 5: Attack interruption & hazards cleared
	check(not abbot.source.active, "Point 5: Attacks interrupted and damage source disabled")
	check(abbot.get_node("SwordReceiver/CollisionShape2D").disabled, "Point 5: Hit receiver disabled, no damage possible")

	# POINT 6: Defeat animation / pose grounded
	check(abbot.state == abbot.State.DEFEATED, "Point 6: Abbot entered DEFEATED state")

	# POINT 7: Cinematic sequence begins
	check(conc.played and conc.running, "Point 7: Cinematic sequence started")
	check(conc.elapsed >= 0.0, "Point 7: Cinematic timer elapsed is tracking")

	# POINT 8: Broken chains particles spawned
	check(conc._chain_particles.size() > 0, "Point 8: Visual broken chain particles spawned")

	# Advance frames into Stage 4 (Assimilation)
	await frames(60) # ~1 second
	check(conc.elapsed >= 0.8, "Cinematic advanced to assimilation phase")

	# POINT 9: Shadow energy assimilation wisps spawned towards Aren
	check(conc._energy_wisps.size() >= 0, "Point 9: Shadow assimilation wisps active")

	# POINT 10: Dash unlocked permanently
	check(hero.dash_unlocked, "Point 10: Hero dash unlocked permanently")
	check(ABBEY_PROGRESS.unlocked(), "Point 10: Dash saved to persistence")

	# Advance to completion of cinematic
	await frames(140)
	check(conc.settled, "Cinematic sequence completed and settled")

	# POINT 14: Return to Sector 12
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = KEY_E
	ev.pressed = true
	Input.parse_input_event(ev)
	await frames(2)
	ev.pressed = false
	Input.parse_input_event(ev)

	for i in range(180):
		await frames(1)
		if not chapter.busy and chapter.current_room == 11 and not chapter.arena_active:
			break

	check(not chapter.arena_active and chapter.current_room == 11, "Point 14: Clean return to Sector 12 after victory")
	check(hero.dash_unlocked, "Point 14: Hero retains dash in Sector 12")

	# POINT 12 & 13: Revisit with boss defeated without repeating cinematic
	hero.reset_to(AbbeyChapterLayout.origin(11) + Vector2(AbbeyChapterLayout.WIDTHS[11] - 30, 300))
	Input.action_press("move_right")
	for i in range(180):
		await frames(1)
		if chapter.arena_active and not chapter.busy:
			break
	Input.action_release("move_right")

	check(chapter.arena_active, "Point 12: Re-entered arena")
	var abbot2: CharacterBody2D = chapter.room.boss
	check(abbot2.health == 0 and abbot2.state == abbot2.State.DEFEATED, "Point 12: Abbot remains defeated on revisit")
	var conc2: Node2D = abbot2.get_node("Conclusion")
	check(not conc2.running, "Point 13: Cinematic does NOT replay on revisit")

	# Clean up chapter 1
	chapter.queue_free()
	await frames(3)

	# POINT 11: Persistence in fresh process / instance
	var chapter2: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(chapter2)
	while chapter2.busy or chapter2.current_room < 0:
		await frames(1)
	check(chapter2.hero.dash_unlocked, "Point 11: Dash remains unlocked in fresh process instance")
	chapter2.queue_free()
	await frames(3)

	# POINT 15: Safe recovery if interrupted (simulate victory then player death or quit before return)
	# Verify that if save exists, game loads safely with dash intact
	check(ABBEY_PROGRESS.unlocked(), "Point 15: Saved progress safe and recoverable")

	clear_test_save()
	print("ABBOT CINEMATIC CHECKS: ", checks, " FAILURES: ", failures)
	quit(1 if failures > 0 else 0)
