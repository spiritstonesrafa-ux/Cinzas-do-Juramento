extends SceneTree
## Script de validação visual intermediária exclusiva para o SETOR 1 (M6-A ART FIX03).

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
	print("CAPTURA S1 GERADA: ", filepath, " tamanho=", img.get_size(), " erro=", err)

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6a_fix03")
	print("Iniciando auditoria visual do SETOR 1 em: ", out_dir)
	
	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)
	
	while stage.busy:
		await physics_frame
	await frames(15)
	
	var hero: KnightController = stage.hero
	hero.dash_unlocked = true
	
	# 1. Início do Setor 1 (x = 80)
	print("--- 1. Setor 1 Início ---")
	hero.reset_to(Vector2(80, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/s1_01_inicio.png")
	
	# 2. Meio do Setor 1 (x = 420)
	print("--- 2. Setor 1 Meio ---")
	hero.reset_to(Vector2(420, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/s1_02_meio.png")
	
	# 3. Plataformas Elevadas do Setor 1 (Aren no galho alto x = 500, y = 174)
	print("--- 3. Setor 1 Plataformas Elevadas ---")
	hero.reset_to(Vector2(500, 174))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/s1_03_galhos_altos.png")
	
	# 4. Final do Setor 1 (x = 860)
	print("--- 4. Setor 1 Fim ---")
	hero.reset_to(Vector2(860, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/s1_04_fim.png")
	
	print("Auditoria do Setor 1 finalizada com sucesso.")
	quit(0)

