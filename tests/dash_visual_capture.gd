extends SceneTree

const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	var isolated: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolated.is_empty() or not actual.begins_with(isolated + "/") or actual.to_lower() == personal.to_lower():
		printerr("Captura recusada: perfil isolado não confirmado.")
		quit(2)
		return
	run.call_deferred()

func frames(n: int) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func shot(filepath: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("HEADLESS: skipped capture for ", filepath)
		return
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var dir: String = filepath.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err: Error = img.save_png(filepath)
	print("CAPTURE ", filepath, " size=", img.get_size(), " err=", err)

func _trigger_dash(hero: KnightController) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = KEY_SHIFT
	event.pressed = true
	event.echo = false
	hero._unhandled_key_input(event)

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/dash_vfx")
	print("DASH VISUAL CAPTURE starting, output directory: ", out_dir)

	# -------------------------------------------------------------
	# STAGE 1: Standard Forgotten Cemetery on wide solid GateFloor (x: 0..448, y: 156)
	# -------------------------------------------------------------
	var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
	root.add_child(stage)
	var hero: KnightController = stage.get_node("Knight")
	hero.dash_unlocked = true

	# 1. Dash Início Direita (Frame 2: Sigilo gótico na origem, faíscas radiais no chão, detritos para trás)
	hero.reset_to(Vector2(100, 156))
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(2)
	print("CAPTURE 1 (Início Direita): dash_rem=", hero.dash_remaining, " start_timer=", hero.visual._dash_start_timer)
	await shot(out_dir + "/dash_inicio_direita.png")
	await frames(35)

	# 2. Dash Meio Direita (Frame 6: Aren em deslocamento, afterimages residuais, rastro de raspagem no chão, sigilo persistente)
	hero.reset_to(Vector2(100, 156))
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(6)
	print("CAPTURE 2 (Meio Direita): dash_rem=", hero.dash_remaining, " ghosts=", hero.visual._dash_ghosts.size(), " wisps=", hero.visual._dash_wisps.size())
	await shot(out_dir + "/dash_meio_direita.png")
	await frames(35)

	# 3. Dash Fim Direita (Frame 11: Término do deslocamento, frenagem no piso, faíscas frontais, detritos projetados à frente)
	hero.reset_to(Vector2(100, 156))
	hero.facing = 1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(11)
	print("CAPTURE 3 (Fim Direita): dash_rem=", hero.dash_remaining, " end_timer=", hero.visual._dash_end_timer, " debris=", hero.visual._dash_debris.size())
	await shot(out_dir + "/dash_fim_direita.png")
	await frames(35)

	# 4. Dash Início Esquerda (Espelhado)
	hero.reset_to(Vector2(320, 156))
	hero.facing = -1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(2)
	print("CAPTURE 4 (Início Esquerda): dash_rem=", hero.dash_remaining, " start_timer=", hero.visual._dash_start_timer)
	await shot(out_dir + "/dash_inicio_esquerda.png")
	await frames(35)

	# 5. Dash Meio Esquerda (Espelhado)
	hero.reset_to(Vector2(320, 156))
	hero.facing = -1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(6)
	print("CAPTURE 5 (Meio Esquerda): dash_rem=", hero.dash_remaining, " ghosts=", hero.visual._dash_ghosts.size())
	await shot(out_dir + "/dash_meio_esquerda.png")
	await frames(35)

	# 6. Dash Fim Esquerda (Espelhado)
	hero.reset_to(Vector2(320, 156))
	hero.facing = -1
	hero.dash_cooldown_remaining = 0.0
	await frames(10)
	_trigger_dash(hero)
	await frames(11)
	print("CAPTURE 6 (Fim Esquerda): dash_rem=", hero.dash_remaining, " end_timer=", hero.visual._dash_end_timer)
	await shot(out_dir + "/dash_fim_esquerda.png")
	await frames(35)

	stage.queue_free()
	await frames(10)

	# -------------------------------------------------------------
	# STAGE 2: Abbey Chapter Scene (Integração com o cenário da Abadia)
	# -------------------------------------------------------------
	ABBEY_PROGRESS.grant()
	var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
	root.add_child(chapter)
	while chapter.busy or chapter.current_room < 0:
		await frames(1)
	var abbey_hero: KnightController = chapter.hero
	abbey_hero.dash_unlocked = true
	abbey_hero.dash_cooldown_remaining = 0.0
	await frames(20)

	var entry_pos: Vector2 = AbbeyChapterLayout.entry(0)
	abbey_hero.reset_to(entry_pos)
	abbey_hero.facing = 1
	abbey_hero.dash_cooldown_remaining = 0.0
	await frames(10)

	_trigger_dash(abbey_hero)
	await frames(6)
	print("CAPTURE 7 (Abadia Meio): dash_rem=", abbey_hero.dash_remaining, " ghosts=", abbey_hero.visual._dash_ghosts.size())
	await shot(out_dir + "/dash_abadia_cenario.png")

	chapter.queue_free()
	await frames(5)

	print("DASH VISUAL CAPTURE COMPLETED SUCCESSFULLY!")
	quit(0)
