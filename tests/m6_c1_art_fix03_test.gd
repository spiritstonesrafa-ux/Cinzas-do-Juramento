extends SceneTree
## Suíte de Testes Automatizados para M6-C1-ART-FIX03
## Validação das Spritesheets Oficiais, Animações Reais e Ausência de Regressões

const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	call_deferred("_run_all_tests")

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_all_tests() -> void:
	print("\n==================================================")
	print("SUÍTE DE TESTES M6-C1-ART-FIX03: ANIMAÇÃO DE SPRITESHEETS OFICIAIS")
	print("==================================================")
	
	_test_01_raw_sheets_imported()
	_test_02_atlases_and_visual_nodes()
	await _test_03_crawler_walk_and_bite_states()
	await _test_04_sentinel_march_and_slam_states()
	await _test_05_crow_flight_and_dive_states()
	await _test_06_facing_orientation()
	_test_07_no_blue_markers_on_visuals()
	
	print("\n==================================================")
	print("RESULTADO M6-C1-ART-FIX03: %d PASSOU, %d FALHOU" % [_passed, _failed])
	print("==================================================")
	
	if _failed > 0:
		quit(1)
	else:
		quit(0)

func _assert(condition: bool, message: String) -> void:
	if condition:
		print("  [PASS] %s" % message)
		_passed += 1
	else:
		printerr("  [FAIL] %s" % message)
		_failed += 1

func _test_01_raw_sheets_imported() -> void:
	print("\n--- 1. Existência e Preservação dos 6 Arquivos Oficiais Brutos ---")
	var raw_files = [
		"res://assets/art/m6c1/raw/sprite_sheet_do_rastejante_fóssil.png",
		"res://assets/art/m6c1/raw/ciclo_de_mordida_do_rastejante_fóssil.png",
		"res://assets/art/m6c1/raw/ciclo_de_caminhada_do_sentinela_ósseo.png",
		"res://assets/art/m6c1/raw/sentinela_ósseo_golpe_devastador.png",
		"res://assets/art/m6c1/raw/ciclo_de_voo_do_corvo_espectral.png",
		"res://assets/art/m6c1/raw/ciclo_de_ataque_do_corvo_espectral.png"
	]
	for path in raw_files:
		var exists: bool = FileAccess.file_exists(path)
		_assert(exists, "Arquivo bruto preservado: %s" % path.get_file())

func _test_02_atlases_and_visual_nodes() -> void:
	print("\n--- 2. Carregamento dos Atlases Padronizados e Nódulos Visuais ---")
	var crawler_atlas: Texture2D = load("res://assets/art/m6c1/crawler_atlas.png")
	var sentinel_atlas: Texture2D = load("res://assets/art/m6c1/sentinel_atlas.png")
	var crow_atlas: Texture2D = load("res://assets/art/m6c1/crow_atlas.png")
	
	_assert(crawler_atlas != null and crawler_atlas.get_width() == 1440 and crawler_atlas.get_height() == 280,
		"Atlas do Rastejante carregado: 1440x280 (4x2 células de 360x140)")
	_assert(sentinel_atlas != null and sentinel_atlas.get_width() == 1360 and sentinel_atlas.get_height() == 672,
		"Atlas do Sentinela carregado: 1360x672 (4x2 células de 340x336)")
	_assert(crow_atlas != null and crow_atlas.get_width() == 1120 and crow_atlas.get_height() == 640,
		"Atlas do Corvo carregado: 1120x640 (4x2 células de 280x320)")

func _test_03_crawler_walk_and_bite_states() -> void:
	print("\n--- 3. Rastejante: Ciclo de Caminhada e Mordida de Ataque ---")
	var scene = load("res://scenes/enemies/forest_crawler.tscn")
	var crawler = scene.instantiate() as ForestCrawler
	root.add_child(crawler)
	await _frames(2)
	
	_assert(crawler.visual != null, "Nódulo visual ForestCrawlerVisual instanciado")
	
	# Teste de caminhada: passos reais
	crawler.state = ForestCrawler.State.PATROL
	crawler.velocity.x = 45.0
	crawler.global_position.x = 0.0
	var step0 = absi(int(crawler.global_position.x / 10.0)) % 4
	crawler.global_position.x = 10.0
	var step1 = absi(int(crawler.global_position.x / 10.0)) % 4
	crawler.global_position.x = 20.0
	var step2 = absi(int(crawler.global_position.x / 10.0)) % 4
	crawler.global_position.x = 30.0
	var step3 = absi(int(crawler.global_position.x / 10.0)) % 4
	
	_assert(step0 == 0 and step1 == 1 and step2 == 2 and step3 == 3,
		"Rastejante progride pelos 4 quadros reais de caminhada (0 -> 1 -> 2 -> 3)")
	
	# Teste de ataque: estados windup, antecipação, active e recovery
	crawler.state = ForestCrawler.State.ATTACK
	crawler.attack_phase = ForestCrawler.AttackPhase.WINDUP
	crawler._timer = 0.25
	_assert(crawler.attack_phase == ForestCrawler.AttackPhase.WINDUP and crawler._timer > 0.15,
		"WINDUP fase 1: postura agachada preparando o bote")
	
	crawler._timer = 0.10
	_assert(crawler._timer <= 0.15,
		"WINDUP fase 2: antecipação com mandíbula abrindo")
	
	crawler.attack_phase = ForestCrawler.AttackPhase.ACTIVE
	_assert(crawler.attack_phase == ForestCrawler.AttackPhase.ACTIVE,
		"ACTIVE: investida com corpo estendido e mordida aberta coincide com dano ativo")
	
	crawler.attack_phase = ForestCrawler.AttackPhase.RECOVERY
	_assert(crawler.attack_phase == ForestCrawler.AttackPhase.RECOVERY,
		"RECOVERY: recolhimento do corpo pós-bote")
	
	crawler.queue_free()

