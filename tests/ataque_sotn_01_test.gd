extends SceneTree
## Suíte de Testes Automatizados para ATAQUE-SOTN-01
## Valida responsividade, geometria dinâmica (arco alto/médio/baixo), espelhamento,
## dano único, momentum aéreo, landing cancel e ausência de regressões.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const SWORD_RECEIVER: Script = preload("res://scripts/combat/sword_receiver.gd")

var total_checks: int = 0
var passed_checks: int = 0
var failed_checks: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	total_checks += 1
	if condition:
		passed_checks += 1
		print("  [PASS] ", message)
	else:
		failed_checks += 1
		printerr("  [FAIL] ", message)

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _create_dummy_receiver(pos: Vector2, size: Vector2 = Vector2(16, 16)) -> Area2D:
	var area: Area2D = Area2D.new()
	area.set_script(SWORD_RECEIVER)
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

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: ATAQUE-SOTN-01")
	print("==================================================================")

	# Cria solo sólido nivelado para testes de chão
	var floor_body = StaticBody2D.new()
	floor_body.position = Vector2(200.0, 200.0)
	var floor_cs = CollisionShape2D.new()
	var floor_shape = RectangleShape2D.new()
	floor_shape.size = Vector2(600.0, 20.0)
	floor_cs.shape = floor_shape
	floor_body.add_child(floor_cs)
	root.add_child(floor_body)

	var knight: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(knight)
	current_scene = knight
	knight.global_position = Vector2(200.0, 190.0)
	await _frames(6)

	var attack: SwordAttack = knight.sword_attack

	# -------------------------------------------------------------------------
	# GRUPO A: RESPONSIVIDADE E FRAME DATA COMPARATIVO
	# -------------------------------------------------------------------------
	print("\n--- GRUPO A: Calibração de Frame Data (ORIGINAL vs SOTN) ---")
	check(attack.mode == SwordAttack.Mode.ORIGINAL, "Modo inicial padrão é ORIGINAL")
	check(is_equal_approx(attack.windup_duration, 0.10), "ORIGINAL windup = 0.10s (6 frames @ 60fps)")
	check(is_equal_approx(attack.active_duration, 0.10), "ORIGINAL active = 0.10s (6 frames @ 60fps)")
	check(is_equal_approx(attack.recovery_duration, 0.20), "ORIGINAL recovery = 0.20s (12 frames @ 60fps)")
	check(is_equal_approx(attack.windup_duration + attack.active_duration + attack.recovery_duration, 0.40), "ORIGINAL ciclo total = 0.40s (24 frames @ 60fps)")

	# Alterna para SOTN
	attack.set_mode(SwordAttack.Mode.SOTN)
	check(attack.mode == SwordAttack.Mode.SOTN, "Alternância para SOTN bem sucedida")
	check(is_equal_approx(attack.windup_duration, 0.05), "SOTN windup = 0.05s (3 frames @ 60fps - snap ágil)")
	check(is_equal_approx(attack.active_duration, 0.05), "SOTN active = 0.05s (3 frames @ 60fps - varredura rápida)")
	check(is_equal_approx(attack.recovery_duration, 0.15), "SOTN recovery = 0.15s (9 frames @ 60fps - follow-through fluido)")
	check(is_equal_approx(attack.windup_duration + attack.active_duration + attack.recovery_duration, 0.25), "SOTN ciclo total = 0.25s (15 frames @ 60fps)")

	# Testa toggle
	attack.toggle_mode()
	check(attack.mode == SwordAttack.Mode.ORIGINAL and is_equal_approx(attack.windup_duration, 0.10), "toggle_mode() reverte para ORIGINAL")
	attack.toggle_mode()
	check(attack.mode == SwordAttack.Mode.SOTN and is_equal_approx(attack.windup_duration, 0.05), "toggle_mode() alterna para SOTN")

	# -------------------------------------------------------------------------
	# GRUPO B: GEOMETRIA E COBERTURA EM MEIA-LUA (ALTO, FRONTAL, BAIXO)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO B: Geometria Dinâmica e Detecção de Alvos ---")
	knight.facing = 1

	# 1. Alvo Aéreo (High) em x=+14, y=-25 (acima do alcance do corte horizontal tradicional)
	var high_dummy = _create_dummy_receiver(knight.global_position + Vector2(14.0, -25.0), Vector2(16.0, 16.0))
	root.add_child(high_dummy)
	var high_hits: Array[int] = [0]
	high_dummy.hit_received.connect(func(): high_hits[0] += 1)

	# 2. Alvo Frontal (Mid) em x=+21, y=-14
	var mid_dummy = _create_dummy_receiver(knight.global_position + Vector2(21.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(mid_dummy)
	var mid_hits: Array[int] = [0]
	mid_dummy.hit_received.connect(func(): mid_hits[0] += 1)

	# 3. Alvo Rasteiro (Low) em x=+16, y=-5 (rente ao chão)
	var low_dummy = _create_dummy_receiver(knight.global_position + Vector2(16.0, -5.0), Vector2(16.0, 14.0))
	root.add_child(low_dummy)
	var low_hits: Array[int] = [0]
	low_dummy.hit_received.connect(func(): low_hits[0] += 1)

	# 4. Alvo Traseiro (Behind) em x=-16, y=-14 (atrás de Aren)
	var rear_dummy = _create_dummy_receiver(knight.global_position + Vector2(-16.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(rear_dummy)
	var rear_hits: Array[int] = [0]
	rear_dummy.hit_received.connect(func(): rear_hits[0] += 1)

	await _frames(2)

	# Dispara o ataque SOTN
	attack._start_attack(true, 1)
	check(attack.phase == SwordAttack.Phase.WINDUP, "Ataque SOTN inicia imediatamente em WINDUP")

	# Aguarda conclusão do ataque completo
	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(1)

	check(high_hits[0] == 1, "SOTN atinge alvo aéreo alto (Região Alta coberta)")
	check(mid_hits[0] == 1, "SOTN atinge alvo frontal (Região Frontal coberta)")
	check(low_hits[0] == 1, "SOTN atinge alvo rasteiro rente ao solo (Região Baixa coberta)")
	check(rear_hits[0] == 0, "SOTN NÃO atinge alvo localizado atrás de Aren (sem back-hits)")

	# Limpa dummies
	high_dummy.queue_free()
	mid_dummy.queue_free()
	low_dummy.queue_free()
	rear_dummy.queue_free()
	await _frames(2)

	# -------------------------------------------------------------------------
	# GRUPO C: ESPELHAMENTO DE GEOMETRIA (FACING = -1)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO C: Espelhamento Físico e Ausência de Detecção Reversa ---")
	knight.facing = -1
	var left_dummy = _create_dummy_receiver(knight.global_position + Vector2(-21.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(left_dummy)
	var left_hits: Array[int] = [0]
	left_dummy.hit_received.connect(func(): left_hits[0] += 1)

	var right_dummy = _create_dummy_receiver(knight.global_position + Vector2(21.0, -14.0), Vector2(16.0, 16.0))
	root.add_child(right_dummy)
	var right_hits: Array[int] = [0]
	right_dummy.hit_received.connect(func(): right_hits[0] += 1)

	await _frames(2)
	attack._start_attack(true, -1)
	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(1)

	check(left_hits[0] == 1, "Golpe voltado para a esquerda atinge alvo à esquerda com precisão")
	check(right_hits[0] == 0, "Golpe voltado para a esquerda NÃO atinge alvo à direita")

	left_dummy.queue_free()
	right_dummy.queue_free()
	await _frames(2)

	# -------------------------------------------------------------------------
	# GRUPO D: DANO ÚNICO POR INSTÂNCIA DE GOLPE
	# -------------------------------------------------------------------------
	print("\n--- GRUPO D: Regra de Dano Único (Single Hit per Target) ---")
	knight.facing = 1
	var single_test_dummy = _create_dummy_receiver(knight.global_position + Vector2(18.0, -14.0), Vector2(24.0, 24.0))
	root.add_child(single_test_dummy)
	var total_receiver_hits: Array[int] = [0]
	single_test_dummy.hit_received.connect(func(): total_receiver_hits[0] += 1)

	await _frames(2)
	attack._start_attack(true, 1)
	while attack.phase != SwordAttack.Phase.NEUTRAL:
		await _frames(1)

	check(total_receiver_hits[0] == 1, "Alvo grande sofre exatamente 1 hit durante toda a varredura do arco")
	single_test_dummy.queue_free()
	await _frames(2)

	# -------------------------------------------------------------------------
	# GRUPO E: ATAQUE AÉREO E CONSERVAÇÃO DE MOMENTUM
	# -------------------------------------------------------------------------
	print("\n--- GRUPO E: Ataque Aéreo e Momentum Físico ---")
	knight.velocity = Vector2(85.0, -120.0)
	attack._start_attack(false, 1)

	check(attack.aerial == true, "Ataque no ar registrado como aerial == true")
	check(attack.aerial_available == false, "Disponibilidade aérea consumida até tocar o chão")
	check(knight.velocity.x == 85.0, "Velocidade horizontal mantida durante início do corte aéreo")
	check(knight.velocity.y == -120.0, "Velocidade vertical mantida sem zeramento artificial")

	# Simula aterrissagem física (grounded = true)
	attack.tick(0.016, true, 1)
	check(attack.phase == SwordAttack.Phase.NEUTRAL, "Aterrissar cancela instantaneamente o ataque aéreo (Landing Cancel)")
	check(attack.hit_shape.disabled == true, "Landing cancel desativa a hitbox sem deixar resíduos")
	check(attack.aerial_available == true, "Aterrissar rearma a disponibilidade de ataque")

	# -------------------------------------------------------------------------
	# GRUPO F: INPUT BUFFERING (~80ms)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO F: Input Buffering no Modo SOTN ---")
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.RECOVERY
	attack._remaining = 0.04 # Dentro da janela de 80ms

	attack._attack_buffered = true
	attack._buffer_timer = 0.08
	attack.tick(0.045, true, 1)

	check(attack.phase == SwordAttack.Phase.WINDUP, "Input buffering engatilha o próximo ciclo fluido no término do recovery")
	attack.cancel()

	# -------------------------------------------------------------------------
	# GRUPO G: HITSTOP LOCALIZADO (ARQUITETURA)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO G: Arquitetura de Hitstop Localizado ---")
	attack.hitstop_enabled = true
	attack.hitstop_duration = 0.05
	attack.hitstop_remaining = 0.05
	var prev_remaining = attack._remaining

	attack.tick(0.016, true, 1)
	check(attack.hitstop_remaining < 0.05 and attack.hitstop_remaining > 0.0, "Hitstop decrementa localmente")
	check(attack._remaining == prev_remaining, "Fase do ataque congelada localmente durante o hitstop")
	attack.hitstop_enabled = false
	attack.hitstop_remaining = 0.0

	# -------------------------------------------------------------------------
	# ENCERRAMENTO
	# -------------------------------------------------------------------------
	print("\n==================================================================")
	print("RESULTADO ATAQUE-SOTN-01: %d verificações | %d PASS | %d FAIL" % [total_checks, passed_checks, failed_checks])
	print("==================================================================")

	knight.queue_free()
	floor_body.queue_free()
	await _frames(2)

	if failed_checks == 0:
		quit(0)
	else:
		quit(1)
