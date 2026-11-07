extends SceneTree
## Script de validação visual e captura de evidências para o M6-B1 FIX01.
## Executa na GPU real, capturando a acessibilidade corrigida do Santuário do Cervo.

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func shot(filepath: String) -> Image:
	if DisplayServer.get_name() == "headless":
		print("AVISO: Headless, captura ignorada para ", filepath)
		return null
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var dir: String = filepath.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err: Error = img.save_png(filepath)
	print("CAPTURA GERADA: ", filepath, " tamanho=", img.get_size(), " erro=", err)
	return img

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6b1_fix01")
	print("Iniciando M6-B1 FIX01 Visual Capture em: ", out_dir)
	
	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)
	
	while stage.busy:
		await physics_frame
	await frames(15)
	
	var hero: KnightController = stage.hero
	hero.dash_unlocked = true
	
	# Mudar para o Setor 2 (Bosque das Raízes)
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	
	var s2_origin: Vector2 = ForestLayout.ORIGINS[1]
	
	# =============================================================
	# 1. santuario_depois.png (Visão geral do Santuário com novos degraus)
	# =============================================================
	print("\n--- 1. santuario_depois.png ---")
	hero.reset_to(s2_origin + Vector2(720, 288))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(20)
	var img_depois: Image = await shot(out_dir + "/santuario_depois.png")
	
	# =============================================================
	# 2. aren_apoio_intermediario.png (Aren no degrau intermediário oeste: x=780, y=268)
	# =============================================================
	print("\n--- 2. aren_apoio_intermediario.png ---")
	hero.reset_to(s2_origin + Vector2(780, 268))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/aren_apoio_intermediario.png")
	
	# =============================================================
	# 3. aren_patamar_superior.png (Aren no patamar superior do Santuário: x=840, y=246)
	# =============================================================
	print("\n--- 3. aren_patamar_superior.png ---")
	hero.reset_to(s2_origin + Vector2(840, 246))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/aren_patamar_superior.png")
	
	# =============================================================
	# 4. aren_descida_segura.png (Aren no degrau leste de descida: x=905, y=268)
	# =============================================================
	print("\n--- 4. aren_descida_segura.png ---")
	hero.reset_to(s2_origin + Vector2(905, 268))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/aren_descida_segura.png")
	
	# =============================================================
	# 5. cenario_completo_pos_fix.png (Visão ampla do complexo do Santuário)
	# =============================================================
	print("\n--- 5. cenario_completo_pos_fix.png ---")
	hero.reset_to(s2_origin + Vector2(810, 246))
	hero.facing = -1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(20)
	await shot(out_dir + "/cenario_completo_pos_fix.png")
	
	# =============================================================
	# 6. comparacao_antes_depois_fix01.png (Painel Comparativo)
	# =============================================================
	print("\n--- 6. comparacao_antes_depois_fix01.png ---")
	var antes_path: String = out_dir + "/santuario_antes.png"
	if FileAccess.file_exists(antes_path) and img_depois != null:
		var img_antes: Image = Image.load_from_file(antes_path)
		if img_antes != null:
			var w: int = img_antes.get_width()
			var h: int = img_antes.get_height()
			var comp: Image = Image.create(w * 2, h, false, Image.FORMAT_RGBA8)
			comp.blit_rect(img_antes, Rect2i(0, 0, w, h), Vector2i(0, 0))
			comp.blit_rect(img_depois, Rect2i(0, 0, w, h), Vector2i(w, 0))
			comp.save_png(out_dir + "/comparacao_antes_depois_fix01.png")
			print("COMPARAÇÃO GERADA: ", out_dir + "/comparacao_antes_depois_fix01.png")
	
	print("\n==================================================")
	print("M6-B1 FIX01 VISUAL CAPTURE CONCLUÍDO COM SUCESSO!")
	print("==================================================")
	quit()

