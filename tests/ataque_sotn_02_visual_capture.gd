extends SceneTree
## Script de Captura Visual Automatizada para ATAQUE-SOTN-02.
## Gera as 9 evidências em GPU real (NVIDIA RTX 2060 SUPER) em tests/evidencias/ataque_sotn_02/.

const ARENA_SCRIPT: Script = preload("res://tests/ataque_sotn_arena.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/ataque_sotn_02/"

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
	print("INICIANDO CAPTURA VISUAL: ATAQUE-SOTN-02 (9 EVIDÊNCIAS)")
	print("Refino Visual, Animação Corporal, Espada e Manto Dinâmico")
	print("==================================================================")

	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	await _frames(6)

	var knight: KnightController = arena.knight
	var attack: SwordAttack = knight.sword_attack

	# ------------------------------------------------------------------
	# 1. Ataque no solo — Startup
	# ------------------------------------------------------------------
	print("Capturando 01_solo_startup.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	await _frames(2)
	await _save_viewport("01_solo_startup.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 2. Ataque no solo — Momento Ativo (Mid Sweep & Lunge)
	# ------------------------------------------------------------------
	print("Capturando 02_solo_momento_ativo.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("02_solo_momento_ativo.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 3. Ataque no solo — Recovery (Acomodação e Retração da Lâmina)
	# ------------------------------------------------------------------
	print("Capturando 03_solo_recovery.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.RECOVERY:
		await _frames(1)
	await _frames(2)
	await _save_viewport("03_solo_recovery.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 4. Ataque aéreo — Subida (Ascensão do Salto e Manto Descendente)
	# ------------------------------------------------------------------
	print("Capturando 04_aereo_subida.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(400.0, 120.0))
	knight.velocity = Vector2(70.0, -180.0)
	knight.facing = 1
	await _frames(1)
	attack._start_attack(false, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("04_aereo_subida.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 5. Ataque aéreo — Queda (Descida em Mergulho e Manto Ascendente)
	# ------------------------------------------------------------------
	print("Capturando 05_aereo_queda.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(400.0, 80.0))
	knight.velocity = Vector2(50.0, 160.0)
	knight.facing = 1
	await _frames(1)
	attack._start_attack(false, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("05_aereo_queda.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 6. Landing cancel (Toque Imediato no Solo sem Travamento)
	# ------------------------------------------------------------------
	print("Capturando 06_landing_cancel.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(400.0, 156.0))
	knight.velocity = Vector2(40.0, 120.0)
	knight.facing = 1
	await _frames(1)
	attack._start_attack(false, 1)
	await _frames(3)
	await _save_viewport("06_landing_cancel.png")

	await _frames(6)

	# ------------------------------------------------------------------
	# 7. Comparação ORIGINAL vs SOTN Refinado
	# ------------------------------------------------------------------
	print("Capturando 07_comparativo_original_vs_sotn.png...")
	attack.mode = SwordAttack.Mode.ORIGINAL
	knight.reset_to(Vector2(320.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	await _frames(7)
	await _save_viewport("07_comparativo_original_vs_sotn.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 8. Golpe contra rastejante (ForestCrawler em pé sem agachar)
	# ------------------------------------------------------------------
	print("Capturando 08_golpe_contra_rastejante.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(588.0, arena.FLOOR_Y))
	knight.facing = 1
	arena.enemy_crawler.position = Vector2(610.0, arena.FLOOR_Y)
	arena.enemy_crawler.reset_enemy()
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("08_golpe_contra_rastejante.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(4)

	# ------------------------------------------------------------------
	# 9. Golpe contra inimigo voador (CursedRaven no ar a partir do chão)
	# ------------------------------------------------------------------
	print("Capturando 09_golpe_contra_voador.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(732.0, arena.FLOOR_Y))
	knight.facing = 1
	arena.enemy_raven.position = Vector2(746.0, 134.0)
	arena.enemy_raven.reset_enemy()
	await _frames(3)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.ACTIVE:
		await _frames(1)
	await _frames(1)
	await _save_viewport("09_golpe_contra_voador.png")

	print("==================================================================")
	print("TODAS AS 9 EVIDÊNCIAS VISUAIS DE SOTN-02 GRAVADAS COM SUCESSO!")
	print("==================================================================")
	quit(0)
