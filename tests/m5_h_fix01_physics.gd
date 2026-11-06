extends SceneTree
## Input and physics driven airborne collision and landing audit.
var checks := 0
var failures := 0
var main: Node2D
var stage: Node2D
var hero: KnightController
var target: TrainingTarget
var wall: StaticBody2D

func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func check(ok: bool, label: String) -> void:
 checks += 1
 print("PASS " if ok else "FAIL ", label)
 if not ok: failures += 1
func release() -> void:
 for action in ["attack", "jump", "move_left", "move_right"]: Input.action_release(action)
func attack() -> void:
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
func place(point: Vector2, face: int) -> void:
 release()
 wall.position = Vector2(9000,9000)
 target.position = Vector2(8000,8000)
 hero.survival.restore()
 hero.reset_to(point)
 hero.facing = face
 await frames(2)
func wall_case(side: int, rising: bool) -> void:
 await place(Vector2(450, 130 if rising else 105), side)
 hero.velocity.y = -105 if rising else 45
 wall.position = Vector2(450 + 14*side, 91)
 target.position = Vector2(450 + 23*side, 116 if rising else 103)
 target.hit_count = 0
 await frames(1)
 var x0: float = hero.position.x
 await attack()
 check(hero.sword_attack.aerial and hero.sword_attack.direction == side, "airborne direction %d rising=%s" % [side,rising])
 await frames(9)
 check(target.hit_count == 0, "solid wall blocks aerial hit side=%d rising=%s" % [side,rising])
 check(absf(hero.position.x-x0) < 0.1, "attack does not displace body at wall side=%d" % side)
 check(not hero.sword_attack.hit_shape.disabled or hero.sword_attack.phase != SwordAttack.Phase.ACTIVE, "active hitbox corresponds to phase")
 await frames(40)
 check(hero.sword_attack.hit_shape.disabled, "no residual hitbox after wall scenario")

func landing_case(height: float, speed_y: float, desired: int, label: String, near_end: bool = false) -> void:
 await place(Vector2(450, 156-height), 1)
 hero.velocity.y = speed_y
 await attack()
 print("LAND DEBUG ",label," pos=",hero.position," velocity=",hero.velocity," phase=",hero.sword_attack.phase," floor=",hero.is_on_floor()," aerial=",hero.sword_attack.aerial)
 var saw_desired := false
 var previous_phase := hero.sword_attack.phase
 var previous_remaining := hero.sword_attack._remaining
 for i in range(40):
  if hero.sword_attack.phase == desired and not hero.is_on_floor(): saw_desired = true
  if hero.is_on_floor(): break
  previous_phase = hero.sword_attack.phase
  previous_remaining = hero.sword_attack._remaining
  await frames(1)
 check(saw_desired, label + " phase observed in air")
 check(previous_phase == desired, label + " phase immediately before floor contact")
 if near_end: check(previous_remaining <= 0.04 and previous_remaining > 0.0, label + " last recovery frames before landing")
 check(hero.is_on_floor(), label + " physical landing")
 check(hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL and hero.sword_attack.hit_shape.disabled, label + " cancels and clears hitbox")
 check(hero.sword_attack.aerial_available, label + " rearms on floor")

