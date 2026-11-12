extends SceneTree

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var camera := Camera2D.new()
	world.add_child(camera)
	camera.make_current()
	var floor_body := StaticBody2D.new()
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(4000, 20)
	collision.shape = shape
	collision.position = Vector2(0, 10)
	floor_body.add_child(collision)
	world.add_child(floor_body)
	var hero: KnightController = load("res://scenes/player/knight.tscn").instantiate()
	world.add_child(hero)
	hero.set_physics_process(false)
	await physics_frame
	var edge: float = camera.get_screen_center_position().x + root.get_visible_rect().size.x / camera.zoom.x * 0.5
	hero.global_position = Vector2(edge - 14.0, 0)
	var enemies: Array = []
	for path in ["res://scenes/enemies/skeleton_patrol.tscn", "res://scenes/enemies/forest_crawler.tscn", "res://scenes/enemies/forest_sentinel.tscn"]:
		var enemy: CharacterBody2D = load(path).instantiate()
		enemy.position = Vector2(edge + 5.0, 0)
		enemy.patrol_left = 0.0
		enemy.patrol_right = 0.0
		world.add_child(enemy)
		enemy.target = hero
		enemies.append(enemy)
	var attacked := [false, false, false]
	for frame in range(90):
		await physics_frame
		for i in range(enemies.size()):
			if enemies[i].state == enemies[i].State.ATTACK: attacked[i] = true
	var failed := false
	for i in range(enemies.size()):
		var visible: bool = enemies[i]._visible_for_attack()
		print("GROUND_OFFSCREEN ", enemies[i].name, " visible=", visible, " attacked=", attacked[i])
		if visible or attacked[i]: failed = true
	camera.position = Vector2(edge, 0)
	camera.force_update_scroll()
	for frame in range(90):
		await physics_frame
		for i in range(enemies.size()):
			if enemies[i].state == enemies[i].State.ATTACK: attacked[i] = true
	for i in range(enemies.size()):
		print("GROUND_VISIBLE ", enemies[i].name, " attacked=", attacked[i])
		if not attacked[i]: failed = true
	world.queue_free()
	quit(1 if failed else 0)
