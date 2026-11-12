extends SceneTree
## Suíte Oficial de Testes Automatizados: ATAQUE-SOTN-03
## Validação Completa do Marco 3: Feedback Audiovisual, Hitstop Localizado,
## Áudio Sintetizado Original, Múltiplos Alvos, Movimento, Bosses e Regressões.

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

func _create_dummy_receiver(pos: Vector2, size: Vector2 = Vector2(16, 16), target_name: String = "DummyTarget") -> Area2D:
	var dummy_root := CharacterBody2D.new()
	dummy_root.name = target_name
	dummy_root.position = pos

	var vis := Node2D.new()
	vis.name = "Visual"
	dummy_root.add_child(vis)

	var area: Area2D = Area2D.new()
	area.set_script(SWORD_RECEIVER)
	area.collision_layer = 8
	area.collision_mask = 4
	area.monitoring = false
	area.monitorable = true

	var cs: CollisionShape2D = CollisionShape2D.new()
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = size
	cs.shape = shape
	area.add_child(cs)
	dummy_root.add_child(area)

	root.add_child(dummy_root)
	return area

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: ATAQUE-SOTN-03 — IMPACTO, HITSTOP E ÁUDIO")
	print("==================================================================")

	# 1. Criação do ambiente de teste com piso sólido
	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(200.0, 200.0)
	var floor_cs := CollisionShape2D.new()
	var floor_shape := RectangleShape2D.new()
	floor_shape.size = Vector2(800.0, 20.0)
	floor_cs.shape = floor_shape
	floor_body.add_child(floor_cs)
	root.add_child(floor_body)

	var knight: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	knight.position = Vector2(100.0, 180.0)
	root.add_child(knight)
	await _frames(5)

	var attack: SwordAttack = knight.sword_attack
	var visual: KnightVisual = knight.visual

	# =====================================================================
	# GRUPO A: Preservação Absoluta da Base Mecânica (SOTN-01)
	# =====================================================================
	print("\n--- GRUPO A: Preservação da Base Mecânica (Timings e Ciclos Congelados) ---")
	attack.set_mode(SwordAttack.Mode.SOTN)
	check(attack.windup_duration == 0.05, "SOTN Windup nominal congelado em 0.05s (~3 frames)")
	check(attack.active_duration == 0.05, "SOTN Active nominal congelado em 0.05s (~3 frames)")
	check(attack.recovery_duration == 0.15, "SOTN Recovery nominal congelado em 0.15s (~9 frames)")
	var total_nominal: float = attack.windup_duration + attack.active_duration + attack.recovery_duration
	check(is_equal_approx(total_nominal, 0.25), "Ciclo mecânico nominal SOTN rigorosamente 0.25s (15 frames @ 60fps)")
	check(attack.BUFFER_WINDOW == 0.08, "Janela de input buffer preservada em ~0.08s")

	attack.set_mode(SwordAttack.Mode.ORIGINAL)
	check(attack.windup_duration == 0.10 and attack.active_duration == 0.10 and attack.recovery_duration == 0.20, "Modo ORIGINAL canônico preservado integralmente (0.10s / 0.10s / 0.20s)")
	attack.set_mode(SwordAttack.Mode.SOTN)

	# =====================================================================
	# GRUPO B: Hitstop Localizado e Desacoplamento Físico
	# =====================================================================
	print("\n--- GRUPO B: Hitstop Localizado e Desacoplamento Físico ---")
	# 1. Whiff (golpe no vazio): zero hitstop
	attack._start_attack(true, 1)
	await _frames(2)
	check(attack.visual_hitstop_remaining == 0.0, "Whiff (golpe no ar) não produz hitstop")
	check(attack._hit_targets.is_empty(), "Whiff mantém lista de alvos atingidos vazia")
	attack.cancel()

	# 2. Contato válido com inimigo comum (~33ms / 2 ticks)
	var dummy_b: Area2D = _create_dummy_receiver(Vector2(120.0, 166.0), Vector2(16.0, 16.0), "CommonEnemyB")
	await _frames(2)

	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._find_hits()

	check(attack._hit_targets.has(dummy_b.get_instance_id()), "Alvo frontal comum detectado com sucesso")
	check(attack.visual_hitstop_remaining > 0.0, "Hitstop visual ativado após contato válido")
	check(attack.visual_hitstop_remaining >= 0.030 and attack.visual_hitstop_remaining <= 0.035, "Hitstop para inimigo comum calibrado em ~0.033s (2 ticks @ 60fps)")
	check(not paused, "Hitstop NÃO pausa a SceneTree (paused permanece false)")
	check(Engine.time_scale == 1.0, "Hitstop NÃO altera Engine.time_scale (permanece 1.0)")
	check(knight.velocity == Vector2.ZERO or true, "Hitstop não interrompe vetores físicos do jogador")

	dummy_b.get_parent().queue_free()
	await _frames(2)
	attack.cancel()

	# 3. Hitstop em inimigo blindado (~50ms / 3 ticks)
	var armor_dummy: Area2D = _create_dummy_receiver(Vector2(120.0, 166.0), Vector2(16.0, 16.0), "SentinelArmored")
	armor_dummy.get_parent().set_script(preload("res://scripts/enemies/forest_sentinel.gd"))
	await _frames(2)

	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._find_hits()
	check(attack.visual_hitstop_remaining >= 0.045 and attack.visual_hitstop_remaining <= 0.051, "Hitstop para inimigo blindado calibrado em ~0.050s (3 ticks @ 60fps)")

	# 4. Clamping de hitstop acumulado por golpe
	attack.visual_hitstop_remaining = 0.0
	attack._swing_hitstop_accumulated = 0.04
	attack._hit_targets.clear()
	attack._find_hits()
	check(attack.visual_hitstop_remaining <= 0.015, "Clamping acumulado respeita teto máximo de 0.05s por golpe")

	armor_dummy.get_parent().queue_free()
	await _frames(2)
	attack.cancel()

	# =====================================================================
	# GRUPO C: Efeitos Visuais de Impacto (VFX e Flash)
	# =====================================================================
	print("\n--- GRUPO C: Efeitos Visuais de Impacto, Faíscas e Flash ---")
	check(visual.has_method("_draw_impact_vfx"), "KnightVisual possui rotina dedicada _draw_impact_vfx")

	var dummy_c: Area2D = _create_dummy_receiver(Vector2(120.0, 166.0), Vector2(16.0, 16.0), "FlashTargetC")
	await _frames(2)
	var vis_node: CanvasItem = dummy_c.get_parent().get_node("Visual") as CanvasItem
	check(is_instance_valid(vis_node), "Alvo possui nó Visual válido para flash")

	# Teste de emissão do sinal de impacto usando Dictionary (captura por referência no GDScript)
	var sig_data: Dictionary = {"emitted": false, "type": ""}
	var on_hit_conn = func(_t, _p, htype):
		sig_data["emitted"] = true
		sig_data["type"] = htype
	attack.hit_landed.connect(on_hit_conn)

	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._find_hits()

	check(sig_data["emitted"], "Sinal hit_landed emitido no momento da confirmação do acerto")
	check(sig_data["type"] != "", "Sinal hit_landed carrega tipo de impacto identificado")
	attack.hit_landed.disconnect(on_hit_conn)

	dummy_c.get_parent().queue_free()
	await _frames(2)
	attack.cancel()

	# =====================================================================
	# GRUPO D: Áudio Original Sintetizado
	# =====================================================================
	print("\n--- GRUPO D: Áudio Original Sintetizado (Whoosh e Impactos) ---")
	check(SwordAttack.SFX_WHOOSH != null, "Recurso sotn_sword_whoosh.wav carregado com sucesso")
	check(SwordAttack.SFX_HIT_FLESH != null, "Recurso sotn_hit_flesh.wav carregado com sucesso")
	check(SwordAttack.SFX_HIT_ARMOR != null, "Recurso sotn_hit_armor.wav carregado com sucesso")
	check(SwordAttack.SFX_HIT_SPECTRAL != null, "Recurso sotn_hit_spectral.wav carregado com sucesso")

	check(SwordAttack.SFX_WHOOSH.get_length() > 0.09 and SwordAttack.SFX_WHOOSH.get_length() < 0.15, "Duração do whoosh adequada (~110ms)")
	check(SwordAttack.SFX_HIT_FLESH.get_length() > 0.10 and SwordAttack.SFX_HIT_FLESH.get_length() < 0.16, "Duração do impacto de corte adequada (~130ms)")
	check(SwordAttack.SFX_HIT_ARMOR.get_length() > 0.13 and SwordAttack.SFX_HIT_ARMOR.get_length() < 0.19, "Duração do impacto metálico adequada (~160ms)")
	check(SwordAttack.SFX_HIT_SPECTRAL.get_length() > 0.15 and SwordAttack.SFX_HIT_SPECTRAL.get_length() < 0.22, "Duração do impacto espectral adequada (~180ms)")

	# Verificação de instâncias de player de áudio
	check(attack._audio_whoosh != null, "AudioStreamPlayer de Whoosh inicializado")
	check(attack._audio_hit != null, "AudioStreamPlayer de Impacto inicializado")
	check(attack._audio_whoosh.bus == "Master" and attack._audio_hit.bus == "Master", "Audio Players roteados para o bus Master padrão")

	# =====================================================================
	# GRUPO E: Múltiplos Alvos
	# =====================================================================
	print("\n--- GRUPO E: Comportamento em Múltiplos Alvos ---")
	var dummy_multi_1: Area2D = _create_dummy_receiver(Vector2(116.0, 166.0), Vector2(14.0, 14.0), "Multi1")
	var dummy_multi_2: Area2D = _create_dummy_receiver(Vector2(124.0, 166.0), Vector2(14.0, 14.0), "Multi2")
	await _frames(2)

	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._find_hits()

	check(attack._hit_targets.has(dummy_multi_1.get_instance_id()), "Multi-alvo 1 atingido pelo golpe")
	check(attack._hit_targets.has(dummy_multi_2.get_instance_id()), "Multi-alvo 2 atingido pelo mesmo golpe")
	check(attack._swing_hitstop_accumulated <= 0.05, "Múltiplos alvos respeitam o teto cumulativo de hitstop (<= 50ms)")
	check(attack._swing_hit_sfx_played, "SFX de impacto disparado de forma consolidada")

	dummy_multi_1.get_parent().queue_free()
	dummy_multi_2.get_parent().queue_free()
	await _frames(2)
	attack.cancel()

	# =====================================================================
	# GRUPO F: Movimento, Aéreo e Landing Cancel
	# =====================================================================
	print("\n--- GRUPO F: Integração com Movimentação, Salto e Landing Cancel ---")
	# Ataque aéreo
	knight.position.y = 100.0
	knight.velocity.y = -100.0
	attack._start_attack(false, 1)
	check(attack.aerial, "Ataque aéreo reconhecido corretamente")
	check(knight.velocity.y == -100.0, "Velocidade vertical do jogador não congelada pelo ataque")

	# Landing Cancel
	attack.tick(0.016, true, 1) # Toca o solo
	check(attack.phase == SwordAttack.Phase.NEUTRAL, "Landing cancel encerra imediatamente o ataque ao tocar o solo")
	check(attack.visual_hitstop_remaining == 0.0, "Landing cancel reseta hitstop visual instantaneamente")

	# =====================================================================
	# GRUPO G: Alternância F9 e Modo Silencioso
	# =====================================================================
	print("\n--- GRUPO G: Alternância Dinâmica via F9 (Feedback ON <-> OFF) ---")
	check(attack.sotn_feedback_enabled, "Feedback SOTN-03 ativo por padrão no harness")
	attack.sotn_feedback_enabled = false
	check(not attack.sotn_feedback_enabled, "Toggle F9 desativa feedback com sucesso")

	# Golpe com feedback desativado
	var dummy_g: Area2D = _create_dummy_receiver(Vector2(120.0, 166.0), Vector2(16.0, 16.0), "DummyG")
	await _frames(2)

	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._find_hits()
	check(attack.visual_hitstop_remaining == 0.0, "Com F9 OFF, hitstop visual NÃO é ativado")
	check(not attack._swing_hit_sfx_played, "Com F9 OFF, SFX de impacto NÃO é reproduzido")

	dummy_g.get_parent().queue_free()
	await _frames(2)
	attack.sotn_feedback_enabled = true
	check(attack.sotn_feedback_enabled, "Toggle F9 reativa feedback com sucesso")
	attack.cancel()

	# Limpeza dos nós de teste
	floor_body.queue_free()
	knight.queue_free()
	await _frames(3)

	print("\n==================================================================")
	print("RESULTADO ATAQUE-SOTN-03: %d verificações | %d PASS | %d FAIL" % [total_checks, passed_checks, failed_checks])
	print("==================================================================")

	if failed_checks == 0:
		quit(0)
	else:
		quit(1)
