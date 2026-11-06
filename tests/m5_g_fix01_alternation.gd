extends SceneTree
var fails: int=0
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v:fails+=1
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
 var boss: Node=chapter.room.boss
 hero.reset_to(chapter.ARENA_ORIGIN+Vector2(80,156));boss.position=Vector2(150,156)
 await tick(5);boss.phase=2;boss.attacks=1;boss._state(boss.State.PURSUIT,0)
 var previous: int=-1;var patterns: Array[int]=[];var jumped: bool=false;var active_checks: bool=true
 for frame: int in range(1200):
  Input.action_release("jump")
  if boss.state!=previous:
   if boss.state==boss.State.WARNING:
    patterns.append(boss.pattern);jumped=false
    print("PATTERN ",boss.pattern," facing=",boss.facing," frame=",frame)
   previous=boss.state
  if boss.state==boss.State.WARNING and boss.remaining<0.20 and not jumped and hero.is_on_floor():
   Input.action_press("jump");jumped=true
  if boss.state==boss.State.ACTIVE:
   if not boss.source.active or boss.source.position.x*boss.facing<=0:active_checks=false
   if patterns.size()>=3:
    boss.health=1;boss._hit()
    break
  await tick()
  if hero.survival.is_dead:break
 Input.action_release("jump")
 check(patterns.size()>=3 and patterns[0]==boss.Pattern.DASH and patterns[1]==boss.Pattern.CHAIN and patterns[2]==boss.Pattern.DASH,"alternância fase 2 dash-corrente-dash")
 check(active_checks,"direção e ativação durante ataques")
 check(boss.state==boss.State.DEFEATED and not boss.source.active,"derrota interrompe ataque ativo")
 print("M5G FIX01 alternation failures=",fails," hp=",hero.survival.current_health)
 chapter.queue_free();await tick(120);quit(1 if fails else 0)
