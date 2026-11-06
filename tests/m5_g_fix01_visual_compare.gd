extends SceneTree
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 await chapter.switch_room(11)
 chapter.hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy:break
 Input.action_release("move_right")
 if not chapter.arena_active:print("FAIL arena");quit(1);return
 var arena: Node=chapter.room
 var boss: Node=arena.boss
 var acolyte: Node=load("res://scenes/enemies/abbey_experimental_enemy.tscn").instantiate()
 acolyte.archetype=0;acolyte.position=Vector2(100,156);arena.add_child(acolyte)
 acolyte.process_mode=Node.PROCESS_MODE_DISABLED
 boss.position=Vector2(230,156);boss.facing=-1
 chapter.hero.reset_to(chapter.ARENA_ORIGIN+Vector2(35,156))
 await tick(10)
 var output: String=ProjectSettings.globalize_path("res://.godot/m5g-fix01-comparacao")
 DirAccess.make_dir_recursive_absolute(output)
 for mode: String in ["comparacao_fase1","comparacao_fase2","flash_dano","dash_ativo","derrota"]:
  boss.flash=0.0
  boss.phase=1 if mode=="comparacao_fase1" else 2
  boss.pattern=boss.Pattern.CHAIN if boss.phase==1 else boss.Pattern.DASH
  if mode=="flash_dano":
   boss._state(boss.State.RECOVER,5.0);boss.flash=5.0
  elif mode=="dash_ativo": boss._state(boss.State.ACTIVE,5.0)
  elif mode=="derrota": boss._state(boss.State.DEFEATED,0.0)
  else: boss._state(boss.State.WARNING,5.0)
  boss.visual.queue_redraw();acolyte.visual.queue_redraw()
  await tick(2)
  chapter.process_mode=Node.PROCESS_MODE_DISABLED
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   root.mode=Window.MODE_WINDOWED;root.size=size
   for f: int in range(3): await process_frame
   await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   var err: Error=img.save_png(output+"/"+mode+"_%dx%d.png" % [size.x,size.y])
   print("COMPARE ",mode," ",img.get_size()," save=",err)
  chapter.process_mode=Node.PROCESS_MODE_INHERIT
 chapter.queue_free();await tick(120);quit(0)
