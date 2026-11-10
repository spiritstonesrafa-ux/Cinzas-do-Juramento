extends SceneTree
## Suíte de testes automatizados do combate do Cervo Espectral (M6-CERVO-BOSS).
## Valida os 5 ataques, hitboxes, 3 fases de HP, transições, conclusão cinematográfica e contrajogo.

const CERVO_BOSS_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss.tscn")
const CERVO_ECHO_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss_echo.tscn")
const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const CervoBossAttackSource = preload("res://scripts/boss/cervo_boss_attack_source.gd")
const CervoBossEcho = preload("res://scripts/boss/cervo_boss_echo.gd")
const CervoBossConclusion = preload("res://scripts/boss/cervo_boss_conclusion.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const CervoEchoVisual = preload("res://scripts/boss/cervo_echo_visual.gd")

var total_passed: int = 0
var total_failed: int = 0

func _init() -> void:
	print("\n==================================================")
	print("SUÍTE DE TESTES: COMBATE DO CERVO ESPECTRAL (M6)")
	print("==================================================")
	call_deferred("_run_all_tests")

func check(condition: bool, description: String) -> void:
	if condition:
		total_passed += 1
		print("  [PASS] %s" % description)
	else:
		total_failed += 1
		print("  [FAIL] %s" % description)

func _frames(count: int = 2) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_all_tests() -> void:
	var original_save_bytes: PackedByteArray = []
	var f = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.READ)
	if f != null:
		original_save_bytes = f.get_buffer(f.get_length())
		f.close()
	
	await test_instantiation_and_nodes()
	await test_intro_and_invulnerability()
	await test_attack_mechanics_and_sources()
	await test_echo_mechanics_and_counterplay()
	await test_contact_damage_and_no_multihit()
	await test_phases_and_hp_transitions()
	await test_defeat_and_conclusion_flow()
	await test_simultaneous_death_safety()
	await test_reset_and_cleanup()
	
	if not original_save_bytes.is_empty():
		var fw = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.WRITE)
		if fw != null:
			fw.store_buffer(original_save_bytes)
			fw.close()
	
	print("\n==================================================")
	print("RESULTADO COMBATE CERVO: %d PASSOU, %d FALHOU" % [total_passed, total_failed])
	print("==================================================")
	
	if total_failed > 0:
		quit(1)
	else:
		quit(0)

func _create_dummy_player() -> KnightController:
	var player: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(player)
	player.global_position = Vector2(200, 260)
	return player

func test_instantiation_and_nodes() -> void:
	print("\n--- 1. Instanciação e Nós do Cervo ---")
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	await _frames(2)
	
	check(boss != null, "CervoBoss instanciado com sucesso")
	check(boss.max_health == 14, "HP máximo canônico é 14")
	check(boss.health == 14, "HP inicial é 14")
	check(boss.phase == 1, "Fase inicial é 1")
	check(boss.state == CervoBoss.State.DORMANT, "Estado inicial é DORMANT")
	check(boss.visual != null, "CervoVisual anexado e inicializado")
	check(boss.attack_source != null, "CervoBossAttackSource anexado")
	check(boss.receiver != null, "SwordReceiver anexado")
	check(boss.conclusion != null, "CervoBossConclusion anexado")
	
	boss.queue_free()
	await _frames(2)

