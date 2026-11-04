class_name AbbeyCounterweight
extends DamageSource
## New pilot hazard. Only the falling weight is offensive; no instant kill.
enum State { SAFE, WARNING, ACTIVE, RECOVER }
const DURATIONS: Array[float] = [1.8,0.8,0.4,1.2]
const ART: Texture2D = preload("res://assets/art/m5a/architecture.png")
var state: State = State.SAFE
var remaining: float = 1.8
var elapsed: float = 0
var cycles: int = 0
var contacted: Array[int] = []
@onready var shape: CollisionShape2D = $CollisionShape2D
func _ready() -> void:
 process_physics_priority = -2
 reset_hazard()
func reset_hazard() -> void:
 process_mode = Node.PROCESS_MODE_INHERIT
 state = State.SAFE
 remaining = DURATIONS[0]
 elapsed = 0
 contacted.clear()
 shape.set_deferred("disabled",true)
 shape.position.y = -84
 queue_redraw()
func offset_y() -> float:
 if state == State.ACTIVE: return lerpf(-84,-14,clampf(elapsed/0.28,0,1))
 if state == State.RECOVER: return lerpf(-14,-84,clampf(elapsed/1.2,0,1))
 return -84
func _physics_process(delta: float) -> void:
 elapsed += delta
 remaining -= delta
 if remaining <= 0:
  state = ((int(state)+1)%4) as State
  remaining = DURATIONS[state]
  elapsed = 0
  if state == State.SAFE: cycles += 1
  if state == State.ACTIVE: contacted.clear()
 shape.position.y = offset_y()
 shape.disabled = state != State.ACTIVE
 queue_redraw()
func contact_damage(receiver_id: int) -> int:
 if state != State.ACTIVE or contacted.has(receiver_id): return 0
 contacted.append(receiver_id)
 return 1
func _draw() -> void:
 var y: float = offset_y()
 draw_line(Vector2(0,-144),Vector2(0,y-20),Color("9a8059"),2)
 draw_texture_rect_region(ART,Rect2(-20,y-23,40,43),Rect2(225,648,310,370))
 var tint: Color = Color("d9bf82") if state == State.WARNING else Color("728785")
 draw_line(Vector2(-25,-1),Vector2(25,-1),tint,1)
 for side: int in [-1,1]: draw_line(Vector2(side*25,-4),Vector2(side*21,-8),tint,1)
 if state == State.WARNING:
  draw_string(ThemeDB.fallback_font,Vector2(-3,-39),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("fff0b9"))
