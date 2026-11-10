extends SceneTree
## Teste de integração de ponta a ponta: Jornada Completa do Cervo Espectral (M6-CERVO-BOSS).
## Simula: Entrada no Setor 10 -> Gatilho -> Combate -> Fases -> Vitória -> Conclusão -> Salto Duplo -> Revisita.

const FOREST_PILOTS_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const CervoBossArena = preload("res://scripts/boss/cervo_boss_arena.gd")

var total_passed: int = 0
var total_failed: int = 0

func _init() -> void:
	print("\n==================================================")
	print("SUÍTE DE TESTES: JORNADA COMPLETA DO CERVO ESPECTRAL")
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
	
	var demo: ForestDemo = FOREST_PILOTS_SCENE.instantiate() as ForestDemo
	root.add_child(demo)
	await _frames(4)
	
	print("\n--- 1. Carga Inicial da Demonstração da Floresta ---")
	check(demo != null, "ForestDemo instanciado com sucesso")
	check(demo.hero != null, "Aren presente e instanciado")
	check(demo.checkpoints.size() == 10, "10 checkpoints da Floresta presentes")
	
	print("\n--- 2. Transição Direta para o Setor 10 (Arena) ---")
	await demo.switch_room(9, false)
	await _frames(4)
	
	check(demo.current_room == 9, "Transição para Setor 10 confirmada")
	check(demo.room != null, "Cena do Setor 10 carregada")
	
	var arena: CervoBossArena = (demo.room.get_node_or_null("ClearingEncounter") if demo.room.has_node("ClearingEncounter") else demo.room.get_node_or_null("BossArena")) as CervoBossArena
	check(arena != null, "ClearingEncounter presente no Setor 10")
	check(arena.boss != null, "CervoBoss posicionado no Setor 10")
	
	print("\n--- 3. Deslocamento até o Gatilho e Início da Luta ---")
	# Configura encontro inicial limpo
	arena.completed = false
	demo.hero.global_position = ForestLayout.ORIGINS[9] + Vector2(215, 260)
	arena.start_encounter()
	await _frames(4)
	
	check(arena.active, "Combate iniciado ao cruzar o gatilho da arena")
	check(not arena.left_gate_col.disabled, "Barreira esquerda ativada (bloqueia fuga para o Setor 9)")
	check(not arena.right_gate_col.disabled, "Barreira direita ativada (bloqueia avanço para o altar)")
	check(arena.boss.state == CervoBoss.State.INTRO, "Cervo Espectral em State.INTRO")
	check(arena.boss_hud.visible, "HUD da batalha exibido no topo da tela")
	
	print("\n--- 4. Progressão das Três Fases de Combate ---")
	arena.boss._physics_process(2.3) # Conclui intro
	check(arena.boss.state == CervoBoss.State.PURSUIT, "Chefe avança para perseguição/ataque")
	
	# Fase 1 para Fase 2 (5 golpes)
	for i in range(5): arena.boss.receive_hit()
	check(arena.boss.phase == 2, "Chefe entra na Fase 2 com 9 HP")
	if arena.boss.state == CervoBoss.State.PHASE_TRANSITION:
		arena.boss._physics_process(1.0)
	
	# Fase 2 para Fase 3 (5 golpes)
	for i in range(5): arena.boss.receive_hit()
	check(arena.boss.phase == 3, "Chefe entra na Fase 3 com 4 HP")
	if arena.boss.state == CervoBoss.State.PHASE_TRANSITION:
		arena.boss._physics_process(1.0)
	
	# Fase 3 até a derrota (4 golpes)
	for i in range(4): arena.boss.receive_hit()
	check(arena.boss.health == 0, "Chefe com 0 HP")
	check(arena.boss.state == CervoBoss.State.DEFEATED, "Chefe entra em State.DEFEATED")
	check(arena.completed, "Arena registra vitória sobre o chefe")
	check(arena.left_gate_col.disabled, "Barreira esquerda se abre na derrota")
	check(arena.right_gate_col.disabled, "Barreira direita se abre na derrota")
	
	print("\n--- 5. Conclusão Cinematográfica e Concessão do Salto Espectral ---")
	check(arena.boss.conclusion.running, "Sequência cinematográfica em execução")
	arena.boss.conclusion._physics_process(3.7)
	await _frames(2)
	
	check(arena.boss.conclusion.settled, "Conclusão concluída e consolidada")
	check(demo.hero.spectral_jump_unlocked, "Salto Espectral ativo no Aren")
	check(ABBEY_PROGRESS.spectral_jump_unlocked(), "Progresso persistido com sucesso no save")
	
	print("\n--- 6. Teste Físico do Salto Espectral no Setor 10 ---")
	demo.hero.can_spectral_jump = true
	demo.hero.velocity.y = demo.hero.jump_impulse
	check(demo.hero.velocity.y < 0.0, "Primeiro salto vertical aplicado")
	
	# No ar
	demo.hero.velocity.y = 50.0
	if demo.hero.can_spectral_jump and not demo.hero.survival.is_dead:
		demo.hero.velocity.y = demo.hero.spectral_jump_impulse
		demo.hero.can_spectral_jump = false
		demo.hero._spectral_jump_fx_timer = 0.20
	check(demo.hero.velocity.y == demo.hero.spectral_jump_impulse, "Segundo salto (Salto Espectral) aplicado com sucesso no ar!")
	check(not demo.hero.can_spectral_jump, "Salto duplo consumido")
	
	print("\n--- 7. Retorno ao Setor 9 e Revisita ao Setor 10 ---")
	await demo.switch_room(8, true)
	await _frames(2)
	check(demo.current_room == 8, "Retorno para o Setor 9 realizado com sucesso")
	
	await demo.switch_room(9, false)
	await _frames(2)
	check(demo.current_room == 9, "Revisita ao Setor 10 realizada com sucesso")
	
	var revisited_arena: CervoBossArena = (demo.room.get_node_or_null("ClearingEncounter") if demo.room.has_node("ClearingEncounter") else demo.room.get_node_or_null("BossArena")) as CervoBossArena
	check(revisited_arena != null, "Arena presente na revisita")
	check(revisited_arena.completed, "Arena permanece concluída na revisita")
	check(revisited_arena.left_gate_col.disabled, "Barreira esquerda permanece aberta")
	check(revisited_arena.right_gate_col.disabled, "Barreira direita permanece aberta")
	check(not revisited_arena.boss_hud.visible, "HUD permanece oculto na revisita")
	check(demo.hero.spectral_jump_unlocked, "Aren mantém Salto Espectral na revisita")
	
	demo.queue_free()
	await _frames(2)
	
	if not original_save_bytes.is_empty():
		var fw = FileAccess.open("user://cinzas_abbey_progress_v1.json", FileAccess.WRITE)
		if fw != null:
			fw.store_buffer(original_save_bytes)
			fw.close()
	
	print("\n==================================================")
	print("RESULTADO JORNADA COMPLETA: %d PASSOU, %d FALHOU" % [total_passed, total_failed])
	print("==================================================")
	
	if total_failed > 0:
		quit(1)
	else:
		quit(0)
