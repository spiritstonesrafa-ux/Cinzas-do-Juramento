extends SceneTree
## Suíte de Testes Automatizados para ART-BOSS-05: Integração Visual do Salto Predatório
## Validação das 3 Spritesheets do Salto, Encadeamento Contínuo e Cena de Pré-Visualização

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
	print("SUÍTE DE TESTES ART-BOSS-05: SALTO PREDATÓRIO")
	print("==================================================")

	_test_01_leap_raw_images_preserved()
	_test_02_leap_spritesheets_dimensions_and_metadata()
	_test_03_anim_state_and_config_integrity()
	await _test_04_individual_leap_state_transitions()
	await _test_05_automated_leap_sequence_chaining()
	await _test_06_bidirectional_facing_leap_sequence()
	await _test_07_repeated_trigger_and_attack_concurrency_safety()
	await _test_08_preview_scene_key_8_integration()
	await _test_09_regression_previous_13_animations()
	await _test_10_no_combat_or_hitboxes_in_sector10()

	print("\n==================================================")
	print("RESULTADO ART-BOSS-05: %d PASSOU, %d FALHOU" % [_passed, _failed])
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

func _test_01_leap_raw_images_preserved() -> void:
	print("\n--- 1. Existência e Preservação dos Arquivos Originais do Salto Predatório ---")
	var leap_raw_files = [
		"res://assets/art/cervo/original/cervo_leap_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_leap_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_leap_recover_original.jpg"
	]
	for path in leap_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original do salto preservado: %s" % path.get_file())

	# Preservação dos 3 originais da Pisada das Almas (ART-BOSS-04)
	var stomp_raw_files = [
		"res://assets/art/cervo/original/cervo_stomp_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_stomp_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_stomp_recover_original.jpg"
	]
	for path in stomp_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original da pisada ART-BOSS-04 intacto: %s" % path.get_file())

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

func _test_02_leap_spritesheets_dimensions_and_metadata() -> void:
	print("\n--- 2. Carregamento e Dimensões das 3 Spritesheets do Salto Predatório ---")
	var tex_prep: Texture2D = load("res://assets/art/cervo/cervo_leap_prep.png")
	var tex_exec: Texture2D = load("res://assets/art/cervo/cervo_leap_exec.png")
	var tex_rec: Texture2D = load("res://assets/art/cervo/cervo_leap_recover.png")

	_assert(tex_prep != null and tex_prep.get_width() == 1024 and tex_prep.get_height() == 512,
		"Spritesheet Preparação (Leap Prep): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_exec != null and tex_exec.get_width() == 1024 and tex_exec.get_height() == 768,
		"Spritesheet Execução (Leap Exec): 1024x768 px (4x3 células de 256x256)")
	_assert(tex_rec != null and tex_rec.get_width() == 1024 and tex_rec.get_height() == 512,
		"Spritesheet Recuperação (Leap Recover): 1024x512 px (4x2 células de 256x256)")

	# Existência dos metadados .import
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_leap_prep.png.import"),
		"Metadado .import de cervo_leap_prep.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_leap_exec.png.import"),
		"Metadado .import de cervo_leap_exec.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_leap_recover.png.import"),
		"Metadado .import de cervo_leap_recover.png presente")

func _test_03_anim_state_and_config_integrity() -> void:
	print("\n--- 3. Estados AnimState e Configurações de Grade do Salto ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	_assert(CervoVisual.AnimState.LEAP_PREP != null, "AnimState.LEAP_PREP definido")
	_assert(CervoVisual.AnimState.LEAP_EXEC != null, "AnimState.LEAP_EXEC definido")
	_assert(CervoVisual.AnimState.LEAP_RECOVER != null, "AnimState.LEAP_RECOVER definido")

	# Validação de quadros, cadência e looping
	var cfg_prep: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.LEAP_PREP]
	_assert(cfg_prep["total_frames"] == 8, "LEAP_PREP: total de 8 quadros")
	_assert(cfg_prep["columns"] == 4 and cfg_prep["rows"] == 2, "LEAP_PREP: grade 4x2")
	_assert(cfg_prep["loop"] == false, "LEAP_PREP: loop desativado (one-shot encadeado)")
	_assert(cfg_prep["fps"] == 8.0, "LEAP_PREP: cadência de 8.0 FPS (~1.0s)")

	var cfg_exec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.LEAP_EXEC]
	_assert(cfg_exec["total_frames"] == 12, "LEAP_EXEC: total de 12 quadros")
	_assert(cfg_exec["columns"] == 4 and cfg_exec["rows"] == 3, "LEAP_EXEC: grade 4x3")
	_assert(cfg_exec["loop"] == false, "LEAP_EXEC: loop desativado (one-shot encadeado)")
	_assert(cfg_exec["fps"] == 12.0, "LEAP_EXEC: cadência de 12.0 FPS (~1.0s)")

	var cfg_rec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.LEAP_RECOVER]
	_assert(cfg_rec["total_frames"] == 8, "LEAP_RECOVER: total de 8 quadros")
	_assert(cfg_rec["columns"] == 4 and cfg_rec["rows"] == 2, "LEAP_RECOVER: grade 4x2")
	_assert(cfg_rec["loop"] == false, "LEAP_RECOVER: loop desativado (one-shot encadeado)")
	_assert(cfg_rec["fps"] == 8.0, "LEAP_RECOVER: cadência de 8.0 FPS (~1.0s)")

	visual.queue_free()

