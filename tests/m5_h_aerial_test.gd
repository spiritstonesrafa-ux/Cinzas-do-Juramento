extends SceneTree

var checks := 0
var failures := 0
var hero: KnightController
var stage: Node

func _initialize() -> void:
 run.call_deferred()

func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame

func check(condition: bool, label: String) -> void:
 checks += 1
 print("PASS: " if condition else "FAIL: ", label)
 if not condition: failures += 1

func press(action: String) -> void:
 Input.action_press(action)
 await frames(1)
 Input.action_release(action)

func run() -> void:
 stage = load("res://tests/fixtures/baseline_main.tscn").instantiate()
 root.add_child(stage)
 hero = stage.get_node("PrototypeStage/Knight")
 await frames(5)
 hero.reset_to(Vector2(450,156))
 await frames(4)
 check(hero.is_on_floor(), "initial floor")
 await press("jump")
 check(not hero.is_on_floor() and hero.velocity.y < 0, "real jump begins ascent")
 var upward: float = hero.velocity.y
 await press("attack")
 check(hero.sword_attack.aerial and hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL, "J starts aerial attack on ascent")
 check(hero.velocity.y > upward, "gravity continues")
 await frames(26)
 check(not hero.sword_attack.aerial_available, "attack consumed for airborne interval")
 await press("attack")
 check(hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL, "second airborne J rejected")
 await frames(40)
 check(hero.is_on_floor() and hero.sword_attack.aerial_available, "landing rearms")
 await press("jump")
 await frames(23)
 check(hero.velocity.y >= 0.0, "falling")
 hero.facing = -1
 await press("attack")
 check(hero.sword_attack.aerial and hero.sword_attack.direction == -1, "falling attack points left")
 hero.receive_damage(1)
 check(hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL and hero.sword_attack.hit_shape.disabled, "damage cancels airborne strike")
 await frames(45)
 check(hero.is_on_floor(), "lands after damage")
 await press("attack")
 check(not hero.sword_attack.aerial and hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL, "ground J remains available")
 await frames(35)
 hero.survival.restore()
 hero.reset_to(Vector2(450,156))
 await frames(4)
 Input.action_press("jump")
 Input.action_press("attack")
 await frames(1)
 Input.action_release("jump")
 Input.action_release("attack")
 check(hero.sword_attack.aerial and hero.velocity.y < 0, "same-frame jump and attack are airborne")
 await frames(8)
 hero.receive_damage(99)
 check(hero.survival.is_dead and hero.sword_attack.phase == SwordAttack.Phase.NEUTRAL and hero.sword_attack.hit_shape.disabled, "death cancels active strike")
 hero.survival.restore()
 hero.reset_to(Vector2(450,156))
 await frames(4)
 var target: TrainingTarget = stage.get_node("PrototypeStage/TrainingTarget")
 target.hit_count = 0
 target.position = Vector2(474, 128)
 hero.facing = 1
 await press("jump")
 await press("attack")
 await frames(10)
 check(target.hit_count == 1, "real aerial hit reaches target exactly once")
 await frames(15)
 check(target.hit_count == 1, "same airborne strike does not repeat damage")
 print("M5-H: %d checks, %d failures" % [checks, failures])
 stage.queue_free()
 await frames(2)
 quit(1 if failures else 0)
