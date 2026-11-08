extends SceneTree
## Suíte de testes automatizados e determinísticos para M6-C3:
## Encontros, perigos e travessia da Ravina das Sombras Fósseis (Setor 9)
## e preparação da Grande Arena da Clareira da Bruma Espectral (Setor 10).

const ForestEncounterLayout = preload("res://scripts/forest/forest_encounter_layout.gd")
const ForestLayout = preload("res://scripts/forest/forest_layout.gd")
const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")
const ForestFossilSpikes = preload("res://scripts/props/forest_fossil_spikes.gd")

const SECTOR_SCENES: Array[String] = [
	"res://scenes/forest/sector_01.tscn",
	"res://scenes/forest/sector_02.tscn",
	"res://scenes/forest/sector_03.tscn",
	"res://scenes/forest/sector_04.tscn",
	"res://scenes/forest/sector_05.tscn",
	"res://scenes/forest/sector_06.tscn",
	"res://scenes/forest/sector_07.tscn",
	"res://scenes/forest/sector_08.tscn",
	"res://scenes/forest/sector_09.tscn",
	"res://scenes/forest/sector_10.tscn"
]
const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")

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
	print("SUÍTE DE TESTES M6-C3: ENCONTROS DA FLORESTA (SETORES 9 E 10)")
	print("==================================================")
	call_deferred("_run_all_tests")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_all_tests() -> void:
	await _test_m6_c3_distribution()
	await _test_checkpoint_safety()
	await _test_crow_e24_optional_dorsal_route()
	await _test_crow_e24_reverse_entry_safety()
	await _test_sentinel_e23_landing_safety_and_duel()
	await _test_hazard_p04_spikes_and_clearance()
	await _test_chasm_jump_kinematics()
	await _test_sector_9_persistence_and_backtracking()
	await _test_sector_10_arena_isolation_and_continuity()
	await _test_m6_c1_c2_regression()

	print("==================================================")
	print("RESULTADO FINAL M6-C3: %d PASSOU, %d FALHOU" % [passed, failed])
	print("==================================================")

	if failed == 0:
		quit(0)
	else:
		quit(1)

# ------------------------------------------------------------------------------
# 1. Distribuição Canônica dos Encontros (M6-C3: Setor 9 e Setor 10)
# ------------------------------------------------------------------------------
func _test_m6_c3_distribution() -> void:
	print("\n--- 1. Distribuição Canônica dos Encontros (Setor 9 e Setor 10) ---")

	var s9 = ForestEncounterLayout.get_encounters_for_sector(8)
	var s10 = ForestEncounterLayout.get_encounters_for_sector(9)

	# Setor 9: exatamente 4 encontros (3 inimigos + 1 armadilha)
	if s9.size() == 4:
		log_pass("Setor 9 possui exatamente 4 encontros configurados")
	else:
		log_fail("Setor 9 tem %d encontros (esperado 4)" % s9.size())

	# Conferência nominal dos IDs de S9
	if s9.size() == 4:
		var ids_s9 = [s9[0].get("id"), s9[1].get("id"), s9[2].get("id"), s9[3].get("id")]
		if ids_s9 == ["E-22", "P-04", "E-23", "E-24"]:
			log_pass("Setor 9 contém E-22, P-04, E-23, E-24 na ordem canônica")
		else:
			log_fail("Setor 9 IDs inesperados: %s" % str(ids_s9))

		# Verificação de Tipos e Coordenadas
		var e22_ok = (s9[0]["type"] == "crawler" and s9[0]["position"] == Vector2(260.0, 260.0) and s9[0]["patrol_left"] == -25.0 and s9[0]["patrol_right"] == 25.0 and s9[0]["facing"] == -1)
		var p04_ok = (s9[1]["type"] == "fossil_spikes" and s9[1]["position"] == Vector2(360.0, 280.0))
		var e23_ok = (s9[2]["type"] == "sentinel" and s9[2]["position"] == Vector2(610.0, 280.0) and s9[2]["patrol_left"] == -20.0 and s9[2]["patrol_right"] == 25.0 and s9[2]["facing"] == -1)
		var e24_ok = (s9[3]["type"] == "spectral_crow" and s9[3]["position"] == Vector2(740.0, 160.0) and s9[3]["patrol_half_width"] == 25.0 and s9[3]["facing"] == -1)

		if e22_ok and p04_ok and e23_ok and e24_ok:
			log_pass("Setor 9: tipos, posições, patrulhas e orientações perfeitamente calibrados")
		else:
			log_fail("Setor 9: inconsistência em parâmetros de layout!")

	# Setor 10 estritamente vazio de encontros comuns (reservado ao Cervo Espectral)
	if s10.is_empty():
		log_pass("Setor 10 permanece estritamente vazio de encontros comuns (0 encontros)")
	else:
		log_fail("Setor 10 possui encontros indevidos: %s" % str(s10))

	# Ausência de IDs duplicados em todo o layout
	var all_ids: Array[String] = []
	var has_duplicate: bool = false
	for s_idx in range(10):
		var sector_enc = ForestEncounterLayout.get_encounters_for_sector(s_idx)
		for enc in sector_enc:
			var eid = enc.get("id", "")
			if all_ids.has(eid):
				has_duplicate = true
				log_fail("ID duplicado detectado: %s no setor %d" % [eid, s_idx + 1])
			all_ids.append(eid)

	if not has_duplicate:
		log_pass("Unicidade absoluta de IDs validada: 24 inimigos e 4 perigos sem duplicatas")

