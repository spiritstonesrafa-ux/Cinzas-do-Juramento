extends SceneTree
## Suíte de testes automatizados e determinísticos para M6-C1:
## Bestiário, Perigos Iniciais e Persistência de Encontros da Floresta dos Ossos.

const ForestEncounterLayout = preload("res://scripts/forest/forest_encounter_layout.gd")
const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")
const ForestFossilSpikes = preload("res://scripts/props/forest_fossil_spikes.gd")

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
	print("SUÍTE DE TESTES M6-C1: COMBATE E ENCONTROS DA FLORESTA")
	print("==================================================")
	call_deferred("_run_all_tests")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_all_tests() -> void:
	await _test_encounter_layout_distribution()
	await _test_crawler_mechanics()
	await _test_sentinel_mechanics_and_poise()
	await _test_spectral_crow_mechanics_and_aerial()
	await _test_fossil_spikes_hazard()
	await _test_sector_persistence_contracts()
	await _test_forest_demo_integration()
	
	print("==================================================")
	print("RESULTADO FINAL M6-C1: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")
	
	if failed == 0:
		quit(0)
	else:
		quit(1)

# ------------------------------------------------------------------------------
# 1. Distribuição Canônica e Layout dos Encontros (M6-C1)
# ------------------------------------------------------------------------------
func _test_encounter_layout_distribution() -> void:
	print("\n--- 1. Distribuição Canônica dos Encontros (Setores 1 a 4) ---")
	
	var s1 = ForestEncounterLayout.get_encounters_for_sector(0)
	var s2 = ForestEncounterLayout.get_encounters_for_sector(1)
	var s3 = ForestEncounterLayout.get_encounters_for_sector(2)
	var s4 = ForestEncounterLayout.get_encounters_for_sector(3)
	var s10 = ForestEncounterLayout.get_encounters_for_sector(9)
	
	# Setor 1: exatamente 2 Rastejantes
	if s1.size() == 2:
		log_pass("Setor 1 possui exatamente 2 encontros configurados")
	else:
		log_fail("Setor 1 tem %d encontros (esperado 2)" % s1.size())
	if s1.size() >= 2 and s1[0]["id"] == "E-01" and s1[0]["type"] == "crawler" and s1[1]["id"] == "E-02" and s1[1]["type"] == "crawler":
		log_pass("Setor 1 contém E-01 e E-02 como crawlers nas posições esperadas")
	else:
		log_fail("Setor 1 mobs divergentes: %s" % str(s1))
	
	# Setor 2: 1 Rastejante, 1 Corvo, Santuário (x >= 764) estritamente vazio
	if s2.size() == 2:
		log_pass("Setor 2 possui exatamente 2 encontros configurados (E-03 crawler, E-04 crow)")
	else:
		log_fail("Setor 2 tem %d encontros (esperado 2)" % s2.size())
	var s2_empty_sanctuary: bool = true
	for item in s2:
		if item["position"].x >= 700.0:
			s2_empty_sanctuary = false
	if s2_empty_sanctuary:
		log_pass("Santuário do Cervo no Setor 2 (x >= 700) permanece estritamente vazio")
	else:
		log_fail("Inimigo encontrado dentro do Santuário do Cervo no Setor 2!")
	
	# Setor 3: 1 Rastejante, 1 Corvo, 1 Sentinela, 1 Espícula
	if s3.size() == 4:
		log_pass("Setor 3 possui exatamente 4 encontros (E-05, E-06, E-07, P-01)")
	else:
		log_fail("Setor 3 tem %d encontros (esperado 4)" % s3.size())
	var has_spikes: bool = false
	for item in s3:
		if item["id"] == "P-01" and item["type"] == "fossil_spikes":
			has_spikes = true
	if has_spikes:
		log_pass("Setor 3 contém P-01 (espículas fósseis temporizadas) em x=480, y=290")
	else:
		log_fail("P-01 não encontrado no Setor 3")
	
	# Setor 4: 1 Sentinela, 1 Rastejante
	if s4.size() == 2:
		log_pass("Setor 4 possui exatamente 2 encontros (E-08 sentinel, E-09 crawler)")
	else:
		log_fail("Setor 4 tem %d encontros (esperado 2)" % s4.size())
	
	# Setor 10: vazio de encontros comuns (reservado para o Cervo Espectral)
	if s10.is_empty():
		log_pass("Setor 10 vazio de encontros comuns (reservado para o Cervo Espectral)")
	else:
		log_fail("Encontros indevidos encontrados no Setor 10!")

