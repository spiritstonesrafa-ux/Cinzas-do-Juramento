extends SceneTree
## M4-A real-input foundation checks. Fixture positioning is separate from live fight/evasion.
var checks: int=0
var failures: int=0
var main: Node
var stage: Node2D
var hero: KnightController
var encounter: Node2D
var boss: OathGuardian
var out: String
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
func check(ok: bool,label: String) -> void:
 checks+=1
 if ok:print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func release() -> void:
 for key: String in ["move_left","move_right","jump","attack"]:Input.action_release(key)
func place(local: Vector2) -> void:
 release()
 hero.reset_to(encounter.arena.global_position+local)
 await frames(4)
func wait_state(wanted: OathGuardian.State,limit: int=400) -> bool:
 for i: int in range(limit):
  if boss.state==wanted:return true
  await frames(1)
 return false
func capture(label: String) -> void:
 if DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 var image: Image=root.get_texture().get_image()
 check(image.save_png(out+"/"+label+".png")==OK,"Native evidence saved: "+label)
func swing() -> void:
 Input.action_press("attack");await frames(1);Input.action_release("attack");await frames(25)
func walk_to_entry() -> void:
 release()
 hero.reset_to(Vector2(2298,156))
 await frames(4)
 Input.action_press("move_right")
 for i: int in range(45):
  await frames(1)
  if encounter.active:break
 release()
 await frames(2)
