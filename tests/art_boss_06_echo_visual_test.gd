extends SceneTree
## Suíte de Testes Automatizados para ART-BOSS-06: Ecos da Floresta (Invocação Espectral)
## Validação das 5 Spritesheets de Produção, Componente Visual de Ecos, Encadeamento Contínuo e Preview

const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const CervoEchoVisual = preload("res://scripts/boss/cervo_echo_visual.gd")
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
	print("SUÍTE DE TESTES ART-BOSS-06: ECOS DA FLORESTA")
	print("==================================================")

	_test_01_echo_raw_images_preserved()
	_test_02_echo_spritesheets_dimensions_and_metadata()
	_test_03_anim_state_and_config_integrity()
	await _test_04_individual_echo_state_transitions()
	await _test_05_automated_echo_sequence_chaining()
	await _test_06_echo_visual_component_and_independence()
	await _test_07_repeated_trigger_and_attack_concurrency_safety()
	await _test_08_preview_scene_key_9_integration()
	await _test_09_regression_previous_16_animations()
	await _test_10_no_combat_or_hitboxes_in_sector10()

	print("\n==================================================")
	print("RESULTADO ART-BOSS-06: %d PASSOU, %d FALHOU" % [_passed, _failed])
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

func _test_01_echo_raw_images_preserved() -> void:
	print("\n--- 1. Existência e Preservação dos Arquivos Originais de Ecos da Floresta ---")
	var echo_raw_files = [
		"res://assets/art/cervo/original/cervo_echo_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_echo_cast_original.jpg",
		"res://assets/art/cervo/original/cervo_echo_recover_original.jpg",
		"res://assets/art/cervo/original/cervo_echo_manifest_original.jpg",
		"res://assets/art/cervo/original/cervo_echo_dissolve_original.jpg"
	]
	for path in echo_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original de ecos preservado: %s" % path.get_file())

	# Preservação dos 3 originais do Salto Predatório (ART-BOSS-05)
	var leap_raw_files = [
		"res://assets/art/cervo/original/cervo_leap_prep_original.jpg",
		"res://assets/art/cervo/original/cervo_leap_exec_original.jpg",
		"res://assets/art/cervo/original/cervo_leap_recover_original.jpg"
	]
	for path in leap_raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original do salto ART-BOSS-05 intacto: %s" % path.get_file())

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

func _test_02_echo_spritesheets_dimensions_and_metadata() -> void:
	print("\n--- 2. Carregamento e Dimensões das 5 Spritesheets de Ecos da Floresta ---")
	var tex_prep: Texture2D = load("res://assets/art/cervo/cervo_echo_prep.png")
	var tex_cast: Texture2D = load("res://assets/art/cervo/cervo_echo_cast.png")
	var tex_rec: Texture2D = load("res://assets/art/cervo/cervo_echo_recover.png")
	var tex_mani: Texture2D = load("res://assets/art/cervo/cervo_echo_manifest.png")
	var tex_diss: Texture2D = load("res://assets/art/cervo/cervo_echo_dissolve.png")

	_assert(tex_prep != null and tex_prep.get_width() == 1024 and tex_prep.get_height() == 512,
		"Spritesheet Preparação do Ritual (Echo Prep): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_cast != null and tex_cast.get_width() == 1024 and tex_cast.get_height() == 768,
		"Spritesheet Invocação (Echo Cast): 1024x768 px (4x3 células de 256x256)")
	_assert(tex_rec != null and tex_rec.get_width() == 1024 and tex_rec.get_height() == 512,
		"Spritesheet Recuperação (Echo Recover): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_mani != null and tex_mani.get_width() == 1024 and tex_mani.get_height() == 512,
		"Spritesheet Formação do Eco (Echo Manifest): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_diss != null and tex_diss.get_width() == 1024 and tex_diss.get_height() == 512,
		"Spritesheet Dissipação do Eco (Echo Dissolve): 1024x512 px (4x2 células de 256x256)")

	# Existência dos metadados .import
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_echo_prep.png.import"),
		"Metadado .import de cervo_echo_prep.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_echo_cast.png.import"),
		"Metadado .import de cervo_echo_cast.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_echo_recover.png.import"),
		"Metadado .import de cervo_echo_recover.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_echo_manifest.png.import"),
		"Metadado .import de cervo_echo_manifest.png presente")
	_assert(FileAccess.file_exists("res://assets/art/cervo/cervo_echo_dissolve.png.import"),
		"Metadado .import de cervo_echo_dissolve.png presente")

