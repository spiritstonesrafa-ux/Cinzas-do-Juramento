extends Node2D
## An isolated reading gallery beyond the archive's ordinary threshold.
const FLOORS: Array[Rect2]=[Rect2(1344,228,72,32),Rect2(1424,204,72,12),Rect2(1504,180,72,12)]
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
func _ready() -> void:
 for rect: Rect2 in FLOORS:
  var body: StaticBody2D=StaticBody2D.new()
  body.position=rect.position
  body.collision_layer=1
  body.collision_mask=2|256
  var cs: CollisionShape2D=CollisionShape2D.new()
  var shape: RectangleShape2D=RectangleShape2D.new()
  shape.size=rect.size
  cs.shape=shape
  cs.position=rect.size/2
  body.add_child(cs)
  add_child(body)
func _draw() -> void:
 draw_texture_rect_region(STONE,Rect2(1308,201,16,27),Rect2(1035,13,235,485),Color(0.72,0.72,0.67,0.8))
 for rect: Rect2 in FLOORS:
  var support_height: float=260-rect.end.y
  draw_texture_rect_region(STONE,Rect2(rect.get_center().x-5,rect.end.y,10,support_height),Rect2(1070,165,96,96),Color(0.51,0.53,0.55,0.65))
  for x: int in range(int(rect.position.x),int(rect.end.x),48):
   var width: float=minf(48,rect.end.x-x)
   draw_texture_rect_region(STONE,Rect2(x,rect.position.y,width,12),Rect2(18,194,364*width/48,186),Color(0.76,0.77,0.73))
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("bdc1b3"),1)
 draw_rect(Rect2(1529,168,22,10),Color("273643"))
 for y: int in [170,173,176]: draw_line(Vector2(1532,y),Vector2(1547,y),Color("c6b99a"),0.7)