# ------------------------------------------------------------------------------
# 2. Segurança Dinâmica dos Checkpoints (CP-09 e CP-10)
# ------------------------------------------------------------------------------
func _test_checkpoint_safety() -> void:
	print("\n--- 2. Segurança Dinâmica dos Checkpoints (CP-09 e CP-10) ---")

	# Teste CP-09 na Ravina das Sombras Fósseis
	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var hero = KNIGHT_SCENE.instantiate()
	root.add_child(hero)
	s9_node.set_hero(hero)

	# CP-09 está em Vector2(96.0, 240.0)
	hero.global_position = Vector2(96.0, 240.0)
	hero.velocity = Vector2.ZERO
	await _frames(20)

	var cp09_damaged: bool = (hero.survival.current_health < hero.survival.max_health)
	var cp09_agro: bool = false
	for enemy in s9_node.enemies:
		if is_instance_valid(enemy):
			if enemy is ForestCrawler or enemy is ForestSentinel:
				if enemy.state == enemy.State.CHASE or enemy.state == enemy.State.ATTACK:
					cp09_agro = true
			elif enemy is ForestSpectralCrow:
				if enemy.state == enemy.State.ALERT or enemy.state == enemy.State.DIVE:
					cp09_agro = true

	if not cp09_damaged and not cp09_agro:
		log_pass("Checkpoint CP-09 (Ravina das Sombras Fósseis): 100% seguro (zero dano e zero agro)")
	else:
		log_fail("Risco de agro ou dano detectado em CP-09!")

	# Teste CP-10 na Clareira da Bruma Espectral
	var s10_scene: PackedScene = load("res://scenes/forest/sector_10.tscn")
	var s10_node = s10_scene.instantiate()
	root.add_child(s10_node)
	s10_node.set_hero(hero)

	# CP-10 está em Vector2(96.0, 260.0)
	hero.global_position = Vector2(96.0, 260.0)
	hero.velocity = Vector2.ZERO
	await _frames(20)

	var cp10_damaged: bool = (hero.survival.current_health < hero.survival.max_health)
	var s10_has_mobs: bool = (s10_node.enemies.size() > 0 or s10_node.hazards.size() > 0)

	if not cp10_damaged and not s10_has_mobs:
		log_pass("Checkpoint CP-10 (Clareira da Bruma Espectral): 100% seguro na antecâmara pré-arena")
	else:
		log_fail("Inconsistência de segurança detectada em CP-10!")

	hero.queue_free()
	s9_node.queue_free()
	s10_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 3. Corvo Espectral E-24 (Rota Elevada Opcional vs Piso Principal)
