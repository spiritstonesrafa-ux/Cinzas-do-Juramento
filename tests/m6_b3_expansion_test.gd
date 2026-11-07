extends SceneTree
## Suíte de testes funcionais e físicos para expansão M6-B3: Setores 7 e 8 da Floresta dos Ossos.

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
	print("SUÍTE DE TESTES M6-B3: EXPANSÃO SETORES 7 E 8")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_layout_eight_sectors()
	await _test_sector_scenes_instantiation()
	await _test_progressive_traversal_forward_and_backward()
	await _test_sector_7_vertebrae_traversal()
	await _test_sector_8_echo_grove_traversal()
	await _test_fall_recovery_all_sectors()
	await _test_camera_clamping_all_sectors()

	print("==================================================")
	print("RESULTADO FINAL M6-B3: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")

	if failed == 0:
		quit(0)
	else:
		quit(1)

func _test_layout_eight_sectors() -> void:
	print("\n--- Teste 1: Configuração dos 8 Setores no ForestLayout ---")
	if ForestLayout.ORIGINS.size() == 8:
		log_pass("ForestLayout possui exatamente 8 origens registradas")
	else:
		log_fail("Quantidade de origens inesperada: %d (esperado 8)" % ForestLayout.ORIGINS.size())

	if ForestLayout.NAMES.size() == 8:
		log_pass("ForestLayout possui 8 nomes definidos: %s" % str(ForestLayout.NAMES))
	else:
		log_fail("Quantidade de nomes inesperada: %d (esperado 8)" % ForestLayout.NAMES.size())

	if ForestLayout.NAMES[6] == "Fenda das Vértebras":
		log_pass("Setor 7 nomeado corretamente como 'Fenda das Vértebras'")
	else:
		log_fail("Nome do Setor 7 incorreto: %s" % ForestLayout.NAMES[6])

	if ForestLayout.NAMES[7] == "Bosque dos Ecos":
		log_pass("Setor 8 nomeado corretamente como 'Bosque dos Ecos'")
	else:
		log_fail("Nome do Setor 8 incorreto: %s" % ForestLayout.NAMES[7])

	var s6: Array[Rect2] = ForestLayout.surfaces(6)
	var s7: Array[Rect2] = ForestLayout.surfaces(7)
	if s6.size() >= 8:
		log_pass("Setor 7 possui %d superfícies definidas (chão + ramos)" % s6.size())
	else:
		log_fail("Setor 7 com superfícies insuficientes: %d" % s6.size())

	if s7.size() >= 8:
		log_pass("Setor 8 possui %d superfícies definidas (chão + ramos)" % s7.size())
	else:
		log_fail("Setor 8 com superfícies insuficientes: %d" % s7.size())

	# Verificação de desnível entre Setor 6 e Setor 7
	var s5_last_rect: Rect2 = ForestLayout.SECTOR_6_MAIN[-1]
	var s6_first_rect: Rect2 = ForestLayout.SECTOR_7_MAIN[0]
	if absf(s5_last_rect.position.y - s6_first_rect.position.y) < 0.01:
		log_pass("Transição Setor 6 -> Setor 7 nivelada perfeitamente em y=%.1f" % s6_first_rect.position.y)
	else:
		log_fail("Desnível na transição Setor 6 -> 7: S6 y=%.1f vs S7 y=%.1f" % [s5_last_rect.position.y, s6_first_rect.position.y])

	# Verificação de desnível entre Setor 7 e Setor 8
	var s6_last_rect: Rect2 = ForestLayout.SECTOR_7_MAIN[-1]
	var s7_first_rect: Rect2 = ForestLayout.SECTOR_8_MAIN[0]
	if absf(s6_last_rect.position.y - s7_first_rect.position.y) < 0.01:
		log_pass("Transição Setor 7 -> Setor 8 nivelada perfeitamente em y=%.1f" % s7_first_rect.position.y)
	else:
		log_fail("Desnível na transição Setor 7 -> 8: S7 y=%.1f vs S8 y=%.1f" % [s6_last_rect.position.y, s7_first_rect.position.y])

	# Verificação de passos de altura dentro do Setor 7 (todos <= 20 px)
	var max_step_s7: float = 0.0
	for i: int in range(ForestLayout.SECTOR_7_MAIN.size() - 1):
		var r1: Rect2 = ForestLayout.SECTOR_7_MAIN[i]
		var r2: Rect2 = ForestLayout.SECTOR_7_MAIN[i + 1]
		var step: float = absf(r2.position.y - r1.position.y)
		max_step_s7 = maxf(max_step_s7, step)
	if max_step_s7 <= 20.0:
		log_pass("Setor 7: degraus máximos entre plataformas = %.1f px (limite <= 20 px)" % max_step_s7)
	else:
		log_fail("Setor 7 possui degrau excessivo: %.1f px" % max_step_s7)

	# Verificação de passos de altura dentro do Setor 8 (todos <= 20 px)
	var max_step_s8: float = 0.0
	for i: int in range(ForestLayout.SECTOR_8_MAIN.size() - 1):
		var r1: Rect2 = ForestLayout.SECTOR_8_MAIN[i]
		var r2: Rect2 = ForestLayout.SECTOR_8_MAIN[i + 1]
		var step: float = absf(r2.position.y - r1.position.y)
		max_step_s8 = maxf(max_step_s8, step)
	if max_step_s8 <= 20.0:
		log_pass("Setor 8: degraus máximos entre plataformas = %.1f px (limite <= 20 px)" % max_step_s8)
	else:
		log_fail("Setor 8 possui degrau excessivo: %.1f px" % max_step_s8)

	# Verificação dos vãos (gaps)
	var gap_s7_w: float = ForestLayout.SECTOR_7_MAIN[3].position.x - ForestLayout.SECTOR_7_MAIN[2].end.x
	if gap_s7_w >= 45.0 and gap_s7_w <= 52.0:
		log_pass("Setor 7: Vão da Fenda das Vértebras = %.1f px (confortável para salto padrão)" % gap_s7_w)
	else:
		log_fail("Setor 7: Largura inesperada do vão: %.1f px" % gap_s7_w)

	var gap_s8_w: float = ForestLayout.SECTOR_8_MAIN[4].position.x - ForestLayout.SECTOR_8_MAIN[3].end.x
	if gap_s8_w >= 40.0 and gap_s8_w <= 50.0:
		log_pass("Setor 8: Vão do Bosque dos Ecos = %.1f px (confortável para salto padrão)" % gap_s8_w)
	else:
		log_fail("Setor 8: Largura inesperada do vão: %.1f px" % gap_s8_w)

