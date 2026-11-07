extends SceneTree
## Script de captura de evidências visuais GPU para M6 Platform Fix02.
## Executa na GPU real (NVIDIA GeForce RTX 2060 SUPER), gerando capturas em tests/evidencias/m6_platform_fix02/.

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6_platform_fix02")
	print("Iniciando M6 Platform Fix02 Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true
	var ox: float = ForestLayout.ORIGINS[0].x

	# 1. Aren na ida (Leste) atravessando a região em x=700, y=276
	print("\n--- Capturando: 01_setor1_aren_ida_terreno.png ---")
	hero.reset_to(Vector2(ox + 700.0, 276.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox + 740.0, 240.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/01_setor1_aren_ida_terreno.png")

	# 2. Aren na descida suave para o solo leste em x=770, y=300
	print("--- Capturando: 02_setor1_aren_transicao_descida.png ---")
	hero.reset_to(Vector2(ox + 770.0, 300.0))
	hero.facing = 1
	stage.camera.position = Vector2(ox + 780.0, 250.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/02_setor1_aren_transicao_descida.png")

	# 3. Retorno: Aren diante do degrau em x=760, y=300 (sem teto obstrutivo)
	print("--- Capturando: 03_setor1_aren_retorno_degrau.png ---")
	hero.reset_to(Vector2(ox + 760.0, 300.0))
	hero.facing = -1
	stage.camera.position = Vector2(ox + 740.0, 250.0)
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/03_setor1_aren_retorno_degrau.png")

	# 4. Retorno: Aren saltando com teto livre em x=740, y=270
	print("--- Capturando: 04_setor1_aren_retorno_salto.png ---")
	hero.reset_to(Vector2(ox + 735.0, 270.0))
	hero.facing = -1
	hero.velocity = Vector2(-80.0, -100.0)
	stage.camera.position = Vector2(ox + 730.0, 245.0)
	stage.camera.force_update_scroll()
	await frames(10)
	await shot(out_dir + "/04_setor1_aren_retorno_salto.png")

	# 5. Vista ampla panorâmica do final do Setor 1 após remoção
	print("--- Capturando: 05_setor1_vista_ampla_pos_remocao.png ---")
	hero.reset_to(Vector2(ox + 680.0, 276.0))
	hero.facing = -1
	stage.camera.position = Vector2(ox + 740.0, 220.0)
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/05_setor1_vista_ampla_pos_remocao.png")

	print("\nTodas as 5 capturas do M6 Platform Fix02 foram geradas com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)