func _test_04_individual_leap_state_transitions() -> void:
	print("\n--- 4. Transições Individuais e Nomes das Animações do Salto ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.play_by_name("leap_prep")
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "play_by_name('leap_prep') ativa LEAP_PREP")
	_assert(visual.get_current_anim_name() == "leap_prep", "Nome canônico é 'leap_prep'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.play_by_name("leap_exec")
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_EXEC, "play_by_name('leap_exec') ativa LEAP_EXEC")
	_assert(visual.get_current_anim_name() == "leap_exec", "Nome canônico é 'leap_exec'")
	_assert(visual.get_total_frames() == 12, "Total de quadros reportado é 12")

	visual.play_by_name("leap_recover")
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_RECOVER, "play_by_name('leap_recover') ativa LEAP_RECOVER")
	_assert(visual.get_current_anim_name() == "leap_recover", "Nome canônico é 'leap_recover'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.queue_free()

func _test_05_automated_leap_sequence_chaining() -> void:
	print("\n--- 5. Encadeamento Automático Completo: IDLE -> PREP -> EXEC -> RECOVER -> IDLE ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	var stage_events: Array[String] = []
	var completed_events: Array[bool] = []

	visual.leap_stage_changed.connect(func(stage: String): stage_events.append(stage))
	visual.leap_sequence_completed.connect(func(): completed_events.append(true))

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Inicia em IDLE")

	# Dispara a sequência completa
	visual.start_leap_sequence()
	_assert(visual.is_leap_sequence_active(), "Sequência do salto predatório está ativa")
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Etapa 1: LEAP_PREP ativa")

	# Avança os 8 quadros da etapa de preparação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da preparação (7)")

	# Transição automática: PREP -> EXEC
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_EXEC, "Etapa 2: transição automática para LEAP_EXEC")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de LEAP_EXEC")

	# Avança os 12 quadros da etapa de execução
	for _i in range(11):
		visual._advance_frame()
	_assert(visual.current_frame == 11, "Atingiu último quadro da execução (11)")

	# Transição automática: EXEC -> RECOVER
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_RECOVER, "Etapa 3: transição automática para LEAP_RECOVER")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de LEAP_RECOVER")

	# Avança os 8 quadros da etapa de recuperação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da recuperação (7)")

	# Transição automática: RECOVER -> IDLE
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Etapa 4: transição automática de volta para IDLE")
	_assert(completed_events.size() == 1, "Sinal leap_sequence_completed emitido com sucesso")
	_assert(not visual.is_leap_sequence_active(), "is_leap_sequence_active() agora é false")
	_assert(stage_events == ["leap_prep", "leap_exec", "leap_recover", "idle"],
		"Todos os estágios do salto foram notificados ordenadamente: %s" % str(stage_events))

	visual.queue_free()

