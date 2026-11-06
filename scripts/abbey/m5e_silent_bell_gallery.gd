extends Node2D
## Optional upper workshop beyond the original Fundição exit.
const FLOORS: Array[Rect2]=[Rect2(1472,348,80,32),Rect2(1560,324,64,12),Rect2(1632,300,72,12)]
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
 # Broken masonry, bronze accents and a bell-shaped mould separate this room.
 draw_texture_rect_region(STONE,Rect2(1436,321,16,27),Rect2(1035,13,235,485),Color(0.76,0.69,0.58,0.8))
 for rect: Rect2 in FLOORS:
  var support_height: float=380-rect.end.y
  draw_texture_rect_region(STONE,Rect2(rect.get_center().x-5,rect.end.y,10,support_height),Rect2(1070,165,96,96),Color(0.55,0.50,0.42,0.65))
  for x: int in range(int(rect.position.x),int(rect.end.x),48):
   var width: float=minf(48,rect.end.x-x)
   draw_texture_rect_region(STONE,Rect2(x,rect.position.y,width,12),Rect2(18,194,364*width/48,186),Color(0.80,0.76,0.67))
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("c0b49c"),1)
 draw_texture_rect_region(STONE,Rect2(1655,267,24,33),Rect2(238,512,300,490),Color(0.8,0.72,0.60,0.85))
