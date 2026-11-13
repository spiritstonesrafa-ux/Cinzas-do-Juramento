extends SceneTree
## Launcher de playtest humano direto diante da Arena do Abade das Correntes (Setor 12).
## Executa com isolamento de save obrigatório, atribui current_scene e posiciona Aren seguro no Setor 12.

const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	call_deferred("_start")

func _setup_isolated_save() -> void:
	# Limpa fixtures prévias apenas no perfil de teste isolado
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with("cinzas_abbey_progress_v1.json"):
			DirAccess.remove_absolute(ProjectSettings.globalize_path("user://" + name))
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH)):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(ABBEY_PROGRESS.LOCK_PATH))

	# Concede legitimamente o progresso prévio da campanha (Guardião derrotado, 6 HP)
	var ok: bool = ABBEY_PROGRESS.grant_guardian_reward()
	if not ok:
		push_warning("Falha ao registrar recompensa do Guardião no perfil isolado.")

func _start() -> void:
	# 1. Verificação estrita de isolamento de save
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

	# 2. Inicialização do save isolado com Guardião derrotado e Abade vivo
	_setup_isolated_save()

	# 3. Instanciação da Abadia e registro estrito de current_scene
	var chapter = ABBEY_SCENE.instantiate()
	root.add_child(chapter)
	current_scene = chapter

	# 4. Aguarda prontidão da cena inicial da Abadia
	while chapter.busy:
		await process_frame

	# 5. Transiciona internamente para o Setor 12 (Coro das Correntes)
	await chapter.switch_room(11)
	while chapter.busy:
		await process_frame

	# 6. Posiciona Aren no patamar seguro do Setor 12 (checkpoint dos últimos 240px)
	var hero = chapter.hero as KnightController
	var sector12_origin: Vector2 = AbbeyChapterLayout.origin(11)
	var safe_pos: Vector2 = sector12_origin + AbbeyChapterLayout.checkpoint_position(11)
	hero.reset_to(safe_pos)
	chapter.camera.position = chapter.camera_target()
	chapter.camera.reset_smoothing()
	chapter.camera.force_update_scroll()

	print("==================================================================")
	print("CINZAS DO JURAMENTO — PLAYTEST DIRETO: ABADE DAS CORRENTES")
	print("Setor 12 (Coro das Correntes) carregado com sucesso.")
	print("Aren posicionado no patamar seguro antes da Arena.")
	print("Vida máxima: %d HP | Dash: %s" % [hero.survival.max_health, "Desbloqueado" if hero.dash_unlocked else "Bloqueado"])
	print("------------------------------------------------------------------")
	print("INSTRUÇÕES:")
	print("1. Caminhe para a direita para ver o aviso 'À direita: arena do Abade'.")
	print("2. Continue avançando para ingressar na Arena do Abade das Correntes.")
	print("3. Combata normalmente (A/D mover, Espaço saltar, J atacar).")
	print("4. Derrote o Abade e assista à cinematográfica de conclusão (3.2s).")
	print("5. Teste o Passo das Sombras desbloqueado (tecla Shift).")
	print("6. Avance à direita para atravessar a saída para a Floresta dos Ossos.")
	print("==================================================================")
