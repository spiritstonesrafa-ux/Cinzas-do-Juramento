extends SceneTree
## Suíte de Testes Automatizados para ART-BOSS-04: Integração Visual da Pisada das Almas
## Validação das 3 Spritesheets da Pisada, Encadeamento Contínuo e Cena de Pré-Visualização

const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const CervoPreview = preload("res://scripts/dev/cervo_preview.gd")

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	call_deferred("_run_all_tests")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_all_tests() -> void:
	print("\n==================================================")
	print("SUÍTE DE TESTES ART-BOSS-04: PISADA DAS ALMAS")
	print("==================================================")

	_test_01_stomp_raw_images_preserved()
	_test_02_stomp_spritesheets_dimensions_and_metadata()
	_test_03_anim_state_and_config_integrity()
	await _test_04_individual_stomp_state_transitions()
	await _test_05_automated_stomp_sequence_chaining()
	await _test_06_bidirectional_facing_stomp_sequence()
	await _test_07_repeated_trigger_and_attack_concurrency_safety()
	await _test_08_preview_scene_key_7_integration()
	await _test_09_regression_previous_10_animations()
	await _test_10_no_combat_or_hitboxes_in_sector10()

	print("\n==================================================")
	print("RESULTADO ART-BOSS-04: %d PASSOU, %d FALHOU" % [_passed, _failed])
	print("==================================================")

	if _failed > 0:
		quit(1)
	else:
		quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("  [PASS] %s" % message)
		_passed += 1
	else:
		printerr("  [FAIL] %s" % message)
		_failed += 1

func _test_01_stomp_raw_images_preserved() -> void:
	print("\n--- 1. Existência e Preservação dos Arquivos Originais da Pisada das Almas ---")
	var stomp_raw_files = [
		"res://assets/art/cervo/original/cervo_stomp_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_stomp_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_stomp_recover_original.jpg"
	]
	for path in stomp_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original da pisada preservado: %s" % path.get_file())

	# Preservação dos 3 originais do Corte das Galhadas (ART-BOSS-03)
	var antler_raw_files = [
		"res://assets/art/cervo/original/cervo_antler_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_antler_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_antler_recover_original.jpg"
	]
	for path in antler_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original do corte ART-BOSS-03 intacto: %s" % path.get_file())

	# Preservação dos 3 originais da Investida (ART-BOSS-02)
	var charge_raw_files = [
		"res://assets/art/cervo/original/cervo_charge_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_charge_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_charge_recover_original.jpg"
	]
	for path in charge_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original da investida ART-BOSS-02 intacto: %s" % path.get_file())

	# Preservação dos 4 originais básicos do ART-BOSS-01
	var base_raw_files = [
		"res://assets/art/cervo/original/cervo_idle_new_original.jpg",
		"res://assets/art/cervo/original/cervo_walk_original.png",
		"res://assets/art/cervo/original/cervo_gallop_original.jpg",
		"res://assets/art/cervo/original/cervo_turn_original.png"
	]
	for path in base_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original básico ART-BOSS-01 intacto: %s" % path.get_file())

func _test_02_stomp_spritesheets_dimensions_and_metadata() -> void:
	print("\n--- 2. Carregamento e Dimensões das 3 Spritesheets da Pisada das Almas ---")
	var tex_prep: Texture2D = load("res://assets/art/cervo/cervo_stomp_prep.png")
	var tex_exec: Texture2D = load("res://assets/art/cervo/cervo_stomp_exec.png")
	var tex_rec: Texture2D = load("res://assets/art/cervo/cervo_stomp_recover.png")

	_assert(tex_prep != null and tex_prep.get_width() == 1024 and tex_prep.get_height() == 512,
		"Spritesheet Preparação (Stomp Prep): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_exec != null and tex_exec.get_width() == 1024 and tex_exec.get_height() == 768,
		"Spritesheet Execução (Stomp Exec): 1024x768 px (4x3 células de 256x256)")
	_assert(tex_rec != null and tex_rec.get_width() == 1024 and tex_rec.get_height() == 512,
		"Spritesheet Recuperação (Stomp Recover): 1024x512 px (4x2 células de 256x256)")

	# Existência dos metadados .import
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_stomp_prep.png.import"),
		"Metadado .import de cervo_stomp_prep.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_stomp_exec.png.import"),
		"Metadado .import de cervo_stomp_exec.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_stomp_recover.png.import"),
		"Metadado .import de cervo_stomp_recover.png presente")

