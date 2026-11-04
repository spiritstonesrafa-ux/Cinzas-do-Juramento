extends SceneTree
## Physical input probes. Resets are isolated fixtures; odometry is continuous.
var checks: int=0
var failures: int=0
var demo: Node2D
var hero: KnightController
var measured: Array=[]
var trials: int=0
var output: String
func _initialize() -> void: run.call_deferred()
func frames(n: int=1) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
func check(ok: bool,label: String) -> void:
 checks+=1
 if ok: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func release() -> void:
 for a: String in ["move_left","move_right","jump","attack"]: Input.action_release(a)
func wait_room() -> void:
 # Fixed-fps headless may simulate seconds before a real disk thread finishes.
 # Synchronize with loader completion, bounded by real time rather than ticks.
 var start: int=Time.get_ticks_msec()
 while Time.get_ticks_msec()-start<10000:
  await frames()
  if not demo.busy and demo.current_room>=0: return
func isolate_threats() -> void:
 # Length/navigation measurement only, like the C1 reference; never gameplay.
 if is_instance_valid(demo.room.pilot) and is_instance_valid(demo.room.pilot.monk):
  demo.room.pilot.monk.process_mode=Node.PROCESS_MODE_DISABLED
  demo.room.pilot.monk.source.set_active(false)
  demo.room.pilot.hazard.process_mode=Node.PROCESS_MODE_DISABLED
  demo.room.pilot.hazard.shape.set_deferred("disabled",true)
func navigation_route(id: int) -> Array[Rect2]:
 if id==5:
  return [Rect2(0,300,80,120),Rect2(80,276,96,12),Rect2(176,300,472,120),Rect2(648,276,80,12),Rect2(728,300,552,120)]
 return AbbeyChapterLayout.main_surfaces(id)
func steer(side: int) -> void:
 Input.action_release("jump")
 Input.action_press("move_right" if side>0 else "move_left")
 if not hero.is_on_floor(): return
 var p: Vector2=hero.global_position
 var space: PhysicsDirectSpaceState2D=hero.get_world_2d().direct_space_state
 var wall: Dictionary=space.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(0,-16),p+Vector2(side*8,-16),1))
 # Adjacent <=24px descents can be walked. Only a genuine horizontal gap
 # warrants a jump; a shallow ray would inflate odometry at every down tread.
 var floor_ahead: Dictionary=space.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(side*13,-2),p+Vector2(side*13,32),1))
 if not wall.is_empty() or floor_ahead.is_empty(): Input.action_press("jump")
func walk_sector(back: bool=false, record: bool=false) -> Dictionary:
 var id: int=demo.current_room
 var side: int=AbbeyChapterLayout.direction(id)*(-1 if back else 1)
 var end: Vector2=AbbeyChapterLayout.exit_point(id,back)
 var previous: Vector2=hero.global_position
 var length: float=0
 var horizontal: float=0
 var vertical: float=0
 var jumps: int=0
 var ticks: int=0
 var trace: Array=[]
 var success: bool=false
 for i: int in range(3600):
  if demo.busy or demo.current_room!=id: success=true;break
  var local: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
  if (local.x-end.x)*side>=0:
   success=true
   break
  var on_floor: bool=hero.is_on_floor()
  steer(side)
  await frames()
  ticks+=1
  if demo.busy or demo.current_room!=id:
   success=true
   break # no loader teleport is ever included in odometry
  var now: Vector2=hero.global_position
  var d: Vector2=now-previous
  length+=d.length();horizontal+=absf(d.x);vertical+=absf(d.y)
  if on_floor and hero.velocity.y<0: jumps+=1
  if record: trace.append([now.x-AbbeyChapterLayout.origin(id).x,now.y,d.length()])
  previous=now
  if hero.survival.is_dead or hero.position.y>AbbeyChapterLayout.bounds(id).end.y+80: break
 release()
 return {"sector":id+1,"backwards":back,"success":success,"length":length,"horizontal":horizontal,"vertical":vertical,"jumps":jumps,"ticks":ticks,"trace":trace}
