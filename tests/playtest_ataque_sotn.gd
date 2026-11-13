extends SceneTree
## Launcher oficial de playtest humano comparativo para ATAQUE-SOTN-01.
## Executa com isolamento obrigatório de save e instancia a Arena de Validação.
## Controles especiais: F6 (Alternar ORIGINAL <-> SOTN), F7 (Resetar Arena), ESC (Sair).

const ARENA_SCRIPT: Script = preload("res://tests/ataque_sotn_arena.gd")

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

	# 2. Instanciação da Arena de Treinamento e registro de current_scene
	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	print("==================================================================")
	print("CINZAS DO JURAMENTO — PLAYTEST COMPARATIVO: ATAQUE SOTN-01")
	print("==================================================================")
	print("Arena de Validação carregada com sucesso.")
	print("Modo inicial ativo: SOTN-PROTÓTIPO (snap 0.05s, ativo 0.05s, recovery 0.15s)")
	print("------------------------------------------------------------------")
	print("CONTROLES DE COMBATE:")
	print("  A / D        : Mover Aren para esquerda / direita")
	print("  Espaço       : Pular (ataque aéreo disponível com landing cancel)")
	print("  J            : Atacar com a espada (corte em meia-lua fluido)")
	print("  Shift        : Passo das Sombras (Dash)")
	print("------------------------------------------------------------------")
	print("CONTROLES DO HARNESS:")
	print("  F6           : Alternar em tempo real entre MODO SOTN e ORIGINAL")
	print("  F8           : Alternar visual SOTN (ART-FIX02 [Homologado] <-> ARM-FIX01 [Fallback])")
	print("  F9           : Alternar Feedback Audiovisual SOTN-03 (ON / OFF)")
	print("  F7           : Resetar posições do jogador, alvos e inimigos")
	print("  ESC          : Fechar sessão de playtest")
	print("------------------------------------------------------------------")
	print("ESTAÇÕES DE TESTE DISPONÍVEIS NA ARENA:")
	print("  1. Retaguarda (x=185)       : Prove que o corte frontal não atinge atrás")
	print("  2. Alvo Frontal (x=290)     : Teste de resposta e timing do corte")
	print("  3. Corte Duplo (x=380/396)  : Prove que um único golpe atinge 2 alvos")
	print("  4. Esqueleto (x=490)        : Teste contra inimigo humanoide móvel")
	print("  5. Crawler Rasteiro (x=610) : Prove que o corte baixo acerta sem agachar")
	print("  6. Corvo Voador (x=750)     : Prove que o arco alto corta inimigos aéreos")
	print("  7. Parede Sólida (x=980)    : Prove que a parede bloqueia o golpe")
	print("==================================================================")
