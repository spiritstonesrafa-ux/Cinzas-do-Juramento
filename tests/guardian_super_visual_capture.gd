extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var isolate=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolate.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolate+"/"):quit(2);return
 var world=Node2D.new();root.add_child(world)
 var hero=load("res://scenes/player/knight.tscn").instantiate();world.add_child(hero);hero.position=Vector2(35,156)
 var arena=load("res://scenes/boss/guardian_arena.tscn").instantiate();world.add_child(arena);arena.get_node("ArenaCamera").enabled=true
 var boss=arena.get_node("Guardian");boss.begin(hero);boss.position=Vector2(160,156);boss.phase=2;boss._start_super()
 for i in range(250):
  await physics_frame
  if i in [40,82,95,145,165,235]:
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://tests/guardian_super_visual_%03d.png"%i)
 quit()
