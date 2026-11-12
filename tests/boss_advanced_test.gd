extends SceneTree
## Isolated fixtures declare pattern/positions; damage, jump and live duels use real physics.
var checks: int=0
var failures: int=0
var main: Node
var encounter: Node2D
var hero: KnightController
var boss: OathGuardian
var out: String
var captures: int=0
var duel_results: Array=[]
var benchmark: Dictionary={}
func _initialize() -> void:run.call_deferred()
func frames(n: int) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
func check(ok: bool,label: String) -> void:
 checks+=1
 if ok:print("PASS: ",label)
 else:failures+=1;push_error("FAIL: "+label)
func release() -> void:
 for key: String in ["move_left","move_right","jump","attack"]:Input.action_release(key)
func wait_state(value: int,limit: int=400) -> bool:
 for i: int in range(limit):
  if boss.state==value:return true
  await frames(1)
 return false
func capture(label: String) -> void:
 if DisplayServer.get_name()=="headless":return
 await RenderingServer.frame_post_draw
 var picture: Image=root.get_texture().get_image()
 if picture.save_png(out+"/"+label+".png")==OK:captures+=1
 else:push_error("Capture failed: "+label)
func fixture(kind: int,side: int,gap: float=60) -> void:
 release()
 boss.reset_encounter()
 hero.survival.restore()
 boss.position=Vector2(110 if side>0 else 210,156)
 hero.reset_to(encounter.arena.global_position+boss.position+Vector2(side*gap,0))
 await frames(4)
 boss.target=hero
 boss.awake=true
 boss.facing=side
 boss.start_pattern(kind)
func jump() -> void:
 Input.action_press("jump");await frames(1);Input.action_release("jump")
func duel(allow_error: bool) -> void:
 release()
 encounter.completed=false
 encounter.arena.get_node("LeftGate/CollisionShape2D").set_deferred("disabled",false)
 boss.reset_encounter();boss.begin(hero)
 hero.survival.restore()
 hero.reset_to(encounter.arena.global_position+Vector2(176,156))
 var start: float=boss.elapsed
 var previous_state: int=-1
 var patterns: Array[int]=[]
 var errors: int=0
 var frames_used: int=0
 var hits: int=0
 var punished: bool=false
 var error_spent: bool=false
 var hp: int=boss.current_health
 var last_hero_hp: int=hero.survival.current_health
 var damage_taken: int=0
 # No teleport, heal, source mutation or boss freeze inside this live loop.
 for i: int in range(7200):
  if boss.state==OathGuardian.State.DEFEATED or hero.survival.is_dead:break
  frames_used=i
  Input.action_release("attack");Input.action_release("jump")
  var dx: float=boss.global_position.x-hero.global_position.x
  Input.action_release("move_left");Input.action_release("move_right")
  var wanted_gap: float=26 if boss.state in [OathGuardian.State.PUNISH,OathGuardian.State.HURT,OathGuardian.State.PHASE_TRANSITION] else 60
  if boss.state!=OathGuardian.State.ATTACK:
   if absf(dx)>wanted_gap+2:Input.action_press("move_right" if dx>0 else "move_left")
   elif absf(dx)<wanted_gap-2:Input.action_press("move_left" if dx>0 else "move_right")
  if boss.state==OathGuardian.State.TELEGRAPH:
   if previous_state!=boss.state:patterns.append(boss.pattern)
   punished=false
   var deliberately_grounded: bool=allow_error and not error_spent
   if not deliberately_grounded and boss.remaining<=(0.3 if boss.pattern==0 else (0.2 if boss.pattern==2 else (0.1 if boss.pattern==1 else 0.06))) and hero.is_on_floor():Input.action_press("jump")
   if deliberately_grounded and boss.remaining<=0.02:error_spent=true
  # Respond to the announced two-pulse ground attack with the normal jump.
  if hero.is_on_floor() and boss.state==OathGuardian.State.SUPER_WARN and boss.remaining<0.25 and absf(dx)<50:
   Input.action_press("jump")
  if hero.is_on_floor() and boss.state==OathGuardian.State.SUPER_ACTIVE:
   if not boss.super_second_sent and boss.remaining<2.0 and absf(dx)<50:
    Input.action_press("jump")
   for wave: Node2D in boss.super_waves:
    if is_instance_valid(wave):
     var wave_dx: float=hero.global_position.x-wave.global_position.x
     if wave_dx*wave.direction>0 and absf(wave_dx)<45:Input.action_press("jump")
  if hero.is_on_floor() and absf(dx)<=38 and boss.state==OathGuardian.State.PUNISH and not punished:
   Input.action_press("attack");punished=true
  previous_state=boss.state
  await frames(1)
  if boss.current_health<hp:hits+=hp-boss.current_health;hp=boss.current_health
  if hero.survival.current_health<last_hero_hp:damage_taken+=last_hero_hp-hero.survival.current_health
  last_hero_hp=hero.survival.current_health
 var row: Dictionary={"error_trial":allow_error,"won":boss.state==OathGuardian.State.DEFEATED,"hp":hero.survival.current_health,"hits":hits,"seconds":frames_used/60.0,"patterns":patterns}
 duel_results.append(row)
 check(row.won,"Live original-input duel wins; error trial="+str(allow_error))
 check(hits==10,"Live duel requires ten original sword hits")
 check(boss.phase==2,"Live duel crosses into phase two")
 check(hero.survival.current_health>0,"Live duel survives without healing")
 check(patterns.has(OathGuardian.Pattern.SWEEP) and patterns.has(OathGuardian.Pattern.WAVE),"Live duel exercises new phase-one and phase-two patterns")
 check(damage_taken==0 if not allow_error else damage_taken>0,"Live duel confirms zero-damage / recoverable-error outcome before reward")
 release()
 await capture("victory_errors" if allow_error else "victory")
