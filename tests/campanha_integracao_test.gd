extends SceneTree
## Teste oficial de integração contínua da campanha (CAMPANHA-INTEGRACAO-01).
## Valida a jornada completa: Fase 1 -> Guardião -> Fase 2 -> Abade -> Fase 3 -> Cervo -> Encerramento.
## Comprova a preservação cumulativa de recompensas (+1 HP, Dash, Salto Espectral).

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const FOREST_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

var checks: int = 0
var failures: int = 0

func check(ok: bool, msg: String) -> void:
	checks += 1
	if ok:
		print("  [PASS] ", msg)
	else:
		failures += 1
		printerr("  [FAIL] ", msg)

func _initialize() -> void:
	var isolated: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()
	if isolated.is_empty() or not actual.begins_with(isolated + "/") or actual.to_lower() == personal.to_lower():
		printerr("Teste recusado: perfil isolado não confirmado (SAVE_SAFETY_ISOLATED_ROOT ausente ou incorreto).")
		quit(2)
		return
	# Garante perfil limpo na pasta isolada de teste
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))
	run_journey.call_deferred()

func _frames(count: int = 3) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func run_journey() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE CAMPANHA-INTEGRACAO-01: JORNADA COMPLETA 1 -> 2 -> 3")
	print("==================================================================")

	# -------------------------------------------------------------------------
	# 1. FASE 1 — CEMITÉRIO ESQUECIDO & GUARDIÃO DO JURAMENTO
	# -------------------------------------------------------------------------
	print("\n--- ETAPA 1: Cemitério Esquecido (Fase 1) & Guardião ---")
	var main_node = MAIN_SCENE.instantiate()
	root.add_child(main_node)
	await _frames(4)

	var cemetery = main_node.get_node("ForgottenCemetery")
	var hero_p1 = cemetery.get_node("Knight") as KnightController
	var encounter = main_node.get_node("GuardianEncounter")

	check(is_instance_valid(cemetery), "Cemitério Esquecido carregado")
	check(is_instance_valid(hero_p1), "Aren presente na Fase 1")
	check(hero_p1.survival.max_health == 5, "Vida inicial padrão de Aren = 5 HP")
	check(not hero_p1.dash_unlocked, "Passo das Sombras bloqueado na Fase 1")
	check(not hero_p1.spectral_jump_unlocked, "Salto Espectral bloqueado na Fase 1")

	# Simula entrada no encontro do Guardião
	encounter.enter()
	await _frames(4)
	check(encounter.active == true, "Arena do Guardião ativada")
	check(is_instance_valid(encounter.arena), "Cena da Arena do Guardião instanciada")

	# Simula derrota do Guardião
	encounter._on_defeated()
	await _frames(4)
	check(encounter.completed == true, "Guardião derrotado com sucesso")
	check(ABBEY_PROGRESS.guardian_reward_unlocked() == true, "Recompensa do Guardião salva no progresso (+1 HP)")
	check(hero_p1.survival.max_health == 6, "HP máximo de Aren ampliado para 6")

	# Retorna com vitória ao Cemitério
	encounter.leave(true)
	await _frames(4)
	check(hero_p1.position.x >= 2290.0, "Aren restabelecido diante do Portão da Catedral (x=2296)")
	check(cemetery.hint_label.text.contains("Catedral aberto") or cemetery.hint_label.text.contains("Abadia"), "HUD indica passagem aberta para a Abadia Silenciosa")

	main_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# 2. FASE 2 — ABADIA SILENCIOSA & ABADE DAS CORRENTES
	# -------------------------------------------------------------------------
	print("\n--- ETAPA 2: Abadia Silenciosa (Fase 2) & Abade ---")
	var abbey_node = ABBEY_SCENE.instantiate()
	root.add_child(abbey_node)
	while abbey_node.busy:
		await process_frame
	await _frames(4)

	var hero_p2 = abbey_node.hero as KnightController
	check(is_instance_valid(abbey_node), "Abadia Silenciosa carregada")
	check(abbey_node.current_room == 0, "Aren surge no Setor 1: Átrio dos Votos")
	check(hero_p2.survival.max_health == 6, "Recompensa de 6 HP persiste na entrada da Abadia!")
	check(not hero_p2.dash_unlocked, "Passo das Sombras permanece bloqueado antes do Abade")

	# Avança até o Setor 12 (Coro das Correntes, id=11)
	await abbey_node.switch_room(11, false, true)
	while abbey_node.busy:
		await process_frame
	await _frames(4)
	check(abbey_node.current_room == 11, "Setor 12 (Coro das Correntes) alcançado")

	# Entra na arena do Abade
	abbey_node._enter_abbot_arena()
	while abbey_node.busy:
		await process_frame
	await _frames(4)
	check(abbey_node.arena_active == true, "Arena do Abade das Correntes ativada")

	# Simula derrota do Abade
	abbey_node._on_abbot_defeated()
	await _frames(6)
	check(abbey_node.abbot_won == true, "Abade das Correntes derrotado com sucesso")
	check(ABBEY_PROGRESS.unlocked() == true, "Passo das Sombras salvo no progresso (unlocked == true)")
	check(hero_p2.dash_unlocked == true, "Técnica Passo das Sombras (Dash) desbloqueada em Aren")

	# Comprova que a passagem à direita conduz para a Floresta
	check(abbey_node.hint.text.contains("Floresta dos Ossos"), "HUD indica avanço à direita para a Floresta dos Ossos")

	abbey_node.queue_free()
	await _frames(4)

	# -------------------------------------------------------------------------
	# 3. FASE 3 — FLORESTA DOS OSSOS & CERVO ESPECTRAL
	# -------------------------------------------------------------------------
	print("\n--- ETAPA 3: Floresta dos Ossos (Fase 3) & Cervo Espectral ---")
	var forest_node = FOREST_SCENE.instantiate()
	root.add_child(forest_node)
	while forest_node.busy:
		await process_frame
	await _frames(4)

	var hero_p3 = forest_node.hero as KnightController
	check(is_instance_valid(forest_node), "Floresta dos Ossos carregada")
	check(forest_node.current_room == 0, "Aren surge no Setor 1: Clareira das Sombras")
	check(hero_p3.survival.max_health == 6, "Recompensa de 6 HP persiste na Floresta!")
	check(hero_p3.dash_unlocked == true, "Passo das Sombras (Dash) ativo e utilizável na Floresta!")
	check(not hero_p3.spectral_jump_unlocked, "Salto Espectral bloqueado antes do Cervo")

	# Avança até o Setor 10 (Clareira da Bruma Espectral, id=9)
	await forest_node.switch_room(9, false, true)
	while forest_node.busy:
		await process_frame
	await _frames(4)
	check(forest_node.current_room == 9, "Setor 10 (Arena do Cervo) alcançado")

	var sector10 = forest_node.room
	var encounter_cervo = sector10.get_node("ClearingEncounter")
	check(is_instance_valid(encounter_cervo), "ClearingEncounter do Cervo Espectral presente")

	# Inicia e simula vitória sobre o Cervo Espectral
	encounter_cervo.boss.target = hero_p3
	encounter_cervo.start_encounter()
	await _frames(4)
	encounter_cervo.boss._physics_process(2.3)

	# Fases de combate até derrota
	for i in range(5): encounter_cervo.boss.receive_hit()
	if encounter_cervo.boss.state == CervoBoss.State.PHASE_TRANSITION:
		encounter_cervo.boss._physics_process(1.0)
	for i in range(5): encounter_cervo.boss.receive_hit()
	if encounter_cervo.boss.state == CervoBoss.State.PHASE_TRANSITION:
		encounter_cervo.boss._physics_process(1.0)
	for i in range(4): encounter_cervo.boss.receive_hit()

	# Processa conclusão cinematográfica
	encounter_cervo.boss.conclusion._physics_process(3.7)
	await _frames(4)

	check(ABBEY_PROGRESS.is_cervo_defeated() == true, "Cervo Espectral marcado como derrotado no progresso")
	check(ABBEY_PROGRESS.spectral_jump_unlocked() == true, "Salto Espectral concedido e salvo!")
	check(hero_p3.spectral_jump_unlocked == true, "Salto Espectral habilitado no controlador de Aren")

	# -------------------------------------------------------------------------
	# 4. ENCERRAMENTO DIGNO DO CONTEÚDO ATUAL
	# -------------------------------------------------------------------------
	print("\n--- ETAPA 4: Encerramento do Conteúdo Atual da Campanha ---")
	# Posiciona Aren próximo ao Pórtico do Juramento (x >= 850)
	hero_p3.global_position = ForestLayout.ORIGINS[9] + Vector2(880.0, 300.0)
	for i in range(4):
		await physics_frame

	check(forest_node.caption.text.contains("CLÍMAX DA CAMPANHA"), "Cabeçalho confirma clímax da campanha")
	check(forest_node.subcaption.text.contains("Três Juramentos Rompidos"), "Subcabeçalho confirma os três chefes derrotados")
	check(forest_node.hint.text.contains("FIM DO CONTEÚDO ATUAL"), "Mensagem de encerramento do conteúdo atual exibida")
	check(forest_node.hint.text.contains("Fase 4"), "Texto confirma que a jornada continuará na Fase 4")

	forest_node.queue_free()
	await _frames(2)

	print("\n==================================================================")
	print("RESULTADO FINAL DA JORNADA: %d verificações | %d PASS | %d FAIL" % [checks, checks - failures, failures])
	print("==================================================================")
	quit(1 if failures > 0 else 0)
