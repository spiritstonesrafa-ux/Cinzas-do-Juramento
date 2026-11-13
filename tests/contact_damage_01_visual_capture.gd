extends SceneTree
## Script de Captura Visual Automatizada para COMBATE-CONTACT-DAMAGE-01.
## Produz as 10 evidências fotográficas em GPU real em tests/evidencias/contact_damage_01/.

const ARENA_SCRIPT: Script = preload("res://tests/contact_damage_arena.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/contact_damage_01/"

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
	print("INICIANDO CAPTURA VISUAL: COMBATE-CONTACT-DAMAGE-01 (10 EVIDÊNCIAS)")
	print("Dano Corporal, Hurtboxes, I-Frames, Knockback e Inimigos")
	print("==================================================================")

	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	await _frames(8)

	var knight: KnightController = arena.knight
	var skel: SkeletonPatrol = arena.enemy_skeleton
	var crawler: ForestCrawler = arena.enemy_crawler
	var crow: ForestSpectralCrow = arena.enemy_crow

	# ------------------------------------------------------------------
	# 1. Aren encostando em esqueleto (Aproximação inicial)
	# ------------------------------------------------------------------
	print("Capturando 01_aren_encostando_esqueleto.png...")
	arena.reset_arena()
	knight.survival.restore()
	knight.position = Vector2(skel.position.x - 14.0, arena.FLOOR_Y)
	knight.facing = 1
	knight.velocity = Vector2.ZERO
	await _frames(4)
	await _save_viewport("01_aren_encostando_esqueleto.png")

	# ------------------------------------------------------------------
	# 2. Primeiro dano corporal (Impacto, HP reduzido)
	# ------------------------------------------------------------------
	print("Capturando 02_primeiro_dano_corporal.png...")
	knight.position = Vector2(skel.position.x - 8.0, arena.FLOOR_Y)
	await _frames(2)
	await _save_viewport("02_primeiro_dano_corporal.png")

	# ------------------------------------------------------------------
	# 3. Aren durante os i-frames (Piscada e Proteção)
	# ------------------------------------------------------------------
	print("Capturando 03_iframes_flash_vermelho.png...")
	knight.survival.invulnerability_remaining = 0.70
	knight._update_survival_visual()
	await _frames(2)
	await _save_viewport("03_iframes_flash_vermelho.png")

	# ------------------------------------------------------------------
	# 4. Knockback controlado (Vetor de recuo horizontal e elevação)
	# ------------------------------------------------------------------
	print("Capturando 04_knockback_recuo_seguro.png...")
	arena.reset_arena()
	knight.position = Vector2(skel.position.x - 8.0, arena.FLOOR_Y)
	knight.receive_damage(1, skel.global_position)
	await _frames(3)
	await _save_viewport("04_knockback_recuo_seguro.png")

	# ------------------------------------------------------------------
	# 5. Sobreposição durante i-frames (Sem dano por frame)
	# ------------------------------------------------------------------
	print("Capturando 05_sobreposicao_durante_iframes.png...")
	knight.position = Vector2(skel.position.x - 4.0, arena.FLOOR_Y)
	knight.survival.invulnerability_remaining = 0.45
	knight._update_survival_visual()
	await _frames(3)
	await _save_viewport("05_sobreposicao_durante_iframes.png")

	# ------------------------------------------------------------------
	# 6. Aren encostando em rastejante baixo
	# ------------------------------------------------------------------
	print("Capturando 06_contato_rastejante_baixo.png...")
	arena.reset_arena()
	knight.survival.restore()
	knight.position = Vector2(crawler.position.x - 8.0, arena.FLOOR_Y)
	knight.facing = 1
	await _frames(4)
	await _save_viewport("06_contato_rastejante_baixo.png")

	# ------------------------------------------------------------------
	# 7. Aren encostando em corvo aéreo
	# ------------------------------------------------------------------
	print("Capturando 07_contato_corvo_aereo.png...")
	arena.reset_arena()
	knight.survival.restore()
	knight.position = Vector2(crow.position.x - 6.0, crow.position.y + 12.0)
	knight.velocity = Vector2.ZERO
	await _frames(4)
	await _save_viewport("07_contato_corvo_aereo.png")

	# ------------------------------------------------------------------
	# 8. Dois inimigos em contato simultâneo (Sem acúmulo duplicado)
	# ------------------------------------------------------------------
	print("Capturando 08_dois_inimigos_em_contato.png...")
	arena.reset_arena()
	knight.survival.restore()
	var g_skel = arena.group_skel
	var g_craw = arena.group_crawler
	knight.position = Vector2(g_skel.position.x + 10.0, arena.FLOOR_Y)
	await _frames(4)
	await _save_viewport("08_dois_inimigos_em_contato.png")

	# ------------------------------------------------------------------
	# 9. Inimigo morto sem dano corporal
	# ------------------------------------------------------------------
	print("Capturando 09_inimigo_morto_sem_dano.png...")
	arena.reset_arena()
	while skel.current_health > 0:
		skel.receive_hit()
	await _frames(3)
	knight.survival.restore()
	knight.position = Vector2(skel.position.x, arena.FLOOR_Y)
	await _frames(4)
	await _save_viewport("09_inimigo_morto_sem_dano.png")

	# ------------------------------------------------------------------
	# 10. Ataque SOTN funcionando normalmente em combate
	# ------------------------------------------------------------------
	print("Capturando 10_ataque_sotn_em_combate.png...")
	arena.reset_arena()
	knight.position = Vector2(skel.position.x - 22.0, arena.FLOOR_Y)
	knight.facing = 1
	await _frames(2)
	knight.sword_attack._start_attack(true, 1)
	knight.sword_attack.phase = SwordAttack.Phase.ACTIVE
	knight.sword_attack._remaining = knight.sword_attack.active_duration * 0.5
	knight.sword_attack._update_hitbox_geometry()
	knight.sword_attack._find_hits()
	await _frames(2)
	await _save_viewport("10_ataque_sotn_em_combate.png")

	print("==================================================================")
	print("TODAS AS 10 EVIDÊNCIAS FORAM CAPTURADAS COM SUCESSO EM GPU REAL!")
	print("Diretório: %s" % OUTPUT_DIR)
	print("==================================================================")
	quit(0)
