extends SceneTree

func _initialize() -> void:
 run.call_deferred()

func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame

func run() -> void:
 var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
 root.add_child(stage)
 var hero: KnightController = stage.get_node("Knight")
 var enemy: CursedRaven = stage.get_node("Enemies/M5HGraveRaven")
 await frames(3)
 hero.reset_to(Vector2(586,156))
 await frames(4)
 hero.facing = 1
 var hp: int = enemy.current_health
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(4)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(10)
 var success: bool = enemy.current_health == hp-1
 print("REAL RAVEN airborne hit initial=",hp," final=",enemy.current_health," result=",success)
 stage.queue_free()
 await frames(2)
 quit(0 if success else 1)
