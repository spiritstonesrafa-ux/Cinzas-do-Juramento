extends SceneTree
const LINKS: Script=preload("res://scripts/abbey/m5e_shortcuts.gd")
var failures: int=0
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 var hero: KnightController=chapter.hero
 for index: int in range(3):
  var link: Array=LINKS.LINKS[index]
  await chapter.switch_room(link[0]);hero.reset_to(AbbeyChapterLayout.origin(link[0])+LINKS.point(link[0],link[1]));await tick(60)
  var e: InputEventKey=InputEventKey.new();e.keycode=KEY_E;e.pressed=true;Input.parse_input_event(e);await tick()
  e=InputEventKey.new();e.keycode=KEY_E;e.pressed=false;Input.parse_input_event(e);await tick()
  var before: bool=not chapter.unlocked_shortcuts.has(index) and chapter.passage_index<0
  var shift: InputEventKey=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=true;Input.parse_input_event(shift);await tick()
  var active: bool=hero.dash_remaining>0
  shift=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=false;Input.parse_input_event(shift);await tick(15)
  while chapter.busy: await tick()
  var no_bypass: bool=index!=2 or (chapter.current_room!=10 and (chapter.current_room!=9 or chapter.visits.has(9)))
  var ok: bool=hero.dash_unlocked and before and active and chapter.passage_index<0 and not chapter.unlocked_shortcuts.has(index) and no_bypass
  print(("PASS " if ok else "FAIL "),"dash não abre porta trancada A",index+1," active=",active," room=",chapter.current_room," visits=",chapter.visits)
  if not ok:failures+=1
 print("M5G FIX01 locked gates failures=",failures)
 chapter.queue_free();await tick(120);quit(1 if failures else 0)
