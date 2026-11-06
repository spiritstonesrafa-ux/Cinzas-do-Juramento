extends SceneTree

func _initialize() -> void:
 run.call_deferred()

func run() -> void:
 var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
 root.add_child(stage)
 await physics_frame
 var errors := 0
 var enemies := stage.get_node("Enemies").get_children()
 print("CEMETERY count=", enemies.size())
 if enemies.size() != 12: errors += 1
 for enemy: Node2D in enemies:
  print("CEMETERY ", enemy.name, " ", enemy.position, " ", enemy.get_class())
  var box := RectangleShape2D.new()
  box.size = Vector2(10, 8)
  var query := PhysicsShapeQueryParameters2D.new()
  query.shape = box
  query.transform = Transform2D(0, enemy.global_position + Vector2(0, -6) if enemy is SkeletonPatrol else enemy.global_position)
  query.collision_mask = 1
  var inside := not enemy.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()
  if inside:
   print("FAIL world overlap: ", enemy.name)
   errors += 1
 var script := load("res://scripts/abbey/m5c3_distribution.gd")
 var total := 0
 for id in range(12):
  for record in script.PLACEMENTS[id]:
   if record[0] not in ["monk", "acolyte", "penitent", "watchman"]: continue
   total += 1
   var surface: Rect2 = AbbeyChapterLayout.main_surfaces(id)[record[2]]
   print("ABBEY sector=", id+1, " kind=",record[0]," position=",Vector2(record[1],surface.position.y))
   if not (record[1] > surface.position.x and record[1] < surface.end.x):
    print("FAIL invalid support")
    errors += 1
 print("ABBEY count=", total)
 if total != 20: errors += 1
 print("M5-H inventory failures: ",errors)
 stage.queue_free()
 await process_frame
 quit(1 if errors else 0)
