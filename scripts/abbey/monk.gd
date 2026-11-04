class_name ChainedMonk
extends CharacterBody2D
## Longer committed reach, not extra HP. Shared M1 receiver and M2 source.
enum State { PATROL, CHASE, WARNING, ACTIVE, RECOVER, HURT, DEAD }
var state: State = State.PATROL
var current_health: int = 3
var facing: int = -1
var target: KnightController
var origin: Vector2
var remaining: float = 0
var age: float = 0
var flash: float = 0
var attacks: int = 0
var hits_received: int = 0
@onready var source: SkeletonAttackSource = $AttackSource
@onready var receiver: SwordReceiver = $SwordReceiver
@onready var visual: Node2D = $Visual
func _ready() -> void:
 process_physics_priority = -1
 origin = global_position
 receiver.hit_received.connect(receive_hit)
 reset_enemy()
func set_state(value: State, seconds: float = 0) -> void:
 state = value
 remaining = seconds
 source.position.x = facing * 28
 source.set_active(value == State.ACTIVE)
 velocity = Vector2.ZERO
 if value == State.ACTIVE: attacks += 1
 visual.queue_redraw()
func reset_enemy() -> void:
 global_position = origin
 current_health = 3
 facing = -1
 $SwordReceiver/CollisionShape2D.set_deferred("disabled",false)
 $CollisionShape2D.set_deferred("disabled",false)
 set_state(State.PATROL)
func receive_hit() -> void:
 if state == State.DEAD: return
 current_health = maxi(0,current_health-1)
 hits_received += 1
 flash = 0.12
 if current_health == 0:
  set_state(State.DEAD)
  $SwordReceiver/CollisionShape2D.set_deferred("disabled",true)
  $CollisionShape2D.set_deferred("disabled",true)
 elif state not in [State.WARNING,State.ACTIVE]:
  set_state(State.HURT,0.18)
 # Committed windup can be hit, but does not become a stun-lock cancellation.
func sees_target() -> bool:
 if not is_instance_valid(target) or target.survival.is_dead: return false
 var offset: Vector2 = target.global_position-global_position
 if absf(offset.x)>104 or absf(offset.y)>20: return false
 var view: Rect2 = Rect2(get_viewport().get_camera_2d().get_screen_center_position()-Vector2(160,90),Vector2(320,180))
 if not view.grow(-12).has_point(global_position+Vector2(0,-16)): return false
 return get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position+Vector2(0,-14),target.global_position+Vector2(0,-14),1)).is_empty()
func _physics_process(delta: float) -> void:
 age += delta
 flash = maxf(0,flash-delta)
 visual.queue_redraw()
 if state == State.DEAD: return
 if is_instance_valid(target) and target.survival.is_dead:
  source.set_active(false)
  velocity = Vector2.ZERO
  return
 remaining = maxf(0,remaining-delta)
 velocity.x = 0
 match state:
  State.WARNING:
   if remaining == 0: set_state(State.ACTIVE,0.14)
  State.ACTIVE:
   if remaining == 0: set_state(State.RECOVER,0.75)
  State.RECOVER, State.HURT:
   if remaining == 0: set_state(State.PATROL)
  _:
   if sees_target():
    var dx: float = target.global_position.x-global_position.x
    facing = 1 if dx>0 else -1
    if absf(dx)<=44: set_state(State.WARNING,0.55)
    else:
     state = State.CHASE
     velocity.x = facing*32.0
   else:
    state = State.PATROL
    if absf(global_position.x-origin.x)>=56: facing = -1 if global_position.x>origin.x else 1
    velocity.x = facing*23.0
   var ahead: Vector2 = global_position+Vector2(facing*14,-2)
   if get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(ahead,ahead+Vector2(0,12),1)).is_empty():
    velocity.x=0
    facing *= -1
 velocity.y = minf(velocity.y+680*delta,360)
 move_and_slide()
 global_position.x = clampf(global_position.x,origin.x-64,origin.x+64)
