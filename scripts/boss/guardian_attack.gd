extends DamageSource
## Visible blade segment and physical box share coordinates. One M2 delivery per swing.
const HILT: Vector2=Vector2(15,-38)
const TIP: Vector2=Vector2(75,-12)
const THICKNESS: float=10
var active: bool=false
var consumed: bool=false
@onready var shape: CollisionShape2D=$CollisionShape2D
func set_direction(side: int) -> void:
 var center: Vector2=(HILT+TIP)*0.5
 position=Vector2(center.x*side,center.y)
 rotation=(TIP-HILT).angle()*side
func configure(pattern: int, progress: float, side: int) -> void:
 var endpoints: Array[Vector2]=blade_points(pattern,progress)
 var start: Vector2=endpoints[0]
 var finish: Vector2=endpoints[1]
 position=Vector2((start.x+finish.x)*0.5*side,(start.y+finish.y)*0.5)
 rotation=(finish-start).angle()*side
 # Resource must be unique: the boss scene can be instantiated more than once.
 if not shape.shape.resource_local_to_scene:
  shape.shape=shape.shape.duplicate()
  shape.shape.resource_local_to_scene=true
 (shape.shape as RectangleShape2D).size=Vector2(start.distance_to(finish),THICKNESS)
static func blade_points(pattern: int, progress: float) -> Array[Vector2]:
	# Titan swings a chain maul; keep each damage box aligned with its visible wind-up.
	if pattern==0:
		var angle: float=lerpf(-1.55,0.2,clampf(progress,0.0,1.0))
		return [Vector2(16,-44),Vector2(16,-44)+Vector2.from_angle(angle)*104.0]
 if pattern==1:return [Vector2(15,-14),Vector2(77,-14)]
 if pattern==2:
  var start: Vector2=Vector2(8,-14)
  return [start,start+Vector2.from_angle(lerpf(-0.08,0.08,clampf(progress,0,1)))*78]
	if pattern==3:return [Vector2(12,-30),Vector2(28,-2)]
 return [HILT,TIP]
func set_active(value: bool) -> void:
 active=value
 shape.set_deferred("disabled",not value)
 if not value:consumed=false
func contact_damage(receiver_id: int) -> int:
 if not active or consumed:return 0
 var player: KnightController=instance_from_id(receiver_id) as KnightController
 if player==null or player.survival.is_dead:return 0
 var ray: PhysicsRayQueryParameters2D=PhysicsRayQueryParameters2D.create(get_parent().global_position+Vector2(0,-28),player.global_position+Vector2(0,-12),1)
 if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():return 0
 consumed=true
 return 1
func _draw() -> void:
 pass
