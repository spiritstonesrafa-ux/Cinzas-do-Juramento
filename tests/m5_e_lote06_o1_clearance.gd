extends SceneTree
## Supported synthetic fixtures on S2 main corridor; production geometry stays enabled.
var chapter: Node2D
var hero: KnightController
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(1)
 hero=chapter.hero
 for x: float in [992.0,1052.0,1148.0]:
  var start: Vector2=AbbeyChapterLayout.origin(1)+Vector2(x,228)
  hero.reset_to(start)
  for frame: int in range(5): await tick()
  var y: float=hero.global_position.y
  var peak: float=y
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  for frame: int in range(65):
   await tick()
   peak=minf(peak,hero.global_position.y)
  var height: float=y-peak
  var passed: bool=height>40 and height<42 and hero.is_on_floor()
  if not passed: failures+=1
  print(("PASS " if passed else "FAIL "),"S2 under O1 x=",x," jump_height=",height," grounded=",hero.is_on_floor())
 print("O1 corridor clearance fixture failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
