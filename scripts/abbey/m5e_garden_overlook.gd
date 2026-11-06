extends Node2D
## Lateral terrace beside the normal exit; no collision over the main spine.
const FLOOR: Rect2=Rect2(1216,276,240,32)
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
func _ready() -> void:
 var body: StaticBody2D=StaticBody2D.new()
 body.position=FLOOR.position
 body.collision_layer=1
 body.collision_mask=2|256
 var cs: CollisionShape2D=CollisionShape2D.new()
 var shape: RectangleShape2D=RectangleShape2D.new()
 shape.size=FLOOR.size
 cs.shape=shape
 cs.position=FLOOR.size/2
 body.add_child(cs)
 add_child(body)
func _draw() -> void:
 # A small overgrown masonry fragment beside the existing exit hints at the
 # continuation while the mandatory doorway remains clearly visible.
 draw_texture_rect_region(STONE,Rect2(1180,249,16,27),Rect2(1035,13,235,485),Color(0.68,0.74,0.66,0.8))
 for i: int in range(4):
  draw_line(Vector2(1184+i*3,251),Vector2(1181+i*3,244-i%2*3),Color("95ad89"),0.8)
 for x: int in range(1216,1456,48):
  draw_texture_rect_region(STONE,Rect2(x,276,48,12),Rect2(18,194,364,186),Color(0.78,0.84,0.79))
  draw_texture_rect_region(STONE,Rect2(x,288,48,20),Rect2(1070,165,96,96),Color(0.60,0.68,0.62))
 draw_line(Vector2(1216,276),Vector2(1456,276),Color("b7c4b0"),1)
 for x: int in [1248,1320,1392,1440]:
  draw_texture_rect_region(STONE,Rect2(x-6,245,12,31),Rect2(1035,13,235,485),Color(0.64,0.71,0.64,0.7))
  for i: int in range(3):
   draw_line(Vector2(x+i*3,274),Vector2(x+i*3-3,267-i*2),Color("8ca884"),0.8)
 draw_rect(Rect2(1391,265,18,9),Color("273643"))
 draw_line(Vector2(1394,268),Vector2(1406,268),Color("b7c596"),0.7)
 draw_line(Vector2(1394,271),Vector2(1405,271),Color("b7c596"),0.7)
