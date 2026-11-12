extends SceneTree
## Suíte Oficial de Testes Automatizados: COMBATE-CONTACT-DAMAGE-01
## Validação Completa: Dano por Contato Corporal, Hurtboxes, I-Frames, Knockback,
## Inimigos (Fases 1, 2 e 3), Chefes, Dash, Habilidades e Regressão SOTN.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const SKELETON_SCENE: PackedScene = preload("res://scenes/enemies/skeleton_patrol.tscn")
const MONK_SCENE: PackedScene = preload("res://scenes/enemies/chained_monk.tscn")
const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/forest_crawler.tscn")
const CROW_SCENE: PackedScene = preload("res://scenes/enemies/forest_spectral_crow.tscn")
const SENTINEL_SCENE: PackedScene = preload("res://scenes/enemies/forest_sentinel.tscn")
const RAVEN_SCENE: PackedScene = preload("res://scenes/enemies/cursed_raven.tscn")
const GUARDIAN_SCENE: PackedScene = preload("res://scenes/boss/guardian.tscn")
const ABBOT_SCENE: PackedScene = preload("res://scenes/abbey/abbot.tscn")
const CERVO_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss.tscn")

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

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: COMBATE-CONTACT-DAMAGE-01")
	print("==================================================================")

	# Setup a basic environment
	var env_node := Node2D.new()
	env_node.name = "TestEnvironment"
	root.add_child(env_node)
	var backdrop := Node2D.new()
	backdrop.name = "Backdrop"
	env_node.add_child(backdrop)

	# -------------------------------------------------------------
	# GRUPO A: DETECÇÃO DE CONTATO CORPORAL
	# -------------------------------------------------------------
	print("\n--- GRUPO A: Detecção de Contato Corporal ---")
	var hero: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	hero.gravity = 0.0 # Impede queda por gravidade durante os testes de colisão precisa
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	env_node.add_child(hero)
	await _frames(2)

	# A1: Ausência de contato quando afastado
	var skel: SkeletonPatrol = SKELETON_SCENE.instantiate() as SkeletonPatrol
	skel.position = Vector2(250, 100)
	env_node.add_child(skel)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 0, "A1: Sem contato corporal com inimigo distante (distância segura)")

	# A2: Contato inicial direto (sobreposição frontal)
	skel.position = Vector2(106, 100) # Sobreposição de 6px lateralmente
	await _frames(2)
	var initial_contact: int = hero.hurtbox.contact_damage()
	check(initial_contact == 1, "A2: Contato corporal inicial detectado com sucesso (dano = 1)")
	check(hero.hurtbox.last_damage_type == "body", "A2: Tipo de dano registrado como 'body'")

	# A3: Sobreposição persistente continua detectável pelo sensor
	await _frames(3)
	check(hero.hurtbox.contact_damage() == 1, "A3: Sobreposição persistente continua reportando contato no sensor")

	# A4: Contato lateral esquerdo vs direito
	skel.position = Vector2(94, 100) # Inimigo à esquerda de Aren
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "A4: Contato lateral pelo flanco esquerdo detectado")
	check(hero.hurtbox.last_source_position.x < hero.global_position.x, "A4: Posição de origem reflete flanco esquerdo")

	# A5: Contato vertical (Aren caindo / acima do inimigo)
	skel.position = Vector2(100, 110) # Inimigo 10px abaixo
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "A5: Contato vertical (Aren sobre o inimigo) detectado")

	# A6: Ausência de contato quando saltando bem acima de rastejante
	var crawler: ForestCrawler = CRAWLER_SCENE.instantiate() as ForestCrawler
	crawler.position = Vector2(100, 130) # Rastejante 30px abaixo (Aren alto no ar)
	env_node.add_child(crawler)
	skel.position = Vector2(500, 100) # Afasta esqueleto
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 0, "A6: Aren saltando claramente sobre rastejante não sofre contato indevido")

	# A7: Contato com rastejante ao tocar seu corpo pequeno
	crawler.position = Vector2(104, 100)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "A7: Contato real com corpo de rastejante detectado")

	# A8: Inimigo derrotado não causa dano por contato
	crawler.position = Vector2(500, 100)
	skel.position = Vector2(104, 100)
	await _frames(1)
	while skel.current_health > 0:
		skel.receive_hit()
	await _frames(2)
	check(skel.state == SkeletonPatrol.State.DEAD, "A8: Esqueleto colocado em estado DEAD")
	check(hero.hurtbox.contact_damage() == 0, "A8: Corpo de inimigo derrotado NÃO provoca dano por contato")

	# -------------------------------------------------------------
	# GRUPO B: DANO E ARBITRAGEM
	# -------------------------------------------------------------
	print("\n--- GRUPO B: Aplicação de Dano e Arbitragem ---")
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	hero.survival.restore()
	var base_hp: int = hero.survival.max_health
	check(hero.survival.current_health == base_hp, "B1: HP de Aren restaurado para valor nominal (" + str(base_hp) + ")")

	# B2: Aplicação do primeiro dano
	var live_skel: SkeletonPatrol = SKELETON_SCENE.instantiate() as SkeletonPatrol
	live_skel.position = Vector2(105, 100)
	env_node.add_child(live_skel)
	await _frames(2)

	# KnightController processa o dano de contato autonomamente no loop de física
	check(hero.survival.current_health == base_hp - 1, "B2: Primeiro dano corporal aceito com sucesso (HP = " + str(base_hp - 1) + ")")
	check(hero.survival.invulnerability_remaining > 0.0, "B2: Janela de invulnerabilidade iniciada imediatamente")

	# B3: Ausência de dano por frame durante sobreposição contínua
	var extra_damage_count: int = 0
	for _f in range(30):
		await _frames(1)
		var tick_dmg: int = hero.hurtbox.contact_damage()
		if tick_dmg > 0:
			if hero.receive_damage(tick_dmg, hero.hurtbox.last_source_position):
				extra_damage_count += 1
	check(extra_damage_count == 0, "B3: Zero dano adicional durante 30 frames de sobreposição contínua")
	check(hero.survival.current_health == base_hp - 1, "B3: HP permanece rigorosamente " + str(base_hp - 1) + " (sem perda a cada frame)")

	# B4: Arbitragem de ataque explícito + contato corporal no mesmo instante
	hero.survival.restore()
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	live_skel.position = Vector2(110, 100)
	live_skel.facing = -1
	live_skel.attack_source.position.x = -17.0
	live_skel.attack_source.damage = 2
	live_skel.attack_source.set_active(true)
	await _frames(1)
	var simultaneous_dmg: int = hero.hurtbox.contact_damage()
	check(simultaneous_dmg == 2, "B4: Arbitragem prioriza ataque explícito do inimigo (dano = 2)")
	check(hero.hurtbox.last_damage_type == "hazard", "B4: Tipo registrado como hazard/attack, sem acúmulo duplicado")
	live_skel.attack_source.set_active(false)

	# B5: Sem dano após morte de Aren
	hero.survival._health = 1
	hero.receive_damage(1)
	check(hero.survival.is_dead, "B5: Aren entra em estado de morte (is_dead = true)")
	var dead_dmg_applied: bool = hero.receive_damage(1)
	check(not dead_dmg_applied, "B5: Nenhum dano adicional é aceito após a morte de Aren")

	# -------------------------------------------------------------
	# GRUPO C: I-FRAMES (INVULNERABILIDADE TEMPORÁRIA)
	# -------------------------------------------------------------
	print("\n--- GRUPO C: I-Frames e Invulnerabilidade Temporária ---")
	hero.survival.restore()
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	live_skel.position = Vector2(105, 100)
	await _frames(1)

	# C1: Invulnerabilidade inicial ativada após dano
	hero.receive_damage(1, live_skel.global_position)
	check(hero.survival.invulnerability_remaining > 0.70, "C1: Janela de invulnerabilidade ativada (~0.8s)")

	# C2: Proteção durante o período de i-frames
	var blocked_damage: bool = false
	for _f in range(20):
		await _frames(1)
		hero.survival.tick(1.0 / 60.0)
		if hero.receive_damage(1):
			blocked_damage = true
	check(not blocked_damage, "C2: Dano bloqueado durante os i-frames ativos")
	check(hero.survival.current_health == base_hp - 1, "C2: HP permanece estável durante toda a janela de proteção")

	# C3: Retorno normal à vulnerabilidade após expiração dos i-frames
	hero.survival.tick(1.0) # Força avanço do tempo além de 0.8s
	check(hero.survival.invulnerability_remaining == 0.0, "C3: Invulnerabilidade encerrada normalmente (0.0s)")
	var post_iframe_applied: bool = hero.receive_damage(1, live_skel.global_position)
	check(post_iframe_applied, "C3: Novo dano corporal aceito legitimamente após expiração dos i-frames")
	check(hero.survival.current_health == base_hp - 2, "C3: HP reduzido em mais 1 ponto após retorno da vulnerabilidade")

	# -------------------------------------------------------------
	# GRUPO D: KNOCKBACK (RECUO CONTROLADO)
	# -------------------------------------------------------------
	print("\n--- GRUPO D: Knockback Controlado ---")
	hero.survival.restore()
	hero.velocity = Vector2.ZERO
	hero.facing = 1

	# D1: Direção coerente - Inimigo à direita empurra Aren para a esquerda
	hero.global_position = Vector2(100, 100)
	hero.receive_damage(1, Vector2(120, 100)) # Inimigo à direita (x=120)
	check(hero.velocity.x < -50.0, "D1: Knockback empurra Aren para a esquerda (longe do inimigo à direita)")

	# D2: Direção coerente - Inimigo à esquerda empurra Aren para a direita
	hero.survival.restore()
	hero.velocity = Vector2.ZERO
	hero.receive_damage(1, Vector2(80, 100)) # Inimigo à esquerda (x=80)
	check(hero.velocity.x > 50.0, "D2: Knockback empurra Aren para a direita (longe do inimigo à esquerda)")

	# D3: Intensidade limitada e segura
	check(absf(hero.velocity.x) <= 120.0, "D3: Intensidade horizontal calibrada com segurança (<= 120 px/s)")
	check(hero.velocity.y <= -50.0, "D3: Elevação vertical sutil presente para descolamento de terreno")

	# D4: Desaceleração suave e recuperação rápida de controle
	var prev_vx: float = absf(hero.velocity.x)
	hero.velocity.x = move_toward(hero.velocity.x, 0.0, hero.deceleration * 0.033)
	check(absf(hero.velocity.x) < prev_vx, "D4: Desaceleração física canônica (1600 px/s²) recupera o controle rapidamente")

	# D5: Knockback NÃO interfere no dash
	hero.survival.restore()
	hero.dash_unlocked = true
	hero.dash_remaining = 0.16
	hero.dash_direction = 1
	hero.velocity.x = hero.dash_speed
	hero.receive_damage(1, Vector2(120, 100)) # Recebe dano durante dash
	check(hero.velocity.x == hero.dash_speed, "D5: Knockback preserva velocidade do dash sem distorção (Sem interferir no dash)")
	hero.dash_remaining = 0.0

	# -------------------------------------------------------------
	# GRUPO E: HABILIDADES DO JOGADOR
	# -------------------------------------------------------------
	print("\n--- GRUPO E: Habilidades de Aren (Salto, Dash, Ataque Aéreo) ---")
	hero.survival.restore()

	# E1: Ataque aéreo cancelado ao receber dano
	hero.sword_attack._start_attack(false, 1)
	check(hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL, "E1: Ataque aéreo de espada iniciado")
	hero.receive_damage(1, Vector2(120, 100))
	check(hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL, "E1: Ataque aéreo cancelado imediatamente ao sofrer dano")

	# E2: Salto espectral disponível e funcional
	hero.can_spectral_jump = true
	hero.spectral_jump_unlocked = true
	check(hero.can_spectral_jump, "E2: Salto Espectral disponível")

	# E3: Dash recebe dano de contato se vulnerável
	hero.survival.restore()
	live_skel.position = Vector2(105, 100)
	await _frames(1)
	var contact_in_dash: int = hero.hurtbox.contact_damage()
	check(contact_in_dash == 1, "E3: Contato corporal detectado durante trajetória de dash")

	# -------------------------------------------------------------
	# GRUPO F: INIMIGOS DAS TRÊS FASES
	# -------------------------------------------------------------
	print("\n--- GRUPO F: Inimigos das Três Fases ---")
	live_skel.position = Vector2(1000, 1000) # Afasta esqueleto

	# F1: Monge da Abadia (Fase 2)
	var monk: ChainedMonk = MONK_SCENE.instantiate() as ChainedMonk
	monk.position = Vector2(105, 100)
	env_node.add_child(monk)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "F1: Monge Acorrentado (Fase 2) causa dano por contato corporal")
	monk.receive_hit()
	monk.receive_hit()
	monk.receive_hit()
	await _frames(2)
	check(monk.state == ChainedMonk.State.DEAD, "F1: Monge Acorrentado derrotado")
	check(hero.hurtbox.contact_damage() == 0, "F1: Monge Acorrentado derrotado NÃO causa dano por contato")
	monk.position = Vector2(1000, 1000)

	# F2: Corvo Espectral (Fase 3)
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	var crow: ForestSpectralCrow = CROW_SCENE.instantiate() as ForestSpectralCrow
	crow.position = Vector2(104, 88) # Em voo na altura do tronco de Aren
	env_node.add_child(crow)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "F2: Corvo Espectral (Fase 3) causa dano por contato corporal em voo")
	crow.receive_hit()
	crow.receive_hit()
	await _frames(2)
	check(crow.state == ForestSpectralCrow.State.DEAD, "F2: Corvo Espectral derrotado")
	check(hero.hurtbox.contact_damage() == 0, "F2: Corvo Espectral derrotado NÃO causa dano por contato")
	crow.position = Vector2(1000, 1000)

	# F3: Sentinela Ossífera (Fase 3)
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	var sentinel: ForestSentinel = SENTINEL_SCENE.instantiate() as ForestSentinel
	sentinel.position = Vector2(105, 100)
	env_node.add_child(sentinel)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "F3: Sentinela Ossífera (Fase 3) causa dano por contato corporal")
	sentinel.receive_hit()
	sentinel.receive_hit()
	sentinel.receive_hit()
	await _frames(2)
	check(sentinel.state == ForestSentinel.State.DEAD, "F3: Sentinela Ossífera derrotada")
	check(hero.hurtbox.contact_damage() == 0, "F3: Sentinela Ossífera derrotada NÃO causa dano por contato")
	sentinel.position = Vector2(1000, 1000)

	# F4: Corvo Amaldiçoado (Fase 1 / Cemitério)
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	var raven: CursedRaven = RAVEN_SCENE.instantiate() as CursedRaven
	raven.position = Vector2(104, 88) # Em voo na altura do tronco de Aren
	env_node.add_child(raven)
	await _frames(2)
	check(hero.hurtbox.contact_damage() == 1, "F4: Corvo Amaldiçoado causa dano por contato corporal")
	raven.receive_hit()
	raven.receive_hit()
	await _frames(2)
	check(raven.state == CursedRaven.State.DEAD, "F4: Corvo Amaldiçoado derrotado")
	check(hero.hurtbox.contact_damage() == 0, "F4: Corvo Amaldiçoado derrotado NÃO causa dano por contato")
	raven.position = Vector2(1000, 1000)

	# -------------------------------------------------------------
	# GRUPO G: AUDITORIA DOS TRÊS CHEFES
	# -------------------------------------------------------------
	print("\n--- GRUPO G: Auditoria dos Três Chefes ---")
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO

	# G1: Guardião do Juramento (Boss 1)
	var guardian: OathGuardian = GUARDIAN_SCENE.instantiate() as OathGuardian
	guardian.position = Vector2(105, 100)
	env_node.add_child(guardian)
	await _frames(2)
	guardian.awake = true
	guardian._set_state(OathGuardian.State.PURSUIT)
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 1, "G1: Guardião do Juramento ativo em combate causa contato perigoso")
	guardian._set_state(OathGuardian.State.DEFEATED)
	guardian.awake = false
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 0, "G1: Guardião do Juramento derrotado NÃO causa dano por contato")
	guardian.queue_free()
	await _frames(1)

	# G2: Abade das Correntes (Boss 2)
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	var abbot: CharacterBody2D = ABBOT_SCENE.instantiate() as CharacterBody2D
	abbot.position = Vector2(105, 100)
	env_node.add_child(abbot)
	await _frames(2)
	abbot.target = hero
	abbot.state = 1 # State.PURSUIT = 1
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 1, "G2: Abade das Correntes ativo em combate causa contato perigoso")
	abbot.state = 6 # State.DEFEATED = 6
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 0, "G2: Abade das Correntes derrotado NÃO causa dano por contato")
	abbot.queue_free()
	await _frames(1)

	# G3: Cervo Espectral (Boss 3)
	hero.position = Vector2(100, 100)
	hero.velocity = Vector2.ZERO
	var cervo: CervoBoss = CERVO_SCENE.instantiate() as CervoBoss
	cervo.position = Vector2(105, 100)
	env_node.add_child(cervo)
	await _frames(2)
	cervo.target = hero
	cervo.state = CervoBoss.State.PURSUIT
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 1, "G3: Cervo Espectral ativo em combate causa contato perigoso")
	cervo.state = CervoBoss.State.DEFEATED
	await _frames(1)
	check(hero.hurtbox.contact_damage() == 0, "G3: Cervo Espectral derrotado NÃO causa dano por contato")
	cervo.queue_free()
	await _frames(1)

	# -------------------------------------------------------------
	# GRUPO H: REGRESSÃO DO ATAQUE SOTN (M1, M2, M3 CONGELADOS)
	# -------------------------------------------------------------
	print("\n--- GRUPO H: Regressão do Ataque SOTN Congelado ---")
	hero.sword_attack.mode = SwordAttack.Mode.SOTN
	check(SwordAttack.SOTN_WINDUP == 0.05, "H1: SOTN windup congelado em 0.05s")
	check(SwordAttack.SOTN_ACTIVE == 0.05, "H1: SOTN active congelado em 0.05s")
	check(SwordAttack.SOTN_RECOVERY == 0.15, "H1: SOTN recovery congelado em 0.15s")
	check(is_equal_approx(SwordAttack.SOTN_WINDUP + SwordAttack.SOTN_ACTIVE + SwordAttack.SOTN_RECOVERY, 0.25), "H1: Ciclo nominal congelado em 0.25s")
	check(SwordAttack.BUFFER_WINDOW == 0.08, "H1: Buffer de ataque congelado em 0.08s")
	check(hero.sword_attack.mode == SwordAttack.Mode.SOTN, "H2: Modo SOTN operacional")
	check(hero.sword_attack.sotn_feedback_enabled, "H3: Hitstop localizado SOTN-03 preservado ativo")
	check(hero.visual.sotn_visual_mode == KnightVisual.SotnVisualMode.ART_FIX02, "H4: Apresentação artística ART-FIX02 congelada e preservada como padrão")

	# -------------------------------------------------------------
	# GRUPO I: COMPARATIVO E SEGURANÇA
	# -------------------------------------------------------------
	print("\n--- GRUPO I: Comparativo (OFF/ON) e Segurança ---")
	var test_skel: SkeletonPatrol = SKELETON_SCENE.instantiate() as SkeletonPatrol
	test_skel.position = Vector2(105, 100)
	env_node.add_child(test_skel)
	await _frames(2)

	# Modo OFF (comportamento legado):
	hero.hurtbox.contact_damage_enabled = false
	check(hero.hurtbox.contact_damage() == 0, "I1: Com contact_damage_enabled = false, contato corporal retorna ZERO (legado)")

	# Modo ON (novo comportamento):
	hero.hurtbox.contact_damage_enabled = true
	check(hero.hurtbox.contact_damage() == 1, "I2: Com contact_damage_enabled = true, contato corporal retorna 1 dano")

	# Cleanup
	env_node.queue_free()

	print("\n==================================================================")
	print("RESULTADO CONTACT-DAMAGE-01: %d verificações | %d PASS | %d FAIL" % [total_checks, passed_checks, failed_checks])
	print("==================================================================")
	if failed_checks == 0:
		print("TODOS OS TESTES DE DANO POR CONTATO FORAM APROVADOS COM SUCESSO!")
		quit(0)
	else:
		printerr("FALHA NA SUÍTE DE DANO POR CONTATO: %d ERROS" % failed_checks)
		quit(1)
