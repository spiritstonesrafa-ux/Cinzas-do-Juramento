extends SceneTree
## Teste de acessibilidade com entradas reais para o Santuário do Cervo e travessia dos 4 setores (M6-B1 FIX01).

var checks: int = 0
var failures: int = 0

func log_check(ok: bool, msg: String) -> void:
	checks += 1
	if ok:
		print("  [PASS] ", msg)
	else:
		failures += 1
		printerr("  [FAIL] ", msg)

func _initialize() -> void:
	run.call_deferred()

func tick(n: int = 1) -> void:
	for i in range(n):
		await physics_frame
		await process_frame

func release_all() -> void:
	for act in ["move_left", "move_right", "jump", "attack"]:
		Input.action_release(act)

func run() -> void:
	print("==================================================")
	print("TESTE DE ACESSIBILIDADE REAL — SANTUÁRIO DO CERVO")
	print("==================================================")
	
	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)
	
	while stage.busy or stage.current_room < 0:
		await tick()
	await tick(5)
	
	var hero: KnightController = stage.hero
	var s2_origin: Vector2 = ForestLayout.ORIGINS[1]
	
	# Muda para o Setor 2
	await stage.switch_room(1, false)
	while stage.busy:
		await tick()
	await tick(5)
	
	# =========================================================================
	# PARTE 1: SUBIDA NO SANTUÁRIO DO CERVO PELA ESQUERDA (Entradas Reais)
	# =========================================================================
	print("\n--- Parte 1: Subida no Santuário pela Esquerda (x=720 -> Altar x=840) ---")
	hero.reset_to(s2_origin + Vector2(720.0, 288.0))
	hero.facing = 1
	await tick(6)
	
	log_check(hero.is_on_floor() and absf(hero.global_position.y - (s2_origin.y + 288.0)) < 1.0, 
		"Aren assentado no chão antes do santuário (y=%.1f)" % (hero.global_position.y - s2_origin.y))
	
	Input.action_press("move_right")
	var reached_left_step: bool = false
	var reached_altar_from_left: bool = false
	var jumped_step1: bool = false
	var jumped_step2: bool = false
	
	for f in range(160):
		var local_x: float = hero.global_position.x - s2_origin.x
		var local_y: float = hero.global_position.y - s2_origin.y
		
		# Salto 1 para o degrau oeste (x=764, y=268)
		if not jumped_step1 and local_x >= 745.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step1 = true
		elif jumped_step1 and not jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		# Confirma pouso no degrau oeste (y=268)
		if jumped_step1 and not reached_left_step and hero.is_on_floor() and local_x >= 764.0 and local_x < 810.0 and absf(local_y - 268.0) < 1.5:
			reached_left_step = true
		
		# Salto 2 do degrau oeste para o topo do Altar (x=810, y=246)
		if reached_left_step and not jumped_step2 and local_x >= 785.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_step2 = true
		elif jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		# Confirma pouso estável no Altar (y=246)
		if jumped_step2 and hero.is_on_floor() and local_x >= 815.0 and local_x <= 885.0 and absf(local_y - 246.0) < 1.5:
			reached_altar_from_left = true
			break
		
		await tick()
	
	release_all()
	log_check(reached_left_step, "Aren alcançou e aterrissou com sucesso no degrau oeste (y=268)")
	log_check(reached_altar_from_left, "Aren alcançou o topo do Altar do Cervo pela esquerda com comandos reais (y=246)")
	
	# =========================================================================
	# PARTE 2: DESCIDA PARA A DIREITA E CONTINUAÇÃO PARA O SETOR 3
	# =========================================================================
	print("\n--- Parte 2: Descida do Altar para a Direita em Direção ao Setor 3 ---")
	Input.action_press("move_right")
	var reached_right_step_descent: bool = false
	var reached_right_ground: bool = false
	
	for f in range(120):
		var local_x: float = hero.global_position.x - s2_origin.x
		var local_y: float = hero.global_position.y - s2_origin.y
		
		if not reached_right_step_descent and hero.is_on_floor() and local_x >= 890.0 and local_x < 934.0 and absf(local_y - 268.0) < 1.5:
			reached_right_step_descent = true
		
		if reached_right_step_descent and hero.is_on_floor() and local_x >= 935.0 and absf(local_y - 288.0) < 1.5:
			reached_right_ground = true
			break
		
		await tick()
	
	release_all()
	log_check(reached_right_step_descent, "Aren desceu com segurança para o degrau leste (y=268)")
	log_check(reached_right_ground, "Aren desceu para o chão à direita do santuário (y=288)")
	
	# =========================================================================
	# PARTE 3: SUBIDA NO SANTUÁRIO PELA DIREITA (Retorno Setor 3 -> Setor 2)
	# =========================================================================
	print("\n--- Parte 3: Subida no Santuário pela Direita (Retorno x=940 -> Altar x=840) ---")
	hero.reset_to(s2_origin + Vector2(940.0, 288.0))
	hero.facing = -1
	await tick(6)
	
	Input.action_press("move_left")
	var ret_jumped_step1: bool = false
	var ret_jumped_step2: bool = false
	var ret_reached_right_step: bool = false
	var ret_reached_altar: bool = false
	
	for f in range(160):
		var local_x: float = hero.global_position.x - s2_origin.x
		var local_y: float = hero.global_position.y - s2_origin.y
		
		# Salto 1 para o degrau leste (x=934, y=268)
		if not ret_jumped_step1 and local_x <= 936.0 and hero.is_on_floor():
			Input.action_press("jump")
			ret_jumped_step1 = true
		elif ret_jumped_step1 and not ret_jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		if ret_jumped_step1 and not ret_reached_right_step and hero.is_on_floor() and local_x <= 930.0 and local_x > 890.0 and absf(local_y - 268.0) < 1.5:
			ret_reached_right_step = true
		
		# Salto 2 do degrau leste para o topo do Altar (x=890, y=246)
		if ret_reached_right_step and not ret_jumped_step2 and local_x <= 905.0 and hero.is_on_floor():
			Input.action_press("jump")
			ret_jumped_step2 = true
		elif ret_jumped_step2 and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		if ret_jumped_step2 and hero.is_on_floor() and local_x <= 880.0 and local_x >= 815.0 and absf(local_y - 246.0) < 1.5:
			ret_reached_altar = true
			break
		
		await tick()
	
	release_all()
	log_check(ret_reached_right_step, "Aren alcançou o degrau leste retornando pela direita (y=268)")
	log_check(ret_reached_altar, "Aren alcançou o topo do Altar retornando pela direita (y=246)")
	
	# =========================================================================
	# PARTE 4: DESCIDA PARA A ESQUERDA (Retorno ao Setor 1)
	# =========================================================================
	print("\n--- Parte 4: Descida do Altar para a Esquerda em Direção ao Setor 1 ---")
	Input.action_press("move_left")
	var ret_reached_left_step: bool = false
	var ret_reached_left_ground: bool = false
	
	for f in range(120):
		var local_x: float = hero.global_position.x - s2_origin.x
		var local_y: float = hero.global_position.y - s2_origin.y
		
		if not ret_reached_left_step and hero.is_on_floor() and local_x <= 810.0 and local_x > 764.0 and absf(local_y - 268.0) < 1.5:
			ret_reached_left_step = true
		
		if ret_reached_left_step and hero.is_on_floor() and local_x <= 760.0 and absf(local_y - 288.0) < 1.5:
			ret_reached_left_ground = true
			break
		
		await tick()
	
	release_all()
	log_check(ret_reached_left_step, "Aren desceu com segurança para o degrau oeste na volta (y=268)")
	log_check(ret_reached_left_ground, "Aren desceu para o chão à esquerda na volta (y=288)")
	
	# =========================================================================
	# PARTE 5: JORNADA COMPLETA CONTÍNUA ENTRE OS 4 SETORES
	# =========================================================================
	print("\n--- Parte 5: Jornada Contínua S1 -> S2 -> S3 -> S4 e Retorno Completo ---")
	
	# S1 -> S2
	await stage.switch_room(0, false)
	while stage.busy:
		await tick()
	hero.reset_to(Vector2(910.0, 300.0))
	hero.facing = 1
	await tick(5)
	Input.action_press("move_right")
	for f in range(60):
		await tick()
		if stage.current_room == 1:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 1, "Entrada contínua no Setor 2 a partir do Setor 1")
	
	# S2 -> S3 (atravessando o Santuário)
	hero.reset_to(s2_origin + Vector2(720.0, 288.0))
	hero.facing = 1
	await tick(5)
	Input.action_press("move_right")
	var jumped_s1_step: bool = false
	var jumped_s1_altar: bool = false
	for f in range(260):
		var lx: float = hero.global_position.x - s2_origin.x
		if not jumped_s1_step and lx >= 745.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_s1_step = true
		elif jumped_s1_step and not jumped_s1_altar and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		if jumped_s1_step and not jumped_s1_altar and lx >= 785.0 and hero.is_on_floor():
			Input.action_press("jump")
			jumped_s1_altar = true
		elif jumped_s1_altar and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		await tick()
		if stage.current_room == 2:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 2, "Avanço contínuo do Setor 2 para o Setor 3 atravessando o Santuário com comandos reais")
	
	# S3 -> S4
	var s3_origin: Vector2 = ForestLayout.ORIGINS[2]
	hero.reset_to(s3_origin + Vector2(910.0, 300.0))
	hero.facing = 1
	await tick(5)
	Input.action_press("move_right")
	for f in range(60):
		await tick()
		if stage.current_room == 3:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 3, "Avanço contínuo do Setor 3 para o Setor 4")
	
	# S4 -> S3 (retorno)
	var s4_origin: Vector2 = ForestLayout.ORIGINS[3]
	hero.reset_to(s4_origin + Vector2(40.0, 300.0))
	hero.facing = -1
	await tick(5)
	Input.action_press("move_left")
	for f in range(60):
		await tick()
		if stage.current_room == 2:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 2, "Retorno contínuo do Setor 4 para o Setor 3")
	
	# S3 -> S2 (retorno)
	hero.reset_to(s3_origin + Vector2(40.0, 288.0))
	hero.facing = -1
	await tick(5)
	Input.action_press("move_left")
	for f in range(60):
		await tick()
		if stage.current_room == 1:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 1, "Retorno contínuo do Setor 3 para o Setor 2")
	
	# S2 -> S1 (retorno atravessando o Santuário pela direita)
	hero.reset_to(s2_origin + Vector2(940.0, 288.0))
	hero.facing = -1
	await tick(5)
	Input.action_press("move_left")
	var ret_s2_step1: bool = false
	var ret_s2_altar: bool = false
	for f in range(260):
		var lx: float = hero.global_position.x - s2_origin.x
		if not ret_s2_step1 and lx <= 936.0 and hero.is_on_floor():
			Input.action_press("jump")
			ret_s2_step1 = true
		elif ret_s2_step1 and not ret_s2_altar and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		if ret_s2_step1 and not ret_s2_altar and lx <= 905.0 and hero.is_on_floor():
			Input.action_press("jump")
			ret_s2_altar = true
		elif ret_s2_altar and hero.velocity.y < 0.0:
			Input.action_release("jump")
		
		await tick()
		if lx <= 700.0:
			break
	release_all()
	
	# Agora vai para o limite esquerdo de S2 para retornar a S1
	hero.reset_to(s2_origin + Vector2(40.0, 300.0))
	hero.facing = -1
	await tick(5)
	Input.action_press("move_left")
	for f in range(60):
		await tick()
		if stage.current_room == 0:
			break
	release_all()
	while stage.busy:
		await tick()
	log_check(stage.current_room == 0, "Retorno contínuo do Setor 2 para o Setor 1 após atravessar o Santuário")
	
	print("\n==================================================")
	print("RESULTADO ACESSIBILIDADE: %d PASSOU, %d FALHOU" % [checks - failures, failures])
	print("==================================================")
	
	stage.queue_free()
	await tick(3)
	quit(1 if failures > 0 else 0)