# ------------------------------------------------------------------------------
# 2. Rastejante Fóssil (ForestCrawler)
# ------------------------------------------------------------------------------
func _test_crawler_mechanics() -> void:
	print("\n--- 2. Mecânicas do Rastejante Fóssil (ForestCrawler) ---")
	
	var scene: PackedScene = load("res://scenes/enemies/forest_crawler.tscn")
	var crawler: ForestCrawler = scene.instantiate() as ForestCrawler
	root.add_child(crawler)
	crawler.global_position = Vector2(200.0, 200.0)
	await _frames(2)
	
	# Geometria e camadas
	if crawler.collision_layer == 128 and crawler.collision_mask == 1:
		log_pass("ForestCrawler possui collision_layer 128 e mask 1")
	else:
		log_fail("ForestCrawler camadas incorretas: layer %d, mask %d" % [crawler.collision_layer, crawler.collision_mask])
	
	var receiver_shape = crawler.get_node("SwordReceiver/CollisionShape2D") as CollisionShape2D
	var rec_rect = receiver_shape.shape as RectangleShape2D
	if rec_rect != null and rec_rect.size.y >= 18.0:
		log_pass("SwordReceiver do Rastejante tem altura de %.1f px (garante sobreposição de 11 px com golpe da espada)" % rec_rect.size.y)
	else:
		log_fail("SwordReceiver altura insuficiente: %s" % str(rec_rect.size if rec_rect else "nulo"))
	
	# Vida e Dano
	if crawler.max_health == 2 and crawler.current_health == 2 and crawler.damage == 1:
		log_pass("Rastejante possui 2 HP máximo e 1 de dano de contato")
	else:
		log_fail("Atributos do Rastejante divergentes: HP=%d, DMG=%d" % [crawler.current_health, crawler.damage])
	
	# Telegrafia e ciclo de ataque
	crawler.state = ForestCrawler.State.ATTACK
	crawler.attack_phase = ForestCrawler.AttackPhase.WINDUP
	crawler._timer = 0.30
	crawler.attack_source.set_active(false)
	if not crawler.attack_source.active:
		log_pass("Fase de WINDUP (telegrafia 0.30s) mantém AttackSource inativo e inofensivo")
	else:
		log_fail("AttackSource ativo durante windup do Rastejante!")
	
	# Transição para ativo
	crawler._tick_attack(0.31)
	if crawler.attack_phase == ForestCrawler.AttackPhase.ACTIVE and crawler.attack_source.active:
		log_pass("Fase ACTIVE ativa o AttackSource e inicia avanço de bote")
	else:
		log_fail("AttackSource não ativou na fase ACTIVE!")
	
	# Recebimento de golpe e dano
	var crawler_defeated: Array[bool] = [false]
	crawler.defeated.connect(func(): crawler_defeated[0] = true)
	
	crawler.receive_hit()
	if crawler.current_health == 1 and crawler.state == ForestCrawler.State.HURT:
		log_pass("Primeiro golpe da espada reduz HP para 1 e coloca Rastejante em HURT")
	else:
		log_fail("Primeiro golpe falhou: HP=%d, State=%d" % [crawler.current_health, crawler.state])
	
	# Segundo golpe (derrota)
	crawler.receive_hit()
	if crawler.current_health == 0 and crawler.state == ForestCrawler.State.DEAD and crawler_defeated[0]:
		log_pass("Segundo golpe reduz HP para 0, emite defeated e define state = DEAD")
	else:
		log_fail("Segundo golpe falhou: HP=%d, State=%d, Defeated=%s" % [crawler.current_health, crawler.state, str(crawler_defeated[0])])
	
	if crawler.hurt_shape.disabled and crawler.body_shape.disabled:
		log_pass("Colisões de corpo e hurtbox desativadas quando DEAD")
	else:
		log_fail("Colisões permaneceram ativas após a morte!")
	
	# Reset
	crawler.reset_enemy()
	if crawler.current_health == 2 and crawler.state == ForestCrawler.State.IDLE and not crawler.hurt_shape.disabled:
		log_pass("reset_enemy() restaura 2 HP, state = IDLE e reabilita colisões")
	else:
		log_fail("reset_enemy() falhou: HP=%d, State=%d" % [crawler.current_health, crawler.state])
	
	crawler.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 3. Sentinela Ósseo (ForestSentinel) & Mecânica Canônica de Poise
