extends SceneTree
var checks: int=0
var failures: int=0
var demo: Node2D
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func check(value: bool, label: String) -> void:
 checks+=1
 if value: print("PASS: ",label)
 else:
  failures+=1
  push_error("FAIL: "+label)
func run() -> void:
 change_scene_to_file("res://scenes/abbey/abbey_hazards_demo.tscn")
 await frames(30)
 demo=current_scene
 check(demo.current_room==0 and demo.hazard is AbbeyCounterweight,"prensa homologada instanciada")
 for id in range(1,4):
  await demo.switch_room(id)
  var h: KnightController=demo.hero
  var trap: DamageSource=demo.hazard
  check(int(trap.get("family"))==id-1,"família %d instanciada" % id)
  check(int(trap.get("state"))==0,"estado inicial seguro %d" % id)
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(38 if id==3 else 0,0))
  await frames(5)
  var saw_warning: bool=false
  var saw_active: bool=false
  var saw_recover: bool=false
  var warning_frames: int=0
  var active_frames: int=0
  for tick in range(400):
   await frames(1)
   var state: int=int(trap.get("state"))
   if state==1:
    saw_warning=true
    warning_frames+=1
   if state==2:
    saw_active=true
    active_frames+=1
   if state==3: saw_recover=true
   if saw_recover: break
  check(saw_warning and warning_frames>=35,"aviso >= 0,6s %d" % id)
  check(saw_active and saw_recover,"ativação e recuperação %d" % id)
  var expected_frames: int=[72,30,42][id-1]
  check(absi(active_frames-expected_frames)<=2,"duração ativa medida %d" % id)
  check(h.survival.current_health<5,"colisão causa dano real %d" % id)
  var shape: CollisionShape2D=trap.get("shape")
  check(shape.disabled,"colisão desativada na recuperação %d" % id)
  var old: WeakRef=weakref(trap)
  await demo.switch_room((id+1)%4)
  await frames(4)
  check(old.get_ref()==null,"perigo liberado ao descarregar %d" % id)
  await demo.switch_room(id)
  check(int(demo.hazard.get("state"))==0,"reentrada reinicia seguro %d" % id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-75,0))
  await frames(3)
  Input.action_press("move_right")
  await frames(85)
  Input.action_release("move_right")
  check(h.global_position.x>trap.global_position.x+45 and h.survival.current_health==5,"travessia segura por movimento real %d" % id)
  await demo.switch_room(id,true)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(75,0))
  await frames(3)
  Input.action_press("move_left")
  await frames(85)
  Input.action_release("move_left")
  check(h.global_position.x<trap.global_position.x-45 and h.survival.current_health==5,"retorno seguro por movimento real %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-75,0))
  var active_seen: bool=false
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==2:
    active_seen=true
    break
  check(active_seen and h.survival.current_health==5,"fora da área durante ativação %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  var outside_x: float=[50.0,18.0,66.0][id-1]
  h.reset_to(trap.global_position+Vector2(outside_x,0))
  var saw_boundary_active: bool=false
  for tick in range(400):
   await frames(1)
   saw_boundary_active=saw_boundary_active or int(trap.get("state"))==2
   if saw_boundary_active and int(trap.get("state"))==3: break
  check(saw_boundary_active and h.survival.current_health==5,"hurtbox imediatamente fora do limite %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(38 if id==3 else 0,0))
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==1 and float(trap.get("remaining"))<0.05: break
  h.receive_damage(1)
  var contact_seen: bool=false
  for tick in range(65):
   await frames(1)
   if trap.get("contacts").size()>0:
    contact_seen=true
    break
  check(contact_seen and h.survival.current_health==4,"contato respeita invulnerabilidade %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-65,0))
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==1: break
  var x_before: float=h.global_position.x
  Input.action_press("move_left")
  var active_during_retreat: bool=false
  for tick in range(100):
   await frames(1)
   active_during_retreat=active_during_retreat or int(trap.get("state"))==2
   if active_during_retreat and int(trap.get("state"))==3: break
  Input.action_release("move_left")
  check(active_during_retreat and h.global_position.x<x_before-15 and h.survival.current_health==5,"recuo físico durante aviso evita perigo %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.reset_to(trap.global_position+Vector2(-45,0))
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==2: break
  var active_old: WeakRef=weakref(trap)
  var active_shape: WeakRef=weakref(trap.get("shape"))
  await demo.switch_room((id+1)%4)
  await frames(4)
  check(active_old.get_ref()==null and active_shape.get_ref()==null,"descarrega perigo e hitbox ativos %d" % id)
  await demo.switch_room(id)
  trap=demo.hazard
  h.survival.restore()
  h.reset_to(trap.global_position+Vector2(-45,0))
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==2: break
  trap.call("reset_hazard")
  await frames(2)
  check(int(trap.get("state"))==0 and trap.get("shape").disabled,"reset direto desarma perigo ativo %d" % id)
 for id in range(1,4):
  for requested in [1,2,3]:
   await demo.switch_room(id)
   var h: KnightController=demo.hero
   h.survival.restore()
   h.reset_to(demo.checkpoints[id].global_position)
   await frames(6)
   check(h.active_checkpoint==demo.checkpoints[id],"checkpoint da estação %d" % id)
   var trap: DamageSource=demo.hazard
   h.reset_to(trap.global_position+Vector2(-45,0))
   var reached: bool=false
   for tick in range(400):
    await frames(1)
    if int(trap.get("state"))==requested:
     reached=true
     break
   check(reached,"estado %d alcançado em %d" % [requested,id])
   h.survival.restore()
   h.receive_damage(999)
   await frames(2)
   check(trap.process_mode==Node.PROCESS_MODE_DISABLED,"desarma ao morrer %d/%d" % [id,requested])
   await frames(60)
   check(not h.survival.is_dead and h.survival.current_health==5 and demo.current_room==id,"respawn da estação %d/%d" % [id,requested])
   check(demo.hazard!=trap and int(demo.hazard.get("state"))==0,"nova instância segura %d/%d" % [id,requested])
 demo.hero.survival.restore()
 demo.hero.receive_damage(999)
 await frames(90)
 check(not demo.hero.survival.is_dead and demo.hero.survival.current_health==5,"morte e respawn")
 var old_scene: WeakRef=weakref(demo)
 var event: InputEventKey=InputEventKey.new()
 event.keycode=KEY_F7
 event.pressed=true
 Input.parse_input_event(event)
 await frames(35)
 demo=current_scene
 check(old_scene.get_ref()==null and demo.current_room==0,"F7 reinicia demonstração")
 for id in range(1,4):
  await demo.switch_room(id)
  var trap: DamageSource=demo.hazard
  demo.hero.reset_to(trap.global_position+Vector2(-45,0))
  var found_active: bool=false
  for tick in range(400):
   await frames(1)
   if int(trap.get("state"))==2:
    found_active=true
    break
  var old_hazard: WeakRef=weakref(trap)
  old_scene=weakref(demo)
  event=InputEventKey.new()
  event.keycode=KEY_F7
  event.pressed=true
  Input.parse_input_event(event)
  await frames(35)
  demo=current_scene
  check(found_active and old_hazard.get_ref()==null and old_scene.get_ref()==null and demo.current_room==0 and demo.hero.survival.current_health==5,"F7 durante perigo ativo limpa estação %d" % id)
 for attempt in range(3):
  old_scene=weakref(demo)
  event=InputEventKey.new()
  event.keycode=KEY_F7
  event.pressed=true
  Input.parse_input_event(event)
  await frames(35)
  demo=current_scene
  check(old_scene.get_ref()==null and demo.current_room==0,"F7 consecutivo %d" % attempt)
 for id in range(3):
  await demo.switch_room(id)
  demo.hero.reset_to(Vector2(id*1200+940,300))
  demo.hero.facing=1
  Input.action_press("move_right")
  await frames(20)
  Input.action_release("move_right")
  check(demo.current_room==id+1 and not demo.busy,"travessia à direita %d" % id)
  demo.hero.reset_to(Vector2((id+1)*1200+20,300))
  demo.hero.facing=-1
  Input.action_press("move_left")
  await frames(20)
  Input.action_release("move_left")
  check(demo.current_room==id and not demo.busy,"retorno à esquerda %d" % id)
 for id in range(1,4):
  await demo.switch_room(id)
  var trap: DamageSource=demo.hazard
  demo.hero.survival.restore()
  demo.hero.reset_to(trap.global_position+Vector2(-45,0))
  await frames(700)
  check(int(trap.get("cycles"))>=2,"dois ciclos automáticos %d" % id)
 var counts: Array[float]=[]
 for i in range(15):
  await demo.switch_room(1)
  await frames(3)
  if i>=5: counts.append(Performance.get_monitor(Performance.OBJECT_COUNT))
 print("OBJECT_SAMPLES ",counts)
 check(counts[-1]<=counts[0]+3,"reinserções não acumulam objetos no ensaio")
 demo.queue_free()
 await frames(5)
 print("M5-C2 checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
