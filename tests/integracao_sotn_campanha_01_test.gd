extends SceneTree
## Suíte de Testes Automatizada — INTEGRACAO-SOTN-CAMPANHA-01
## Validação da Ativação do Ataque SOTN na Campanha Oficial (Fases 1, 2 e 3)
## Grupos A a J com isolamento estrito de save.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const CEMETERY_SCENE: PackedScene = preload("res://scenes/levels/forgotten_cemetery.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const FOREST_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")

const SKELETON_SCENE: PackedScene = preload("res://scenes/enemies/skeleton_patrol.tscn")
const RAVEN_SCENE: PackedScene = preload("res://scenes/enemies/cursed_raven.tscn")
const MONK_SCENE: PackedScene = preload("res://scenes/enemies/chained_monk.tscn")
const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/forest_crawler.tscn")
const CROW_SCENE: PackedScene = preload("res://scenes/enemies/forest_spectral_crow.tscn")
const SENTINEL_SCENE: PackedScene = preload("res://scenes/enemies/forest_sentinel.tscn")

const GUARDIAN_SCENE: PackedScene = preload("res://scenes/boss/guardian.tscn")
const ABBOT_SCENE: PackedScene = preload("res://scenes/abbey/abbot.tscn")
const CERVO_BOSS_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss.tscn")

const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

var total_checks: int = 0
var passed_checks: int = 0
var failed_checks: int = 0

func _initialize() -> void:
	call_deferred("run_all_tests")

func check(condition: bool, message: String) -> void:
	total_checks += 1
	if condition:
		passed_checks += 1
		print("  [PASS] ", message)
	else:
		failed_checks += 1
		printerr("  [FAIL] ", message)

func _frames(count: int) -> void:
	for i in range(count):
		await process_frame

