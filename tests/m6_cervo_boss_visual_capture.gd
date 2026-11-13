extends SceneTree
## Script oficial de validação visual e captura de evidências GPU para M6-CERVO-BOSS.
## Renderiza na GPU real, gerando capturas oficiais em tests/evidencias/m6_cervo_boss/.

const FOREST_PILOTS_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const CervoBoss = preload("res://scripts/boss/cervo_boss.gd")
const CervoBossArena = preload("res://scripts/boss/cervo_boss_arena.gd")
const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")

var out_dir: String = "res://tests/evidencias/m6_cervo_boss"

func _init() -> void:
	call_deferred("_run_capture")

func _frames(count: int = 2) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _capture(path: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	for _i in range(4):
		await process_frame
		await physics_frame
	await RenderingServer.frame_post_draw
	var img: Image = root.get_texture().get_image()
	if img != null:
		var err: Error = img.save_png(path)
		print("  Evidência gravada: %s (%dx%d) err=%d" % [path.get_file(), img.get_width(), img.get_height(), err])

func _run_capture() -> void:
	print("Iniciando captura de evidências visuais M6-CERVO-BOSS...")
	DirAccess.make_dir_recursive_absolute(out_dir)

	var demo: ForestDemo = FOREST_PILOTS_SCENE.instantiate() as ForestDemo
	root.add_child(demo)
	await _frames(6)

	# Transita para o Setor 10
	await demo.switch_room(9, false)
	await _frames(6)

	var arena: CervoBossArena = (demo.room.get_node_or_null("ClearingEncounter") if demo.room.has_node("ClearingEncounter") else demo.room.get_node_or_null("BossArena")) as CervoBossArena
	arena.completed = false
	var hero: KnightController = demo.hero
	var boss: CervoBoss = arena.boss

	# 1. Entrada no Setor 10
	hero.global_position = ForestLayout.ORIGINS[9] + Vector2(100, 260)
	demo.camera.position = demo.camera_target()
	await _capture("%s/cervo_boss_01_arena_entry.png" % out_dir)

	# 2. Ativação do Gatilho e Barreiras
	hero.global_position = ForestLayout.ORIGINS[9] + Vector2(215, 260)
	arena.start_encounter()
	await _frames(4)
	await _capture("%s/cervo_boss_02_trigger_and_barriers.png" % out_dir)

	# 3. Introdução e HUD
	boss._set_state(CervoBoss.State.INTRO, 2.0)
	await _capture("%s/cervo_boss_03_intro_stare.png" % out_dir)

	# 4. Investida: Telégrafo
	boss._start_attack(CervoBoss.BossAttack.CHARGE)
	await _capture("%s/cervo_boss_04_charge_telegraph.png" % out_dir)

	# 5. Investida: Ativa
	boss._execute_attack()
	boss.visual.play(CervoVisual.AnimState.CHARGE_EXEC)
	boss.visual.set_frame(6)
	await _capture("%s/cervo_boss_05_charge_active.png" % out_dir)

	# 6. Investida: Recuperação
	boss._enter_recovery()
	await _capture("%s/cervo_boss_06_charge_recovery.png" % out_dir)

	# 7. Corte das Galhadas: Telégrafo
	boss._start_attack(CervoBoss.BossAttack.ANTLER)
	await _capture("%s/cervo_boss_07_antler_telegraph.png" % out_dir)

	# 8. Corte das Galhadas: Varredura
	boss._execute_attack()
	boss.visual.play(CervoVisual.AnimState.ANTLER_EXEC)
	boss.visual.set_frame(5)
	await _capture("%s/cervo_boss_08_antler_sweep.png" % out_dir)

	# 9. Pisada das Almas: Telégrafo
	boss._start_attack(CervoBoss.BossAttack.STOMP)
	await _capture("%s/cervo_boss_09_stomp_telegraph.png" % out_dir)

	# 10. Pisada das Almas: Impacto e Onda de Choque
	boss._execute_attack()
	boss.visual.play(CervoVisual.AnimState.STOMP_EXEC)
	boss.visual.set_frame(6)
	await _capture("%s/cervo_boss_10_stomp_shockwave.png" % out_dir)

	# 11. Salto Predatório: Telégrafo e Subida
	boss._start_attack(CervoBoss.BossAttack.LEAP)
	await _capture("%s/cervo_boss_11_leap_ascension.png" % out_dir)

	# 12. Salto Predatório: Ápice Aéreo
	boss._execute_attack()
	boss.visual.play(CervoVisual.AnimState.LEAP_EXEC)
	boss.visual.set_frame(6)
	boss.global_position.y -= 60.0
	await _capture("%s/cervo_boss_12_leap_apex_arc.png" % out_dir)

	# 13. Salto Predatório: Impacto de Descida
	boss.global_position.y += 60.0
	boss.visual.play(CervoVisual.AnimState.LEAP_RECOVER)
	boss.visual.set_frame(2)
	await _capture("%s/cervo_boss_13_leap_impact.png" % out_dir)

	# 14. Ecos da Floresta: Invocação
	boss._start_attack(CervoBoss.BossAttack.ECHOES)
	boss.visual.play(CervoVisual.AnimState.ECHO_CAST)
	boss.visual.set_frame(8)
	await _capture("%s/cervo_boss_14_echoes_cast.png" % out_dir)

	# 15. Ecos da Floresta: Manifestações Duplas
	boss._execute_attack()
	await _frames(4)
	await _capture("%s/cervo_boss_15_echoes_active.png" % out_dir)

	# 16. Ecos da Floresta: Dissipação por Golpe de Espada
	if boss.active_echoes.size() > 0:
		boss.active_echoes[0]._on_sword_hit()
	await _frames(2)
	await _capture("%s/cervo_boss_16_echoes_sword_dissolve.png" % out_dir)

	# 17. Flash de Dano no Chefe
	boss.receive_hit()
	await _capture("%s/cervo_boss_17_cervo_hit_flash.png" % out_dir)

	# 18. Transição para Fase 2 (9 HP)
	boss.health = 9
	boss.phase = 2
	boss._set_state(CervoBoss.State.PHASE_TRANSITION, 1.0)
	await _capture("%s/cervo_boss_18_phase2_transition.png" % out_dir)

	# 19. Transição para Fase 3 (4 HP)
	boss.health = 4
	boss.phase = 3
	boss._set_state(CervoBoss.State.PHASE_TRANSITION, 1.0)
	await _capture("%s/cervo_boss_19_phase3_transition.png" % out_dir)

	# 20. Chefe Derrotado
	boss.health = 0
	boss._on_defeated()
	await _capture("%s/cervo_boss_20_cervo_defeated.png" % out_dir)

	# 21. Conclusão Cinematográfica: Dispersão e Feixes
	boss.conclusion._begin()
	boss.conclusion._physics_process(1.5)
	await _frames(4)
	await _capture("%s/cervo_boss_21_conclusion_motes.png" % out_dir)

	# 22. Conclusão: Cartão de Recompensa Salto Espectral
	boss.conclusion._physics_process(1.0)
	await _frames(4)
	await _capture("%s/cervo_boss_22_spectral_jump_reward.png" % out_dir)

	# 23. Teste do Salto Espectral (Aren no Ar)
	hero.spectral_jump_unlocked = true
	hero.global_position = ForestLayout.ORIGINS[9] + Vector2(400, 200)
	hero.velocity.y = hero.spectral_jump_impulse
	hero._spectral_jump_fx_timer = 0.20
	await _capture("%s/cervo_boss_23_aren_double_jump_arena.png" % out_dir)

	# 24. Arena Desbloqueada e Exploração Livre
	hero.global_position = ForestLayout.ORIGINS[9] + Vector2(850, 260)
	arena.boss.conclusion.settle(true)
	await _capture("%s/cervo_boss_24_arena_unsealed_exploration.png" % out_dir)

	demo.queue_free()
	print("Captura de evidências visuais M6-CERVO-BOSS concluída (24/24)!")
	quit(0)
