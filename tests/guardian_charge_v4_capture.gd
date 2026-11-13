extends SceneTree
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var isolate=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolate.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolate+"/"):quit(2);return
 var world=Node2D.new();root.add_child(world)
 var hero=load("res://scenes/player/knight.tscn").instantiate();world.add_child(hero);hero.position=Vector2(60,156)
 var arena=load("res://scenes/boss/guardian_arena.tscn").instantiate();world.add_child(arena);arena.get_node("ArenaCamera").enabled=true
 var boss=arena.get_node("Guardian");boss.begin(hero);boss.start_pattern(boss.Pattern.CHARGE)
 for i in range(90):
  await physics_frame
  if i in [3,12,35,50,60,70]:
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://tests/guardian_charge_v4_%02d.png"%i)
 quit()