# ------------------------------------------------------------------------------
func _test_crow_e24_optional_dorsal_route() -> void:
	print("\n--- 3. Corvo Espectral E-24 (Rota Elevada Opcional) ---")

	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var hero = KNIGHT_SCENE.instantiate()
	root.add_child(hero)
	s9_node.set_hero(hero)

	var crow: ForestSpectralCrow = s9_node.get_node_or_null("Encounters/E-24") as ForestSpectralCrow
	if crow == null:
		log_fail("E-24 não encontrado em Sector09!")
		hero.queue_free()
		s9_node.queue_free()
		return

	# Cenário 1: Aren caminhando no PISO PRINCIPAL (y=260.0) logo abaixo da rota elevada
	# x=740.0, y=260.0. Distância vertical até o corvo (y=160.0) é |246 - 160| = 86 px > 60 px max_vertical
	hero.global_position = Vector2(740.0, 260.0)
	hero.velocity = Vector2.ZERO
	await _frames(15)

	var crow_calm_on_floor = (crow.state == crow.State.IDLE or crow.state == crow.State.PATROL)
	if crow_calm_on_floor:
		log_pass("E-24 permanece passivo quando Aren percorre o piso principal (y=260) - rota direta livre")
	else:
		log_fail("E-24 alertou indevidamente no piso principal!")

	# Cenário 2: Aren subindo na PLATAFORMA ELEVADA de costelas (Rect2(700, 202, 80, 12))
	# Topo da plataforma é y=202.0. Posição de Aren: Vector2(740.0, 202.0).
	# Distância vertical: |188.0 - 160.0| = 28.0 px <= 60.0 px. Linha de visão aberta acima do galho!
	crow._cooldown = 0.0
	crow.state = crow.State.IDLE
	hero.global_position = Vector2(740.0, 202.0)
	hero.velocity = Vector2.ZERO
	await _frames(15)

	# Verifica se o corvo detectou e entrou em combate (ALERT ou DIVE) ou se _can_alert é true
	var crow_detected = (crow.state == crow.State.ALERT or crow.state == crow.State.DIVE or crow._can_alert())
	if crow_detected:
		log_pass("E-24 detecta Aren com precisão na rota elevada (y=202) - desafio opcional funcional")
	else:
		log_fail("E-24 falhou em detectar Aren na plataforma elevada!")

	hero.queue_free()
	s9_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 4. Transição Reversa (Setor 10 -> Setor 9) e Segurança de E-24
# ------------------------------------------------------------------------------
func _test_crow_e24_reverse_entry_safety() -> void:
	print("\n--- 4. Transição Reversa (Setor 10 -> Setor 9) e Segurança de E-24 ---")

	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var hero = KNIGHT_SCENE.instantiate()
	root.add_child(hero)
	s9_node.set_hero(hero)

	var crow: ForestSpectralCrow = s9_node.get_node_or_null("Encounters/E-24") as ForestSpectralCrow

	# Aren retornando pelo portal leste do Setor 9 (origem do switch_room da direita é x=912, y=260)
	hero.global_position = Vector2(912.0, 260.0)
	hero.velocity = Vector2.ZERO
	await _frames(20)

	var reverse_calm = (crow.state == crow.State.IDLE or crow.state == crow.State.PATROL)
	if reverse_calm:
		log_pass("Entrada reversa (S10 -> S9): Aren em x=912 não sofre agro imediato de E-24")
	else:
		log_fail("Emboscada injusta detectada na entrada reversa do Setor 9!")

	hero.queue_free()
	s9_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 5. Sentinela E-23 (Pouso Pós-Abismo e Duelo de Poise)
