extends SceneTree
## Launcher oficial de playtest humano comparativo para COMBATE-CONTACT-DAMAGE-01.
## Executa com isolamento obrigatório de save e instancia a Arena de Validação de Dano por Contato.
## Controles especiais: F10 (Alternar Contato ON <-> OFF), F6 (Modo Espada), F8 (Visual), F9 (Feedback), F7 (Reset), ESC (Sair).

const ARENA_SCRIPT: Script = preload("res://tests/contact_damage_arena.gd")

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

	# 2. Instanciação da Arena de Dano por Contato
	var arena = ARENA_SCRIPT.new()
	root.add_child(arena)
	current_scene = arena

	print("==================================================================")
	print("CINZAS DO JURAMENTO — PLAYTEST COMPARATIVO: COMBATE-CONTACT-DAMAGE-01")
	print("==================================================================")
	print("Arena de Validação de Dano por Contato carregada com sucesso.")
	print("Modo inicial ativo: DANO POR CONTATO ATIVO (ON)")
	print("Ataque SOTN congelado: ART-FIX02 com Hitstop e Áudios Oficiais")
	print("------------------------------------------------------------------")
	print("CONTROLES DE COMBATE:")
	print("  A / D        : Mover Aren para esquerda / direita")
	print("  Espaço       : Pular (ataque aéreo disponível com landing cancel)")
	print("  J            : Atacar com a espada (corte SOTN fluido 0.25s)")
	print("  Shift        : Passo das Sombras (Dash)")
	print("------------------------------------------------------------------")
	print("CONTROLES DO HARNESS DE TESTES:")
	print("  F10 (ou F5)  : ALTERNAR DANO POR CONTATO (ATIVO [ON] <-> INATIVO [OFF])")
	print("  F6           : Alternar modo de espada (SOTN <-> ORIGINAL)")
	print("  F8           : Alternar visual SOTN (ART-FIX02 <-> ARM-FIX01)")
	print("  F9           : Alternar feedback audiovisual SOTN-03 (ON <-> OFF)")
	print("  F7           : Resetar arena (restaura HP, posição e inimigos)")
	print("  ESC          : Fechar sessão de playtest")
	print("------------------------------------------------------------------")
	print("ESTAÇÕES DE TESTE DISPONÍVEIS NA ARENA:")
	print("  1. Esqueleto (x=320)         : Caminhe contra ele para verificar o dano corporal inicial")
	print("  2. Rastejante (x=510)        : Pule por cima; toque o corpo baixo para verificar colisão")
	print("  3. Corvo em Voo (x=670)      : Verifique colisão aérea no tronco de Aren")
	print("  4. Sentinela (x=920)         : Teste contato frontal e traseiro com inimigo blindado")
	print("  5. Grupo Agrupado (x=1130)   : Teste passagem com dash e ausência de dano duplicado")
	print("==================================================================")
