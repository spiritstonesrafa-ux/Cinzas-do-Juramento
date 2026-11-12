extends SceneTree
var failures: int=0
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var isolate=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolate.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolate+"/"): quit(2); return
 var world=Node2D.new(); root.add_child(world)
 var hero: KnightController=load("res://scenes/player/knight.tscn").instantiate()
 world.add_child(hero)
 var arena=load("res://scenes/abbey/abbot_arena.tscn").instantiate(); arena.configure(hero,false); world.add_child(arena)
 var start_x: float=float(OS.get_environment("BOSS_BALANCE_START_X")) if OS.has_environment("BOSS_BALANCE_START_X") else 145.0
 hero.position=Vector2(start_x,156); hero.survival.max_health=6; hero.survival.restore()
 var boss=arena.boss
 await physics_frame
 boss.phase=2; boss._start_judgment()
 var seen=0; var danger: float=-1000; var samples=[]; var was_active=false
 for i in range(720):
  Input.action_release("move_left"); Input.action_release("move_right")
  if boss.judgment_index>seen:
   seen=boss.judgment_index
   var h=boss.judgment_hazards.back()
   danger=h.global_position.x
   samples.append({"n":seen,"x":danger,"hero_warning":hero.global_position.x})
  var delta_x: float=hero.global_position.x-danger
  if seen==7 and not is_instance_valid(boss.judgment_hazards[6]):
   var toward: float=boss.global_position.x-hero.global_position.x
   if absf(toward)>30:Input.action_press("move_right" if toward>0 else "move_left")
  elif absf(delta_x)<22:
   var dir: String="move_left" if delta_x<0 else "move_right"
   if danger<50:dir="move_right"
   elif danger>270:dir="move_left"
   Input.action_press(dir)
  await physics_frame
  if seen>0 and is_instance_valid(boss.judgment_hazards[seen-1]):
   var h=boss.judgment_hazards[seen-1]
   var active=h.age>=h.WARNING and h.age<h.WARNING+h.ACTIVE
   if active and not was_active:
    samples[seen-1]["hero_impact"]=hero.global_position.x
    samples[seen-1]["hp"]=hero.survival.current_health
   was_active=active
  else:was_active=false
  if hero.survival.is_dead or (seen==7 and boss.state==boss.State.RECOVER):break
 Input.action_release("move_left"); Input.action_release("move_right")
 check(not hero.dash_unlocked,"sem dash")
 check(seen==7,"sete impactos")
 check(hero.survival.current_health==6,"sete impactos evitados sem dano")
 check(boss.state not in [boss.State.ASCEND,boss.State.JUDGMENT,boss.State.DESCEND],"retorno terrestre")
 print("IMPACTOS ",JSON.stringify(samples))
 var before_hp: int=boss.health
 Input.action_press("move_left" if hero.global_position.x>boss.global_position.x else "move_right")
 await physics_frame
 Input.action_release("move_left"); Input.action_release("move_right")
 Input.action_press("attack")
 await physics_frame
 Input.action_release("attack")
 for i in range(25):await physics_frame
 check(boss.health<before_hp,"contra-ataque SOTN real após aterrissagem")
 world.queue_free(); await process_frame
 quit(1 if failures else 0)
