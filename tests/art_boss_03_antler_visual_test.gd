extends SceneTree
## Suíte de Testes Automatizados para ART-BOSS-03: Integração Visual do Corte das Galhadas
## Validação das 3 Spritesheets do Corte, Encadeamento Contínuo e Cena de Pré-Visualização

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
	print("SUÍTE DE TESTES ART-BOSS-03: CORTE DAS GALHADAS")
	print("==================================================")

	_test_01_antler_raw_images_preserved()
	_test_02_antler_spritesheets_dimensions_and_metadata()
	_test_03_anim_state_and_config_integrity()
	await _test_04_individual_antler_state_transitions()
	await _test_05_automated_antler_sequence_chaining()
	await _test_06_bidirectional_facing_antler_sequence()
	await _test_07_repeated_trigger_and_attack_concurrency_safety()
	await _test_08_preview_scene_key_6_integration()
	await _test_09_regression_previous_7_animations()
	await _test_10_no_combat_or_hitboxes_in_sector10()

	print("\n==================================================")
	print("RESULTADO ART-BOSS-03: %d PASSOU, %d FALHOU" % [_passed, _failed])
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

func _test_01_antler_raw_images_preserved() -> void:
	print("\n--- 1. Existência e Preservação dos Arquivos Originais do Corte das Galhadas ---")
	var antler_raw_files = [
		"res://assets/art/cervo/original/cervo_antler_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_antler_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_antler_recover_original.jpg"
	]
	for path in antler_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original do corte preservado: %s" % path.get_file())

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

func _test_02_antler_spritesheets_dimensions_and_metadata() -> void:
	print("\n--- 2. Carregamento e Dimensões das 3 Spritesheets do Corte das Galhadas ---")
	var tex_prep: Texture2D = load("res://assets/art/cervo/cervo_antler_prep.png")
	var tex_exec: Texture2D = load("res://assets/art/cervo/cervo_antler_exec.png")
	var tex_rec: Texture2D = load("res://assets/art/cervo/cervo_antler_recover.png")

	_assert(tex_prep != null and tex_prep.get_width() == 1024 and tex_prep.get_height() == 512,
		"Spritesheet Preparação (Antler Prep): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_exec != null and tex_exec.get_width() == 1024 and tex_exec.get_height() == 768,
		"Spritesheet Execução (Antler Exec): 1024x768 px (4x3 células de 256x256)")
	_assert(tex_rec != null and tex_rec.get_width() == 1024 and tex_rec.get_height() == 512,
		"Spritesheet Recuperação (Antler Recover): 1024x512 px (4x2 células de 256x256)")

	# Existência dos metadados .import
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_antler_prep.png.import"),
		"Metadado .import de cervo_antler_prep.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_antler_exec.png.import"),
		"Metadado .import de cervo_antler_exec.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_antler_recover.png.import"),
		"Metadado .import de cervo_antler_recover.png presente")

func _test_03_anim_state_and_config_integrity() -> void:
	print("\n--- 3. Estados AnimState e Configurações de Grade do Corte ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	_assert(CervoVisual.AnimState.ANTLER_PREP != null, "AnimState.ANTLER_PREP definido")
	_assert(CervoVisual.AnimState.ANTLER_EXEC != null, "AnimState.ANTLER_EXEC definido")
	_assert(CervoVisual.AnimState.ANTLER_RECOVER != null, "AnimState.ANTLER_RECOVER definido")

	# Validação de quadros, cadência e looping
	var cfg_prep: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ANTLER_PREP]
	_assert(cfg_prep["total_frames"] == 8, "ANTLER_PREP: total de 8 quadros")
	_assert(cfg_prep["columns"] == 4 and cfg_prep["rows"] == 2, "ANTLER_PREP: grade 4x2")
	_assert(cfg_prep["loop"] == false, "ANTLER_PREP: loop desativado (one-shot encadeado)")
	_assert(cfg_prep["fps"] == 8.0, "ANTLER_PREP: cadência de 8.0 FPS (~1.0s)")

	var cfg_exec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ANTLER_EXEC]
	_assert(cfg_exec["total_frames"] == 12, "ANTLER_EXEC: total de 12 quadros")
	_assert(cfg_exec["columns"] == 4 and cfg_exec["rows"] == 3, "ANTLER_EXEC: grade 4x3")
	_assert(cfg_exec["loop"] == false, "ANTLER_EXEC: loop desativado (one-shot encadeado)")
	_assert(cfg_exec["fps"] == 12.0, "ANTLER_EXEC: cadência de 12.0 FPS (~1.0s)")

	var cfg_rec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ANTLER_RECOVER]
	_assert(cfg_rec["total_frames"] == 8, "ANTLER_RECOVER: total de 8 quadros")
	_assert(cfg_rec["columns"] == 4 and cfg_rec["rows"] == 2, "ANTLER_RECOVER: grade 4x2")
	_assert(cfg_rec["loop"] == false, "ANTLER_RECOVER: loop desativado (one-shot encadeado)")
	_assert(cfg_rec["fps"] == 8.0, "ANTLER_RECOVER: cadência de 8.0 FPS (~1.0s)")

	visual.queue_free()