func _test_03_anim_state_and_config_integrity() -> void:
	print("\n--- 3. Estados AnimState e Configurações de Grade de Ecos da Floresta ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	_assert(CervoVisual.AnimState.ECHO_PREP != null, "AnimState.ECHO_PREP definido")
	_assert(CervoVisual.AnimState.ECHO_CAST != null, "AnimState.ECHO_CAST definido")
	_assert(CervoVisual.AnimState.ECHO_RECOVER != null, "AnimState.ECHO_RECOVER definido")
	_assert(CervoVisual.AnimState.ECHO_MANIFEST != null, "AnimState.ECHO_MANIFEST definido")
	_assert(CervoVisual.AnimState.ECHO_DISSOLVE != null, "AnimState.ECHO_DISSOLVE definido")

	# Validação de quadros, cadência e looping
	var cfg_prep: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ECHO_PREP]
	_assert(cfg_prep["total_frames"] == 8, "ECHO_PREP: total de 8 quadros")
	_assert(cfg_prep["columns"] == 4 and cfg_prep["rows"] == 2, "ECHO_PREP: grade 4x2")
	_assert(cfg_prep["loop"] == false, "ECHO_PREP: loop desativado (one-shot encadeado)")
	_assert(cfg_prep["fps"] == 8.0, "ECHO_PREP: cadência de 8.0 FPS (~1.0s)")

	var cfg_cast: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ECHO_CAST]
	_assert(cfg_cast["total_frames"] == 12, "ECHO_CAST: total de 12 quadros")
	_assert(cfg_cast["columns"] == 4 and cfg_cast["rows"] == 3, "ECHO_CAST: grade 4x3")
	_assert(cfg_cast["loop"] == false, "ECHO_CAST: loop desativado (one-shot encadeado)")
	_assert(cfg_cast["fps"] == 12.0, "ECHO_CAST: cadência de 12.0 FPS (~1.0s)")

	var cfg_rec: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ECHO_RECOVER]
	_assert(cfg_rec["total_frames"] == 8, "ECHO_RECOVER: total de 8 quadros")
	_assert(cfg_rec["columns"] == 4 and cfg_rec["rows"] == 2, "ECHO_RECOVER: grade 4x2")
	_assert(cfg_rec["loop"] == false, "ECHO_RECOVER: loop desativado (one-shot encadeado)")
	_assert(cfg_rec["fps"] == 8.0, "ECHO_RECOVER: cadência de 8.0 FPS (~1.0s)")

	var cfg_mani: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ECHO_MANIFEST]
	_assert(cfg_mani["total_frames"] == 8, "ECHO_MANIFEST: total de 8 quadros")
	_assert(cfg_mani["columns"] == 4 and cfg_mani["rows"] == 2, "ECHO_MANIFEST: grade 4x2")
	_assert(cfg_mani["loop"] == false, "ECHO_MANIFEST: loop desativado")
	_assert(cfg_mani["fps"] == 8.0, "ECHO_MANIFEST: cadência de 8.0 FPS (~1.0s)")

	var cfg_diss: Dictionary = visual.ANIM_CONFIG[CervoVisual.AnimState.ECHO_DISSOLVE]
	_assert(cfg_diss["total_frames"] == 8, "ECHO_DISSOLVE: total de 8 quadros")
	_assert(cfg_diss["columns"] == 4 and cfg_diss["rows"] == 2, "ECHO_DISSOLVE: grade 4x2")
	_assert(cfg_diss["loop"] == false, "ECHO_DISSOLVE: loop desativado")
	_assert(cfg_diss["fps"] == 8.0, "ECHO_DISSOLVE: cadência de 8.0 FPS (~1.0s)")

	visual.queue_free()

func _test_04_individual_echo_state_transitions() -> void:
	print("\n--- 4. Transições Individuais e Nomes das Animações de Ecos ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.play_by_name("echo_prep")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "play_by_name('echo_prep') ativa ECHO_PREP")
	_assert(visual.get_current_anim_name() == "echo_prep", "Nome canônico é 'echo_prep'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.play_by_name("echo_cast")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_CAST, "play_by_name('echo_cast') ativa ECHO_CAST")
	_assert(visual.get_current_anim_name() == "echo_cast", "Nome canônico é 'echo_cast'")
	_assert(visual.get_total_frames() == 12, "Total de quadros reportado é 12")

	visual.play_by_name("echo_recover")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_RECOVER, "play_by_name('echo_recover') ativa ECHO_RECOVER")
	_assert(visual.get_current_anim_name() == "echo_recover", "Nome canônico é 'echo_recover'")
	_assert(visual.get_total_frames() == 8, "Total de quadros reportado é 8")

	visual.play_by_name("echo_manifest")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_MANIFEST, "play_by_name('echo_manifest') ativa ECHO_MANIFEST")
	_assert(visual.get_current_anim_name() == "echo_manifest", "Nome canônico é 'echo_manifest'")

	visual.play_by_name("echo_dissolve")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_DISSOLVE, "play_by_name('echo_dissolve') ativa ECHO_DISSOLVE")
	_assert(visual.get_current_anim_name() == "echo_dissolve", "Nome canônico é 'echo_dissolve'")

	visual.queue_free()

