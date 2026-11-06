extends Node2D
## Original Abade poses; the visual never controls the damage source or movement.
const ATLAS: Texture2D = preload("res://assets/art/m5g/abbot_fix02.png")
## Bottom alpha margin per atlas row/pose, measured at alpha >= 128.
const FOOT_OFFSETS: Array[float] = [4.45,4.64,4.25,4.64,10.06,10.25,10.06,10.25,11.02,11.02,11.02,11.22]
var ghosts: Array[Dictionary] = []
var clock: float = 0.0
var sample: float = 0.0
var previous_state: int = -1
var impact: float = 0.0
var defeat_blend: float = 1.0

func _process(delta: float) -> void:
 var b: Node = get_parent()
 clock += delta
 sample -= delta
 var dashing: bool = b.state==b.State.ACTIVE and b.pattern==b.Pattern.DASH
 if b.state==b.State.DEFEATED and previous_state>=0 and previous_state!=b.State.DEFEATED:
  defeat_blend=0.0
 if b.state==b.State.DEFEATED: defeat_blend=minf(1.0,defeat_blend+delta/0.20)
 else: defeat_blend=1.0
 if previous_state==b.State.ACTIVE and b.state==b.State.RECOVER and b.pattern==b.Pattern.DASH:
  impact=0.18
 previous_state=b.state
 impact=maxf(0.0,impact-delta)
 for i: int in range(ghosts.size()-1,-1,-1):
  ghosts[i].age += delta
  if ghosts[i].age>=0.18: ghosts.remove_at(i)
 if b.state==b.State.DEFEATED or not is_instance_valid(b.target) or b.target.survival.is_dead:
  ghosts.clear()
 elif dashing and sample<=0:
  ghosts.push_back({"position":global_position,"age":0.0,"facing":b.facing})
  if ghosts.size()>5: ghosts.pop_front()
  sample=0.035
 queue_redraw()

func _draw() -> void:
 var b: Node=get_parent()
 var frame: int=0
 match b.state:
  b.State.PURSUIT: frame=1 if int(clock*7)%2==0 else 0
  b.State.WARNING: frame=[2,4,6][b.pattern]
  b.State.ACTIVE: frame=[3,5,7][b.pattern]
  b.State.RECOVER: frame=8
  b.State.TRANSITION: frame=10
  b.State.DEFEATED: frame=11
 if b.flash>0 and b.state not in [b.State.TRANSITION,b.State.DEFEATED]: frame=9
 var cell: Vector2=ATLAS.get_size()/Vector2(4,3)
 var destination: Rect2=Rect2(-34,-70+FOOT_OFFSETS[frame],80,70)
 # The dash cape extends slightly into the otherwise empty gutter to its left.
 var dash_region: Rect2=Rect2(cell.x*3.0-30.0,cell.y,cell.x+30.0,cell.y)
 for g: Dictionary in ghosts:
  var offset: Vector2=to_local(g.position)
  draw_set_transform(offset,0,Vector2(g.facing,1))
  var ghost_destination: Rect2=Rect2(-34,-70+FOOT_OFFSETS[7],80,70)
  draw_texture_rect_region(ATLAS,ghost_destination,dash_region,Color(0.62,0.35,0.85,0.22*(1.0-g.age/0.18)))
 draw_set_transform(Vector2.ZERO,0,Vector2(b.facing,1))
 var tint: Color=Color(1.18,0.94,1.25) if b.phase==2 else Color.WHITE
 if b.flash>0: tint=Color(1.5,1.3,1.3)
 var region: Rect2=dash_region if frame==7 else Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell)
 if b.state==b.State.DEFEATED and defeat_blend<1.0:
  var hurt_destination: Rect2=Rect2(-34,-70+FOOT_OFFSETS[9],80,70)
  draw_texture_rect_region(ATLAS,hurt_destination,Rect2(Vector2(1,2)*cell,cell),Color(1,1,1,1.0-defeat_blend))
  tint.a=defeat_blend
 draw_texture_rect_region(ATLAS,destination,region,tint)
 if b.state==b.State.WARNING:
  draw_string(ThemeDB.fallback_font,Vector2(0,-72),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,10,Color("ffe8b0"))
  if b.pattern==b.Pattern.DASH:
   for i: int in range(4):
    draw_line(Vector2(-8-i*5,-42+i*2),Vector2(-11-i*5,-39+i*2),Color(0.75,0.48,0.91,0.8),1)
 if impact>0:
  for i: int in range(4):
   draw_rect(Rect2(-10-i*5,-2-i%2*3,2,2),Color(0.65,0.42,0.8,impact/0.18))
