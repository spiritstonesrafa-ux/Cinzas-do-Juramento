extends SceneTree
## Suíte de Testes Automatizados para ATAQUE-SOTN-02 — ART-FIX02:
## Verificação do Refino Artístico Experimental e Alternância via F8 (ARM-FIX01 <-> ART-FIX02).
## Garante preservação mecânica absoluta e integridade visual de ambos os modos.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const KNIGHT_VISUAL_SCRIPT: Script = preload("res://scripts/player/knight_visual.gd")

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
	print("INICIANDO SUÍTE OFICIAL: ATAQUE-SOTN-02 — ART-FIX02")
	print("Validação do Refino Artístico e Alternância F8 (ARM-FIX01 <-> ART-FIX02)")
	print("==================================================================")

	var env: Dictionary = await _setup_test_environment()
	var knight: KnightController = env["knight"]
	var attack: SwordAttack = knight.sword_attack
	var visual: Node2D = knight.visual

	# =================================================================
	# GRUPO A: ESTADO PADRÃO CONSOLIDADO (ART-FIX02 HOMOLOGADO)
	# =================================================================
	print("\n--- GRUPO A: Estado Padrão Consolidado (ART-FIX02 Homologado) ---")
	check(visual != null, "Nó Visual de Aren instanciado no player")
	check(visual.sotn_visual_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02, "Visual mode padrão é rigorosamente ART-FIX02 (versão homologada pelo responsável)")

	# =================================================================
	# GRUPO B: ALTERNÂNCIA DINÂMICA VIA TOGGLE (F8) COM FALLBACK ARM-FIX01
	# =================================================================
	print("\n--- GRUPO B: Alternância Dinâmica via Toggle (F8) com Fallback ---")
	var new_mode = visual.toggle_sotn_visual_mode()
	check(new_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01, "toggle_sotn_visual_mode() comuta com sucesso para ARM-FIX01 (fallback)")
	check(visual.sotn_visual_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01, "Estado ativo atualizado para ARM-FIX01")

	var back_mode = visual.toggle_sotn_visual_mode()
	check(back_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02, "toggle_sotn_visual_mode() retorna com segurança para ART-FIX02")
	check(visual.sotn_visual_mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02, "Estado ativo restaurado para ART-FIX02")

	# =================================================================
	# GRUPO C: EQUIVALÊNCIA MECÂNICA ABSOLUTA ENTRE MODOS VISUAIS
	# =================================================================
	print("\n--- GRUPO C: Equivalência Mecânica Absoluta (M1 Intocado) ---")
	for mode in [KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01, KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02]:
		visual.sotn_visual_mode = mode
		var m_label = "ARM-FIX01" if mode == KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ARM_FIX01 else "ART-FIX02"

		attack.set_mode(SwordAttack.Mode.SOTN)
		check(attack.windup_duration == 0.05, "[%s] Startup nominal congelado em 0.05s" % m_label)
		check(attack.active_duration == 0.05, "[%s] Active nominal congelado em 0.05s" % m_label)
		check(attack.recovery_duration == 0.15, "[%s] Recovery nominal congelado em 0.15s" % m_label)
		check(attack.windup_duration + attack.active_duration + attack.recovery_duration == 0.25, "[%s] Ciclo total congelado em 0.25s" % m_label)
		check(SwordAttack.BUFFER_WINDOW == 0.08, "[%s] Buffer mantido em 0.08s" % m_label)

	# =================================================================
	# GRUPO D: COLISÃO E HITBOX EM ART-FIX02
	# =================================================================
	print("\n--- GRUPO D: Colisão e Hitbox em ART-FIX02 ---")
	visual.sotn_visual_mode = KNIGHT_VISUAL_SCRIPT.SotnVisualMode.ART_FIX02

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

	check(high_hit[0] == 1, "[ART-FIX02] Região Alta atinge alvo aéreo com precisão")
	check(mid_hit[0] == 1, "[ART-FIX02] Região Frontal alcança extensão máxima com precisão")
	check(low_hit[0] == 1, "[ART-FIX02] Região Baixa atinge alvo rente ao solo com precisão")
	check(rear_hit[0] == 0, "[ART-FIX02] Alvo na retaguarda de Aren NÃO é atingido (sem back-hits)")

	target_high.queue_free()
	target_mid.queue_free()
	target_low.queue_free()
	target_rear.queue_free()
	await _frames(2)

	# =================================================================
	# GRUPO E: ANATOMIA E REGISTRO DA ESPADA NAS 8 POSES
	# =================================================================
	print("\n--- GRUPO E: Registro Anatômico da Espada nas 8 Poses ---")
	for pose_idx in range(8):
		var reg = ArenAttackArt.registration(pose_idx)
		check(reg.has("blade") and reg.has("root") and reg.has("scale"), "Pose %d possui chaves de registro completas (blade, root, scale)" % pose_idx)
		var hand_pos: Vector2 = reg["blade"].position
		check(hand_pos.y <= -15.0 and hand_pos.y >= -25.0, "Pose %d hand.y = %.1f alinhado à altura da manopla (entre -15 e -25)" % [pose_idx, hand_pos.y])

	# =================================================================
	# GRUPO F: ESPELHAMENTO HORIZONTAL E DINÂMICA AÉREA
	# =================================================================
	print("\n--- GRUPO F: Espelhamento Horizontal e Dinâmica Aérea ---")
	for f in [1, -1]:
		knight.facing = f
		attack._start_attack(true, f)
		check(attack.phase == SwordAttack.Phase.WINDUP, "Ataque com facing=%d inicia em WINDUP sem erros" % f)
		await _frames(4)
		check(attack.phase == SwordAttack.Phase.ACTIVE, "Ataque com facing=%d transita para ACTIVE sem erros" % f)
		while attack.phase != SwordAttack.Phase.NEUTRAL:
			await _frames(1)

	# Teste de Landing Cancel em ART-FIX02
	knight.reset_to(Vector2(100.0, 175.0))
	knight.velocity = Vector2(0.0, 120.0)
	attack._start_attack(false, 1)
	check(attack.phase != SwordAttack.Phase.NEUTRAL, "Ataque aéreo ART-FIX02 ativo antes do pouso")

	for _i in range(10):
		await _frames(1)
		if knight.is_on_floor():
			break

	check(attack.phase == SwordAttack.Phase.NEUTRAL, "Landing cancel em ART-FIX02 interrompe imediatamente o golpe ao tocar o solo")

	# =================================================================
	# RESULTADO FINAL
	# =================================================================
	print("\n==================================================================")
	print("RESULTADO ART-FIX02: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")

	env["floor"].queue_free()
	knight.queue_free()

	quit(0 if failures == 0 else 1)