func _test_05_automated_echo_sequence_chaining() -> void:
	print("\n--- 5. Encadeamento Automático do Ritual: IDLE -> PREP -> CAST -> RECOVER -> IDLE ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	var stage_events: Array[String] = []
	var completed_events: Array[bool] = []

	visual.echo_stage_changed.connect(func(stage: String): stage_events.append(stage))
	visual.echo_sequence_completed.connect(func(): completed_events.append(true))

	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Inicia em IDLE")

	# Dispara a sequência completa do ritual
	visual.start_echo_sequence()
	_assert(visual.is_echo_sequence_active(), "Sequência do ritual está ativa")
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Etapa 1: ECHO_PREP ativa")

	# Avança os 8 quadros da etapa de preparação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da preparação (7)")

	# Próximo avanço transita para ECHO_CAST
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_CAST, "Transição automática para Etapa 2: ECHO_CAST")
	_assert(visual.current_frame == 0, "Reinicia contador de quadro para 0")
	_assert(stage_events.has("echo_cast"), "Sinal echo_stage_changed('echo_cast') emitido")

	# Avança os 12 quadros da etapa de invocação
	for _i in range(11):
		visual._advance_frame()
	_assert(visual.current_frame == 11, "Atingiu último quadro da invocação (11)")

	# Próximo avanço transita para ECHO_RECOVER
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_RECOVER, "Transição automática para Etapa 3: ECHO_RECOVER")
	_assert(visual.current_frame == 0, "Reinicia contador de quadro para 0")
	_assert(stage_events.has("echo_recover"), "Sinal echo_stage_changed('echo_recover') emitido")

	# Avança os 8 quadros da etapa de recuperação
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da recuperação (7)")

	# Próximo avanço conclui a sequência e retorna para IDLE
	visual._advance_frame()
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Retorno natural ao estado IDLE")
	_assert(not visual.is_echo_sequence_active(), "Sequência de ecos concluída")
	_assert(completed_events.size() == 1, "Sinal echo_sequence_completed emitido com sucesso")
	_assert(stage_events.has("idle"), "Sinal echo_stage_changed('idle') emitido")

	visual.queue_free()

func _test_06_echo_visual_component_and_independence() -> void:
	print("\n--- 6. Independência das Manifestações Espectrais (Echo_A e Echo_B) ---")
	var echo_a: CervoEchoVisual = CervoEchoVisual.new()
	var echo_b: CervoEchoVisual = CervoEchoVisual.new()
	root.add_child(echo_a)
	root.add_child(echo_b)
	await _frames(2)

	_assert(echo_a.is_inactive(), "Echo_A inicia inativo")
	_assert(echo_b.is_inactive(), "Echo_B inicia inativo")

	# Manifestação independente com posições e orientações opostas
	echo_a.spawn_echo(Vector2(100.0, 138.0), -1, 2.0, 30.0)
	echo_b.spawn_echo(Vector2(260.0, 138.0), 1, 2.0, 30.0)

	_assert(echo_a.is_manifesting() and echo_a.visible, "Echo_A manifestando e visível")
	_assert(echo_b.is_manifesting() and echo_b.visible, "Echo_B manifestando e visível")
	_assert(echo_a.facing == -1, "Echo_A voltado para a esquerda (-1)")
	_assert(echo_b.facing == 1, "Echo_B voltado para a direita (1)")
	_assert(echo_a.position != echo_b.position, "Posições espaciais distintas")
	_assert(echo_a.modulate_color.a > 0.5, "Modulação espectral ativa")

	# Avança frames da manifestação até se tornarem ativos
	for _i in range(8):
		echo_a._advance_frame()
		echo_b._advance_frame()

	_assert(echo_a.is_active_echo(), "Echo_A concluiu manifestação e está ativo")
	_assert(echo_b.is_active_echo(), "Echo_B concluiu manifestação e está ativo")

	# Inicia dissipação individual
	echo_a.start_dissolve()
	_assert(echo_a.is_dissolving(), "Echo_A em dissipação")
	_assert(echo_b.is_active_echo(), "Echo_B permanece ativo independentemente")

	for _i in range(8):
		echo_a._advance_frame()
	_assert(echo_a.is_inactive() and not echo_a.visible, "Echo_A concluiu dissipação e ficou invisível")
	_assert(echo_b.is_active_echo(), "Echo_B continua ativo sem interferência")

	echo_b.dismiss()
	_assert(echo_b.is_inactive(), "Echo_B dispensado com sucesso")

	echo_a.queue_free()
	echo_b.queue_free()

