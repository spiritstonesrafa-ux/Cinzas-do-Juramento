extends Node2D
const ART: Texture2D = preload("res://assets/art/m5a/monk.png")
func _draw() -> void:
 var monk: ChainedMonk = get_parent() as ChainedMonk
 var frame: int = 0
 match monk.state:
  ChainedMonk.State.PATROL,ChainedMonk.State.CHASE: frame = 1+int(monk.age*8)%2
  ChainedMonk.State.WARNING: frame = 3
  ChainedMonk.State.ACTIVE: frame = 4
  ChainedMonk.State.RECOVER: frame = 5
  ChainedMonk.State.HURT: frame = 6
  ChainedMonk.State.DEAD: frame = 7
 var cell: Vector2 = ART.get_size()/Vector2(4,2)
 draw_set_transform(Vector2.ZERO,0,Vector2(monk.facing,1))
 var tint: Color = Color(1.7,1.6,1.45) if monk.flash>0 else Color.WHITE
 draw_texture_rect_region(ART,Rect2(-25,-40,64,44),Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell),tint)
 if monk.state == ChainedMonk.State.WARNING:
  draw_line(Vector2(8,-18),Vector2(42,-18),Color("e8c883"),1)
  draw_line(Vector2(40,-21),Vector2(44,-18),Color("fff0c7"),1)
 if monk.state == ChainedMonk.State.ACTIVE:
  draw_line(Vector2(8,-14),Vector2(50,-14),Color("c7b48a"),2)