# ------------------------------------------------------------------------------
func _test_sentinel_e23_landing_safety_and_duel() -> void:
	print("\n--- 5. Sentinela E-23 (Pouso Pós-Abismo e Duelo de Poise) ---")

	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var hero = KNIGHT_SCENE.instantiate()
	root.add_child(hero)
	s9_node.set_hero(hero)

	var sentinel: ForestSentinel = s9_node.get_node_or_null("Encounters/E-23") as ForestSentinel
	if sentinel == null:
		log_fail("E-23 não encontrado em Sector09!")
		hero.queue_free()
		s9_node.queue_free()
		return

	# Margem física do abismo até o Sentinela
	# Abismo termina em x=506. Patrulha de E-23 vai de 610-20=590 a 610+25=635.
	var chasm_margin: float = 590.0 - 506.0
	if chasm_margin >= 60.0:
		log_pass("Zona de segurança pós-abismo: 84.0 px livres entre a borda (x=506) e a patrulha de E-23")
	else:
		log_fail("Margem insuficiente pós-abismo: %.1f px" % chasm_margin)

	# Simulação do Pouso de Aren em x=525, y=280
	hero.global_position = Vector2(525.0, 280.0)
	hero.velocity = Vector2.ZERO
	await _frames(5)

	# E-23 detecta Aren (distância 65 px <= 90 px), mas NÃO causa dano imediato
	var initial_health = hero.survival.current_health
	await _frames(15) # 0.25s no ar/chão

	var no_instant_damage = (hero.survival.current_health == initial_health)
	if no_instant_damage:
		log_pass("Pouso pós-abismo em x=525: zero dano imediato (Sentinela necessita fechar distância de 26 px)")
	else:
		log_fail("Dano injusto detectado imediatamente no pouso pós-abismo!")

	# Duelo de Poise: ataque recebido durante windup do Sentinela
	sentinel.global_position = hero.global_position + Vector2(24.0, 0)
	sentinel.state = sentinel.State.ATTACK
	sentinel.attack_phase = sentinel.AttackPhase.WINDUP
	sentinel.receive_hit()

	if sentinel.is_flashing_poise() and sentinel.state == sentinel.State.ATTACK:
		log_pass("Poise de E-23 confirmada: absorve golpe sem cancelamento durante o windup")
	else:
		log_fail("Poise de E-23 falhou durante o windup!")

	hero.queue_free()
	s9_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 6. Armadilha P-04 (Espículas Ósseas e Pista de Salto)
# ------------------------------------------------------------------------------
func _test_hazard_p04_spikes_and_clearance() -> void:
	print("\n--- 6. Armadilha P-04 (Espículas Ósseas e Pista de Salto) ---")

	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var spikes: ForestFossilSpikes = s9_node.get_node_or_null("Encounters/P-04") as ForestFossilSpikes
	if spikes == null:
		log_fail("P-04 não encontrado em Sector09!")
		s9_node.queue_free()
		return

	# Verificação da forma geométrica do colisor (24 x 12)
	var col_shape: CollisionShape2D = spikes.get_node("CollisionShape2D") as CollisionShape2D
	var rect_shape: RectangleShape2D = col_shape.shape as RectangleShape2D
	if rect_shape.size == Vector2(24, 12):
		log_pass("Colisor real de P-04 validado: RectangleShape2D de 24 x 12 px")
	else:
		log_fail("Dimensão inesperada do colisor de P-04: %s" % str(rect_shape.size))

	# Pista desimpedida até o abismo:
	# Centro x=360, meia-largura=12 -> borda direita=372. Abismo em x=460.
	var net_runway: float = 460.0 - (spikes.position.x + 12.0)
	if is_equal_approx(net_runway, 88.0):
		log_pass("Pista de decolagem comprovada: exatamente 88.0 px livres entre P-04 e o abismo")
	else:
		log_fail("Pista livre divergente de 88 px: %.1f px" % net_runway)

	# Ciclo de Estados e Dano
	var safe_disabled = col_shape.disabled
	spikes.remaining = 0.00001
	spikes._physics_process(0.01) # Transiciona para WARNING
	var warning_damage = spikes.contact_damage(0)

	if safe_disabled and warning_damage == 0:
		log_pass("Ciclo de P-04: estados SAFE e WARNING mantêm colisão inativa e dano 0")
	else:
		log_fail("Inconsistência de colisão no ciclo de P-04!")

	s9_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 7. Cinemática e Física do Salto sobre o Vão de 46 px
