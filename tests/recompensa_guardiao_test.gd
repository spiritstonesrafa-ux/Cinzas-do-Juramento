extends SceneTree
## Comprehensive integration test for Boss 1 (Oath Guardian) permanent +1 Max HP reward.
## Tests all 15 points from Section 12 in an isolated profile environment.

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
	# POINT 12 & 13: Fresh isolated profile has no pre-existing save
	clear_test_save()
	check(not ABBEY_PROGRESS.guardian_reward_unlocked(), "Point 1 & 13: Fresh progression has no guardian reward")
	check(not ABBEY_PROGRESS.unlocked(), "Point 1: Fresh progression has no dash")

	# POINT 2: Fresh player instance has default max HP = 5
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await frames(5)
	var stage: Node2D = main.get_node("ForgottenCemetery")
	var hero: KnightController = stage.get_node("Knight")
	var encounter: Node2D = main.get_node("GuardianEncounter")

	check(hero.survival.max_health == 5, "Point 2: Initial max HP is 5")
	check(hero.survival.current_health == 5, "Point 2: Initial current HP is 5")

	# POINT 3: Boss alive
	hero.reset_to(Vector2(2340, 138))
	await frames(10)
	check(encounter.active and encounter.arena != null, "Point 3: Encounter activated and arena created")
	var guardian: OathGuardian = encounter.arena.get_node("Guardian")
	check(guardian.current_health == guardian.max_health and guardian.current_health == 10, "Point 3: Boss is alive with 10 HP")

	# Damage hero slightly to verify current HP +1 rule (rule 8.3: adds exactly 1 to current health, no arbitrary full heal)
	hero.survival.receive_damage(2)
	check(hero.survival.current_health == 3, "Hero took 2 damage: current HP is 3/5")

	# POINT 4: Legitimate victory
	# Deliver hits to guardian when vulnerable until HP reaches 0
	guardian.awake = true
	while guardian.current_health > 0:
		while guardian.state in [OathGuardian.State.INTRO, OathGuardian.State.WAKE, OathGuardian.State.PHASE_TRANSITION, OathGuardian.State.HURT]:
			await frames(3)
		if guardian.state == OathGuardian.State.DEFEATED:
			break
		guardian.receive_hit()
		await frames(12)
	check(guardian.current_health == 0, "Boss HP reached 0")
	check(encounter.completed, "Point 4: Legitimate victory registered")

	# POINT 5 & 6: Max HP +1 and Current HP +1
	check(hero.survival.max_health == 6, "Point 5: Max HP increased by exactly 1 (5 -> 6)")
	check(hero.survival.current_health == 4, "Point 6: Current HP increased by exactly 1 (3 -> 4, no full heal)")

	# POINT 7: HUD updated
	var hud_label: Label = stage.get_node("HealthHUD/Life")
	check(hud_label.text == "VIDA 4/6", "Point 7: HUD Life label reads VIDA 4/6")
	var hud_frame: Node2D = stage.get_node("HealthHUD/Frame")
	check(hud_frame.maximum == 6 and hud_frame.current == 4, "Point 7: HUD Frame maximum is 6 and current is 4")

	# POINT 11: Refight does not duplicate reward
	# Call _on_defeated again
	encounter._on_defeated()
	check(hero.survival.max_health == 6, "Point 11: Second victory call does NOT increase max HP beyond 6")
	check(hero.survival.current_health == 4, "Point 11: Second victory call does NOT add extra current HP")

	# POINT 9 & 10: Persistence after death and respawn
	# Wait for any prior invulnerability to clear before inflicting lethal damage
	await frames(55)
	hero.survival.receive_damage(4)
	check(hero.survival.is_dead, "Hero died")
	await frames(45) # Wait for death delay (0.6s) and respawn
	check(not hero.survival.is_dead, "Hero respawned")
	check(hero.survival.max_health == 6, "Point 9: Max HP remains 6 after death")
	check(hero.survival.current_health == 6, "Point 10: Respawn restores health to new max HP (6/6)")

	# Clean up main
	main.queue_free()
	await frames(3)

	# POINT 8: Persistence across closing and reopening game (new scene tree instance)
	var main2: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main2)
	await frames(5)
	var hero2: KnightController = main2.get_node("ForgottenCemetery/Knight")
	check(hero2.survival.max_health == 6, "Point 8: New game instance reads saved +1 Max HP (starts at 6)")
	check(hero2.survival.current_health == 6, "Point 8: New game instance current HP is 6/6")
	main2.queue_free()
	await frames(3)

	# POINT 14: Compatibility with Boss 2 dash reward
	# Grant dash via AbbeyProgress
	check(ABBEY_PROGRESS.grant(), "Grant dash reward")
	check(ABBEY_PROGRESS.unlocked(), "Dash is unlocked")
	check(ABBEY_PROGRESS.guardian_reward_unlocked(), "Guardian reward is still unlocked alongside dash")
	var main3: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main3)
	await frames(5)
	var hero3: KnightController = main3.get_node("ForgottenCemetery/Knight")
	check(hero3.dash_unlocked, "Point 14: Aren has dash unlocked")
	check(hero3.survival.max_health == 6, "Point 14: Aren simultaneously has 6 Max HP")
	main3.queue_free()
	await frames(3)

	# POINT 15: Compatibility with older saves (save having only abbot_defeated and dash_unlocked)
	clear_test_save()
	var file: FileAccess = FileAccess.open(ABBEY_PROGRESS.PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify({"version": 1, "abbot_defeated": true, "dash_unlocked": true}))
	file.close()

	check(ABBEY_PROGRESS.unlocked(), "Old save has dash")
	check(not ABBEY_PROGRESS.guardian_reward_unlocked(), "Point 15: Old save does NOT have guardian reward yet")

	var main4: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main4)
	await frames(5)
	var hero4: KnightController = main4.get_node("ForgottenCemetery/Knight")
	check(hero4.survival.max_health == 5, "Point 15: Old save starts with base 5 Max HP")
	check(hero4.dash_unlocked, "Point 15: Old save retains dash")

	# Defeating guardian on old save upgrades cleanly
	var enc4: Node2D = main4.get_node("GuardianEncounter")
	hero4.reset_to(Vector2(2340, 138))
	await frames(10)
	enc4._on_defeated()
	check(hero4.survival.max_health == 6, "Point 15: Defeating guardian on old save upgrades Max HP to 6")
	check(ABBEY_PROGRESS.unlocked(), "Point 15: Dash remains unlocked after guardian upgrade on old save")
	check(ABBEY_PROGRESS.guardian_reward_unlocked(), "Point 15: Guardian reward is now saved")

	main4.queue_free()
	await frames(3)

	# Clean test save at end
	clear_test_save()

	print("GUARDIAN REWARD CHECKS: ", checks, " FAILURES: ", failures)
	quit(1 if failures > 0 else 0)
