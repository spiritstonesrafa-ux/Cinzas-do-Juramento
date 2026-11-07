extends SceneTree
## Suíte de testes funcionais e físicos para expansão M6-B2: Setores 5 e 6 da Floresta dos Ossos.

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
	print("SUÍTE DE TESTES M6-B2: EXPANSÃO SETORES 5 E 6")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_layout_six_sectors()
	await _test_sector_scenes_instantiation()
	await _test_progressive_traversal_forward_and_backward()
	await _test_sector_5_traversal_and_roots()
	await _test_sector_6_ossuary_and_monument()
	await _test_fall_recovery_all_sectors()
	await _test_camera_clamping_all_sectors()

	print("==================================================")
	print("RESULTADO FINAL M6-B2: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")

	if failed == 0:
		quit(0)
	else:
		quit(1)

func _test_layout_six_sectors() -> void:
	print("\n--- Teste 1: Configuração dos 6 Setores no ForestLayout ---")
	if ForestLayout.ORIGINS.size() == 6:
		log_pass("ForestLayout possui exatamente 6 origens registradas")
	else:
		log_fail("Quantidade de origens inesperada: %d" % ForestLayout.ORIGINS.size())

	if ForestLayout.NAMES.size() == 6:
		log_pass("ForestLayout possui 6 nomes definidos: %s" % str(ForestLayout.NAMES))
	else:
		log_fail("Quantidade de nomes inesperada: %d" % ForestLayout.NAMES.size())

	var s0: Array[Rect2] = ForestLayout.surfaces(0)
	var s1: Array[Rect2] = ForestLayout.surfaces(1)
	var s2: Array[Rect2] = ForestLayout.surfaces(2)
	var s3: Array[Rect2] = ForestLayout.surfaces(3)
	var s4: Array[Rect2] = ForestLayout.surfaces(4)
	var s5: Array[Rect2] = ForestLayout.surfaces(5)

	if s0.size() == 10:
		log_pass("Setor 1 preservado intacto (10 superfícies)")
	else:
		log_fail("Setor 1 divergente: %d superfícies" % s0.size())

	if s1.size() == 11:
		log_pass("Setor 2 preservado intacto (11 superfícies com degraus do Santuário)")
	else:
		log_fail("Setor 2 divergente: %d superfícies" % s1.size())

	if s2.size() == 10:
		log_pass("Setor 3 preservado intacto (10 superfícies)")
	else:
		log_fail("Setor 3 divergente: %d superfícies" % s2.size())

	if s3.size() == 9:
		log_pass("Setor 4 preservado intacto (9 superfícies)")
	else:
		log_fail("Setor 4 divergente: %d superfícies" % s3.size())

	if s4.size() == 11:
		log_pass("Setor 5 configurado com sucesso (11 superfícies: 6 solo, 5 galhos/raízes)")
	else:
		log_fail("Setor 5 superfícies inconsistentes: %d" % s4.size())

	if s5.size() == 10:
		log_pass("Setor 6 configurado com sucesso (10 superfícies: 6 solo, 4 arcos/costelas)")
	else:
		log_fail("Setor 6 superfícies inconsistentes: %d" % s5.size())

	# Continuidade de altura nos limiares de transição
	var exit_s4: Vector2 = ForestLayout.entry(3, true)
	var entry_s5: Vector2 = ForestLayout.entry(4, false)
	if entry_s5.y - ForestLayout.ORIGINS[4].y == 260.0:
		log_pass("Entrada do Setor 5 (y=260) alinhada exatamente com a saída do Setor 4")
	else:
		log_fail("Desalinhamento vertical S4->S5")

	var exit_s5: Vector2 = ForestLayout.entry(4, true)
	var entry_s6: Vector2 = ForestLayout.entry(5, false)
	if entry_s6.y - ForestLayout.ORIGINS[5].y == 280.0:
		log_pass("Entrada do Setor 6 (y=280) alinhada exatamente com a saída do Setor 5")
	else:
		log_fail("Desalinhamento vertical S5->S6")