func run() -> void:
 out=OS.get_environment("CINZAS_M4A_EVIDENCE")
 if out.is_empty():out=ProjectSettings.globalize_path("res://.godot/m4a")
 DirAccess.make_dir_recursive_absolute(out)
 if OS.get_environment("CINZAS_M4A_4K")=="1":root.mode=Window.MODE_FULLSCREEN
 main=(load("res://scenes/main.tscn") as PackedScene).instantiate()
 root.add_child(main)
 await frames(5)
 stage=main.get_node("ForgottenCemetery") as Node2D
 hero=stage.get_node("Knight") as KnightController
 encounter=main.get_node("GuardianEncounter") as Node2D
 check(not encounter.active and encounter.arena==null,"Arena loads lazily, normal exploration stays untouched")
 check(stage.get_node("WorldGeometry").get_child_count()==19 and stage.get_node("Enemies").get_child_count()==12,"M3 geometry preserved and M5-H twelve enemies present")
 check(root.content_scale_mode==Window.CONTENT_SCALE_MODE_CANVAS_ITEMS and root.get_visible_rect().size==Vector2(320,180),"Approved display and logical reference preserved")
 hero.reset_to(Vector2(2288,156));await frames(5)
 check(not encounter.active,"Homologated finish marker does not force encounter")
 await capture("cathedral_portal")
 await walk_to_entry()
 check(encounter.active and encounter.arena!=null,"Actual walk into trigger enters cathedral room")
 boss=encounter.arena.get_node("Guardian") as OathGuardian
 check(is_instance_valid(boss),"Boss scene loads")
 check((encounter.arena.get_node("Floor/CollisionShape2D").shape as RectangleShape2D).size.x==320,"Arena has a full-screen 320px supported floor")
 check(boss.state==OathGuardian.State.INTRO,"Short intro begins on trigger")
 check(encounter.arena.get_node("BossHUD").visible,"Boss bar appears")
 check(encounter.arena.get_node("BossHUD/Presentation").boss==boss,"Boss bar binds live boss HP")
 check(not encounter.arena.get_node("LeftGate/CollisionShape2D").disabled,"Arena lock is physically active")
 check(not stage.get_node("StageHUD").visible and stage.get_node("HealthHUD").visible,"Exploration notice hidden, base health HUD retained")
 check(root.get_camera_2d()==encounter.arena.get_node("ArenaCamera"),"Dedicated fixed camera becomes current")
 check(stage.get_node("Enemies").process_mode==Node.PROCESS_MODE_DISABLED,"Exploration enemies pause outside the room")
 await capture("intro")
 # Intro remains mobile but invulnerable to the unchanged sword.
 await place(Vector2(206,156))
 Input.action_press("attack");await frames(1);Input.action_release("attack");await frames(8)
 check(boss.current_health==boss.max_health,"Intro rejects actual M1 sword damage")
 check(not boss.attack_source.active,"No contact damage during intro")
 check(await wait_state(OathGuardian.State.WAKE),"Explicit wake state follows intro")
 check(await wait_state(OathGuardian.State.IDLE),"Awakened idle state exists")
 await capture("idle")
 # Lock: run into the existing physical left boundary, without disabling controls.
 boss.reset_encounter();boss.begin(hero)
 await place(Vector2(24,156))
 Input.action_press("move_left");await frames(30);release()
 check(hero.position.x-encounter.arena.global_position.x>=5.9 and encounter.active,"Physical gate blocks escape during fight")
 check(hero.speed==100 and hero.gravity==680 and hero.jump_impulse==-230,"Aren motion parameters unchanged")
 check(await wait_state(OathGuardian.State.PURSUIT),"Awake guardian enters pursuit")
 var previous_x: float=boss.position.x
 await frames(20)
 check(boss.position.x<previous_x and boss.position.x>=28,"Pursuit physically closes distance inside arena bounds")
 boss.reset_encounter()
 check(boss.state==OathGuardian.State.IDLE and boss.position==boss.origin,"Reset explicitly restores dormant idle/origin")
 boss.begin(hero)
 await place(Vector2(176,156))
 check(await wait_state(OathGuardian.State.TELEGRAPH),"Distance detection/positioning reaches visible telegraph")
 check(not boss.attack_source.active,"Telegraph has no damage source")
 var locked_direction: int=boss.facing
 await capture("telegraph")
 while boss.state==OathGuardian.State.TELEGRAPH and boss.remaining>0.30:await frames(1)
 var health_before: int=hero.survival.current_health
 Input.action_press("jump");await frames(1);Input.action_release("jump")
 check(await wait_state(OathGuardian.State.ATTACK),"Telegraph leads to real attack")
 check(boss.attack_source.active and boss.facing==locked_direction,"Swing enables source and keeps committed direction")
 await capture("attack_evaded")
 check(await wait_state(OathGuardian.State.PUNISH),"Attack ends in punish window")
 check(hero.survival.current_health==health_before,"Timed real jump evades complete swing without damage")
 check(not boss.attack_source.active,"Punish window clears active source")
 await frames(35)
 # Grounded contact is delivered through the existing M2 hurtbox, once per swing.
 await place(Vector2(boss.position.x-60,156))
 check(await wait_state(OathGuardian.State.TELEGRAPH),"Next attack requires a new warning")
 check(await wait_state(OathGuardian.State.ATTACK),"Second attack begins")
 health_before=hero.survival.current_health
 await frames(4)
 check(hero.survival.current_health==health_before-1,"Grounded blade overlap deals exactly one M2 HP")
 await frames(6)
 check(hero.survival.current_health==health_before-1,"Same swing cannot duplicate damage")
 check(await wait_state(OathGuardian.State.PUNISH),"Contact swing recovers")
 await capture("punish")
 await place(Vector2(boss.position.x-30,156))
 Input.action_press("attack");await frames(1);Input.action_release("attack");await frames(8)
 check(boss.state==OathGuardian.State.HURT and boss.current_health==boss.max_health-1,"Real punish hit enters hurt state and removes one boss HP")
 await capture("hurt")
 # Full live victory: no boss processing freeze, healing or resets inside the duel.
 hero.survival.restore()
 boss.reset_encounter();boss.begin(hero)
 await place(Vector2(210,156))
 check(await wait_state(OathGuardian.State.TELEGRAPH),"Live duel becomes attackable after wake")
 var full_hp: int=boss.current_health
 await swing()
 check(boss.current_health==full_hp-1,"Unchanged horizontal sword damages boss once")
 check(encounter.arena.get_node("BossHUD/Presentation").boss.current_health==boss.current_health,"Bar reads updated HP")
 await capture("duel")
 for i: int in range(16):
  if boss.state==OathGuardian.State.DEFEATED:break
  await swing()
 check(boss.state==OathGuardian.State.DEFEATED and boss.current_health==0,"Live M1 swings can defeat prototype")
 check(not hero.survival.is_dead,"Prototype can be won with original Aren")
 check(encounter.completed and not boss.attack_source.active,"Defeat signals completion and clears danger")
 await frames(2)
 check(encounter.arena.get_node("LeftGate/CollisionShape2D").disabled,"Victory unlocks physical gate")
 check(boss.receiver.disabled,"Defeated boss cannot receive stale hits")
 await capture("defeated")
 Input.action_press("move_left")
 for i: int in range(160):
  await frames(1)
  if not encounter.active:break
 release()
 check(not encounter.active and hero.position.x<2340,"Walk back through opened seal returns to cemetery")
 check(root.get_camera_2d()==stage.get_node("Camera2D"),"Original exploration camera restored")
 check(stage.get_node("StageHUD").visible and not encounter.arena.get_node("BossHUD").visible,"Exploration HUD restored and boss bar hidden")
 check(hero.z_index==0 and stage.get_node("Enemies").process_mode!=Node.PROCESS_MODE_DISABLED,"Visual order and original enemy processing restored")
 # Death in the room must use CP2, not invent a new boss checkpoint.
 hero.reset_to(Vector2(1936,156));await frames(4)
 var checkpoint: RespawnCheckpoint=hero.active_checkpoint
 check(checkpoint==stage.get_node("Mechanisms/Checkpoint2"),"Existing CP2 activates by real contact")
 await walk_to_entry()
 check(encounter.active,"Completed room can be revisited without another fight")
 hero.receive_damage(999);await frames(50)
 check(not encounter.active and not hero.survival.is_dead,"M2 death exits room safely")
 check(hero.position.distance_to(checkpoint.position)<0.2 and hero.survival.current_health==hero.survival.max_health,"M2 checkpoint destination/full health preserved")
 check(boss.state==OathGuardian.State.IDLE and boss.current_health==boss.max_health and not encounter.completed,"Death resets boss to dormant idle for retry")
 check(not boss.attack_source.active,"Reset clears boss damage source")
 await walk_to_entry()
 check(encounter.active and boss.state==OathGuardian.State.INTRO,"Retry triggers intro again")
 hero.receive_damage(1)
 hero.position.y=300
 await frames(3)
 check(not encounter.active and hero.position.distance_to(Vector2(48,156))<0.2,"Alive fall returns to original M3 spawn")
 check(hero.survival.current_health==hero.survival.max_health-1 and hero.active_checkpoint==checkpoint,"Alive fall keeps HP loss and checkpoint progress")
 check(root.get_camera_2d()==stage.get_node("Camera2D") and hero.z_index==0,"Fall restores camera and draw order")
 await frames(60)
 hero.receive_damage(999)
 encounter.enter() # Deferred entry must recheck life even after an earlier alive overlap.
 check(not encounter.active,"Delayed entry cannot start an encounter with dead Aren")
 await frames(50)
 release()
 var data: Dictionary={"checks":checks,"failures":failures,"window":str(root.size),"logical":str(root.get_visible_rect()),"image":str(root.get_texture().get_image().get_size()) if DisplayServer.get_name()!="headless" else "headless"}
 var file: FileAccess=FileAccess.open(out+"/boss_test.json",FileAccess.WRITE)
 file.store_string(JSON.stringify(data,"  "))
 print("M4-A checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
