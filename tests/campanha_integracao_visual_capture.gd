extends SceneTree
## Script oficial de validação visual e captura de evidências GPU para CAMPANHA-INTEGRACAO-01.
## Registra em GPU real as 8 evidências mandatórias em tests/evidencias/campanha_integracao_01/.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const FOREST_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const CervoBossArena = preload("res://scripts/boss/cervo_boss_arena.gd")

var out_dir: String = "res://tests/evidencias/campanha_integracao_01"

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
	print("INICIANDO CAPTURA VISUAL: CAMPANHA-INTEGRACAO-01 (8 EVIDÊNCIAS)")
	print("==================================================================")
	DirAccess.make_dir_recursive_absolute(out_dir)

	# -------------------------------------------------------------------------
	# 1. SETOR 3 ORIGINAL RESTAURADO (ABADIA SILENCIOSA)
	# -------------------------------------------------------------------------
	print("\n--- 1. Setor 3 Original Restaurado (Sem portais experimentais) ---")
	var abbey_node = ABBEY_SCENE.instantiate()
	root.add_child(abbey_node)
	while abbey_node.busy:
		await process_frame
	await _frames(4)

	await abbey_node.switch_room(2, false, true) # Setor 3 (id=2)
	while abbey_node.busy:
		await process_frame
	await _frames(6)

	abbey_node.hero.global_position = abbey_node.room.global_position + Vector2(300.0, 160.0)
	abbey_node.camera.position = abbey_node.camera_target()
	await _capture("%s/01_setor3_original_restaurado.png" % out_dir)

	# -------------------------------------------------------------------------
	# 2. SETOR 9 ORIGINAL RESTAURADO (ABADIA SILENCIOSA)
	# -------------------------------------------------------------------------
	print("\n--- 2. Setor 9 Original Restaurado (Sem scriptorium superior) ---")
	await abbey_node.switch_room(8, false, true) # Setor 9 (id=8)
	while abbey_node.busy:
		await process_frame
	await _frames(6)

	abbey_node.hero.global_position = abbey_node.room.global_position + Vector2(400.0, 140.0)
	abbey_node.camera.position = abbey_node.camera_target()
	await _capture("%s/02_setor9_original_restaurado.png" % out_dir)

	abbey_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# 3. CONCLUSÃO DO GUARDIÃO & ABERTURA DA CATEDRAL (FASE 1)
	# -------------------------------------------------------------------------
	print("\n--- 3. Conclusão Guardião & Portão da Catedral (Fase 1) ---")
	var main_node = MAIN_SCENE.instantiate()
	root.add_child(main_node)
	await _frames(6)

	var encounter = main_node.get_node("GuardianEncounter")
	encounter.enter()
	await _frames(4)
	encounter._on_defeated()
	await _frames(4)
	encounter.leave(true)
	await _frames(6)

	var cemetery = main_node.get_node("ForgottenCemetery")
	var hero_p1 = cemetery.get_node("Knight")
	cemetery.camera.position = hero_p1.global_position
	await _capture("%s/03_conclusao_guardiao.png" % out_dir)

	main_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# 4. ENTRADA NA ABADIA SILENCIOSA (COM 6 HP HERDADO)
	# -------------------------------------------------------------------------
	print("\n--- 4. Entrada na Abadia Silenciosa com 6 HP ---")
	abbey_node = ABBEY_SCENE.instantiate()
	root.add_child(abbey_node)
	while abbey_node.busy:
		await process_frame
	await _frames(6)

	abbey_node.camera.position = abbey_node.camera_target()
	await _capture("%s/04_entrada_abadia.png" % out_dir)

	# -------------------------------------------------------------------------
	# 5. CONCLUSÃO DO ABADE DAS CORRENTES & SAÍDA PARA FLORESTA
	# -------------------------------------------------------------------------
	print("\n--- 5. Conclusão do Abade & Saída para Floresta ---")
	await abbey_node.switch_room(11, false, true) # Setor 12
	while abbey_node.busy:
		await process_frame
	await _frames(4)

	abbey_node._enter_abbot_arena()
	while abbey_node.busy:
		await process_frame
	await _frames(4)

	abbey_node._on_abbot_defeated()
	await _frames(6)

	abbey_node.camera.position = abbey_node.camera_target()
	await _capture("%s/05_conclusao_abade.png" % out_dir)

	abbey_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# 6. ENTRADA NA FLORESTA DOS OSSOS (COM 6 HP E DASH)
	# -------------------------------------------------------------------------
	print("\n--- 6. Entrada na Floresta dos Ossos com 6 HP e Dash ---")
	var forest_node = FOREST_SCENE.instantiate()
	root.add_child(forest_node)
	while forest_node.busy:
		await process_frame
	await _frames(6)

	forest_node.camera.position = forest_node.camera_target()
	await _capture("%s/06_entrada_floresta.png" % out_dir)

	# -------------------------------------------------------------------------
	# 7. CONCLUSÃO DO CERVO ESPECTRAL (SALTO ESPECTRAL)
	# -------------------------------------------------------------------------
	print("\n--- 7. Conclusão do Cervo Espectral ---")
	await forest_node.switch_room(9, false, true) # Setor 10
	while forest_node.busy:
		await process_frame
	await _frames(6)

	var sector10 = forest_node.room
	var encounter_cervo = sector10.get_node("ClearingEncounter")
	encounter_cervo.boss.target = forest_node.hero
	encounter_cervo.start_encounter()
	await _frames(4)
	encounter_cervo.boss._physics_process(2.3)

	for i in range(5): encounter_cervo.boss.receive_hit()
	if encounter_cervo.boss.state == CervoBoss.State.PHASE_TRANSITION:
		encounter_cervo.boss._physics_process(1.0)
	for i in range(5): encounter_cervo.boss.receive_hit()
	if encounter_cervo.boss.state == CervoBoss.State.PHASE_TRANSITION:
		encounter_cervo.boss._physics_process(1.0)
	for i in range(4): encounter_cervo.boss.receive_hit()

	encounter_cervo.boss.conclusion._physics_process(3.7)
	await _frames(6)

	forest_node.camera.position = forest_node.camera_target()
	await _capture("%s/07_conclusao_cervo.png" % out_dir)

	# -------------------------------------------------------------------------
	# 8. ENCERRAMENTO DIGNO DA CAMPANHA (PÓRTICO DO JURAMENTO)
	# -------------------------------------------------------------------------
	print("\n--- 8. Encerramento Digno da Campanha ---")
	forest_node.hero.global_position = ForestLayout.ORIGINS[9] + Vector2(880.0, 300.0)
	for i in range(6):
		await physics_frame
		await process_frame

	forest_node.camera.position = forest_node.camera_target()
	await _capture("%s/08_encerramento_campanha.png" % out_dir)

	forest_node.queue_free()
	await _frames(2)

	print("\n==================================================================")
	print("TODAS AS 8 EVIDÊNCIAS FORAM CAPTURADAS COM SUCESSO!")
	print("==================================================================")
	quit(0)
