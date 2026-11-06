extends SceneTree
var chapter: Node2D
var hero: KnightController
var failures: int=0
var seen_phase2: bool=false
var seen_boss_dash: bool=false
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
func check(value: bool,label: String) -> void:
 print(("PASS " if value else "FAIL ")+label)
 if not value: failures+=1
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 check(not hero.dash_unlocked,"progressão nova sem dash")
 await chapter.switch_room(11)
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for i: int in range(180):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 check(chapter.arena_active,"entrada real pela saída do setor 12")
 if not chapter.arena_active:
  print("failures=",failures);quit(1);return
 check(not hero.dash_unlocked and chapter.room.boss.health==10,"chefe e dash inicial")
 for i: int in range(12000):
  var boss: Node=chapter.room.boss
  if boss.phase==2: seen_phase2=true
  if boss.phase==2 and boss.pattern==boss.Pattern.DASH and boss.state==boss.State.ACTIVE: seen_boss_dash=true
  var dx: float=boss.global_position.x-hero.global_position.x
  Input.action_release("move_left"); Input.action_release("move_right"); Input.action_release("jump"); Input.action_release("attack")
  if absf(dx)>27: Input.action_press("move_right" if dx>0 else "move_left")
  elif hero.facing!=(1 if dx>0 else -1): Input.action_press("move_right" if dx>0 else "move_left")
  if boss.state==boss.State.WARNING and boss.remaining<0.55 and hero.is_on_floor(): Input.action_press("jump")
  if i%30==0 and hero.is_on_floor() and (boss.phase==1 or seen_boss_dash): Input.action_press("attack")
  await tick()
  if i%600==0: print("FIGHT frame=",i," hp=",hero.survival.current_health," boss=",boss.health," phase=",boss.phase," state=",boss.state," dx=",dx)
  if hero.survival.is_dead or chapter.abbot_won: break
 for action: String in ["move_left","move_right","jump","attack"]: Input.action_release(action)
 check(seen_phase2,"transição para fase dois")
 check(seen_boss_dash,"dash ofensivo observado no combate")
 check(chapter.abbot_won,"vitória por golpes reais e controles")
 if chapter.abbot_won:
  check(hero.dash_unlocked,"recompensa após vitória")
  var ev: InputEventKey=InputEventKey.new();ev.keycode=KEY_E;ev.pressed=true;Input.parse_input_event(ev)
  await tick()
  ev=InputEventKey.new();ev.keycode=KEY_E;ev.pressed=false;Input.parse_input_event(ev)
  for f: int in range(3000):
   await tick()
   if not chapter.busy and chapter.current_room==11 and not chapter.arena_active: break
  check(not chapter.busy and chapter.current_room==11 and hero.dash_unlocked,"retorno ao Coro após vitória")
  Input.action_press("move_right")
  for f: int in range(180):
   await tick()
   if chapter.arena_active and not chapter.busy: break
  Input.action_release("move_right")
  check(chapter.completed and chapter.arena_active and chapter.abbot_won and chapter.room.boss.health==0,"vitória permite revisitar arena concluída")
 print("M5G fixture failures=",failures)
 chapter.queue_free()
 await tick(120)
 quit(1 if failures else 0)
