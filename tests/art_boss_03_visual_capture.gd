extends SceneTree
## Script de captura visual automatizada para ART-BOSS-03 (Corte das Galhadas)
## Gera imagens PNG oficiais de alta fidelidade para auditoria forense e homologação visual

const CervoPreview = preload("res://scripts/dev/cervo_preview.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")

func _init() -> void:
	call_deferred("_run_capture")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_capture() -> void:
	print("Iniciando capturas visuais ART-BOSS-03...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_03")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	preview.is_paused = true
	preview.cervo.is_playing = false

	# 1. ANTLER_PREP — início (quadro 0)
	preview.cervo.facing = 1
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.ANTLER_PREP)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_01_prep_start.png")

	# 2. ANTLER_PREP — meio (quadro 3)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_PREP)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_02_prep_mid.png")

	# 3. ANTLER_PREP — recolhimento máximo (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_PREP)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_03_prep_coiled.png")

	# 4. ANTLER_EXEC — início do golpe (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_04_exec_launch.png")

	# 5. ANTLER_EXEC — arco espectral ascendente (quadro 4)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_05_exec_arc_rising.png")

	# 6. ANTLER_EXEC — clímax do corte (quadro 6)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_06_exec_climax.png")

	# 7. ANTLER_EXEC — extensão máxima / dissipação (quadro 11)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(11)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_07_exec_followthrough.png")

	# 8. ANTLER_RECOVER — início do retorno (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_RECOVER)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_08_recover_start.png")

	# 9. ANTLER_RECOVER — patas dianteiras tocando o chão (quadro 2)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_RECOVER)
	preview.cervo.set_frame(2)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_09_recover_touchdown.png")

	# 10. ANTLER_RECOVER — restabilização (quadro 5)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_RECOVER)
	preview.cervo.set_frame(5)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_10_recover_settling.png")

	# 11. ANTLER_RECOVER — transição de volta ao Idle (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_RECOVER)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_11_recover_idle.png")

	# 12. ANTLER_EXEC — executando virado para a esquerda (facing = -1, quadro 6)
	preview.cervo.facing = -1
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_12_exec_left.png")

	# 13. Comparação de proporções Cervo vs Aren (lado a lado na arena)
	preview.cervo.facing = 1
	preview.show_aren = true
	preview.show_guides = true
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_13_aren_comparison.png")

	# 14. Regressão visual da Investida Devastadora (CHARGE_EXEC quadro 6)
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_03/cervo_antler_14_charge_regression.png")

	print("Capturas visuais ART-BOSS-03 concluídas com sucesso (14/14)!")
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
		print("  Salvo: %s (%dx%d) err=%d" % [path.get_file(), img.get_width(), img.get_height(), err])
