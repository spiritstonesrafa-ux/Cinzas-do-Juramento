extends Node2D
## Optional chapel gallery, built after the isolated bidirectional jump fixture.
const LEDGES: Array[Rect2]=[Rect2(968,60,48,12),Rect2(1028,84,48,12),Rect2(1088,108,120,12)]
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
func _ready() -> void:
 for rect: Rect2 in LEDGES:
  var body: StaticBody2D=StaticBody2D.new()
  body.position=rect.position
  body.collision_layer=1
  body.collision_mask=2|256
  var shape_node: CollisionShape2D=CollisionShape2D.new()
  var shape: RectangleShape2D=RectangleShape2D.new()
  shape.size=rect.size
  shape_node.shape=shape
  shape_node.position=rect.size/2
  body.add_child(shape_node)
  add_child(body)
func _draw() -> void:
 for rect: Rect2 in LEDGES:
  # Reuse abbey masonry for recessed decorative supports, without collision.
  var base_y: float=228.0
  for y: int in range(int(rect.end.y),int(base_y),24):
   var h: float=minf(24,base_y-y)
   draw_texture_rect_region(STONE,Rect2(rect.get_center().x-4,y,8,h),Rect2(1070,165,96,96*h/24),Color(0.52,0.59,0.61,0.65))
  for x: int in range(int(rect.position.x),int(rect.end.x),48):
   var w: float=minf(48,rect.end.x-x)
   draw_texture_rect_region(STONE,Rect2(x,rect.position.y,w,12),Rect2(18,194,364*w/48,186),Color(0.82,0.87,0.89))
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("b7c4bd"),1)
 # Recessed name tablet; separate from the existing Votos sem Nome monument.
 draw_rect(Rect2(1138,96,19,10),Color("273643"))
 draw_line(Vector2(1140,98),Vector2(1154,98),Color("c6b488"),0.7)
 draw_line(Vector2(1140,101),Vector2(1152,101),Color("c6b488"),0.7)
 draw_line(Vector2(1141,104),Vector2(1154,104),Color("c6b488"),0.7)
 # Recessed chapel arch and altar are background ornament, never collision.
 draw_texture_rect_region(STONE,Rect2(1090,66,18,42),Rect2(1035,13,235,485),Color(0.64,0.70,0.72,0.8))
 draw_texture_rect_region(STONE,Rect2(1186,66,18,42),Rect2(1035,13,235,485),Color(0.64,0.70,0.72,0.8))
 draw_texture_rect_region(STONE,Rect2(1090,59,114,10),Rect2(18,194,728,186),Color(0.64,0.70,0.72,0.8))
