extends SceneTree
## Physical probes plus state fixtures; no alteration to approved C1 suites.
var checks: int = 0
var failures: int = 0
var demo: Node2D
var hero: KnightController
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
func check(ok: bool,label: String) -> void:
 checks += 1
 if ok: print("PASS: ",label)
 else:
  failures += 1
  push_error("FAIL: "+label)
func release() -> void:
 for action: String in ["move_right","move_left","jump","attack"]: Input.action_release(action)
func wait_room() -> void:
 for i: int in range(120):
  await frames(1)
  if not demo.busy and demo.current_room>=0: return
func leg(a: Rect2,b: Rect2,side: int,offset: float) -> bool:
 release()
 var edge: float = a.end.x if side>0 else a.position.x
 hero.reset_to(Vector2(edge-side*(offset+20),a.position.y))
 await frames(4)
 var action: String = "move_right" if side>0 else "move_left"
 Input.action_press(action)
 for i: int in range(40):
  if (hero.position.x-(edge-side*offset))*side>=0: break
  await frames(1)
 # Small descending gaps are deliberately walked, preventing overshoot of a short tread.
 var gap: float = b.position.x-a.end.x if side>0 else a.position.x-b.end.x
 var down: bool = b.position.y>a.position.y and gap<=20
 var landing: Vector2=Vector2(b.position.x+12 if side>0 else b.end.x-12,b.position.y)
 var view: Rect2=Rect2(demo.camera.get_screen_center_position()-Vector2(160,90),Vector2(320,180))
 check(view.has_point(landing+Vector2(0,8)) and view.has_point(landing+Vector2(0,-24)),"Destination body and tread visible before launch")
 if not down:
  Input.action_press("jump")
  await frames(1)
  Input.action_release("jump")
 for i: int in range(110):
  await frames(1)
  if hero.is_on_floor() and absf(hero.position.y-b.position.y)<0.2 and hero.position.x>=b.position.x+6 and hero.position.x<=b.end.x-6:
   release()
   return true
 release()
 return false
func walk_to(x: float,upstairs: bool = true) -> bool:
 var side: int = 1 if x>hero.position.x else -1
 var action: String = "move_right" if side>0 else "move_left"
 Input.action_press(action)
 for i: int in range(1800):
  Input.action_release("jump")
  if demo.busy: break
  if upstairs and hero.is_on_floor():
   var p: Vector2=hero.global_position
   var hit: Dictionary=hero.get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(0,-4),p+Vector2(side*8,-4),1))
   if not hit.is_empty(): Input.action_press("jump")
  await frames(1)
  if (hero.position.x-x)*side>=0:
   release()
   return true
 release()
 return false
func swing() -> void:
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(28)
func explore_optional() -> bool:
 hero.reset_to(Vector2(48,300))
 await frames(5)
 if not await walk_to(732): return false
 for index: int in range(3):
  var edge: float = 768 if index==0 else AbbeyPilotLayout.OPTIONAL[index-1].end.x
  Input.action_press("move_right")
  for i: int in range(90):
   if hero.position.x>=edge-12: break
   await frames(1)
  Input.action_press("jump")
  await frames(1)
  Input.action_release("jump")
  var destination: Rect2=AbbeyPilotLayout.OPTIONAL[index]
  var landed: bool=false
  for i: int in range(90):
   await frames(1)
   if hero.is_on_floor() and absf(hero.position.y-destination.position.y)<0.2 and hero.position.x>=destination.position.x+8:
    landed=true
    break
  release()
  if not landed: return false
  await frames(3)
 return true
