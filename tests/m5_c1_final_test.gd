extends "res://tests/m5_c1_audit_test.gd"
## Fixtures use actual scene, collision queries, movement and deferred unloading.
func run() -> void:
 change_scene_to_file("res://scenes/abbey/abbey_enemies_demo.tscn")
 await frames(30)
 demo=current_scene
 await demo.switch_room(1,false,true)
 var e: ChainedMonk=demo.enemy
 var h: KnightController=demo.hero
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(-42,0))
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 await frames(5)
 for i in range(90):
  if e.state==ChainedMonk.State.WARNING: break
  await frames(1)
 check(e.state==ChainedMonk.State.WARNING,"Penitente detecta e inicia aviso naturalmente")
 while e.state==ChainedMonk.State.WARNING and e.remaining>0.18:
  await frames(1)
 var start_y: float=h.global_position.y
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 var peak: float=start_y
 var active: bool=false
 var recovery: bool=false
 for i in range(90):
  await frames(1)
  peak=minf(peak,h.global_position.y)
  active=active or e.state==ChainedMonk.State.ACTIVE
  if e.state==ChainedMonk.State.RECOVER:
   recovery=true
   break
 check(peak<start_y-20,"Aren executa salto físico na antecipação")
 check(active and recovery,"investida e recuperação seguem aviso natural")
 check(h.survival.current_health==5,"salto real evita investida")
 await demo.switch_room(1,false,true)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(-42,0))
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 await frames(5)
 for i in range(90):
  if e.state==ChainedMonk.State.WARNING: break
  await frames(1)
 var start_x: float=h.global_position.x
 Input.action_press("move_left")
 for i in range(65):
  await frames(1)
  if e.state==ChainedMonk.State.RECOVER: break
 Input.action_release("move_left")
 check(h.global_position.x<start_x-10,"Aren recua por movimento físico")
 check(h.survival.current_health==5,"recuo evita investida")
 await demo.switch_room(1,false,true)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(-55,0))
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 await frames(5)
 start_x=h.global_position.x
 Input.action_press("move_right")
 var approached_warning: bool=false
 for i in range(40):
  await frames(1)
  approached_warning=approached_warning or e.state==ChainedMonk.State.WARNING
 Input.action_release("move_right")
 check(h.global_position.x>start_x+10 and approached_warning,"aproximação física provoca aviso do Penitente")
 await demo.switch_room(1,false,true)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(-50,0))
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 await frames(5)
 for i in range(90):
  if e.state==ChainedMonk.State.WARNING: break
  await frames(1)
 while e.state==ChainedMonk.State.WARNING and e.remaining>0.04: await frames(1)
 start_x=h.global_position.x
 Input.action_press("move_left")
 active=false
 for i in range(35):
  await frames(1)
  active=active or e.state==ChainedMonk.State.ACTIVE
  if e.state==ChainedMonk.State.RECOVER: break
 Input.action_release("move_left")
 check(active and h.global_position.x<start_x-10 and h.survival.current_health==5,"recuo continua durante investida e evita dano")
 await demo.switch_room(2,false,true)
 e=demo.enemy
 var visual_script: String=FileAccess.get_file_as_string("res://scripts/abbey/m5c1_visual.gd")
 check(visual_script.contains("6 if enemy.archetype==2 else 8"),"marcador interno cobre início da hitbox do Vigia em 6 px")
 await attack_at(1,0,true,"Vigia direita: sobreposição na borda interna")
 await attack_at(-1,0,true,"Vigia esquerda: sobreposição na borda interna",-1)
 await attack_at(-1,0,false,"Vigia direita: centro atrás não recebe dano")
 await attack_at(1,0,false,"Vigia esquerda: centro atrás não recebe dano",-1)
 for sample in [5,20,35]:
  h.survival.restore()
  h.reset_to(e.global_position+Vector2(30,0))
  e.set_state(ChainedMonk.State.WARNING,5.0)
  await frames(4)
  Input.action_press("jump")
  await frames(1)
  Input.action_release("jump")
  await frames(sample-1)
  var vertical_speed: float=h.velocity.y
  var height: float=e.global_position.y-h.global_position.y
  e.facing=1
  e.set_state(ChainedMonk.State.ACTIVE,0.18)
  await frames(3)
  print("JUMP_SAMPLE frame=",sample," vy=",vertical_speed," height=",height," health=",h.survival.current_health)
  if sample==5: check(vertical_speed<0 and h.survival.current_health==5,"Vigia: subida evita dano durante ativação")
  elif sample==20: check(height>30 and h.survival.current_health==5,"Vigia: ápice acima evita dano")
  else: check(vertical_speed>0 and h.survival.current_health<5,"Vigia: colisão real na descida baixa")
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(30,0))
 await frames(3)
 e.facing=1
 e.set_state(ChainedMonk.State.WARNING,0.20)
 await frames(8)
 check(h.survival.current_health==5 and not e.source.active,"aviso não ativa dano")
 for i in range(30):
  await frames(1)
  if e.state==ChainedMonk.State.ACTIVE: break
 check(e.state==ChainedMonk.State.ACTIVE and e.source.active,"primeiro frame ativo habilita hitbox")
 for i in range(30):
  await frames(1)
  if e.state==ChainedMonk.State.RECOVER: break
 check(e.state==ChainedMonk.State.RECOVER and not e.source.active,"primeiro frame de recuperação desabilita hitbox")
 e.set_state(ChainedMonk.State.DEAD)
 check(not e.source.active,"derrota desabilita ataque do Vigia")
 for id in range(3):
  for state in [ChainedMonk.State.PATROL,ChainedMonk.State.WARNING,ChainedMonk.State.ACTIVE,ChainedMonk.State.RECOVER,ChainedMonk.State.HURT,ChainedMonk.State.DEAD]:
   await demo.switch_room(id,false,true)
   e=demo.enemy
   e.set_state(state,5.0)
   var enemy_ref: WeakRef=weakref(e)
   var source_ref: WeakRef=weakref(e.source)
   var receiver_ref: WeakRef=weakref(e.receiver)
   var projectile_ref: WeakRef=weakref(e.get("missile")) if is_instance_valid(e.get("missile")) else null
   check(e.state==state,"estado %d confirmado inimigo %d" % [state,id])
   check(e.receiver.hit_received.get_connections().size()==1,"uma conexão de dano %d/%d" % [id,state])
   await demo.switch_room((id+1)%3,false,true)
   await frames(3)
   check(enemy_ref.get_ref()==null and source_ref.get_ref()==null and receiver_ref.get_ref()==null,"inimigo e áreas liberados %d/%d" % [id,state])
   check(projectile_ref==null or projectile_ref.get_ref()==null,"sem projétil órfão %d/%d" % [id,state])
   check(demo.get_node("Rooms").get_child_count()==1,"uma sala após troca %d/%d" % [id,state])
 await demo.switch_room(1,false,true)
 demo.enemy.receive_hit()
 check(demo.enemy.state==ChainedMonk.State.HURT,"reação a dano realmente alcançada")
 await restart_probe("F7 após reação a dano")
 for i in range(3): await restart_probe("F7 consecutivo %d" % i)
 var object_samples: Array[float]=[]
 for i in range(20):
  await demo.switch_room(0,false,true)
  await frames(3)
  if i>=5: object_samples.append(Performance.get_monitor(Performance.OBJECT_COUNT))
 print("OBJECT_SAMPLES ",object_samples)
 check(object_samples[-1]<=object_samples[0]+3,"objetos sem crescimento contínuo em 15 reinserções equivalentes")
 demo.queue_free()
 await frames(5)
 print("FINAL checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
