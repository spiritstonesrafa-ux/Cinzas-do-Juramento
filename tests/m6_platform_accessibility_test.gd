extends SceneTree
## Suíte de Testes de Acessibilidade Dedicada às Plataformas Suspensas da Floresta dos Ossos (M6 FIX01).
## Valida a subida do solo, permanência, travessia aérea e descida segura em todos os 8 setores.

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
	print("SUÍTE DE TESTES: ACESSIBILIDADE DAS PLATAFORMAS SUSPENSAS")
	print("Floresta dos Ossos — Setores 1 ao 8")
	print("==================================================")
	call_deferred("_run_all_tests")

func _run_all_tests() -> void:
	await _test_sector_1_platforms()
	await _test_sector_2_platforms()
	await _test_sector_3_platforms()
	await _test_sector_4_platforms()
	await _test_sector_5_platforms()
	await _test_sector_6_platforms()
	await _test_sector_7_platforms()
	await _test_sector_8_platforms()

	print("==================================================")
	print("RESULTADO FINAL ACESSIBILIDADE: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")

	if failed == 0:
		quit(0)
	else:
		quit(1)

func _setup_demo(sector_id: int) -> ForestDemo:
	var scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn") as PackedScene
	var demo: ForestDemo = scene.instantiate() as ForestDemo
	root.add_child(demo)
	while demo.busy:
		await physics_frame
	if sector_id > 0:
		await demo.switch_room(sector_id, false)
		while demo.busy:
			await physics_frame
	for i in range(5):
		await physics_frame
	return demo

func _jump_and_move_right(hero: KnightController, max_frames: int = 60) -> void:
	Input.action_press("move_right")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(max_frames):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_right")
	for i in range(3):
		await physics_frame

func _jump_and_move_left(hero: KnightController, max_frames: int = 60) -> void:
	Input.action_press("move_left")
	Input.action_press("jump")
	await physics_frame
	Input.action_release("jump")
	for f in range(max_frames):
		await physics_frame
		if hero.is_on_floor() and f > 10:
			break
	Input.action_release("move_left")
	for i in range(3):
		await physics_frame

func _wait_for_floor(hero: KnightController, max_frames: int = 60) -> void:
	for f in range(max_frames):
		await physics_frame
		if hero.is_on_floor():
			break

func _walk_until_floor(hero: KnightController, max_frames: int = 80) -> void:
	Input.action_press("move_right")
	for f in range(max_frames):
		await physics_frame
		if hero.is_on_floor() and f > 20:
			break
	Input.action_release("move_right")
	for i in range(5):
		await physics_frame

