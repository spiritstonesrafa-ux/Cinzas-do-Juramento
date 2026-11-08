extends SceneTree
## Suíte de Testes Automatizados para ART-BOSS-01: Animações Básicas do Cervo Espectral
## Validação das Spritesheets Oficiais, Componente CervoVisual e Cena de Pré-Visualização

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
	print("SUÍTE DE TESTES ART-BOSS-01: ANIMAÇÕES DO CERVO ESPECTRAL")
	print("==================================================")

	_test_01_raw_images_preserved()
	_test_02_processed_spritesheets_dimensions()
	_test_03_cervo_visual_instantiation_and_config()
	await _test_04_animation_playback_and_transitions()
	await _test_05_turn_animation_and_facing_inversion()
	await _test_06_preview_scene_instantiation()
	await _test_07_no_premature_boss_combat_in_sector10()

	print("\n==================================================")
	print("RESULTADO ART-BOSS-01: %d PASSOU, %d FALHOU" % [_passed, _failed])
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

func _test_01_raw_images_preserved() -> void:
	print("\n--- 1. Existência e Preservação dos 4 Arquivos Originais Aprovados ---")
	var raw_files = [
		"res://assets/art/cervo/original/cervo_idle_new_original.jpg",
		"res://assets/art/cervo/original/cervo_walk_original.png",
		"res://assets/art/cervo/original/cervo_gallop_original.jpg",
		"res://assets/art/cervo/original/cervo_turn_original.png"
	]
	for path in raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo original preservado: %s" % path.get_file())

func _test_02_processed_spritesheets_dimensions() -> void:
	print("\n--- 2. Carregamento e Dimensões das Spritesheets Processadas ---")
	var tex_idle: Texture2D = load("res://assets/art/cervo/cervo_idle.png")
	var tex_walk: Texture2D = load("res://assets/art/cervo/cervo_walk.png")
	var tex_gallop: Texture2D = load("res://assets/art/cervo/cervo_gallop.png")
	var tex_turn: Texture2D = load("res://assets/art/cervo/cervo_turn.png")

	_assert(tex_idle != null and tex_idle.get_width() == 1024 and tex_idle.get_height() == 512,
		"Spritesheet Repouso (Idle): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_walk != null and tex_walk.get_width() == 1024 and tex_walk.get_height() == 512,
		"Spritesheet Caminhada (Walk): 1024x512 px (4x2 células de 256x256)")
	_assert(tex_gallop != null and tex_gallop.get_width() == 1024 and tex_gallop.get_height() == 768,
		"Spritesheet Galope (Gallop): 1024x768 px (4x3 células de 256x256)")
	_assert(tex_turn != null and tex_turn.get_width() == 1024 and tex_turn.get_height() == 512,
		"Spritesheet Virada (Turn): 1024x512 px (4x2 células de 256x256)")

func _test_03_cervo_visual_instantiation_and_config() -> void:
	print("\n--- 3. Instanciação do CervoVisual e Calibração Geométrica ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)

	_assert(visual != null, "CervoVisual instanciado com sucesso")
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Estado inicial padrão é IDLE")
	_assert(visual.facing == 1, "Orientação inicial padrão é DIREITA (+1)")
	_assert(visual.display_scale == CervoVisual.DEFAULT_SCALE, "Escala padrão é %.2fx" % CervoVisual.DEFAULT_SCALE)
	_assert(visual.CELL_SIZE == Vector2(256.0, 256.0), "Dimensão de célula é 256x256 px")
	_assert(visual.PIVOT_HOOF == Vector2(128.0, 225.0), "Pivô dos cascos calibrado em (128, 225)")

	# Verifica total de quadros e looping
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.IDLE]["total_frames"] == 8, "Idle possui 8 quadros")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.IDLE]["loop"] == true, "Idle é em loop contínuo")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.WALK]["total_frames"] == 8, "Walk possui 8 quadros")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.WALK]["loop"] == true, "Walk é em loop contínuo")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.GALLOP]["total_frames"] == 12, "Gallop possui 12 quadros")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.GALLOP]["loop"] == true, "Gallop é em loop contínuo")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.TURN]["total_frames"] == 8, "Turn possui 8 quadros")
	_assert(visual.ANIM_CONFIG[CervoVisual.AnimState.TURN]["loop"] == false, "Turn é one-shot transitório")

	visual.queue_free()

func _test_04_animation_playback_and_transitions() -> void:
	print("\n--- 4. Reprodução e Transições de Animação ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.play(CervoVisual.AnimState.WALK)
	_assert(visual.current_state == CervoVisual.AnimState.WALK, "Transição para WALK bem-sucedida")
	_assert(visual.get_current_anim_name() == "walk", "Nome canônico da animação é 'walk'")
	_assert(visual.current_frame == 0, "Quadro inicial resetado para 0")

	visual.play(CervoVisual.AnimState.GALLOP)
	_assert(visual.current_state == CervoVisual.AnimState.GALLOP, "Transição para GALLOP bem-sucedida")
	_assert(visual.get_total_frames() == 12, "Total de quadros reportado para GALLOP é 12")

	visual.play_by_name("repouso")
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "play_by_name('repouso') seleciona IDLE")

	visual.play_by_name("galope")
	_assert(visual.current_state == CervoVisual.AnimState.GALLOP, "play_by_name('galope') seleciona GALLOP")

	visual.queue_free()

