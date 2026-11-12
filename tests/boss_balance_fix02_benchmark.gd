extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var iso=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if iso.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(iso+"/"):quit(2);return
 for kind in ["guardian","abbot"]:
  for trial in ["observe","spam"]:
   await sample(kind,trial)
 quit(0)
func sample(kind: String, trial: String) -> void:
 var world=Node2D.new(); root.add_child(world)
 var hero: KnightController=load("res://scenes/player/knight.tscn").instantiate()
 world.add_child(hero)
 var arena: Node2D
 if kind=="guardian":arena=load("res://scenes/boss/guardian_arena.tscn").instantiate();world.add_child(arena)
 else:
  arena=load("res://scenes/abbey/abbot_arena.tscn").instantiate();arena.configure(hero,false);world.add_child(arena)
 var boss=arena.get_node("Guardian") if kind=="guardian" else arena.boss
 hero.position=Vector2(196 if trial=="spam" else 60,156)
 hero.survival.max_health=99 if trial=="observe" else (5 if kind=="guardian" else 6)
 hero.survival.restore()
 await physics_frame
 if kind=="guardian": boss.begin(hero)
 else:boss.target=hero
 var states: Dictionary={};var patterns: Dictionary={};var last: int=-1;var n: int=0
 for i in range(720):
  if trial=="spam":
   if i%15==0:Input.action_press("attack")
   elif i%15==1:Input.action_release("attack")
  await physics_frame
  n=i+1
  var st: int=boss.state
  states[st]=states.get(st,0)+1
  var warning: int=boss.State.TELEGRAPH if kind=="guardian" else boss.State.WARNING
  if st==warning and last!=st:patterns[boss.pattern]=patterns.get(boss.pattern,0)+1
  last=st
  if hero.survival.is_dead or st==boss.State.DEFEATED:break
 Input.action_release("attack")
 var hp: int=boss.current_health if kind=="guardian" else boss.health
 print("BENCH ",JSON.stringify({"kind":kind,"trial":trial,"frames":n,"seconds":n/60.0,"hero_hp":hero.survival.current_health,"boss_hp":hp,"states_frames":states,"patterns":patterns}))
 world.queue_free();await process_frame
