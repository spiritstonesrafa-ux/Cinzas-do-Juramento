extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 root.size=Vector2i(1280,720)
 var chapter: Node=load("res://scenes/dev/m5g_boss_playtest.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or not chapter.arena_active:
  await physics_frame;await process_frame
 var boss: Node=chapter.room.boss
 var folder: String=ProjectSettings.globalize_path("res://.godot/m5g-fix05-evidencias")
 DirAccess.make_dir_recursive_absolute(folder)
 for side: int in [-1,1]:
  for pattern: int in [0,1,2]:
   boss.position=Vector2(160,156)
   boss.facing=side;boss.pattern=pattern;boss._state(boss.State.WARNING,30)
   await physics_frame;await process_frame
   chapter.process_mode=Node.PROCESS_MODE_DISABLED
   boss.visual.queue_redraw()
   for i: int in range(3): await process_frame
   await RenderingServer.frame_post_draw
   var err: Error=root.get_texture().get_image().save_png(folder+"/aviso_p%d_lado%d.png" % [pattern,side])
   if err!=OK:quit(1);return
   chapter.process_mode=Node.PROCESS_MODE_INHERIT
 print("M5G FIX05: seis capturas de avisos em direções opostas")
 quit(0)
