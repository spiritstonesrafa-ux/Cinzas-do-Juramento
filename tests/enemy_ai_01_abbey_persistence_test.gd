extends SceneTree

func make_sector(world: Node2D, id: int) -> Node2D:
	var sector := Node2D.new()
	sector.set_script(load("res://scripts/abbey/chapter_sector.gd"))
	sector.set("sector_id", id)
	sector.position = AbbeyChapterLayout.origin(id)
	world.add_child(sector)
	sector.install_encounters(null)
	return sector

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	var world := Node2D.new()
	root.add_child(world)
	var snapshots: Array = []
	for id in range(12):
		var sector = make_sector(world, id)
		var enemy: ChainedMonk = sector.encounters.enemies[0]
		while enemy.current_health > 0: enemy.receive_hit()
		snapshots.append(sector.snapshot())
		sector.queue_free()
	await physics_frame
	await physics_frame
	var restored: Array = []
	for id in range(12):
		var sector = make_sector(world, id)
		sector.restore_state(snapshots[id])
		restored.append(sector.encounters.enemies[0])
	await physics_frame
	await physics_frame
	var starts: Array = []
	for enemy in restored: starts.append(enemy.global_position)
	for frame in range(60): await physics_frame
	var failed := false
	for i in range(restored.size()):
		var enemy: ChainedMonk = restored[i]
		var safe: bool = enemy.state == ChainedMonk.State.DEAD and enemy.current_health == 0 and enemy.global_position == starts[i] and enemy.receiver.get_node("CollisionShape2D").disabled and not enemy.source.active
		print("abbey restored dead sector=", i + 1, " safe=", safe)
		if not safe: failed = true
	world.queue_free()
	quit(1 if failed else 0)
