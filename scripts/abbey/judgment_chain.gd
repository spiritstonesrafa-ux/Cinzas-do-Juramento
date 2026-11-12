extends DamageSource
## One fixed, announced impact. The visible chain occupies the same ground region as its box.
var owner_boss: Node
var age: float=0.0
var armed: bool=true
var consumed: bool=false
var collider: CollisionShape2D
const WARNING: float=0.72
const ACTIVE: float=0.18
func _ready() -> void:
 collision_layer=32
 collision_mask=16
 monitoring=false
 process_physics_priority=-3
 collider=CollisionShape2D.new()
 var box: RectangleShape2D=RectangleShape2D.new()
 box.size=Vector2(24,48)
 collider.shape=box
 collider.position=Vector2(0,-24)
 collider.disabled=true
 add_child(collider)
func _physics_process(delta: float) -> void:
 if not armed:return
 if not is_instance_valid(owner_boss) or owner_boss.state==owner_boss.State.DEFEATED:
  disarm(); queue_free(); return
 age+=delta
 collider.set_deferred("disabled",not (age>=WARNING and age<WARNING+ACTIVE))
 if age>=WARNING+ACTIVE:
  disarm(); queue_free(); return
 queue_redraw()
func disarm() -> void:
 armed=false
 if is_instance_valid(collider):collider.set_deferred("disabled",true)
func contact_damage(receiver_id: int) -> int:
 if not armed or consumed or age<WARNING or age>=WARNING+ACTIVE:return 0
 var player: KnightController=instance_from_id(receiver_id) as KnightController
 if player==null or player.survival.is_dead:return 0
 consumed=true
 return 1
func _draw() -> void:
 if not armed:return
 var ink: Color=Color("302933")
 var iron: Color=Color("a5959b")
 var glint: Color=Color("e7c6af")
 if age<WARNING:
  # A low, bounded floor seal announces exactly the width of the danger.
  var pulse: float=clampf(age/WARNING,0.0,1.0)
  var glow: Color=Color(0.72,0.36,0.52,0.35+pulse*0.5)
  draw_line(Vector2(-12,-1),Vector2(12,-1),glow,1.5)
  draw_arc(Vector2(0,-2),10,PI,TAU,16,glow,1.0)
  for side: int in [-1,1]:
   draw_line(Vector2(side*12,-1),Vector2(side*9,-5-pulse*2),glow,1)
   draw_line(Vector2(side*9,-5-pulse*2),Vector2(side*6,-1),glow,1)
 else:
  # Interlocking iron links travel from the caster to the floor impact.
  var start: Vector2=Vector2(0,-100)
  if is_instance_valid(owner_boss):start=to_local(owner_boss.global_position+Vector2(0,-28))
  var finish: Vector2=Vector2(0,-4)
  var middle: Vector2=start.lerp(finish,0.5)+Vector2(signf(finish.x-start.x)*8,12)
  var points: PackedVector2Array=PackedVector2Array()
  for i: int in range(21):
   var t: float=float(i)/20.0
   points.append(start*(1-t)*(1-t)+middle*2*t*(1-t)+finish*t*t)
  draw_polyline(points,Color(0.18,0.13,0.18,0.65),3.0)
  var chain_length: float=0.0
  for i: int in range(1,points.size()):chain_length+=points[i-1].distance_to(points[i])
  var link_count: int=maxi(1,ceili(chain_length/7.0))
  for i: int in range(link_count):
   var t: float=(float(i)+0.5)/link_count
   var point: Vector2=start*(1-t)*(1-t)+middle*2*t*(1-t)+finish*t*t
   var tangent: Vector2=(middle-start)*2*(1-t)+(finish-middle)*2*t
   var tilt: float=0.20 if i%2==0 else -0.20
   draw_set_transform(point,tangent.angle()+tilt,Vector2(1.0,0.57 if i%2==0 else 0.78))
   draw_arc(Vector2.ZERO,3.2,0,TAU,12,ink,2.3)
   draw_arc(Vector2.ZERO,3.2,0,TAU,12,iron,1.0)
   draw_line(Vector2(-1,-3),Vector2(1,-3),glint,0.7)
   draw_set_transform(Vector2.ZERO)
  var fade: float=1.0-clampf((age-WARNING)/ACTIVE,0.0,1.0)
  draw_arc(Vector2(0,-2),10,PI,TAU,14,Color(0.92,0.68,0.58,fade),1.5)
  for i: int in range(5):
   var x: float=(i-2)*4
   draw_line(Vector2(x,0),Vector2(x*1.35,-5-((i*7)%4)),Color(0.95,0.72,0.58,fade),1)