func run() -> void:
 out=OS.get_environment("CINZAS_M4B_EVIDENCE")
 if out.is_empty():out=ProjectSettings.globalize_path("res://.godot/m4b")
 DirAccess.make_dir_recursive_absolute(out)
 if DisplayServer.get_name()!="headless":root.mode=Window.MODE_FULLSCREEN
 main=(load("res://scenes/main.tscn") as PackedScene).instantiate();root.add_child(main)
 await frames(5)
 hero=main.get_node("ForgottenCemetery/Knight") as KnightController
 encounter=main.get_node("GuardianEncounter") as Node2D
 hero.reset_to(Vector2(2298,156));Input.action_press("move_right")
 for i: int in range(50):
  await frames(1)
  if encounter.active:break
 release()
 check(encounter.active,"Advanced arena activated by actual movement")
 boss=encounter.arena.get_node("Guardian") as OathGuardian
 check(boss.state==OathGuardian.State.INTRO,"Approved intro retained")
 check(boss.max_health==10 and hero.survival.max_health==5,"Approved HP values retained")
 check(hero.speed==100 and hero.gravity==680 and hero.jump_impulse==-230,"Approved movement retained")
 check(root.get_camera_2d()==encounter.arena.get_node("ArenaCamera"),"Approved arena framing retained")
 await capture("phase1")
 var texture: Texture2D=load("res://assets/art/m4b/oath_flame.png")
 check(texture.get_size()==Vector2(1536,1024),"Original new flame resource loads")
 var bitmap: Image=texture.get_image()
 check(bitmap.detect_alpha()!=Image.ALPHA_NONE,"Flame transparency preserved")
 # Physical grounded/jump trials for both directions and all patterns.
 for side: int in [-1,1]:
  for kind: int in range(4):
   await fixture(kind,side)
   check(not boss.attack_source.active,"No damage during windup kind="+str(kind)+" side="+str(side))
   var warning: float=boss.remaining
   check(warning>=0.8,"Windup at least 0.8 seconds")
   await capture("warning_%s_%s"%[kind,side])
   var direction: int=boss.facing
   var x_before: float=boss.position.x
   var hp_before: int=hero.survival.current_health
   check(await wait_state(OathGuardian.State.ATTACK),"Windup executes pattern="+str(kind))
   await frames(3)
   await capture("active_%s_%s"%[kind,side])
   check(await wait_state(OathGuardian.State.PUNISH),"Pattern has recovery")
   await frames(18)
   check(hero.survival.current_health==hp_before-1,"Actual grounded contact loses one HP; kind="+str(kind)+" side="+str(side))
   check(boss.facing==direction,"Execution does not home or turn")
   check(not boss.attack_source.active,"Recovery ends melee damage")
   if kind==OathGuardian.Pattern.CHARGE:
    check(absf(boss.position.x-x_before)<=72.1 and absf(boss.position.x-x_before)>0 and absf(hero.global_position.x-boss.global_position.x)>=27,"Charge stops before occupying Aren while retaining bounded movement")
    check(boss.position.x>=28 and boss.position.x<=292,"Charge stays inside arena")
    check(boss.position.x+77<=320 if side>0 else boss.position.x-77>=0,"Charge blade fits the approved camera")
   boss.clear_dangers()
   await fixture(kind,side)
   var jump_lead: float=0.27 if kind==0 else (0.2 if kind==2 else (0.1 if kind==1 else 0.0))
   while boss.state==OathGuardian.State.TELEGRAPH and boss.remaining>jump_lead:await frames(1)
   hp_before=hero.survival.current_health
   await jump()
   check(await wait_state(OathGuardian.State.ATTACK),"Real jump leads into attack")
   if kind==OathGuardian.Pattern.WAVE:await frames(9)
   await capture("evade_%s_%s"%[kind,side])
   check(await wait_state(OathGuardian.State.PUNISH),"Jump trial reaches recovery")
   await frames(22)
   check(hero.survival.current_health==hp_before,"Real jump evades full attack kind="+str(kind)+" side="+str(side))
   boss.clear_dangers()
 # A clear lane must still permit the original full charge distance.
 for side: int in [-1,1]:
  await fixture(OathGuardian.Pattern.CHARGE,side,150)
  var start_x: float=boss.position.x
  await wait_state(OathGuardian.State.PUNISH)
  check(absf(boss.position.x-start_x)>60 and absf(boss.position.x-start_x)<=72.1,"Charge retains full reach in clear lane side="+str(side))
 # Timing windows: three different jump times per new pattern in both directions.
 for side: int in [-1,1]:
  for kind: int in [1,2,3]:
   var leads: Array=[0.1,0.16,0.22] if kind==1 else ([0.12,0.2,0.26] if kind==2 else [0.0,0.06,0.12])
   for lead: float in leads:
    await fixture(kind,side)
    while boss.state==OathGuardian.State.TELEGRAPH and boss.remaining>lead:await frames(1)
    var before: int=hero.survival.current_health
    await jump()
    await wait_state(OathGuardian.State.PUNISH)
    await frames(30)
    check(hero.survival.current_health==before,"Timing-window physical dodge kind=%s side=%s lead=%s"%[kind,side,lead])
    boss.clear_dangers()
 # Invulnerability: consumption applies even if original M2 armor rejects damage.
 await fixture(OathGuardian.Pattern.SWEEP,1)
 while boss.remaining>0.05:await frames(1)
 hero.receive_damage(1)
 await frames(25)
 check(hero.survival.current_health==4,"Original invulnerability blocks overlapping sweep")
 # Deferred phase transition never cancels a committed warning.
 await fixture(OathGuardian.Pattern.HEAVY,1)
 for i: int in range(5):boss.receive_hit()
 check(boss.current_health==5 and boss.phase_pending and boss.state==OathGuardian.State.TELEGRAPH,"50 percent schedules transition without canceling warning")
 check(await wait_state(OathGuardian.State.PHASE_TRANSITION),"Transition follows committed attack")
 check(not boss.attack_source.active and boss.phase==2,"Transition removes offensive damage")
 var hp: int=boss.current_health
 boss.receive_hit()
 check(boss.current_health==hp,"Short transformation rejects stale sword hits")
 await frames(20);await capture("phase_transition")
 check(await wait_state(OathGuardian.State.PUNISH),"Short transition gives safe punish window")
 boss.receive_hit()
 check(boss.current_health==hp-1,"Phase two receives normal one-point hits")
 await capture("phase2")
 # Selector considers distance, available room, cooldowns and previous pattern.
 boss.cooldowns.clear();boss.attack_count=2;boss.phase=1;boss.position.x=110;boss.facing=1;boss.last_pattern=0
 check(boss._choose_pattern(120)==OathGuardian.Pattern.CHARGE,"Long distance and space choose charge")
 boss.cooldowns[OathGuardian.Pattern.CHARGE]=2.0
 check(boss._choose_pattern(120)!=OathGuardian.Pattern.CHARGE,"Cooldown excludes charge")
 boss.cooldowns.clear();boss.position.x=280
 check(boss._choose_pattern(120)!=OathGuardian.Pattern.CHARGE,"Insufficient space excludes charge")
 boss.phase=2;boss.last_pattern=0
 check(boss._choose_pattern(60)==OathGuardian.Pattern.WAVE,"Phase two unlocks special")
 boss.last_pattern=OathGuardian.Pattern.WAVE
 check(boss._choose_pattern(60)!=OathGuardian.Pattern.WAVE,"Special cannot repeat immediately")
 boss.reset_encounter()
 check(boss.phase==1 and boss.cooldowns.is_empty() and boss.attack_count==0,"Reset restores phase, cooldowns and selection")
 # Projectile lifetime, limited range and no duplicate delivery after M2 immunity ends.
 await fixture(OathGuardian.Pattern.WAVE,1,90)
 await wait_state(OathGuardian.State.ATTACK)
 var wave: Node2D=boss.special_wave
 check(is_instance_valid(wave),"Slam creates visible travelling source")
 var origin: float=wave.position.x
 await frames(50)
 check(hero.survival.current_health==4,"Wave delivers a single original damage point")
 check(is_instance_valid(wave) and wave.travelled<170 and wave.position.x>origin,"Wave propagates physically at bounded speed")
 await frames(85)
 check(not is_instance_valid(wave),"Wave expires at limited range before next offense")
 check(hero.survival.current_health==4,"Same wave cannot hit twice after immunity expires")
 # Near wall: ray prevents wave crossing World, charge stops safely in either direction.
 for side: int in [-1,1]:
  await fixture(OathGuardian.Pattern.CHARGE,side,26)
  boss.position.x=32 if side<0 else 288
  await wait_state(OathGuardian.State.ATTACK);await frames(39)
  check(boss.position.x>=28 and boss.position.x<=292,"Physical boundary clamps charge side="+str(side))
 await fixture(OathGuardian.Pattern.WAVE,1)
 boss.position.x=275
 await wait_state(OathGuardian.State.ATTACK);await frames(20)
 check(not is_instance_valid(boss.special_wave),"World ray stops wave at wall")
 # Real deaths in all phase contexts clean danger before checkpoint respawn.
 for context: int in range(3):
  await fixture(OathGuardian.Pattern.WAVE,1)
  if context==1:boss._start_transition()
  elif context==2:
   boss.phase=2
   await wait_state(OathGuardian.State.ATTACK)
  hero.receive_damage(999)
  check(not boss.attack_source.active and not is_instance_valid(boss.special_wave),"Death immediately disarms danger context="+str(context))
  await frames(50)
  check(not encounter.active and boss.phase==1 and boss.current_health==10,"Death restores encounter and phase context="+str(context))
  encounter.enter();await frames(2)
 await duel(false)
 await duel(true)
 # Functional victory still permits actual walking out of the same seal.
 Input.action_press("move_left")
 for i: int in range(200):
  await frames(1)
  if not encounter.active:break
 release()
 check(not encounter.active,"M4-B victory exits through original seal")
 check(root.get_camera_2d()==main.get_node("ForgottenCemetery/Camera2D"),"Exit restores original exploration camera")
 if OS.get_environment("CINZAS_M4B_BENCH")=="1" and DisplayServer.get_name()!="headless":await measure()
 release()
 var result: Dictionary={"checks":checks,"failures":failures,"captures":captures,"image":str(root.get_texture().get_image().get_size()) if DisplayServer.get_name()!="headless" else "headless","duels":duel_results,"benchmark":benchmark}
 FileAccess.open(out+"/advanced.json",FileAccess.WRITE).store_string(JSON.stringify(result,"  "))
 print("M4-B checks: ",checks,"; failures: ",failures)
 quit(0 if failures==0 else 1)