func physical_leg(id: int,a: Rect2,b: Rect2,side: int,offset: float,standing: bool=false) -> void:
 release()
 var origin: Vector2=AbbeyChapterLayout.origin(id)
 var edge: float=a.end.x if side>0 else a.position.x
 hero.reset_to(origin+Vector2(edge-side*(offset+(0 if standing else 20)),a.position.y))
 await frames(ceili(demo.camera.position.distance_to(demo.camera_target())/10.0)+5)
 Input.action_press("move_right" if side>0 else "move_left")
 for i: int in range(0 if standing else 45):
  if (hero.global_position.x-origin.x-(edge-side*offset))*side>=0: break
  await frames()
 var p: Vector2=origin+Vector2(b.position.x+10 if side>0 else b.end.x-10,b.position.y)
 var view: Rect2=Rect2(demo.camera.get_screen_center_position()-Vector2(160,90),Vector2(320,180))
 check(view.has_point(p+Vector2(0,-24)) and view.has_point(p+Vector2(0,8)),"Landing visible before launch S%d" % (id+1))
 var gap: float=b.position.x-a.end.x if side>0 else a.position.x-b.end.x
 var jump: bool=b.position.y<a.position.y or gap>0
 if jump:
  Input.action_press("jump")
  await frames()
  Input.action_release("jump")
 var landed: bool=false
 for i: int in range(110):
  await frames()
  var local: Vector2=hero.global_position-origin
  if hero.is_on_floor() and absf(local.y-b.position.y)<0.2 and local.x>=b.position.x+6 and local.x<=b.end.x-6:
   landed=true;break
 release()
 trials+=1
 check(landed,"Physical leg S%d %s -> %s offset %.0f" % [id+1,a.position,b.position,offset])
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b")
 DirAccess.make_dir_recursive_absolute(output)
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo)
 await wait_room()
 hero=demo.hero
 await frames(5)
 var hero_id: int=hero.get_instance_id()
 var hud_id: int=demo.get_node("HealthHUD").get_instance_id()
 check(demo.current_room==0 and hero.is_on_floor(),"Supported first sector entry")
 check(AbbeyChapterLayout.NAMES.size()==12,"Twelve named sectors")
 check(demo.checkpoints.size()==7,"Seven stable functional checkpoints")
 check(hero.speed==100 and hero.gravity==680 and hero.jump_impulse==-230,"Approved movement intact")
 check(hero.survival.max_health==5 and hero.survival.invulnerability_duration==0.8,"Approved M2 life intact")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/main.tscn","F5 remains original campaign")
 var geometric: float=0
 for id: int in range(12):
  check(ResourceLoader.exists(AbbeyChapterLayout.room_path(id)),"Modular scene S"+str(id+1))
  geometric+=AbbeyChapterLayout.WIDTHS[id]-64
 check(geometric>=12227.52,"Horizontal unique spine lower bound exceeds 4x (geometry, separate from physics)")
 # Continuous full route: only input and actual door loads, no hero reset per leg.
 for id: int in range(12):
  await wait_room()
  check(demo.current_room==id,"Forward door sequence S"+str(id+1))
  isolate_threats()
  var result: Dictionary=await walk_sector(false,true)
  measured.append(result)
  check(result.success,"Continuous forward navigation S"+str(id+1))
  var required: int=0
  var route: Array[Rect2]=navigation_route(id)
  for edge: int in range(route.size()-1):
   var a: Rect2=route[edge]
   var b: Rect2=route[edge+1]
   var gap: float=b.position.x-a.end.x if AbbeyChapterLayout.direction(id)>0 else a.position.x-b.end.x
   if b.position.y<a.position.y or gap>0.1: required+=1
  check(int(result.jumps)==required,"Only geometry-required jumps, no gratuitous descending jumps S"+str(id+1))
  if id<11:
   for i: int in range(20):
    if demo.current_room!=id or demo.busy: break
    steer(AbbeyChapterLayout.direction(id));await frames()
   release()
   await wait_room()
 var total: float=0
 for data: Dictionary in measured: total+=float(data.length)
 check(total>=14400,"Measured continuous real-physics main path reaches 14400px")
 check(total>=4*3056.879979,"Measured route exceeds absolute 4x requirement")
 await frames(4)
 check(demo.completed,"Safe structural end, not chapter completion")
 check(demo.hint.text=="Fim da versão estrutural da Abadia — M5-B.","Exact structural end notice")
 # Full reverse navigation, still no per-leg reset; transitions not counted.
 for id: int in range(11,-1,-1):
  await wait_room();isolate_threats()
  check(demo.current_room==id,"Reverse door sequence S"+str(id+1))
  var result: Dictionary=await walk_sector(true)
  check(result.success,"Continuous reverse navigation S"+str(id+1))
  if id>0:
   for i: int in range(20):
    if demo.current_room!=id or demo.busy: break
    steer(-AbbeyChapterLayout.direction(id));await frames()
   release();await wait_room()
 # Independent multi-approach landing probes, not odometry.
 for id: int in range(12):
  if demo.current_room!=id: await demo.switch_room(id)
  isolate_threats()
  var route: Array[Rect2]=navigation_route(id)
  for i: int in range(route.size()-1):
   if route[i].position.y==route[i+1].position.y and absf(route[i].end.x-route[i+1].position.x)<0.1: continue
   for forward: bool in [true,false]:
    var a: Rect2=route[i] if forward else route[i+1]
    var b: Rect2=route[i+1] if forward else route[i]
    var side: int=AbbeyChapterLayout.direction(id)*(1 if forward else -1)
    for offset: float in [8.0,12.0,16.0,20.0]: await physical_leg(id,a,b,side,offset)
    await physical_leg(id,a,b,side,8.0,true)
 # Seven physical CP triggers; unload destination, die in another room, reload first.
 for cp: RespawnCheckpoint in demo.checkpoints:
  var id: int=int(cp.get_meta("sector_id"))
  await demo.switch_room(id)
  hero.reset_to(cp.global_position+Vector2(-36,0))
  await frames(4)
  Input.action_press("move_right")
  await frames(24);release()
  check(hero.active_checkpoint==cp and cp.active,"Physical CP activation "+cp.name)
  check(hero.is_respawn_safe(cp.respawn_point.global_position),"Supported safe CP marker "+cp.name)
  var old: WeakRef=weakref(demo.room)
  await demo.switch_room((id+2)%12)
  check(old.get_ref()==null,"Checkpoint room safely unloaded "+cp.name)
  await frames(55)
  hero.receive_damage(999)
  await frames(60);await wait_room();await frames(4)
  check(demo.current_room==id and hero.survival.current_health==5,"Death reloads owning CP sector "+cp.name)
  check(hero.global_position.distance_to(cp.respawn_point.global_position)<0.3 and hero.is_on_floor(),"Actual safe respawn "+cp.name)
  check(demo.get_node("HealthHUD/Life").text=="VIDA 5/5","HUD follows respawn "+cp.name)
  var stable: WeakRef=weakref(demo.room)
  hero.receive_damage(999)
  await frames(60)
  check(stable.get_ref()!=null and hero.survival.current_health==5,"Same-room death does not duplicate sector "+cp.name)
 # Approved pilot health snapshot survives unload, death/fall clears it.
 await demo.switch_room(5)
 var monk: ChainedMonk=demo.room.pilot.monk
 check(monk.get_script().resource_path=="res://scripts/abbey/monk.gd","Approved monk implementation reused")
 check(demo.room.pilot.hazard.get_script().resource_path=="res://scripts/abbey/counterweight.gd","Approved hazard implementation reused")
 monk.current_health=0;monk.set_state(ChainedMonk.State.DEAD)
 await demo.switch_room(4,true);await demo.switch_room(5)
 check(demo.room.pilot.monk.state==ChainedMonk.State.DEAD,"Enemy defeat snapshot persists same life")
 var previous_cp: RespawnCheckpoint=hero.active_checkpoint
 hero.receive_damage(1)
 hero.position.y=1000
 await frames(15);await wait_room()
 check(demo.current_room==0 and hero.survival.current_health==4,"Alive fall returns start without healing")
 check(hero.active_checkpoint==previous_cp,"Alive fall preserves stable CP identity")
 check(not hero.receive_damage(999),"Alive fall preserves M2 invulnerability")
 await frames(55);hero.receive_damage(999)
 await frames(60);await wait_room()
 check(demo.current_room==11 and hero.survival.current_health==5,"Death after fall reloads distant CP7")
 await demo.switch_room(5)
 check(demo.room.pilot.monk.current_health==3,"Death clears unloaded enemy snapshot")
 var identities: Array=[]
 for id: int in range(12):
  var old: WeakRef=weakref(demo.room)
  await demo.switch_room(id)
  check(old.get_ref()==null and demo.get_node("Rooms").get_child_count()==1,"One resident room, no retained old nodes S"+str(id+1))
  check(hero.get_instance_id()==hero_id and demo.get_node("HealthHUD").get_instance_id()==hud_id,"Persistent hero/HUD identities S"+str(id+1))
  check(hero.survival.respawn_requested.get_connections().size()==1,"No duplicated respawn signal S"+str(id+1))
  identities.append(demo.room.get_instance_id())
 check(root.content_scale_size==Vector2i(320,180),"Logical FOV preserved")
 # F7 uses real scene reload in a current scene, not a synthetic reset helper.
 current_scene=demo
 var key: InputEventKey=InputEventKey.new();key.keycode=KEY_F7;key.pressed=true
 demo._unhandled_key_input(key)
 await frames(20)
 demo=current_scene;hero=demo.hero;await wait_room()
 check(demo.current_room==0 and demo.visits==[0] and hero.active_checkpoint==null,"F7 resets whole isolated chapter/session")
 check(not demo.completed and not demo.discovered and hero.survival.current_health==5,"F7 clears completion/discovery and restores initial life")
 FileAccess.open(output+"/functional.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"physical_trials":trials,"route":measured,"total":total,"factor":total/3056.879979,"horizontal_lower_bound":geometric,"transition_distance_counted":0,"threats_disabled_for_navigation_only":true},"  "))
 print("M5-B checks: ",checks,"; failures: ",failures,"; route: ",total)
 quit(0 if failures==0 else 1)
