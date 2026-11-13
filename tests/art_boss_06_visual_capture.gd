extends SceneTree
## Script de captura visual automatizada para ART-BOSS-06 (Ecos da Floresta)
## Gera imagens PNG oficiais em 960x540 para auditoria forense e homologação visual

const CervoPreview = preload("res://scripts/dev/cervo_preview.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const CervoEchoVisual = preload("res://scripts/boss/cervo_echo_visual.gd")

func _init() -> void:
	call_deferred("_run_capture")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_capture() -> void:
	print("Iniciando capturas visuais ART-BOSS-06...")
	DirAccess.make_dir_recursive_absolute("res://tests/evidencias/art_boss_06")

	var scene = load("res://scenes/dev/cervo_preview.tscn")
	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(6)

	preview.is_paused = true
	preview.cervo.is_playing = false
	preview.show_aren = false
	preview.show_guides = false
	if preview.echo_a: preview.echo_a.dismiss()
	if preview.echo_b: preview.echo_b.dismiss()

	# 1. ECHO_PREP — quadro 0 (postura inicial firme, raízes espectrais)
	preview.cervo.facing = 1
	preview.cervo.play(CervoVisual.AnimState.ECHO_PREP)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_01_prep_start.png")

	# 2. ECHO_PREP — quadro 3 (energia acumulando nas galhadas)
	preview.cervo.play(CervoVisual.AnimState.ECHO_PREP)
	preview.cervo.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_02_prep_mid.png")

	# 3. ECHO_PREP — quadro 7 (carga máxima antes do chamado)
	preview.cervo.play(CervoVisual.AnimState.ECHO_PREP)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_03_prep_charged.png")

	# 4. ECHO_CAST — quadro 0 (início do chamado, galhadas erguidas)
	preview.cervo.play(CervoVisual.AnimState.ECHO_CAST)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_04_cast_start.png")

	# 5. ECHO_CAST — quadro 4 (energia crescente e névoa expandindo)
	preview.cervo.play(CervoVisual.AnimState.ECHO_CAST)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_05_cast_radiance.png")

	# 6. ECHO_CAST — quadro 8 (início da formação das silhuetas espectrais)
	preview.cervo.play(CervoVisual.AnimState.ECHO_CAST)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_06_cast_silhouettes.png")

	# 7. ECHO_CAST — quadro 11 (ápice da invocação com ecos coalescendo)
	preview.cervo.play(CervoVisual.AnimState.ECHO_CAST)
	preview.cervo.set_frame(11)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_07_cast_culmination.png")

	# 8. ECHO_MANIFEST — quadro 0 (névoa inicial no solo)
	preview.cervo.play(CervoVisual.AnimState.ECHO_MANIFEST)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_08_manifest_start.png")

	# 9. ECHO_MANIFEST — quadro 4 (formação intermediária do corpo espectral)
	preview.cervo.play(CervoVisual.AnimState.ECHO_MANIFEST)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_09_manifest_mid.png")

	# 10. ECHO_MANIFEST — quadro 7 (eco completamente formado e radiante)
	preview.cervo.play(CervoVisual.AnimState.ECHO_MANIFEST)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_10_manifest_full.png")

	# 11. Echo_A isolado no preview
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.set_frame(0)
	preview.echo_a.spawn_echo(Vector2(110.0, preview.FLOOR_Y), -1, 3.0, 0.0)
	preview.echo_a.is_playing = false
	preview.echo_a.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_11_echo_a_isolated.png")

	# 12. Echo_B isolado no preview
	preview.echo_a.dismiss()
	preview.echo_b.spawn_echo(Vector2(250.0, preview.FLOOR_Y), 1, 3.0, 0.0)
	preview.echo_b.is_playing = false
	preview.echo_b.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_12_echo_b_isolated.png")

	# 13. Ambos os ecos presentes na arena
	preview.echo_a.spawn_echo(Vector2(110.0, preview.FLOOR_Y), -1, 3.0, 0.0)
	preview.echo_a.is_playing = false
	preview.echo_a.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_13_both_echoes.png")

	# 14. Ambos em orientações opostas (espelhamento independente)
	preview.echo_a.facing = 1
	preview.echo_b.facing = -1
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_14_both_opposite_facing.png")

	# 15. Momento de transferência entre CAST e instâncias independentes
	preview.echo_a.facing = -1
	preview.echo_b.facing = 1
	preview.cervo.play(CervoVisual.AnimState.ECHO_RECOVER)
	preview.cervo.set_frame(0)
	preview.echo_a.position = preview.cervo.position + Vector2(-60.0, 0.0)
	preview.echo_b.position = preview.cervo.position + Vector2(+60.0, 0.0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_15_handoff_moment.png")

	# 16. ECHO_RECOVER — quadro 0 (início da recuperação do Cervo verdadeiro)
	preview.echo_a.dismiss()
	preview.echo_b.dismiss()
	preview.cervo.play(CervoVisual.AnimState.ECHO_RECOVER)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_16_recover_start.png")

	# 17. ECHO_RECOVER — quadro 4 (energia arrefecendo)
	preview.cervo.play(CervoVisual.AnimState.ECHO_RECOVER)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_17_recover_mid.png")

	# 18. ECHO_RECOVER — quadro 7 (retorno suave a Idle)
	preview.cervo.play(CervoVisual.AnimState.ECHO_RECOVER)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_18_recover_idle.png")

	# 19. Cervo em repouso enquanto os ecos demonstram atividade
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.set_frame(0)
	preview.echo_a.spawn_active(Vector2(95.0, preview.FLOOR_Y), -1, 3.0, 0.0)
	preview.echo_b.spawn_active(Vector2(265.0, preview.FLOOR_Y), 1, 3.0, 0.0)
	preview.echo_a.is_playing = false
	preview.echo_b.is_playing = false
	preview.echo_a.set_frame(4)
	preview.echo_b.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_19_idle_with_echoes_active.png")

	# 20. Demonstração de travessia/movimento espectral dos ecos
	preview.echo_a.position = Vector2(75.0, preview.FLOOR_Y)
	preview.echo_b.position = Vector2(285.0, preview.FLOOR_Y)
	preview.echo_a.set_frame(8)
	preview.echo_b.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_20_echoes_traversal.png")

	# 21. ECHO_DISSOLVE — quadro 0 (início da dissipação espectral)
	preview.echo_a.dismiss()
	preview.echo_b.dismiss()
	preview.cervo.play(CervoVisual.AnimState.ECHO_DISSOLVE)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_21_dissolve_start.png")

	# 22. ECHO_DISSOLVE — quadro 4 (dissolução intermediária)
	preview.cervo.play(CervoVisual.AnimState.ECHO_DISSOLVE)
	preview.cervo.set_frame(4)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_22_dissolve_mid.png")

	# 23. ECHO_DISSOLVE — quadro 7 (nuvem residual próxima ao solo)
	preview.cervo.play(CervoVisual.AnimState.ECHO_DISSOLVE)
	preview.cervo.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_23_dissolve_residual.png")

	# 24. Dissipação independente (um eco dissipado, outro ainda ativo)
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.set_frame(0)
	preview.echo_a.dismiss()
	preview.echo_b.spawn_echo(Vector2(260.0, preview.FLOOR_Y), 1, 3.0, 0.0)
	preview.echo_b.play(CervoVisual.AnimState.ECHO_DISSOLVE)
	preview.echo_b.set_frame(3)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_24_independent_dissolve.png")

	# 25. Cenário final limpo após dissipação completa de ambos os ecos
	preview.echo_a.dismiss()
	preview.echo_b.dismiss()
	preview.cervo.play(CervoVisual.AnimState.IDLE)
	preview.cervo.set_frame(0)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_25_clean_arena_post_ritual.png")

	# 26. Proporções relativas com Aren (Cervo verdadeiro + ecos + Aren)
	preview.show_aren = true
	preview.show_guides = true
	preview.echo_a.spawn_echo(Vector2(110.0, preview.FLOOR_Y), -1, 3.0, 0.0)
	preview.echo_b.spawn_echo(Vector2(250.0, preview.FLOOR_Y), 1, 3.0, 0.0)
	preview.echo_a.is_playing = false
	preview.echo_b.is_playing = false
	preview.echo_a.set_frame(7)
	preview.echo_b.set_frame(7)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_26_aren_comparison.png")

	# 27. Regressão visual da Investida Devastadora (CHARGE_EXEC quadro 6)
	preview.show_aren = false
	preview.show_guides = false
	preview.echo_a.dismiss()
	preview.echo_b.dismiss()
	preview.cervo.play(CervoVisual.AnimState.CHARGE_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_27_charge_regression.png")

	# 28. Regressão visual do Corte das Galhadas (ANTLER_EXEC quadro 6)
	preview.cervo.play(CervoVisual.AnimState.ANTLER_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_28_antler_regression.png")

	# 29. Regressão visual da Pisada das Almas (STOMP_EXEC quadro 8)
	preview.cervo.play(CervoVisual.AnimState.STOMP_EXEC)
	preview.cervo.set_frame(8)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_29_stomp_regression.png")

	# 30. Regressão visual do Salto Predatório (LEAP_EXEC quadro 6)
	preview.cervo.play(CervoVisual.AnimState.LEAP_EXEC)
	preview.cervo.set_frame(6)
	await _capture(preview, "res://tests/evidencias/art_boss_06/cervo_echo_30_leap_regression.png")

	print("Capturas visuais ART-BOSS-06 concluídas com sucesso (30/30)!")
	quit(0)

func _capture(preview: CervoPreview, path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	preview.queue_redraw()
	preview.cervo.queue_redraw()
	if preview.echo_a: preview.echo_a.queue_redraw()
	if preview.echo_b: preview.echo_b.queue_redraw()
	for _i in range(3):
		await process_frame
		await physics_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if img != null:
		var err: Error = img.save_png(path)
		print("  Salvo: %s (%dx%d) err=%d" % [path.get_file(), img.get_width(), img.get_height(), err])
