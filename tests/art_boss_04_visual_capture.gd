extends SceneTree
## Script de captura visual automatizada para ART-BOSS-04 (Pisada das Almas)
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
	print("Iniciando capturas visuais ART-BOSS-04...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_04")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	preview.is_paused = true
	preview.cervo.is_playing = false

	# 1. STOMP_PREP — início (quadro 0) - postura inicial 4 patas
	preview.cervo.facing = 1
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.STOMP_PREP)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_01_prep_start.png")

	# 2. STOMP_PREP — meio (quadro 3) - tronco erguendo-se
	preview.cervo.play(CervoVisual.AnimState.STOMP_PREP)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_02_prep_mid.png")

	# 3. STOMP_PREP — recolhimento máximo empinado (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.STOMP_PREP)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_03_prep_reared.png")

	# 4. STOMP_EXEC — início da descida (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_04_exec_launch.png")

	# 5. STOMP_EXEC — descida em velocidade (quadro 3)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_05_exec_descending.png")

	# 6. STOMP_EXEC — primeiro contato no solo (quadro 5)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(5)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_06_exec_contact.png")

	# 7. STOMP_EXEC — surgimento dos raios espectrais (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_07_exec_shockwave_burst.png")

	# 8. STOMP_EXEC — ápice da onda de choque radial (quadro 8)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_08_exec_shockwave_peak.png")

	# 9. STOMP_EXEC — onda em expansão máxima (quadro 10)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(10)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_09_exec_shockwave_expansion.png")

	# 10. STOMP_EXEC — finalização da pancada (quadro 11)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(11)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_10_exec_followthrough.png")

	# 11. STOMP_RECOVER — início do amortecimento com anel residual (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.STOMP_RECOVER)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_11_recover_start.png")

	# 12. STOMP_RECOVER — dissipação progressiva da onda em névoa (quadro 3)
	preview.cervo.play(CervoVisual.AnimState.STOMP_RECOVER)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_12_recover_dissipating.png")

	# 13. STOMP_RECOVER — patas firmes e amortecimento do impacto (quadro 5)
	preview.cervo.play(CervoVisual.AnimState.STOMP_RECOVER)
	preview.cervo.set_frame(5)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_13_recover_settling.png")

	# 14. STOMP_RECOVER — retorno harmônico à postura Idle (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.STOMP_RECOVER)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_14_recover_idle.png")

	# 15. STOMP_EXEC — executando virado para a esquerda (facing = -1, quadro 8)
	preview.cervo.facing = -1
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_15_exec_left.png")

	# 16. Comparação de proporções Cervo vs Aren (lado a lado na arena)
	preview.cervo.facing = 1
	preview.show_aren = true
	preview.show_guides = true
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_16_aren_comparison.png")

	# 17. Regressão visual da Investida Devastadora (CHARGE_EXEC quadro 6)
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_17_charge_regression.png")

	# 18. Regressão visual do Corte das Galhadas (ANTLER_EXEC quadro 6)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_04/cervo_stomp_18_antler_regression.png")

	print("Capturas visuais ART-BOSS-04 concluídas com sucesso (18/18)!")
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
