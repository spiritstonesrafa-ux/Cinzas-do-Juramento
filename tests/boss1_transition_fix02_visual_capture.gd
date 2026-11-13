extends SceneTree
## Script oficial de captura visual GPU para BOSS1-TRANSITION-FIX02.
## Registra em GPU real as evidências comprovando a ausência de sobreposição de HUD ou nós da Fase 1.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const OathGuardian = preload("res://scripts/boss/guardian.gd")

var out_dir: String = "res://tests/evidencias/boss1_transition_fix02"

func _init() -> void:
	call_deferred("_run_capture")

func _frames(count: int = 3) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _capture(path: String) -> void:
	for _i in range(4):
		await process_frame
		await physics_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if img != null:
		var err: Error = img.save_png(path)
		print("  Evidência gravada: %s (%dx%d) err=%d" % [path.get_file(), img.get_width(), img.get_height(), err])

func _run_capture() -> void:
	print("==================================================================")
	print("INICIANDO CAPTURA VISUAL: BOSS1-TRANSITION-FIX02")
	print("==================================================================")
	DirAccess.make_dir_recursive_absolute(out_dir)

	var main_node = MAIN_SCENE.instantiate()
	root.add_child(main_node)
	current_scene = main_node
	await _frames(4)

	var cemetery = main_node.get_node("ForgottenCemetery")
	var knight = cemetery.get_node("Knight") as KnightController
	var encounter = main_node.get_node("GuardianEncounter")

	encounter.enter()
	await _frames(4)

	var arena = encounter.arena
	var guardian = arena.get_node("Guardian") as OathGuardian
	var conclusion = arena.get_node("Guardian/Conclusion")

	# Derrota do Guardião
	guardian.current_health = 0
	guardian.clear_dangers()
	guardian.awake = false
	guardian.receiver.set_deferred("disabled", true)
	guardian._set_state(OathGuardian.State.DEFEATED)
	guardian.defeated.emit()
	await _frames(4)

	# 1. Últimos momentos da conclusão do Guardião (2.55s de duração)
	conclusion._physics_process(2.55)
	await _frames(4)
	await _capture("%s/01_conclusao_guardiao_ultimos_momentos.png" % out_dir)

	# Conclui cinemática oficialmente
	conclusion._physics_process(0.1)
	await _frames(4)

	# 2. Aren diante da saída liberada
	knight.global_position = arena.global_position + Vector2(290.0, 156.0)
	await _frames(4)
	await _capture("%s/02_aren_saida_liberada.png" % out_dir)

	# 3. Transição física para a Abadia
	knight.global_position = arena.global_position + Vector2(325.0, 156.0)
	for _i in range(8):
		await physics_frame
		await process_frame

	# 3. Momento posterior ao carregamento da Abadia
	await _capture("%s/03_momento_posterior_carregamento_abadia.png" % out_dir)

	# 4. Átrio dos Votos com HUD limpo
	var abbey = current_scene
	if abbey != null and "busy" in abbey:
		while abbey.busy:
			await process_frame
	if abbey != null and "hero" in abbey and is_instance_valid(abbey.hero):
		abbey.hero.global_position = abbey.room.global_position + Vector2(200.0, 160.0)
		abbey.camera.position = abbey.camera_target()
	await _frames(6)
	await _capture("%s/04_atrio_dos_votos_hud_limpo.png" % out_dir)

	# 5. Estado geral e ausência de sobreposição na exploração
	if abbey != null and "hero" in abbey and is_instance_valid(abbey.hero):
		abbey.hero.global_position = abbey.room.global_position + Vector2(400.0, 160.0)
		abbey.camera.position = abbey.camera_target()
	await _frames(6)
	await _capture("%s/05_estado_scenetree_pos_transicao.png" % out_dir)

	abbey.queue_free()
	await _frames(2)

	print("TODAS AS EVIDÊNCIAS DE BOSS1-TRANSITION-FIX02 CAPTURADAS COM SUCESSO!")
	quit(0)
