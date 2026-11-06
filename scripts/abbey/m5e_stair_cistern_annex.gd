extends Node2D
## Separate spillway and counterweight study, outside mandatory room bounds.
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
const STAIR: Array[Rect2]=[Rect2(1216,252,80,32),Rect2(1304,228,64,12),Rect2(1376,204,72,12)]
const CISTERN: Array[Rect2]=[Rect2(1344,444,200,32),Rect2(1552,420,48,12)]
var floors: Array[Rect2]
var id: int
func _ready() -> void:
 id=get_parent().sector_id
 floors=STAIR if id==2 else CISTERN
 for rect: Rect2 in floors:
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
 var hue: Color=Color(0.70,0.73,0.68) if id==2 else Color(0.55,0.76,0.73)
 var hint_x: float=1180 if id==2 else 1308
 var hint_y: float=225 if id==2 else 417
 draw_texture_rect_region(STONE,Rect2(hint_x,hint_y,16,27),Rect2(1035,13,235,485),hue)
 for rect: Rect2 in floors:
  var bottom: float=284 if id==2 else 476
  draw_texture_rect_region(STONE,Rect2(rect.get_center().x-5,rect.end.y,10,bottom-rect.end.y),Rect2(1070,165,96,96),Color(hue,0.6))
  for x: int in range(int(rect.position.x),int(rect.end.x),48):
   var width: float=minf(48,rect.end.x-x)
   draw_texture_rect_region(STONE,Rect2(x,rect.position.y,width,12),Rect2(18,194,364*width/48,186),hue)
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("bdc6b6"),1)
 if id==2:
  draw_texture_rect_region(STONE,Rect2(1398,171,24,33),Rect2(238,512,300,490),Color(0.70,0.68,0.60,0.8))
 else:
  for x: int in [1380,1430,1480,1530]: draw_line(Vector2(x,461),Vector2(x+25,461),Color("72a59f"),0.8)
  draw_rect(Rect2(1568,410,16,8),Color("273643"))
  draw_line(Vector2(1570,413),Vector2(1582,413),Color("9bbeb6"),0.7)