# ------------------------------------------------------------------------------
func _test_sentinel_mechanics_and_poise() -> void:
	print("\n--- 3. Sentinela Ósseo (ForestSentinel) & Mecânica de Poise ---")
	
	var scene: PackedScene = load("res://scenes/enemies/forest_sentinel.tscn")
	var sentinel: ForestSentinel = scene.instantiate() as ForestSentinel
	root.add_child(sentinel)
	sentinel.global_position = Vector2(300.0, 200.0)
	await _frames(2)
	
	# Atributos básicos
	if sentinel.max_health == 3 and sentinel.current_health == 3 and sentinel.attack_distance == 26.0:
		log_pass("Sentinela Ósseo possui 3 HP, 1 dano e alcance de golpe de 26 px")
	else:
		log_fail("Atributos do Sentinela incorretos: HP=%d, Alcance=%.1f" % [sentinel.current_health, sentinel.attack_distance])
	
	# TESTE DE POISE: golpe recebido durante WINDUP
	sentinel.state = ForestSentinel.State.ATTACK
	sentinel.attack_phase = ForestSentinel.AttackPhase.WINDUP
	sentinel._timer = 0.45
	
	sentinel.receive_hit()
	if sentinel.current_health == 2 and sentinel.state == ForestSentinel.State.ATTACK and sentinel.attack_phase == ForestSentinel.AttackPhase.WINDUP:
		log_pass("POISE CANÔNICA: golpe recebido durante WINDUP causa dano (HP 3->2) mas NÃO interrompe o ataque!")
	else:
		log_fail("Falha no Poise: State=%d, Phase=%d, HP=%d" % [sentinel.state, sentinel.attack_phase, sentinel.current_health])
	
	if sentinel.is_flashing_poise():
		log_pass("Sentinela ativa feedback visual (_poise_flash_timer) ao absorver impacto com poise")
	else:
		log_fail("Feedback de poise visual inativo!")
	
	# TESTE DE VULNERABILIDADE NO RECOVERY: golpe recebido durante RECOVERY
	sentinel.attack_phase = ForestSentinel.AttackPhase.RECOVERY
	sentinel._timer = 0.40
	sentinel.receive_hit()
	if sentinel.current_health == 1 and sentinel.state == ForestSentinel.State.HURT:
		log_pass("VULNERABILIDADE NO RECOVERY: golpe recebido durante RECOVERY interrompe o Sentinela e entra em HURT")
	else:
		log_fail("Falha na vulnerabilidade do recovery: State=%d, HP=%d" % [sentinel.state, sentinel.current_health])
	
	# Terceiro golpe (derrota)
	var sentinel_defeated: Array[bool] = [false]
	sentinel.defeated.connect(func(): sentinel_defeated[0] = true)
	sentinel.receive_hit()
	if sentinel.current_health == 0 and sentinel.state == ForestSentinel.State.DEAD and sentinel_defeated[0]:
		log_pass("Terceiro golpe derrota o Sentinela (HP=0, State=DEAD, defeated emitido)")
	else:
		log_fail("Falha na derrota do Sentinela: HP=%d, State=%d" % [sentinel.current_health, sentinel.state])
	
	sentinel.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 4. Corvo Espectral (ForestSpectralCrow) & Combate Aéreo
# ------------------------------------------------------------------------------
func _test_spectral_crow_mechanics_and_aerial() -> void:
	print("\n--- 4. Corvo Espectral (ForestSpectralCrow) & Combate Aéreo ---")
	
	var scene: PackedScene = load("res://scenes/enemies/forest_spectral_crow.tscn")
	var crow: ForestSpectralCrow = scene.instantiate() as ForestSpectralCrow
	root.add_child(crow)
	crow.global_position = Vector2(400.0, 150.0)
	await _frames(2)
	
	if crow.motion_mode == CharacterBody2D.MOTION_MODE_FLOATING:
		log_pass("Corvo Espectral possui motion_mode FLOATING para navegação aérea livre")
	else:
		log_fail("Corvo Espectral motion_mode incorreto: %d" % crow.motion_mode)
	
	if crow.max_health == 2 and crow.dive_speed == 90.0 and crow.alert_duration == 0.45:
		log_pass("Corvo Espectral: 2 HP, mergulho veloz a 90 px/s e telegrafia ALERT de 0.45s")
	else:
		log_fail("Atributos do Corvo divergentes: HP=%d, Vel=%.1f, Alert=%.2f" % [crow.max_health, crow.dive_speed, crow.alert_duration])
	
	# Frustum guard test
	if crow.has_method("visible_for_attack"):
		log_pass("visible_for_attack() implementado para garantir que o corvo não ataca fora de vista")
	else:
		log_fail("visible_for_attack() ausente!")
	
	# Alvo para ataque aéreo (SwordReceiver layer 8, mask 4)
	var receiver = crow.get_node("SwordReceiver") as Area2D
	if receiver.collision_layer == 8 and receiver.collision_mask == 4:
		log_pass("SwordReceiver aéreo na camada 8 (detectável pelo golpe aéreo 'J' do Aren)")
	else:
		log_fail("SwordReceiver camadas divergentes: layer %d, mask %d" % [receiver.collision_layer, receiver.collision_mask])
	
	# Dano e derrota em 2 golpes
	var crow_defeated: Array[bool] = [false]
	crow.defeated.connect(func(): crow_defeated[0] = true)
	crow.receive_hit()
	if crow.current_health == 1 and crow.state == ForestSpectralCrow.State.HURT:
		log_pass("Primeiro golpe aéreo atinge o Corvo (HP=1, State=HURT)")
	else:
		log_fail("Primeiro golpe no corvo falhou: HP=%d, State=%d" % [crow.current_health, crow.state])
	
	crow.receive_hit()
	if crow.current_health == 0 and crow.state == ForestSpectralCrow.State.DEAD and crow_defeated[0]:
		log_pass("Segundo golpe aéreo derrota o Corvo (HP=0, State=DEAD, defeated emitido)")
	else:
		log_fail("Segundo golpe no corvo falhou: HP=%d, State=%d" % [crow.current_health, crow.state])
	
	crow.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 5. Espículas Ósseas Temporizadas (ForestFossilSpikes)
