extends SceneTree
func _initialize() -> void: run.call_deferred()
func run() -> void:
 root.size=Vector2i(1280,720)
 var arena: Node=load("res://scenes/boss/guardian_arena.tscn").instantiate()
 root.add_child(arena)
 arena.get_node("BossHUD/Presentation").boss=arena.get_node("Guardian")
 arena.get_node("BossHUD").show()
 var camera: Camera2D=arena.get_node("ArenaCamera")
 camera.enabled=true;camera.make_current()
 for i: int in range(10): await process_frame
 await RenderingServer.frame_post_draw
 var output: String=ProjectSettings.globalize_path("res://.godot/m5g-fix05-evidencias")
 DirAccess.make_dir_recursive_absolute(output)
 var err: Error=root.get_texture().get_image().save_png(output+"/guardiao_referencia_1280x720.png")
 print("GUARDIAN REFERENCE save=",err)
 quit(0 if err==OK else 1)
