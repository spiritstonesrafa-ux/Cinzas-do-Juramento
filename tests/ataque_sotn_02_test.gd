extends SceneTree
## Suíte de Testes Automatizados para ATAQUE-SOTN-02:
## Refino Visual, Animação Corporal, Sincronização da Espada e Manto Dinâmico.
## Verifica estritamente a preservação da base mecânica e a integridade da nova apresentação visual.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const TARGET_SCENE: PackedScene = preload("res://scenes/targets/training_target.tscn")

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run_suite")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("  [PASS] %s" % description)
	else:
		failures += 1
		printerr("  [FAIL] %s" % description)

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _setup_test_environment() -> Dictionary:
	var floor_body := StaticBody2D.new()
	floor_body.collision_layer = 1
	floor_body.collision_mask = 0
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(800.0, 40.0)
	col.shape = rect
	col.position = Vector2(200.0, 200.0)
	floor_body.add_child(col)
	root.add_child(floor_body)

	var knight: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	knight.position = Vector2(100.0, 180.0)
	root.add_child(knight)

	for _i in range(5):
		await physics_frame
		await process_frame

	return {"floor": floor_body, "knight": knight}

func _create_dummy_receiver(pos: Vector2, size: Vector2) -> Area2D:
	var area: Area2D = Area2D.new()
	area.set_script(load("res://scripts/combat/sword_receiver.gd"))
	area.collision_layer = 8
	area.collision_mask = 4
	area.monitoring = false
	area.monitorable = true
	area.position = pos

	var cs: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	return area

