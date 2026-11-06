extends SceneTree
## Short sequence of real input and rendered frames, isolated profile only.
var hero: KnightController
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func shot(name: String) -> void:
 await RenderingServer.frame_post_draw
 var image := root.get_texture().get_image()
 var path := "user://fix01_"+name+".png"
 print("VIS ",name," size=",image.get_size()," p=",hero.global_position," vy=",hero.velocity.y," phase=",hero.sword_attack.phase," aerial=",hero.sword_attack.aerial," hitbox=",not hero.sword_attack.hit_shape.disabled," saved=",image.save_png(path))
func run() -> void:
 var stage: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
 root.add_child(stage)
 hero = stage.get_node("Knight")
 await frames(4)
 hero.reset_to(Vector2(300,156))
 await frames(8)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(3)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await shot("subida_preparacao")
 await frames(1)
 await shot("subida_ativo")
 await frames(2)
 await shot("subida_recuperacao")
 await frames(50)
 hero.reset_to(Vector2(300,156))
 await frames(6)
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(25)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(6)
 await shot("queda_ativo")
 await frames(25)
 await shot("aterrissagem")
 hero.reset_to(Vector2(470,110))
 hero.facing=1
 hero.velocity.y=40
 Input.action_press("move_right")
 await frames(3)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(2)
 await shot("perto_parede")
 Input.action_release("move_right")
 await frames(35)
 hero.reset_to(Vector2(586,156))
 await frames(4)
 hero.facing=1
 var raven: CursedRaven = stage.get_node("Enemies/M5HGraveRaven")
 raven.reset_enemy()
 Input.action_press("jump")
 await frames(1)
 Input.action_release("jump")
 await frames(4)
 Input.action_press("attack")
 await frames(1)
 Input.action_release("attack")
 await frames(9)
 await shot("corvo_real")
 print("VIS RAVEN hp=",raven.current_health," position=",raven.position)
 stage.queue_free()
 await frames(3)
 var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 hero=chapter.hero
 while chapter.busy or chapter.current_room<0: await process_frame
 await chapter.switch_room(6)
 while chapter.busy: await process_frame
 hero.reset_to(AbbeyChapterLayout.origin(6)+Vector2(360,300))
 await frames(6)
 await shot("abadia_fundicao")
 chapter.queue_free()
 await frames(3)
 quit()
