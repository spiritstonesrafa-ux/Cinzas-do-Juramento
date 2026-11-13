extends SceneTree
## Script de Captura Visual Automatizada para ATAQUE-SOTN-01.
## Gera as 6 evidências em GPU real (NVIDIA RTX 2060 SUPER) em tests/evidencias/ataque_sotn_01/.

const ARENA_SCRIPT: Script = preload("res://tests/ataque_sotn_arena.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/ataque_sotn_01/"

func _initialize() -> void:
	call_deferred("_run_capture")

func _save_viewport(filename: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	var abs_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var out_path: String = abs_dir.path_join(filename)
	var err: Error = img.save_png(out_path)
	print("  [EVIDÊNCIA GRAVADA] %s (%dx%d) err=%d" % [filename, img.get_width(), img.get_height(), err])

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _run_capture() -> void:
	print("==================================================================")
	print("INICIANDO CAPTURA VISUAL: ATAQUE-SOTN-01 (6 EVIDÊNCIAS)")
	print("==================================================================")

	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	await _frames(6)

	var knight: KnightController = arena.knight
	var attack: SwordAttack = knight.sword_attack

	# ------------------------------------------------------------------
	# 1. Modo Original (caixa frontal)
	# ------------------------------------------------------------------
	print("Capturando 01_modo_original_caixa_frontal.png...")
	attack.mode = SwordAttack.Mode.ORIGINAL
	knight.reset_to(Vector2(265.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	# Avançar para fase ativa do modo original (após 0.10s de windup = 6 frames)
	await _frames(7)
	_save_viewport("01_modo_original_caixa_frontal.png")

	# Aguardar término do ataque
	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(5)

	# ------------------------------------------------------------------
	# 2. Modo SOTN: Região Alta cortando inimigo voador
	# ------------------------------------------------------------------
	print("Capturando 02_sotn_regiao_alta_inimigo_voador.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(730.0, arena.FLOOR_Y))
	knight.facing = 1
	arena.enemy_raven.position = Vector2(746.0, 134.0)
	arena.enemy_raven.reset_enemy()
	await _frames(3)
	attack._start_attack(true, 1)
	# No SOTN, windup é 3 frames (0.05s). Frame 4 entra em ACTIVE (progress < 0.33, Região Alta)
	await _frames(4)
	_save_viewport("02_sotn_regiao_alta_inimigo_voador.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(5)

	# ------------------------------------------------------------------
	# 3. Modo SOTN: Região Frontal cortando esqueleto ou alvo padrão
	# ------------------------------------------------------------------
	print("Capturando 03_sotn_regiao_frontal_alvo_padrao.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(468.0, arena.FLOOR_Y))
	knight.facing = 1
	arena.enemy_skeleton.position = Vector2(490.0, arena.FLOOR_Y)
	arena.enemy_skeleton.reset_enemy()
	await _frames(3)
	attack._start_attack(true, 1)
	# Frame 5: ACTIVE no meio do arco (progress ~0.50, Região Frontal Máxima)
	await _frames(5)
	_save_viewport("03_sotn_regiao_frontal_alvo_padrao.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(5)

	# ------------------------------------------------------------------
	# 4. Modo SOTN: Região Baixa cortando crawler no chão sem Aren abaixar
	# ------------------------------------------------------------------
	print("Capturando 04_sotn_regiao_baixa_crawler_chao.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(590.0, arena.FLOOR_Y))
	knight.facing = 1
	arena.enemy_crawler.position = Vector2(610.0, arena.FLOOR_Y)
	arena.enemy_crawler.reset_enemy()
	await _frames(3)
	attack._start_attack(true, 1)
	# Frame 6: ACTIVE no final do arco (progress > 0.67, Região Baixa rente ao chão)
	await _frames(6)
	_save_viewport("04_sotn_regiao_baixa_crawler_chao.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(5)

	# ------------------------------------------------------------------
	# 5. Modo SOTN: Feixe em Meia-Lua (efeito visual do arco em contraste)
	# ------------------------------------------------------------------
	print("Capturando 05_sotn_feixe_meia_lua_visual.png...")
	attack.mode = SwordAttack.Mode.SOTN
	knight.reset_to(Vector2(340.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	# Frame 5: instante do flash luminoso e faíscas em contraste com o fundo escuro
	await _frames(5)
	_save_viewport("05_sotn_feixe_meia_lua_visual.png")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)
	await _frames(5)

	# ------------------------------------------------------------------
	# 6. Modo SOTN: Ataque Aéreo e Landing Cancel
	# ------------------------------------------------------------------
	print("Capturando 06_sotn_ataque_aereo_landing_cancel.png...")
	attack.mode = SwordAttack.Mode.SOTN
	# Aren salta no ar sobre a plataforma baixa
	knight.reset_to(Vector2(530.0, 105.0))
	knight.velocity = Vector2(60.0, -80.0)
	knight.facing = 1
	await _frames(2)
	attack._start_attack(false, 1)
	await _frames(4)
	_save_viewport("06_sotn_ataque_aereo_landing_cancel.png")

	print("==================================================================")
	print("TODAS AS 6 EVIDÊNCIAS VISUAIS GRAVADAS COM SUCESSO!")
	print("==================================================================")
	quit(0)