func _test_06_bidirectional_facing_leap_sequence() -> void:
	print("\n--- 6. Suporte Bidirecional do Salto (Direita + Esquerda) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# 1. Execução voltada para a direita (+1)
	visual.facing = 1
	visual.start_leap_sequence()
	_assert(visual.facing == 1, "Orientação inicial mantida à DIREITA (+1)")
	for _i in range(28):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à DIREITA")
	_assert(visual.facing == 1, "Facing permaneceu exatamente 1 ao fim da sequência à direita")

	# 2. Execução voltada para a esquerda (-1)
	visual.facing = -1
	visual.start_leap_sequence()
	_assert(visual.facing == -1, "Orientação inicial mantida à ESQUERDA (-1)")
	for _i in range(28):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à ESQUERDA")
	_assert(visual.facing == -1, "Facing permaneceu exatamente -1 ao fim da sequência à esquerda")

	visual.queue_free()

func _test_07_repeated_trigger_and_attack_concurrency_safety() -> void:
	print("\n--- 7. Robustez contra Acionamentos Repetidos e Concorrência entre os Quatro Ataques ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# Inicia salto
	visual.start_leap_sequence()
	_assert(visual.is_leap_sequence_active(), "Iniciou salto predatório")
	visual._advance_frame()
	visual._advance_frame()
	visual._advance_frame() # Frame 3
	_assert(visual.current_frame == 3, "No quadro 3 da preparação do salto")

	# Tentativa de reiniciar o salto em andamento deve ser ignorada
	visual.start_leap_sequence()
	_assert(visual.current_frame == 3, "Quadro 3 preservado (não reiniciou indevidamente)")
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Estado LEAP_PREP preservado")

	# Tentativa de disparar investida, corte ou pisada durante o salto ativo deve ser ignorada
	visual.start_charge_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Investida não interrompeu o salto ativo")
	_assert(not visual.is_charge_sequence_active(), "Sequência de investida permaneceu inativa")

	visual.start_antler_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Corte de galhadas não interrompeu o salto ativo")
	_assert(not visual.is_antler_sequence_active(), "Sequência de corte permaneceu inativa")

	visual.start_stomp_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Pisada das almas não interrompeu o salto ativo")
	_assert(not visual.is_stomp_sequence_active(), "Sequência da pisada permaneceu inativa")

	# Conclui o salto
	for _i in range(25):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Salto concluído de volta em IDLE")

	# Teste inverso: Salto não pode interromper Investida
	visual.start_charge_sequence()
	_assert(visual.is_charge_sequence_active(), "Iniciou investida")
	visual._advance_frame()
	visual.start_leap_sequence()
	_assert(visual.is_charge_sequence_active(), "Salto não interrompeu a investida ativa")
	_assert(not visual.is_leap_sequence_active(), "Sequência do salto permaneceu inativa")
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Investida concluída de volta em IDLE")

	# Teste inverso: Salto não pode interromper Corte
	visual.start_antler_sequence()
	_assert(visual.is_antler_sequence_active(), "Iniciou corte das galhadas")
	visual._advance_frame()
	visual.start_leap_sequence()
	_assert(visual.is_antler_sequence_active(), "Salto não interrompeu o corte ativo")
	_assert(not visual.is_leap_sequence_active(), "Sequência do salto permaneceu inativa")
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Corte concluído de volta em IDLE")

	# Teste inverso: Salto não pode interromper Pisada
	visual.start_stomp_sequence()
	_assert(visual.is_stomp_sequence_active(), "Iniciou pisada das almas")
	visual._advance_frame()
	visual.start_leap_sequence()
	_assert(visual.is_stomp_sequence_active(), "Salto não interrompeu a pisada ativa")
	_assert(not visual.is_leap_sequence_active(), "Sequência do salto permaneceu inativa")
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Pisada concluída de volta em IDLE")

	visual.queue_free()

func _test_08_preview_scene_key_8_integration() -> void:
	print("\n--- 8. Integração da Tecla 8 na Cena CervoPreview ---")
	var scene = load("res://scenes/dev/cervo_preview.tscn")
	_assert(scene != null, "Cena cervo_preview.tscn carregada com sucesso")

	var preview = scene.instantiate() as CervoPreview
	root.add_child(preview)
	await _frames(4)
	_assert(preview != null and preview.cervo != null, "Instância de CervoPreview criada com CervoVisual")

	# Simula pressionamento da tecla 8
	var event = InputEventKey.new()
	event.keycode = KEY_8
	event.pressed = true
	preview._unhandled_input(event)
	_assert(preview.cervo.current_state == CervoVisual.AnimState.LEAP_PREP, "Tecla 8 disparou LEAP_PREP no CervoVisual")
	_assert(preview.cervo.is_leap_sequence_active(), "Sequência do salto ativa no preview")

	# Conclui sequência no preview
	for _i in range(28):
		preview.cervo._advance_frame()
	_assert(preview.cervo.current_state == CervoVisual.AnimState.IDLE, "Retornou a IDLE no preview")

	# Valida preservação das teclas 5, 6 e 7
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

	var ev_7 = InputEventKey.new()
	ev_7.keycode = KEY_7
	ev_7.pressed = true
	preview._unhandled_input(ev_7)
	_assert(preview.cervo.is_stomp_sequence_active(), "Tecla 7 continua disparando Pisada das Almas no preview")

	for _i in range(28):
		preview.cervo._advance_frame()

	preview.queue_free()

func _test_09_regression_previous_13_animations() -> void:
	print("\n--- 9. Regressão das 13 Animações Homologadas (ART-BOSS-01, 02, 03 e 04) ---")
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

	# 11. STOMP_PREP
	visual.play(CervoVisual.AnimState.STOMP_PREP)
	_assert(visual.get_total_frames() == 8, "11. STOMP_PREP funcional (8 quadros)")

	# 12. STOMP_EXEC
	visual.play(CervoVisual.AnimState.STOMP_EXEC)
	_assert(visual.get_total_frames() == 12, "12. STOMP_EXEC funcional (12 quadros)")

	# 13. STOMP_RECOVER
	visual.play(CervoVisual.AnimState.STOMP_RECOVER)
	_assert(visual.get_total_frames() == 8, "13. STOMP_RECOVER funcional (8 quadros)")

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
