extends "res://scripts/abbey/monk.gd"
## Experimental controlled-demo enemy; approved monk remains untouched.
@export_range(0,2,1) var archetype: int=0
var missile: Node2D
func reset_enemy() -> void:
 super.reset_enemy()
 current_health=3 if archetype==2 else 2
 if is_instance_valid(missile): missile.queue_free()
 missile=null
func set_state(value: State, seconds: float=0) -> void:
 super.set_state(value,seconds)
 if value==State.ACTIVE and archetype==0:
  source.set_active(false)
  missile=Area2D.new()
  missile.set_script(load("res://scripts/abbey/m5c1_projectile.gd"))
  missile.set("direction",facing)
  get_parent().add_child(missile)
  missile.global_position=global_position+Vector2(facing*18,-14)
 if value==State.DEAD and is_instance_valid(missile):
  missile.queue_free()
  missile=null
func _physics_process(delta: float) -> void:
 age+=delta
 flash=maxf(0,flash-delta)
 visual.queue_redraw()
 if state==State.DEAD: return
 if not is_instance_valid(target) or target.survival.is_dead:
  source.set_active(false)
  velocity=Vector2.ZERO
  return
 remaining=maxf(0,remaining-delta)
 velocity.x=0
 match state:
  State.WARNING:
   if remaining==0: set_state(State.ACTIVE,0.18 if archetype!=1 else 0.30)
  State.ACTIVE:
   if archetype==1: velocity.x=facing*72.0
   if remaining==0: set_state(State.RECOVER,0.90)
  State.RECOVER,State.HURT:
   if remaining==0: set_state(State.PATROL)
  _:
   if sees_target():
    var dx: float=target.global_position.x-global_position.x
    facing=1 if dx>0 else -1
    var attack_range: float=[92.0,52.0,50.0][archetype]
    if absf(dx)<=attack_range: set_state(State.WARNING,0.75 if archetype!=1 else 0.65)
    elif archetype!=2: velocity.x=facing*(26.0 if archetype==0 else 40.0)
   elif archetype==1:
    if absf(global_position.x-origin.x)>=40: facing=-1 if global_position.x>origin.x else 1
    velocity.x=facing*22.0
 if velocity.x!=0:
  var ahead: Vector2=global_position+Vector2(signf(velocity.x)*14,-2)
  if get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(ahead,ahead+Vector2(0,12),1)).is_empty(): velocity.x=0
 velocity.y=minf(velocity.y+680*delta,360)
 move_and_slide()
 global_position.x=clampf(global_position.x,origin.x-64,origin.x+64)
func _exit_tree() -> void:
 if is_instance_valid(missile): missile.queue_free()