func _test_07_repeated_trigger_and_attack_concurrency_safety() -> void:
	print("\n--- 7. Robustez contra Disparos Repetidos e Concorrência entre os 5 Ataques ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.start_echo_sequence()
	_assert(visual.is_echo_sequence_active(), "Ritual iniciado")

	# Disparo repetido do ritual não deve reiniciar
	visual.current_frame = 3
	visual.start_echo_sequence()
	_assert(visual.current_frame == 3, "Disparo repetido do ritual ignorado sem resetar quadro")

	# Tentativa de iniciar outros ataques durante o ritual deve ser bloqueada
	visual.start_charge_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Investida bloqueada durante ritual de ecos")
	_assert(not visual.is_charge_sequence_active(), "Investida permanece inativa")

	visual.start_antler_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Corte das galhadas bloqueado durante ritual de ecos")
	_assert(not visual.is_antler_sequence_active(), "Corte permanece inativo")

	visual.start_stomp_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Pisada das almas bloqueada durante ritual de ecos")
	_assert(not visual.is_stomp_sequence_active(), "Pisada permanece inativa")

	visual.start_leap_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Salto predatório bloqueado durante ritual de ecos")
	_assert(not visual.is_leap_sequence_active(), "Salto permanece inativo")

	# Conclui o ritual para retornar a IDLE
	visual._is_echo_sequence = false
	visual.play(CervoVisual.AnimState.IDLE)

	# Tentativa inversa: ritual bloqueado durante Salto Predatório
	visual.start_leap_sequence()
	_assert(visual.is_leap_sequence_active(), "Salto iniciado com sucesso")
	visual.start_echo_sequence()
	_assert(visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Ritual bloqueado durante Salto Predatório")
	_assert(not visual.is_echo_sequence_active(), "Ritual permanece inativo")

	visual.queue_free()

func _test_08_preview_scene_key_9_integration() -> void:
	print("\n--- 8. Integração da Cena de Pré-Visualização (CervoPreview Tecla 9) ---")
	var preview: CervoPreview = CervoPreview.new()
	root.add_child(preview)
	await _frames(3)

	_assert(preview.cervo != null, "Preview possui instância do CervoVisual")
	_assert(preview.echo_a != null, "Preview possui instância de Echo_A")
	_assert(preview.echo_b != null, "Preview possui instância de Echo_B")

	# Simulação do evento de pressionar a tecla 9
	var key_event: InputEventKey = InputEventKey.new()
	key_event.keycode = KEY_9
	key_event.pressed = true
	preview._unhandled_input(key_event)

	_assert(preview.cervo.is_echo_sequence_active(), "Pressionar tecla 9 inicia o ritual de ecos no preview")
	_assert(preview.cervo.current_state == CervoVisual.AnimState.ECHO_PREP, "Preview transiciona para ECHO_PREP")

	# Simulação do reset via tecla R
	var reset_event: InputEventKey = InputEventKey.new()
	reset_event.keycode = KEY_R
	reset_event.pressed = true
	preview._unhandled_input(reset_event)

	_assert(preview.cervo.current_state == CervoVisual.AnimState.IDLE, "Tecla R reseta Cervo para IDLE")
	_assert(preview.echo_a.is_inactive(), "Tecla R dispensa Echo_A")
	_assert(preview.echo_b.is_inactive(), "Tecla R dispensa Echo_B")

	preview.queue_free()

func _test_09_regression_previous_16_animations() -> void:
	print("\n--- 9. Regressão das 16 Animações Canônicas Anteriores (148 Quadros) ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	var expected_anims = {
		CervoVisual.AnimState.IDLE: {"name": "idle", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.WALK: {"name": "walk", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.GALLOP: {"name": "gallop", "frames": 12, "cols": 4, "rows": 3},
		CervoVisual.AnimState.TURN: {"name": "turn", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.CHARGE_PREP: {"name": "charge_prep", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.CHARGE_EXEC: {"name": "charge_exec", "frames": 12, "cols": 4, "rows": 3},
		CervoVisual.AnimState.CHARGE_RECOVER: {"name": "charge_recover", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.ANTLER_PREP: {"name": "antler_prep", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.ANTLER_EXEC: {"name": "antler_exec", "frames": 12, "cols": 4, "rows": 3},
		CervoVisual.AnimState.ANTLER_RECOVER: {"name": "antler_recover", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.STOMP_PREP: {"name": "stomp_prep", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.STOMP_EXEC: {"name": "stomp_exec", "frames": 12, "cols": 4, "rows": 3},
		CervoVisual.AnimState.STOMP_RECOVER: {"name": "stomp_recover", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.LEAP_PREP: {"name": "leap_prep", "frames": 8, "cols": 4, "rows": 2},
		CervoVisual.AnimState.LEAP_EXEC: {"name": "leap_exec", "frames": 12, "cols": 4, "rows": 3},
		CervoVisual.AnimState.LEAP_RECOVER: {"name": "leap_recover", "frames": 8, "cols": 4, "rows": 2}
	}

	var total_frames_verified: int = 0
	for state in expected_anims.keys():
		var exp_data: Dictionary = expected_anims[state]
		var cfg: Dictionary = visual.ANIM_CONFIG[state]
		_assert(cfg["name"] == exp_data["name"], "Nome da animação regressiva '%s' preservado" % exp_data["name"])
		_assert(cfg["total_frames"] == exp_data["frames"], "Total de quadros de '%s' é %d" % [exp_data["name"], exp_data["frames"]])
		_assert(cfg["columns"] == exp_data["cols"] and cfg["rows"] == exp_data["rows"], "Grade %dx%d de '%s' preservada" % [exp_data["cols"], exp_data["rows"], exp_data["name"]])
		total_frames_verified += int(cfg["total_frames"])

	_assert(total_frames_verified == 148, "Total exato de 148 quadros regressivos preservados nas 16 animações anteriores")
	visual.queue_free()

func _test_10_no_combat_or_hitboxes_in_sector10() -> void:
	print("\n--- 10. Delimitação Estrita de Escopo: Zero Combate, Sem Hitboxes, Setor 10 Intacto ---")
	var visual: CervoVisual = CervoVisual.new()
	var echo: CervoEchoVisual = CervoEchoVisual.new()
	root.add_child(visual)
	root.add_child(echo)

	# 1. Verifica ausência de nós de combate filhos
	var forbidden_nodes: int = 0
	for child in visual.get_children():
		if child is Area2D or child is CollisionShape2D or child is CollisionPolygon2D:
			forbidden_nodes += 1
	for child in echo.get_children():
		if child is Area2D or child is CollisionShape2D or child is CollisionPolygon2D:
			forbidden_nodes += 1
	_assert(forbidden_nodes == 0, "CervoVisual e CervoEchoVisual não contêm nós de colisão, ataque ou hitboxes")

	# 2. Verifica ausência de propriedades de combate (dano, vida, stun, knockback)
	_assert(visual.get("damage") == null, "CervoVisual não possui propriedade 'damage'")
	_assert(visual.get("hitbox") == null, "CervoVisual não possui propriedade 'hitbox'")
	_assert(visual.get("hurtbox") == null, "CervoVisual não possui propriedade 'hurtbox'")
	_assert(echo.get("damage") == null, "CervoEchoVisual não possui propriedade 'damage'")
	_assert(echo.get("hitbox") == null, "CervoEchoVisual não possui propriedade 'hitbox'")
	_assert(echo.get("hurtbox") == null, "CervoEchoVisual não possui propriedade 'hurtbox'")

	# 3. Verifica integridade de scenes/forest/sector_10.tscn (não deve conter instâncias do chefe ou ecos)
	var s10_exists: bool = FileAccess.file_exists("res://scenes/forest/sector_10.tscn")
	_assert(s10_exists, "scenes/forest/sector_10.tscn preservada no projeto")
	if s10_exists:
		var s10_file: FileAccess = FileAccess.open("res://scenes/forest/sector_10.tscn", FileAccess.READ)
		var content: String = s10_file.get_as_text()
		s10_file.close()
		_assert(not ("CervoVisual" in content), "Setor 10 não instancia CervoVisual prematuramente")
		_assert(not ("CervoEchoVisual" in content), "Setor 10 não instancia CervoEchoVisual prematuramente")
		_assert(not ("cervo_echo" in content), "Setor 10 não contém referências aos ecos da floresta")

	visual.queue_free()
	echo.queue_free()