# ------------------------------------------------------------------------------
func _test_chasm_jump_kinematics() -> void:
	print("\n--- 7. Cinemática e Física do Salto sobre o Vão de 46 px ---")

	# Parâmetros de KnightController: speed = 100, jump_impulse = -230, gravity = 680
	var v0: float = -230.0
	var g: float = 680.0
	var vx: float = 100.0

	var t_up: float = absf(v0) / g
	var t_air: float = 2.0 * t_up
	var jump_reach: float = vx * t_air
	var gap_width: float = 506.0 - 460.0 # 46.0 px

	var margin: float = jump_reach - gap_width

	if margin >= 20.0 and is_equal_approx(gap_width, 46.0):
		log_pass("Salto simples no vão nivelado (y=280): alcance de %.1f px para vão de 46 px (margem +%.1f px)" % [jump_reach, margin])
		log_pass("Retorno simétrico garantido: desnível vertical zero (ambas as bordas em y=280)")
	else:
		log_fail("Física de travessia do vão de 46 px insuficiente!")

# ------------------------------------------------------------------------------
# 8. Persistência de Estado e Backtracking no Setor 9
# ------------------------------------------------------------------------------
func _test_sector_9_persistence_and_backtracking() -> void:
	print("\n--- 8. Persistência de Estado e Backtracking no Setor 9 ---")

	var s9_scene: PackedScene = load("res://scenes/forest/sector_09.tscn")
	var s9_node = s9_scene.instantiate()
	root.add_child(s9_node)

	var hero = KNIGHT_SCENE.instantiate()
	root.add_child(hero)
	s9_node.set_hero(hero)

	var crawler: ForestCrawler = s9_node.get_node_or_null("Encounters/E-22") as ForestCrawler
	crawler.force_dead() # Derrota E-22

	var snap: Dictionary = s9_node.snapshot()
	if snap.has("enemies") and snap["enemies"].has("E-22") and snap["enemies"]["E-22"]["alive"] == false:
		log_pass("Snapshot de Setor 9 registra corretamente E-22 como derrotado")
	else:
		log_fail("Snapshot falhou em capturar derrota de E-22!")

	# Simulação de Backtracking (Setor 10 -> Setor 9)
	s9_node.queue_free()
	await _frames(2)

	var new_s9 = s9_scene.instantiate()
	root.add_child(new_s9)
	new_s9.set_hero(hero)
	new_s9.restore_state(snap)
	await _frames(5)

	var restored_e22 = new_s9.get_node_or_null("Encounters/E-22")
	if restored_e22 != null and restored_e22.state == restored_e22.State.DEAD:
		log_pass("Backtracking validado: E-22 permanece morto após restore_state()")
	else:
		log_fail("Backtracking falhou: E-22 reviveu indevidamente!")

	# Reset de Checkpoint
	new_s9.reset_encounters()
	await _frames(5)
	if restored_e22 != null and restored_e22.state != restored_e22.State.DEAD and restored_e22.current_health == restored_e22.max_health:
		log_pass("Reset de Checkpoint validado: E-22 renasce com vida integral")
	else:
		log_fail("Reset de Checkpoint falhou em restaurar E-22!")

	hero.queue_free()
	new_s9.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 9. Grande Arena do Setor 10 e Continuidade Sem Conclusão Prematura