func _test_03_anim_state_and_config_integrity() -> void:
	print("\n--- 3. Estados AnimState e Configurações de Grade da Pisada ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	_assert(CervoVisual.AnimState.STOMP_PREP != null, "AnimState.STOMP_PREP definido")
	_assert(CervoVisual.AnimState.STOMP_EXEC != null, "AnimState.STOMP_EXEC definido")
	_assert(CervoVisual.AnimState.STOMP_RECOVER != null, "AnimState.STOMP_RECOVER definido")

	# Validação de quadros, cadência e looping
	var cfg_prep: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.STOMP_PREP]
	_assert(cfg_prep["total_frames"] == 8, "STOMP_PREP: total de 8 quadros")
	_assert(cfg_prep["columns"] == 4 and cfg_prep["rows"] == 2, "STOMP_PREP: grade 4x2")
	_assert(cfg_prep["loop"] == false, "STOMP_PREP: loop desativado (one-shot encadeado)")
	_assert(cfg_prep["fps"] == 8.0, "STOMP_PREP: cadência de 8.0 FPS (~1.0s)")

	var cfg_exec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.STOMP_EXEC]
	_assert(cfg_exec["total_frames"] == 12, "STOMP_EXEC: total de 12 quadros")
	_assert(cfg_exec["columns"] == 4 and cfg_exec["rows"] == 3, "STOMP_EXEC: grade 4x3")
	_assert(cfg_exec["loop"] == false, "STOMP_EXEC: loop desativado (one-shot encadeado)")
	_assert(cfg_exec["fps"] == 12.0, "STOMP_EXEC: cadência de 12.0 FPS (~1.0s)")

	var cfg_rec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.STOMP_RECOVER]
	_assert(cfg_rec["total_frames"] == 8, "STOMP_RECOVER: total de 8 quadros")
	_assert(cfg_rec["columns"] == 4 and cfg_rec["rows"] == 2, "STOMP_RECOVER: grade 4x2")
	_assert(cfg_rec["loop"] == false, "STOMP_RECOVER: loop desativado (one-shot encadeado)")
	_assert(cfg_rec["fps"] == 8.0, "STOMP_RECOVER: cadência de 8.0 FPS (~1.0s)")

	visual.queue_free()

func _test_04_individual_stomp_state_transitions() -> void:
	print("\n--- 4. Transições Individuais e Nomes das Animações da Pisada ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.play_by_name("stomp_prep")
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_PREP, "play_by_name('stomp_prep') ativa STOMP_PREP")
	_assert(visual.get_current_anim_name() == "stomp_prep", "Nome canônico é 'stomp_prep'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.play_by_name("stomp_exec")
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_EXEC, "play_by_name('stomp_exec') ativa STOMP_EXEC")
	_assert(visual.get_current_anim_name() == "stomp_exec", "Nome canônico é 'stomp_exec'")
	_assert(visual.get_total_frames() == 12, "Total de quadros reportado é 12")

	visual.play_by_name("stomp_recover")
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_RECOVER, "play_by_name('stomp_recover') ativa STOMP_RECOVER")
	_assert(visual.get_current_anim_name() == "stomp_recover", "Nome canônico é 'stomp_recover'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.queue_free()

func _test_05_automated_stomp_sequence_chaining() -> void:
	print("\n--- 5. Encadeamento Automático Completo: IDLE -> PREP -> EXEC -> RECOVER -> IDLE ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	var stage_events: Array[String] = []
	var completed_events: Array[bool] = []

	visual.stomp_stage_changed.connect(func(stage: String): stage_events.append(stage))
	visual.stomp_sequence_completed.connect(func(): completed_events.append(true))

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Inicia em IDLE")

	# Dispara a sequência completa
	visual.start_stomp_sequence()
	_assert(visual.is_stomp_sequence_active(), "Sequência da pisada das almas está ativa")
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_PREP, "Etapa 1: STOMP_PREP ativa")

	# Avança os 8 quadros da etapa de preparação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da preparação (7)")

	# Transição automática: PREP -> EXEC
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_EXEC, "Etapa 2: transição automática para STOMP_EXEC")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de STOMP_EXEC")

	# Avança os 12 quadros da etapa de execução
	for _i in range(11):
		visual._advance_frame()
	_assert(visual.current_frame == 11, "Atingiu último quadro da execução (11)")

	# Transição automática: EXEC -> RECOVER
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_RECOVER, "Etapa 3: transição automática para STOMP_RECOVER")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de STOMP_RECOVER")

	# Avança os 8 quadros da etapa de recuperação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da recuperação (7)")

	# Transição automática: RECOVER -> IDLE
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Etapa 4: transição automática de volta para IDLE")
	_assert(completed_events.size() == 1, "Sinal stomp_sequence_completed emitido com sucesso")
	_assert(not visual.is_stomp_sequence_active(), "is_stomp_sequence_active() agora é false")
	_assert(stage_events == ["stomp_prep", "stomp_exec", "stomp_recover", "idle"],
		"Todos os estágios da pisada foram notificados ordenadamente: %s" % str(stage_events))

	visual.queue_free()