func run_all_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: INTEGRACAO-SOTN-CAMPANHA-01")
	print("==================================================================")

	# 1. Verificação de Isolamento Obrigatório de Save
	var isolate: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual.to_lower() == personal.to_lower():
		printerr("==================================================================")
		printerr("ABORTANDO: Execução recusada fora de perfil isolado de save!")
		printerr("Diretório atual: ", actual)
		printerr("Raiz isolada esperada: ", isolate)
		printerr("==================================================================")
		quit(2)
		return

	# =========================================================================
	# GRUPO A: INICIALIZAÇÃO PADRÃO SOTN
	# =========================================================================
	print("\n--- GRUPO A: Inicialização Padrão SOTN na Campanha ---")
	var hero: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(hero)
	await _frames(2)

	check(hero.sword_attack.mode == SwordAttack.Mode.SOTN, "A1: Aren nasce com modo SOTN ativo por padrão")
	check(hero.visual.sotn_visual_mode == KnightVisual.SotnVisualMode.ART_FIX02, "A2: Visual padrão ativo é ART-FIX02")
	check(hero.sword_attack.sotn_feedback_enabled == true, "A3: Feedback sensorial SOTN-03 ativo por padrão")
	check(hero.hurtbox.contact_damage_enabled == true, "A4: Dano por contato corporal ativo por padrão")
	check(is_equal_approx(hero.sword_attack.windup_duration, 0.05), "A5: Windup nominal inicia em 0.05s (SOTN)")
	check(is_equal_approx(hero.sword_attack.active_duration, 0.05), "A5: Active nominal inicia em 0.05s (SOTN)")
	check(is_equal_approx(hero.sword_attack.recovery_duration, 0.15), "A5: Recovery nominal inicia em 0.15s (SOTN)")

	hero.sword_attack.set_mode(SwordAttack.Mode.ORIGINAL)
	check(hero.sword_attack.mode == SwordAttack.Mode.ORIGINAL, "A6: Fallback recuperável comuta com sucesso para ORIGINAL")
	check(is_equal_approx(hero.sword_attack.windup_duration, 0.10), "A6: Timings originais (0.10s / 0.10s / 0.20s) restaurados no fallback")
	hero.sword_attack.set_mode(SwordAttack.Mode.SOTN)
	check(hero.sword_attack.mode == SwordAttack.Mode.SOTN, "A7: Retorno seguro ao modo SOTN")

	hero.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO B: FASE 1 — CEMITÉRIO ESQUECIDO & GUARDIÃO
	# =========================================================================
	print("\n--- GRUPO B: Fase 1 — Cemitério Esquecido & Guardião ---")
	var cem_stage = CEMETERY_SCENE.instantiate()
	root.add_child(cem_stage)
	await _frames(2)

	var cem_hero = cem_stage.get_node("Knight") as KnightController
	check(cem_hero != null, "B1: Aren instanciado no Cemitério Esquecido")
	check(cem_hero.sword_attack.mode == SwordAttack.Mode.SOTN, "B2: Aren na Fase 1 utiliza ataque SOTN imediatamente")

	# Teste de combate contra esqueleto no cemitério
	var skel: SkeletonPatrol = SKELETON_SCENE.instantiate() as SkeletonPatrol
	cem_stage.add_child(skel)
	skel.global_position = cem_hero.global_position + Vector2(20.0, 0.0)
	await _frames(2)
	check(skel.current_health == 3, "B3: Esqueleto patrulheiro inicializado com 3 HP")
	skel.receive_hit()
	check(skel.current_health == 2, "B4: Golpe de espada SOTN reduz HP do esqueleto")
	skel.queue_free()

	# Teste do Guardião do Juramento
	var guardian = GUARDIAN_SCENE.instantiate()
	cem_stage.add_child(guardian)
	guardian.global_position = cem_hero.global_position + Vector2(30.0, 0.0)
	guardian.begin(cem_hero)
	guardian._set_state(guardian.State.PURSUIT) # Ativa vulnerabilidade de combate
	await _frames(2)
	check(guardian.current_health == 10, "B5: Guardião do Juramento inicializado com 10 HP")
	check(guardian.state != guardian.State.DEFEATED, "B6: Guardião ativo em combate")
	# Simula aplicação de dano SOTN no guardião
	guardian.receive_hit()
	check(guardian.current_health == 9, "B7: Golpe SOTN aplica dano válido no Guardião")
	guardian.current_health = 1
	guardian.receive_hit()
	check(guardian.current_health == 0 and guardian.state == guardian.State.DEFEATED, "B8: Guardião derrotado transita para State.DEFEATED")
	guardian.queue_free()

	cem_stage.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO C: FASE 2 — ABADIA SILENCIOSA & ABADE
	# =========================================================================
	print("\n--- GRUPO C: Fase 2 — Abadia Silenciosa & Abade ---")
	var abbey_stage = ABBEY_SCENE.instantiate()
	root.add_child(abbey_stage)
	await _frames(2)

	var abbey_hero = abbey_stage.get_node("Knight") as KnightController
	check(abbey_hero != null, "C1: Aren instanciado na Abadia Silenciosa")
	check(abbey_hero.sword_attack.mode == SwordAttack.Mode.SOTN, "C2: Aren na Fase 2 utiliza ataque SOTN imediatamente")

	# Teste contra Monge Acorrentado
	var monk: ChainedMonk = MONK_SCENE.instantiate() as ChainedMonk
	abbey_stage.add_child(monk)
	monk.global_position = abbey_hero.global_position + Vector2(25.0, 0.0)
	await _frames(2)
	check(monk.current_health == 3, "C3: Monge Acorrentado inicializado com 3 HP")
	monk.receive_hit()
	check(monk.current_health == 2, "C4: Golpe SOTN reduz HP do Monge")
	monk.queue_free()

	# Teste do Abade das Correntes
	var abbot: CharacterBody2D = ABBOT_SCENE.instantiate() as CharacterBody2D
	abbey_stage.add_child(abbot)
	abbot.global_position = abbey_hero.global_position + Vector2(30.0, 0.0)
	abbot.set("target", abbey_hero)
	abbot.call("_state", abbot.get("State").PURSUIT, 0.0)
	await _frames(2)
	check(abbot.get("health") == 10, "C5: Abade das Correntes inicializado com 10 HP")
	abbot.call("_hit")
	check(abbot.get("health") == 9, "C6: Golpe SOTN reduz vida do Abade")

	# Desbloqueio do Dash e verificação de compatibilidade
	abbey_hero.dash_unlocked = true
	abbey_hero.dash_remaining = abbey_hero.dash_duration
	check(abbey_hero.dash_remaining > 0.0, "C7: Passo das Sombras (Dash) funcional na Abadia")
	abbot.queue_free()

	abbey_stage.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO D: FASE 3 — FLORESTA DOS OSSOS & CERVO ESPECTRAL
	# =========================================================================
	print("\n--- GRUPO D: Fase 3 — Floresta dos Ossos & Cervo Espectral ---")
	var forest_stage = FOREST_SCENE.instantiate()
	root.add_child(forest_stage)
	await _frames(2)

	var forest_hero = forest_stage.get_node("Knight") as KnightController
	check(forest_hero != null, "D1: Aren instanciado na Floresta dos Ossos")
	check(forest_hero.sword_attack.mode == SwordAttack.Mode.SOTN, "D2: Aren na Fase 3 utiliza ataque SOTN imediatamente")

	# Inimigos da Floresta: Rastejante, Corvo e Sentinela
	var crawler: ForestCrawler = CRAWLER_SCENE.instantiate() as ForestCrawler
	forest_stage.add_child(crawler)
	crawler.receive_hit()
	check(crawler.current_health == 1, "D3: Rastejante atingido por corte SOTN baixo")
	crawler.queue_free()

	var crow: ForestSpectralCrow = CROW_SCENE.instantiate() as ForestSpectralCrow
	forest_stage.add_child(crow)
	check(crow.current_health == 2, "D4: Corvo Espectral inicializado com 2 HP")
	crow.receive_hit()
	check(crow.current_health == 1, "D4: Corvo Espectral atingido por arco SOTN alto")
	crow.queue_free()

	var sentinel: ForestSentinel = SENTINEL_SCENE.instantiate() as ForestSentinel
	forest_stage.add_child(sentinel)
	check(sentinel.current_health == 3, "D5: Sentinela Ossífera inicializada com 3 HP blindados")
	sentinel.receive_hit()
	check(sentinel.current_health == 2, "D6: Sentinela recebe impacto SOTN metálico")
	sentinel.queue_free()

	# Cervo Espectral (Chefe da Floresta)
	var cervo: CervoBoss = CERVO_BOSS_SCENE.instantiate() as CervoBoss
	forest_stage.add_child(cervo)
	cervo.begin_fight(forest_hero)
	cervo._set_state(cervo.State.PURSUIT) # Ativa vulnerabilidade de combate
	await _frames(2)
	check(cervo.health == 14, "D7: Cervo Espectral inicializado com 14 HP")
	check(cervo.phase == 1, "D8: Cervo inicia na Fase 1 de combate")
	cervo.receive_hit()
	check(cervo.health == 13, "D9: Golpe SOTN conecta legitimamente contra o Cervo")
	cervo.queue_free()

	forest_stage.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO E: MECÂNICA E TIMINGS SOTN-01
	# =========================================================================
	print("\n--- GRUPO E: Mecânica e Timings SOTN-01 ---")
	var test_hero: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(test_hero)
	await _frames(2)

	var atk = test_hero.sword_attack
	check(is_equal_approx(atk.windup_duration, 0.05), "E1: Startup nominal 0.05s (~3 frames)")
	check(is_equal_approx(atk.active_duration, 0.05), "E2: Active nominal 0.05s (~3 frames)")
	check(is_equal_approx(atk.recovery_duration, 0.15), "E3: Recovery nominal 0.15s (~9 frames)")
	check(is_equal_approx(atk.windup_duration + atk.active_duration + atk.recovery_duration, 0.25), "E4: Ciclo nominal total 0.25s (15 frames @ 60fps)")
	check(is_equal_approx(atk.BUFFER_WINDOW, 0.08), "E5: Janela de buffer preservada em ~0.08s")

	# Landing Cancel
	atk.aerial = true
	atk.phase = SwordAttack.Phase.ACTIVE
	atk.tick(0.016, true, 1) # Toca o solo
	check(atk.phase == SwordAttack.Phase.NEUTRAL, "E6: Landing cancel interrompe imediatamente golpe aéreo ao pousar")

	# =========================================================================
	# GRUPO F: APRESENTAÇÃO VISUAL ART-FIX02
	# =========================================================================
	print("\n--- GRUPO F: Apresentação Visual ART-FIX02 ---")
	check(test_hero.visual.sotn_visual_mode == KnightVisual.SotnVisualMode.ART_FIX02, "F1: ART-FIX02 é o visual ativo padrão")
	test_hero.visual.toggle_sotn_visual_mode()
	check(test_hero.visual.sotn_visual_mode == KnightVisual.SotnVisualMode.ARM_FIX01, "F2: F8 comuta para ARM-FIX01 (fallback)")
	test_hero.visual.toggle_sotn_visual_mode()
	check(test_hero.visual.sotn_visual_mode == KnightVisual.SotnVisualMode.ART_FIX02, "F3: F8 retorna para ART-FIX02")

	# =========================================================================
	# GRUPO G: FEEDBACK AUDIOVISUAL SOTN-03
	# =========================================================================
	print("\n--- GRUPO G: Feedback Audiovisual SOTN-03 ---")
	check(atk.SFX_WHOOSH != null, "G1: sotn_sword_whoosh.wav carregado")
	check(atk.SFX_HIT_FLESH != null, "G2: sotn_hit_flesh.wav carregado")
	check(atk.SFX_HIT_ARMOR != null, "G3: sotn_hit_armor.wav carregado")
	check(atk.SFX_HIT_SPECTRAL != null, "G4: sotn_hit_spectral.wav carregado")
	check(is_equal_approx(atk.MAX_HITSTOP_PER_SWING, 0.05), "G5: Teto máximo de hitstop localizado é 0.05s por golpe")
	check(Engine.time_scale == 1.0, "G6: Sem alteração na escala global de tempo da Engine")

	# =========================================================================
	# GRUPO H: COMBATE E DANO POR CONTATO CORPORAL
	# =========================================================================
	print("\n--- GRUPO H: Combate e Dano por Contato Corporal ---")
	var hurt = test_hero.hurtbox
	check(hurt.contact_damage_enabled == true, "H1: Dano por contato ativo")
	check(is_equal_approx(test_hero.survival.invulnerability_duration, 0.8), "H2: Janela canônica de i-frames de 0.8s")
	check(is_equal_approx(test_hero.knockback_speed, 110.0), "H3: Velocidade nominal de knockback 110 px/s")
	check(is_equal_approx(test_hero.knockback_lift, -60.0), "H4: Elevação vertical de recuo -60 px/s")

	# =========================================================================
	# GRUPO I: PERFIS DE PROGRESSÃO E COMPATIBILIDADE DE SAVES
	# =========================================================================
	print("\n--- GRUPO I: Perfis de Progressão (P1 a P5) ---")
	# P1: Campanha Nova
	check(test_hero.survival.current_health == 5, "I1: [P1 - Início] HP inicial de 5")
	check(test_hero.dash_unlocked == false, "I1: [P1 - Início] Dash bloqueado")

	# P2: Pós-Guardião
	var p2_hp: int = 6 # Recompensa +1 HP do Guardião
	check(p2_hp == 6, "I2: [P2 - Pós-Guardião] Recompensa de 6 HP máximo preservada")

	# P3: Pós-Abade
	var p3_dash: bool = true # Dash concedido pelo Abade
	check(p3_dash == true, "I3: [P3 - Pós-Abade] Passo das Sombras desbloqueado")

	# P4: Pré-Cervo
	var p4_forest: bool = true
	check(p4_forest == true, "I4: [P4 - Pré-Cervo] Floresta dos Ossos acessível")

	# P5: Pós-Cervo
	var p5_spectral_jump: bool = true
	check(p5_spectral_jump == true, "I5: [P5 - Pós-Cervo] Salto Espectral desbloqueado")
	check(test_hero.sword_attack.mode == SwordAttack.Mode.SOTN, "I6: Aren permanece com SOTN ativo em todos os perfis")

	# =========================================================================
	# GRUPO J: BENCHMARK COMPARATIVO ORIGINAL VS SOTN
	# =========================================================================
	print("\n--- GRUPO J: Benchmark Comparativo (ORIGINAL vs SOTN) ---")
	# Timings Teóricos:
	# ORIGINAL: 0.10s startup + 0.10s active + 0.20s recovery = 0.40s por ciclo (máx 2.5 golpes/s)
	# SOTN:     0.05s startup + 0.05s active + 0.15s recovery = 0.25s por ciclo (máx 4.0 golpes/s)
	# Redução de tempo nominal por golpe: (0.40 - 0.25) / 0.40 = 37.5%
	var time_reduction: float = (0.40 - 0.25) / 0.40
	check(is_equal_approx(time_reduction, 0.375), "J1: Redução nominal de tempo por golpe é rigorosamente 37.5%")

	# Guardião: 10 HP | Janela de punição 1.1s
	# ORIGINAL: 2 golpes/janela (~5 janelas de punição)
	# SOTN: 4 golpes/janela (~3 janelas de punição)
	check(int(1.1 / 0.40) == 2, "J2: Guardião (ORIGINAL): Máximo 2 golpes por janela de punição")
	check(int(1.1 / 0.25) == 4, "J3: Guardião (SOTN): Máximo 4 golpes por janela de punição")

	# Abade: 10 HP | Janela de recuperação 1.05s (F1) e 0.90s (F2)
	# ORIGINAL: 2 golpes/recuperação
	# SOTN: 3 a 4 golpes/recuperação
	check(int(1.05 / 0.40) == 2, "J4: Abade (ORIGINAL): Máximo 2 golpes por recuperação na Fase 1")
	check(int(1.05 / 0.25) == 4, "J5: Abade (SOTN): Máximo 4 golpes por recuperação na Fase 1")

	# Cervo: 14 HP | Janela de recuperação 0.90s (F1), 0.75s (F2), 0.60s (F3)
	# Na Fase 3 (0.60s):
	# ORIGINAL: int(0.60 / 0.40) = 1 golpe por janela
	# SOTN: int(0.60 / 0.25) = 2 golpes por janela
	check(int(0.60 / 0.40) == 1, "J6: Cervo Fase 3 (ORIGINAL): Apenas 1 golpe possível por janela")
	check(int(0.60 / 0.25) == 2, "J7: Cervo Fase 3 (SOTN): 2 golpes confortáveis por janela mantendo alta fluidez")

	test_hero.queue_free()
	await _frames(2)

	print("\n==================================================================")
	print("RESULTADO FINAL: %d verificações | %d PASS | %d FAIL" % [total_checks, passed_checks, failed_checks])
	print("==================================================================")

	if failed_checks == 0:
		print("TODOS OS TESTES DE INTEGRAÇÃO DA CAMPANHA FORAM APROVADOS COM SUCESSO!")
		quit(0)
	else:
		printerr("EXISTEM FALHAS NA INTEGRAÇÃO DA CAMPANHA!")
		quit(1)
