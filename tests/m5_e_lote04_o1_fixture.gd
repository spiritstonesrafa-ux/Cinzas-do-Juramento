extends SceneTree
## Synthetic fixture for candidate geometry only; NOT a journey from sector entry.
const NEW: Array[Rect2]=[Rect2(968,60,48,12),Rect2(1028,84,48,12),Rect2(1088,108,48,12)]
var chapter: Node2D
var hero: KnightController
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func local() -> Vector2: return hero.global_position-AbbeyChapterLayout.origin(1)
func release() -> void:
 Input.action_release("move_left")
 Input.action_release("move_right")
 Input.action_release("jump")
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(1)
 hero=chapter.hero
 for r: Rect2 in NEW:
  var body: StaticBody2D=StaticBody2D.new()
  body.position=r.position
  body.collision_layer=1
  var collider: CollisionShape2D=CollisionShape2D.new()
  var shape: RectangleShape2D=RectangleShape2D.new()
  shape.size=r.size
  collider.shape=shape
  collider.position=r.size/2
  body.add_child(collider)
  chapter.room.add_child(body)
 for frame: int in range(3): await tick()
 var floor: Rect2=AbbeyPilotLayout.OPTIONAL[2]
 var all: Array[Rect2]=[floor]
 all.append_array(NEW)
 for side: int in [1,-1]:
  for i: int in range(3):
   var src: Rect2=all[i if side==1 else 3-i]
   var dest: Rect2=all[i+1 if side==1 else 2-i]
   # Reset only for independent supported jump fixtures.
   var start: Vector2=Vector2(src.end.x-13 if side==1 else src.position.x+13,src.position.y)
   hero.reset_to(AbbeyChapterLayout.origin(1)+start)
   for frame: int in range(5): await tick()
   check(hero.is_on_floor(),"apoio inicial %s" % start)
   Input.action_press("move_right" if side==1 else "move_left")
   Input.action_press("jump")
   await tick()
   Input.action_release("jump")
   var landed: bool=false
   for frame: int in range(100):
    await tick()
    var p: Vector2=local()
    if (p.x-dest.get_center().x)*side>=-5:
     Input.action_release("move_right" if side==1 else "move_left")
    if hero.is_on_floor() and absf(p.y-dest.position.y)<0.5 and p.x>dest.position.x+6 and p.x<dest.end.x-6:
     landed=true
     break
   release()
   check(landed,"salto %s -> %s direção %d final %s" % [src,dest,side,local()])
 for r: Rect2 in NEW:
  check(r.position.y+12<160,"laje distante da altura da espinha %s" % r)
 print("CANDIDATE O1 fixture failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
