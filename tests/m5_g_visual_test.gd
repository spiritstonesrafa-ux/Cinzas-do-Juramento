extends "res://tests/m5_g_abbot_test.gd"
var frames_captured: Dictionary={}
func tick(n: int=1) -> void:
 for j: int in range(n):
  await physics_frame
  await process_frame
  if not is_instance_valid(chapter) or not chapter.arena_active or chapter.busy or not is_instance_valid(chapter.room): continue
  var b: Node=chapter.room.boss
  var label: String=""
  if chapter.abbot_won: label="recompensa"
  elif b.phase==2 and b.pattern==b.Pattern.DASH and b.state==b.State.ACTIVE: label="dash_abade"
  elif b.phase==2 and b.state==b.State.TRANSITION: label="transicao"
  elif b.phase==1 and b.state==b.State.WARNING: label="aviso"
  elif b.phase==1 and b.state==b.State.INTRO: label="arena"
  if label.is_empty() or frames_captured.has(label): continue
  frames_captured[label]=true
  var old_mode: Node.ProcessMode=chapter.process_mode
  chapter.process_mode=Node.PROCESS_MODE_DISABLED
  var dir: String=ProjectSettings.globalize_path("res://.godot/m5g-evidencias")
  DirAccess.make_dir_recursive_absolute(dir)
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   root.mode=Window.MODE_WINDOWED;root.size=size
   for k: int in range(3): await process_frame
   await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   var err: Error=img.save_png(dir+"/%s_%dx%d.png" % [label,size.x,size.y])
   print("M5G CAPTURE ",label," ",img.get_size()," save=",err)
  chapter.process_mode=old_mode
