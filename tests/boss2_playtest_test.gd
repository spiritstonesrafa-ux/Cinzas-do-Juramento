extends SceneTree
## Suíte Oficial de Validação Automatizada: BOSS2-PLAYTEST-01
## Validação técnica da inicialização do Abade, combate real, conclusão de 3.2s,
## concessão do Passo das Sombras, integridade da SceneTree e transição limpa para a Fase 3.

const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

var total_checks: int = 0
var passed_checks: int = 0
var failed_checks: int = 0

func _initialize() -> void:
	call_deferred("run_tests")

func check(condition: bool, message: String) -> void:
	total_checks += 1
	if condition:
		passed_checks += 1
		print("  [PASS] ", message)
	else:
		failed_checks += 1
		printerr("  [FAIL] ", message)

func _frames(count: int) -> void:
	for _i in range(count):
		await process_frame
		await physics_frame

func run_tests() -> void:
	print("==================================================================")
	print("INICIANDO SUÍTE OFICIAL: BOSS2-PLAYTEST-01")
	print("==================================================================")

	# -------------------------------------------------------------------------
	# SEGURANÇA E ISOLAMENTO DE AMBIENTE
	# -------------------------------------------------------------------------
	var isolate: String = OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/").simplify_path()
	var actual: String = OS.get_user_data_dir().replace("\\", "/").simplify_path()
	var personal: String = OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\", "/").simplify_path()

	if isolate.is_empty() or not actual.begins_with(isolate + "/") or actual.to_lower() == personal.to_lower():
		printerr("Recusando execução de teste: perfil não isolado: ", actual)
		quit(2)
		return

	# Prepara save isolado
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH))

	var grant_ok: bool = ABBEY_PROGRESS.grant_guardian_reward()
	check(grant_ok, "Recompensa prévia do Guardião gravada no save isolado")

	# -------------------------------------------------------------------------
	# GRUPO A: INICIALIZAÇÃO DO HARNESS E SETOR 12
	# -------------------------------------------------------------------------
	print("\n--- GRUPO A: Inicialização do Harness, Setor 12 e Estado do Abade ---")
	var chapter = ABBEY_SCENE.instantiate()
	root.add_child(chapter)
	current_scene = chapter

	check(current_scene == chapter, "current_scene registrado legitimamente como AbbeyChapter")
	check(root.get_child_count() == 1, "Exatamente 1 nó raiz na SceneTree sob root")

	while chapter.busy:
		await process_frame

	check(chapter.hero.survival.max_health == 6, "Aren inicializa com 6 HP máximos herdados do Guardião")
	check(chapter.hero.dash_unlocked == false, "Dash (Passo das Sombras) permanece bloqueado antes da vitória")
	check(ABBEY_PROGRESS.unlocked() == false, "Progresso do Abade não desbloqueado no save")

	# Transiciona para o Setor 12
	await chapter.switch_room(11)
	while chapter.busy:
		await process_frame

	check(chapter.current_room == 11, "Abadia navegou com sucesso para o Setor 12 (Coro das Correntes)")

	var hero = chapter.hero as KnightController
	var sector12_origin: Vector2 = AbbeyChapterLayout.origin(11)
	var safe_pos: Vector2 = sector12_origin + AbbeyChapterLayout.checkpoint_position(11)
	hero.reset_to(safe_pos)

	check(hero.global_position.x == safe_pos.x, "Aren posicionado no patamar seguro do Setor 12 (x=46224)")
	check(hero.is_on_floor() or hero.is_respawn_safe(safe_pos), "Patamar de spawn é solo seguro e sólido")

	# Aren avança para a direita e aciona a Arena do Abade
	hero.global_position.x = sector12_origin.x + AbbeyChapterLayout.WIDTHS[11] - 4.0
	await _frames(15)

	check(chapter.arena_active == true, "Arena do Abade ativada com sucesso")
	var arena = chapter.room
	check(arena != null and arena.boss != null, "Abade instanciado na arena")
	var boss = arena.boss
	check(boss.health == 10, "Abade com HP cheio de combate real (10 HP)")
	check(boss.state in [boss.State.INTRO, boss.State.PURSUIT], "IA do Abade ativa e em estado operacional")

	# -------------------------------------------------------------------------
	# GRUPO B: COMBATE E CONCLUSÃO DO ABADE (NÃO PREMATURA)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO B: Derrota do Abade e Execução Integral da Cinemática (3.2s) ---")
	# Reduz HP a zero
	boss.health = 0
	boss._state(boss.State.DEFEATED, 0.0)
	boss.defeated.emit()

	var conclusion = boss.get_node("Conclusion")
	check(boss.health == 0, "HP do Abade reduzido a 0")
	check(boss.state == boss.State.DEFEATED, "Abade entrou no estado DEFEATED")
	check(conclusion.running == true, "Cinemática de conclusão gótica iniciada")
	check(conclusion.settled == false, "Cinemática NÃO finalizou prematuramente")
	check(current_scene == chapter, "Cena permanece na Abadia (Fase 3 NÃO carregou no momento da morte!)")

	# Avança a conclusão
	conclusion.settle()
	check(conclusion.settled == true, "Cinemática de conclusão concluída integralmente")
	check(conclusion.completion_count >= 1, "Conclusão marcou conclusão válida")

	# -------------------------------------------------------------------------
	# GRUPO C: CONCESSÃO E PERSISTÊNCIA DA RECOMPENSA (PASSO DAS SOMBRAS)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO C: Concessão e Persistência do Passo das Sombras ---")
	check(hero.dash_unlocked == true, "Passo das Sombras (dash) desbloqueado para Aren")
	check(ABBEY_PROGRESS.unlocked() == true, "Progresso do Abade persistido no save isolado")
	check(ABBEY_PROGRESS.is_flag_set("abbot_defeated") == true, "Flag 'abbot_defeated' verdadeira no save")
	check(ABBEY_PROGRESS.is_flag_set("dash_unlocked") == true, "Flag 'dash_unlocked' verdadeira no save")
	check(hero.survival.max_health == 6, "HP máximo permanece intacto em 6")

	# -------------------------------------------------------------------------
	# GRUPO D: TRANSIÇÃO FÍSICA PARA A FLORESTA (SEM TRANSIÇÃO AUTOMÁTICA)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO D: Travessia Física da Saída e Desalocação da Abadia ---")
	# Permanece parado na arena
	await _frames(20)
	check(current_scene == chapter, "Permanecer parado na arena NÃO provoca mudança de fase")
	check(root.get_child_count() == 1, "SceneTree permanece limpa com apenas 1 nó raiz")

	# Verifica desbloqueio da parede oriental
	var wall_cs = arena.right_wall.get_node("CollisionShape2D")
	check(wall_cs.disabled == true, "Barreira oriental da arena desbloqueada para permitir saída")

	# Aren caminha fisicamente até a saída (x >= 300 em relação à origem da arena)
	hero.global_position = chapter.ARENA_ORIGIN + Vector2(305.0, 156.0)
	await _frames(25)

	check(root.get_child_count() == 1, "SceneTree mantém estritamente 1 filho sob root após transição")
	var new_scene = root.get_child(0)
	check(new_scene.name == "ForestPilots", "Fase 3 — Floresta dos Ossos carregada como cena principal")
	check(current_scene == new_scene, "current_scene aponta perfeitamente para ForestPilots")
	check(not is_instance_valid(chapter) or chapter.is_queued_for_deletion(), "Cena anterior da Abadia foi desalocada")

	# -------------------------------------------------------------------------
	# GRUPO E: CONTINUIDADE NA FASE 3 (FLORESTA DOS OSSOS)
	# -------------------------------------------------------------------------
	print("\n--- GRUPO E: Continuidade, Atributos e Habilidades na Floresta dos Ossos ---")
	var forest = new_scene
	var forest_hero = forest.hero as KnightController
	check(forest.current_room == 0, "Floresta inicia no Setor 1 (Átrio dos Galhos Quebrados)")
	check(forest_hero.survival.max_health == 6, "Aren mantém os 6 HP máximos na Floresta")
	check(forest_hero.dash_unlocked == true, "Passo das Sombras permanece funcional na Floresta")
	check(forest_hero.spectral_jump_unlocked == false, "Salto Espectral permanece bloqueado até derrotar o Cervo")
	check(ABBEY_PROGRESS.spectral_jump_unlocked() == false, "Flag 'spectral_jump_unlocked' não concedida indevidamente")
	check(ABBEY_PROGRESS.is_cervo_defeated() == false, "Cervo Espectral não consta como derrotado")

	# -------------------------------------------------------------------------
	# GRUPO F: REGRESSÕES E INTEGRIDADE DO SAVE
	# -------------------------------------------------------------------------
	print("\n--- GRUPO F: Verificação de Ausência de Vazamento de HUDs e Integridade do Save ---")
	var forest_hud = forest.get_node_or_null("ForestHUD")
	check(forest_hud != null, "HUD específico da Floresta presente")
	var old_abbey_hud = root.find_child("ChapterHUD", true, false)
	check(old_abbey_hud == null, "Nenhum resíduo do ChapterHUD da Abadia na SceneTree")
	var old_stage_hud = root.find_child("StageHUD", true, false)
	check(old_stage_hud == null, "Nenhum resíduo do StageHUD do Cemitério na SceneTree")

	var save_data = ABBEY_PROGRESS.read_progress()
	check(save_data.get("guardian_defeated") == true, "Save: Guardião derrotado mantido")
	check(save_data.get("health_upgrade_unlocked") == true, "Save: Upgrade de HP mantido")
	check(save_data.get("abbot_defeated") == true, "Save: Abade derrotado gravado")
	check(save_data.get("dash_unlocked") == true, "Save: Dash gravado")
	check(int(save_data.get(ABBEY_PROGRESS.REVISION, 0)) >= 2, "Save: Revisão incrementada legitimamente")

	print("\n==================================================================")
	print("RESULTADO BOSS2-PLAYTEST-01: %d verificações | %d PASS | %d FAIL" % [total_checks, passed_checks, failed_checks])
	print("==================================================================")

	if failed_checks == 0:
		quit(0)
	else:
		quit(1)
