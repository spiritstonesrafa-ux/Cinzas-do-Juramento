extends SceneTree
## Launcher de playtest humano direto diante do Guardião do Juramento.
## Executa com isolamento de save e posiciona Aren em x=2300 diante do Selo da Catedral.

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")

func _initialize() -> void:
	call_deferred("_start")

func _start() -> void:
	var main = MAIN_SCENE.instantiate()
	root.add_child(main)
	current_scene = main
	for _i in range(3):
		await process_frame
		await physics_frame
	var cemetery = main.get_node("ForgottenCemetery")
	var knight = cemetery.get_node("Knight") as KnightController
	knight.reset_to(Vector2(2300.0, 156.0))
	print("==================================================================")
	print("PLAYTEST DIRETO DO GUARDIÃO DO JURAMENTO INICIADO")
	print("Aren posicionado diante do Selo da Catedral (x=2300).")
	print("Caminhe para a direita para iniciar o confronto com o Guardião.")
	print("==================================================================")
