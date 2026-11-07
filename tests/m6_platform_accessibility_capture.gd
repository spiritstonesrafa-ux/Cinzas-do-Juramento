extends SceneTree
## Script de captura de evidências visuais GPU para M6 Platform Accessibility Fix01.
## Executa na GPU real (NVIDIA GeForce RTX 2060 SUPER), gerando capturas em tests/evidencias/m6_platform_accessibility/.

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6_platform_accessibility")
	print("Iniciando M6 Platform Accessibility Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# 1. SETOR 1: Entrada da Floresta — Aren sobre a Branch 0 e sobre a Canópea Central
	print("\n--- [SETOR 1] Capturando: setor1_01_branch0_acessivel.png ---")
	hero.reset_to(ForestLayout.ORIGINS[0] + Vector2(220, 266))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_01_branch0_acessivel.png")

	print("--- [SETOR 1] Capturando: setor1_02_canopea_central.png ---")
	hero.reset_to(ForestLayout.ORIGINS[0] + Vector2(430, 222))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_02_canopea_central.png")

	# 2. SETOR 2: Bosque das Raízes — Aren no dossel sobrevoando o abismo
	print("\n--- [SETOR 2] Capturando: setor2_01_dossel_raizes.png ---")
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[1] + Vector2(490, 252))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_01_dossel_raizes.png")

	print("--- [SETOR 2] Capturando: setor2_02_sobrevoo_abismo.png ---")
	hero.reset_to(ForestLayout.ORIGINS[1] + Vector2(664, 246))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_02_sobrevoo_abismo.png")

	# 3. SETOR 3: Passagem dos Fósseis — Arco Alto do Desfiladeiro
	print("\n--- [SETOR 3] Capturando: setor3_arco_desfiladeiro.png ---")
	await stage.switch_room(2, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(510, 200))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_arco_desfiladeiro.png")

	# 4. SETOR 4: Clareira Ancestral — Arco Gótico Superior
	print("\n--- [SETOR 4] Capturando: setor4_arco_gotico.png ---")
	await stage.switch_room(3, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(594, 190))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_arco_gotico.png")

	# 5. SETOR 5: Passagem das Raízes Profundas — Plataforma Suspensa sobre Abismo de Raízes
	print("\n--- [SETOR 5] Capturando: setor5_abismo_raizes.png ---")
	await stage.switch_room(4, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[4] + Vector2(515, 228))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor5_abismo_raizes.png")

	# 6. SETOR 6: Galeria dos Ossos Antigos — Costelas Monumentais
	print("\n--- [SETOR 6] Capturando: setor6_costelas_monumentais.png ---")
	await stage.switch_room(5, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[5] + Vector2(480, 190))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor6_costelas_monumentais.png")

	# 7. SETOR 7: Fenda das Vértebras — Ponte das Vértebras Fósseis
	print("\n--- [SETOR 7] Capturando: setor7_ponte_vertebras.png ---")
	await stage.switch_room(6, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[6] + Vector2(470, 154))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor7_ponte_vertebras.png")

	# 8. SETOR 8: Bosque dos Ecos — Abóbada dos Ecos
	print("\n--- [SETOR 8] Capturando: setor8_abobada_ecos.png ---")
	await stage.switch_room(7, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[7] + Vector2(462, 154))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor8_abobada_ecos.png")

	print("\n==================================================")
	print("TODAS AS CAPTURAS DE ACESSIBILIDADE GERADAS COM SUCESSO!")
	print("==================================================")
	quit(0)
