extends SceneTree
var fails: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame; await process_frame
func run() -> void:
 var scene: Node=load("res://scenes/dev/m5g_boss_playtest.tscn").instantiate()
 root.add_child(scene)
 current_scene=scene
 while scene.busy or not scene.arena_active: await tick()
 var old: int=scene.get_instance_id()
 var ev: InputEventKey=InputEventKey.new(); ev.keycode=KEY_F7; ev.pressed=true; Input.parse_input_event(ev)
 await tick()
 ev=InputEventKey.new(); ev.keycode=KEY_F7; ev.pressed=false; Input.parse_input_event(ev)
 for i: int in range(900):
  await tick()
  if is_instance_valid(current_scene) and current_scene.get_instance_id()!=old and current_scene.arena_active and not current_scene.busy: break
 var ok: bool=is_instance_valid(current_scene) and current_scene.get_instance_id()!=old and current_scene.arena_active and not current_scene.hero.dash_unlocked and current_scene.room.boss.health==10
 print(("PASS " if ok else "FAIL ")+"F7 retorna ao Abade vivo no perfil ainda não vencido")
 quit(0 if ok else 1)