func _run_suite() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: ATAQUE-SOTN-02")
	print("Refino Visual, Animação Corporal e Sincronia da Espada")
	print("==================================================================")

	var env: Dictionary = await _setup_test_environment()
	var knight: KnightController = env["knight"]
	var attack: SwordAttack = knight.sword_attack
	var visual: Node2D = knight.get_node("Visual")

	# =================================================================
	# GRUPO A: PRESERVAÇÃO DA BASE MECÂNICA HOMOLOGADA (M1)
	# =================================================================
	print("\n--- GRUPO A: Preservação da Base Mecânica Homologada ---")
	attack.set_mode(SwordAttack.Mode.SOTN)
	check(attack.windup_duration == 0.05, "Startup nominal congelado em 0.05s (3 frames)")
	check(attack.active_duration == 0.05, "Active nominal congelado em 0.05s (3 frames)")
	check(attack.recovery_duration == 0.15, "Recovery nominal congelado em 0.15s (9 frames)")
	check(attack.windup_duration + attack.active_duration + attack.recovery_duration == 0.25, "Ciclo total congelado em 0.25s (15 frames)")
	check(SwordAttack.BUFFER_WINDOW == 0.08, "Janela de input buffering mantida em 0.08s")

	# =================================================================
	# GRUPO B: HITBOX E LIMITES DE COLISÃO DO ARCO EM MEIA-LUA
	# =================================================================
	print("\n--- GRUPO B: Hitbox e Limites de Colisão do Arco ---")
	var target_high = _create_dummy_receiver(knight.global_position + Vector2(14.0, -25.0), Vector2(16.0, 16.0))
	root.add_child(target_high)

	var target_mid = _create_dummy_receiver(knight.global_position + Vector2(21.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(target_mid)

	var target_low = _create_dummy_receiver(knight.global_position + Vector2(16.0, -5.0), Vector2(16.0, 14.0))
	root.add_child(target_low)

	var target_rear = _create_dummy_receiver(knight.global_position + Vector2(-20.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(target_rear)

	var high_hit: Array[int] = [0]
	var mid_hit: Array[int] = [0]
	var low_hit: Array[int] = [0]
	var rear_hit: Array[int] = [0]

	target_high.hit_received.connect(func(): high_hit[0] += 1)
	target_mid.hit_received.connect(func(): mid_hit[0] += 1)
	target_low.hit_received.connect(func(): low_hit[0] += 1)
	target_rear.hit_received.connect(func(): rear_hit[0] += 1)

	await _frames(2)
	attack._start_attack(true, 1)

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(1)

	check(high_hit[0] == 1, "Região Alta atinge alvo aéreo com precisão de acerto único")
	check(mid_hit[0] == 1, "Região Frontal alcança extensão máxima com precisão de acerto único")
	check(low_hit[0] == 1, "Região Baixa atinge alvo rente ao solo com precisão de acerto único")
	check(rear_hit[0] == 0, "Alvo na retaguarda de Aren não é atingido (sem back-hits)")

	target_high.queue_free()
	target_mid.queue_free()
	target_low.queue_free()
	target_rear.queue_free()
	await _frames(2)

	# =================================================================
	# GRUPO C: SINCRONIA VISUAL E ARTICULAÇÃO DA ESPADA/BRAÇO
	# =================================================================
	print("\n--- GRUPO C: Sincronia Visual e Articulação da Espada ---")
	# 1. Startup: intenção e glint
	attack._start_attack(true, 1)
	check(attack.phase == SwordAttack.Phase.WINDUP, "Golpe entra imediatamente em WINDUP visual")
	await _frames(2)

	# 2. Transição para Active: varredura do arco
	await _frames(2)
	check(attack.phase == SwordAttack.Phase.ACTIVE, "Transição suave de WINDUP para ACTIVE aos 0.05s")
	var prog_early: float = attack.get_active_progress()
	check(prog_early >= 0.0 and prog_early <= 1.0, "Progresso do arco ativo calculado com precisão normalizada [0..1]")
	check(attack.get_current_arc_region() in [SwordAttack.ArcRegion.HIGH, SwordAttack.ArcRegion.MID, SwordAttack.ArcRegion.LOW], "Regiões do arco Alta/Média/Baixa mapeadas")

	# 3. Transição para Recovery
	while attack.phase == SwordAttack.Phase.ACTIVE:
		await _frames(1)
	check(attack.phase == SwordAttack.Phase.RECOVERY, "Transição precisa para RECOVERY aos 0.10s")
	check(attack._remaining <= 0.15, "Tempo residual de recovery alinhado ao frame data de 0.15s")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)

	# =================================================================
	# GRUPO D: ATAQUE NO AR, MOMENTUM E LANDING CANCEL
	# =================================================================
	print("\n--- GRUPO D: Dinâmica Aérea e Landing Cancel ---")
	knight.reset_to(Vector2(100.0, 100.0))
	knight.velocity = Vector2(85.0, -140.0)
	attack._start_attack(false, 1)
	check(attack.aerial == true, "Ataque no ar registrado como postura aérea")
	check(knight.velocity.x == 85.0, "Velocidade horizontal conservada integralmente no início do golpe")
	check(knight.velocity.y == -140.0, "Velocidade vertical de subida conservada sem paradas artificiais")

	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(2)

	# Teste de Landing Cancel: inicia ataque aéreo rente ao chão (y=175) e aterra durante o golpe
	knight.reset_to(Vector2(100.0, 175.0))
	knight.velocity = Vector2(0.0, 120.0)
	attack._start_attack(false, 1)
	check(attack.phase != SwordAttack.Phase.NEUTRAL, "Ataque aéreo ativo antes do toque no solo")

	# Avança até tocar o chão
	for _i in range(10):
		await _frames(1)
		if knight.is_on_floor():
			break

	check(attack.phase == SwordAttack.Phase.NEUTRAL, "Landing cancel interrompe imediatamente o golpe ao tocar o solo")
	check(attack.aerial == false, "Estado aéreo desarmado e pronto para combate no solo")

	# =================================================================
	# GRUPO E: MODO COMPARATIVO E ISOLAMENTO DE DEPURAÇÃO
	# =================================================================
	print("\n--- GRUPO E: Modo Comparativo e Isolamento ---")
	var toggled_mode: SwordAttack.Mode = attack.toggle_mode()
	check(toggled_mode == SwordAttack.Mode.ORIGINAL, "toggle_mode() comuta perfeitamente para ORIGINAL")
	check(attack.windup_duration == 0.10 and attack.recovery_duration == 0.20, "Modo ORIGINAL restaura 100% dos timings históricos")
	attack.toggle_mode()
	check(attack.mode == SwordAttack.Mode.SOTN, "toggle_mode() retorna com segurança para SOTN")

	# =================================================================
	# RESULTADO FINAL
	# =================================================================
	print("\n==================================================================")
	print("RESULTADO ATAQUE-SOTN-02: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")

	env["floor"].queue_free()
	knight.queue_free()

	quit(0 if failures == 0 else 1)