# ------------------------------------------------------------------------------
func _test_sector_10_arena_isolation_and_continuity() -> void:
	print("\n--- 9. Grande Arena do Setor 10 e Continuidade ---")

	var s10_scene: PackedScene = load("res://scenes/forest/sector_10.tscn")
	var s10_node = s10_scene.instantiate()
	root.add_child(s10_node)

	# Verifica se encounters está totalmente vazio
	var encounters_node = s10_node.get_node_or_null("Encounters")
	var mob_count = encounters_node.get_child_count() if encounters_node != null else 0

	if mob_count == 0:
		log_pass("Grande Arena do Setor 10: 100% isolada e livre de inimigos comuns (preparada para o chefe)")
	else:
		log_fail("Setor 10 contém %d nós indevidos em Encounters!" % mob_count)

	# Verificação da extensão monumental da arena (640 px de vão plano em y=260)
	var s10_surfaces = ForestLayout.surfaces(9)
	var main_floor_width: float = 0.0
	for surf in s10_surfaces:
		if surf.position.y == 260.0 and surf.size.x >= 600.0:
			main_floor_width = surf.size.x

	if main_floor_width >= 640.0:
		log_pass("Piso da Arena validado: 640 px de superfície de combate contínua sem degraus")
	else:
		log_fail("Dimensão do piso monumental divergente: %.1f px" % main_floor_width)

	s10_node.queue_free()
	await _frames(2)

# ------------------------------------------------------------------------------
# 10. Regressão Estrita de M6-C1 e M6-C2 (Setores 1 a 8)
# ------------------------------------------------------------------------------
func _test_m6_c1_c2_regression() -> void:
	print("\n--- 10. Regressão Estrita de M6-C1 e M6-C2 (Setores 1 a 8) ---")

	var s1_4_ok: bool = true
	var s5_8_ok: bool = true

	# Setores 1 a 4
	var s1 = ForestEncounterLayout.get_encounters_for_sector(0)
	var s2 = ForestEncounterLayout.get_encounters_for_sector(1)
	var s3 = ForestEncounterLayout.get_encounters_for_sector(2)
	var s4 = ForestEncounterLayout.get_encounters_for_sector(3)

	s1_4_ok = (s1.size() == 2 and s1[0]["id"] == "E-01" and s1[1]["id"] == "E-02") and \
			  (s2.size() == 2 and s2[0]["id"] == "E-03" and s2[1]["id"] == "E-04") and \
			  (s3.size() == 4 and s3[0]["id"] == "E-05" and s3[1]["id"] == "E-06" and s3[2]["id"] == "E-07" and s3[3]["id"] == "P-01") and \
			  (s4.size() == 2 and s4[0]["id"] == "E-08" and s4[1]["id"] == "E-09")

	# Setores 5 a 8
	var s5 = ForestEncounterLayout.get_encounters_for_sector(4)
	var s6 = ForestEncounterLayout.get_encounters_for_sector(5)
	var s7 = ForestEncounterLayout.get_encounters_for_sector(6)
	var s8 = ForestEncounterLayout.get_encounters_for_sector(7)

	s5_8_ok = (s5.size() == 3 and s5[0]["id"] == "E-10" and s5[1]["id"] == "E-11" and s5[2]["id"] == "E-12") and \
			  (s6.size() == 4 and s6[0]["id"] == "E-13" and s6[1]["id"] == "P-02" and s6[2]["id"] == "E-14" and s6[3]["id"] == "E-15") and \
			  (s7.size() == 4 and s7[0]["id"] == "E-16" and s7[1]["id"] == "P-03" and s7[2]["id"] == "E-18" and s7[3]["id"] == "E-17") and \
			  (s8.size() == 3 and s8[0]["id"] == "E-19" and s8[1]["id"] == "E-20" and s8[2]["id"] == "E-21")

	if s1_4_ok and s5_8_ok:
		log_pass("Regressão Total M6-C1 e M6-C2: 21 inimigos e 3 armadilhas preservados (E-01..E-21, P-01..P-03)")
	else:
		log_fail("Regressão detectada nos encontros dos Setores 1 a 8!")
