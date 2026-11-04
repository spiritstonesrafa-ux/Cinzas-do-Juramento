extends "res://tests/abbey_chapter_test.gd"
## Direction across all links; only the two reported internal seams are visual fixes.
var pairs: Array=[]
var captures: int=0
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b-fix01")
 DirAccess.make_dir_recursive_absolute(output)
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo);await wait_room();hero=demo.hero
 check(DisplayServer.get_name()!="headless","Graphical continuity audit")
 for link: int in range(11):
  await demo.switch_room(link);isolate_threats()
  hero.reset_to(AbbeyChapterLayout.origin(link)+AbbeyChapterLayout.exit_point(link)-Vector2(24,0))
  hero.facing=1;await frames(5)
  Input.action_press("move_right")
  for i: int in range(90):
   await frames()
   if demo.busy or demo.current_room!=link: break
  await wait_room();isolate_threats()
  var entry_x: float=hero.global_position.x-AbbeyChapterLayout.origin(link+1).x
  await frames(24);release()
  check(demo.current_room==link+1,"Holding RIGHT advances without accidental return "+str(link+1))
  check(entry_x<96 and hero.global_position.x-AbbeyChapterLayout.origin(link+1).x>entry_x,"Enter LEFT and continue RIGHT "+str(link+1))
  check(hero.facing==1,"East facing retained "+str(link+1))
  hero.reset_to(AbbeyChapterLayout.origin(link+1)+AbbeyChapterLayout.exit_point(link+1,true)+Vector2(24,0))
  hero.facing=-1;await frames(5)
  Input.action_press("move_left")
  for i: int in range(90):
   await frames()
   if demo.busy or demo.current_room==link: break
  await wait_room();isolate_threats()
  entry_x=hero.global_position.x-AbbeyChapterLayout.origin(link).x
  await frames(24);release()
  check(demo.current_room==link,"Holding LEFT returns without bouncing "+str(link+1))
  check(entry_x>AbbeyChapterLayout.WIDTHS[link]-96 and hero.global_position.x-AbbeyChapterLayout.origin(link).x<entry_x,"Enter RIGHT and continue LEFT "+str(link+1))
  check(hero.facing==-1,"West facing retained on return "+str(link+1))
  pairs.append({"from":link+1,"to":link+2,"same_input_forward_and_reverse":true})
 for id: int in range(12):
  await demo.switch_room(id)
  check(demo.room.art.owns_backdrop()==(id not in [1,5]),"Backdrop ownership unchanged except the two integration seams S"+str(id+1))
  if id in [1,5]:
   check(demo.room.pilot.get_node("Art").get_script().resource_path=="res://scripts/abbey/pilot_art.gd","Original pilot renderer remains sole background owner")
 for id: int in [1,5]:
  await demo.switch_room(id);isolate_threats()
  var y: float=228 if id==1 else 300
  for x: float in [920.0,1000.0]:
   hero.reset_to(AbbeyChapterLayout.origin(id)+Vector2(x,y))
   await frames(ceili(demo.camera.position.distance_to(demo.camera_target())/10.0)+8)
   for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
    root.mode=Window.MODE_WINDOWED;root.size=size
    await frames(5);await RenderingServer.frame_post_draw
    var img: Image=root.get_texture().get_image()
    check(img.get_size()==size,"Native seam capture S%d x%d %d" % [id+1,int(x),size.x])
    check(img.save_png(output+"/seam_S%02d_x%d_%d.png" % [id+1,int(x),size.x])==OK,"Saved targeted seam evidence")
    captures+=1
  # Pixel oracle: above terrain/actors, the frame around X960 must be exactly
  # the original pilot background, whether the connector skin is visible or not.
  await RenderingServer.frame_post_draw
  var normal: Image=root.get_texture().get_image()
  var camera_local: Vector2=demo.camera.get_screen_center_position()-AbbeyChapterLayout.origin(id)
  var seam_x: int=roundi((960-(camera_local.x-160))*12)
  var region: Rect2i=Rect2i(seam_x-16*12,55*12,32*12,20*12)
  demo.room.art.hide();await frames(2);await RenderingServer.frame_post_draw
  var pilot_only: Image=root.get_texture().get_image()
  check(normal.get_region(region).get_data()==pilot_only.get_region(region).get_data(),"Exact pilot-only background pixels across X960 S"+str(id+1))
  demo.room.art.show()
  hero.reset_to(AbbeyChapterLayout.origin(id)+Vector2(932,y));await frames(5)
  Input.action_press("move_right");await frames(42);release()
  check(demo.current_room==id and hero.global_position.x-AbbeyChapterLayout.origin(id).x>980 and hero.is_on_floor(),"Actual same-sector crossing of seam x960 S"+str(id+1))
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/main.tscn","F5 original campaign preserved")
 FileAccess.open(output+"/links.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"pairs":pairs,"targeted_sectors":[2,6],"seam_x":960,"captures":captures,"scope":"physical direction and native seam evidence; no human artistic approval inferred"},"  "))
 print("Continuity checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
