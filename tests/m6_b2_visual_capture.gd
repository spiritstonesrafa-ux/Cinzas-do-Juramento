extends SceneTree
## Script oficial de validação visual e captura de evidências GPU para M6-B2 (Setores 5 e 6).
## Renderiza na GPU real (RTX 2060 SUPER), gerando capturas em tests/evidencias/m6b2/.

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6b2")
	print("Iniciando M6-B2 Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# =============================================================
	# REFERÊNCIAS ANTERIORES: SETOR 3 E SETOR 4
	# =============================================================
	print("\n--- [REFERÊNCIA] Capturando: setor3_referencia.png ---")
	await stage.switch_room(2, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(460, 290))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_referencia.png")

	print("\n--- [REFERÊNCIA] Capturando: setor4_referencia.png ---")
	await stage.switch_room(3, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(450, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_referencia.png")

	# =============================================================
	# NOVO SETOR 5: PASSAGEM DAS RAÍZES PROFUNDAS
	# =============================================================
	print("\n--- [SETOR 5] Capturando: setor5_01_entrada.png ---")
	await stage.switch_room(4, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(80, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor5_01_entrada.png")

	print("--- [SETOR 5] Capturando: setor5_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(420, 308))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor5_02_meio.png")

	print("--- [SETOR 5] Capturando: setor5_03_plataformas.png ---")
	# Aren posicionado sobre as raízes elevadas
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(280, 170))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor5_03_plataformas.png")

	print("--- [SETOR 5] Capturando: setor5_04_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(860, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor5_04_saida.png")

	# =============================================================
	# NOVO SETOR 6: GALERIA DOS OSSOS ANTIGOS
	# =============================================================
	print("\n--- [SETOR 6] Capturando: setor6_01_entrada.png ---")
	await stage.switch_room(5, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(80, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_01_entrada.png")

	print("--- [SETOR 6] Capturando: setor6_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(420, 278))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_02_meio.png")

	print("--- [SETOR 6] Capturando: setor6_03_estruturas_osseas.png ---")
	# Aren diante do Grande Ossuário e arcos ogivais
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(760, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_03_estruturas_osseas.png")

	print("--- [SETOR 6] Capturando: setor6_04_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(880, 220))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_04_saida.png")

	# =============================================================
	# TRAVESSIA DE OBSTÁCULO E TRANSIÇÃO ENTRE SETORES
	# =============================================================
	print("\n--- [TRAVESSIA] Capturando: aren_travessia_obstaculo.png ---")
	await stage.switch_room(4, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(480, 308))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(6)
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	await frames(6)
	await shot(out_dir + "/aren_travessia_obstaculo.png")
	Input.action_release("move_right")
	await frames(20)

	print("\n--- [TRANSIÇÃO] Capturando: transicao_setor5_para_6.png ---")
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(936, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/transicao_setor5_para_6.png")

	print("\nM6-B2 Visual Capture concluída com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)
