extends DamageSource
## Standalone M5-C2 hazards; use the existing M2 damage contract.
enum State { SAFE, WARNING, ACTIVE, RECOVER }
@export_range(0,2,1) var family: int=0
var state: State=State.SAFE
var elapsed: float=0.0
var remaining: float=1.8
var cycles: int=0
var target: KnightController
var contacts: Array[int]=[]
var shape: CollisionShape2D
const TIMES: Array[Array]=[[1.8,0.8,1.2,1.4],[1.6,0.8,0.5,1.5],[1.8,0.8,0.7,1.4]]
const ART: Array[Texture2D]=[preload("res://assets/art/m5c2/pendulum.png"),preload("res://assets/art/m5c2/gate.png"),preload("res://assets/art/m5c2/incense.png")]
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
const SMOKE: Texture2D=preload("res://assets/art/m5c2/incense_smoke.png")
func _ready() -> void:
 process_physics_priority=-2
 collision_layer=32
 collision_mask=16
 monitoring=false
 shape=CollisionShape2D.new()
 var rect: RectangleShape2D=RectangleShape2D.new()
 rect.size=[Vector2(24,24),Vector2(20,48),Vector2(40,16)][family]
 shape.shape=rect
 add_child(shape)
 reset_hazard()
func reset_hazard() -> void:
 process_mode=Node.PROCESS_MODE_INHERIT
 state=State.SAFE
 elapsed=0
 remaining=TIMES[family][0]
 contacts.clear()
 shape.set_deferred("disabled",true)
 update_shape()
 queue_redraw()
func disarm() -> void:
 process_mode=Node.PROCESS_MODE_DISABLED
 shape.set_deferred("disabled",true)
func update_shape() -> void:
 if family==0:
  var x: float=0.0
  if state==State.ACTIVE: x=lerpf(-30,30,clampf(elapsed/TIMES[0][2],0,1))
  elif state==State.RECOVER: x=lerpf(30,-30,clampf(elapsed/TIMES[0][3],0,1))
  else: x=-30
  shape.position=Vector2(x,-18)
 elif family==1: shape.position=Vector2(0,-24)
 else: shape.position=Vector2(38,-16)
func _physics_process(delta: float) -> void:
 elapsed+=delta
 if family==1 and state==State.SAFE:
  remaining=maxf(0,remaining-delta)
  if remaining<=0 and is_instance_valid(target) and not target.survival.is_dead and absf(target.global_position.x-global_position.x)<85 and absf(target.global_position.y-global_position.y)<28:
   state=State.WARNING
   elapsed=0
   remaining=TIMES[family][state]
 else:
  remaining-=delta
  if remaining<=0:
   state=((int(state)+1)%4) as State
   elapsed=0
   remaining=TIMES[family][state]
   if state==State.ACTIVE: contacts.clear()
   if state==State.SAFE: cycles+=1
 update_shape()
 shape.disabled=state!=State.ACTIVE
 queue_redraw()
func contact_damage(receiver_id: int) -> int:
 if state!=State.ACTIVE or contacts.has(receiver_id): return 0
 contacts.append(receiver_id)
 return 1
func _draw() -> void:
 var tex: Texture2D=ART[family]
 if family==0:
  var pivot: Vector2=Vector2(0,-90)
  draw_line(pivot,shape.position,Color("ac9368"),2)
  draw_texture_rect(tex,Rect2(shape.position+Vector2(-18,-20),Vector2(36,40)),false)
  if state==State.WARNING: draw_line(Vector2(-42,-3),Vector2(42,-3),Color("e8c883"),1)
 elif family==1:
  draw_texture_rect(tex,Rect2(-25,-70,50,70),false)
  var bolt_x: float=lerpf(0,8,clampf(elapsed/0.8,0,1)) if state==State.WARNING else (8 if state==State.ACTIVE else 0)
  draw_line(Vector2(-8+bolt_x,-50),Vector2(8+bolt_x,-50),Color("e8c883"),2)
  if state==State.WARNING: draw_line(Vector2(-10,-47),Vector2(10,-47),Color("f0cb7d"),1)
  if state in [State.ACTIVE,State.RECOVER]:
   var shutter_y: float=-48.0
   if state==State.RECOVER: shutter_y-=48*clampf(elapsed/TIMES[1][3],0,1)
   draw_texture_rect_region(STONE,Rect2(-10,shutter_y,20,48),Rect2(1070,165,96,96),Color(0.85,0.72,0.55))
  if state==State.ACTIVE:
   draw_line(Vector2(-10,-1),Vector2(10,-1),Color("f3df9b"),1)
 else:
  draw_texture_rect(tex,Rect2(-24,-45,48,45),false)
  if state==State.WARNING: draw_line(Vector2(18,-16),Vector2(58,-16),Color("e8c883"),1)
  if state==State.ACTIVE:
   var cell: Vector2=SMOKE.get_size()/Vector2(4,1)
   var frame: int=mini(3,int(elapsed/0.175))
   draw_texture_rect_region(SMOKE,Rect2(18,-24,40,16),Rect2(Vector2(frame*cell.x,cell.y*0.2),Vector2(cell.x,cell.y*0.65)))
   for x in range(18,58,8):
    draw_line(Vector2(x,-24),Vector2(x+4,-24),Color(0.9,0.79,0.58,0.8),1)
    draw_line(Vector2(x,-8),Vector2(x+4,-8),Color(0.9,0.79,0.58,0.8),1)
