extends "res://tests/m5_e_lote09_shortcut_fixture.gd"
## Traverse the existing gated passages with the saved dash enabled.
func cross_passage(side: int) -> float:
 for n: int in range(240):
  if chapter.passage_index>=0 and not chapter.busy: break
  await tick()
 for n: int in range(5): await tick()
 var action: String="move_right" if side>0 else "move_left"
 Input.action_press(action)
 var event: InputEventKey=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=true;Input.parse_input_event(event)
 await tick()
 var did_dash: bool=hero.dash_remaining>0
 event=InputEventKey.new();event.keycode=KEY_SHIFT;event.pressed=false;Input.parse_input_event(event)
 print("DASH PASSAGE ",chapter.passage_index," direction=",side," active=",did_dash)
 check(did_dash,"dash ativado ao entrar no corredor")
 return await super.cross_passage(side)