func _test_sector_scenes_instantiation() -> void:
	print("\n--- Teste 2: Instanciação das Cenas dos Setores 7 e 8 ---")
	var scene7: PackedScene = load("res://scenes/forest/sector_07.tscn") as PackedScene
	if scene7 != null:
		var inst7: Node2D = scene7.instantiate() as Node2D
		root.add_child(inst7)
		if inst7 is ForestSector and inst7.sector_id == 6:
			log_pass("sector_07.tscn instanciado com ForestSector e sector_id=6")
		else:
			log_fail("sector_07.tscn com tipo ou sector_id incorreto")
		var art7: Node = inst7.get_node_or_null("Art")
		if art7 != null and art7 is ForestArt and art7.sector_id == 6:
			log_pass("sector_07.tscn possui nó Art com ForestArt configurado")
		else:
			log_fail("sector_07.tscn sem nó Art adequado")
		var geom7: Node = inst7.get_node_or_null("Geometry")
		if geom7 != null and geom7.get_child_count() >= 8:
			log_pass("sector_07.tscn gerou %d colisores físicos em Geometry" % geom7.get_child_count())
		else:
			log_fail("sector_07.tscn sem colisores adequados em Geometry")
		inst7.queue_free()
	else:
		log_fail("Falha ao carregar scenes/forest/sector_07.tscn")

	var scene8: PackedScene = load("res://scenes/forest/sector_08.tscn") as PackedScene
	if scene8 != null:
		var inst8: Node2D = scene8.instantiate() as Node2D
		root.add_child(inst8)
		if inst8 is ForestSector and inst8.sector_id == 7:
			log_pass("sector_08.tscn instanciado com ForestSector e sector_id=7")
		else:
			log_fail("sector_08.tscn com tipo ou sector_id incorreto")
		var art8: Node = inst8.get_node_or_null("Art")
		if art8 != null and art8 is ForestArt and art8.sector_id == 7:
			log_pass("sector_08.tscn possui nó Art com ForestArt configurado")
		else:
			log_fail("sector_08.tscn sem nó Art adequado")
		var geom8: Node = inst8.get_node_or_null("Geometry")
		if geom8 != null and geom8.get_child_count() >= 8:
			log_pass("sector_08.tscn gerou %d colisores físicos em Geometry" % geom8.get_child_count())
		else:
			log_fail("sector_08.tscn sem colisores adequados em Geometry")
		inst8.queue_free()
	else:
		log_fail("Falha ao carregar scenes/forest/sector_08.tscn")
	await process_frame

