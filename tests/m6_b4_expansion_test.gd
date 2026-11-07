extends SceneTree
## Suíte de testes funcionais e físicos para expansão M6-B4: Setores 9 e 10 da Floresta dos Ossos.
## Valida a conclusão estrutural dos 10 setores da Fase 3, travessia bidirecional e futura arena do Cervo.

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
	print("SUÍTE DE TESTES M6-B4: EXPANSÃO SETORES 9 E 10")
	print("Conclusão Estrutural da Floresta dos Ossos (10 Setores)")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_layout_ten_sectors()
	await _test_sector_scenes_instantiation()
	await _test_progressive_traversal_forward_and_backward()
	await _test_sector_9_ravine_traversal()
	await _test_sector_10_arena_traversal()
	await _test_sector_9_and_10_platforms()
	await _test_fall_recovery_all_sectors()
	await _test_camera_clamping_all_sectors()
	await _test_no_premature_completion_and_boss_arena_state()

	print("==================================================")
	print("RESULTADO FINAL M6-B4: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")

	if failed == 0:
		quit(0)
	else:
		quit(1)

func _test_layout_ten_sectors() -> void:
	print("\n--- Teste 1: Configuração dos 10 Setores no ForestLayout ---")
	if ForestLayout.ORIGINS.size() == 10:
		log_pass("ForestLayout possui exatamente 10 origens registradas")
	else:
		log_fail("Quantidade de origens inesperada: %d (esperado 10)" % ForestLayout.ORIGINS.size())

	if ForestLayout.NAMES.size() == 10:
		log_pass("ForestLayout possui 10 nomes definidos: %s" % str(ForestLayout.NAMES))
	else:
		log_fail("Quantidade de nomes inesperada: %d (esperado 10)" % ForestLayout.NAMES.size())

	if ForestLayout.NAMES[8] == "Ravina das Sombras Fósseis":
		log_pass("Setor 9 nomeado corretamente como 'Ravina das Sombras Fósseis'")
	else:
		log_fail("Nome do Setor 9 incorreto: %s" % ForestLayout.NAMES[8])

	if ForestLayout.NAMES[9] == "Clareira da Bruma Espectral":
		log_pass("Setor 10 nomeado corretamente como 'Clareira da Bruma Espectral'")
	else:
		log_fail("Nome do Setor 10 incorreto: %s" % ForestLayout.NAMES[9])

	var s8_surfaces: Array[Rect2] = ForestLayout.surfaces(8)
	var s9_surfaces: Array[Rect2] = ForestLayout.surfaces(9)
	if s8_surfaces.size() >= 10:
		log_pass("Setor 9 possui %d superfícies definidas (chão + ramos)" % s8_surfaces.size())
	else:
		log_fail("Setor 9 com superfícies insuficientes: %d" % s8_surfaces.size())

	if s9_surfaces.size() >= 8:
		log_pass("Setor 10 possui %d superfícies definidas (chão de arena + ramos)" % s9_surfaces.size())
	else:
		log_fail("Setor 10 com superfícies insuficientes: %d" % s9_surfaces.size())

	# Verificação de desnível entre Setor 8 e Setor 9 (ambos em y=240)
	var s7_last_rect: Rect2 = ForestLayout.SECTOR_8_MAIN[-1]
	var s8_first_rect: Rect2 = ForestLayout.SECTOR_9_MAIN[0]
	if absf(s7_last_rect.position.y - s8_first_rect.position.y) < 0.01:
		log_pass("Transição Setor 8 -> Setor 9 nivelada perfeitamente em y=%.1f" % s8_first_rect.position.y)
	else:
		log_fail("Desnível na transição Setor 8 -> 9: S8 y=%.1f vs S9 y=%.1f" % [s7_last_rect.position.y, s8_first_rect.position.y])

	# Verificação de desnível entre Setor 9 e Setor 10 (ambos em y=260)
	var s8_last_rect: Rect2 = ForestLayout.SECTOR_9_MAIN[-1]
	var s9_first_rect: Rect2 = ForestLayout.SECTOR_10_MAIN[0]
	if absf(s8_last_rect.position.y - s9_first_rect.position.y) < 0.01:
		log_pass("Transição Setor 9 -> Setor 10 nivelada perfeitamente em y=%.1f" % s9_first_rect.position.y)
	else:
		log_fail("Desnível na transição Setor 9 -> 10: S9 y=%.1f vs S10 y=%.1f" % [s8_last_rect.position.y, s9_first_rect.position.y])

	# Verificação de passos de altura dentro do Setor 9 (todos <= 20 px)
	var max_step_s9: float = 0.0
	for i: int in range(ForestLayout.SECTOR_9_MAIN.size() - 1):
		var r1: Rect2 = ForestLayout.SECTOR_9_MAIN[i]
		var r2: Rect2 = ForestLayout.SECTOR_9_MAIN[i + 1]
		var step: float = absf(r2.position.y - r1.position.y)
		if step > max_step_s9:
			max_step_s9 = step
	if max_step_s9 <= 20.0:
		log_pass("Setor 9: Degraus verticais suaves no relevo (passo máximo = %.1f px <= 20 px)" % max_step_s9)
	else:
		log_fail("Setor 9: Degrau muito íngreme no relevo: %.1f px" % max_step_s9)

	# Verificação da arena no Setor 10 (chão contínuo e plano em y=260 de x: 0 a 960)
	var s10_total_width: float = 0.0
	var s10_all_at_260: bool = true
	for r: Rect2 in ForestLayout.SECTOR_10_MAIN:
		s10_total_width += r.size.x
		if absf(r.position.y - 260.0) >= 0.01:
			s10_all_at_260 = false
	if s10_total_width >= 960.0 and s10_all_at_260:
		log_pass("Setor 10: Chão plano contínuo para combate de chefe (largura=%.1f px, y=260.0)" % s10_total_width)
	else:
		log_fail("Setor 10: Geometria do chão da arena inadequada: largura=%.1f, y_valido=%s" % [s10_total_width, str(s10_all_at_260)])

	# Verificação de gaps no caminho principal do Setor 9 (o vão central da ravina tem 46 px, perfeitamente transponível)
	var s9_gap_r1: Rect2 = ForestLayout.SECTOR_9_MAIN[2]
	var s9_gap_r2: Rect2 = ForestLayout.SECTOR_9_MAIN[3]
	var s9_gap_width: float = s9_gap_r2.position.x - (s9_gap_r1.position.x + s9_gap_r1.size.x)
	if s9_gap_width > 0.0 and s9_gap_width <= 50.0:
		log_pass("Setor 9: Vão da ravina projetado com %.1f px de largura (limite do salto básico = 54 px)" % s9_gap_width)
	else:
		log_fail("Setor 9: Vão da ravina com largura inadequada: %.1f px" % s9_gap_width)

