extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var isolated := OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\", "/")
	var output := OS.get_environment("ENEMY_AI_01_VISUAL_OUTPUT")
	if isolated.is_empty() or not OS.get_user_data_dir().replace("\\", "/").begins_with(isolated + "/") or output.is_empty() or DisplayServer.get_name() == "headless":
		printerr("Perfil isolado, saída e renderizador gráfico são obrigatórios")
		quit(2)
		return
	root.size = Vector2i(1280, 720)
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	camera.position = Vector2(160, 90)
	world.add_child(camera)
	camera.make_current()
	var labels := ["Monge", "Acolito", "Penitente", "Vigia"]
	for kind in range(4):
		var path := "res://scenes/enemies/chained_monk.tscn" if kind == 0 else "res://scenes/enemies/abbey_experimental_enemy.tscn"
		var enemy: ChainedMonk = load(path).instantiate()
		if kind > 0: enemy.set("archetype", kind - 1)
		enemy.position = Vector2(55 + 70 * kind, 115)
		world.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.set_state(ChainedMonk.State.WARNING, 0.55)
		var label := Label.new()
		label.text = labels[kind]
		label.position = enemy.position + Vector2(-20, 12)
		label.add_theme_font_size_override("font_size", 8)
		world.add_child(label)
	for frame in range(5): await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var error := image.save_png(output)
	print("abbey warning capture=", output, " size=", image.get_size(), " result=", error)
	world.queue_free()
	quit(0 if error == OK else 1)
