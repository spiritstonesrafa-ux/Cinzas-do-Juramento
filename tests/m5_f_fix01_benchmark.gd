extends "res://tests/abbey_chapter_performance_test.gd"
## Preserve benchmark assertions; control live threats as in the validated journey.
func isolate_threats() -> void:
 # All enemies and hazards stay active, including pilots.
 pass
func steer(side: int) -> void:
 super.steer(side)
 if not is_instance_valid(demo.room) or not is_instance_valid(demo.room.encounters): return
 for hazard: Node2D in demo.room.encounters.hazards:
  var strike_center: float=hazard.global_position.x+(38 if hazard.family==2 else 0)
  var distance: float=(strike_center-hero.global_position.x)*side
  var hold: float=[64.0,24.0,43.0][hazard.family]
  if distance>=hold and distance<hold+25 and absf(hazard.global_position.y-hero.global_position.y)<60 and hazard.state in [1,2]:
   Input.action_release("move_right" if side>0 else "move_left")
   Input.action_release("jump")
 if Engine.get_physics_frames()%2==0: Input.action_press("attack")
 else: Input.action_release("attack")