func run() -> void:
 main = load("res://tests/fixtures/baseline_main.tscn").instantiate()
 root.add_child(main)
 stage = main.get_node("PrototypeStage")
 hero = stage.get_node("Knight")
 target = stage.get_node("TrainingTarget")
 wall = StaticBody2D.new()
 wall.collision_layer = 1
 wall.collision_mask = 0
 var shape := RectangleShape2D.new()
 shape.size = Vector2(4,120)
 var cs := CollisionShape2D.new()
 cs.shape = shape
 wall.add_child(cs)
 stage.add_child(wall)
 await frames(4)
 check(not hero.dash_unlocked, "fresh profile has no dash")
 for side in [-1,1]:
  await place(Vector2(450,105),side)
  hero.velocity.y = 45
  target.position = Vector2(450+23*side,103)
  target.hit_count = 0
  await attack()
  await frames(10)
  check(target.hit_count == 1, "unobstructed aerial target receives one hit side=%d" % side)
  await frames(10)
  check(target.hit_count == 1, "aerial target does not receive duplicate hit side=%d" % side)
 for side in [-1,1]:
  for rising in [true,false]: await wall_case(side,rising)
 for side in [-1,1]:
  await place(Vector2(450,105),side)
  wall.position = Vector2(450+12*side, 91)
  target.position = Vector2(450+23*side,103)
  target.hit_count = 0
  hero.velocity.y = 25
  Input.action_press("move_right" if side > 0 else "move_left")
  await frames(8)
  print("WALL CONTACT ", side, " position=",hero.position," velocity=",hero.velocity," floor=",hero.is_on_floor())
  check(hero.is_on_wall(), "real airborne wall contact side=%d" % side)
  await attack()
  await frames(8)
  check(target.hit_count == 0, "contacting wall blocks target side=%d" % side)
  release()
 await place(Vector2(450,156),1)
 await frames(3)
 var ceiling := StaticBody2D.new()
 ceiling.collision_layer = 1
 var ceiling_shape := RectangleShape2D.new()
 ceiling_shape.size = Vector2(100,4)
 var ceiling_collision := CollisionShape2D.new()
 ceiling_collision.shape = ceiling_shape
 ceiling.add_child(ceiling_collision)
 ceiling.position = Vector2(450,100)
 stage.add_child(ceiling)
 await frames(2)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await attack()
 var ceiling_seen := false
 for i in range(25):
  await frames(1)
  if hero.is_on_ceiling(): ceiling_seen = true
 check(ceiling_seen, "body collides with low ceiling during airborne attack")
 ceiling.queue_free()
 await frames(2)
 await landing_case(12,110,SwordAttack.Phase.WINDUP,"windup")
 await landing_case(30,110,SwordAttack.Phase.ACTIVE,"active")
 await landing_case(55,110,SwordAttack.Phase.RECOVERY,"recovery")
 await landing_case(95,110,SwordAttack.Phase.RECOVERY,"end recovery",true)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await attack()
 check(hero.velocity.y < 0 and hero.sword_attack.aerial, "immediate jump after landing accepts airborne J")
 await frames(50)
 await place(Vector2(450,156),1)
 await frames(4)
 Input.action_press("move_right")
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 for i in range(40):
  if absf(hero.velocity.y) <= 15 and not hero.is_on_floor(): break
  await frames(1)
 check(absf(hero.velocity.y) <= 15 and not hero.is_on_floor(), "real jump reaches apex")
 var apex_velocity_x := hero.velocity.x
 await attack()
 check(hero.sword_attack.aerial and absf(hero.velocity.x-apex_velocity_x)<0.1, "J near apex preserves horizontal velocity")
 release()
 await place(Vector2(545,156),1)
 await frames(3)
 Input.action_press("move_right")
 for i in range(30):
  await frames(1)
  if not hero.is_on_floor(): break
 check(not hero.is_on_floor() and hero.position.x > 560, "walked off physical platform without jumping")
 await attack()
 check(hero.sword_attack.aerial, "aerial strike works after walking off edge")
 release()
 await place(Vector2(450,120),1)
 hero.velocity.y = 40
 await attack()
 hero.receive_damage(1)
 check(not hero.sword_attack.aerial_available and hero.sword_attack.hit_shape.disabled, "damage cancels but does not rearm in air")
 await attack()
 check(hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL, "damage cannot grant another airborne strike")
 await frames(40)
 check(hero.is_on_floor() and hero.sword_attack.aerial_available, "real floor rearms after damage")
 await attack()
 check(not hero.sword_attack.aerial and hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL, "ground attack after landing")
 await frames(35)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await attack()
 check(hero.sword_attack.aerial and not hero.sword_attack.aerial_available, "new physical jump permits new airborne strike")
 hero.dash_unlocked = true
 var shift := InputEventKey.new()
 shift.keycode = KEY_SHIFT
 shift.pressed = true
 Input.parse_input_event(shift)
 await frames(1)
 check(hero.dash_remaining == 0.0 and hero.sword_attack.aerial, "airborne Shift does not cancel strike or start dash")
 shift.pressed = false
 Input.parse_input_event(shift)
 print("FIX01 physics checks=",checks," failures=",failures)
 main.queue_free()
 await frames(2)
 quit(1 if failures else 0)
