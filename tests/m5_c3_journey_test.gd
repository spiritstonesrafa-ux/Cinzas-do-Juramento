extends SceneTree
## Continuous integration run using player inputs and actual room transitions.
var chapter: Node2D
var hero: KnightController

func _initialize() -> void:
 run.call_deferred()

func tick() -> void:
 await physics_frame
 await process_frame

func steer(side: int) -> void:
 Input.action_release("jump")
 Input.action_press("move_right" if side>0 else "move_left")
 if not hero.is_on_floor(): return
 var p: Vector2=hero.global_position
 var space: PhysicsDirectSpaceState2D=hero.get_world_2d().direct_space_state
 var wall: Dictionary=space.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(0,-16),p+Vector2(side*8,-16),1))
 # Adjacent <=24px descents can be walked. Only a genuine horizontal gap
 # warrants a jump; a shallow ray would inflate odometry at every down tread.
 var floor_ahead: Dictionary=space.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(side*13,-2),p+Vector2(side*13,32),1))
 if not wall.is_empty() or floor_ahead.is_empty(): Input.action_press("jump")
func run() -> void:
 chapter = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 hero = chapter.hero
 while chapter.busy or chapter.current_room < 0:
  await tick()
 for side: int in [1, -1]:
  for id: int in (range(12) if side == 1 else range(11, -1, -1)):
   if chapter.current_room != id:
    finish(1)
    return
   var previous_room: WeakRef = weakref(chapter.room)
   print("ENTRY S%d dir=%d local=%s new_enemies=%d new_hazards=%d" % [
    id+1, side, hero.global_position - AbbeyChapterLayout.origin(id),
    chapter.room.encounters.enemies.size(), chapter.room.encounters.hazards.size()])
   var start_health: int = hero.survival.current_health
   var tick_number: int = 0
   for i: int in range(3600):
    steer(side)
    # Wait outside each danger zone during warning and strike.
    for hazard: Node2D in chapter.room.encounters.hazards:
     var strike_center: float = hazard.global_position.x + (38 if hazard.family == 2 else 0)
     var distance: float = (strike_center - hero.global_position.x) * side
     var hold_distance: float = [64.0, 24.0, 43.0][hazard.family]
     if distance >= hold_distance and distance < hold_distance + 25 and absf(hazard.global_position.y - hero.global_position.y) < 60 and hazard.state in [1, 2]:
      Input.action_release("move_right" if side > 0 else "move_left")
      Input.action_release("jump")
    if i % 2 == 0: Input.action_press("attack")
    else: Input.action_release("attack")
    await tick()
    tick_number = i + 1
    if hero.survival.is_dead or chapter.busy or chapter.current_room != id:
     break
    if (id == 11 and side == 1 and chapter.completed) or (id == 0 and side == -1 and hero.position.x <= 17):
     break
   for action: String in ["move_left", "move_right", "jump", "attack"]:
    Input.action_release(action)
   var local: Vector2 = hero.global_position - AbbeyChapterLayout.origin(id)
   var exit_reached: bool = chapter.busy or chapter.current_room != id
   if id == 11 and side == 1: exit_reached = chapter.completed
   if id == 0 and side == -1: exit_reached = local.x <= 17
   print("LEG S%d dir=%d ticks=%d local=%s velocity=%s facing=%d floor=%s HP=%d->%d dead=%s invuln=%.2f camera=%s checkpoint=%s exit=%s" % [
    id+1, side, tick_number, local, hero.velocity, hero.facing, hero.is_on_floor(), start_health,
    hero.survival.current_health, hero.survival.is_dead, hero.survival.invulnerability_remaining,
    chapter.camera.position, str(hero.active_checkpoint), exit_reached])
   if not exit_reached or hero.survival.is_dead:
    for enemy: Node2D in chapter.room.encounters.enemies:
     print("ENEMY ", enemy.position, " state=", enemy.state, " HP=", enemy.current_health)
    for hazard: Node2D in chapter.room.encounters.hazards:
     print("HAZARD ", hazard.position, " state=", hazard.state, " hitbox=", not hazard.shape.disabled)
    finish(1)
    return
   while chapter.busy:
    await tick()
   if chapter.current_room != id and previous_room.get_ref() != null:
    push_error("Previous room was retained after transition")
    finish(1)
    return
 finish(0)

func finish(code: int) -> void:
 chapter.queue_free()
 await tick()
 quit(code)
