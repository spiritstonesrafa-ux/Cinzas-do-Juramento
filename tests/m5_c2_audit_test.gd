extends "res://tests/m5_c2_hazards_test.gd"
## Additional probes use the actual physics loop and loaded demonstration.
var health_callbacks: int=0
func on_health_changed(_current: int,_maximum: int) -> void:
 health_callbacks+=1
func wait_state(hazard: DamageSource, desired: int, limit: int=400) -> bool:
 for tick in range(limit):
  if int(hazard.get("state"))==desired: return true
  await frames(1)
 return false
func overlaps_at(hazard: DamageSource, offset: Vector2) -> bool:
 var player: KnightController=demo.hero
 var q: PhysicsShapeQueryParameters2D=PhysicsShapeQueryParameters2D.new()
 q.shape=player.hurtbox.collision_shape.shape
 q.transform=Transform2D(0.0,hazard.get("shape").global_position+offset)
 q.collide_with_areas=true
 q.collide_with_bodies=false
 q.collision_mask=32
 for hit in player.get_world_2d().direct_space_state.intersect_shape(q):
  if hit.collider==hazard: return true
 return false
func run() -> void:
 change_scene_to_file("res://scenes/abbey/abbey_hazards_demo.tscn")
 await frames(30)
 demo=current_scene
 await demo.switch_room(2)
 var trap: DamageSource=demo.hazard
 var h: KnightController=demo.hero
 h.reset_to(trap.global_position+Vector2(-200,0))
 await frames(120)
 check(int(trap.get("state"))==0,"comporta aguarda Aren fora do sensor após cooldown")
 h.reset_to(trap.global_position+Vector2(-45,0))
 check(await wait_state(trap,1,10),"comporta inicia aviso ao entrar no sensor")
 for id in range(1,4):
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-45,0))
  var warning_frames: int=0
  var all_off: bool=true
  for tick in range(400):
   await frames(1)
   var state: int=int(trap.get("state"))
   var col: CollisionShape2D=trap.get("shape")
   if state==0 or state==1: all_off=all_off and col.disabled
   if state==1: warning_frames+=1
   if state==2: break
  check(warning_frames>=47 and warning_frames<=49,"aviso real de 0,8s com tolerância de 1 frame %d" % id)
  check(all_off and int(trap.get("state"))==2 and not trap.get("shape").disabled,"primeiro frame ativo coincide com hitbox %d" % id)
  var rect: RectangleShape2D=trap.get("shape").shape
  var half: Vector2=rect.size/2
  check(overlaps_at(trap,Vector2.ZERO),"centro físico %d" % id)
  check(overlaps_at(trap,Vector2(-half.x-4,0)) and overlaps_at(trap,Vector2(half.x+4,0)),"margens horizontais internas por hurtbox completa %d" % id)
  check(not overlaps_at(trap,Vector2(-half.x-8,0)) and not overlaps_at(trap,Vector2(half.x+8,0)),"margens horizontais externas por hurtbox completa %d" % id)
  check(overlaps_at(trap,Vector2(0,-half.y-10)) and overlaps_at(trap,Vector2(0,half.y+10)),"limites verticais internos %d" % id)
  check(not overlaps_at(trap,Vector2(0,-half.y-14)) and not overlaps_at(trap,Vector2(0,half.y+14)),"limites verticais externos %d" % id)
  var initial_x: float=trap.get("shape").position.x
  var active_frames: int=0
  while int(trap.get("state"))==2 and active_frames<100:
   await frames(1)
   if int(trap.get("state"))==2:
    check(not trap.get("shape").disabled,"hitbox acompanha frame ativo %d/%d" % [id,active_frames])
   active_frames+=1
  check(int(trap.get("state"))==3 and trap.get("shape").disabled,"primeiro frame de recuperação sem hitbox %d" % id)
  if id==1: check(trap.get("shape").position.x>initial_x+40,"pêndulo desloca hitbox durante varredura")
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2([-70,-35,-25][id-1],0))
  await frames(4)
  check(await wait_state(trap,2),"ativação real para travessia arriscada %d" % id)
  Input.action_press("move_right")
  var was_hurt: bool=false
  for tick in range(100):
   await frames(1)
   was_hurt=was_hurt or h.survival.current_health<5
   if int(trap.get("state"))==3: break
  Input.action_release("move_right")
  check(was_hurt,"atravessar perigo ativo causa dano real %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-65,0))
  await frames(5)
  Input.action_press("jump")
  await frames(1)
  Input.action_release("jump")
  await frames(4)
  check(h.velocity.y<0,"salto em subida real %d" % id)
  await frames(15)
  check(h.global_position.y<trap.global_position.y-30,"salto próximo do ápice %d" % id)
  await frames(15)
  check(h.velocity.y>0,"salto em descida real %d" % id)
  await frames(20)
  check(h.is_on_floor(),"aterrissagem real %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(38 if id==3 else 0,0))
  await frames(5)
  check(await wait_state(trap,1),"aviso natural antes de salto com perigo %d" % id)
  while int(trap.get("state"))==1 and float(trap.get("remaining"))>0.25: await frames(1)
  Input.action_press("jump")
  await frames(1)
  Input.action_release("jump")
  var rose: bool=false
  var fell: bool=false
  var active_in_jump: bool=false
  for tick in range(65):
   await frames(1)
   rose=rose or h.velocity.y<0
   fell=fell or h.velocity.y>0
   active_in_jump=active_in_jump or int(trap.get("state"))==2
  print("JUMP_HAZARD family=",id," health=",h.survival.current_health," contacts=",trap.get("contacts")," landed=",h.is_on_floor())
  check(rose and fell and active_in_jump and h.is_on_floor(),"salto físico transcorre durante ativação %d" % id)
  check(h.survival.current_health in [4,5] and (h.survival.current_health==5 or trap.get("contacts").has(h.get_instance_id())),"dano no salto só com contato real %d" % id)
  for desired in [0,1,3]:
   await demo.switch_room(id)
   trap=demo.hazard
   h.survival.restore()
   h.reset_to(trap.global_position+Vector2(-45,0))
   var reached: bool=await wait_state(trap,desired)
   check(reached,"estado natural antes de descarregar %d/%d" % [id,desired])
   var old: WeakRef=weakref(trap)
   var old_shape: WeakRef=weakref(trap.get("shape"))
   await demo.switch_room((id+1)%4)
   await frames(5)
   check(old.get_ref()==null and old_shape.get_ref()==null,"perigo e hitbox liberados %d/%d" % [id,desired])
   await demo.switch_room(id)
   check(int(demo.hazard.get("state"))==0 and demo.get_node("Rooms").get_child_count()==1,"reentrada segura sem duplicação %d/%d" % [id,desired])
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(demo.checkpoints[id].global_position)
  await frames(6)
  check(h.active_checkpoint==demo.checkpoints[id],"checkpoint para morte em seguro %d" % id)
  h.receive_damage(999)
  await frames(65)
  check(not h.survival.is_dead and h.survival.current_health==5 and demo.current_room==id and int(demo.hazard.get("state"))==0,"morte em seguro retorna sem perigo imediato %d" % id)
  var connections_before: int=h.survival.respawn_requested.get_connections().size()
  await demo.switch_room(id)
  await demo.switch_room(id)
  check(h.survival.respawn_requested.get_connections().size()==connections_before,"reentradas não duplicam sinal de respawn %d" % id)
 for id in range(1,4):
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-75,0))
  health_callbacks=0
  h.survival.health_changed.connect(on_health_changed)
  h.receive_damage(1)
  var reached_active: bool=await wait_state(trap,2)
  var callbacks_before: int=health_callbacks
  var released: WeakRef=weakref(trap)
  await demo.switch_room((id+1)%4)
  await frames(70)
  check(reached_active and callbacks_before==1 and health_callbacks==1 and released.get_ref()==null,"sem callback tardio após descarga ativa %d" % id)
  h.survival.health_changed.disconnect(on_health_changed)
 for id in range(1,4):
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-45,0))
  var warned: bool=await wait_state(trap,1)
  var old_scene: WeakRef=weakref(demo)
  var old_hazard: WeakRef=weakref(trap)
  var event: InputEventKey=InputEventKey.new()
  event.keycode=KEY_F7
  event.pressed=true
  Input.parse_input_event(event)
  await frames(35)
  demo=current_scene
  h=demo.hero
  check(warned and old_scene.get_ref()==null and old_hazard.get_ref()==null and demo.current_room==0,"F7 durante aviso libera estação %d" % id)
 h.survival.restore()
 h.receive_damage(999)
 var previous_scene: WeakRef=weakref(demo)
 var death_event: InputEventKey=InputEventKey.new()
 death_event.keycode=KEY_F7
 death_event.pressed=true
 Input.parse_input_event(death_event)
 await frames(35)
 demo=current_scene
 check(previous_scene.get_ref()==null and demo.hero.survival.current_health==5 and not demo.hero.survival.is_dead,"F7 durante morte retorna seguro")
 demo.queue_free()
 await frames(5)
 print("M5-C2 AUDIT checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
