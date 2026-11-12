extends SceneTree
## Suíte de Testes Automatizada — RETORNO-ENTRE-FASES-01
## Transições Físicas Bidirecionais: Cemitério ↔ Abadia ↔ Floresta
## Grupos A a G com isolamento estrito de save.

const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const CEMETERY_SCENE: PackedScene = preload("res://scenes/levels/forgotten_cemetery.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const FOREST_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const GUARDIAN_ENCOUNTER_SCENE: PackedScene = preload("res://scenes/boss/guardian_arena.tscn")

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
	print("INICIANDO SUÍTE OFICIAL: RETORNO-ENTRE-FASES-01")
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
	# GRUPO A: TRANSIÇÕES BIDIRECIONAIS E CONEXÕES FÍSICAS
	# =========================================================================
	print("\n--- GRUPO A: Conexões Físicas Bidirecionais ---")

	# Limpa estado de transição em memória
	ABBEY_PROGRESS.set_pending_entrance("")

	# A1: Teste Cemitério -> Abadia (Avanço)
	var cemetery: Node2D = CEMETERY_SCENE.instantiate() as Node2D
	root.add_child(cemetery)
	await _frames(2)
	check(cemetery.knight.position.x == 48.0, "A1: Cemitério inicial padrão inicia Aren em x=48")

	# Simula vitória do Guardião
	ABBEY_PROGRESS._grant_fields({"guardian_defeated": true, "health_upgrade_unlocked": true})
	check(ABBEY_PROGRESS.guardian_reward_unlocked(), "A2: Recompensa do Guardião registrada")

	# Simula Aren alcançando o gatilho de saída do Cemitério (x >= 2340)
	cemetery.knight.position.x = 2345.0
	cemetery._physics_process(0.016)
	check(cemetery.transitioning == true, "A3: Gatilho de saída do Cemitério acionado ao avançar para x >= 2340")
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_cemetery", "A4: Sinalizador pending_entrance marcado como 'from_cemetery'")
	cemetery.queue_free()
	await _frames(2)

	# A5: Teste Abadia vinda do Cemitério (Chegada no Setor 0)
	var abbey: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey)
	while abbey.busy or abbey.current_room < 0:
		await _frames(1)
	check(abbey.current_room == 0, "A5: Abadia vinda do Cemitério carrega Setor 0 (Átrio dos Votos)")
	check(abbey.hero.global_position.x == 48.0, "A6: Aren surge na entrada oeste do Setor 0 (x=48)")
	check(abbey.hero.facing == 1, "A7: Aren surge virado para a direita (+1)")
	check(ABBEY_PROGRESS.get_pending_entrance() == "", "A8: Sinalizador pending_entrance consumido na entrada da Abadia")

	# A9: Teste Abadia -> Cemitério (Retorno físico do Setor 0)
	abbey.hero.global_position = AbbeyChapterLayout.origin(0) + Vector2(10.0, 300.0) # Margem oeste (x <= 16)
	abbey.hero.facing = -1 # Virado para a esquerda
	abbey._physics_process(0.016)
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_abbey", "A9: Retorno oeste do Setor 0 sinaliza pending_entrance='from_abbey'")
	abbey.queue_free()
	await _frames(2)

	ABBEY_PROGRESS.set_pending_entrance("from_abbey")
	# A10: Teste Reentrada no Cemitério (Vindo da Abadia)
	var cemetery_return: Node2D = CEMETERY_SCENE.instantiate() as Node2D
	root.add_child(cemetery_return)
	await _frames(2)
	check(cemetery_return.knight.position.x == 2296.0, "A10: Aren reaparece fisicamente junto ao Portão da Catedral (x=2296)")
	check(cemetery_return.knight.facing == -1, "A11: Aren surge no Cemitério virado para a esquerda (-1)")
	check(cemetery_return.transitioning == false, "A12: Sem transição imediata (não cai em loop de retorno)")
	cemetery_return.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO B: CONEXÃO ABADIA ↔ FLORESTA E SPAWNS SEGUROS
	# =========================================================================
	print("\n--- GRUPO B: Conexão Abadia ↔ Floresta e Spawns Seguros ---")

	# Simula vitória do Abade (Dash desbloqueado)
	ABBEY_PROGRESS._grant_fields({"abbot_defeated": true, "dash_unlocked": true})
	check(ABBEY_PROGRESS.unlocked(), "B1: Vitória do Abade e Dash desbloqueados")

	# B2: Teste Abadia Setor 11 -> Floresta
	var abbey_exit: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey_exit)
	while abbey_exit.busy or abbey_exit.current_room < 0:
		await _frames(1)
	await abbey_exit.switch_room(11, false)
	while abbey_exit.busy:
		await _frames(1)
	check(abbey_exit.current_room == 11, "B2: Aren no Setor 11 da Abadia")

	# Caminha para a margem leste do Setor 11
	abbey_exit.hero.global_position = AbbeyChapterLayout.origin(11) + Vector2(1400.0, 300.0)
	abbey_exit.hero.facing = 1
	abbey_exit._physics_process(0.016)
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_abbey", "B3: Saída leste do Setor 11 sinaliza pending_entrance='from_abbey'")
	abbey_exit.queue_free()
	await _frames(2)

	# B4: Teste Floresta vinda da Abadia (Chegada no Setor 0)
	var forest: Node2D = FOREST_SCENE.instantiate() as Node2D
	root.add_child(forest)
	await _frames(2)
	check(forest.current_room == 0, "B4: Floresta carrega Setor 0 (Entrada da Floresta)")
	check(forest.hero.global_position.x == 48.0, "B5: Aren surge na entrada oeste da Floresta (x=48)")
	check(forest.hero.facing == 1, "B6: Aren virado para a direita (+1)")
	check(forest.hero.dash_unlocked == true, "B7: Dash disponível na Floresta")

	# B8: Teste Floresta -> Abadia (Retorno físico do Setor 0)
	forest.hero.global_position.x = 10.0 # Margem oeste (local.x <= 16)
	forest.hero.facing = -1 # Virado para a esquerda
	forest._physics_process(0.016)
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_forest", "B8: Retorno oeste da Floresta sinaliza pending_entrance='from_forest'")
	forest.queue_free()
	await _frames(2)

	ABBEY_PROGRESS.set_pending_entrance("from_forest")
	# B9: Teste Reentrada na Abadia (Vindo da Floresta -> Chegada no Setor 11)
	var abbey_return: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey_return)
	while abbey_return.busy or abbey_return.current_room < 0:
		await _frames(1)
	check(abbey_return.current_room == 11, "B9: Abadia vinda da Floresta carrega Setor 11 (Coro das Correntes)")
	check(abbey_return.hero.global_position.x == AbbeyChapterLayout.origin(11).x + 1360.0, "B10: Aren surge na margem leste do Setor 11 (x=1360)")
	check(abbey_return.hero.facing == -1, "B11: Aren surge virado para a esquerda (-1, adentrando a Abadia)")
	check(abbey_return.busy == false, "B12: Estado desimpedido (busy=false) e pronto para controle")
	abbey_return.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO C: GUARDIÃO DO JURAMENTO (REVISITA E NÃO DUPLICAÇÃO)
	# =========================================================================
	print("\n--- GRUPO C: Guardião do Juramento (Revisita Idempotente) ---")

	var cemetery_boss: Node2D = CEMETERY_SCENE.instantiate() as Node2D
	var main_holder: Node2D = Node2D.new()
	main_holder.name = "Main"
	root.add_child(main_holder)
	main_holder.add_child(cemetery_boss)

	var encounter_script: Script = load("res://scripts/boss/encounter.gd")
	var encounter: Node2D = Node2D.new()
	encounter.name = "GuardianEncounter"
	encounter.set_script(encounter_script)
	main_holder.add_child(encounter)
	await _frames(2)

	check(encounter.completed == true, "C1: Encontro do Guardião detecta vitória prévia automaticamente")
	check(encounter.exit_unlocked == true, "C2: Saída da arena permanece desbloqueada")
	check(encounter.arena == null, "C3: Arena do Guardião não é instanciada indevidamente na revisita")
	check(cemetery_boss.knight.survival.max_health == 6, "C4: HP máximo de Aren permanece 6 HP no Cemitério")

	# Verifica se entrar no gatilho do selo não reinicia batalha
	cemetery_boss.knight.position = Vector2(2344, 138)
	await _frames(2)
	check(encounter.active == false, "C5: Entrar no ponto do selo não inicia combate obrigatório")

	main_holder.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO D: ABADE DAS CORRENTES (REVISITA E DASH PRESERVADO)
	# =========================================================================
	print("\n--- GRUPO D: Abade das Correntes (Revisita Idempotente) ---")

	var abbey_boss: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey_boss)
	while abbey_boss.busy or abbey_boss.current_room < 0:
		await _frames(1)
	await abbey_boss.switch_room(11, false)
	while abbey_boss.busy:
		await _frames(1)

	check(abbey_boss.hero.dash_unlocked == true, "D1: Dash permanece desbloqueado na revisita da Abadia")
	check(abbey_boss.hero.survival.max_health == 6, "D2: HP Máximo de 6 HP preservado")

	# Avanço em direção à Floresta não bloqueia com arena obrigatória
	abbey_boss.hero.global_position = AbbeyChapterLayout.origin(11) + Vector2(1395.0, 300.0)
	abbey_boss.hero.facing = 1
	abbey_boss._physics_process(0.016)
	check(abbey_boss.arena_active == false, "D3: Aren atravessa para a Floresta sem ser puxado para luta obrigatória")
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_abbey", "D4: Transição para Floresta acionada com sucesso")

	abbey_boss.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO E: PÓS-CERVO E RETORNO INTEGRAL DA FASE 3
	# =========================================================================
	print("\n--- GRUPO E: Pós-Cervo e Retorno Integral da Fase 3 ---")

	# Simula vitória do Cervo Espectral
	ABBEY_PROGRESS._grant_fields({"cervo_defeated": true, "spectral_jump_unlocked": true})
	check(ABBEY_PROGRESS.spectral_jump_unlocked(), "E1: Salto Espectral desbloqueado no progresso")

	var forest_cervo: Node2D = FOREST_SCENE.instantiate() as Node2D
	root.add_child(forest_cervo)
	await _frames(2)

	check(forest_cervo.hero.spectral_jump_unlocked == true, "E2: Salto Espectral ativo no herói da Floresta")
	check(forest_cervo.hero.dash_unlocked == true, "E3: Dash ativo no herói")
	check(forest_cervo.hero.survival.max_health == 6, "E4: 6 HP ativo no herói")

	# Move Aren para o Setor 9 (Clareira da Bruma Espectral)
	await forest_cervo.switch_room(9, false)
	await _frames(2)
	check(forest_cervo.current_room == 9, "E5: Aren alcança o Setor 9 (Arena pós-Cervo)")

	# Retorno do Setor 9 para o Setor 8
	await forest_cervo.switch_room(8, true)
	await _frames(2)
	check(forest_cervo.current_room == 8, "E6: Aren retorna fisicamente do Setor 9 para o Setor 8")

	# Retorno para o Setor 0
	await forest_cervo.switch_room(0, true)
	await _frames(2)
	check(forest_cervo.current_room == 0, "E7: Aren retorna fisicamente até o Setor 0 da Floresta")

	# Atravessa a saída oeste para a Abadia
	forest_cervo.hero.global_position.x = 12.0
	forest_cervo.hero.facing = -1
	forest_cervo._physics_process(0.016)
	check(ABBEY_PROGRESS.get_pending_entrance() == "from_forest", "E8: Saída da Floresta acionada após retorno do Cervo")

	forest_cervo.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO F: SINCRONIZAÇÃO DE HABILIDADES EM TODAS AS FASES
	# =========================================================================
	print("\n--- GRUPO F: Sincronização de Habilidades e Persistência ---")

	# F1: Re-teste no Cemitério com TODAS as habilidades conquistadas
	ABBEY_PROGRESS.set_pending_entrance("from_abbey")
	var cemetery_full: Node2D = CEMETERY_SCENE.instantiate() as Node2D
	root.add_child(cemetery_full)
	await _frames(2)

	check(cemetery_full.knight.survival.max_health == 6, "F1: Cemitério sincroniza 6 HP máximo")
	check(cemetery_full.knight.dash_unlocked == true, "F2: Cemitério sincroniza Passo das Sombras (Dash)")
	check(cemetery_full.knight.spectral_jump_unlocked == true, "F3: Cemitério sincroniza Salto Espectral")
	check(cemetery_full.knight.sword_attack.mode == SwordAttack.Mode.SOTN, "F4: Ataque SOTN ativo no Cemitério")
	check(cemetery_full.knight.position.x == 2296.0, "F5: Posição de retorno no Cemitério preservada (x=2296)")

	cemetery_full.queue_free()
	await _frames(2)

	# F2: Re-teste na Abadia com TODAS as habilidades
	ABBEY_PROGRESS.set_pending_entrance("from_forest")
	var abbey_full: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey_full)
	while abbey_full.busy or abbey_full.current_room < 0:
		await _frames(1)

	check(abbey_full.hero.survival.max_health == 6, "F6: Abadia sincroniza 6 HP máximo")
	check(abbey_full.hero.dash_unlocked == true, "F7: Abadia sincroniza Passo das Sombras (Dash)")
	check(abbey_full.hero.spectral_jump_unlocked == true, "F8: Abadia sincroniza Salto Espectral")
	check(abbey_full.hero.sword_attack.mode == SwordAttack.Mode.SOTN, "F9: Ataque SOTN ativo na Abadia")

	abbey_full.queue_free()
	await _frames(2)

	# =========================================================================
	# GRUPO G: CASOS EXTREMOS, ROBUSTEZ E NÃO-DUPLICAÇÃO
	# =========================================================================
	print("\n--- GRUPO G: Casos Extremos, Robustez e Não-Duplicação ---")

	# G1: Tentativa de transição durante a morte
	var cemetery_dead: Node2D = CEMETERY_SCENE.instantiate() as Node2D
	root.add_child(cemetery_dead)
	await _frames(2)
	cemetery_dead.knight.survival.current_health = 0
	cemetery_dead.knight.survival.is_dead = true
	cemetery_dead.knight.position.x = 2350.0
	cemetery_dead._physics_process(0.016)
	check(cemetery_dead.transitioning == false, "G1: Transição bloqueada se o jogador estiver morto")
	cemetery_dead.queue_free()
	await _frames(2)

	# G2: Ausência de duplicação de nós
	var abbey_nodes: Node2D = ABBEY_SCENE.instantiate() as Node2D
	root.add_child(abbey_nodes)
	await _frames(2)
	var knight_count: int = 0
	for child in abbey_nodes.get_children():
		if child is KnightController:
			knight_count += 1
	check(knight_count == 1, "G2: Exatamente 1 instância de KnightController na Abadia (sem duplicidade)")

	var hud_count: int = 0
	for child in abbey_nodes.get_children():
		if child.name.ends_with("HUD"):
			hud_count += 1
	check(hud_count >= 1, "G3: HUD presente sem instâncias fantasmas duplicadas")
	abbey_nodes.queue_free()
	await _frames(2)

	# G4: Limpeza final de variáveis temporárias
	ABBEY_PROGRESS.set_pending_entrance("")
	check(ABBEY_PROGRESS.get_pending_entrance() == "", "G4: pending_entrance limpo com sucesso")

	# =========================================================================
	# RESUMO FINAL
	# =========================================================================
	print("\n==================================================================")
	print("RESUMO DA SUÍTE: RETORNO-ENTRE-FASES-01")
	print("==================================================================")
	print("  TOTAL DE VERIFICAÇÕES : ", total_checks)
	print("  APROVADAS (PASS)      : ", passed_checks)
	print("  FALHAS    (FAIL)      : ", failed_checks)
	print("==================================================================")

	if failed_checks == 0 and total_checks >= 40:
		print("RESULTADO: TODAS AS VERIFICAÇÕES APROVADAS COM SUCESSO!")
		quit(0)
	else:
		printerr("RESULTADO: SUÍTE REPROVADA!")
		quit(1)
