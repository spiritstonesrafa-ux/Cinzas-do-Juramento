extends "res://tests/abbey_pilot_test.gd"
var output: String
var captures: int=0
func capture(label: String,size: Vector2i) -> void:
 root.mode=Window.MODE_WINDOWED
 root.size=size
 await frames(5)
 await RenderingServer.frame_post_draw
 var img: Image=root.get_texture().get_image()
 check(img.get_size()==size,"Native dimensions "+label)
 check(root.get_visible_rect().size==Vector2(320,180),"Logical FOV retained "+label)
 check(img.save_png(output+"/"+label+".png")==OK,"Native evidence saved "+label)
 captures+=1
func run() -> void:
 output=OS.get_environment("CINZAS_M5_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5a-visual")
 DirAccess.make_dir_recursive_absolute(output)
 check(DisplayServer.get_name()!="headless","Actual graphics backend available")
 demo=(load("res://scenes/abbey/abbey_pilots.tscn") as PackedScene).instantiate()
 root.add_child(demo)
 await wait_room()
 hero=demo.hero
 for id: int in [0,1]:
  if id!=demo.current_room: await demo.switch_room(id)
  hero.reset_to(AbbeyPilotLayout.ORIGINS[id]+Vector2(420,228 if id==0 else 300))
  if id==1:
   demo.room.monk.process_mode=Node.PROCESS_MODE_DISABLED
   demo.room.hazard.process_mode=Node.PROCESS_MODE_DISABLED
  await frames(50)
  check(demo.room.get_node("Art").texture_filter==CanvasItem.TEXTURE_FILTER_LINEAR,"Only backdrop/material adopts Linear in room "+str(id))
  check(root.canvas_item_default_texture_filter==Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST,"Actors/HUD retain Nearest "+str(id))
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   await capture("room"+str(id+1)+"_"+str(size.x),size)
 await demo.switch_room(0)
 check(await explore_optional(),"Graphical optional traversal reaches actual high ledges")
 await frames(8)
 await capture("optional_discovery_4k",Vector2i(3840,2160))
 check(demo.discovered,"Visible optional discovery state")
 await demo.switch_room(1)
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(350,300))
 await frames(35)
 var monk: ChainedMonk=demo.room.monk
 monk.process_mode=Node.PROCESS_MODE_DISABLED
 for state: ChainedMonk.State in [ChainedMonk.State.WARNING,ChainedMonk.State.ACTIVE,ChainedMonk.State.RECOVER,ChainedMonk.State.DEAD]:
  monk.facing=-1
  monk.set_state(state,0.5)
  await capture("monk_state_"+str(state),Vector2i(3840,2160))
 # Poses are fixtures; functional suite separately tests real damage and timing.
 monk.source.set_active(false)
 var hazard: AbbeyCounterweight=demo.room.hazard
 hazard.process_mode=Node.PROCESS_MODE_DISABLED
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(535,300))
 await frames(35)
 for state: AbbeyCounterweight.State in [AbbeyCounterweight.State.SAFE,AbbeyCounterweight.State.WARNING,AbbeyCounterweight.State.ACTIVE,AbbeyCounterweight.State.RECOVER]:
  hazard.state=state
  hazard.elapsed=0.3
  hazard.queue_redraw()
  await capture("counterweight_state_"+str(state),Vector2i(3840,2160))
 for path: String in ["cloister","gallery","monk","architecture"]:
  var texture: Texture2D=load("res://assets/art/m5a/"+path+".png")
  check(texture.get_width()>1000,"Original detailed atlas/source loaded "+path)
  var id: int=ResourceLoader.get_resource_uid("res://assets/art/m5a/"+path+".png")
  check(ResourceUID.has_id(id),"Imported UID resolves "+path)
  if path in ["monk","architecture"]:check(texture.get_image().detect_alpha()!=Image.ALPHA_NONE,"Transparent alpha preserved "+path)
 FileAccess.open(output+"/visual.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"captures":captures,"backend":DisplayServer.get_name(),"fixture_poses":true},"  "))
 print("M5-A visual checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
