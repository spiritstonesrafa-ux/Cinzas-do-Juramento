extends SceneTree
## Script de captura de evidências visuais GPU para a Auditoria Final M6-B3 + FIX01 + FIX02.
## Executa na GPU real (NVIDIA GeForce RTX 2060 SUPER), gerando capturas em tests/evidencias/m6_auditoria_final/.

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6_auditoria_final")
	print("Iniciando M6 Auditoria Final Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# --- PARTE 1: SETOR 1 (CORREÇÃO DE RETORNO - FIX02) ---
	var ox0: float = ForestLayout.ORIGINS[0].x
	print("\n--- [SETOR 1] Capturando: setor1_01_retorno_degrau_livre.png ---")
	hero.reset_to(Vector2(ox0 + 760.0, 300.0))
	hero.facing = -1
	stage.camera.position = Vector2(ox0 + 740.0, 250.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_01_retorno_degrau_livre.png")

	print("--- [SETOR 1] Capturando: setor1_02_retorno_salto_desobstruido.png ---")
	hero.reset_to(Vector2(ox0 + 735.0, 270.0))
	hero.facing = -1
	hero.velocity = Vector2(-80.0, -100.0)
	stage.camera.position = Vector2(ox0 + 730.0, 245.0)
	stage.camera.force_update_scroll()
	await frames(10)
	await shot(out_dir + "/setor1_02_retorno_salto_desobstruido.png")

	# --- PARTE 2: SETOR 7 (FENDA DAS VÉRTEBRAS - M6-B3) ---
	await stage.switch_room(6, false)
	while stage.busy:
		await physics_frame
	var ox6: float = ForestLayout.ORIGINS[6].x

	print("\n--- [SETOR 7] Capturando: setor7_01_entrada.png ---")
	hero.reset_to(Vector2(ox6 + 80.0, 220.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox6 + 160.0, 220.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_01_entrada.png")

	print("--- [SETOR 7] Capturando: setor7_02_fenda_vertebras.png ---")
	hero.reset_to(Vector2(ox6 + 460.0, 260.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox6 + 490.0, 240.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_02_fenda_vertebras.png")

	print("--- [SETOR 7] Capturando: setor7_03_plataformas_aereas.png ---")
	hero.reset_to(Vector2(ox6 + 340.0, 154.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox6 + 360.0, 180.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_03_plataformas_aereas.png")

	print("--- [SETOR 7] Capturando: setor7_04_terraco_saida.png ---")
	hero.reset_to(Vector2(ox6 + 850.0, 240.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox6 + 800.0, 230.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_04_terraco_saida.png")

	# --- PARTE 3: SETOR 8 (BOSQUE DOS ECOS - M6-B3) ---
	await stage.switch_room(7, false)
	while stage.busy:
		await physics_frame
	var ox7: float = ForestLayout.ORIGINS[7].x

	print("\n--- [SETOR 8] Capturando: setor8_01_entrada.png ---")
	hero.reset_to(Vector2(ox7 + 80.0, 240.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox7 + 160.0, 230.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_01_entrada.png")

	print("--- [SETOR 8] Capturando: setor8_02_abobada_e_chama.png ---")
	hero.reset_to(Vector2(ox7 + 490.0, 260.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox7 + 510.0, 240.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_02_abobada_e_chama.png")

	print("--- [SETOR 8] Capturando: setor8_03_plataformas_ecos.png ---")
	hero.reset_to(Vector2(ox7 + 460.0, 154.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox7 + 460.0, 180.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_03_plataformas_ecos.png")

	print("--- [SETOR 8] Capturando: setor8_04_monolito_dos_ecos.png ---")
	hero.reset_to(Vector2(ox7 + 850.0, 240.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox7 + 800.0, 210.0)
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/setor8_04_monolito_dos_ecos.png")

	print("--- [SETOR 8] Capturando: setor8_05_retorno_setor7.png ---")
	hero.reset_to(Vector2(ox7 + 120.0, 240.0))
	hero.facing = -1
	stage.camera.position = Vector2(ox7 + 160.0, 230.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_05_retorno_setor7.png")

	print("\nTodas as 11 capturas da Auditoria Final foram geradas com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)
