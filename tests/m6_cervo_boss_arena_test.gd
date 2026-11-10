extends SceneTree
## Suíte de testes automatizados da arena e integração no Setor 10 (M6-CERVO-BOSS).
## Valida barreiras dinâmicas, ativação por trigger, HUD, morte/respawn, vitória e revisita pacífica.

const ARENA_SCENE: PackedScene = preload("res://scenes/boss/cervo_boss_arena.tscn")
const SECTOR_10_SCENE: PackedScene = preload("res://scenes/forest/sector_10.tscn")
const KNIGHT_SCENE: PackedScene = preload("res://scenes/player/knight.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CervoBossArena = preload("res://scripts/boss/cervo_boss_arena.gd")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const ForestSector = preload("res://scripts/forest/forest_sector.gd")

var total_passed: int = 0
var total_failed: int = 0

func _init() -> void:
	print("\n==================================================")
	print("SUÍTE DE TESTES: ARENA DO CERVO E SETOR 10 (M6)")
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

func _create_dummy_player() -> KnightController:
	var player: KnightController = KNIGHT_SCENE.instantiate() as KnightController
	root.add_child(player)
	player.global_position = Vector2(48, 260)
	return player

func _run_all_tests() -> void:
	var original_save_bytes: PackedByteArray = []
	var f = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.READ)
	if f != null:
		original_save_bytes = f.get_buffer(f.get_length())
		f.close()
	
	await test_arena_hierarchy_and_initial_state()
	await test_trigger_activation_and_barriers()
	await test_player_death_opens_barriers_and_resets()
	await test_boss_victory_unseals_arena()
	await test_sector_10_scene_integration()
	await test_peaceful_revisit()
	
	if not original_save_bytes.is_empty():
		var fw = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.WRITE)
		if fw != null:
			fw.store_buffer(original_save_bytes)
			fw.close()
	
	print("\n==================================================")
	print("RESULTADO ARENA E SETOR 10: %d PASSOU, %d FALHOU" % [total_passed, total_failed])
	print("==================================================")
	
	if total_failed > 0:
		quit(1)
	else:
		quit(0)

func test_arena_hierarchy_and_initial_state() -> void:
	print("\n--- 1. Hierarquia e Estado Inicial da Arena ---")
	var arena: CervoBossArena = ARENA_SCENE.instantiate() as CervoBossArena
	root.add_child(arena)
	await _frames(2)
	
	check(arena != null, "CervoBossArena instanciada com sucesso")
	check(arena.boss != null, "CervoBoss presente na arena")
	check(arena.left_gate_col != null, "Barreira esquerda (LeftGate) presente")
	check(arena.right_gate_col != null, "Barreira direita (RightGate) presente")
	check(arena.trigger_area != null, "Área de ativação (TriggerArea) presente")
	check(arena.boss_hud != null, "HUD do chefe presente")
	check(arena.hud_bar != null, "Barra de vida CervoBossBar vinculada")
	
	# Inicialmente os portões estão abertos (disabled == true) antes da ativação
	check(arena.left_gate_col.disabled, "Barreira esquerda inicialmente aberta")
	check(arena.right_gate_col.disabled, "Barreira direita inicialmente aberta")
	check(not arena.active, "Encontro inicia inativo")
	
	arena.queue_free()
	await _frames(2)

func test_trigger_activation_and_barriers() -> void:
	print("\n--- 2. Ativação por Gatilho e Fechamento de Barreiras ---")
	var player: KnightController = _create_dummy_player()
	var arena: CervoBossArena = ARENA_SCENE.instantiate() as CervoBossArena
	root.add_child(arena)
	await _frames(2)
	
	arena.completed = false
	arena.set_hero(player)
	check(not arena.active, "Arena inativa com jogador fora do gatilho")
	
	# Jogador entra na área de gatilho
	arena.start_encounter()
	await _frames(2)
	
	check(arena.active, "Arena ativada com sucesso")
	check(not arena.left_gate_col.disabled, "Barreira esquerda trancada durante a luta")
	check(not arena.right_gate_col.disabled, "Barreira direita trancada durante a luta")
	check(arena.boss.state == CervoBoss.State.INTRO, "Chefe iniciou a sequência de introdução")
	check(arena.boss_hud.visible, "HUD do chefe exibido")
	
	arena.queue_free()
	player.queue_free()
	await _frames(2)