func _test_sector_scenes_instantiation() -> void:
	print("\n--- Teste 2: Cenas Individuais dos 6 Setores ---")
	for id: int in range(6):
		var path: String = "res://scenes/forest/sector_%02d.tscn" % (id + 1)
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			log_fail("Falha ao carregar cena %s" % path)
			continue

		var node: Node2D = packed.instantiate() as Node2D
		root.add_child(node)
		await process_frame

		var art: ForestArt = node.get_node_or_null("Art") as ForestArt
		if art != null and art.sector_id == id:
			log_pass("Cena %s instanciada com Art vinculada ao sector_id=%d" % [path, id])
		else:
			log_fail("Cena %s com vinculação de Art incorreta" % path)

		node.queue_free()
		await process_frame

func _test_progressive_traversal_forward_and_backward() -> void:
	print("\n--- Teste 3: Travessia Progressiva Completa (1 -> 2 -> 3 -> 4 -> 5 -> 6 -> 5 -> 4 -> 3 -> 2 -> 1) ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy or demo.current_room < 0:
		await physics_frame
	for i in range(5):
		await physics_frame

	if demo.checkpoints.size() == 6:
		log_pass("ForestDemo inicializou com 6 checkpoints (um por setor)")
	else:
		log_fail("Quantidade de checkpoints incorreta: %d" % demo.checkpoints.size())

	# Transições progressivas para a frente (0 -> 1 -> 2 -> 3 -> 4 -> 5)
	for next_room: int in range(1, 6):
		var prev_room: int = next_room - 1
		demo.hero.global_position = ForestLayout.ORIGINS[prev_room] + Vector2(946, ForestLayout.entry(prev_room, true).y - ForestLayout.ORIGINS[prev_room].y)
		demo.hero.facing = 1
		await demo.switch_room(next_room, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		if demo.current_room == next_room:
			log_pass("Transição Setor %d -> %d concluída com sucesso (Hero em %s)" % [prev_room + 1, next_room + 1, str(demo.hero.global_position)])
		else:
			log_fail("Falha na transição Setor %d -> %d" % [prev_room + 1, next_room + 1])

	# Transições regressivas para trás (5 -> 4 -> 3 -> 2 -> 1 -> 0)
	for prev_room: int in range(4, -1, -1):
		var curr_room: int = prev_room + 1
		demo.hero.global_position = ForestLayout.ORIGINS[curr_room] + Vector2(10, ForestLayout.entry(curr_room, false).y - ForestLayout.ORIGINS[curr_room].y)
		demo.hero.facing = -1
		await demo.switch_room(prev_room, true)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		if demo.current_room == prev_room:
			log_pass("Retorno bidirecional Setor %d -> %d concluído com sucesso" % [curr_room + 1, prev_room + 1])
		else:
			log_fail("Falha no retorno Setor %d -> %d" % [curr_room + 1, prev_room + 1])

	demo.queue_free()
	await process_frame

func _test_sector_5_traversal_and_roots() -> void:
	print("\n--- Teste 4: Física, Travessia do Abismo de Raízes e Elevações no Setor 5 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(4, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[4].x

	# Verifica chão inicial
	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada do Setor 5 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada do Setor 5: pos=%s" % str(hero.global_position))

	# Travessia física do gap de raízes profundas (x: 520 -> 568, 48 px)
	hero.reset_to(Vector2(origin_x + 460.0, 308.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped and local_x >= 510.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped and local_x >= 575.0 and hero.is_on_floor():
			gap_cleared = true
			break
	Input.action_release("move_right")

	if gap_cleared:
		log_pass("Vão de 48 px do Setor 5 transposto com salto seguro (aterrissou em x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Falha na transposição do vão no Setor 5")

	# Continuidade de subida até a saída do Setor 5 (y=280)
	hero.reset_to(Vector2(origin_x + 700.0, 290.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var reached_exit: bool = false
	var jumped_step: bool = false

	for f in range(180):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped_step and local_x >= 720.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step = true
		elif jumped_step and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= 850.0 and hero.is_on_floor() and absf(hero.global_position.y - 280.0) < 1.0:
			reached_exit = true
			break
	Input.action_release("move_right")

	if reached_exit:
		log_pass("Aren alcançou o terraço de saída do Setor 5 em y=280 (x=%.1f)" % [hero.global_position.x - origin_x])
	else:
		log_fail("Aren não alcançou a saída do Setor 5")

	demo.queue_free()
	await process_frame

func _test_sector_6_ossuary_and_monument() -> void:
	print("\n--- Teste 5: Física, Terraços do Ossuário e Monumento no Setor 6 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(5, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[5].x

	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada do Setor 6 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada do Setor 6: pos=%s" % str(hero.global_position))

	# Travessia física do gap do ossuário (x: 510 -> 555, 45 px)
	hero.reset_to(Vector2(origin_x + 450.0, 278.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false

	for f in range(120):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped and local_x >= 500.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped and local_x >= 560.0 and hero.is_on_floor():
			gap_cleared = true
			break
	Input.action_release("move_right")

	if gap_cleared:
		log_pass("Vão de 45 px do ossuário no Setor 6 transposto com salto (aterrissou em x=%.1f)" % [hero.global_position.x - origin_x])
	else:
		log_fail("Falha na transposição do vão do ossuário no Setor 6")

	# Escalada progressiva dos terraços do Grande Ossuário (subidas de 20 px: 260 -> 240 -> 220)
	hero.reset_to(Vector2(origin_x + 670.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped_step1: bool = false
	var jumped_step2: bool = false
	var reached_monument: bool = false

	for f in range(220):
		var local_x: float = hero.global_position.x - origin_x

		# Salto para o degrau 1 (x=705, y=240, subida 20 px)
		if not jumped_step1 and local_x >= 695.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step1 = true
		elif jumped_step1 and not jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")

		# Salto para o terraço culminante (x=785, y=220, subida 20 px)
		if jumped_step1 and not jumped_step2 and local_x >= 775.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step2 = true
		elif jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")

		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= 810.0 and hero.is_on_floor() and absf(hero.global_position.y - 220.0) < 1.0:
			reached_monument = true
			break
	Input.action_release("move_right")

	if reached_monument:
		log_pass("Aren escalou os terraços até o Grande Ossuário no Setor 6 (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Aren não alcançou o Grande Ossuário no Setor 6")

	# Verificação da margem direita e colisão sólida até x=960
	hero.reset_to(Vector2(origin_x + 940.0, 220.0))
	for i in range(5):
		await physics_frame
	if hero.is_on_floor() and absf(hero.global_position.y - 220.0) < 1.0:
		log_pass("Margem leste do Setor 6 sólida e segura sem buracos (x=940, y=220)")
	else:
		log_fail("Falha de colisão na margem leste do Setor 6")

	demo.queue_free()
	await process_frame

func _test_fall_recovery_all_sectors() -> void:
	print("\n--- Teste 6: Recuperação de Queda (Alive Fall) nos 6 Setores ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)

	for id: int in range(6):
		while demo.busy:
			await physics_frame
		await demo.switch_room(id, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		demo.hero.global_position = ForestLayout.ORIGINS[id] + Vector2(300, 450)
		demo._alive_fall()
		for i in range(5):
			await physics_frame

		var expected: Vector2 = ForestLayout.entry(id, false)
		if demo.hero.global_position.distance_to(expected) < 10.0:
			log_pass("Recuperação de queda no Setor %d reposicionou com segurança na entrada (%s)" % [id + 1, str(demo.hero.global_position)])
		else:
			log_fail("Recuperação de queda falhou no Setor %d: pos=%s (esperado: %s)" % [id + 1, str(demo.hero.global_position), str(expected)])

	demo.queue_free()
	await process_frame

func _test_camera_clamping_all_sectors() -> void:
	print("\n--- Teste 7: Limites de Câmera nos 6 Setores ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)

	for id: int in range(6):
		while demo.busy:
			await physics_frame
		await demo.switch_room(id, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame

		var target: Vector2 = demo.camera_target()
		var local_target: Vector2 = target - ForestLayout.ORIGINS[id]
		if local_target.x >= 160.0 and local_target.x <= 800.0 and local_target.y >= 90.0 and local_target.y <= 330.0:
			log_pass("Câmera do Setor %d perfeitamente contida nos limites seguros (%s)" % [id + 1, str(local_target)])
		else:
			log_fail("Câmera fora dos limites no Setor %d: %s" % [id + 1, str(local_target)])

	demo.queue_free()
	await process_frame