func test_intro_and_invulnerability() -> void:
	print("\n--- 2. Introdução e Invulnerabilidade Inicial ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	check(boss.state == CervoBoss.State.INTRO, "begin_fight coloca o chefe em State.INTRO")
	check(boss.facing == -1, "Chefe vira para a esquerda de frente para o jogador")
	check(not boss.attack_source.is_active, "AttackSource inativa durante a introdução")
	
	var initial_hp: int = boss.health
	boss.receive_hit()
	check(boss.health == initial_hp, "Golpe ignorado durante a introdução (sem dano prematuro)")
	
	# Avança o tempo da introdução
	boss._physics_process(2.3)
	check(boss.state == CervoBoss.State.PURSUIT, "Transição para State.PURSUIT após término da introdução")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_attack_mechanics_and_sources() -> void:
	print("\n--- 3. Mecânicas dos Cinco Ataques Oficiais ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	boss.deterministic = true
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	
	# Teste Investida (CHARGE)
	boss._start_attack(CervoBoss.BossAttack.CHARGE)
	check(boss.state == CervoBoss.State.TELEGRAPH, "Investida inicia em TELEGRAPH")
	check(boss.visual.current_state == CervoVisual.AnimState.CHARGE_PREP, "Visual aciona sequência de investida")
	boss._execute_attack()
	check(boss.state == CervoBoss.State.ATTACK_ACTIVE, "Investida avança para ATTACK_ACTIVE")
	check(boss.attack_source.is_active, "Hitbox de investida ativa")
	check(boss.attack_source.current_attack == CervoBossAttackSource.AttackType.CHARGE, "Tipo de hitbox configurado como CHARGE")
	boss._enter_recovery()
	check(boss.state == CervoBoss.State.RECOVERY, "Investida avança para RECOVERY")
	check(not boss.attack_source.is_active, "Hitbox desligada no RECOVERY")
	
	# Teste Corte das Galhadas (ANTLER)
	boss._start_attack(CervoBoss.BossAttack.ANTLER)
	check(boss.visual.current_state == CervoVisual.AnimState.ANTLER_PREP, "Visual aciona sequência das galhadas")
	boss._execute_attack()
	check(boss.attack_source.is_active, "Hitbox das galhadas ativa")
	check(boss.attack_source.current_attack == CervoBossAttackSource.AttackType.ANTLER, "Tipo de hitbox configurado como ANTLER")
	boss._enter_recovery()
	
	# Teste Pisada das Almas (STOMP)
	boss._start_attack(CervoBoss.BossAttack.STOMP)
	check(boss.visual.current_state == CervoVisual.AnimState.STOMP_PREP, "Visual aciona sequência da pisada")
	boss._execute_attack()
	check(boss.attack_source.is_active, "Hitbox da pisada ativa no piso")
	check(boss.attack_source.current_attack == CervoBossAttackSource.AttackType.STOMP, "Tipo de hitbox configurado como STOMP")
	boss._enter_recovery()
	
	# Teste Salto Predatório (LEAP)
	boss._start_attack(CervoBoss.BossAttack.LEAP)
	check(boss.visual.current_state == CervoVisual.AnimState.LEAP_PREP, "Visual aciona sequência do salto")
	boss._execute_attack()
	check(boss.state == CervoBoss.State.ATTACK_ACTIVE, "Salto em execução aérea")
	# Durante a subida inicial o impacto de solo ainda não ocorreu
	check(not boss.attack_source.is_active, "Hitbox de solo inativa durante a ascensão do salto")
	boss._process_attack_active(0.9) # Próximo da aterrissagem
	check(boss.attack_source.is_active, "Impacto de aterrissagem ativado no final do salto")
	boss._enter_recovery()
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_echo_mechanics_and_counterplay() -> void:
	print("\n--- 4. Ecos da Floresta e Contrajogo Legítimo ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	
	boss._start_attack(CervoBoss.BossAttack.ECHOES)
	check(boss.visual.current_state == CervoVisual.AnimState.ECHO_PREP, "Visual aciona sequência dos ecos")
	boss._execute_attack()
	await _frames(2)
	check(boss.active_echoes.size() == 2, "Invocação cria exatamente 2 manifestações espectrais")
	
	var echo_left: CervoBossEcho = boss.active_echoes[0]
	var echo_right: CervoBossEcho = boss.active_echoes[1]
	check(echo_left.facing == -1, "Eco esquerdo direcionado para a esquerda")
	check(echo_right.facing == 1, "Eco direito direcionado para a direita")
	check(echo_left.attack_source.is_active, "Hitbox ofensiva do eco ativa")
	
	# Contrajogo: ataque de espada dissipa o eco
	echo_left._on_sword_hit()
	check(not echo_left.attack_source.is_active, "Golpe de espada desarma imediatamente o eco")
	check(echo_left.visual.echo_state == CervoEchoVisual.EchoState.DISSOLVING, "Eco entra em dissolução visual")
	
	# Disarm dissipa o outro eco
	boss.disarm()
	check(boss.active_echoes.is_empty(), "boss.disarm() remove todos os ecos ativos da lista")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_contact_damage_and_no_multihit() -> void:
	print("\n--- 5. Dano por Contato e Proteção contra Multi-Hit ---")
	var source: CervoBossAttackSource = CervoBossAttackSource.new()
	root.add_child(source)
	await _frames(2)
	
	source.configure(CervoBossAttackSource.AttackType.CHARGE, 1, 101)
	source.set_active(true)
	
	var dmg1: int = source.contact_damage(1)
	check(dmg1 == 1, "Primeiro contato causa 1 ponto de dano")
	
	var dmg2: int = source.contact_damage(1)
	check(dmg2 == 0, "Segundo contato no mesmo ciclo bloqueado (sem dano múltiplo por quadro)")
	
	# Novo ciclo de ataque
	source.configure(CervoBossAttackSource.AttackType.ANTLER, 1, 102)
	source.set_active(true)
	var dmg3: int = source.contact_damage(1)
	check(dmg3 == 1, "Novo ciclo permite novo golpe legítimo de 1 ponto de dano")
	
	source.queue_free()
	await _frames(2)

func test_phases_and_hp_transitions() -> void:
	print("\n--- 6. Três Fases de HP e Transições Suaves ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	
	check(boss.phase == 1, "Inicia na Fase 1 com 14 HP")
	
	# Dano até 10 HP (ainda fase 1)
	for i in range(4):
		boss.receive_hit()
	check(boss.health == 10, "HP reduzido para 10")
	check(boss.phase == 1, "Permanece na Fase 1 com 10 HP")
	
	# 5º golpe: HP vai para 9 -> ativa transição para Fase 2
	boss.receive_hit()
	check(boss.health == 9, "HP reduzido para 9")
	check(boss.phase == 2, "HP <= 9 transita para Fase 2")
	check(boss.state == CervoBoss.State.PHASE_TRANSITION, "Estado transita para PHASE_TRANSITION")
	
	boss._physics_process(1.0)
	check(boss.state == CervoBoss.State.PURSUIT, "Após intervalo, volta a State.PURSUIT")
	
	# Dano até 4 HP -> ativa transição para Fase 3
	for i in range(5):
		boss.receive_hit()
	check(boss.health == 4, "HP reduzido para 4")
	check(boss.phase == 3, "HP <= 4 transita para Fase 3")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_defeat_and_conclusion_flow() -> void:
	print("\n--- 7. Derrota e Conclusão Cinematográfica ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	
	# Fase 1 para 2 (5 golpes)
	for i in range(5):
		boss.receive_hit()
	if boss.state == CervoBoss.State.PHASE_TRANSITION:
		boss._physics_process(1.0)
	
	# Fase 2 para 3 (5 golpes)
	for i in range(5):
		boss.receive_hit()
	if boss.state == CervoBoss.State.PHASE_TRANSITION:
		boss._physics_process(1.0)
	
	# Fase 3 até a derrota (4 golpes)
	for i in range(4):
		boss.receive_hit()
	
	check(boss.health == 0, "HP reduzido a zero")
	check(boss.state == CervoBoss.State.DEFEATED, "Estado torna-se DEFEATED")
	check(not boss.attack_source.is_active, "Fontes de ataque completamente desarmadas na derrota")
	
	# Conclusão cinemática
	check(boss.conclusion.played, "Conclusão cinematográfica iniciada")
	check(boss.conclusion.running, "Sequência cinematográfica em execução")
	
	# Avança física para completar os 3.6s de conclusão
	boss.conclusion._physics_process(3.7)
	check(boss.conclusion.settled, "Conclusão consolidada com sucesso")
	check(player.spectral_jump_unlocked, "Salto Espectral concedido com sucesso ao jogador")
	check(ABBEY_PROGRESS.spectral_jump_unlocked(), "Salto Espectral persistido no AbbeyProgress")
	check(ABBEY_PROGRESS.is_cervo_defeated(), "Flag cervo_defeated confirmada no progresso")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_simultaneous_death_safety() -> void:
	print("\n--- 8. Segurança contra Morte Simultânea ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	
	# Dano até a derrota
	for i in range(5): boss.receive_hit()
	if boss.state == CervoBoss.State.PHASE_TRANSITION: boss._physics_process(1.0)
	for i in range(5): boss.receive_hit()
	if boss.state == CervoBoss.State.PHASE_TRANSITION: boss._physics_process(1.0)
	for i in range(4): boss.receive_hit()
	
	check(boss.conclusion.running, "Conclusão cinemática rodando")
	
	# Jogador morre durante a conclusão
	player.survival.receive_damage(99)
	check(player.survival.is_dead, "Jogador faleceu")
	check(not boss.conclusion.running, "Conclusão cancelada imediatamente na morte do jogador")
	check(not boss.conclusion.settled, "Recompensa NÃO concedida prematuramente em caso de morte simultânea")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)

func test_reset_and_cleanup() -> void:
	print("\n--- 9. Reset de Encontro e Limpeza de Estado ---")
	var player: KnightController = _create_dummy_player()
	var boss: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	root.add_child(boss)
	boss.global_position = Vector2(400, 260)
	await _frames(2)
	
	boss.begin_fight(player)
	boss.health = 5
	boss.phase = 2
	
	boss.reset_encounter()
	check(boss.health == 14, "HP restaurado para 14")
	check(boss.phase == 1, "Fase restaurada para 1")
	check(boss.state == CervoBoss.State.DORMANT, "Estado restaurado para DORMANT")
	check(not boss.attack_source.is_active, "AttackSource desativada no reset")
	
	boss.queue_free()
	player.queue_free()
	await _frames(2)