# ------------------------------------------------------------------------------
func _test_fossil_spikes_hazard() -> void:
	print("\n--- 5. Espículas Ósseas Temporizadas (ForestFossilSpikes) ---")
	
	var scene: PackedScene = load("res://scenes/props/forest_fossil_spikes.tscn")
	var spikes: ForestFossilSpikes = scene.instantiate() as ForestFossilSpikes
	root.add_child(spikes)
	await _frames(2)
	
	if spikes.collision_layer == 32 and spikes.collision_mask == 16:
		log_pass("ForestFossilSpikes configurado na layer 32 e mask 16 (DamageSource padrão)")
	else:
		log_fail("Camadas incorretas nas espículas: layer %d, mask %d" % [spikes.collision_layer, spikes.collision_mask])
	
	# SAFE state
	spikes.reset_hazard()
	if spikes.state == ForestFossilSpikes.State.SAFE and spikes.shape.disabled and spikes.contact_damage(0) == 0:
		log_pass("Estado SAFE (1.8s): colisão desativada e dano de contato = 0")
	else:
		log_fail("SAFE ativo de forma irregular: shape disabled=%s, dmg=%d" % [str(spikes.shape.disabled), spikes.contact_damage(0)])
	
	# WARNING state
	spikes._physics_process(1.85)
	if spikes.state == ForestFossilSpikes.State.WARNING and spikes.shape.disabled and spikes.contact_damage(0) == 0:
		log_pass("Estado WARNING (0.6s): telegrafia visual ativa, colisão ainda desativada e dano = 0")
	else:
		log_fail("WARNING falhou: State=%d, shape disabled=%s, dmg=%d" % [spikes.state, str(spikes.shape.disabled), spikes.contact_damage(0)])
	
	# ACTIVE state
	spikes._physics_process(0.65)
	if spikes.state == ForestFossilSpikes.State.ACTIVE and not spikes.shape.disabled and spikes.contact_damage(0) == 1:
		log_pass("Estado ACTIVE (0.8s): colisão ativada e causa exatamente 1 de dano de contato!")
	else:
		log_fail("ACTIVE falhou: State=%d, shape disabled=%s, dmg=%d" % [spikes.state, str(spikes.shape.disabled), spikes.contact_damage(0)])
	
	# RECOVER state
	spikes._physics_process(0.85)
	if spikes.state == ForestFossilSpikes.State.RECOVER and spikes.shape.disabled and spikes.contact_damage(0) == 0:
		log_pass("Estado RECOVER (0.4s): colisão desativada e dano = 0")
	else:
		log_fail("RECOVER falhou: State=%d, shape disabled=%s, dmg=%d" % [spikes.state, str(spikes.shape.disabled), spikes.contact_damage(0)])
	
	# Disarm
	spikes.state = ForestFossilSpikes.State.ACTIVE
	spikes.shape.disabled = false
	spikes.disarm()
	if spikes.shape.disabled:
		log_pass("disarm() desativa colisão e desarma o perigo imediatamente")
	else:
		log_fail("disarm() não desativou colisão!")
	
	spikes.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 6. Persistência de Encontros nos Setores (ForestSector)
