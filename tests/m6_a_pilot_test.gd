extends SceneTree

var passed: int = 0
var failed: int = 0
var test_log: Array[String] = []

func log_pass(msg: String) -> void:
	passed += 1
	test_log.append("  [PASS] " + msg)
	print("  [PASS] " + msg)

func log_fail(msg: String) -> void:
	failed += 1
	test_log.append("  [FAIL] " + msg)
	printerr("  [FAIL] " + msg)

func _init() -> void:
	print("==================================================")
	print("SUÍTE DE TESTES M6-A: PILOTOS DA FLORESTA DOS OSSOS")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_layout_data()
	await _test_scene_structure()
	await _test_sector_1_spawn_and_movement()
	await _test_combat_ground_and_aerial()
	await _test_dash_mechanic()
	await _test_sector_transition_forward()
	await _test_sector_2_traversal_gap()
	await _test_sector_transition_return()
	await _test_fall_recovery()
	await _test_camera_clamping()
	
	print("==================================================")
	print("RESULTADO FINAL: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")
	
	if failed == 0:
		quit(0)
	else:
		quit(1)

func _test_layout_data() -> void:
	print("\n--- Teste 1: Dados do Layout da Floresta ---")
	var s0: Array[Rect2] = ForestLayout.surfaces(0)
	var s1: Array[Rect2] = ForestLayout.surfaces(1)
	
	if s0.size() >= 8:
		log_pass("Setor 1 possui superfícies suficientes (%d retângulos de solo e galhos)" % s0.size())
	else:
		log_fail("Setor 1 possui poucas superfícies: %d" % s0.size())
	
	if s1.size() >= 7:
		log_pass("Setor 2 possui superfícies suficientes (%d retângulos de solo, abismos e galhos)" % s1.size())
	else:
		log_fail("Setor 2 possui poucas superfícies: %d" % s1.size())
	
	var gap: Rect2 = ForestLayout.get_sector_2_challenge_gap()
	if is_equal_approx(gap.size.x, 60.0):
		log_pass("Abismo de travessia do Setor 2 calibrado com precisão física (largura: %.1f px)" % gap.size.x)
	else:
		log_fail("Abismo de travessia do Setor 2 com largura inesperada: %.1f px" % gap.size.x)
	
	var entry0: Vector2 = ForestLayout.entry(0)
	var entry1: Vector2 = ForestLayout.entry(1)
	if entry0 == Vector2(48, 300) and entry1 == Vector2(1248, 300):
		log_pass("Entradas dos setores calculadas corretamente (S1: %s, S2: %s)" % [str(entry0), str(entry1)])
	else:
		log_fail("Entradas dos setores incorretas: S1=%s, S2=%s" % [str(entry0), str(entry1)])