func _test_sector_scenes_instantiation() -> void:
	print("\n--- Teste 2: Instanciação das Cenas dos Setores 9 e 10 ---")
	var scene9: PackedScene = load("res://scenes/forest/sector_09.tscn") as PackedScene
	if scene9 != null:
		var inst9: Node2D = scene9.instantiate() as Node2D
		root.add_child(inst9)
		if inst9 is ForestSector and inst9.sector_id == 8:
			log_pass("sector_09.tscn instanciado com ForestSector e sector_id=8")
		else:
			log_fail("sector_09.tscn com tipo ou sector_id incorreto")
		var art9: Node = inst9.get_node_or_null("Art")
		if art9 != null and art9 is ForestArt and art9.sector_id == 8:
			log_pass("sector_09.tscn possui nó Art com ForestArt configurado")
		else:
			log_fail("sector_09.tscn sem nó Art adequado")
		var geom9: Node = inst9.get_node_or_null("Geometry")
		if geom9 != null and geom9.get_child_count() >= 10:
			log_pass("sector_09.tscn gerou %d colisores físicos em Geometry" % geom9.get_child_count())
		else:
			log_fail("sector_09.tscn sem colisores adequados em Geometry")
		inst9.queue_free()
	else:
		log_fail("Falha ao carregar scenes/forest/sector_09.tscn")
	await process_frame

	var scene10: PackedScene = load("res://scenes/forest/sector_10.tscn") as PackedScene
	if scene10 != null:
		var inst10: Node2D = scene10.instantiate() as Node2D
		root.add_child(inst10)
		if inst10 is ForestSector and inst10.sector_id == 9:
			log_pass("sector_10.tscn instanciado com ForestSector e sector_id=9")
		else:
			log_fail("sector_10.tscn com tipo ou sector_id incorreto")
		var art10: Node = inst10.get_node_or_null("Art")
		if art10 != null and art10 is ForestArt and art10.sector_id == 9:
			log_pass("sector_10.tscn possui nó Art com ForestArt configurado")
		else:
			log_fail("sector_10.tscn sem nó Art adequado")
		var geom10: Node = inst10.get_node_or_null("Geometry")
		if geom10 != null and geom10.get_child_count() >= 8:
			log_pass("sector_10.tscn gerou %d colisores físicos em Geometry" % geom10.get_child_count())
		else:
			log_fail("sector_10.tscn sem colisores adequados em Geometry")
		inst10.queue_free()
	else:
		log_fail("Falha ao carregar scenes/forest/sector_10.tscn")
	await process_frame

