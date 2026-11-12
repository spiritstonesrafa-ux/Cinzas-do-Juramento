extends SceneTree
var checks=0
var failures=0
func check(value: bool,label: String) -> void:
 checks+=1
 print(("PASS " if value else "FAIL ")+label)
 if not value:failures+=1
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var isolated=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolated.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolated+"/"):quit(2);return
 var world=Node2D.new();root.add_child(world)
 var hero: KnightController=load("res://scenes/player/knight.tscn").instantiate();world.add_child(hero);hero.position=Vector2(float(OS.get_environment("GUARDIAN_SUPER_START_X")) if OS.has_environment("GUARDIAN_SUPER_START_X") else 60.0,156)
 var arena=load("res://scenes/boss/guardian_arena.tscn").instantiate();world.add_child(arena)
 var boss: OathGuardian=arena.get_node("Guardian");boss.begin(hero);boss.position=Vector2(160,156);boss.phase=2;boss._start_super()
 check(boss.state==boss.State.SUPER_WARN and not boss.attack_source.active,"aviso sem hitbox")
 var saw_active=false; var saw_second=false; var saw_recover=false; var jumps=0; var ready_jump=true; var was_airborne=false
 for i in range(380):
  Input.action_release("jump")
  if not hero.is_on_floor():was_airborne=true
  if was_airborne and hero.is_on_floor():ready_jump=true;was_airborne=false
  if ready_jump and boss.state==boss.State.SUPER_WARN and boss.remaining<0.25 and absf(hero.global_position.x-boss.global_position.x)<50 and hero.is_on_floor():
   Input.action_press("jump");jumps+=1;ready_jump=false
  if ready_jump and boss.state==boss.State.SUPER_ACTIVE and not boss.super_second_sent and boss.remaining<2.0 and absf(hero.global_position.x-boss.global_position.x)<50 and hero.is_on_floor():
   Input.action_press("jump");jumps+=1;ready_jump=false
  for wave in boss.super_waves:
   if not is_instance_valid(wave):continue
   var delta_x: float=hero.global_position.x-wave.global_position.x
   if ready_jump and delta_x*wave.direction>0 and absf(delta_x)<45 and hero.is_on_floor():
    Input.action_press("jump");jumps+=1;ready_jump=false;break
  await physics_frame
  await process_frame
  saw_active=saw_active or boss.state==boss.State.SUPER_ACTIVE
  saw_second=saw_second or boss.super_second_sent
  saw_recover=saw_recover or boss.state==boss.State.SUPER_RECOVER
  if saw_recover:break
 Input.action_release("jump")
 check(saw_active and saw_second and saw_recover,"duas ondas e recuperação finita")
 check(jumps>=2 and not hero.dash_unlocked and hero.survival.current_health==5,"duas ondas evitadas com salto normal")
 check(boss.super_used,"especial limitado a uma vez")
 boss.reset_encounter();check(boss.super_waves.is_empty() and not boss.super_used,"reset limpa fontes e especial")
 boss.begin(hero);boss.phase=2;boss._set_state(boss.State.PURSUIT)
 await physics_frame
 await physics_frame
 check(boss.state==boss.State.SUPER_WARN and boss.super_used,"fase dois aciona especial pela IA")
 boss._set_state(boss.State.SUPER_ACTIVE,2.8);boss._spawn_super_pair();boss.current_health=1;boss.receive_hit()
 check(boss.state==boss.State.DEFEATED and boss.super_waves.is_empty(),"derrota limpa as ondas imediatamente")
 print("SUPER checks=",checks," failures=",failures," jumps=",jumps," hp=",hero.survival.current_health," pos=",hero.global_position)
 world.queue_free();await process_frame
 quit(1 if failures else 0)
