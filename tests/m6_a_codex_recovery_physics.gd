extends SceneTree
## Real input/physics checks for the two existing forest pilots.
var demo: ForestDemo
var hero: KnightController
var checks := 0
var failures := 0
func _initialize() -> void: run.call_deferred()
func tick(n: int = 1) -> void:
 for i in range(n): await physics_frame; await process_frame
func check(ok: bool, label: String) -> void:
 checks += 1
 print("PASS " if ok else "FAIL ",label)
 if not ok: failures += 1
func release_inputs() -> void:
 for action in ["move_left","move_right","jump","attack"]: Input.action_release(action)
func press_shift() -> void:
 var event := InputEventKey.new()
 event.keycode=KEY_SHIFT
 event.pressed=true
 Input.parse_input_event(event)
 await tick()
 event=InputEventKey.new()
 event.keycode=KEY_SHIFT
 event.pressed=false
 Input.parse_input_event(event)
func gap(side: int) -> void:
 var origin: Vector2=ForestLayout.ORIGINS[1]
 hero.reset_to(origin+Vector2(50 if side>0 else 340,300))
 hero.facing=side
 hero.dash_cooldown_remaining=0
 await tick(6)
 var move: String="move_right" if side>0 else "move_left"
 Input.action_press(move)
 var launched:=false
 var jumped:=false
 var landed:=false
 for i in range(200):
  var x: float=hero.global_position.x-origin.x
  if not launched and ((side>0 and x>=140) or (side<0 and x<=315)) and hero.is_on_floor():
   await press_shift()
   launched=hero.dash_remaining>0
  if launched and not jumped and hero.dash_remaining<=0 and (hero.is_on_floor() or hero._coyote_remaining>0):
   Input.action_press("jump")
   jumped=true
  elif jumped: Input.action_release("jump")
  await tick()
  x=hero.global_position.x-origin.x
  if jumped and hero.is_on_floor() and ((side>0 and x>=260) or (side<0 and x<=200)):
   landed=true
   break
  if hero.global_position.y>350: break
 release_inputs()
 check(launched,"actual Shift activates grounded dash side=%d" % side)
 check(jumped and landed,"dash then jump clears 60px gap side=%d" % side)
func run() -> void:
 demo=load("res://scenes/forest/forest_pilots.tscn").instantiate()
 root.add_child(demo)
 while demo.busy or demo.current_room<0: await tick()
 hero=demo.hero
 await tick(5)
 hero.reset_to(Vector2(910,300))
 await tick(5)
 Input.action_press("move_right")
 for i in range(120):
  await tick()
  if demo.current_room==1: break
 release_inputs()
 while demo.busy: await tick()
 check(demo.current_room==1,"walking crosses first sector boundary")
 await gap(1)
 await gap(-1)
 hero.reset_to(ForestLayout.ORIGINS[1]+Vector2(48,300))
 hero.facing=-1
 await tick(6)
 Input.action_press("move_left")
 for i in range(120):
  await tick()
  if demo.current_room==0: break
 release_inputs()
 while demo.busy: await tick()
 check(demo.current_room==0,"walking crosses boundary in reverse")
 print("M6 recovery real inputs checks=",checks," failures=",failures)
 demo.queue_free()
 await tick(2)
 quit(1 if failures else 0)
