extends "res://tests/abbey_chapter_test.gd"
## Sample a fixed world point in masonry while the real hero jumps and camera follows.
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b-ceiling")
 DirAccess.make_dir_recursive_absolute(output)
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(1280,720)
 check(DisplayServer.get_name()!="headless","Real graphical renderer")
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo);await wait_room();hero=demo.hero
 for id: int in [3,4,8]:
  await demo.switch_room(id)
  var rect: Rect2=AbbeyChapterLayout.ceilings(id)[1]
  var floor_y: float=rect.position.y+92
  var x: float=rect.get_center().x
  hero.reset_to(AbbeyChapterLayout.origin(id)+Vector2(x,floor_y))
  await frames(50)
  var anchor: Vector2=AbbeyChapterLayout.origin(id)+Vector2(x+12,rect.end.y-24)
  var colors: Array[Color]=[]
  var centers: Array[Vector2]=[]
  Input.action_press("jump");await frames();Input.action_release("jump")
  for i: int in range(48):
   await frames();await RenderingServer.frame_post_draw
   var center: Vector2=demo.camera.get_screen_center_position()
   var screen: Vector2=(anchor-center+Vector2(160,90))*4
   var img: Image=root.get_texture().get_image()
   if screen.x>=0 and screen.y>=0 and screen.x<img.get_width() and screen.y<img.get_height():
    colors.append(img.get_pixelv(Vector2i(screen)))
    centers.append(center)
  var stable: bool=colors.size()>5
  var max_delta: float=0
  for color: Color in colors:
   max_delta=maxf(max_delta,maxf(absf(color.r-colors[0].r),maxf(absf(color.g-colors[0].g),absf(color.b-colors[0].b))))
  stable=stable and max_delta<=2.0/255.0
  print("Maximum channel difference S",id+1,": ",max_delta)
  check(centers.size()>5 and centers[0].distance_to(centers[centers.size()/2])>1,"Camera moved during real jump S"+str(id+1))
  check(stable,"Fixed masonry point retains pixels during jump S"+str(id+1))
 print("Ceiling movement checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
