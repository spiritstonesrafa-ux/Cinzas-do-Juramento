extends SceneTree
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame;await process_frame
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
 for pattern: int in [boss.Pattern.CHAIN,boss.Pattern.SWEEP]:
  hero.reset_to(chapter.ARENA_ORIGIN+Vector2(80,156));boss.position=Vector2(150,156);boss.facing=-1
  boss.pattern=pattern;boss._state(boss.State.WARNING,boss.warning_time)
  var hp: int=hero.survival.current_health
  var seen_active: bool=false
  Input.action_press("move_left")
  for n: int in range(180):
   await tick()
   if boss.state==boss.State.ACTIVE:seen_active=true
   if seen_active and boss.state==boss.State.RECOVER:break
  Input.action_release("move_left")
  check(seen_active and hero.survival.current_health==hp,"recuo evita padrão "+str(pattern))
  check(boss.state==boss.State.RECOVER and not boss.source.active,"hitbox desarmada "+str(pattern))
 print("M5G conventional failures=",failures)
 chapter.queue_free()
 for n: int in range(120):await tick()
 quit(1 if failures else 0)
