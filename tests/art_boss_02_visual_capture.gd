extends SceneTree
## Script de captura visual automatizada para ART-BOSS-02 (Investida do Cervo Espectral)
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
	print("Iniciando capturas visuais ART-BOSS-02...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_02")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	preview.is_paused = true
	preview.cervo.is_playing = false

	# 1. Repouso oficial antes do ataque
	preview.cervo.facing = 1
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_01_idle_pre.png")

	# 2. Início da preparação com início da inclinação (Prep F1)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_PREP)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_02_prep_start.png")

	# 3. Meio da preparação com galhadas baixas e névoa (Prep F4)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_PREP)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_03_prep_mid.png")

	# 4. Compressão máxima pronta para o avanço (Prep F8)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_PREP)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_04_prep_coiled.png")

	# 5. Primeiro quadro da execução em arrancada (Exec F1)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_05_exec_launch.png")

	# 6. Meio da execução em velocidade máxima (Exec F5)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_06_exec_run.png")

	# 7. Salto / impulsão da investida em suspensão (Exec F8)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_07_exec_leap.png")

	# 8. Frenagem inicial da recuperação (Recover F1)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_RECOVER)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_08_recover_brake.png")

	# 9. Levantamento gradual da cabeça (Recover F4)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_RECOVER)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_09_recover_rising.png")

	# 10. Retorno à postura de repouso oficial (Recover F8)
	preview.cervo.play(CervoVisual.AnimState.CHARGE_RECOVER)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_10_recover_idle.png")

	# 11. Sequência completa voltada para a esquerda (Exec F8 com facing -1)
	preview.cervo.facing = -1
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_11_exec_leap_left.png")

	# 12. Comparação lado a lado com Aren e guias de altura
	preview.cervo.facing = 1
	preview.show_aren = true
	preview.show_guides = true
	preview.cervo.play(CervoVisual.AnimState.CHARGE_PREP)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_02/cervo_charge_12_aren_comparison.png")

	print("Capturas visuais ART-BOSS-02 concluídas com sucesso (12/12)!")
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