func run() -> void:
 demo=(load("res://scenes/abbey/abbey_pilots.tscn") as PackedScene).instantiate()
 root.add_child(demo)
 await wait_room()
 hero=demo.hero
 await frames(5)
 check(demo.current_room==0 and demo.get_node("Rooms").get_child_count()==1,"Only first pilot resident at initialization")
 check(hero.is_on_floor() and hero.is_respawn_safe(Vector2(48,300)),"Original Aren enters supported safe spawn")
 check(hero.speed==100 and hero.gravity==680 and hero.jump_impulse==-230,"M0 movement parameters preserved")
 check(hero.survival.max_health==5 and hero.survival.invulnerability_duration==0.8,"M2 life contract preserved")
 check(hero.sword_attack.windup_duration==0.1 and hero.sword_attack.active_duration==0.1 and hero.sword_attack.recovery_duration==0.2,"M1 sword cycle unchanged")
 check(demo.get_node("HealthHUD/Life").text=="VIDA 5/5","Original HUD binds exact health signal")
 check(ProjectSettings.get_setting("application/run/main_scene")=="res://scenes/main.tscn","Official campaign entry not replaced")
 check(root.content_scale_size==Vector2i(320,180) and root.content_scale_mode==Window.CONTENT_SCALE_MODE_CANVAS_ITEMS,"Approved logical canvas remains effective")
 check(demo.room.get_node("Geometry").get_child_count()==13,"Cloister has ten main solids and three optional ledges")
 # Independent physical leg samples: geometry only, not manual comfort approval.
 var routes: Array = [AbbeyPilotLayout.MAIN,[AbbeyPilotLayout.MAIN[6],AbbeyPilotLayout.OPTIONAL[0],AbbeyPilotLayout.OPTIONAL[1],AbbeyPilotLayout.OPTIONAL[2]]]
 for route: Array in routes:
  for index: int in range(route.size()-1):
   for side: int in [1,-1]:
    for offset: float in [8.0,12.0,16.0,20.0]:
     var a: Rect2=route[index] if side>0 else route[index+1]
     var b: Rect2=route[index+1] if side>0 else route[index]
     check(await leg(a,b,side,offset),"Physical supported landing %s -> %s offset %s" % [a.position,b.position,offset])
     # Camera is observed, never used to teleport the character.
     var view: Rect2=Rect2(demo.camera.get_screen_center_position()-Vector2(160,90),Vector2(320,180))
     check(view.grow(2).has_point(hero.position+Vector2(0,-12)),"Camera keeps landed Aren inside frame")
 release()
 check(await explore_optional(),"Uninterrupted spawn-to-optional route uses real input and landings")
 await frames(8)
 check(demo.discovered,"Optional monument discovery triggers without inventory")
 check(demo.current_room==0,"Upper optional ledge cannot accidentally enter next room")
 hero.reset_to(Vector2(48,300))
 await frames(5)
 check(await walk_to(930),"Continuous horizontal and vertical main route by original inputs")
 check(hero.position.y<240,"Live route climbs and returns through the authored upper gallery")
 release()
 hero.reset_to(Vector2(800,180))
 await frames(6)
 check(await walk_to(60),"Continuous main return with original inputs")
 check(hero.is_on_floor(),"Return ends on supported entry floor")
 hero.reset_to(Vector2(96,300))
 await frames(6)
 check(hero.active_checkpoint==demo.checkpoints[0],"Independent checkpoint physically activates")
 var old: WeakRef=weakref(demo.room)
 hero.reset_to(Vector2(936,228))
 Input.action_press("move_right")
 await frames(15)
 release()
 await wait_room()
 check(demo.current_room==1,"Walking through authored exit enters gallery")
 check(old.get_ref()==null and demo.get_node("Rooms").get_child_count()==1,"Unloaded room nodes freed before replacement")
 check(hero.active_checkpoint==demo.checkpoints[0] and is_instance_valid(hero.active_checkpoint),"Checkpoint reference survives owner room unload")
 # Death before gallery CP reloads the unloaded checkpoint sector first.
 hero.receive_damage(999)
 await frames(55)
 await wait_room()
 check(demo.current_room==0 and hero.survival.current_health==5,"Death reloads checkpoint room before safe original M2 respawn")
 check(hero.position.distance_to(demo.checkpoints[0].respawn_point.global_position)<1 and hero.is_on_floor(),"Respawn supported at stable checkpoint transform")
 await demo.switch_room(1)
 await frames(5)
 var monk: ChainedMonk=demo.room.monk
 var hazard: AbbeyCounterweight=demo.room.hazard
 check(monk.current_health==3 and monk.source.damage==1,"Monk has skeleton-equivalent HP/damage, different pattern")
 check((monk.source.shape.shape as RectangleShape2D).size==Vector2(44,12),"Committed chain has authored longer physical reach")
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(350,300))
 monk.reset_enemy()
 monk.target=hero
 for i: int in range(30):
  await frames(1)
  if monk.state==ChainedMonk.State.WARNING: break
 check(monk.state==ChainedMonk.State.WARNING,"Visible nearby Aren triggers learned windup")
 check(not monk.source.active,"No damage source during warning")
 var direction: int=monk.facing
 hero.reset_to(monk.global_position+Vector2(-direction*26,0))
 await frames(8)
 check(monk.facing==direction,"Windup direction cannot track player crossing behind")
 monk.reset_enemy()
 hero.reset_to(monk.global_position+Vector2(-35,0))
 await frames(5)
 var hp: int=hero.survival.current_health
 await frames(40)
 check(hero.survival.current_health==hp-1,"Real chain contact causes exactly one M2 damage")
 check(monk.state==ChainedMonk.State.RECOVER and not monk.source.active,"Attack enters long disarmed recovery")
 hero.survival.restore()
 monk.reset_enemy()
 hero.reset_to(monk.global_position+Vector2(-35,0))
 for i: int in range(40):
  await frames(1)
  if monk.state==ChainedMonk.State.WARNING and monk.remaining<=0.30: break
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(44)
 check(hero.survival.current_health==5,"Original jump can avoid the committed attack")
 # Isolated recovery fixtures ensure real M1 hits; not proof of full human duel.
 monk.reset_enemy()
 for hit: int in range(3):
  monk.set_state(ChainedMonk.State.RECOVER,1.2)
  hero.reset_to(monk.global_position+Vector2(-25,0))
  hero.facing=1
  await frames(4)
  await swing()
  check(monk.current_health==2-hit,"Original physical sword hits monk once per swing "+str(hit))
 check(monk.state==ChainedMonk.State.DEAD and not monk.source.active,"Third real sword hit leaves inert defeat state")
 # Continuous duel: original inputs only; no healing or state fixtures inside loop.
 monk.reset_enemy()
 hero.survival.restore()
 hero.reset_to(monk.global_position+Vector2(-35,0))
 var before_hits: int=monk.hits_received
 var before_attacks: int=monk.attacks
 for i: int in range(900):
  Input.action_release("jump")
  Input.action_release("attack")
  if monk.state==ChainedMonk.State.DEAD or hero.survival.is_dead: break
  if monk.state==ChainedMonk.State.WARNING and monk.remaining<=0.30 and hero.is_on_floor():Input.action_press("jump")
  if monk.state==ChainedMonk.State.RECOVER and hero.is_on_floor() and hero.sword_attack.phase==SwordAttack.Phase.NEUTRAL:Input.action_press("attack")
  await frames(1)
 release()
 check(monk.state==ChainedMonk.State.DEAD,"Live original-input duel wins without state manipulation")
 check(monk.hits_received-before_hits==3,"Live duel requires three real M1 sword hits")
 check(monk.attacks>before_attacks,"Live duel exercises committed offensive pattern")
 check(hero.survival.current_health==5,"Learned timing permits a no-damage live duel")
 await demo.switch_room(0,true)
 await demo.switch_room(1)
 await frames(4)
 monk=demo.room.monk
 hazard=demo.room.hazard
 check(monk.state==ChainedMonk.State.DEAD,"Defeated enemy stays defeated across same-life unload/reentry")
 check(demo.discovered,"Optional discovery persists across scene replacement")
 hazard.reset_hazard()
 check(hazard.state==AbbeyCounterweight.State.SAFE and hazard.shape.disabled,"Counterweight starts safe and has no offensive collision")
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(588,300))
 hero.survival.restore()
 await frames(110)
 check(hazard.state==AbbeyCounterweight.State.WARNING and hazard.shape.disabled,"Warning is visible but nonoffensive")
 await frames(62)
 check(hero.survival.current_health==4,"Falling weight physically delivers one coherent damage")
 await frames(14)
 check(hazard.state==AbbeyCounterweight.State.RECOVER and hazard.shape.disabled,"Recovery retracts weight without damaging")
 hazard.reset_hazard()
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(535,300))
 hero.survival.restore()
 await frames(185)
 check(hero.survival.current_health==5,"Visible side refuge stays safe through full hazard cycle")
 hazard.reset_hazard()
 check(await walk_to(AbbeyPilotLayout.ORIGINS[1].x+636,false) and hero.survival.current_health==5,"Original movement physically crosses weight lane during safe window")
 hero.reset_to(AbbeyPilotLayout.ORIGINS[1]+Vector2(96,300))
 await frames(6)
 check(hero.active_checkpoint==demo.checkpoints[1],"Gallery checkpoint physically activates")
 hero.receive_damage(999)
 await frames(55)
 check(not hero.survival.is_dead and hero.survival.current_health==5,"Gallery death restores original life")
 check(demo.room.monk.current_health==3 and demo.room.monk.state!=ChainedMonk.State.DEAD,"Death resets resident and stored enemy defeat")
 check(demo.room.hazard.shape.disabled,"Death resets hazard offensive collision")
 var hazard_clock: float=demo.room.hazard.remaining
 await frames(4)
 check(demo.room.hazard.remaining<hazard_clock and demo.room.hazard.process_mode==Node.PROCESS_MODE_INHERIT,"Hazard resumes its cycle after same-room death reset")
 check(demo.get_node("HealthHUD/Life").text=="VIDA 5/5","HUD remains coherent after death/reset")
 hero.receive_damage(1)
 hero.position.y=520
 await frames(12)
 await wait_room()
 check(demo.current_room==0 and hero.survival.current_health==4,"Alive fall reloads initial room without healing")
 check(hero.active_checkpoint==demo.checkpoints[1],"Alive fall preserves checkpoint progression")
 check(not hero.receive_damage(999),"Alive fall preserves remaining M2 invulnerability instead of cancelling it")
 await frames(60)
 check(hero.receive_damage(999),"Fatal contact accepted after original invulnerability expires")
 await frames(55)
 await wait_room()
 check(demo.current_room==1 and hero.position.distance_to(demo.checkpoints[1].respawn_point.global_position)<1,"Death after alive fall reloads other stable checkpoint")
 for cycle: int in range(6):
  old=weakref(demo.room)
  await demo.switch_room(0,true)
  check(old.get_ref()==null,"Cycle "+str(cycle)+" releases gallery")
  await demo.switch_room(1)
  check(demo.get_node("Rooms").get_child_count()==1,"Cycle "+str(cycle)+" leaves one resident room")
 release()
 var output: String=OS.get_environment("CINZAS_M5_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5a")
 DirAccess.make_dir_recursive_absolute(output)
 FileAccess.open(output+"/functional.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"physical_trials":96,"room_transitions":demo.transitions,"load_ms":demo.load_times_ms},"  "))
 print("M5-A checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
