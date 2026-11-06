extends SceneTree
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 var hero: KnightController=chapter.hero
 hero.reset_to(AbbeyChapterLayout.origin(0)+Vector2(300,300));await tick(10)
 var start: float=hero.global_position.x
 var shift: InputEventKey=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=true;Input.parse_input_event(shift);await tick()
 var active: bool=hero.dash_remaining>0
 shift=InputEventKey.new();shift.keycode=KEY_SHIFT;shift.pressed=false;Input.parse_input_event(shift)
 await tick(60)
 var rest: float=hero.global_position.x
 var stopped: bool=absf(hero.velocity.x)<0.1 and hero.dash_remaining==0.0
 Input.action_press("move_left");await tick(20);Input.action_release("move_left")
 var moved_back: bool=hero.global_position.x<rest-5
 var ok: bool=hero.dash_unlocked and active and rest>start and stopped and moved_back
 print(("PASS " if ok else "FAIL "),"dash termina, para e controle responde ao sentido oposto; start=",start," rest=",rest," now=",hero.global_position.x)
 chapter.queue_free();await tick(120);quit(0 if ok else 1)