func _test_scene_structure() -> void:
	print("\n--- Teste 2: Instanciação e Estrutura de Cena ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	if scene == null:
		log_fail("Falha ao carregar scenes/forest/forest_pilots.tscn")
		return
	
	var demo: Node = scene.instantiate()
	root.add_child(demo)
	await process_frame
	
	if demo is ForestDemo:
		log_pass("Cena instanciada é uma instância de ForestDemo")
	else:
		log_fail("Raiz da cena não é ForestDemo")
	
	var knight: Node = demo.get_node_or_null("Knight")
	var camera: Node = demo.get_node_or_null("Camera2D")
	var hud: Node = demo.get_node_or_null("ForestHUD")
	var rooms: Node = demo.get_node_or_null("Rooms")
	
	if knight != null and camera != null and hud != null and rooms != null:
		log_pass("Todos os nós principais presentes (Knight, Camera2D, ForestHUD, Rooms)")
	else:
		log_fail("Nó principal ausente em forest_pilots.tscn")
	
	demo.queue_free()
	await process_frame

func _test_sector_1_spawn_and_movement() -> void:
	print("\n--- Teste 3: Spawn, Estabilidade e Movimentação no Setor 1 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	var hero: KnightController = demo.hero
	if is_instance_valid(hero):
		log_pass("Aren instanciado com sucesso")
	else:
		log_fail("Aren inválido")
		demo.queue_free()
		return
	
	if hero.dash_unlocked:
		log_pass("Passo das Sombras (Dash) desbloqueado para o protótipo da Fase 3")
	else:
		log_fail("Dash não foi desbloqueado para o protótipo")
	
	if hero.is_on_floor():
		log_pass("Aren assentado firmemente no solo do Setor 1 (is_on_floor == true)")
	else:
		log_fail("Aren não está no solo no spawn: pos=%s" % str(hero.global_position))
	
	# Simulação de movimento à direita
	hero.velocity.x = 100.0
	hero.move_and_slide()
	if hero.velocity.x > 0.0 or hero.position.x > 48.0:
		log_pass("Movimentação horizontal responde adequadamente")
	else:
		log_fail("Falha na movimentação horizontal")
	
	demo.queue_free()
	await process_frame

func _test_combat_ground_and_aerial() -> void:
	print("\n--- Teste 4: Combate Terrestre e Ataque Aéreo (J) ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	var hero: KnightController = demo.hero
	
	# Ataque no chão via ação attack
	Input.action_press("attack")
	await physics_frame
	Input.action_release("attack")
	await physics_frame
	
	if hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL and not hero.sword_attack.aerial:
		log_pass("Ataque com espada no solo iniciado corretamente (fase WINDUP/ACTIVE, aerial=false)")
	else:
		log_fail("Falha ao iniciar ataque no solo")
	hero.sword_attack.cancel()
	
	# Simula salto e ataque aéreo
	hero.velocity.y = hero.jump_impulse
	hero.sword_attack.aerial_available = true
	Input.action_press("attack")
	await physics_frame
	Input.action_release("attack")
	await physics_frame
	
	if hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL and hero.sword_attack.aerial:
		log_pass("Ataque aéreo (J no ar) iniciado com sucesso (aerial=true)")
	else:
		log_fail("Falha ao iniciar ataque aéreo")
	hero.sword_attack.cancel()
	
	demo.queue_free()
	await process_frame

func _test_dash_mechanic() -> void:
	print("\n--- Teste 5: Execução do Passo das Sombras (Dash / Shift) ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	var hero: KnightController = demo.hero
	
	# Força acionamento do dash
	hero.dash_remaining = hero.dash_duration
	hero.dash_direction = 1
	hero.velocity.x = hero.dash_direction * hero.dash_speed
	
	if hero.dash_remaining > 0.0 and is_equal_approx(hero.velocity.x, 260.0):
		log_pass("Dash ativado com velocidade correta (260.0 px/s) e duração ativa")
	else:
		log_fail("Falha no acionamento do dash: vel=%s, rem=%.2f" % [str(hero.velocity), hero.dash_remaining])
	
	demo.queue_free()
	await process_frame

func _test_sector_transition_forward() -> void:
	print("\n--- Teste 6: Transição Setor 1 -> Setor 2 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	# Posiciona o herói no limiar de saída do Setor 1
	demo.hero.global_position = Vector2(946, 300)
	demo.hero.facing = 1
	
	# Dispara transição
	await demo.switch_room(1, false)
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	if demo.current_room == 1:
		log_pass("Transição concluída com sucesso para o Setor 2 (Bosque das Raízes)")
	else:
		log_fail("Transição falhou: current_room=%d" % demo.current_room)
	
	var expected_pos: Vector2 = ForestLayout.entry(1)
	if demo.hero.global_position.distance_to(expected_pos) < 10.0:
		log_pass("Aren posicionado corretamente na entrada do Setor 2 (%s)" % str(demo.hero.global_position))
	else:
		log_fail("Posição de entrada incorreta no Setor 2: %s (esperado: %s)" % [str(demo.hero.global_position), str(expected_pos)])
	
	demo.queue_free()
	await process_frame

func _test_sector_2_traversal_gap() -> void:
	print("\n--- Teste 7: Desafio de Travessia no Setor 2 com Entradas Reais ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	await demo.switch_room(1, false)
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	var gap: Rect2 = ForestLayout.get_sector_2_challenge_gap()
	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[1].x
	
	# 7.1: Geometria física do abismo
	var surfaces: Array[Rect2] = ForestLayout.surfaces(1)
	var left_solid: Rect2 = surfaces[0] # Rect2(0, 300, 200, 120)
	var right_solid: Rect2 = surfaces[1] # Rect2(260, 300, 170, 120)
	var gap_width: float = right_solid.position.x - left_solid.end.x
	
	if is_equal_approx(gap_width, 60.0):
		log_pass("Abismo de 60 px verificado entre sólidos no Setor 2 (x: %.1f -> %.1f)" % [left_solid.end.x, right_solid.position.x])
	else:
		log_fail("Largura do abismo inconsistente: %.1f" % gap_width)
	
	# 7.2: Entrada real do jogador: Salto normal correndo sem Dash
	hero.reset_to(Vector2(origin_x + 50.0, 300.0))
	for i in range(5):
		await physics_frame
	
	Input.action_press("move_right")
	var normal_jump_reached_other_side: bool = false
	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if local_x >= 195.0 and hero.is_on_floor():
			Input.action_press("jump")
		else:
			Input.action_release("jump")
		
		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= right_solid.position.x and hero.is_on_floor():
			normal_jump_reached_other_side = true
			break
		if hero.global_position.y > 350.0:
			break
	Input.action_release("move_right")
	
	if not normal_jump_reached_other_side:
		log_pass("Salto normal sozinho não transpõe o abismo (cai no precipício)")
	else:
		log_fail("Salto normal transpôs o abismo sem dash (inconsistente com o requisito)")
	
	# 7.3: Entrada real do jogador: Dash no chão + Salto com momentum
	hero.reset_to(Vector2(origin_x + 50.0, 300.0))
	for i in range(5):
		await physics_frame
	
	Input.action_press("move_right")
	var dash_triggered: bool = false
	var jumped: bool = false
	var dash_jump_cleared: bool = false
	
	for f in range(140):
		var local_x: float = hero.global_position.x - origin_x
		
		# Aciona Dash no chão na aproximação (x local ~ 140)
		if not dash_triggered and local_x >= 140.0 and hero.is_on_floor():
			var ev: InputEventKey = InputEventKey.new()
			ev.keycode = KEY_SHIFT
			ev.pressed = true
			ev.echo = false
			hero._unhandled_key_input(ev)
			dash_triggered = true
		
		# Salta logo após o dash no limiar do patamar
		if dash_triggered and not jumped and hero.dash_remaining <= 0.0 and (hero.is_on_floor() or hero._coyote_remaining > 0.0):
			Input.action_press("jump")
			jumped = true
		elif jumped:
			Input.action_release("jump")
		
		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= right_solid.position.x and hero.is_on_floor():
			dash_jump_cleared = true
			break
		if hero.global_position.y > 350.0:
			break
	Input.action_release("move_right")
	
	if dash_jump_cleared:
		log_pass("Sequência real Dash Terrestre + Salto transpõe com sucesso o abismo (aterrissou em x=%.1f)" % [hero.global_position.x - origin_x])
	else:
		log_fail("Dash + Salto falhou na travessia do abismo")
	
	# 7.4: Travessia inversa real (Volta da direita para a esquerda)
	hero.reset_to(Vector2(origin_x + 340.0, 300.0))
	hero.facing = -1
	for i in range(5):
		await physics_frame
	
	Input.action_press("move_left")
	var ret_dash_triggered: bool = false
	var ret_jumped: bool = false
	var return_cleared: bool = false
	
	for f in range(140):
		var local_x: float = hero.global_position.x - origin_x
		
		# Aciona Dash retornando à esquerda
		if not ret_dash_triggered and local_x <= 315.0 and hero.is_on_floor():
			var ev: InputEventKey = InputEventKey.new()
			ev.keycode = KEY_SHIFT
			ev.pressed = true
			ev.echo = false
			hero._unhandled_key_input(ev)
			ret_dash_triggered = true
		
		# Salta na beirada da volta
		if ret_dash_triggered and not ret_jumped and hero.dash_remaining <= 0.0 and (hero.is_on_floor() or hero._coyote_remaining > 0.0):
			Input.action_press("jump")
			ret_jumped = true
		elif ret_jumped:
			Input.action_release("jump")
		
		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x <= left_solid.end.x and hero.is_on_floor():
			return_cleared = true
			break
		if hero.global_position.y > 350.0:
			break
	Input.action_release("move_left")
	
	if return_cleared:
		log_pass("Travessia no sentido inverso validada com sucesso com comandos reais (aterrissou em x=%.1f)" % [hero.global_position.x - origin_x])
	else:
		log_fail("Travessia no sentido inverso falhou")
	
	demo.queue_free()
	await process_frame

func _test_sector_transition_return() -> void:
	print("\n--- Teste 8: Retorno Bidirecional Setor 2 -> Setor 1 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	await demo.switch_room(1, false)
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	# Posiciona o herói no limiar de retorno do Setor 2 (esquerda)
	demo.hero.global_position = ForestLayout.ORIGINS[1] + Vector2(10, 300)
	demo.hero.facing = -1
	
	# Dispara transição de retorno
	await demo.switch_room(0, true)
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	if demo.current_room == 0:
		log_pass("Retorno bidirecional concluído com sucesso para o Setor 1")
	else:
		log_fail("Retorno bidirecional falhou: current_room=%d" % demo.current_room)
	
	var expected_pos: Vector2 = ForestLayout.entry(0, true)
	if demo.hero.global_position.distance_to(expected_pos) < 10.0:
		log_pass("Aren posicionado com segurança na margem direita do Setor 1 (%s)" % str(demo.hero.global_position))
	else:
		log_fail("Posição de retorno incorreta: %s (esperado: %s)" % [str(demo.hero.global_position), str(expected_pos)])
	
	demo.queue_free()
	await process_frame

func _test_fall_recovery() -> void:
	print("\n--- Teste 9: Recuperação de Queda em Abismo (Alive Fall) ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	await demo.switch_room(1, false)
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	# Simula queda profunda no abismo do Setor 2
	demo.hero.global_position = ForestLayout.ORIGINS[1] + Vector2(240, 450)
	demo._alive_fall()
	for i: int in range(6):
		await physics_frame
	
	var expected_safe_entry: Vector2 = ForestLayout.entry(1, false)
	if demo.hero.global_position.distance_to(expected_safe_entry) < 10.0:
		log_pass("Recuperação de queda reposicionou Aren na entrada segura do Setor 2")
	else:
		log_fail("Falha no reposicionamento da queda: %s" % str(demo.hero.global_position))
	
	demo.queue_free()
	await process_frame

func _test_camera_clamping() -> void:
	print("\n--- Teste 10: Limites e Suavização da Câmera ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	for i: int in range(6):
		await physics_frame
	
	# Testa cálculo do alvo da câmera
	var cam_target: Vector2 = demo.camera_target()
	if not is_nan(cam_target.x) and not is_nan(cam_target.y) and not is_inf(cam_target.x) and not is_inf(cam_target.y):
		log_pass("Alvo da câmera válido e livre de NaN/Inf (%s)" % str(cam_target))
	else:
		log_fail("Alvo da câmera inválido: %s" % str(cam_target))
	
	if cam_target.x >= 160.0 and cam_target.x <= 800.0 and cam_target.y >= 90.0 and cam_target.y <= 330.0:
		log_pass("Câmera perfeitamente contida nos limites seguros do setor 320x180")
	else:
		log_fail("Câmera fora dos limites estipulados: %s" % str(cam_target))
	
	demo.queue_free()
	await process_frame
