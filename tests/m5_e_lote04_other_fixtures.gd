extends SceneTree
## Isolated launch fixtures for proposed first ledges. Not a journey proof.
const TARGETS: Dictionary={2:Rect2(830,336,48,12),4:Rect2(540,380,48,12),6:Rect2(860,284,48,12),8:Rect2(1100,212,48,12),9:Rect2(680,260,48,12)}
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
 for id: int in TARGETS:
  await chapter.switch_room(id)
  var rect: Rect2=TARGETS[id]
  var origin: Vector2=AbbeyChapterLayout.origin(id)
  var x: float=rect.position.x-20
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
  var start: Vector2=origin+Vector2(x,y)
  var safe: bool=hero.is_respawn_safe(start)
  hero.reset_to(start)
  for frame: int in range(5): await tick()
  Input.action_press("move_right")
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var landed: bool=false
  for frame: int in range(80):
   await tick()
   var p: Vector2=hero.global_position-origin
   if p.x>=rect.get_center().x-5: Input.action_release("move_right")
   if hero.is_on_floor() and absf(p.y-rect.position.y)<0.5 and p.x>rect.position.x+6 and p.x<rect.end.x-6:
    landed=true
    break
  Input.action_release("move_right")
  print("SECTOR %d fixture support=%s first_landing=%s from=%s to=%s final=%s" % [id+1,safe,landed,Vector2(x,y),rect,hero.global_position-origin])
 print("Fixtures only; no claim of inaccessible route or integrated traversal.")
 chapter.queue_free()
 await tick()
 quit()