func measure() -> void:
 encounter.completed=false;encounter.enter();await frames(2)
 boss.reset_encounter();boss.begin(hero)
 hero.survival.restore()
 var samples: Array[float]=[]
 var start: int=Time.get_ticks_usec()
 var previous: int=start
 var end: int=start+45000000
 var frame: int=0
 # Continuous graphical load, automatic retries; not a human playtest or perfect duel.
 while Time.get_ticks_usec()<end:
  Input.action_release("attack");Input.action_release("jump")
  if not encounter.active:
   encounter.completed=false;encounter.enter()
  if boss.state==OathGuardian.State.DEFEATED:encounter.completed=false;boss.reset_encounter();boss.begin(hero)
  if hero.is_on_floor() and boss.state==OathGuardian.State.TELEGRAPH and boss.remaining<0.27:Input.action_press("jump")
  if hero.is_on_floor() and frame%26==0:Input.action_press("attack")
  Input.action_release("move_left");Input.action_release("move_right")
  var dx: float=boss.global_position.x-hero.global_position.x
  if absf(dx)>26:Input.action_press("move_right" if dx>0 else "move_left")
  await process_frame
  var now: int=Time.get_ticks_usec()
  samples.append((now-previous)/1000.0)
  previous=now;frame+=1
 samples.sort()
 benchmark={"seconds":(previous-start)/1000000.0,"frames":frame,"fps":frame/((previous-start)/1000000.0),"p95_ms":samples[int(samples.size()*0.95)],"max_ms":samples[-1],"mode":"native graphical, no fixed-fps"}