func _test_06_bidirectional_facing_stomp_sequence() -> void:
	print("\n--- 6. Suporte Bidirecional da Pisada (Direita + Esquerda) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# 1. Execução voltada para a direita (+1)
	visual.facing = 1
	visual.start_stomp_sequence()
	_assert(visual.facing == 1, "Orientação inicial mantida à DIREITA (+1)")
	for _i in range(28):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à DIREITA")
	_assert(visual.facing == 1, "Facing permaneceu exatamente 1 ao fim da sequência à direita")

	# 2. Execução voltada para a esquerda (-1)
	visual.facing = -1
	visual.start_stomp_sequence()
	_assert(visual.facing == -1, "Orientação inicial mantida à ESQUERDA (-1)")
	for _i in range(28):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à ESQUERDA")
	_assert(visual.facing == -1, "Facing permaneceu exatamente -1 ao fim da sequência à esquerda")

	visual.queue_free()

func _test_07_repeated_trigger_and_attack_concurrency_safety() -> void:
	print("\n--- 7. Robustez contra Acionamentos Repetidos e Concorrência entre os Três Ataques ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# Inicia pisada
	visual.start_stomp_sequence()
	_assert(visual.is_stomp_sequence_active(), "Iniciou pisada das almas")
	visual._advance_frame()
	visual._advance_frame()
	visual._advance_frame() # Frame 3
	_assert(visual.current_frame == 3, "No quadro 3 da preparação da pisada")

	# Tentativa de reiniciar a pisada em andamento deve ser ignorada
	visual.start_stomp_sequence()
	_assert(visual.current_frame == 3, "Quadro 3 preservado (não reiniciou indevidamente)")
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_PREP, "Estado STOMP_PREP preservado")

	# Tentativa de disparar investida ou corte durante a pisada ativa deve ser ignorada
	visual.start_charge_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_PREP, "Investida não interrompeu a pisada ativa")
	_assert(not visual.is_charge_sequence_active(), "Sequência de investida permaneceu inativa")

	visual.start_antler_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.STOMP_PREP, "Corte de galhadas não interrompeu a pisada ativa")
	_assert(not visual.is_antler_sequence_active(), "Sequência de corte permaneceu inativa")

	# Conclui a pisada
	for _i in range(25):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Pisada concluída de volta em IDLE")

	# Teste inverso: Pisada não pode interromper Investida
	visual.start_charge_sequence()
	_assert(visual.is_charge_sequence_active(), "Iniciou investida")
	visual._advance_frame()
	visual.start_stomp_sequence()
	_assert(visual.is_charge_sequence_active(), "Pisada não interrompeu a investida ativa")
	_assert(not visual.is_stomp_sequence_active(), "Sequência da pisada permaneceu inativa")
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Investida concluída de volta em IDLE")

	# Teste inverso: Pisada não pode interromper Corte
	visual.start_antler_sequence()
	_assert(visual.is_antler_sequence_active(), "Iniciou corte das galhadas")
	visual._advance_frame()
	visual.start_stomp_sequence()
	_assert(visual.is_antler_sequence_active(), "Pisada não interrompeu o corte ativo")
	_assert(not visual.is_stomp_sequence_active(), "Sequência da pisada permaneceu inativa")
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Corte concluído de volta em IDLE")

	visual.queue_free()

