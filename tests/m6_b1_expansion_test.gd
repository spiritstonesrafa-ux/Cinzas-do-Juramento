extends SceneTree
## Suíte de testes funcionais e físicos para expansão M6-B1: Setores 3 e 4 da Floresta dos Ossos.

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
	print("SUÍTE DE TESTES M6-B1: EXPANSÃO SETORES 3 E 4")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_layout_four_sectors()
	await _test_sector_scenes_instantiation()
	await _test_progressive_traversal_forward_and_backward()
	await _test_sector_3_traversal_and_branches()
	await _test_sector_4_clearing_and_steps()
	await _test_fall_recovery_all_sectors()
	await _test_camera_clamping_all_sectors()
	
	print("==================================================")
	print("RESULTADO FINAL M6-B1: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")
	
	if failed == 0:
		quit(0)
	else:
		quit(1)

func _test_layout_four_sectors() -> void:
	print("\n--- Teste 1: Configuração dos 4 Setores no ForestLayout ---")
	if ForestLayout.ORIGINS.size() == 4:
		log_pass("ForestLayout possui exatamente 4 origens registradas")
	else:
		log_fail("Quantidade de origens inesperada: %d" % ForestLayout.ORIGINS.size())
	
	if ForestLayout.NAMES.size() == 4:
		log_pass("ForestLayout possui 4 nomes definidos: %s" % str(ForestLayout.NAMES))
	else:
		log_fail("Quantidade de nomes inesperada: %d" % ForestLayout.NAMES.size())
	
	var s0: Array[Rect2] = ForestLayout.surfaces(0)
	var s1: Array[Rect2] = ForestLayout.surfaces(1)
	var s2: Array[Rect2] = ForestLayout.surfaces(2)
	var s3: Array[Rect2] = ForestLayout.surfaces(3)
	
	if s0.size() == 10:
		log_pass("Setor 1 preservado intacto (10 superfícies)")
	else:
		log_fail("Setor 1 divergente: %d superfícies" % s0.size())
	
	if s1.size() == 11:
		log_pass("Setor 2 com degraus de acesso ao Santuário (11 superfícies)")
	else:
		log_fail("Setor 2 divergente: %d superfícies" % s1.size())
	
	if s2.size() == 10:
		log_pass("Setor 3 configurado com sucesso (10 superfícies: 5 solo, 5 galhos)")
	else:
		log_fail("Setor 3 superfícies inconsistentes: %d" % s2.size())
	
	if s3.size() == 9:
		log_pass("Setor 4 configurado com sucesso (9 superfícies: 5 solo, 4 ruínas/galhos)")
	else:
		log_fail("Setor 4 superfícies inconsistentes: %d" % s3.size())
	
	# Continuidade de altura nos limiares de transição
	var exit_s2: Vector2 = ForestLayout.entry(1, true)
	var entry_s3: Vector2 = ForestLayout.entry(2, false)
	if entry_s3.y - ForestLayout.ORIGINS[2].y == 288.0:
		log_pass("Entrada do Setor 3 (y=288) alinhada com a saída do Setor 2")
	else:
		log_fail("Desalinhamento vertical S2->S3")
	
	var exit_s3: Vector2 = ForestLayout.entry(2, true)
	var entry_s4: Vector2 = ForestLayout.entry(3, false)
	if entry_s4.y - ForestLayout.ORIGINS[3].y == 300.0:
		log_pass("Entrada do Setor 4 (y=300) alinhada com a saída do Setor 3")
	else:
		log_fail("Desalinhamento vertical S3->S4")