func _test_progressive_traversal_forward_and_backward() -> void:
	print("\n--- Teste 3: Travessia Progressiva Contínua dos 10 Setores (1 -> 10 e 10 -> 1) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	if demo.checkpoints.size() == 10:
		log_pass("ForestDemo inicializou com exatamente 10 checkpoints (um por setor)")
	else:
		log_fail("Quantidade de checkpoints incorreta: %d (esperado 10)" % demo.checkpoints.size())

	# Transições progressivas para a frente (0 -> 1 -> ... -> 9)
	for next_room: int in range(1, 10):
		await demo.switch_room(next_room, false)
		while demo.busy:
			await physics_frame
		for i in range(5):
			await physics_frame
		if demo.current_room == next_room:
			log_pass("Avanço para Setor %d (%s) realizado com sucesso" % [next_room + 1, ForestLayout.NAMES[next_room]])
		else:
			log_fail("Falha ao avançar para Setor %d" % [next_room + 1])

	# No Setor 10 (sala índice 9), a demo NÃO deve sinalizar completed = true (conclusão prematura eliminada no FIX01)
	if not demo.completed:
		log_pass("Setor 10 alcançado com demo.completed == false (sem conclusão prematura sem derrotar o chefe)")
	else:
		log_fail("Setor 10 ativou demo.completed indevidamente (conclusão prematura)")

	# Transições de retorno (9 -> 8 -> ... -> 0)
	for prev_room: int in range(8, -1, -1):
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

func _test_sector_9_ravine_traversal() -> void:
	print("\n--- Teste 4: Física, Travessia e Entradas Reais no Setor 9 (Ravina das Sombras Fósseis) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(8, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[8].x

	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada do Setor 9 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada do Setor 9: pos=%s" % str(hero.global_position))

	# 1. Travessia física do gap da Ravina (x: 460 -> 506, 46 px plano em y=280) - IDA
	hero.reset_to(Vector2(origin_x + 400.0, 280.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var jumped: bool = false
	var gap_cleared: bool = false

	for f in range(120):
		await physics_frame
		var lx: float = hero.global_position.x - origin_x
		if lx >= 452.0 and lx <= 458.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped and hero.velocity.y < 0.0:
			Input.action_release("jump")
			jumped = false
		if lx >= 530.0 and hero.is_on_floor():
			gap_cleared = true
			break

	Input.action_release("move_right")
	Input.action_release("jump")

	if gap_cleared:
		log_pass("Setor 9: Travessia física do Vão da Ravina (Ida Leste) concluída em x=%.1f, y=%.1f" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Setor 9: Falha na travessia física do vão da ravina: pos=%s" % str(hero.global_position))

	# 2. Travessia física do gap da Ravina - VOLTA
	hero.reset_to(Vector2(origin_x + 550.0, 280.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_left")
	jumped = false
	gap_cleared = false

	for f in range(120):
		await physics_frame
		var lx: float = hero.global_position.x - origin_x
		if lx <= 512.0 and lx >= 506.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped and hero.velocity.y < 0.0:
			Input.action_release("jump")
			jumped = false
		if lx <= 440.0 and hero.is_on_floor():
			gap_cleared = true
			break

	Input.action_release("move_left")
	Input.action_release("jump")

	if gap_cleared:
		log_pass("Setor 9: Retorno físico do Vão da Ravina (Volta Oeste) concluído em x=%.1f, y=%.1f" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Setor 9: Falha no retorno físico do vão da ravina para o oeste: pos=%s" % str(hero.global_position))

	# 3. Subida do terraço de saída e transição física para o Setor 10
	hero.reset_to(Vector2(origin_x + 630.0, 280.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	jumped = false
	var reached_exit: bool = false

	for f in range(250):
		await physics_frame
		var lx: float = hero.global_position.x - origin_x
		if (lx >= 644.0 and lx <= 652.0) and hero.is_on_floor():
			Input.action_press("jump")
			jumped = true
		elif jumped and hero.velocity.y < 0.0:
			Input.action_release("jump")
			jumped = false
		if demo.current_room == 9 or (demo.current_room == 8 and lx >= 940.0):
			reached_exit = true
			break

	Input.action_release("move_right")
	Input.action_release("jump")

	if reached_exit:
		log_pass("Setor 9: Travessia completa até a saída leste para o Setor 10 concluída com sucesso")
	else:
		log_fail("Setor 9: Falha ao alcançar a saída leste do Setor 9")

	demo.queue_free()
	await process_frame

func _test_sector_10_arena_traversal() -> void:
	print("\n--- Teste 5: Física e Travessia no Setor 10 (Clareira da Bruma Espectral / Arena) ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame
	await demo.switch_room(9, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var origin_x: float = ForestLayout.ORIGINS[9].x

	if hero.is_on_floor():
		log_pass("Aren assentado firmemente na entrada da Arena do Setor 10 (y=%.1f)" % hero.global_position.y)
	else:
		log_fail("Aren flutuando na entrada da Arena do Setor 10: pos=%s" % str(hero.global_position))

	# 1. Corrida contínua por todo o chão plano da arena até o Altar e Pórtico Leste
	hero.reset_to(Vector2(origin_x + 50.0, 260.0))
	for i in range(5):
		await physics_frame

	Input.action_press("move_right")
	var reached_altar: bool = false
	var reached_portal: bool = false

	for f in range(600):
		await physics_frame
		var lx: float = hero.global_position.x - origin_x
		if lx >= 440.0 and lx <= 520.0 and absf(hero.global_position.y - 260.0) < 1.0:
			reached_altar = true
		if lx >= 880.0 and hero.is_on_floor():
			reached_portal = true
			break

	Input.action_release("move_right")

	if reached_altar:
		log_pass("Setor 10: Aren percorreu a arena passando pelo Altar da Bruma Espectral em y=260.0 px")
	else:
		log_fail("Setor 10: Falha ao cruzar o centro da arena")

	if reached_portal:
		log_pass("Setor 10: Aren alcançou o Pórtico do Juramento no extremo leste da fase em x=%.1f, y=%.1f" % [hero.global_position.x - origin_x, hero.global_position.y])
	else:
		log_fail("Setor 10: Falha ao alcançar o extremo leste da arena")

	# 2. Retorno bidirecional do extremo leste até a fronteira oeste com Setor 9
	Input.action_press("move_left")
	var reached_west_border: bool = false

	for f in range(600):
		await physics_frame
		var lx: float = hero.global_position.x - origin_x
		if lx <= 25.0 and hero.is_on_floor():
			reached_west_border = true
			break

	Input.action_release("move_left")

	if reached_west_border:
		log_pass("Setor 10: Retorno completo de ponta a ponta na arena concluído (retorno ao Setor 9 viável)")
	else:
		log_fail("Setor 10: Falha no retorno completo pela arena")

	demo.queue_free()
	await process_frame

func _test_sector_9_and_10_platforms() -> void:
	print("\n--- Teste 6: Acessibilidade das Plataformas Aéreas dos Setores 9 e 10 ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame

	# Setor 9: Plataformas suspensas
	await demo.switch_room(8, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[8].x

	# Subida da entrada (y=240) para Branch 0 (x: 100..175, y: 216)
	hero.reset_to(Vector2(ox + 60.0, 240.0))
	for i in range(5):
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(40):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")

	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 100.0 and lx <= 175.0 and absf(hero.global_position.y - 216.0) < 1.0:
		log_pass("Setor 9 - Branch 0 alcançada do solo da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 9 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 440..550, y: 154) sobre o abismo da ravina
	hero.reset_to(Vector2(ox + 390.0, 172.0))
	for i in range(3):
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(45):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")

	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 440.0 and lx <= 550.0 and absf(hero.global_position.y - 154.0) < 1.0:
		log_pass("Setor 9 - Branch 3 (Arco Central da Ravina) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 9 - Falha ao alcançar Branch 3 do Setor 9: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Setor 10: Plataformas da abóbada da Arena
	await demo.switch_room(9, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	ox = ForestLayout.ORIGINS[9].x

	# Subida do solo da arena (y=260) para Branch 0 (x: 140..225, y: 234)
	hero.reset_to(Vector2(ox + 100.0, 260.0))
	for i in range(5):
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(40):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")

	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 140.0 and lx <= 225.0 and absf(hero.global_position.y - 234.0) < 1.0:
		log_pass("Setor 10 - Branch 0 (Poleiro Oeste da Arena) alcançada do chão (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 10 - Falha ao alcançar Branch 0 da Arena: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 255..345, y: 210)
	hero.reset_to(Vector2(ox + 215.0, 234.0))
	for i in range(3):
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(45):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")

	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 255.0 and lx <= 345.0 and absf(hero.global_position.y - 210.0) < 1.0:
		log_pass("Setor 10 - Branch 1 (Costela Superior Oeste) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 10 - Falha ao alcançar Branch 1 da Arena: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 375..465, y: 186)
	hero.reset_to(Vector2(ox + 335.0, 210.0))
	for i in range(3):
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(45):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")

	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 375.0 and lx <= 465.0 and absf(hero.global_position.y - 186.0) < 1.0:
		log_pass("Setor 10 - Branch 2 (Abóbada Central da Arena) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 10 - Falha ao alcançar Branch 2 da Arena: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	demo.queue_free()
	await process_frame

func _test_fall_recovery_all_sectors() -> void:
	print("\n--- Teste 7: Recuperação de Queda em Todos os 10 Setores ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame

	for sector_idx: int in range(10):
		await demo.switch_room(sector_idx, false)
		while demo.busy:
			await physics_frame
		for i in range(3):
			await physics_frame

		var origin: Vector2 = ForestLayout.ORIGINS[sector_idx]
		# Forçar queda simulada no abismo (y > 430)
		demo.hero.global_position = origin + Vector2(400.0, 440.0)
		demo.hero.velocity = Vector2(0.0, 300.0)
		await physics_frame
		await physics_frame

		var expected_entry: Vector2 = ForestLayout.entry(sector_idx, false)
		var dist_to_entry: float = demo.hero.global_position.distance_to(expected_entry)
		if dist_to_entry < 2.0:
			log_pass("Setor %d: Recuperação de queda segura retornou exatamente ao ponto de entrada" % [sector_idx + 1])
		else:
			log_fail("Setor %d: Falha na recuperação de queda: pos=%s (esperado %s)" % [sector_idx + 1, str(demo.hero.global_position), str(expected_entry)])

	demo.queue_free()
	await process_frame

func _test_camera_clamping_all_sectors() -> void:
	print("\n--- Teste 8: Limites e Clamping da Câmera nos 10 Setores ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame

	for sector_idx: int in range(10):
		await demo.switch_room(sector_idx, false)
		while demo.busy:
			await physics_frame
		for i in range(3):
			await physics_frame

		var origin: Vector2 = ForestLayout.ORIGINS[sector_idx]
		var c_target: Vector2 = demo.camera_target()
		var local_c: Vector2 = c_target - origin

		if local_c.x >= 160.0 and local_c.x <= 800.0 and local_c.y >= 90.0 and local_c.y <= 330.0:
			log_pass("Setor %d: Câmera enquadrada dentro dos limites seguros da sala: %s" % [sector_idx + 1, str(local_c)])
		else:
			log_fail("Setor %d: Câmera fora dos limites seguros: %s" % [sector_idx + 1, str(local_c)])

	demo.queue_free()
	await process_frame

func _test_no_premature_completion_and_boss_arena_state() -> void:
	print("\n--- Teste 9: Auditoria de Conclusão Prematura, Arena do Chefe e Retorno Físico S10 -> S9 -> S8 ---")
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)

	while demo.busy:
		await physics_frame

	# 1. Entrar no Setor 10 (Arena)
	await demo.switch_room(9, false)
	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	# 2. Verificar que demo.completed permanece estritamente falso
	if not demo.completed:
		log_pass("Setor 10: demo.completed é estritamente false ao entrar na arena")
	else:
		log_fail("Setor 10: demo.completed ativado indevidamente (conclusão prematura)")

	# 3. Verificar que o subhint é narrativo e de exploração sem declarar conclusão
	if "Clareira da Bruma Espectral" in demo.subhint.text and not ("concluída" in demo.subhint.text.to_lower() or "vitória" in demo.subhint.text.to_lower()):
		log_pass("Setor 10: subhint de exploração narrativa aprovado: '%s'" % demo.subhint.text)
	else:
		log_fail("Setor 10: subhint inadequado ou com declaração de vitória: '%s'" % demo.subhint.text)

	# 4. Cruzar a arena de ponta a ponta e confirmar que demo.completed permanece false
	var hero: KnightController = demo.hero
	var origin_10: Vector2 = ForestLayout.ORIGINS[9]
	hero.reset_to(origin_10 + Vector2(500.0, 260.0))
	for i in range(10):
		await physics_frame

	if not demo.completed:
		log_pass("Setor 10: exploração do Altar e centro da arena mantém demo.completed == false")
	else:
		log_fail("Setor 10: exploração ativou demo.completed indevidamente")

	# 5. Garantir que não existe transição para Fase 4 além do Setor 10
	if ForestLayout.NAMES.size() == 10 and ForestLayout.ORIGINS.size() == 10:
		log_pass("Fase 3 possui exatamente 10 setores canônicos (sem fase 4 indevida)")
	else:
		log_fail("Quantidade de setores em ForestLayout inconsistente")

	# 6. Teste de Retorno Físico Bidirecional: Setor 10 -> Setor 9
	hero.reset_to(origin_10 + Vector2(25.0, 260.0))
	hero.facing = -1.0
	for i in range(3):
		await physics_frame

	Input.action_press("move_left")
	for f in range(120):
		await physics_frame
		if demo.current_room == 8:
			break
	Input.action_release("move_left")

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	if demo.current_room == 8:
		log_pass("Retorno físico acionado por caminhada: Setor 10 -> Setor 9 concluído com sucesso")
	else:
		log_fail("Falha no retorno físico Setor 10 -> Setor 9 (current_room=%d)" % demo.current_room)

	# 7. Teste de Retorno Físico Bidirecional: Setor 9 -> Setor 8
	var origin_9: Vector2 = ForestLayout.ORIGINS[8]
	hero.reset_to(origin_9 + Vector2(25.0, 240.0))
	hero.facing = -1.0
	for i in range(3):
		await physics_frame

	Input.action_press("move_left")
	for f in range(120):
		await physics_frame
		if demo.current_room == 7:
			break
	Input.action_release("move_left")

	while demo.busy:
		await physics_frame
	for i in range(5):
		await physics_frame

	if demo.current_room == 7:
		log_pass("Retorno físico acionado por caminhada: Setor 9 -> Setor 8 concluído com sucesso")
	else:
		log_fail("Falha no retorno físico Setor 9 -> Setor 8 (current_room=%d)" % demo.current_room)

	# 8. Verificação de integridade: demo.completed continua false após revisitar setores anteriores
	if not demo.completed:
		log_pass("Estado de jogo preservado: demo.completed permanece false após navegação reversa")
	else:
		log_fail("demo.completed alterado indevidamente após navegação reversa")

	demo.queue_free()
	await process_frame
