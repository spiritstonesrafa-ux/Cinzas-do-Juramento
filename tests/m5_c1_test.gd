extends SceneTree
var checks: int=0
var failures: int=0
var demo: Node2D
func _initialize() -> void:
 run.call_deferred()
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
 demo=load("res://scenes/abbey/abbey_enemies_demo.tscn").instantiate()
 root.add_child(demo)
 await frames(30)
 check(demo.current_room==0 and not demo.busy,"demonstração carregada")
 for id in range(3):
  if id>0: await demo.switch_room(id)
  var enemy: ChainedMonk=demo.enemy
  var hero: KnightController=demo.hero
  check(enemy.get("archetype")==id,"arquétipo %d instanciado" % id)
  check(enemy.current_health==(3 if id==2 else 2),"vida inicial %d" % id)
  if id==1:
   hero.reset_to(Vector2(1200+48,300))
   await frames(180)
   check(enemy.global_position.x>=1200+672 and enemy.global_position.x<=1200+800 and absf(enemy.global_position.y-276)<1,"penitente patrulha sem cair da plataforma")
  hero.reset_to(enemy.global_position+Vector2(-40,0))
  demo.camera.position=demo.camera_target()
  demo.camera.force_update_scroll()
  await frames(4)
  check(enemy.sees_target(),"detecção %d" % id)
  var saw_warning: bool=false
  var saw_active: bool=false
  var saw_recover: bool=false
  var initial_health: int=hero.survival.current_health
  for i in range(160):
   await frames(1)
   saw_warning = saw_warning or enemy.state==ChainedMonk.State.WARNING
   saw_active = saw_active or enemy.state==ChainedMonk.State.ACTIVE
   saw_recover = saw_recover or enemy.state==ChainedMonk.State.RECOVER
   if saw_recover and hero.survival.current_health<initial_health: break
  check(saw_warning,"aviso %d" % id)
  check(saw_active,"ataque %d" % id)
  check(saw_recover,"recuperação %d" % id)
  check(hero.survival.current_health<initial_health,"dano físico real %d" % id)
  var old: ChainedMonk=enemy
  await demo.switch_room(id,false,true)
  await frames(4)
  check(not is_instance_valid(old),"descarregamento %d" % id)
  check(demo.enemy.current_health==(3 if id==2 else 2),"reinício %d" % id)
  enemy=demo.enemy
  hero.survival.restore()
  hero.reset_to(enemy.global_position+Vector2(-24,0))
  hero.facing=1
  await frames(5)
  enemy.set_state(ChainedMonk.State.RECOVER,5.0)
  for hit in range(3 if id==2 else 2):
   Input.action_press("attack")
   await frames(1)
   Input.action_release("attack")
   await frames(28)
  check(enemy.state==ChainedMonk.State.DEAD,"espada derrota inimigo %d" % id)
  check(not enemy.source.active,"ataque desligado após derrota %d" % id)
  check(not is_instance_valid(enemy.get("missile")),"projétil limpo após derrota %d" % id)
 demo.hero.survival.restore()
 demo.hero.receive_damage(999)
 await frames(80)
 check(not demo.hero.survival.is_dead and demo.hero.survival.current_health==5,"morte e respawn restauram vida")
 await demo.switch_room(0,false,true)
 demo.hero.reset_to(Vector2(940,300))
 demo.hero.facing=1
 Input.action_press("move_right")
 await frames(20)
 Input.action_release("move_right")
 check(demo.current_room==1 and not demo.busy,"travessia física para a direita")
 demo.hero.reset_to(Vector2(1200+20,300))
 demo.hero.facing=-1
 Input.action_press("move_left")
 await frames(20)
 Input.action_release("move_left")
 check(demo.current_room==0 and not demo.busy,"travessia física de volta")
 demo.queue_free()
 await frames(3)
 print("M5-C1 checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