func test_player_death_opens_barriers_and_resets() -> void:
	print("\n--- 3. Morte do Jogador: Desarme e Abertura de Barreiras ---")
	var player: KnightController = _create_dummy_player()
	var arena: CervoBossArena = ARENA_SCENE.instantiate() as CervoBossArena
	root.add_child(arena)
	await _frames(2)
	
	arena.completed = false
	arena.set_hero(player)
	arena.start_encounter()
	await _frames(2)
	
	# Morte do jogador
	player.survival.receive_damage(99)
	await _frames(2)
	
	check(not arena.active, "Arena desativada na morte do jogador")
	check(arena.left_gate_col.disabled, "Barreira esquerda destrancada na morte")
	check(arena.right_gate_col.disabled, "Barreira direita destrancada na morte")
	check(not arena.boss_hud.visible, "HUD do chefe ocultado na morte")
	
	# Respawn
	arena.reset_encounter()
	check(arena.boss.health == 14, "Chefe resetado com 14 HP para nova tentativa")
	check(arena.boss.state == CervoBoss.State.DORMANT, "Chefe em DORMANT aguardando nova entrada")
	
	arena.queue_free()
	player.queue_free()
	await _frames(2)

func test_boss_victory_unseals_arena() -> void:
	print("\n--- 4. Vitória sobre o Chefe: Liberação e Salto Duplo ---")
	var player: KnightController = _create_dummy_player()
	var arena: CervoBossArena = ARENA_SCENE.instantiate() as CervoBossArena
	root.add_child(arena)
	await _frames(2)
	
	arena.completed = false
	arena.set_hero(player)
	arena.start_encounter()
	await _frames(2)
	
	# Derrota o chefe
	arena.boss._set_state(CervoBoss.State.PURSUIT, 0.0)
	for i in range(5): arena.boss.receive_hit()
	if arena.boss.state == CervoBoss.State.PHASE_TRANSITION: arena.boss._physics_process(1.0)
	for i in range(5): arena.boss.receive_hit()
	if arena.boss.state == CervoBoss.State.PHASE_TRANSITION: arena.boss._physics_process(1.0)
	for i in range(4): arena.boss.receive_hit()
	
	check(arena.completed, "Arena registra vitória sobre o chefe")
	check(arena.left_gate_col.disabled, "Barreira esquerda aberta permanentemente após vitória")
	check(arena.right_gate_col.disabled, "Barreira direita aberta permanentemente após vitória")
	
	# Conclusão cinemática
	arena.boss.conclusion._physics_process(3.7)
	check(player.spectral_jump_unlocked, "Salto Espectral ativo no jogador após a conclusão")
	check(ABBEY_PROGRESS.spectral_jump_unlocked(), "Progresso persistido com sucesso")
	
	arena.queue_free()
	player.queue_free()
	await _frames(2)

func test_sector_10_scene_integration() -> void:
	print("\n--- 5. Integração na Cena Oficial do Setor 10 ---")
	var player: KnightController = _create_dummy_player()
	var sector: ForestSector = SECTOR_10_SCENE.instantiate() as ForestSector
	root.add_child(sector)
	await _frames(2)
	
	check(sector != null, "Sector 10 instanciado")
	check(sector.sector_id == 9, "sector_id é 9 (Setor 10 da Floresta)")
	check(sector.arena != null, "Arena do chefe conectada no ForestSector")
	
	sector.set_hero(player)
	check(sector.arena.hero == player, "set_hero propaga herói para a arena do chefe")
	
	sector.disarm()
	check(not sector.arena.boss.attack_source.is_active, "disarm() propaga para o chefe")
	
	sector.queue_free()
	player.queue_free()
	await _frames(2)

func test_peaceful_revisit() -> void:
	print("\n--- 6. Revisita Pacífica ao Setor 10 ---")
	var player: KnightController = _create_dummy_player()
	var sector: ForestSector = SECTOR_10_SCENE.instantiate() as ForestSector
	root.add_child(sector)
	await _frames(2)
	
	sector.set_hero(player)
	
	# Com cervo_defeated ativo no save, a arena deve iniciar pacificada
	check(sector.arena.completed, "Revisita reconhece chefe já derrotado")
	check(sector.arena.left_gate_col.disabled, "Barreira esquerda aberta na revisita")
	check(sector.arena.right_gate_col.disabled, "Barreira direita aberta na revisita")
	check(not sector.arena.boss_hud.visible, "HUD oculto na revisita")
	check(sector.arena.boss.state == CervoBoss.State.DEFEATED, "Chefe em repouso pacificado (não hostil)")
	check(player.spectral_jump_unlocked, "Jogador possui Salto Espectral na revisita")
	
	sector.queue_free()
	player.queue_free()
	await _frames(2)
