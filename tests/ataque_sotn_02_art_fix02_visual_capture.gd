extends SceneTree
## Script de Captura Visual Comparativa: ARM-FIX01 vs ART-FIX02.
## Captura os momentos exatos do golpe para ambos os modos visuais.
## Salva em res://tests/evidencias/ataque_sotn_02_art_fix02/.

const ARENA_SCRIPT: Script = preload("res://tests/ataque_sotn_arena.gd")
const KNIGHT_VISUAL_SCRIPT: Script = preload("res://scripts/player/knight_visual.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/ataque_sotn_02_art_fix02/"

func _initialize() -> void:
	call_deferred("_run_capture")

func _save_viewport(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_viewport().get_texture().get_image()
	var abs_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var out_path: String = abs_dir.path_join(filename)
	var err: Error = img.save_png(out_path)
	print("  [EVIDÊNCIA GRAVADA] %s (%dx%d) err=%d" % [filename, img.get_width(), img.get_height(), err])

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_capture() -> void:
	print("==================================================================")
	print("INICIANDO CAPTURA COMPARATIVA: ARM-FIX01 vs ART-FIX02")
	print("==================================================================")

	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	await _frames(6)

	var knight: KnightController = arena.knight
	var attack: SwordAttack = knight.sword_attack
	var visual = knight.visual

	# ==================================================================
	# 1. ARM-FIX01: Startup no solo
	# ==================================================================
	print("1. Capturando 01_arm_fix01_startup.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	await _frames(2)
	await _save_viewport("01_arm_fix01_startup.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 2. ART-FIX02: Startup no solo
	# ==================================================================
	print("2. Capturando 02_art_fix02_startup.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	await _frames(2)
	await _save_viewport("02_art_fix02_startup.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 3. ARM-FIX01: Active no solo
	# ==================================================================
	print("3. Capturando 03_arm_fix01_active.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("03_arm_fix01_active.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 4. ART-FIX02: Active no solo
	# ==================================================================
	print("4. Capturando 04_art_fix02_active.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("04_art_fix02_active.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 5. ARM-FIX01: Recovery no solo
	# ==================================================================
	print("5. Capturando 05_arm_fix01_recovery.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.RECOVERY:
		await _frames(1)
	await _frames(2)
	await _save_viewport("05_arm_fix01_recovery.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 6. ART-FIX02: Recovery no solo
	# ==================================================================
	print("6. Capturando 06_art_fix02_recovery.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.RECOVERY:
		await _frames(1)
	await _frames(2)
	await _save_viewport("06_art_fix02_recovery.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 7. ARM-FIX01: Aéreo no ar (Active)
	# ==================================================================
	print("7. Capturando 07_arm_fix01_aereo.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(400.0, 110.0))
	knight.velocity = Vector2(70.0, -160.0)
	knight.facing = 1
	await _frames(1)
	attack._start_attack(false, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("07_arm_fix01_aereo.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 8. ART-FIX02: Aéreo no ar (Active)
	# ==================================================================
	print("8. Capturando 08_art_fix02_aereo.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(400.0, 110.0))
	knight.velocity = Vector2(70.0, -160.0)
	knight.facing = 1
	await _frames(1)
	attack._start_attack(false, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("08_art_fix02_aereo.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ==================================================================
	# 9. ART-FIX02: Impacto contra Inimigo (Spark Burst)
	# ==================================================================
	print("9. Capturando 09_art_fix02_impacto_alvo.png...")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(2)
	await _save_viewport("09_art_fix02_impacto_alvo.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)

	print("Capturas concluídas com sucesso.")
	quit(0)
