extends SceneTree
## Audit actual authored actors with the world's physics, not test doubles.
const CEMETERY_ADDED := ["M5HGateSkeleton","M5HGraveSkeleton","M5HGraveRaven","M5HGardenSkeleton","M5HCryptRaven","M5HBridgeRaven"]
const ABBEY_ADDED := {0:320,2:600,3:900,4:380,5:450,6:850,7:260,8:1060,9:680,10:1030}
var failures := 0
var checks := 0
func _initialize() -> void: run.call_deferred()
func frames(n: int) -> void:
 for i in range(n): await physics_frame; await process_frame
func check(v: bool,label: String) -> void:
 checks += 1
 print("PASS " if v else "FAIL ",label)
 if not v: failures += 1
func world_overlap(actor: Node2D) -> bool:
 var body: CollisionShape2D = actor.get_node("CollisionShape2D")
 var query := PhysicsShapeQueryParameters2D.new()
 # Exclude normal floor contact from the overlap query without changing the actor.
 var inset: RectangleShape2D = body.shape.duplicate()
 inset.size -= Vector2(0.4,0.4)
 query.shape = inset
 query.transform = body.global_transform
 query.collision_mask = 1
 return not actor.get_world_2d().direct_space_state.intersect_shape(query,1).is_empty()
func ground(actor: Node2D) -> bool:
 var p := actor.global_position
 var ray := PhysicsRayQueryParameters2D.create(p+Vector2(0,-2),p+Vector2(0,7),1)
 return not actor.get_world_2d().direct_space_state.intersect_ray(ray).is_empty()
func run() -> void:
 var level: Node2D = load("res://scenes/levels/forgotten_cemetery.tscn").instantiate()
 root.add_child(level)
 await frames(1)
 check(level.get_node("Enemies").get_child_count()==12,"cemetery total 12")
 for name in CEMETERY_ADDED:
  var actor: Node2D = level.get_node("Enemies/"+name)
  check(not world_overlap(actor),"cemetery body not in world: "+name)
  if actor is SkeletonPatrol: check(ground(actor),"cemetery ground support: "+name)
 level.queue_free()
 await frames(2)
 var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await process_frame
 var total := 0
 for id in range(12):
  if id != 0: await chapter.switch_room(id)
  while chapter.busy: await process_frame
  await frames(1)
  total += chapter.room.encounters.enemies.size()
  if ABBEY_ADDED.has(id):
   var expected: float = ABBEY_ADDED[id]
   var match_actor: Node2D
   for enemy in chapter.room.encounters.enemies:
    if absf(enemy.position.x-expected)<8: match_actor=enemy
   check(is_instance_valid(match_actor),"sector %d new actor exists" % (id+1))
   if is_instance_valid(match_actor):
    check(not world_overlap(match_actor),"sector %d body not in world" % (id+1))
    check(ground(match_actor),"sector %d ground support" % (id+1))
 check(total==20,"abbey total 20")
 check(chapter.checkpoints.size()==7,"seven checkpoints remain")
 print("FIX01 spawn checks=",checks," failures=",failures)
 chapter.queue_free()
 await frames(2)
 quit(1 if failures else 0)
