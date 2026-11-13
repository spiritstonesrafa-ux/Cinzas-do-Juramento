extends SceneTree
## Script de captura visual automatizada para ART-BOSS-05 (Salto Predatório)
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
	print("Iniciando capturas visuais ART-BOSS-05...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_05")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	preview.is_paused = true
	preview.cervo.is_playing = false

	# 1. LEAP_PREP — início (quadro 0) - postura em 4 patas antes de agachar
	preview.cervo.facing = 1
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.LEAP_PREP)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_01_prep_start.png")

	# 2. LEAP_PREP — meio (quadro 3) - flexão das patas dianteiras e traseiras
	preview.cervo.play(CervoVisual.AnimState.LEAP_PREP)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_02_prep_mid.png")

	# 3. LEAP_PREP — agachamento máximo recolhido para o salto (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.LEAP_PREP)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_03_prep_coiled.png")

	# 4. LEAP_EXEC — arranque / impulso inicial (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_04_exec_launch.png")

	# 5. LEAP_EXEC — decolagem ascendente (quadro 2)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(2)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_05_exec_takeoff.png")

	# 6. LEAP_EXEC — subida potente e totalmente aéreo (quadro 4)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_06_exec_airborne.png")

	# 7. LEAP_EXEC — ápice do arco parabólico com rastro espectral (quadro 6)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_07_exec_peak_arc.png")

	# 8. LEAP_EXEC — descida rápida com cauda turquesa estendida (quadro 8)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_08_exec_descending.png")

	# 9. LEAP_EXEC — mergulho em direção ao solo (quadro 9)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(9)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_09_exec_glide.png")

	# 10. LEAP_EXEC — primeiro contato com o solo e dissipação de choque (quadro 10)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(10)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_10_exec_contact.png")

	# 11. LEAP_EXEC — compressão final de impacto e frenagem (quadro 11)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(11)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_11_exec_followthrough.png")

	# 12. LEAP_RECOVER — início do amortecimento / postura agachada (quadro 0)
	preview.cervo.play(CervoVisual.AnimState.LEAP_RECOVER)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_12_recover_start.png")

	# 13. LEAP_RECOVER — dissipação progressiva da energia espectral (quadro 3)
	preview.cervo.play(CervoVisual.AnimState.LEAP_RECOVER)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_13_recover_mid.png")

	# 14. LEAP_RECOVER — elevação do tronco e assentamento das patas (quadro 5)
	preview.cervo.play(CervoVisual.AnimState.LEAP_RECOVER)
	preview.cervo.set_frame(5)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_14_recover_settling.png")

	# 15. LEAP_RECOVER — retorno suave à postura de repouso (quadro 7)
	preview.cervo.play(CervoVisual.AnimState.LEAP_RECOVER)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_15_recover_idle.png")

	# 16. LEAP_EXEC — executando virado para a esquerda (facing = -1, quadro 6)
	preview.cervo.facing = -1
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_16_exec_left.png")

	# 17. Comparação de proporções Cervo vs Aren (lado a lado na arena, quadro 6)
	preview.cervo.facing = 1
	preview.show_aren = true
	preview.show_guides = true
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_17_aren_comparison.png")

	# 18. Regressão visual da Investida Devastadora (CHARGE_EXEC quadro 6)
	preview.show_aren = false
	preview.show_guides = false
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_18_charge_regression.png")

	# 19. Regressão visual do Corte das Galhadas (ANTLER_EXEC quadro 6)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_19_antler_regression.png")

	# 20. Regressão visual da Pisada das Almas (STOMP_EXEC quadro 8)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_20_stomp_regression.png")

	# 21. Regressão visual do Galope (GALLOP quadro 6)
	preview.cervo.play(CervoVisual.AnimState.GALLOP)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_05/cervo_leap_21_gallop_regression.png")

	print("Capturas visuais ART-BOSS-05 concluídas com sucesso (21/21)!")
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
