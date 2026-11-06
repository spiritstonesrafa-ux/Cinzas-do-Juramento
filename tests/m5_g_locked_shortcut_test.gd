extends SceneTree
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame;await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(8)
 var hero: KnightController=chapter.hero
 var point: Vector2=preload("res://scripts/abbey/m5e_shortcuts.gd").point(8,1270)
 hero.reset_to(AbbeyChapterLayout.origin(8)+point)
 for n: int in range(5): await tick()
 var e: InputEventKey=InputEventKey.new();e.keycode=KEY_E;e.pressed=true;Input.parse_input_event(e)
 await tick();e=InputEventKey.new();e.keycode=KEY_E;e.pressed=false;Input.parse_input_event(e);await tick()
 var locked_before: bool=not chapter.unlocked_shortcuts.has(2) and chapter.passage_index<0
 var shift: InputEventKey=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=true;Input.parse_input_event(shift)
 for n: int in range(15): await tick()
 shift=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=false;Input.parse_input_event(shift)
 var ok: bool=hero.dash_unlocked and locked_before and chapter.passage_index<0 and not chapter.unlocked_shortcuts.has(2) and not chapter.visits.has(9)
 print("PASS dash não abre A3 nem substitui primeira visita S10" if ok else "FAIL trava A3")
 chapter.queue_free()
 for n: int in range(120):await tick()
 quit(0 if ok else 1)
