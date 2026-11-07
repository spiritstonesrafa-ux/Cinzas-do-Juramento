extends SceneTree
## Script oficial de validação visual e captura de evidências para o M6-B1 (Setores 3 e 4).
## Executa na GPU real, capturando os setores preservados (1 e 2) e os novos setores (3 e 4).

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
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6b1")
	print("Iniciando M6-B1 Visual Capture em: ", out_dir)
	
	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)
	
	while stage.busy:
		await physics_frame
	await frames(15)
	
	var hero: KnightController = stage.hero
	hero.dash_unlocked = true
	
	# =============================================================
	# REFERÊNCIAS PRESERVADAS: SETOR 1 E SETOR 2
	# =============================================================
	print("\n--- [SETOR 1 PRESERVADO] Capturando: setor1_preservado.png ---")
	hero.reset_to(Vector2(160, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_preservado.png")
	
	print("\n--- [SETOR 2 PRESERVADO] Capturando: setor2_preservado.png ---")
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[1] + Vector2(810, 246))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_preservado.png")
	
	# =============================================================
	# NOVO SETOR 3: PASSAGEM DOS FÓSSEIS
	# =============================================================
	print("\n--- [SETOR 3] Capturando: setor3_01_entrada.png ---")
	await stage.switch_room(2, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(80, 288))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_01_entrada.png")
	
	print("--- [SETOR 3] Capturando: setor3_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(460, 290))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_02_meio.png")
	
	print("--- [SETOR 3] Capturando: setor3_03_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(860, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_03_saida.png")
	
	print("--- [SETOR 3] Capturando: setor3_04_travessia_movimento.png ---")
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(500, 290))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(6)
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	await frames(6)
	await shot(out_dir + "/setor3_04_travessia_movimento.png")
	Input.action_release("move_right")
	await frames(20)
	
	# =============================================================
	# NOVO SETOR 4: CLAREIRA ANCESTRAL
	# =============================================================
	print("\n--- [SETOR 4] Capturando: setor4_01_entrada.png ---")
	await stage.switch_room(3, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(80, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_01_entrada.png")
	
	print("--- [SETOR 4] Capturando: setor4_02_meio.png ---")
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(450, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_02_meio.png")
	
	print("--- [SETOR 4] Capturando: setor4_03_saida.png ---")
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(840, 260))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_03_saida.png")
	
	print("--- [SETOR 4] Capturando: setor4_04_travessia_movimento.png ---")
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(620, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	Input.action_press("move_right")
	await frames(6)
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	await frames(6)
	await shot(out_dir + "/setor4_04_travessia_movimento.png")
	Input.action_release("move_right")
	await frames(20)
	
	print("\nM6-B1 Visual Capture concluída com sucesso!")
	stage.queue_free()
	await frames(5)
	quit(0)

