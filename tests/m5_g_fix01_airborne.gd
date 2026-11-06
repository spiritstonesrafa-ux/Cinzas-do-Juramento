extends SceneTree
var failures: int=0
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v:failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 await chapter.switch_room(11)
 var hero: KnightController=chapter.hero
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy:break
 Input.action_release("move_right")
 var boss: Node=chapter.room.boss
 for side: int in [-1,1]:
  var h: float=100 if side<0 else 220
  hero.survival.restore();hero.reset_to(chapter.ARENA_ORIGIN+Vector2(h,156));boss.position=Vector2(h-side*55,156);boss.phase=2;boss._state(boss.State.INTRO,10.0);await tick(5)
  Input.action_press("jump");await tick(1);Input.action_release("jump");await tick(7)
  var airborne: bool=not hero.is_on_floor() and hero.velocity.y<0
  boss.facing=side;boss.pattern=boss.Pattern.DASH;boss._state(boss.State.WARNING,boss.dash_warning_time)
  var jumped: bool=false;var active: bool=false;var hp: int=hero.survival.current_health
  for n: int in range(180):
   Input.action_release("jump")
   if boss.state==boss.State.WARNING and boss.remaining<=0.20 and not jumped and hero.is_on_floor():Input.action_press("jump");jumped=true
   await tick()
   if boss.state==boss.State.ACTIVE:active=true
   if active and boss.state==boss.State.RECOVER:break
  Input.action_release("jump")
  check(airborne and active,"aviso começa com Aren em salto lado "+str(side))
  check(jumped and hero.survival.current_health==hp,"aterrissa e responde ao dash lado "+str(side))
 print("M5G FIX01 airborne failures=",failures)
 chapter.queue_free();await tick(120);quit(1 if failures else 0)
