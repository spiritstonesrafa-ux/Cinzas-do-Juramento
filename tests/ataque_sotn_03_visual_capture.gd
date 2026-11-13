extends SceneTree
## Script de Captura Visual Automatizada para ATAQUE-SOTN-03.
## Produz as 10 evidências fotográficas em GPU real em tests/evidencias/ataque_sotn_03/.

const ARENA_SCRIPT: Script = preload("res://tests/ataque_sotn_arena.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/ataque_sotn_03/"

func _initialize() -> void:
	call_deferred("_run_capture")

func _save_viewport(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var img: Image = root.get_viewport().get_texture().get_image()
	var abs_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var out_path: String = abs_dir.path_join(filename)
	var err: Error = img.save_png(out_path)
	print("  [EVIDÊNCIA GRAVADA] %s (%dx%d) err=%d" % [filename, img.get_width(), img.get_height(), err])

func _frames(count: int) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func _run_capture() -> void:
	print("==================================================================")
	print("INICIANDO CAPTURA VISUAL: ATAQUE-SOTN-03 (10 EVIDÊNCIAS)")
	print("Impacto, Hitstop Localizado, Flash, Faíscas e Áudio")
	print("==================================================================")

	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	await _frames(8)

	var knight: KnightController = arena.knight
	var attack: SwordAttack = knight.sword_attack

	# Garante modo SOTN e feedback ativado
	attack.mode = SwordAttack.Mode.SOTN
	attack.sotn_feedback_enabled = true

	# ------------------------------------------------------------------
	# 1. Corte no ar (Whiff) — Somente Rastro e Whoosh
	# ------------------------------------------------------------------
	print("Capturando 01_corte_no_ar_whiff.png...")
	knight.reset_to(Vector2(240.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(3)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("01_corte_no_ar_whiff.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 2. Impacto em Esqueleto (Humanoide Móvel)
	# ------------------------------------------------------------------
	print("Capturando 02_impacto_esqueleto.png...")
	knight.reset_to(Vector2(468.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("02_impacto_esqueleto.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 3. Impacto em Crawler Rasteiro (Corte Baixo)
	# ------------------------------------------------------------------
	print("Capturando 03_impacto_rastejante_baixo.png...")
	knight.reset_to(Vector2(588.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.2
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("03_impacto_rastejante_baixo.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 4. Impacto em Corvo Voador (Arco Alto)
	# ------------------------------------------------------------------
	print("Capturando 04_impacto_corvo_alto.png...")
	knight.reset_to(Vector2(730.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.8
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("04_impacto_corvo_alto.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 5. Impacto em Alvo Frontal (Contato Padrão / Flash)
	# ------------------------------------------------------------------
	print("Capturando 05_impacto_alvo_frontal.png...")
	knight.reset_to(Vector2(268.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("05_impacto_alvo_frontal.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 6. Golpe Aéreo com Impacto no Ar
	# ------------------------------------------------------------------
	print("Capturando 06_golpe_aereo_impacto.png...")
	knight.reset_to(Vector2(728.0, 115.0))
	knight.velocity = Vector2(50.0, 10.0)
	knight.facing = 1
	await _frames(4)
	attack._start_attack(false, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.6
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("06_golpe_aereo_impacto.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 7. Comparativo: Feedback OFF (F9 Desativado)
	# ------------------------------------------------------------------
	print("Capturando 07_comparativo_feedback_off.png...")
	knight.reset_to(Vector2(268.0, arena.FLOOR_Y))
	knight.facing = 1
	attack.sotn_feedback_enabled = false
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("07_comparativo_feedback_off.png")
	attack.cancel()
	attack.sotn_feedback_enabled = true
	await _frames(4)

	# ------------------------------------------------------------------
	# 8. Comparativo: Feedback ON (F9 Ativado - SOTN-03 Completo)
	# ------------------------------------------------------------------
	print("Capturando 08_comparativo_feedback_on.png...")
	knight.reset_to(Vector2(268.0, arena.FLOOR_Y))
	knight.facing = 1
	attack.sotn_feedback_enabled = true
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("08_comparativo_feedback_on.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 9. Corte Duplo — Dois Alvos Atingidos em Simultâneo
	# ------------------------------------------------------------------
	print("Capturando 09_corte_duplo_multiplos_alvos.png...")
	knight.reset_to(Vector2(366.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.ACTIVE
	attack._remaining = attack.active_duration * 0.5
	attack._update_hitbox_geometry()
	attack._find_hits()
	await _frames(2)
	await _save_viewport("09_corte_duplo_multiplos_alvos.png")
	attack.cancel()
	await _frames(4)

	# ------------------------------------------------------------------
	# 10. Recuperação Pós-Impacto (Follow-Through ART-FIX02 Preservado)
	# ------------------------------------------------------------------
	print("Capturando 10_recuperacao_pos_impacto.png...")
	knight.reset_to(Vector2(268.0, arena.FLOOR_Y))
	knight.facing = 1
	await _frames(4)
	attack._start_attack(true, 1)
	attack.phase = SwordAttack.Phase.RECOVERY
	attack._remaining = attack.recovery_duration * 0.4
	attack._update_hitbox_geometry()
	await _frames(2)
	await _save_viewport("10_recuperacao_pos_impacto.png")
	attack.cancel()
	await _frames(4)

	print("==================================================================")
	print("CAPTURA VISUAL CONCLUÍDA: 10/10 EVIDÊNCIAS SALVAS COM SUCESSO!")
	print("==================================================================")
	quit(0)
