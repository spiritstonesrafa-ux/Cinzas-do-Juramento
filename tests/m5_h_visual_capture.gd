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
 await frames(4)
 hero.reset_to(Vector2(465,144))
 await frames(8)
 Input.action_press("move_right")
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(3)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(7)
 await RenderingServer.frame_post_draw
 var file := "user://m5h_aerial_%dx%d.png" % [root.size.x,root.size.y]
 var error := root.get_texture().get_image().save_png(file)
 print("VISUAL ", ProjectSettings.globalize_path(file), " result=", error, " phase=", hero.sword_attack.phase, " airborne=",hero.sword_attack.aerial)
 Input.action_release("move_right")
 stage.queue_free()
 await frames(2)
 quit(0 if error == OK else 1)
