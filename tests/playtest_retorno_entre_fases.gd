extends SceneTree
## Launcher oficial de playtest humano — RETORNO-ENTRE-FASES-01
## Transições Físicas Bidirecionais: Cemitério ↔ Abadia ↔ Floresta
## Executa com isolamento obrigatório de save e suporta progressão contínua completa.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const ABBEY_SCENE: PackedScene = preload("res://scenes/abbey/abbey_chapter.tscn")
const FOREST_SCENE: PackedScene = preload("res://scenes/forest/forest_pilots.tscn")
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")

func _initialize() -> void:
	call_deferred("_start")

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

	# 2. Instanciação da Campanha Oficial
	var camp = MAIN_SCENE.instantiate()
	root.add_child(camp)
	current_scene = camp

	print("==================================================================")
	print("CINZAS DO JURAMENTO — PLAYTEST: RETORNO ENTRE FASES (M1)")
	print("Transições Físicas Bidirecionais: Cemitério ↔ Abadia ↔ Floresta")
	print("==================================================================")
	print("Campanha iniciada com sucesso na Fase 1 (Cemitério Esquecido).")
	print("Ataque SOTN ativo por padrão em todas as fases.")
	print("Dano por contato corporal (1 HP) ativo em todas as fases.")
	print("------------------------------------------------------------------")
	print("CONTROLES DE JOGO:")
	print("  A / D        : Mover Aren")
	print("  Espaço       : Pular (ataque aéreo disponível com landing cancel)")
	print("  J            : Atacar com a espada (Ataque SOTN fluido)")
	print("  Shift        : Passo das Sombras (Dash desbloqueado após Abade)")
	print("------------------------------------------------------------------")
	print("CONEXÕES BIDIRECIONAIS PARA TESTAR:")
	print("  [1] Cemitério -> Abadia   : Avance além de x=2340 após derrotar Guardião")
	print("  [2] Abadia -> Cemitério   : Retorne à esquerda no Setor 0 (Átrio dos Votos)")
	print("  [3] Abadia -> Floresta    : Avance à direita no Setor 11 após derrotar Abade")
	print("  [4] Floresta -> Abadia    : Retorne à esquerda no Setor 0 da Floresta")
	print("------------------------------------------------------------------")
	print("ATALHOS DE CONVENIÊNCIA (HARNESS DE TESTE):")
	print("  F6           : Teletransporte seguro para Abadia (com Guardião vencido)")
	print("  F8           : Teletransporte seguro para Floresta (com Abade vencido)")
	print("  F7           : Reiniciar fase atual")
	print("  ESC          : Sair do jogo")
	print("==================================================================")

func _process(_delta: float) -> bool:
	if Input.is_key_pressed(KEY_ESCAPE):
		quit(0)
		return true
	elif Input.is_physical_key_pressed(KEY_F6):
		if current_scene != null and not current_scene.name.begins_with("Abbey"):
			ABBEY_PROGRESS._grant_fields({"guardian_defeated": true, "health_upgrade_unlocked": true})
			ABBEY_PROGRESS.set_pending_entrance("")
			change_scene_to_file("res://scenes/abbey/abbey_chapter.tscn")
	elif Input.is_physical_key_pressed(KEY_F8):
		if current_scene != null and not current_scene.name.begins_with("Forest"):
			ABBEY_PROGRESS._grant_fields({"guardian_defeated": true, "health_upgrade_unlocked": true, "abbot_defeated": true, "dash_unlocked": true})
			ABBEY_PROGRESS.set_pending_entrance("")
			change_scene_to_file("res://scenes/forest/forest_pilots.tscn")
	return false
