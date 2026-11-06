extends SceneTree
## Controlled visual fixture in the real chapter/arena; never writes progression.
var chapter: Node
var hero: KnightController
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n): await physics_frame; await process_frame
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(11)
 await chapter._enter_abbot_arena()
 hero=chapter.hero
 var boss: Node=chapter.room.boss
 var folder: String=ProjectSettings.globalize_path("res://.godot/aspect-comparison")
 DirAccess.make_dir_recursive_absolute(folder)
 var mode: String=OS.get_environment("M5_ASPECT_VARIANT")
 for size: Vector2i in [Vector2i(1920,1080),Vector2i(1280,800),Vector2i(1024,768),Vector2i(2560,1080)]:
  root.mode=Window.MODE_WINDOWED
  DisplayServer.window_set_size(size)
  DisplayServer.window_set_position(Vector2i(50,50))
  DisplayServer.window_move_to_foreground()
  for i: int in range(12): await process_frame
  hero.reset_to(chapter.ARENA_ORIGIN+Vector2(65,156))
  boss.position=Vector2(235,156)
  boss.phase=1;boss.health=10;boss.facing=-1;boss.pattern=boss.Pattern.CHAIN
  boss._state(boss.State.INTRO,30.0)
  await tick(4)
  await capture(folder,mode,size,"arena")
  # Only the isolated fixture unlocks dash in memory; it does not create a save.
  hero.dash_unlocked=true
  var ev: InputEventKey=InputEventKey.new();ev.keycode=KEY_SHIFT;ev.pressed=true;Input.parse_input_event(ev)
  await tick(2)
  ev=InputEventKey.new();ev.keycode=KEY_SHIFT;ev.pressed=false;Input.parse_input_event(ev)
  await capture(folder,mode,size,"dash_aren")
  hero.reset_to(chapter.ARENA_ORIGIN+Vector2(65,156))
  boss.position=Vector2(235,156);boss.phase=2;boss.pattern=boss.Pattern.DASH;boss.facing=-1
  boss._state(boss.State.ACTIVE,0.42)
  await tick(3)
  await capture(folder,mode,size,"dash_abade")
  boss._state(boss.State.INTRO,30.0)
  await tick(90)
 print("ASPECT finished")
 chapter.queue_free();await tick(5);quit()
func capture(folder: String,mode: String,size: Vector2i,label: String) -> void:
 await RenderingServer.frame_post_draw
 var img: Image=root.get_texture().get_image()
 var filename: String=folder+"/%s_%dx%d_%s.png" % [mode,size.x,size.y,label]
 var error: Error=img.save_png(filename)
 print("ASPECT variant=",mode," requested=",size," window=",DisplayServer.window_get_size()," image=",img.get_size()," visible=",root.get_visible_rect()," content=",root.content_scale_size," aspect=",root.content_scale_aspect," screen_transform=",root.get_screen_transform()," camera=",chapter.camera.position," arena=",chapter.arena_active," dash_aren=",hero.dash_remaining," mode=",label," save=",error)
