extends SceneTree
## Isolated new-session fixture; seed unlock state to test the actual F7 reload.
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var scene: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(scene)
 current_scene=scene
 while scene.busy or scene.current_room<0: await process_frame
 scene.unlocked_shortcuts={0:true,1:true,2:true}
 var old_id: int=scene.get_instance_id()
 var ev: InputEventKey=InputEventKey.new()
 ev.keycode=KEY_F7
 ev.pressed=true
 Input.parse_input_event(ev)
 await process_frame
 ev=InputEventKey.new()
 ev.keycode=KEY_F7
 ev.pressed=false
 Input.parse_input_event(ev)
 for n: int in range(300):
  await process_frame
  if is_instance_valid(current_scene) and current_scene.get_instance_id()!=old_id and current_scene.current_room>=0 and not current_scene.busy: break
 var ok: bool=is_instance_valid(current_scene) and current_scene.get_instance_id()!=old_id and current_scene.unlocked_shortcuts.is_empty()
 for frame: int in range(240): await process_frame
 print("PASS F7 creates new session and closes seeded shortcuts" if ok else "FAIL F7 new session")
 quit(0 if ok else 1)
