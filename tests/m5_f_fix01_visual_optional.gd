extends "res://tests/m5_e_lote08_o2_test.gd"
## Dynamic frames from the established O2 live-input route.
var seen: Dictionary={}
func tick() -> void:
 await super.tick()
 if not is_instance_valid(chapter) or not is_instance_valid(hero) or chapter.busy or chapter.current_room!=2: return
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(2)
 var phase: String=""
 if chapter.stair_annex and hero.velocity.x>1 and p.x<1280: phase="entrada"
 elif chapter.stair_annex and hero.velocity.x>1 and p.x>1320: phase="interior"
 elif chapter.stair_annex and hero.velocity.x< -1: phase="retorno"
 if phase.is_empty() or seen.has(phase): return
 seen[phase]=true
 var v: Vector2=hero.velocity
 var mode: Node.ProcessMode=chapter.process_mode
 chapter.process_mode=Node.PROCESS_MODE_DISABLED
 var dir: String=ProjectSettings.globalize_path("res://.godot/m5f-fix01-optional")
 DirAccess.make_dir_recursive_absolute(dir)
 for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
  root.mode=Window.MODE_WINDOWED;root.size=size
  for f: int in range(3): await process_frame
  await RenderingServer.frame_post_draw
  var image: Image=root.get_texture().get_image()
  var err: Error=image.save_png(dir+"/O2_%s_%dx%d.png" % [phase,size.x,size.y])
  print("OPTIONAL ",phase," size=",image.get_size()," p=",p," vel=",v," save=",err)
 chapter.process_mode=mode