## 1. Setor 1: Entrada da Floresta
func _test_sector_1_platforms() -> void:
	print("\n--- Setor 1: Entrada da Floresta ---")
	var demo: ForestDemo = await _setup_demo(0)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[0].x

	# Aren no patamar de solo em x=265 (y=288), saltando à esquerda para a Branch 0 (x: 160..240, y: 252)
	hero.reset_to(Vector2(ox + 265.0, 288.0))
	for i in range(5):
		await physics_frame

	await _jump_and_move_left(hero, 40)

	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 160.0 and lx <= 240.0 and absf(hero.global_position.y - 252.0) < 1.0:
		log_pass("Setor 1 - Branch 0 alcançada a partir do patamar inicial (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 1 - Falha ao subir em Branch 0: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	# Salto para Branch 1 (x: 290..380, y: 244)
	hero.reset_to(Vector2(ox + 230.0, 252.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 290.0 and lx <= 380.0 and absf(hero.global_position.y - 244.0) < 1.0:
		log_pass("Setor 1 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 1 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 410..540, y: 222)
	hero.reset_to(Vector2(ox + 370.0, 244.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 410.0 and lx <= 540.0 and absf(hero.global_position.y - 222.0) < 1.0:
		log_pass("Setor 1 - Branch 2 (Canópea Central) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 1 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 570..660, y: 224)
	hero.reset_to(Vector2(ox + 530.0, 222.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 570.0 and lx <= 660.0 and absf(hero.global_position.y - 224.0) < 1.0:
		log_pass("Setor 1 - Branch 3 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 1 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida segura de Branch 3 para o solo leste
	hero.reset_to(Vector2(ox + 650.0, 224.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 270.0 and lx >= 660.0:
		log_pass("Setor 1 - Descida segura de Branch 3 para o solo concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 1 - Falha na descida segura de Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Teste de Retorno no Setor 1: Aren entra pela direita (entry right) e retorna até o início
	hero.reset_to(ForestLayout.entry(0, true)) # Vector2(ox + 912.0, 300.0)
	hero.facing = -1
	for i in range(5):
		await physics_frame

	Input.action_press("move_left")
	var jumped_s3: bool = false
	var jumped_s1: bool = false
	var reached_west: bool = false

	for f in range(650):
		lx = hero.global_position.x - ox
		# Salto 1: ao alcançar o degrau em x=745 para subir de y=300 para y=276
		if lx <= 752.0 and lx >= 740.0 and hero.is_on_floor() and not jumped_s3:
			Input.action_press("jump")
			jumped_s3 = true
		elif jumped_s3 and hero.velocity.y >= 0.0 and not jumped_s1:
			Input.action_release("jump")

		# Salto 2: ao alcançar o degrau em x=385 para subir de y=300 para y=288
		if lx <= 390.0 and lx >= 380.0 and hero.is_on_floor() and not jumped_s1:
			Input.action_press("jump")
			jumped_s1 = true
		elif jumped_s1 and hero.velocity.y >= 0.0:
			Input.action_release("jump")

		await physics_frame
		lx = hero.global_position.x - ox
		if lx <= 25.0:
			reached_west = true
			break

	Input.action_release("move_left")
	Input.action_release("jump")

	if reached_west:
		log_pass("Setor 1 - Retorno bidirecional completo validado com sucesso (alcançou x=%.1f)" % [hero.global_position.x - ox])
	else:
		log_fail("Setor 1 - Falha no retorno bidirecional: parou em x=%.1f, y=%.1f" % [hero.global_position.x - ox, hero.global_position.y])

	demo.queue_free()
	await process_frame

## 2. Setor 2: Bosque das Raízes
func _test_sector_2_platforms() -> void:
	print("\n--- Setor 2: Bosque das Raízes ---")
	var demo: ForestDemo = await _setup_demo(1)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[1].x

	# Subida do solo oeste (y=300) para Branch 0 (x: 350..440, y: 276)
	hero.reset_to(Vector2(ox + 330.0, 300.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 350.0 and lx <= 440.0 and absf(hero.global_position.y - 276.0) < 1.0:
		log_pass("Setor 2 - Branch 0 alcançada a partir do solo oeste (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 2 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 475..605, y: 252)
	hero.reset_to(Vector2(ox + 430.0, 276.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 475.0 and lx <= 605.0 and absf(hero.global_position.y - 252.0) < 1.0:
		log_pass("Setor 2 - Branch 1 (Dossel de Raízes) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 2 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 640..720, y: 246)
	hero.reset_to(Vector2(ox + 595.0, 252.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 640.0 and lx <= 720.0 and absf(hero.global_position.y - 246.0) < 1.0:
		log_pass("Setor 2 - Branch 2 alcançada sobrevoando o abismo (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 2 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o Santuário do Cervo
	hero.reset_to(Vector2(ox + 710.0, 246.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 265.0:
		log_pass("Setor 2 - Descida suave diante do Santuário concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 2 - Falha na descida para o Santuário: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame

## 3. Setor 3: Passagem dos Fósseis
func _test_sector_3_platforms() -> void:
	print("\n--- Setor 3: Passagem dos Fósseis ---")
	var demo: ForestDemo = await _setup_demo(2)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[2].x

	# Subida do solo oeste (y=288) para Branch 0 (x: 120..200, y: 266)
	hero.reset_to(Vector2(ox + 90.0, 288.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 120.0 and lx <= 200.0 and absf(hero.global_position.y - 266.0) < 1.0:
		log_pass("Setor 3 - Branch 0 alcançada a partir da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 230..320, y: 244)
	hero.reset_to(Vector2(ox + 190.0, 266.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 230.0 and lx <= 320.0 and absf(hero.global_position.y - 244.0) < 1.0:
		log_pass("Setor 3 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 350..460, y: 222)
	hero.reset_to(Vector2(ox + 310.0, 244.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 350.0 and lx <= 460.0 and absf(hero.global_position.y - 222.0) < 1.0:
		log_pass("Setor 3 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 480..590, y: 200) sobre o desfiladeiro
	hero.reset_to(Vector2(ox + 450.0, 222.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 480.0 and lx <= 590.0 and absf(hero.global_position.y - 200.0) < 1.0:
		log_pass("Setor 3 - Branch 3 (Arco Alto do Desfiladeiro) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 4 (x: 620..710, y: 222)
	hero.reset_to(Vector2(ox + 580.0, 200.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 620.0 and lx <= 710.0 and absf(hero.global_position.y - 222.0) < 1.0:
		log_pass("Setor 3 - Branch 4 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha ao alcançar Branch 4: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o solo leste
	hero.reset_to(Vector2(ox + 700.0, 222.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 270.0:
		log_pass("Setor 3 - Descida segura no solo leste concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 3 - Falha na descida: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	demo.queue_free()
	await process_frame

## 4. Setor 4: Clareira Ancestral
func _test_sector_4_platforms() -> void:
	print("\n--- Setor 4: Clareira Ancestral ---")
	var demo: ForestDemo = await _setup_demo(3)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[3].x

	# Subida do terraço rochoso (y=270) para Branch 0 (x: 210..290, y: 248)
	hero.reset_to(Vector2(ox + 200.0, 270.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 210.0 and lx <= 290.0 and absf(hero.global_position.y - 248.0) < 1.0:
		log_pass("Setor 4 - Branch 0 alcançada a partir do terraço oeste (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 4 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 320..410, y: 226)
	hero.reset_to(Vector2(ox + 280.0, 248.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 320.0 and lx <= 410.0 and absf(hero.global_position.y - 226.0) < 1.0:
		log_pass("Setor 4 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 4 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 440..540, y: 204)
	hero.reset_to(Vector2(ox + 400.0, 226.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 440.0 and lx <= 540.0 and absf(hero.global_position.y - 204.0) < 1.0:
		log_pass("Setor 4 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 4 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 570..680, y: 190)
	hero.reset_to(Vector2(ox + 530.0, 204.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 570.0 and lx <= 680.0 and absf(hero.global_position.y - 190.0) < 1.0:
		log_pass("Setor 4 - Branch 3 (Arco Gótico Superior) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 4 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o Mirante final (x=740, y=260)
	hero.reset_to(Vector2(ox + 670.0, 190.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 255.0:
		log_pass("Setor 4 - Descida direta no Mirante final concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 4 - Falha na descida para o mirante: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame

## 5. Setor 5: Passagem das Raízes Profundas
func _test_sector_5_platforms() -> void:
	print("\n--- Setor 5: Passagem das Raízes Profundas ---")
	var demo: ForestDemo = await _setup_demo(4)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[4].x

	# Subida da entrada (y=260) para Branch 0 (x: 110..180, y: 238)
	hero.reset_to(Vector2(ox + 70.0, 260.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 110.0 and lx <= 180.0 and absf(hero.global_position.y - 238.0) < 1.0:
		log_pass("Setor 5 - Branch 0 alcançada a partir da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 210..300, y: 216)
	hero.reset_to(Vector2(ox + 170.0, 238.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 210.0 and lx <= 300.0 and absf(hero.global_position.y - 216.0) < 1.0:
		log_pass("Setor 5 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 330..450, y: 216)
	hero.reset_to(Vector2(ox + 290.0, 216.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 330.0 and lx <= 450.0 and absf(hero.global_position.y - 216.0) < 1.0:
		log_pass("Setor 5 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 480..590, y: 228) sobre o abismo de raízes
	hero.reset_to(Vector2(ox + 440.0, 216.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 480.0 and lx <= 590.0 and absf(hero.global_position.y - 228.0) < 1.0:
		log_pass("Setor 5 - Branch 3 alcançada sobre o abismo de raízes (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 4 (x: 620..710, y: 250)
	hero.reset_to(Vector2(ox + 580.0, 228.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 620.0 and lx <= 710.0 and absf(hero.global_position.y - 250.0) < 1.0:
		log_pass("Setor 5 - Branch 4 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha ao alcançar Branch 4: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o solo leste
	hero.reset_to(Vector2(ox + 700.0, 250.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 270.0:
		log_pass("Setor 5 - Descida suave no solo leste concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 5 - Falha na descida: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame

## 6. Setor 6: Galeria dos Ossos Antigos
func _test_sector_6_platforms() -> void:
	print("\n--- Setor 6: Galeria dos Ossos Antigos ---")
	var demo: ForestDemo = await _setup_demo(5)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[5].x

	# Subida da entrada (y=280) para Branch 0 (x: 110..185, y: 256)
	hero.reset_to(Vector2(ox + 70.0, 280.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 110.0 and lx <= 185.0 and absf(hero.global_position.y - 256.0) < 1.0:
		log_pass("Setor 6 - Branch 0 alcançada a partir da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 6 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 215..300, y: 234)
	hero.reset_to(Vector2(ox + 180.0, 256.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 215.0 and lx <= 300.0 and absf(hero.global_position.y - 234.0) < 1.0:
		log_pass("Setor 6 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 6 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 330..430, y: 212)
	hero.reset_to(Vector2(ox + 295.0, 234.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 330.0 and lx <= 430.0 and absf(hero.global_position.y - 212.0) < 1.0:
		log_pass("Setor 6 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 6 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 460..610, y: 190)
	hero.reset_to(Vector2(ox + 420.0, 212.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 460.0 and lx <= 610.0 and absf(hero.global_position.y - 190.0) < 1.0:
		log_pass("Setor 6 - Branch 3 (Costelas Monumentais) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 6 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o Grande Terraço Monumental (x=785, y=220)
	hero.reset_to(Vector2(ox + 600.0, 190.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 215.0:
		log_pass("Setor 6 - Descida segura no terraço do santuário ossuário (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 6 - Falha na descida para o terraço: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame

## 7. Setor 7: Fenda das Vértebras
func _test_sector_7_platforms() -> void:
	print("\n--- Setor 7: Fenda das Vértebras ---")
	var demo: ForestDemo = await _setup_demo(6)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[6].x

	# Subida da entrada (y=220) para Branch 0 (x: 100..175, y: 196)
	hero.reset_to(Vector2(ox + 60.0, 220.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 100.0 and lx <= 175.0 and absf(hero.global_position.y - 196.0) < 1.0:
		log_pass("Setor 7 - Branch 0 alcançada a partir da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 205..290, y: 174)
	hero.reset_to(Vector2(ox + 165.0, 196.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 205.0 and lx <= 290.0 and absf(hero.global_position.y - 174.0) < 1.0:
		log_pass("Setor 7 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 320..410, y: 154)
	hero.reset_to(Vector2(ox + 280.0, 174.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 320.0 and lx <= 410.0 and absf(hero.global_position.y - 154.0) < 1.0:
		log_pass("Setor 7 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 440..550, y: 154) sobre a fenda das vértebras
	hero.reset_to(Vector2(ox + 400.0, 154.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 440.0 and lx <= 550.0 and absf(hero.global_position.y - 154.0) < 1.0:
		log_pass("Setor 7 - Branch 3 (Ponte das Vértebras) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 4 (x: 580..670, y: 170)
	hero.reset_to(Vector2(ox + 540.0, 154.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 580.0 and lx <= 670.0 and absf(hero.global_position.y - 170.0) < 1.0:
		log_pass("Setor 7 - Branch 4 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha ao alcançar Branch 4: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o solo leste
	hero.reset_to(Vector2(ox + 660.0, 170.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 235.0:
		log_pass("Setor 7 - Descida segura no solo leste concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 7 - Falha na descida: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame

## 8. Setor 8: Bosque dos Ecos
func _test_sector_8_platforms() -> void:
	print("\n--- Setor 8: Bosque dos Ecos ---")
	var demo: ForestDemo = await _setup_demo(7)
	var hero: KnightController = demo.hero
	var ox: float = ForestLayout.ORIGINS[7].x

	# Subida da entrada (y=240) para Branch 0 (x: 100..175, y: 216)
	hero.reset_to(Vector2(ox + 60.0, 240.0))
	for i in range(5):
		await physics_frame
	await _jump_and_move_right(hero, 40)
	var lx: float = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 100.0 and lx <= 175.0 and absf(hero.global_position.y - 216.0) < 1.0:
		log_pass("Setor 8 - Branch 0 alcançada a partir da entrada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha ao alcançar Branch 0: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 1 (x: 205..290, y: 194)
	hero.reset_to(Vector2(ox + 165.0, 216.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 205.0 and lx <= 290.0 and absf(hero.global_position.y - 194.0) < 1.0:
		log_pass("Setor 8 - Branch 1 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha ao alcançar Branch 1: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 2 (x: 320..410, y: 172)
	hero.reset_to(Vector2(ox + 280.0, 194.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 320.0 and lx <= 410.0 and absf(hero.global_position.y - 172.0) < 1.0:
		log_pass("Setor 8 - Branch 2 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha ao alcançar Branch 2: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 3 (x: 440..550, y: 154) sobre a clareira dos ecos
	hero.reset_to(Vector2(ox + 400.0, 172.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 440.0 and lx <= 550.0 and absf(hero.global_position.y - 154.0) < 1.0:
		log_pass("Setor 8 - Branch 3 (Abóbada dos Ecos) alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha ao alcançar Branch 3: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Salto para Branch 4 (x: 580..670, y: 172)
	hero.reset_to(Vector2(ox + 540.0, 154.0))
	for i in range(3):
		await physics_frame
	await _jump_and_move_right(hero, 45)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and lx >= 580.0 and lx <= 670.0 and absf(hero.global_position.y - 172.0) < 1.0:
		log_pass("Setor 8 - Branch 4 alcançada (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha ao alcançar Branch 4: pos=(%.1f, %.1f)" % [lx, hero.global_position.y])

	# Descida para o Terraço dos Monólitos
	hero.reset_to(Vector2(ox + 660.0, 172.0))
	for i in range(3):
		await physics_frame
	await _walk_until_floor(hero, 80)
	lx = hero.global_position.x - ox
	if hero.is_on_floor() and hero.global_position.y >= 235.0:
		log_pass("Setor 8 - Descida segura no Terraço dos Monólitos concluída (x=%.1f, y=%.1f)" % [lx, hero.global_position.y])
	else:
		log_fail("Setor 8 - Falha na descida: pos=(%.1f, %.1f), floor=%s" % [lx, hero.global_position.y, hero.is_on_floor()])

	demo.queue_free()
	await process_frame
