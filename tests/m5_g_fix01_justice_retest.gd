extends SceneTree
var failures: int=0
var checks: int=0
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n): await physics_frame;await process_frame
func check(v: bool,label: String) -> void:
 checks+=1
 print(("PASS " if v else "FAIL ")+label)
 if not v: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 await chapter.switch_room(11)
 var hero: KnightController=chapter.hero
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for i: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy:break
 Input.action_release("move_right")
 if not chapter.arena_active:print("FAIL arena");quit(1);return
 var boss: Node=chapter.room.boss
 var scenarios: Array=[
  {"name":"perto_esquerda","hero":100.0,"boss":145.0,"side":-1},
  {"name":"longe_esquerda","hero":50.0,"boss":160.0,"side":-1},
  {"name":"parede_esquerda","hero":20.0,"boss":65.0,"side":-1},
  {"name":"perto_direita","hero":220.0,"boss":175.0,"side":1},
  {"name":"longe_direita","hero":270.0,"boss":160.0,"side":1},
  {"name":"parede_direita","hero":300.0,"boss":255.0,"side":1}
 ]
 for pattern: int in [boss.Pattern.CHAIN,boss.Pattern.SWEEP,boss.Pattern.DASH]:
  for scenario: Dictionary in scenarios:
   hero.survival.restore();hero.reset_to(chapter.ARENA_ORIGIN+Vector2(scenario.hero,156))
   boss.position=Vector2(scenario.boss,156);boss.velocity=Vector2.ZERO;boss.health=10;boss.phase=2 if pattern==boss.Pattern.DASH else 1
   await tick(4)
   boss.facing=scenario.side;boss.pattern=pattern;boss._state(boss.State.WARNING,boss.dash_warning_time if pattern==boss.Pattern.DASH else boss.warning_time)
   var warning_seen: bool=false;var active_seen: bool=false;var inactive_correct: bool=true;var jumped: bool=false
   var original_health: int=hero.survival.current_health;var first_x: float=boss.position.x;var max_step: float=0.0
   for frame: int in range(180):
    Input.action_release("jump")
    if boss.state==boss.State.WARNING:
     warning_seen=true
     if boss.remaining<=(0.05 if pattern==boss.Pattern.DASH and scenario.name.begins_with("longe") else 0.20) and not jumped and hero.is_on_floor():Input.action_press("jump");jumped=true
    var was_active: bool=boss.state==boss.State.ACTIVE
    var previous_x: float=boss.position.x
    await tick()
    max_step=maxf(max_step,absf(boss.position.x-previous_x))
    if boss.state==boss.State.ACTIVE:active_seen=true
    if boss.source.active != (boss.state==boss.State.ACTIVE):inactive_correct=false
    if active_seen and boss.state==boss.State.RECOVER:break
   Input.action_release("jump")
   var label: String="p%d_%s" % [pattern,scenario.name]
   print("CASE ",label," hp=",hero.survival.current_health," jumped=",jumped," first_x=",first_x," end_x=",boss.position.x," max_step=",max_step)
   check(warning_seen and active_seen and inactive_correct,label+" sinalização e janela")
   check(jumped and hero.survival.current_health==original_health,label+" salto sem dano")
   check(boss.state==boss.State.RECOVER and not boss.source.active and boss.position.x>=24.9 and boss.position.x<=295.1,label+" recuperação e limites")
   if pattern==boss.Pattern.DASH: check(max_step<=boss.dash_speed/60.0+0.2,label+" velocidade")
 # Sword recovery overlap, directions mirrored; actual J starts the existing cycle.
 for side: int in [-1,1]:
  var h: float=100.0 if side<0 else 220.0
  hero.survival.restore();hero.reset_to(chapter.ARENA_ORIGIN+Vector2(h,156))
  boss.position=Vector2(h-side*60,156);boss.health=10;boss.phase=2;await tick(4)
  boss.facing=side;boss.pattern=boss.Pattern.DASH;boss._state(boss.State.WARNING,boss.dash_warning_time)
  var launched: bool=false;var jumped: bool=false;var in_recovery: bool=false;var active: bool=false;var hp: int=hero.survival.current_health
  for frame: int in range(180):
   Input.action_release("attack");Input.action_release("jump")
   if boss.state==boss.State.WARNING and boss.remaining<=0.43 and not launched:Input.action_press("attack");launched=true
   if boss.state==boss.State.WARNING and boss.remaining<=0.20 and not jumped and hero.is_on_floor():
    in_recovery=hero.sword_attack.phase==SwordAttack.Phase.RECOVERY
    Input.action_press("jump");jumped=true
   await tick()
   if boss.state==boss.State.ACTIVE:active=true
   if active and boss.state==boss.State.RECOVER:break
  Input.action_release("attack");Input.action_release("jump")
  print("RECOVERY side=",side," attacked=",launched," recovery=",in_recovery," jumped=",jumped," hp=",hero.survival.current_health)
  check(launched and jumped and in_recovery,"recuperação de espada durante aviso lado "+str(side))
  check(active and hero.survival.current_health==hp,"esquiva durante recuperação lado "+str(side))
 print("M5G FIX01 justice checks=",checks," failures=",failures)
 chapter.queue_free();await tick(120);quit(1 if failures else 0)