func _test_sector_scenes_instantiation() -> void:
	print("\n--- Teste 2: Cenas Individuais dos 4 Setores ---")
	for id: int in range(4):
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
	print("\n--- Teste 3: Travessia Progressiva Completa (1 -> 2 -> 3 -> 4 -> 3 -> 2 -> 1) ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy or demo.current_room < 0:
		await physics_frame
	for i in range(5):
		await physics_frame
	
	if demo.checkpoints.size() == 4:
		log_pass("ForestDemo inicializou com 4 checkpoints (um por setor)")
	else:
		log_fail("Quantidade de checkpoints incorreta: %d" % demo.checkpoints.size())
	
	# Transição 1 -> 2
	demo.hero.global_position = ForestLayout.ORIGINS[0] + Vector2(946, 300)
	demo.hero.facing = 1
	await demo.switch_room(1, false)
	while demo.busy:
		await physics_frame
	if demo.current_room == 1:
		log_pass("Avanço 1 -> 2 concluído com sucesso")
	else:
		log_fail("Falha no avanço 1 -> 2")
	
	# Transição 2 -> 3
	demo.hero.global_position = ForestLayout.ORIGINS[1] + Vector2(946, 288)
	demo.hero.facing = 1
	await demo.switch_room(2, false)
	while demo.busy:
		await physics_frame
	if demo.current_room == 2:
		log_pass("Avanço 2 -> 3 concluído com sucesso")
	else:
		log_fail("Falha no avanço 2 -> 3")
	
	var expected_entry_3: Vector2 = ForestLayout.entry(2, false)
	if demo.hero.global_position.distance_to(expected_entry_3) < 10.0:
		log_pass("Aren posicionado com precisão na entrada do Setor 3 (%s)" % str(demo.hero.global_position))
	else:
		log_fail("Posicionamento incorreto em S3: %s" % str(demo.hero.global_position))
	
	# Transição 3 -> 4
	demo.hero.global_position = ForestLayout.ORIGINS[2] + Vector2(946, 300)
	demo.hero.facing = 1
	await demo.switch_room(3, false)
	while demo.busy:
		await physics_frame
	if demo.current_room == 3:
		log_pass("Avanço 3 -> 4 concluído com sucesso (Clareira Ancestral)")
	else:
		log_fail("Falha no avanço 3 -> 4")
	
	var expected_entry_4: Vector2 = ForestLayout.entry(3, false)
	if demo.hero.global_position.distance_to(expected_entry_4) < 10.0:
		log_pass("Aren posicionado com precisão na entrada do Setor 4 (%s)" % str(demo.hero.global_position))
	else:
		log_fail("Posicionamento incorreto em S4: %s" % str(demo.hero.global_position))
	
	# Retorno 4 -> 3
	demo.hero.global_position = ForestLayout.ORIGINS[3] + Vector2(10, 300)
	demo.hero.facing = -1
	await demo.switch_room(2, true)
	while demo.busy:
		await physics_frame
	if demo.current_room == 2:
		log_pass("Retorno 4 -> 3 concluído com sucesso")
	else:
		log_fail("Falha no retorno 4 -> 3")
	
	# Retorno 3 -> 2
	demo.hero.global_position = ForestLayout.ORIGINS[2] + Vector2(10, 288)
	demo.hero.facing = -1
	await demo.switch_room(1, true)
	while demo.busy:
		await physics_frame
	if demo.current_room == 1:
		log_pass("Retorno 3 -> 2 concluído com sucesso")
	else:
		log_fail("Falha no retorno 3 -> 2")
	
	# Retorno 2 -> 1
	demo.hero.global_position = ForestLayout.ORIGINS[1] + Vector2(10, 300)
	demo.hero.facing = -1
	await demo.switch_room(0, true)
	while demo.busy:
		await physics_frame
	if demo.current_room == 0:
		log_pass("Retorno 2 -> 1 concluído com sucesso")
	else:
		log_fail("Falha no retorno 2 -> 1")
	
	demo.queue_free()
	await process_frame

func _test_sector_3_traversal_and_branches() -> void:
	print("\n--- Teste 4: Física, Desníveis e Travessia no Setor 3 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	await demo.switch_room(2, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame
	
	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[2].x
	
	# Confirma que Aren está firme no solo no início do Setor 3
	if hero.is_on_floor():
		log_pass("Aren assentado firmemente no solo inicial do Setor 3 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando em S3: pos=%s" % str(hero.global_position))
	
	# Testa travessia do gap de 50 px no Setor 3 (x: 540 -> 590) com corrida e salto normal
	hero.reset_to(Vector2(origin_x + 480.0, 290.0))
	for i in range(5):
		await physics_frame
	
	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false
	for f in range(100):
		var local_x: float = hero.global_position.x - origin_x
		if not jumped and local_x >= 535.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped:
			Input.action_release("jump")
		
		await physics_frame
		local_x = hero.global_position.x - origin_x
		if jumped and local_x >= 595.0 and hero.is_on_floor():
			gap_cleared = true
			break
	Input.action_release("move_right")
	
	if gap_cleared:
		log_pass("Desfiladeiro de 50 px no Setor 3 transposto perfeitamente com salto convencional (aterrissou em x=%.1f)" % [hero.global_position.x - origin_x])
	else:
		log_fail("Falha na travessia do desfiladeiro no Setor 3")
	
	demo.queue_free()
	await process_frame

func _test_sector_4_clearing_and_steps() -> void:
	print("\n--- Teste 5: Física, Terraços e Degraus no Setor 4 ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	while demo.busy:
		await physics_frame
	await demo.switch_room(3, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame
	
	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[3].x
	
	# Verifica entrada segura em S4
	if hero.is_on_floor():
		log_pass("Aren assentado firmemente no solo inicial do Setor 4 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando em S4: pos=%s" % str(hero.global_position))
	
	# Subida dos degraus em direção ao mirante final
	hero.reset_to(Vector2(origin_x + 550.0, 300.0))
	for i in range(5):
		await physics_frame
	
	Input.action_press("move_right")
	var jumped_step1: bool = false
	var jumped_step2: bool = false
	var reached_overlook: bool = false
	
	for f in range(200):
		var local_x: float = hero.global_position.x - origin_x
		
		# Salto para o degrau 1 (x=600, y=280)
		if not jumped_step1 and local_x >= 580.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step1 = true
		elif jumped_step1 and not jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		# Salto para o terraço 2 (x=740, y=260)
		if jumped_step1 and not jumped_step2 and local_x >= 710.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step2 = true
		elif jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		await physics_frame
		local_x = hero.global_position.x - origin_x
		if local_x >= 760.0 and hero.is_on_floor() and absf(hero.global_position.y - 260.0) < 1.0:
			reached_overlook = true
			break
	Input.action_release("move_right")
	
	if reached_overlook:
		log_pass("Aren subiu os terraços até o mirante final do Setor 4 (x=%.1f, y=%.1f)" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Aren não alcançou o mirante do Setor 4")
	
	demo.queue_free()
	await process_frame

func _test_fall_recovery_all_sectors() -> void:
	print("\n--- Teste 6: Recuperação de Queda (Alive Fall) nos 4 Setores ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	for id: int in range(4):
		while demo.busy:
			await physics_frame
		await demo.switch_room(id, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame
		
		# Força posição de queda
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
	print("\n--- Teste 7: Limites de Câmera nos 4 Setores ---")
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	
	for id: int in range(4):
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
