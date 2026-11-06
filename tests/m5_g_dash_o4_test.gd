extends "res://tests/m5_e_lote08_o4_test.gd"
## Exercise an unlocked dash at the sector start, then retain the route assertions.
var dash_tested: bool=false
func tick() -> void:
 if not dash_tested and is_instance_valid(chapter) and is_instance_valid(hero) and chapter.current_room==6 and not chapter.busy and hero.is_on_floor() and hero.dash_unlocked:
  var event: InputEventKey=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=true;Input.parse_input_event(event)
  await super.tick()
  event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=false;Input.parse_input_event(event)
  if hero.dash_remaining>0:
   dash_tested=true
   print("DASH BEFORE ROUTE active=true")
 else:
  await super.tick()
