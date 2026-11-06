extends SceneTree
## Tests whether previous candidate platforms obstruct ordinary jumps on the spine.
const CASES: Dictionary={6:Rect2(860,284,48,12),8:Rect2(1100,212,48,12),9:Rect2(680,260,48,12)}
var chapter: Node2D
var hero: KnightController
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 for id: int in CASES:
  await chapter.switch_room(id)
  var rect: Rect2=CASES[id]
  var origin: Vector2=AbbeyChapterLayout.origin(id)
  var x: float=rect.get_center().x
  var y: float=INF
  for floor: Rect2 in AbbeyChapterLayout.main_surfaces(id):
   if x>=floor.position.x and x<floor.end.x: y=floor.position.y
  var body: StaticBody2D=StaticBody2D.new()
  body.position=rect.position
  body.collision_layer=1
  var cs: CollisionShape2D=CollisionShape2D.new()
  var shape: RectangleShape2D=RectangleShape2D.new()
  shape.size=rect.size
  cs.shape=shape
  cs.position=rect.size/2
  body.add_child(cs)
  chapter.room.add_child(body)
  for frame: int in range(3): await tick()
  hero.reset_to(origin+Vector2(x,y))
  for frame: int in range(5): await tick()
  var start: float=hero.global_position.y
  var peak: float=start
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  for frame: int in range(45):
   await tick()
   peak=minf(peak,hero.global_position.y)
  print("S%d candidate=%s main_route_jump_height=%.3f baseline=~41px" % [id+1,rect,start-peak])
 print("Synthetic tests under candidate ledges, not proof that all alternate layouts fail.")
 chapter.queue_free()
 await tick()
 quit()
