extends "res://tests/m5_c3_journey_test.gd"
## Real forward/reverse journey; captures sampled frames at recorded velocities.
var captured: Dictionary={}
var output_dir: String=""
func tick() -> void:
 await physics_frame
 await process_frame
 if not is_instance_valid(chapter) or not is_instance_valid(hero) or chapter.busy or chapter.current_room<0: return
 var id: int=chapter.current_room
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
 var width: float=AbbeyChapterLayout.WIDTHS[id]
 var phase: String=""
 if hero.velocity.x>10:
  if p.x>=width*0.15 and p.x<width*0.35: phase="aproxima"
  elif p.x>=width*0.45 and p.x<width*0.65: phase="meio"
  elif p.x>=width*0.78 and p.x<width*0.95: phase="saida"
 if (phase.is_empty() or captured.has("%02d_%s" % [id+1,phase])) and id in [1,2,7,9,10] and p.x>width*0.18 and p.x<width*0.88:
  if hero.velocity.y < -25: phase="salto"
  elif hero.velocity.y > 25: phase="queda"
 if phase.is_empty(): return
 var key: String="%02d_%s" % [id+1,phase]
 if captured.has(key): return
 captured[key]=true
 var vel: Vector2=hero.velocity
 var grounded: bool=hero.is_on_floor()
 var prev_mode: Node.ProcessMode=chapter.process_mode
 chapter.process_mode=Node.PROCESS_MODE_DISABLED
 if output_dir.is_empty():
  output_dir=ProjectSettings.globalize_path("res://.godot/m5f-fix01-dynamic")
  DirAccess.make_dir_recursive_absolute(output_dir)
 for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
  root.mode=Window.MODE_WINDOWED
  root.size=size
  for f: int in range(3): await process_frame
  await RenderingServer.frame_post_draw
  var img: Image=root.get_texture().get_image()
  var path: String=output_dir+"/S%02d_%s_%dx%d.png" % [id+1,phase,size.x,size.y]
  var err: Error=img.save_png(path)
  print("CAPTURE S",id+1," ",phase," ",size," actual=",img.get_size()," p=",p," velocity=",vel," grounded=",grounded," save=",err)
 chapter.process_mode=prev_mode
