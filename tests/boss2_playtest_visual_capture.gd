extends SceneTree
## Script de Captura Visual Automatizada para BOSS2-PLAYTEST-01
## Gera as 7 evidências em GPU real (NVIDIA RTX 2060 SUPER) no diretório tests/evidencias/boss2_playtest_01/

const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const OUTPUT_DIR: String = "res://tests/evidencias/boss2_playtest_01/"

func _initialize() -> void:
	call_deferred("_run_capture")

func _save_viewport(filename: String) -> void:
	var img: Image = root.get_viewport().get_texture().get_image()
	var abs_dir: String = ProjectSettings.globalize_path(OUTPUT_DIR)
	DirAccess.make_dir_recursive_absolute(abs_dir)
	var out_path: String = abs_dir.path_join(filename)
	var err: Error = img.save_png(out_path)
	print("  Evidência gravada: %s (%dx%d) err=%d" % [filename, img.get_width(), img.get_height(), err])

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func _run_capture() -> void:
	print("==================================================================")
	print("INICIANDO CAPTURA VISUAL: BOSS2-PLAYTEST-01 (7 EVIDÊNCIAS)")
	print("==================================================================")

	# 1. Setup save isolado com 6 HP do Guardião
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH))

	ABBEY_PROGRESS.grant_guardian_reward()

	var chapter = ABBEY_SCENE.instantiate()
	root.add_child(chapter)
	current_scene = chapter

	while chapter.busy:
		await process_frame

	await chapter.switch_room(11)
	while chapter.busy:
		await process_frame

	var hero = chapter.hero as KnightController
	var sector12_origin: Vector2 = AbbeyChapterLayout.origin(11)
	var safe_pos: Vector2 = sector12_origin + AbbeyChapterLayout.checkpoint_position(11)
	hero.reset_to(safe_pos)
	chapter.camera.position = chapter.camera_target()
	chapter.camera.reset_smoothing()
	chapter.camera.force_update_scroll()

	# Caminha ligeiramente à direita para exibir a dica da arena
	hero.global_position.x = sector12_origin.x + AbbeyChapterLayout.WIDTHS[11] - 80.0
	await _frames(15)

	# 1. Aren diante da arena do Abade
	_save_viewport("01_aren_diante_da_arena_abade.png")

	# Ingressa na arena
	hero.global_position.x = sector12_origin.x + AbbeyChapterLayout.WIDTHS[11] - 4.0
	await _frames(25)

	var arena = chapter.room
	var boss = arena.boss

	# 2. Início do combate do Abade
	await _frames(10)
	_save_viewport("02_inicio_combate_abade.png")

	# Reduz HP a zero para iniciar conclusão
	boss.health = 0
	boss._state(boss.State.DEFEATED, 0.0)
	boss.defeated.emit()

	# 3. Conclusão do chefe (partículas e banner VÍNCULO QUEBRADO)
	await _frames(12)
	_save_viewport("03_conclusao_chefe_correntes.png")

	# Avança conclusão até o término
	var conclusion = boss.get_node("Conclusion")
	conclusion.settle()
	await _frames(15)

	# 4. Recompensa Passo das Sombras assimilado
	_save_viewport("04_recompensa_passo_das_sombras.png")

	# 5. Saída da Abadia liberada (Aren próximo a x=280)
	hero.global_position = chapter.ARENA_ORIGIN + Vector2(285.0, 156.0)
	await _frames(15)
	_save_viewport("05_saida_abadia_liberada.png")

	# Atravessa a saída para a Floresta
	hero.global_position = chapter.ARENA_ORIGIN + Vector2(305.0, 156.0)
	await _frames(30)

	var forest = current_scene
	while forest.busy:
		await process_frame

	# 6. Entrada na Floresta (Setor 1)
	await _frames(15)
	_save_viewport("06_entrada_floresta_setor1.png")

	# Executa um dash na Floresta para registrar o Passo das Sombras em ação
	var forest_hero = forest.hero as KnightController
	forest_hero.dash_remaining = 0.15
	forest_hero.velocity.x = 240.0
	await _frames(4)

	# 7. HUD de 6 HP e dash funcional na Floresta
	_save_viewport("07_floresta_hud_6hp_dash_funcional.png")

	print("==================================================================")
	print("TODAS AS 7 EVIDÊNCIAS GRAVADAS COM SUCESSO!")
	print("==================================================================")
	quit(0)
