extends SceneTree
## Script oficial de validação visual e captura de evidências GPU para M6-B4 (Setores 9 e 10).
## Renderiza na GPU real (RTX 2060 SUPER), gerando capturas em tests/evidencias/m6b4/.

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func shot(filepath: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("AVISO: Headless, captura ignorada para ", filepath)
		return
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var dir: String = filepath.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err: Error = img.save_png(filepath)
	print("CAPTURA GERADA: ", filepath, " tamanho=", img.get_size(), " erro=", err)

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6b4")
	print("Iniciando M6-B4 Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# =============================================================
	# REFERÊNCIA ANTERIOR: SETOR 8 APROVADO
	# =============================================================
	print("\n--- [REFERÊNCIA] Capturando: setor8_referencia.png ---")
	await stage.switch_room(7, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(810, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_referencia.png")

	# =============================================================
	# NOVO SETOR 9: RAVINA DAS SOMBRAS FÓSSEIS
	# =============================================================
	print("\n--- [SETOR 9] Capturando: setor9_01_entrada.png ---")
	await stage.switch_room(8, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(80, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor9_01_entrada.png")

	print("--- [SETOR 9] Capturando: setor9_02_ravina_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(360, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor9_02_ravina_meio.png")

	print("--- [SETOR 9] Capturando: setor9_03_abismo_sombras.png ---")
	# Aren diante do abismo central da ravina e arcada de costelas
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(430, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor9_03_abismo_sombras.png")

	print("--- [SETOR 9] Capturando: setor9_04_plataformas_aereas.png ---")
	# Aren sobre o arco central de ossadas suspensas sobre a ravina
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(480, 154))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor9_04_plataformas_aereas.png")

	print("--- [SETOR 9] Capturando: setor9_05_terraco_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(870, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor9_05_terraco_saida.png")

	# =============================================================
	# NOVO SETOR 10: CLAREIRA DA BRUMA ESPECTRAL (ARENA DO CERVO)
	# =============================================================
	print("\n--- [SETOR 10] Capturando: setor10_01_entrada_arena.png ---")
	await stage.switch_room(9, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(80, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor10_01_entrada_arena.png")

	print("--- [SETOR 10] Capturando: setor10_02_visao_geral_arena.png ---")
	# Aren percorrendo o chão plano da arena
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(300, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor10_02_visao_geral_arena.png")

	print("--- [SETOR 10] Capturando: setor10_03_altar_bruma_espectral.png ---")
	# Aren diante do Altar da Bruma Espectral no coração da arena
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(480, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor10_03_altar_bruma_espectral.png")

	print("--- [SETOR 10] Capturando: setor10_04_abobada_costelas_poleiro.png ---")
	# Aren sobre a abóbada de costelas no poleiro superior da arena
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(420, 186))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor10_04_abobada_costelas_poleiro.png")

	print("--- [SETOR 10] Capturando: setor10_05_portico_do_juramento.png ---")
	# Aren diante do Pórtico Rúnico no extremo leste da fase
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(890, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor10_05_portico_do_juramento.png")

	# =============================================================
	# INTEGRAÇÃO: TRANSIÇÕES E TRAVESSIA DE OBSTÁCULO
	# =============================================================
	print("\n--- [TRANSIÇÃO] Capturando: transicao_setor8_para_9.png ---")
	await stage.switch_room(7, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(936, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/transicao_setor8_para_9.png")

	print("\n--- [TRANSIÇÃO] Capturando: transicao_setor9_para_10.png ---")
	await stage.switch_room(8, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(936, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/transicao_setor9_para_10.png")

	print("\n--- [TRAVESSIA] Capturando: aren_salto_abismo_s9.png ---")
	hero.reset_to(ForestLayout.ORIGINS[8] + Vector2(430, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(6)
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	await frames(6)
	await shot(out_dir + "/aren_salto_abismo_s9.png")
	Input.action_release("move_right")
	await frames(20)

	# =============================================================
	# FIX01: EVIDÊNCIAS DE EXPLORAÇÃO LIVRE E RETORNO BIDIRECIONAL
	# =============================================================
	print("\n--- [FIX01] Capturando: setor10_sem_vitoria_prematura.png ---")
	await stage.switch_room(9, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(400, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(10)
	await shot(out_dir + "/setor10_sem_vitoria_prematura.png")
	Input.action_release("move_right")
	await frames(10)

	print("\n--- [FIX01] Capturando: setor10_retorno_setor9.png ---")
	hero.reset_to(ForestLayout.ORIGINS[9] + Vector2(30, 260))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_left")
	await frames(10)
	await shot(out_dir + "/setor10_retorno_setor9.png")
	Input.action_release("move_left")
	await frames(10)

	print("\nM6-B4 Visual Capture concluída com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)
