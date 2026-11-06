extends SceneTree
var failures: int=0
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v: failures+=1
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
  hero.survival.restore();hero.reset_to(chapter.ARENA_ORIGIN+Vector2(200 if side<0 else 120,156));boss.position=Vector2(45 if side<0 else 275,156);await tick(3)
  boss.phase=2;boss.facing=side;boss.pattern=boss.Pattern.DASH;boss._state(boss.State.ACTIVE,0.42)
  var min_x: float=boss.position.x;var max_x: float=boss.position.x
  for n: int in range(60):
   await tick();min_x=minf(min_x,boss.position.x);max_x=maxf(max_x,boss.position.x)
   if boss.state==boss.State.RECOVER:break
  print("BOUND side=",side," min=",min_x," max=",max_x," end=",boss.position.x," state=",boss.state)
  check(min_x>=24.9 and max_x<=295.1,"dash respeita parede lado "+str(side))
  check(boss.state==boss.State.RECOVER and not boss.source.active,"recuperação após parede lado "+str(side))
 print("M5G FIX01 boss walls failures=",failures)
 chapter.queue_free();await tick(120);quit(1 if failures else 0)