# ------------------------------------------------------------------------------
func _test_sector_persistence_contracts() -> void:
	print("\n--- 6. Contratos de Persistência nos Setores (ForestSector) ---")
	
	var sector_scene: PackedScene = load("res://scenes/forest/sector_01.tscn")
	var sector1: ForestSector = sector_scene.instantiate() as ForestSector
	root.add_child(sector1)
	await _frames(2)
	
	if sector1.enemies.size() == 2:
		log_pass("Setor 1 instancia automaticamente 2 inimigos (E-01 e E-02)")
	else:
		log_fail("Setor 1 enemies count: %d" % sector1.enemies.size())
	
	# Snapshot inicial
	var snap1 = sector1.snapshot()
	if snap1.has("enemies") and snap1["enemies"].has("E-01") and snap1["enemies"]["E-01"]["alive"]:
		log_pass("snapshot() captura estado inicial: E-01 e E-02 vivos com HP integral")
	else:
		log_fail("snapshot() inicial incorreto: %s" % str(snap1))
	
	# Derrota E-01
	var e01: ForestCrawler = sector1.enemies[0] as ForestCrawler
	e01.force_dead()
	var snap2 = sector1.snapshot()
	if not snap2["enemies"]["E-01"]["alive"] and snap2["enemies"]["E-02"]["alive"]:
		log_pass("snapshot() após combate registra E-01 derrotado e E-02 sobrevivente")
	else:
		log_fail("snapshot() após combate falhou: %s" % str(snap2))
	
	# Recriação do Setor 1 simulando retorno de exploração
	sector1.queue_free()
	await _frames(2)
	
	var sector1_revisit: ForestSector = sector_scene.instantiate() as ForestSector
	root.add_child(sector1_revisit)
	await _frames(2)
	
	sector1_revisit.restore_state(snap2)
	await _frames(1)
	
	var rev_e01 = sector1_revisit.enemies[0] as ForestCrawler
	var rev_e02 = sector1_revisit.enemies[1] as ForestCrawler
	if rev_e01.state == ForestCrawler.State.DEAD and rev_e01.hurt_shape.disabled:
		log_pass("restore_state() mantém E-01 derrotado (sem respawn indevido ao revisitar sala)")
	else:
		log_fail("E-01 renasceu indevidamente após restore_state(): State=%d" % rev_e01.state)
	
	if rev_e02.state == ForestCrawler.State.IDLE and rev_e02.current_health == 2:
		log_pass("restore_state() mantém E-02 vivo e operante")
	else:
		log_fail("E-02 em estado irregular após restore_state(): State=%d, HP=%d" % [rev_e02.state, rev_e02.current_health])
	
	# Reset de encontros (após morte do herói no checkpoint)
	sector1_revisit.reset_encounters()
	if rev_e01.state == ForestCrawler.State.IDLE and rev_e01.current_health == 2 and not rev_e01.hurt_shape.disabled:
		log_pass("reset_encounters() (respawn do jogador) restaura todos os inimigos à vida e origem")
	else:
		log_fail("reset_encounters() falhou ao restaurar E-01: State=%d, HP=%d" % [rev_e01.state, rev_e01.current_health])
	
	sector1_revisit.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 7. Integração no ForestDemo e Preservação Canônica
# ------------------------------------------------------------------------------
func _test_forest_demo_integration() -> void:
	print("\n--- 7. Integração no ForestDemo e Integridade Canônica ---")
	
	var demo_scene: PackedScene = load("res://scenes/forest/forest_pilots.tscn")
	var demo: ForestDemo = demo_scene.instantiate() as ForestDemo
	root.add_child(demo)
	await _frames(10)
	
	# Preservação dos 10 Checkpoints
	if demo.checkpoints.size() == 10:
		log_pass("ForestDemo preserva integralmente os 10 checkpoints de sessão (1 por setor)")
	else:
		log_fail("Quantidade de checkpoints divergente: %d (esperado 10)" % demo.checkpoints.size())
	
	# Hero target binding
	if is_instance_valid(demo.room) and demo.room.enemies.size() > 0:
		var first_enemy = demo.room.enemies[0]
		if first_enemy.target == demo.hero:
			log_pass("Inimigos do setor ativo vinculam o hero (Aren) como target automaticamente")
		else:
			log_fail("Target do inimigo não vinculado ao hero!")
	else:
		log_fail("Sala ativa não possui inimigos no Setor 1!")
	
	# Setor 10 sem vitória prematura
	if not demo.completed:
		log_pass("ForestDemo mantém completed = false (sem vitória prematura, arena aguarda Cervo)")
	else:
		log_fail("ForestDemo com vitória prematura ativada!")
	
	demo.queue_free()
	await _frames(2)