func _test_progressive_traversal_forward_and_backward() -> void:
	print("\n--- Teste 3: Travessia Progressiva Completa (1 -> 8 e 8 -> 1) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	if demo.checkpoints.size() == 8:
		log_pass("ForestDemo inicializou com exatamente 8 checkpoints (um por setor)")
	else:
		log_fail("Quantidade de checkpoints incorreta: %d (esperado 8)" % demo.checkpoints.size())

	# Transições progressivas para a frente (0 -> 1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 7)
	for next_room: int in range(1, 8):
		await demo.switch_room(next_room, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame
		if demo.current_room == next_room:
			log_pass("Avanço para Setor %d (%s) realizado com sucesso" % [next_room + 1, ForestLayout.NAMES[next_room]])
		else:
			log_fail("Falha ao avançar para Setor %d" % [next_room + 1])

	# Transições de retorno (7 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1 -> 0)
	for prev_room: int in range(6, -1, -1):
		await demo.switch_room(prev_room, true)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame
		if demo.current_room == prev_room:
			log_pass("Retorno para Setor %d (%s) realizado com sucesso" % [prev_room + 1, ForestLayout.NAMES[prev_room]])
		else:
			log_fail("Falha ao retornar para Setor %d" % [prev_room + 1])

	demo.queue_free()
	await process_frame

func _test_sector_7_vertebrae_traversal() -> void:
	print("\n--- Teste 4: Física, Travessia e Entradas Reais no Setor 7 (Fenda das Vértebras) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(6, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[6].x

	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada do Setor 7 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada do Setor 7: pos=%s" % str(hero.global_position))

	# 1. Travessia física do gap da Fenda das Vértebras (x: 480 -> 528, 48 px plano em y=260)
	hero.reset_to(Vector2(origin_x + 420.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped and local_x >= 470.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped and local_x >= 535.0 and hero.is_on_floor():
			gap_cleared = true
			break
	Input.action_release("move_right")
	Input.action_release("jump")

	if gap_cleared:
		log_pass("Vão de 48 px da Fenda das Vértebras transposto com salto seguro (aterrissou em x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Falha na transposição do vão da Fenda das Vértebras")

	# 2. Escalada para o terraço leste (x=678, y=240, subida 20 px)
	hero.reset_to(Vector2(origin_x + 640.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped_terrace: bool = false
	var terrace_reached: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped_terrace and local_x >= 668.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_terrace = true
		elif jumped_terrace and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= 710.0 and hero.is_on_floor() and absf(hero.global_position.y - 240.0) < 1.0:
			terrace_reached = true
			break
	Input.action_release("move_right")
	Input.action_release("jump")

	if terrace_reached:
		log_pass("Aren escalou para o terraço leste do Setor 7 (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Aren não conseguiu alcançar o terraço leste do Setor 7")

	# 3. Retorno no sentido Oeste (Leste -> Oeste, saltando o vão da fenda no sentido inverso)
	hero.reset_to(Vector2(origin_x + 560.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_left")
	var jumped_back: bool = false
	var gap_cleared_back: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped_back and local_x <= 538.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_back = true
		elif jumped_back and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped_back and local_x <= 470.0 and hero.is_on_floor():
			gap_cleared_back = true
			break
	Input.action_release("move_left")
	Input.action_release("jump")

	if gap_cleared_back:
		log_pass("Retorno: Vão da Fenda das Vértebras transposto de volta para o oeste (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Falha no retorno através do vão da Fenda das Vértebras")

	# 4. Verificação de solidez da margem leste até x=950
	hero.reset_to(Vector2(origin_x + 940.0, 240.0))
	for i in range(5):
		await physics_frame
	if hero.is_on_floor() and absf(hero.global_position.y - 240.0) < 1.0:
		log_pass("Margem leste do Setor 7 sólida e segura (x=940, y=240)")
	else:
		log_fail("Falha de colisão na margem leste do Setor 7")

	demo.queue_free()
	await process_frame

func _test_sector_8_echo_grove_traversal() -> void:
	print("\n--- Teste 5: Física, Travessia e Entradas Reais no Setor 8 (Bosque dos Ecos) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(7, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[7].x

	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada do Setor 8 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada do Setor 8: pos=%s" % str(hero.global_position))

	# 1. Travessia física do gap do Bosque dos Ecos (x: 520 -> 566, 46 px plano em y=260)
	hero.reset_to(Vector2(origin_x + 485.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped and local_x >= 505.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped and local_x >= 575.0 and hero.is_on_floor():
			gap_cleared = true
			break
	Input.action_release("move_right")
	Input.action_release("jump")

	if gap_cleared:
		log_pass("Vão de 46 px do Bosque dos Ecos transposto com salto seguro (aterrissou em x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Falha na transposição do vão do Bosque dos Ecos")

	# 2. Escalada para o terraço do Monólito dos Ecos (x=716, y=240, subida 20 px)
	hero.reset_to(Vector2(origin_x + 680.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped_terrace: bool = false
	var reached_monolith: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped_terrace and local_x >= 706.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_terrace = true
		elif jumped_terrace and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= 750.0 and hero.is_on_floor() and absf(hero.global_position.y - 240.0) < 1.0:
			reached_monolith = true
			break
	Input.action_release("move_right")
	Input.action_release("jump")

	if reached_monolith:
		log_pass("Aren alcançou o terraço do Monólito dos Ecos no Setor 8 (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Aren não alcançou o terraço do Monólito dos Ecos")

	# 3. Retorno no sentido Oeste (Leste -> Oeste, saltando o vão de raízes no sentido inverso)
	hero.reset_to(Vector2(origin_x + 600.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_left")
	var jumped_back: bool = false
	var gap_cleared_back: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped_back and local_x <= 576.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_back = true
		elif jumped_back and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped_back and local_x <= 510.0 and hero.is_on_floor():
			gap_cleared_back = true
			break
	Input.action_release("move_left")
	Input.action_release("jump")

	if gap_cleared_back:
		log_pass("Retorno: Vão do Bosque dos Ecos transposto de volta para o oeste (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Falha no retorno através do vão do Bosque dos Ecos")

	# 4. Verificação da margem leste até x=950 (fronteira preparada para futura expansão)
	hero.reset_to(Vector2(origin_x + 940.0, 240.0))
	for i in range(5):
		await physics_frame
	if hero.is_on_floor() and absf(hero.global_position.y - 240.0) < 1.0:
		log_pass("Margem leste do Setor 8 sólida e preparada (x=940, y=240)")
	else:
		log_fail("Falha de colisão na margem leste do Setor 8")

	demo.queue_free()
	await process_frame

func _test_fall_recovery_all_sectors() -> void:
	print("\n--- Teste 6: Recuperação de Queda em Todos os 8 Setores ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	for sector_idx: int in range(8):
		await demo.switch_room(sector_idx, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		# Força posição de queda (y = 440)
		demo.hero.global_position = ForestLayout.ORIGINS[sector_idx] + Vector2(300, 440)
		for f in range(5):
			await physics_frame

		var local_after: Vector2 = demo.hero.global_position - ForestLayout.ORIGINS[sector_idx]
		var entry_pos: Vector2 = ForestLayout.entry(sector_idx, false) - ForestLayout.ORIGINS[sector_idx]
		if local_after.distance_to(entry_pos) < 30.0:
			log_pass("Setor %d: Queda recuperada com sucesso para ponto seguro de entrada" % (sector_idx + 1))
		else:
			log_fail("Setor %d: Posição pós-queda incorreta: %s vs esperado %s" % [sector_idx + 1, str(local_after), str(entry_pos)])

	demo.queue_free()
	await process_frame

func _test_camera_clamping_all_sectors() -> void:
	print("\n--- Teste 7: Limites e Suavização de Câmera nos 8 Setores ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	for sector_idx: int in range(8):
		await demo.switch_room(sector_idx, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		var origin: Vector2 = ForestLayout.ORIGINS[sector_idx]
		var target: Vector2 = demo.camera_target()
		var local_target: Vector2 = target - origin

		if local_target.x >= 159.0 and local_target.x <= 801.0 and local_target.y >= 89.0 and local_target.y <= 331.0:
			log_pass("Setor %d: Câmera enquadra perfeitamente dentro dos limites da sala" % (sector_idx + 1))
		else:
			log_fail("Setor %d: Alvo de câmera fora dos limites: %s" % [sector_idx + 1, str(local_target)])

	demo.queue_free()
	await process_frame
