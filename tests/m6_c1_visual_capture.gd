extends SceneTree
## Script de validação visual e captura de evidências GPU para M6-C1-ART-FIX02.
## Registra a remoção total dos pontos azuis e as fases de animação articulada dos 3 inimigos.

const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")

func _initialize() -> void:
	run.call_deferred()

func frames(n: int) -> void:
	for _i in range(n):
		await physics_frame
		await process_frame

func shot(filepath: String) -> void:
	if DisplayServer.get_name() == "headless":
		print("AVISO: Headless, captura ignorada para ", filepath)
		return
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	var dir: String = filepath.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var err: Error = img.save_png(filepath)
	print("CAPTURA GERADA: ", filepath, " tamanho=", img.get_size(), " erro=", err)

func run() -> void:
	var out_dir: String = ProjectSettings.globalize_path("res://tests/evidencias/m6c1")
	print("Iniciando M6-C1-ART-FIX02 Visual Capture em: ", out_dir)

	var stage: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
	root.add_child(stage)

	while stage.busy:
		await physics_frame
	await frames(15)

	var hero: KnightController = stage.hero
	hero.dash_unlocked = true

	# =============================================================
	# 1. SEQUÊNCIA DE ANIMAÇÃO DO CORVO (BATER DE ASAS & MERGULHO)
	# =============================================================
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[1] + Vector2(460, 280))
	hero.facing = 1

	var crow: ForestSpectralCrow = null
	if stage.room != null and stage.room.enemies.size() > 1:
		crow = stage.room.enemies[1] as ForestSpectralCrow

	if crow != null:
		stage.camera.zoom = Vector2(2.5, 2.5)
		stage.camera.position = ForestLayout.ORIGINS[1] + Vector2(510, 240)
		stage.camera.force_update_scroll()

		# Fase 1: Asas batendo para cima (Flap Up)
		crow.flight_time = 0.0 # frame 1 no step 0
		crow._sync_visual()
		await frames(5)
		await shot(out_dir + "/corvo_flap_01_up.png")

		# Fase 2: Asas batendo para baixo (Flap Down)
		crow.flight_time = 0.25 # frame 3 no step 2
		crow._sync_visual()
		await frames(5)
		await shot(out_dir + "/corvo_flap_02_down.png")

		# Fase 3: Asas planando (Glide)
		crow.flight_time = 0.38 # frame 0 no step 3
		crow._sync_visual()
		await frames(5)
		await shot(out_dir + "/corvo_flap_03_glide.png")

		# Fase 4: Mergulho ofensivo em direção a Aren
		crow.state = ForestSpectralCrow.State.DIVE
		crow.facing = -1
		crow.velocity = Vector2(-70, 50)
		crow._sync_visual()
		await frames(5)
		await shot(out_dir + "/corvo_04_mergulho.png")

		stage.camera.zoom = Vector2.ONE

	# =============================================================
	# 2. SEQUÊNCIA DE ANIMAÇÃO DO SENTINELA (MARCHA & POISE OVERHEAD)
	# =============================================================
	await stage.switch_room(2, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(600, 276))
	hero.facing = 1

	var sentinel: ForestSentinel = null
	if stage.room != null and stage.room.enemies.size() > 2:
		sentinel = stage.room.enemies[2] as ForestSentinel

	if sentinel != null:
		stage.camera.zoom = Vector2(2.5, 2.5)
		stage.camera.position = ForestLayout.ORIGINS[2] + Vector2(650, 260)
		stage.camera.force_update_scroll()

		# Passo 1: perna dianteira avançada, perna traseira recuada
		sentinel.state = ForestSentinel.State.PATROL
		sentinel.velocity.x = 28.0
		sentinel.global_position.x = sentinel.origin.x + 0.0 # step 0 -> frame 1
		sentinel._sync_visual()
		await frames(5)
		await shot(out_dir + "/sentinela_marcha_01_passo1.png")

		# Passo 2: perna traseira avançada, perna dianteira recuada
		sentinel.global_position.x = sentinel.origin.x + 24.0 # step 2 -> frame 3
		sentinel._sync_visual()
		await frames(5)
		await shot(out_dir + "/sentinela_marcha_02_passo2.png")

		# Windup: Cutelo ósseo erguido acima da cabeça com as duas mãos (POISE ativo)
		sentinel.state = ForestSentinel.State.ATTACK
		sentinel.attack_phase = ForestSentinel.AttackPhase.WINDUP
		sentinel.facing = -1
		sentinel._sync_visual()
		await frames(5)
		await shot(out_dir + "/sentinela_03_poise_overhead.png")

		# Slam: Cutelo cravado contra o chão
		sentinel.attack_phase = ForestSentinel.AttackPhase.ACTIVE
		sentinel._sync_visual()
		await frames(5)
		await shot(out_dir + "/sentinela_04_slam.png")

		stage.camera.zoom = Vector2.ONE

	# =============================================================
	# 3. SEQUÊNCIA DE ANIMAÇÃO DO RASTEJANTE (PASSOS, BOTE E WINDUP)
	# =============================================================
	await stage.switch_room(0, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[0] + Vector2(380, 300))
	hero.facing = 1

	var crawler: ForestCrawler = null
	if stage.room != null and stage.room.enemies.size() > 0:
		crawler = stage.room.enemies[0] as ForestCrawler

	if crawler != null:
		stage.camera.zoom = Vector2(2.5, 2.5)
		stage.camera.position = ForestLayout.ORIGINS[0] + Vector2(440, 290)
		stage.camera.force_update_scroll()

		# Passo 1: patas dianteiras avançadas
		crawler.state = ForestCrawler.State.PATROL
		crawler.velocity.x = 45.0
		crawler.global_position.x = crawler.origin.x + 0.0 # step 0 -> frame 1
		crawler._sync_visual()
		await frames(5)
		await shot(out_dir + "/rastejante_marcha_01_passo1.png")

		# Passo 2: patas traseiras empurrando
		crawler.global_position.x = crawler.origin.x + 20.0 # step 2 -> frame 3
		crawler._sync_visual()
		await frames(5)
		await shot(out_dir + "/rastejante_marcha_02_passo2.png")

		# Windup: agachamento tenso
		crawler.state = ForestCrawler.State.ATTACK
		crawler.attack_phase = ForestCrawler.AttackPhase.WINDUP
		crawler.facing = -1
		crawler._sync_visual()
		await frames(5)
		await shot(out_dir + "/rastejante_04_windup.png")

		# Bote ativo: pounce alongado
		crawler.attack_phase = ForestCrawler.AttackPhase.ACTIVE
		crawler._sync_visual()
		await frames(5)
		await shot(out_dir + "/rastejante_03_bote_lunge.png")

		stage.camera.zoom = Vector2.ONE

	# =============================================================
	# 4. CAPTURAS DE GAMEPLAY REAL NOS SETORES (SEM PONTOS AZUIS)
	# =============================================================
	# SETOR 1
	await stage.switch_room(0, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[0] + Vector2(380, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor1_01_rastejante_e01.png")

	# SETOR 2
	await stage.switch_room(1, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[1] + Vector2(460, 280))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor2_02_corvo_espectral_e04.png")

	# SETOR 3 (Espículas e Sentinela)
	await stage.switch_room(2, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(420, 290))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(25)
	await shot(out_dir + "/setor3_01_espicula_p01.png")

	hero.reset_to(ForestLayout.ORIGINS[2] + Vector2(600, 276))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor3_02_sentinela_e07.png")

	# SETOR 4 (Sentinela e Combate Poise)
	await stage.switch_room(3, false)
	while stage.busy:
		await physics_frame
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(400, 300))
	hero.facing = 1
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(15)
	await shot(out_dir + "/setor4_01_sentinela_e08.png")

	# Combate Poise
	hero.reset_to(ForestLayout.ORIGINS[3] + Vector2(450, 300))
	hero.facing = 1
	if stage.room != null and stage.room.enemies.size() > 0:
		var s: ForestSentinel = stage.room.enemies[0] as ForestSentinel
		if s != null:
			s.state = ForestSentinel.State.ATTACK
			s.attack_phase = ForestSentinel.AttackPhase.WINDUP
			s.facing = -1
			s._poise_flash_timer = 0.10
			s._sync_visual()
	stage.camera.position = stage.camera_target()
	stage.camera.force_update_scroll()
	await frames(10)
	await shot(out_dir + "/combate_poise_sentinela.png")

	print("\nCaptura M6-C1-ART-FIX02 finalizada com sucesso!")
	quit(0)
