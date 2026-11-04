extends DamageSource
## One visible projectile, blocked by world, finite range, single contact.
var direction: int=1
var elapsed: float=0
var contacted: Array[int]=[]
func _ready() -> void:
 collision_layer=32
 collision_mask=0
 monitoring=false
 var shape: CollisionShape2D=CollisionShape2D.new()
 var circle: CircleShape2D=CircleShape2D.new()
 circle.radius=5
 shape.shape=circle
 add_child(shape)
func _physics_process(delta: float) -> void:
 elapsed+=delta
 var step: Vector2=Vector2(direction*65*delta,0)
 var hit: Dictionary=get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position,global_position+step,1))
 if not hit.is_empty() or elapsed>1.6:
  queue_free();return
 global_position+=step
 queue_redraw()
func contact_damage(receiver_id: int) -> int:
 if contacted.has(receiver_id): return 0
 contacted.append(receiver_id)
 queue_free()
 return 1
func _draw() -> void:
 draw_circle(Vector2.ZERO,5,Color("d6bb78"))
 draw_circle(Vector2.ZERO,3,Color("a4e4d3"))