func _test_08_preview_scene_key_7_integration() -> void:
	print("\n--- 8. Integração da Tecla 7 na Cena CervoPreview ---")
	var scene = load("res://scenes/dev/cervo_preview.tscn")
	_assert(scene != null, "Cena cervo_preview.tscn carregada com sucesso")

	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(4)
	_assert(preview != null and preview.cervo != null, "Instância de CervoPreview criada com CervoVisual")

	# Simula pressionamento da tecla 7
	var event = InputEventKey.new()
	event.keycode = KEY_7
	event.pressed = true
	preview._unhandled_input(event)
	_assert(preview.cervo.current_state == CervoVisual.AnimState.STOMP_PREP, "Tecla 7 disparou STOMP_PREP no CervoVisual")
	_assert(preview.cervo.is_stomp_sequence_active(), "Sequência da pisada ativa no preview")

	# Conclui sequência no preview
	for _i in range(28):
		preview.cervo._advance_frame()
	_assert(preview.cervo.current_state == CervoVisual.AnimState.IDLE, "Retornou a IDLE no preview")

	# Valida preservação das teclas 5 e 6
	var ev_5 = InputEventKey.new()
	ev_5.keycode = KEY_5
	ev_5.pressed = true
	preview._unhandled_input(ev_5)
	_assert(preview.cervo.is_charge_sequence_active(), "Tecla 5 continua disparando Investida no preview")

	for _i in range(28):
		preview.cervo._advance_frame()

	var ev_6 = InputEventKey.new()
	ev_6.keycode = KEY_6
	ev_6.pressed = true
	preview._unhandled_input(ev_6)
	_assert(preview.cervo.is_antler_sequence_active(), "Tecla 6 continua disparando Corte das Galhadas no preview")

	for _i in range(28):
		preview.cervo._advance_frame()

	preview.queue_free()

func _test_09_regression_previous_10_animations() -> void:
	print("\n--- 9. Regressão das 10 Animações Homologadas (ART-BOSS-01, 02 e 03) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# 1. IDLE
	visual.play(CervoVisual.AnimState.IDLE)
	_assert(visual.get_total_frames() == 8, "1. IDLE funcional (8 quadros)")

	# 2. WALK
	visual.play(CervoVisual.AnimState.WALK)
	_assert(visual.get_total_frames() == 8, "2. WALK funcional (8 quadros)")

	# 3. GALLOP
	visual.play(CervoVisual.AnimState.GALLOP)
	_assert(visual.get_total_frames() == 12, "3. GALLOP funcional (12 quadros)")

	# 4. TURN
	visual.play(CervoVisual.AnimState.TURN)
	_assert(visual.get_total_frames() == 8, "4. TURN funcional (8 quadros)")

	# 5. CHARGE_PREP
	visual.play(CervoVisual.AnimState.CHARGE_PREP)
	_assert(visual.get_total_frames() == 8, "5. CHARGE_PREP funcional (8 quadros)")

	# 6. CHARGE_EXEC
	visual.play(CervoVisual.AnimState.CHARGE_EXEC)
	_assert(visual.get_total_frames() == 12, "6. CHARGE_EXEC funcional (12 quadros)")

	# 7. CHARGE_RECOVER
	visual.play(CervoVisual.AnimState.CHARGE_RECOVER)
	_assert(visual.get_total_frames() == 8, "7. CHARGE_RECOVER funcional (8 quadros)")

	# 8. ANTLER_PREP
	visual.play(CervoVisual.AnimState.ANTLER_PREP)
	_assert(visual.get_total_frames() == 8, "8. ANTLER_PREP funcional (8 quadros)")

	# 9. ANTLER_EXEC
	visual.play(CervoVisual.AnimState.ANTLER_EXEC)
	_assert(visual.get_total_frames() == 12, "9. ANTLER_EXEC funcional (12 quadros)")

	# 10. ANTLER_RECOVER
	visual.play(CervoVisual.AnimState.ANTLER_RECOVER)
	_assert(visual.get_total_frames() == 8, "10. ANTLER_RECOVER funcional (8 quadros)")

	visual.queue_free()

func _test_10_no_combat_or_hitboxes_in_sector10() -> void:
	print("\n--- 10. Preservação de Escopo: Sem Combate, Hitboxes ou Dano ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	var has_hitboxes: bool = false
	for child in visual.get_children():
		if child is Area2D or child is CollisionShape2D or "hitbox" in child.name.to_lower():
			has_hitboxes = true
			break
	_assert(not has_hitboxes, "CervoVisual não possui hitboxes, áreas de colisão ou lógica de dano")

	# Verifica que a cena do Setor 10 existe e está preservada
	_assert(FileAccess.file_exists("res://scenes/forest/sector_10.tscn"), "Cena sector_10.tscn preservada")

	visual.queue_free()