func _test_05_turn_animation_and_facing_inversion() -> void:
	print("\n--- 5. Animação de Virada e Inversão de Orientação ---")
	var visual: CervoVisual = CervoVisual.new()
	root.add_child(visual)
	await _frames(2)

	visual.facing = 1
	_assert(visual.facing == 1, "Orientação inicial: 1 (Direita)")

	# Inicia virada para esquerda
	visual.turn_to(-1)
	_assert(visual.current_state == CervoVisual.AnimState.TURN, "Iniciou estado TURN")
	_assert(visual._turn_initial_facing == 1, "Facing de início gravado como 1")

	# Simula o avanço dos 8 quadros de virada
	for _i in range(7):
		visual._advance_frame()
	_assert(visual.current_frame == 7, "Atingiu último quadro da virada (quadro 7)")

	# Avança além do último quadro para disparar conclusão da virada
	visual._advance_frame()
	_assert(visual.facing == -1, "Orientação invertida com sucesso para -1 (Esquerda)")
	_assert(visual.current_state == CervoVisual.AnimState.IDLE, "Retornou para IDLE após concluir virada")

	# Virada de volta para a direita
	visual.turn_to(1)
	_assert(visual.current_state == CervoVisual.AnimState.TURN, "Iniciou retorno TURN")
	_assert(visual._turn_initial_facing == -1, "Facing de início gravado como -1")
	for _i in range(8):
		visual._advance_frame()
	_assert(visual.facing == 1, "Orientação invertida de volta para 1 (Direita)")

	visual.queue_free()

func _test_06_preview_scene_instantiation() -> void:
	print("\n--- 6. Instanciação e Controles da Cena CervoPreview ---")
	var scene: PackedScene = load("res://scenes/dev/cervo_preview.tscn")
	_assert(scene != null, "Cena cervo_preview.tscn carregada com sucesso")

	var preview = scene.instantiate() as CervoPreview
	_assert(preview != null, "Instância de CervoPreview criada com sucesso")
	root.add_child(preview)
	await _frames(2)

	_assert(preview.cervo != null, "CervoVisual presente como filho de CervoPreview")
	_assert(preview.cervo.position.y == preview.FLOOR_Y, "Cervo posicionado exatamente no piso FLOOR_Y (%.1f)" % preview.FLOOR_Y)

	# Simula teclas de controle
	var key_event = InputEventKey.new()
	key_event.pressed = true

	# Alterna escala com tecla S
	key_event.keycode = KEY_S
	preview._unhandled_input(key_event)
	_assert(preview.cervo.display_scale == 0.50, "Tecla S alternou escala para 0.50x")
	preview._unhandled_input(key_event)
	_assert(preview.cervo.display_scale == 1.00, "Tecla S alternou escala para 1.00x")
	preview._unhandled_input(key_event)
	_assert(preview.cervo.display_scale == 0.38, "Tecla S ciclou escala de volta para 0.38x")

	# Alterna animações com teclas 2 e 3
	key_event.keycode = KEY_2
	preview._unhandled_input(key_event)
	_assert(preview.cervo.current_state == CervoVisual.AnimState.WALK, "Tecla 2 ativou WALK")

	key_event.keycode = KEY_3
	preview._unhandled_input(key_event)
	_assert(preview.cervo.current_state == CervoVisual.AnimState.GALLOP, "Tecla 3 ativou GALLOP")

	# Alterna movimentação com M
	key_event.keycode = KEY_M
	preview._unhandled_input(key_event)
	_assert(preview.moving_enabled == true, "Tecla M ativou movimentação lateral")
	preview._unhandled_input(key_event)
	_assert(preview.moving_enabled == false, "Tecla M desativou movimentação lateral")

	preview.queue_free()

func _test_07_no_premature_boss_combat_in_sector10() -> void:
	print("\n--- 7. Preservação de Escopo: Sem Instância Prematura no Setor 10 ---")
	var s10_scene: PackedScene = load("res://scenes/forest/sector_10.tscn")
	_assert(s10_scene != null, "Cena do Setor 10 carregada")
	var s10 = s10_scene.instantiate()
	root.add_child(s10)
	await _frames(2)

	# Setor 10 não deve conter nenhum nó de combate do chefe, hitboxes ativas ou IA
	var has_cervo_combat: bool = false
	for child in s10.get_children():
		var name_lower: String = child.name.to_lower()
		if "cervo" in name_lower or "boss" in name_lower or "spectral_deer" in name_lower:
			has_cervo_combat = true
			break

	_assert(not has_cervo_combat, "Setor 10 permanece sem instância prematura de chefe ou combate (escopo preservado)")
	s10.queue_free()
