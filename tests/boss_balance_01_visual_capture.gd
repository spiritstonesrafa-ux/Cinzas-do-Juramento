extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var isolate=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolate.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolate+"/"): quit(2); return
 var progress=load("res://scripts/abbey/abbey_progress.gd")
 progress.grant_guardian_reward()
 var chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter); current_scene=chapter
 while chapter.busy: await process_frame
 await chapter.switch_room(11)
 await chapter._enter_abbot_arena()
 chapter.room.boss._start_judgment()
 for i in range(560):
  await physics_frame
  if i in [25,76,112,460,525] or (chapter.room.boss.judgment_index==1 and is_instance_valid(chapter.room.boss.judgment_hazards[0]) and chapter.room.boss.judgment_hazards[0].age>0.75 and chapter.room.boss.judgment_hazards[0].age<0.78):
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png("res://tests/boss_visual_refine_%03d.png"%i)
 quit()
