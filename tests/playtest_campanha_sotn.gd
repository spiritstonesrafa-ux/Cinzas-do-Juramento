extends SceneTree
## Launcher oficial de playtest humano da Campanha Completa com Ataque SOTN Integrado.
## Executa com isolamento obrigatório de save e instancia a cena principal da campanha (Cemitério -> Abadia -> Floresta).

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

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
	print("CINZAS DO JURAMENTO — CAMPANHA OFICIAL (SOTN INTEGRADO)")
	print("==================================================================")
	print("Campanha iniciada com sucesso na Fase 1 (Cemitério Esquecido).")
	print("Ataque SOTN ativo por padrão (0.05s / 0.05s / 0.15s - ciclo 0.25s).")
	print("Visual ART-FIX02 ativo por padrão com manto e espada articulada.")
	print("Feedback sensorial SOTN-03 ativo (Whoosh e impactos em WAV).")
	print("Dano por contato corporal ativo (1 HP + i-frames 0.8s + knockback 110 px/s).")
	print("------------------------------------------------------------------")
	print("CONTROLES DE JOGO:")
	print("  A / D        : Mover Aren")
	print("  Espaço       : Pular (ataque aéreo disponível com landing cancel)")
	print("  J            : Atacar com a espada (Ataque SOTN fluído)")
	print("  Shift        : Passo das Sombras (Dash desbloqueado após Abade)")
	print("------------------------------------------------------------------")
	print("ROTEIRO DA JORNADA:")
	print("  1. Cemitério Esquecido : Enfrente esqueletos e corvos; derrote o Guardião")
	print("  2. Recompensa Guardião : Receba +1 HP Máximo (6 HP) e entre no portal")
	print("  3. Abadia Silenciosa   : Supere 12 setores e derrote o Abade das Correntes")
	print("  4. Recompensa Abade    : Desbloqueie o Passo das Sombras (Dash)")
	print("  5. Floresta dos Ossos  : Atravesse os 10 setores e confronte o Cervo")
	print("==================================================================")