func _test_04_individual_antler_state_transitions() -> void:
	print("\n--- 4. Transições Individuais e Nomes das Animações do Corte ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.play_by_name("antler_prep")
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "play_by_name('antler_prep') ativa ANTLER_PREP")
	_assert(visual.get_current_anim_name() == "antler_prep", "Nome canônico é 'antler_prep'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.play_by_name("antler_exec")
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_EXEC, "play_by_name('antler_exec') ativa ANTLER_EXEC")
	_assert(visual.get_current_anim_name() == "antler_exec", "Nome canônico é 'antler_exec'")
	_assert(visual.get_total_frames() == 12, "Total de quadros reportado é 12")

	visual.play_by_name("antler_recover")
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_RECOVER, "play_by_name('antler_recover') ativa ANTLER_RECOVER")
	_assert(visual.get_current_anim_name() == "antler_recover", "Nome canônico é 'antler_recover'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.queue_free()
func _test_05_automated_antler_sequence_chaining() -> void:
	print("\n--- 5. Encadeamento Automático Completo: IDLE -> PREP -> EXEC -> RECOVER -> IDLE ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	var stage_events: Array[String] = []
	var completed_events: Array[bool] = []

	visual.antler_stage_changed.connect(func(stage: String): stage_events.append(stage))
	visual.antler_sequence_completed.connect(func(): completed_events.append(true))

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Inicia em IDLE")

	# Dispara a sequência completa
	visual.start_antler_sequence()
	_assert(visual.is_antler_sequence_active(), "Sequência do corte de galhadas está ativa")
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "Etapa 1: ANTLER_PREP ativa")

	# Avança os 8 quadros da etapa de preparação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da preparação (7)")

	# Transição automática: PREP -> EXEC
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_EXEC, "Etapa 2: transição automática para ANTLER_EXEC")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de ANTLER_EXEC")

	# Avança os 12 quadros da etapa de execução
	for _i in range(11):
		visual._advance_frame()
	_assert(visual.current_frame == 11, "Atingiu último quadro da execução (11)")

	# Transição automática: EXEC -> RECOVER
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_RECOVER, "Etapa 3: transição automática para ANTLER_RECOVER")
	_assert(visual.current_frame == 0, "Quadro resetado para 0 no início de ANTLER_RECOVER")

	# Avança os 8 quadros da etapa de recuperação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da recuperação (7)")

	# Transição automática: RECOVER -> IDLE
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Etapa 4: transição automática de volta para IDLE")
	_assert(not completed_events.is_empty(), "Sinal antler_sequence_completed emitido com sucesso")
	_assert(not visual.is_antler_sequence_active(), "is_antler_sequence_active() agora é false")

	# Verifica histórico de estágios emitidos
	_assert(stage_events.has("antler_prep") and stage_events.has("antler_exec") and stage_events.has("antler_recover") and stage_events.has("idle"),
		"Todos os estágios foram notificados ordenadamente: %s" % str(stage_events))

	visual.queue_free()
func _test_06_bidirectional_facing_antler_sequence() -> void:
	print("\n--- 6. Suporte Bidirecional do Corte (Direita + Esquerda) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# Teste 1: Voltado para a DIREITA (+1)
	visual.facing = 1
	visual.start_antler_sequence()
	_assert(visual.facing == 1, "Orientação inicial mantida à DIREITA (+1)")

	# Avança toda a sequência (8 + 12 + 8 = 28 quadros)
	for _i in range(28):
		visual._advance_frame()

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à DIREITA")
	_assert(visual.facing == 1, "Facing permaneceu exatamente 1 ao fim da sequência à direita")

	# Teste 2: Voltado para a ESQUERDA (-1)
	visual.facing = -1
	visual.start_antler_sequence()
	_assert(visual.facing == -1, "Orientação inicial mantida à ESQUERDA (-1)")

	# Avança toda a sequência à esquerda
	for _i in range(28):
		visual._advance_frame()

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Concluiu em IDLE voltado à ESQUERDA")
	_assert(visual.facing == -1, "Facing permaneceu exatamente -1 ao fim da sequência à esquerda")

	visual.queue_free()
func _test_07_repeated_trigger_and_attack_concurrency_safety() -> void:
	print("\n--- 7. Robustez contra Acionamentos Repetidos e Concorrência entre Ataques ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# 1. Acionamento repetido durante o corte
	visual.start_antler_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "Iniciou corte das galhadas")

	visual._advance_frame()
	visual._advance_frame()
	visual._advance_frame()
	_assert(visual.current_frame == 3, "No quadro 3 da preparação do corte")

	# Tentativa de disparar o corte novamente é ignorada
	visual.start_antler_sequence()
	_assert(visual.current_frame == 3, "Quadro 3 preservado (não reiniciou indevidamente)")
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "Estado ANTLER_PREP preservado")

	# 2. Tentativa de disparar a Investida enquanto o corte está ativo é ignorada
	visual.start_charge_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "Investida não interrompeu o corte ativo")
	_assert(not visual.is_charge_sequence_active(), "Sequência de investida permaneceu inativa")

	# Conclui a sequência do corte
	for _i in range(25):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Corte concluído de volta em IDLE")

	# 3. Tentativa de disparar o corte enquanto a investida está ativa é ignorada
	visual.start_charge_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.CHARGE_PREP, "Iniciou investida")
	visual._advance_frame()
	_assert(visual.current_frame == 1, "Investida no quadro 1")

	visual.start_antler_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.CHARGE_PREP, "Corte não interrompeu a investida ativa")
	_assert(not visual.is_antler_sequence_active(), "Sequência do corte permaneceu inativa")

	# Conclui a investida
	for _i in range(27):
		visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Investida concluída de volta em IDLE")

	visual.queue_free()
