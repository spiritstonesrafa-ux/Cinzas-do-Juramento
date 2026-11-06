extends SceneTree
## Profile must already contain a legitimately won reward. Captures consecutive frames.
var fails: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func check(value: bool,label: String) -> void:
 print(("PASS " if value else "FAIL ")+label)
 if not value: fails+=1
func key(pressed: bool) -> void:
 var event: InputEventKey=InputEventKey.new()
 event.keycode=KEY_SHIFT
 event.pressed=pressed
 Input.parse_input_event(event)
func run() -> void:
 root.size=Vector2i(1280,720)
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 var hero: KnightController=chapter.hero
 check(hero.dash_unlocked,"recompensa persistida disponível")
 var folder: String=ProjectSettings.globalize_path("res://.godot/m5g-fix02-sequence")
 DirAccess.make_dir_recursive_absolute(folder)
 for side: int in [1,-1]:
  hero.reset_to(AbbeyChapterLayout.origin(0)+Vector2(150,300))
  for i: int in range(70): await tick()
  Input.action_press("move_right" if side==1 else "move_left")
  for i: int in range(3): await tick()
  Input.action_release("move_right" if side==1 else "move_left")
  var start: float=hero.global_position.x
  key(true)
  var observed: bool=false
  var ghosts_seen: bool=false
  for frame: int in range(20):
   await tick()
   if frame==2: key(false)
   if hero.dash_remaining>0: observed=true
   if hero.get_node("Visual")._dash_ghosts.size()>0: ghosts_seen=true
   await RenderingServer.frame_post_draw
   root.get_texture().get_image().save_png(folder+"/aren_%s_%02d.png" % ["direita" if side==1 else "esquerda",frame])
  check(observed and ghosts_seen and (hero.global_position.x-start)*side>0,"dash e rastros lado "+str(side))
  for i: int in range(30): await tick()
  check(hero.get_node("Visual")._dash_ghosts.is_empty(),"rastros expiram lado "+str(side))
 print("M5G FIX02 visual dash failures=",fails)
 chapter.queue_free()
 for i: int in range(5): await tick()
 quit(1 if fails else 0)
