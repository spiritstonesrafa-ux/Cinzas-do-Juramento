extends SceneTree
## Script de captura visual automatizada para ART-BOSS-01 (Cervo Espectral)
## Gera imagens PNG para auditoria e evidências documentais

const CervoPreview = preload("res://scripts/dev/cervo_preview.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")

func _init() -> void:
	call_deferred("_run_capture")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_capture() -> void:
	print("Iniciando capturas visuais ART-BOSS-01...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_01")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	# 1. Idle + Aren comparison
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.is_playing = false
	preview.cervo.set_frame(0)
	preview.is_paused = true
	await _capture(preview, "res://tests/evidencias/art_boss_01/cervo_01_idle_aren.png")

	# 2. Walk frame 2
	preview.cervo.play(CervoVisual.AnimState.WALK)
	preview.cervo.is_playing = false
	preview.cervo.set_frame(2)
	await _capture(preview, "res://tests/evidencias/art_boss_01/cervo_02_walk.png")

	# 3. Gallop leap frame 6
	preview.cervo.play(CervoVisual.AnimState.GALLOP)
	preview.cervo.is_playing = false
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_01/cervo_03_gallop.png")

	# 4. Turn front-facing frame 4
	preview.cervo.play(CervoVisual.AnimState.TURN)
	preview.cervo.is_playing = false
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_01/cervo_04_turn_front.png")

	# 5. Flipped left idle
	preview.cervo.facing = -1
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.is_playing = false
	preview.cervo.set_frame(1)
	await _capture(preview, "res://tests/evidencias/art_boss_01/cervo_05_idle_left.png")

	print("Capturas visuais concluídas com sucesso!")
	quit(0)

func _capture(preview: CervoPreview, path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	preview.queue_redraw()
	preview.cervo.queue_redraw()
	for _i in range(3):
		await process_frame
		await physics_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if img != null:
		var err: Error = img.save_png(path)
		print("  Salvo: %s (%dx%d) err=%d" % [path, img.get_width(), img.get_height(), err])
