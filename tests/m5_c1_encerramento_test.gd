extends "res://tests/m5_c1_audit_test.gd"
var callbacks: int=0
func observed_hit() -> void: callbacks+=1
func ready_room(id: int) -> void:
 await demo.switch_room(id,false,true)
 var e: ChainedMonk=demo.enemy
 var h: KnightController=demo.hero
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(-40,0))
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 await frames(5)
func wait_state(target_state: int, limit: int=130) -> bool:
 for i in range(limit):
  if demo.enemy.state==target_state: return true
  await frames(1)
 return false
func run() -> void:
 change_scene_to_file("res://scenes/abbey/abbey_enemies_demo.tscn")
 await frames(30)
 demo=current_scene
 await ready_room(1)
 var e: ChainedMonk=demo.enemy
 var h: KnightController=demo.hero
 h.reset_to(e.global_position+Vector2(-100,0))
 await frames(3)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.30)
 await frames(22)
 check(h.survival.current_health==5,"Penitente: fora de alcance não recebe dano")
 await ready_room(1)
 e=demo.enemy
 h.reset_to(e.global_position+Vector2(-30,0))
 await frames(3)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.30)
 await frames(5)
 check(h.survival.current_health==5,"Penitente: atrás do golpe não recebe dano")
 await ready_room(1)
 e=demo.enemy
 h.reset_to(e.global_position+Vector2(-30,0))
 h.survival.restore()
 await frames(3)
 h.receive_damage(1)
 e.facing=-1
 e.set_state(ChainedMonk.State.ACTIVE,0.30)
 await frames(5)
 check(h.survival.current_health==4,"Penitente respeita invulnerabilidade durante investida")
 await ready_room(1)
 e=demo.enemy
 check(await wait_state(ChainedMonk.State.WARNING),"Penitente: aviso antes do cruzamento")
 Input.action_press("move_right")
 var crossed: bool=false
 for i in range(95):
  await frames(1)
  crossed=crossed or h.global_position.x>e.global_position.x+8
  if e.state==ChainedMonk.State.RECOVER: break
 Input.action_release("move_right")
 check(crossed and h.survival.current_health==5,"Aren cruza fisicamente a trajetória durante aviso e evita investida")
 await ready_room(1)
 e=demo.enemy
 check(await wait_state(ChainedMonk.State.RECOVER),"Penitente alcança recuperação sem fixture")
 var before_hp: int=e.current_health
 Input.action_press("move_right")
 for i in range(30):
  if e.global_position.x-h.global_position.x<29: break
  await frames(1)
 h.facing=1
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 var hit_during_recovery: bool=false
 for i in range(20):
  var previous_state: int=e.state
  await frames(1)
  if e.current_health<before_hp and previous_state==ChainedMonk.State.RECOVER:
   hit_during_recovery=true
 Input.action_release("move_right")
 print("COUNTER_PROBE enemy=",e.global_position," hero=",h.global_position," health=",e.current_health," state=",e.state," hero_dead=",h.survival.is_dead)
 check(hit_during_recovery,"espada real contra-ataca durante recuperação")
 await ready_room(1)
 e=demo.enemy
 h.reset_to(e.global_position+Vector2(120,0))
 e.global_position.x=e.origin.x+54
 await frames(4)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.30)
 await frames(23)
 check(e.global_position.y<278 and e.global_position.x<e.origin.x+64 and e.state==ChainedMonk.State.RECOVER,"Penitente: investida na borda recupera sem cair")
 await ready_room(2)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(30,0))
 await frames(3)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 var active_frames: int=0
 while e.state==ChainedMonk.State.ACTIVE and active_frames<30:
  await frames(1)
  if e.state==ChainedMonk.State.ACTIVE:
   check(e.source.active and not e.source.shape.disabled,"Vigia: hitbox ativa em frame %d" % active_frames)
  active_frames+=1
 check(active_frames>2 and e.state==ChainedMonk.State.RECOVER and not e.source.active,"Vigia: último frame e recuperação desativam hitbox")
 check(h.survival.current_health==4,"Vigia: um único dano no ciclo")
 h.survival.restore()
 await frames(12)
 check(h.survival.current_health==5 and not e.source.active,"Vigia: recuperação não causa dano")
 e.set_state(ChainedMonk.State.DEAD)
 h.survival.restore()
 await frames(12)
 check(h.survival.current_health==5 and not e.source.active,"Vigia: derrota impede dano com Aren na área")
 await ready_room(1)
 e=demo.enemy
 h.reset_to(e.global_position+Vector2(-24,0))
 h.facing=1
 await frames(3)
 e.set_state(ChainedMonk.State.RECOVER,2.0)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 var hurt_reached: bool=await wait_state(ChainedMonk.State.HURT,20)
 check(hurt_reached,"espada causa reação real do Penitente")
 var hurt_ref: WeakRef=weakref(e)
 await demo.switch_room(2,false,true)
 await frames(5)
 check(hurt_ref.get_ref()==null,"Penitente liberado durante reação real")
 # Actual warning -> active -> recovery; each state is reached by the real loop.
 for id in range(3):
  for desired in [ChainedMonk.State.WARNING,ChainedMonk.State.ACTIVE,ChainedMonk.State.RECOVER]:
   await ready_room(id)
   e=demo.enemy
   var reached: bool=await wait_state(desired)
   check(reached,"estado natural %d inimigo %d" % [desired,id])
   if not reached: continue
   var old_enemy: WeakRef=weakref(e)
   var old_source: WeakRef=weakref(e.source)
   var old_receiver: WeakRef=weakref(e.receiver)
   var missile: WeakRef=weakref(e.get("missile")) if is_instance_valid(e.get("missile")) else null
   var previous_callbacks: int=callbacks
   e.receiver.hit_received.connect(observed_hit)
   if desired!=ChainedMonk.State.RECOVER:
    e.receiver.hit_received.emit()
    check(callbacks==previous_callbacks+1 and e.state==desired,"callback único preserva estado antes da descarga %d/%d" % [id,desired])
   else:
    check(e.state==desired and e.receiver.hit_received.get_connections().size()==2,"recuperação preservada antes da descarga %d" % id)
   var callbacks_at_unload: int=callbacks
   await demo.switch_room((id+1)%3,false,true)
   await frames(5)
   check(old_enemy.get_ref()==null and old_source.get_ref()==null and old_receiver.get_ref()==null,"estado natural descarregado %d/%d" % [id,desired])
   check(missile==null or missile.get_ref()==null,"projétil liberado %d/%d" % [id,desired])
   check(callbacks==callbacks_at_unload and demo.get_node("Rooms").get_child_count()==1,"sem callback tardio nem duplicação %d/%d" % [id,desired])
   check(demo.enemy.receiver.hit_received.get_connections().size()==1,"reentrada tem conexão única %d/%d" % [id,desired])
 demo.queue_free()
 await frames(5)
 print("ENCERRAMENTO checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
