extends "res://tests/abbey_chapter_test.gd"
var captures: int=0
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b-visual")
 DirAccess.make_dir_recursive_absolute(output)
 check(DisplayServer.get_name()!="headless","Real graphics backend")
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo);await wait_room();hero=demo.hero
 var selected: Array=range(12) if OS.get_environment("CINZAS_M5B_FIXTURE_ONLY")!="1" else []
 for id: int in selected:
  if demo.current_room!=id: await demo.switch_room(id)
  isolate_threats()
  var route: Array[Rect2]=AbbeyChapterLayout.main_surfaces(id)
  var rect: Rect2=route[int(route.size()/2.0)]
  var p: Vector2=rect.position+Vector2(rect.size.x/2,0)
  if id==1: p=Vector2(420,228)
  if id==5: p=Vector2(535,300)
  hero.reset_to(AbbeyChapterLayout.origin(id)+p)
  await frames(50)
  check(demo.room.art.background!=null,"Original backdrop resolves S"+str(id+1))
  check(demo.room.art.texture_filter==CanvasItem.TEXTURE_FILTER_LINEAR,"Backdrop filter S"+str(id+1))
  check(root.canvas_item_default_texture_filter==Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,"Actors/HUD Nearest S"+str(id+1))
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   root.mode=Window.MODE_WINDOWED;root.size=size
   await frames(5);await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   check(img.get_size()==size,"Native image dimensions S%d %d" % [id+1,size.x])
   check(root.get_visible_rect().size==Vector2(320,180),"Logical FOV S%d %d" % [id+1,size.x])
   var path: String=output+"/sector_%02d_%d.png" % [id+1,size.x]
   check(img.save_png(path)==OK,"Saved native evidence "+path.get_file())
   captures+=1
 root.mode=Window.MODE_WINDOWED;root.size=Vector2i(3840,2160)
 for fixture: int in [1,11]:
  await demo.switch_room(fixture)
  hero.reset_to(AbbeyChapterLayout.origin(fixture)+(Vector2(936,84) if fixture==1 else AbbeyChapterLayout.exit_point(11)))
  hero.facing=1
  await frames(ceili(demo.camera.position.distance_to(demo.camera_target())/10.0)+8)
  await RenderingServer.frame_post_draw
  var img: Image=root.get_texture().get_image()
  check(img.get_size()==Vector2i(3840,2160),"Native 4K optional/end fixture")
  var view: Rect2=Rect2(demo.camera.get_screen_center_position()-Vector2(160,90),Vector2(320,180))
  check(view.has_point(hero.global_position+Vector2(-6,-24)) and view.has_point(hero.global_position+Vector2(6,8)),"Aren and supported tread framed in optional/end fixture")
  check(img.save_png(output+("/optional_4k.png" if fixture==1 else "/structural_end_4k.png"))==OK,"Saved optional/end evidence")
  if fixture==1: check(demo.discovered,"Integrated discovery on approved monument")
  else: check(demo.completed and demo.hint.text=="Fim da versão estrutural da Abadia — M5-B.","Safe end visible in actual integrated room")
  captures+=1
 FileAccess.open(output+"/visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"captures":captures,"backend":DisplayServer.get_name(),"scope":"sector composition fixtures, not human playtest"},"  "))
 print("M5-B graphic checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
