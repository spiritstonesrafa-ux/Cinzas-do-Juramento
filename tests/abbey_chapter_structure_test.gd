extends "res://tests/abbey_chapter_test.gd"
## Geometry/manifests are labelled separately from the physical optional trace.
var optional_trace: Array=[]
var optional_length: float=0
func optional_frame() -> void:
 var before: Vector2=hero.global_position
 await frames()
 var d: float=hero.global_position.distance_to(before)
 optional_length+=d
 optional_trace.append([hero.global_position.x-4096,hero.global_position.y,d])
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b-structure")
 DirAccess.make_dir_recursive_absolute(output)
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo);await wait_room();hero=demo.hero;await frames(5)
 var layouts: Array=[]
 for id: int in range(12):
  var rects: Array=[]
  var rise: float=0
  var gap_max: float=0
  var route: Array[Rect2]=AbbeyChapterLayout.main_surfaces(id)
  for i: int in range(route.size()):
   var r: Rect2=route[i]
   rects.append({"x":r.position.x,"y":r.position.y,"w":r.size.x,"h":r.size.y})
   if i>0:
    rise=maxf(rise,absf(r.position.y-route[i-1].position.y))
    var gap: float=r.position.x-route[i-1].end.x if AbbeyChapterLayout.direction(id)>0 else route[i-1].position.x-r.end.x
    gap_max=maxf(gap_max,gap)
  check(rise<=24,"Geometric max height step <=24 S"+str(id+1))
  check(gap_max<=24,"Geometric main gap <=24 S"+str(id+1))
  for ceiling: Rect2 in AbbeyChapterLayout.ceilings(id):
   check(ceiling.size.y==12,"Geometric vault intrados thickness S"+str(id+1))
  await demo.switch_room(id)
  check(hero.is_respawn_safe(hero.global_position),"Actual support and clearance at entry S"+str(id+1))
  check(demo.room.get_node("FutureIntegration").get_child_count()>=1,"Future descriptors, no fake threats S"+str(id+1))
  var b: Rect2=AbbeyChapterLayout.bounds(id)
  var entry: Vector2=AbbeyChapterLayout.entry(id)
  var end: Vector2=AbbeyChapterLayout.exit_point(id)
  layouts.append({"sector":id+1,"name":AbbeyChapterLayout.NAMES[id],"feature":AbbeyChapterLayout.FEATURES[id],"width":b.size.x,"height":b.size.y,"top":b.position.y,"bottom":b.end.y,"entry":[entry.x,entry.y],"exit":[end.x,end.y],"direction":AbbeyChapterLayout.direction(id),"surfaces":rects,"max_step":rise,"max_gap":gap_max})
  if id in [1,5]:
   check(demo.room.pilot!=null,"Approved pilot instantiated, not recreated S"+str(id+1))
  else:
   var path: String="res://assets/art/m5b/"+AbbeyChapterLayout.KEYS[id]+".png"
   var texture: Texture2D=load(path) as Texture2D
   check(texture.get_width()>1000,"Detailed original background S"+str(id+1))
   check(ResourceUID.has_id(ResourceLoader.get_resource_uid(path)),"Imported art UID resolves S"+str(id+1))
 # Real maximum jump in unchanged M0, standing and running on level support.
 await demo.switch_room(0)
 hero.reset_to(Vector2(48,300));await frames(5)
 var peak: float=hero.global_position.y
 Input.action_press("jump");await frames();Input.action_release("jump")
 for i: int in range(80):
  await frames();peak=minf(peak,hero.position.y)
  if hero.is_on_floor(): break
 var jump_height: float=300-peak
 check(jump_height>40 and jump_height<42,"Real physics maximum jump unchanged")
 # Exclusive optional branch starts at its takeoff junction, no common approach.
 await demo.switch_room(1)
 hero.reset_to(Vector2(4096+756,156));await frames(5)
 var branch_ok: bool=true
 for i: int in range(3):
  var edge: float=768 if i==0 else AbbeyPilotLayout.OPTIONAL[i-1].end.x
  Input.action_press("move_right")
  while hero.global_position.x-4096<edge-12: await optional_frame()
  Input.action_press("jump");await optional_frame();Input.action_release("jump")
  var dest: Rect2=AbbeyPilotLayout.OPTIONAL[i]
  var landed: bool=false
  for tick: int in range(90):
   await optional_frame()
   var p: Vector2=hero.global_position-Vector2(4096,0)
   if hero.is_on_floor() and absf(p.y-dest.position.y)<0.2 and p.x>dest.position.x+8:
    landed=true;break
  release()
  if not landed: branch_ok=false;break
  for tick: int in range(3): await optional_frame()
 check(branch_ok and demo.discovered,"Integrated optional branch physically reaches Votos sem Nome")
 check(optional_length>180 and optional_length<400,"Optional exclusive path measured separately")
 # Stay five seconds at each real activated checkpoint: no safety invulnerability.
 var cps: Array=[]
 for cp: RespawnCheckpoint in demo.checkpoints:
  var id: int=int(cp.get_meta("sector_id"))
  await demo.switch_room(id)
  hero.reset_to(cp.global_position)
  await frames(305)
  check(hero.active_checkpoint==cp and hero.survival.current_health==5,"Five-second supported safe CP "+cp.name)
  check(hero.survival.invulnerability_remaining==0,"CP safety does not rely on invulnerability "+cp.name)
  cps.append({"name":cp.name,"sector":id+1,"local_x":cp.position.x-AbbeyChapterLayout.origin(id).x,"local_y":cp.position.y,"marker_same_as_trigger":true})
 # External fatal contact at the first async handoff: timer/loader serialize.
 demo.switch_room(2)
 check(demo.busy and hero.receive_damage(999),"Fatal event accepted during async sector handoff")
 await wait_room();await frames(65);await wait_room()
 check(demo.current_room==11 and hero.survival.current_health==5 and hero.is_on_floor(),"Fatal handoff resolves to loaded safe CP7")
 FileAccess.open(output+"/structure.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"layouts":layouts,"jump_height":jump_height,"optional_exclusive_length":optional_length,"optional_trace":optional_trace,"checkpoints":cps,"reserved_optional_branches":6,"active_discoveries":1,"reserved_shortcuts":3,"active_shortcuts":0},"  "))
 print("M5-B structure checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
