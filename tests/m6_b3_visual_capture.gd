extends SceneTree
## Script oficial de validação visual e captura de evidências GPU para M6-B3 (Setores 7 e 8).
## Renderiza na GPU real (RTX 2060 SUPER), gerando capturas em tests/evidencias/m6b3/.

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6b3")
	print("Iniciando M6-B3 Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# =============================================================
	# REFERÊNCIA ANTERIOR: SETOR 6 APROVADO
	# =============================================================
	print("\n--- [REFERÊNCIA] Capturando: setor6_referencia.png ---")
	await stage.switch_room(5, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(420, 278))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_referencia.png")

	# =============================================================
	# NOVO SETOR 7: FENDA DAS VÉRTEBRAS
	# =============================================================
	print("\n--- [SETOR 7] Capturando: setor7_01_entrada.png ---")
	await stage.switch_room(6, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(80, 220))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_01_entrada.png")

	print("--- [SETOR 7] Capturando: setor7_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(400, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_02_meio.png")

	print("--- [SETOR 7] Capturando: setor7_03_estruturas_fossilizadas.png ---")
	# Aren diante da arcada de vértebras e ossadas gigantes
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(550, 260))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_03_estruturas_fossilizadas.png")

	print("--- [SETOR 7] Capturando: setor7_04_plataformas.png ---")
	# Aren sobre os galhos fósseis e pontes de costelas suspensas
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(440, 160))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_04_plataformas.png")

	print("--- [SETOR 7] Capturando: setor7_05_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(880, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_05_saida.png")

	# =============================================================
	# NOVO SETOR 8: BOSQUE DOS ECOS
	# =============================================================
	print("\n--- [SETOR 8] Capturando: setor8_01_entrada.png ---")
	await stage.switch_room(7, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(80, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_01_entrada.png")

	print("--- [SETOR 8] Capturando: setor8_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(400, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_02_meio.png")

	print("--- [SETOR 8] Capturando: setor8_03_area_monumental.png ---")
	# Aren diante do Monólito dos Ecos no terraço culminante
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(810, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_03_area_monumental.png")

	print("--- [SETOR 8] Capturando: setor8_04_plataformas.png ---")
	# Aren sobre os ramos e cipós fossilizados da abóbada vegetal
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(460, 185))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_04_plataformas.png")

	print("--- [SETOR 8] Capturando: setor8_05_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(920, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_05_saida.png")

	# =============================================================
	# INTEGRAÇÃO: TRANSIÇÕES E TRAVESSIA DE OBSTÁCULO
	# =============================================================
	print("\n--- [TRANSIÇÃO] Capturando: transicao_setor6_para_7.png ---")
	await stage.switch_room(5, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(936, 220))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/transicao_setor6_para_7.png")

	print("\n--- [TRANSIÇÃO] Capturando: transicao_setor7_para_8.png ---")
	await stage.switch_room(6, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(936, 240))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/transicao_setor7_para_8.png")

	print("\n--- [TRAVESSIA] Capturando: aren_travessia_obstaculo_s7.png ---")
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(450, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(6)
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	await frames(6)
	await shot(out_dir + "/aren_travessia_obstaculo_s7.png")
	Input.action_release("move_right")
	await frames(20)

	print("\nM6-B3 Visual Capture concluída com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)
