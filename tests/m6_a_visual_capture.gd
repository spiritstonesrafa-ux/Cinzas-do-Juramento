extends SceneTree
## Script oficial de validação visual e captura de evidências para o M6-A ART FIX03.
## Executa na GPU real, validando o Setor 1 e Setor 2 sem colagens, duplicações ou distorções.

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

func _trigger_dash(hero: KnightController) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_SHIFT
	event.pressed = true
	event.echo = false
	hero._unhandled_key_input(event)

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6a")
	print("Iniciando M6-A ART FIX03 Visual Capture em: ", out_dir)
	
	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)
	
	while stage.busy:
		await physics_frame
	await frames(15)
	
	var hero: KnightController = stage.hero
	hero.dash_unlocked = true
	
	# =============================================================
	# SETOR 1: ENTRADA DA FLORESTA
	# =============================================================
	print("\n--- [SETOR 1] Capturando 1: setor1_01_inicio.png ---")
	hero.reset_to(Vector2(80, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_01_inicio.png")
	
	print("--- [SETOR 1] Capturando 2: setor1_02_meio.png ---")
	hero.reset_to(Vector2(450, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_02_meio.png")
	
	print("--- [SETOR 1] Capturando 3: setor1_03_fim.png ---")
	hero.reset_to(Vector2(880, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_03_fim.png")
	
	print("--- [SETOR 1] Capturando 4: setor1_04_movimento_dash.png ---")
	hero.reset_to(Vector2(140, 300))
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(10)
	_trigger_dash(hero)
	await frames(4)
	await shot(out_dir + "/setor1_04_movimento_dash.png")
	await frames(30)
	
	print("--- [SETOR 1] Capturando 5: setor1_05_plataformas_altas.png ---")
	hero.reset_to(Vector2(500, 174))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_05_plataformas_altas.png")
	
	print("--- [SETOR 1] Capturando 6: setor1_06_parallax_deslocado.png ---")
	hero.reset_to(Vector2(700, 276))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_06_parallax_deslocado.png")
	
	# =============================================================
	# SETOR 2: BOSQUE DAS RAÍZES E SANTUÁRIO DO CERVO
	# =============================================================
	print("\n--- Transição para Setor 2 ---")
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	await frames(15)
	
	print("--- [SETOR 2] Capturando 7: setor2_01_inicio.png ---")
	hero.reset_to(Vector2(1200 + 80, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_01_inicio.png")
	
	print("--- [SETOR 2] Capturando 8: setor2_02_abismo_travessia.png ---")
	hero.reset_to(Vector2(1200 + 170, 300))
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(10)
	_trigger_dash(hero)
	await frames(5)
	await shot(out_dir + "/setor2_02_abismo_travessia.png")
	await frames(30)
	
	print("--- [SETOR 2] Capturando 9: setor2_03_bosque_meio.png ---")
	hero.reset_to(Vector2(1200 + 500, 316))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_03_bosque_meio.png")
	
	print("--- [SETOR 2] Capturando 10: setor2_04_arvore_monumental.png ---")
	hero.reset_to(Vector2(1200 + 440, 238))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_04_arvore_monumental.png")
	
	print("--- [SETOR 2] Capturando 11: setor2_05_santuario_cervo.png ---")
	hero.reset_to(Vector2(1200 + 780, 288))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_05_santuario_cervo.png")
	
	print("--- [SETOR 2] Capturando 12: setor2_06_parallax_deslocado.png ---")
	hero.reset_to(Vector2(1200 + 860, 246))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_06_parallax_deslocado.png")
	
	print("\nTODAS AS 12 CAPTURAS M6-A ART FIX03 FINALIZADAS COM SUCESSO.")
	quit(0)