func _test_08_preview_scene_key_6_integration() -> void:
	print("\n--- 8. Integração da Tecla 6 na Cena CervoPreview ---")
	var scene: PackedScene = load("res://scenes/dev/cervo_preview.tscn")
	_assert(scene != null, "Cena cervo_preview.tscn carregada com sucesso")

	var preview = scene.instantiate() as CervoPreview
	_assert(preview != null, "Instância de CervoPreview criada")
	root.add_child(preview)
	await _frames(2)

	# Simula pressão da tecla 6
	var key_6 = InputEventKey.new()
	key_6.pressed = true
	key_6.keycode = KEY_6
	preview._unhandled_input(key_6)

	_assert(preview.cervo.current_state == CervoVisual.AnimState.ANTLER_PREP, "Tecla 6 disparou ANTLER_PREP no CervoVisual")
	_assert(preview.cervo.is_antler_sequence_active(), "Sequência do corte ativa no preview")

	# Conclui a animação no preview
	for _i in range(28):
		preview.cervo._advance_frame()
	_assert(preview.cervo.current_state == CervoVisual.AnimState.IDLE, "Retornou a IDLE no preview")

	# Simula tecla 5 para confirmar investida preservada
	var key_5 = InputEventKey.new()
	key_5.pressed = true
	key_5.keycode = KEY_5
	preview._unhandled_input(key_5)

	_assert(preview.cervo.current_state == CervoVisual.AnimState.CHARGE_PREP, "Tecla 5 continua disparando Investida no preview")

	preview.queue_free()

func _test_09_regression_previous_7_animations() -> void:
	print("\n--- 9. Regressão das 7 Animações Homologadas (ART-BOSS-01 e ART-BOSS-02) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	# 1. IDLE
	visual.play(CervoVisual.AnimState.IDLE)
	_assert(visual.current_state == CervoVisual.AnimState.IDLE and visual.get_total_frames() == 8, "1. IDLE funcional (8 quadros)")

	# 2. WALK
	visual.play(CervoVisual.AnimState.WALK)
	_assert(visual.current_state == CervoVisual.AnimState.WALK and visual.get_total_frames() == 8, "2. WALK funcional (8 quadros)")

	# 3. GALLOP
	visual.play(CervoVisual.AnimState.GALLOP)
	_assert(visual.current_state == CervoVisual.AnimState.GALLOP and visual.get_total_frames() == 12, "3. GALLOP funcional (12 quadros)")

	# 4. TURN
	visual.play(CervoVisual.AnimState.TURN)
	_assert(visual.current_state == CervoVisual.AnimState.TURN and visual.get_total_frames() == 8, "4. TURN funcional (8 quadros)")

	# 5. CHARGE_PREP
	visual.play(CervoVisual.AnimState.CHARGE_PREP)
	_assert(visual.current_state == CervoVisual.AnimState.CHARGE_PREP and visual.get_total_frames() == 8, "5. CHARGE_PREP funcional (8 quadros)")

	# 6. CHARGE_EXEC
	visual.play(CervoVisual.AnimState.CHARGE_EXEC)
	_assert(visual.current_state == CervoVisual.AnimState.CHARGE_EXEC and visual.get_total_frames() == 12, "6. CHARGE_EXEC funcional (12 quadros)")

	# 7. CHARGE_RECOVER
	visual.play(CervoVisual.AnimState.CHARGE_RECOVER)
	_assert(visual.current_state == CervoVisual.AnimState.CHARGE_RECOVER and visual.get_total_frames() == 8, "7. CHARGE_RECOVER funcional (8 quadros)")

	visual.queue_free()
func _test_10_no_combat_or_hitboxes_in_sector10() -> void:
	print("\n--- 10. Preservação de Escopo: Sem Combate, Hitboxes ou Dano ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	# O componente CervoVisual não deve possuir colisores de dano ou áreas de ataque
	var has_hitboxes: bool = false
	for child in visual.get_children():
		if child is Area2D or child is CollisionShape2D or "hitbox" in child.name.to_lower():
			has_hitboxes = true
			break
	_assert(not has_hitboxes, "CervoVisual não possui hitboxes, áreas de colisão ou lógica de dano")

	# Verifica que a cena do Setor 10 existe e está preservada
	_assert(FileAccess.file_exists("res://scenes/forest/sector_10.tscn"), "Cena sector_10.tscn preservada")

	visual.queue_free()