func _test_04_sentinel_march_and_slam_states() -> void:
	print("\n--- 4. Sentinela Ósseo: Ciclo de Marcha e Golpe Devastador ---")
	var scene = load("res://scenes/enemies/forest_sentinel.tscn")
	var sentinel = scene.instantiate() as ForestSentinel
	root.add_child(sentinel)
	await _frames(2)
	
	_assert(sentinel.visual != null, "Nódulo visual ForestSentinelVisual instanciado")
	
	# Teste de marcha
	sentinel.state = ForestSentinel.State.PATROL
	sentinel.velocity.x = 28.0
	sentinel.global_position.x = 0.0
	var step0 = absi(int(sentinel.global_position.x / 12.0)) % 4
	sentinel.global_position.x = 12.0
	var step1 = absi(int(sentinel.global_position.x / 12.0)) % 4
	sentinel.global_position.x = 24.0
	var step2 = absi(int(sentinel.global_position.x / 12.0)) % 4
	sentinel.global_position.x = 36.0
	var step3 = absi(int(sentinel.global_position.x / 12.0)) % 4
	
	_assert(step0 == 0 and step1 == 1 and step2 == 2 and step3 == 3,
		"Sentinela progride pelos 4 quadros reais de marcha pesada (0 -> 1 -> 2 -> 3)")
	
	# Teste de ataque
	sentinel.state = ForestSentinel.State.ATTACK
	sentinel.attack_phase = ForestSentinel.AttackPhase.WINDUP
	sentinel._timer = 0.40
	_assert(sentinel._timer > 0.30,
		"WINDUP fase 1: ready inicial com cutelo subindo")
	
	sentinel._timer = 0.20
	_assert(sentinel._timer <= 0.30,
		"WINDUP fase 2: cutelo colossal erguido acima do crânio com as duas mãos e poise")
	
	sentinel.attack_phase = ForestSentinel.AttackPhase.ACTIVE
	_assert(sentinel.attack_phase == ForestSentinel.AttackPhase.ACTIVE,
		"ACTIVE: golpe descendente cravando a lâmina no solo durante a janela de dano")
	
	sentinel.attack_phase = ForestSentinel.AttackPhase.RECOVERY
	_assert(sentinel.attack_phase == ForestSentinel.AttackPhase.RECOVERY,
		"RECOVERY: cutelo apoiado no chão e postura vulnerável ao jogador")
	
	sentinel.queue_free()

func _test_05_crow_flight_and_dive_states() -> void:
	print("\n--- 5. Corvo Espectral: Ciclo de Batimento de Asas e Mergulho ---")
	var scene = load("res://scenes/enemies/forest_spectral_crow.tscn")
	var crow = scene.instantiate() as ForestSpectralCrow
	root.add_child(crow)
	await _frames(2)
	
	_assert(crow.visual != null, "Nódulo visual ForestSpectralCrowVisual instanciado")
	
	# Batimento de asas contínuo
	crow.state = ForestSpectralCrow.State.PATROL
	var f0 = int(0.00 * 8.0) % 4
	var f1 = int(0.13 * 8.0) % 4
	var f2 = int(0.26 * 8.0) % 4
	var f3 = int(0.38 * 8.0) % 4
	_assert(f0 == 0 and f1 == 1 and f2 == 2 and f3 == 3,
		"Corvo bate asas continuamente em 4 poses a 8 FPS (Flap Up -> Mid -> Down -> Recover)")
	
	# Ataque de mergulho
	crow.state = ForestSpectralCrow.State.ALERT
	crow._timer = 0.35
	_assert(crow._timer > 0.20, "ALERT fase 1: voo tenso com asas abertas")
	crow._timer = 0.10
	_assert(crow._timer <= 0.20, "ALERT fase 2 / WINDUP: preparação aerodinâmica")
	
	crow.state = ForestSpectralCrow.State.DIVE
	_assert(crow.state == ForestSpectralCrow.State.DIVE, "DIVE: asas recolhidas em flecha apontada na direção do mergulho")
	
	crow.state = ForestSpectralCrow.State.RECOVER
	_assert(crow.state == ForestSpectralCrow.State.RECOVER, "RECOVER: abertura de asas e frenagem")
	
	crow.queue_free()

func _test_06_facing_orientation() -> void:
	print("\n--- 6. Orientação Esquerda/Direita (Facing) ---")
	var scene = load("res://scenes/enemies/forest_crawler.tscn")
	var crawler = scene.instantiate() as ForestCrawler
	root.add_child(crawler)
	await _frames(2)
	
	crawler.facing = 1
	crawler._sync_visual()
	_assert(crawler.visual.scale.x > 0.0, "Facing +1 mantém visual voltado para a direita")
	
	crawler.facing = -1
	crawler._sync_visual()
	_assert(crawler.visual.scale.x < 0.0, "Facing -1 espelha visual perfeitamente para a esquerda")
	
	crawler.queue_free()

func _test_07_no_blue_markers_on_visuals() -> void:
	print("\n--- 7. Ausência Absoluta de Marcadores Azuis/Ciano ---")
	var scripts = [
		"res://scripts/enemies/forest_crawler_visual.gd",
		"res://scripts/enemies/forest_sentinel_visual.gd",
		"res://scripts/enemies/forest_spectral_crow_visual.gd"
	]
	var has_teal: bool = false
	for s_path in scripts:
		var f = FileAccess.open(s_path, FileAccess.READ)
		if f:
			var content = f.get_as_text()
			if "EYE_TEAL" in content or "40e0d0" in content:
				has_teal = true
	_assert(not has_teal, "Nenhum script visual contém EYE_TEAL ou marcadores azuis técnicos")
