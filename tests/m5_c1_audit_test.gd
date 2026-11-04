extends SceneTree
var checks: int=0
var failures: int=0
var demo: Node2D
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func check(ok: bool, what: String) -> void:
 checks+=1
 if ok: print("PASS: ",what)
 else:
  failures+=1
  push_error("FAIL: "+what)
func attack_at(dx: float, dy: float, should_hit: bool, label: String, direction: int=1) -> void:
 var e: ChainedMonk=demo.enemy
 var h: KnightController=demo.hero
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(dx,dy))
 await frames(3)
 e.facing=direction
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 await frames(4)
 check((h.survival.current_health<5)==should_hit,label)
 e.set_state(ChainedMonk.State.RECOVER,1.0)
 await frames(2)
func restart_probe(label: String) -> void:
 var old: WeakRef=weakref(demo)
 var event: InputEventKey=InputEventKey.new()
 event.keycode=KEY_F7
 event.pressed=true
 Input.parse_input_event(event)
 await frames(35)
 demo=current_scene
 check(old.get_ref()==null and demo.current_room==0 and demo.hero.survival.current_health==5 and demo.get_node("Rooms").get_child_count()==1,label)
func run() -> void:
 change_scene_to_file("res://scenes/abbey/abbey_enemies_demo.tscn")
 await frames(25)
 demo=current_scene
 await demo.switch_room(2)
 var e: ChainedMonk=demo.enemy
 var h: KnightController=demo.hero
 var shape: RectangleShape2D=e.source.shape.shape
 check(shape.size==Vector2(44,12),"Vigia forma 44x12")
 await attack_at(30,0,true,"Vigia centro frontal")
 await attack_at(54,0,true,"Vigia sobreposição perto da borda externa")
 await attack_at(58,0,false,"Vigia fora da borda considerando hurtbox de Aren")
 await attack_at(-8,0,false,"Vigia não atinge atrás")
 await attack_at(30,-40,false,"Vigia não atinge acima")
 await attack_at(-54,0,true,"Vigia esquerda sobrepõe hurtbox",-1)
 await attack_at(-58,0,false,"Vigia esquerda fora da borda",-1)
 await attack_at(8,0,false,"Vigia esquerda não atinge atrás",-1)
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(59,0))
 await frames(3)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 Input.action_press("move_left")
 await frames(6)
 Input.action_release("move_left")
 check(h.survival.current_health<5,"entrar andando na área ativa causa dano")
 e.set_state(ChainedMonk.State.RECOVER,1.0)
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(54,0))
 Input.action_press("move_right")
 await frames(5)
 Input.action_release("move_right")
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 await frames(4)
 check(h.survival.current_health==5,"sair andando antes da ativação evita dano")
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(30,0))
 await frames(3)
 h.receive_damage(1)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 await frames(4)
 check(h.survival.current_health==4,"Vigia respeita invulnerabilidade")
 await frames(16)
 check(not e.source.active,"hitbox desativa após ataque")
 await demo.switch_room(0,false,true)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(75,0))
 await frames(4)
 e.facing=1
 e.set_state(ChainedMonk.State.WARNING,0.20)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(45)
 check(h.survival.current_health==5,"salto real evita projétil")
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(75,0))
 await frames(4)
 e.facing=1
 e.set_state(ChainedMonk.State.WARNING,0.20)
 Input.action_press("move_right")
 await frames(45)
 Input.action_release("move_right")
 check(h.survival.current_health==5,"recuo real evita projétil")
 await demo.switch_room(0,false,true)
 e=demo.enemy
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(80,0))
 var wall: StaticBody2D=StaticBody2D.new()
 wall.collision_layer=1
 var wall_shape: CollisionShape2D=CollisionShape2D.new()
 var wall_rect: RectangleShape2D=RectangleShape2D.new()
 wall_rect.size=Vector2(6,60)
 wall_shape.shape=wall_rect
 wall.add_child(wall_shape)
 demo.room.add_child(wall)
 wall.global_position=e.global_position+Vector2(34,-20)
 await frames(4)
 demo.camera.position=demo.camera_target()
 demo.camera.force_update_scroll()
 check(not e.sees_target(),"parede bloqueia detecção do Acólito")
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 var blocked: Node=e.get("missile")
 await frames(30)
 print("WALL_PROBE projectile_alive=",is_instance_valid(blocked)," health=",h.survival.current_health," enemy=",e.global_position," wall=",wall.global_position," hero=",h.global_position)
 check(not is_instance_valid(blocked) and h.survival.current_health==5,"parede bloqueia e remove projétil")
 wall.queue_free()
 await frames(2)
 await demo.switch_room(0,false,true)
 e=demo.enemy
 h.reset_to(e.global_position+Vector2(-130,0))
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 var expired: Node=e.get("missile")
 await frames(110)
 check(not is_instance_valid(expired),"projétil expira sem contato")
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.18)
 await frames(2)
 var projectile: Node=e.get("missile")
 check(is_instance_valid(projectile),"projétil ativo antes do reinício")
 var old: WeakRef=weakref(demo)
 var event: InputEventKey=InputEventKey.new()
 event.keycode=KEY_F7
 event.pressed=true
 Input.parse_input_event(event)
 await frames(35)
 demo=current_scene
 check(old.get_ref()==null,"F7 libera cena anterior")
 check(demo!=null and demo.current_room==0 and demo.hero.survival.current_health==5,"F7 restaura sala e vida")
 check(not is_instance_valid(projectile),"F7 libera projétil")
 check(demo.get_node("Rooms").get_child_count()==1,"F7 não duplica sala")
 await demo.switch_room(1,false,true)
 e=demo.enemy
 h=demo.hero
 h.survival.restore()
 h.reset_to(e.global_position+Vector2(40,0))
 wall=StaticBody2D.new()
 wall.collision_layer=1
 wall_shape=CollisionShape2D.new()
 wall_rect=RectangleShape2D.new()
 wall_rect.size=Vector2(6,48)
 wall_shape.shape=wall_rect
 wall.add_child(wall_shape)
 demo.room.add_child(wall)
 wall.global_position=e.global_position+Vector2(22,-20)
 await frames(4)
 e.facing=1
 e.set_state(ChainedMonk.State.ACTIVE,0.30)
 await frames(20)
 check(e.global_position.x<=wall.global_position.x-9 and h.survival.current_health==5,"investida respeita parede e não causa dano através dela")
 wall.queue_free()
 await frames(2)
 for id in range(3):
  await demo.switch_room(id,false,true)
  e=demo.enemy
  demo.hero.survival.restore()
  e.set_state(ChainedMonk.State.WARNING,2.0)
  await restart_probe("F7 durante preparação %d" % id)
  await demo.switch_room(id,false,true)
  e=demo.enemy
  e.set_state(ChainedMonk.State.ACTIVE,2.0)
  await restart_probe("F7 durante ataque %d" % id)
 demo.hero.receive_damage(1)
 await restart_probe("F7 depois de dano")
 demo.enemy.set_state(ChainedMonk.State.DEAD)
 await restart_probe("F7 depois da derrota")
 demo.hero.receive_damage(999)
 await restart_probe("F7 durante morte de Aren")
 for id in range(3):
  if id>0: await demo.switch_room(id,false,true)
  e=demo.enemy
  for hit in range(3 if id==2 else 2): e.receive_hit()
 await restart_probe("F7 após derrotar os três encontros")
 for i in range(12):
  var previous: WeakRef=weakref(demo.enemy)
  await demo.switch_room(i%3,false,true)
  await frames(2)
  check(previous.get_ref()==null and demo.get_node("Rooms").get_child_count()==1,"ciclo de descarga %d" % i)
 demo.queue_free()
 await frames(5)
 print("AUDIT checks=",checks," failures=",failures)
 quit(0 if failures==0 else 1)
