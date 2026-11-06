extends "res://tests/m5_e_lote09_segment_journey.gd"
## Capture a sequence while actually walking the unlocked A3 passage.
var fix_seen: Dictionary={}
func tick() -> void:
 await super.tick()
 if not is_instance_valid(chapter) or not is_instance_valid(hero) or chapter.busy or chapter.passage_index!=2: return
 var p: Vector2=hero.global_position-chapter.passage_origin
 var phase: String=""
 if hero.velocity.x>1 and p.x>=100 and p.x<220: phase="entrada"
 elif hero.velocity.x>1 and p.x>=450 and p.x<570: phase="meio"
 elif hero.velocity.x>1 and p.x>=800 and p.x<940: phase="saida"
 if phase.is_empty() or fix_seen.has(phase): return
 fix_seen[phase]=true
 var v: Vector2=hero.velocity
 var mode: Node.ProcessMode=chapter.process_mode
 chapter.process_mode=Node.PROCESS_MODE_DISABLED
 var dir: String=ProjectSettings.globalize_path("res://.godot/m5f-fix01-shortcut")
 DirAccess.make_dir_recursive_absolute(dir)
 for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
  root.mode=Window.MODE_WINDOWED;root.size=size
  for f: int in range(3): await process_frame
  await RenderingServer.frame_post_draw
  var img: Image=root.get_texture().get_image()
  var err: Error=img.save_png(dir+"/A3_%s_%dx%d.png" % [phase,size.x,size.y])
  print("SHORTCUT ",phase," size=",img.get_size()," p=",p," vel=",v," save=",err)
 chapter.process_mode=mode
