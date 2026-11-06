extends Node2D
## Physical service corridor between paired room doors. It is not a shortcut by teleport.
const WIDTHS: Array[int]=[192,208,1056]
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
var index: int=0
func configure(which: int) -> void: index=which
func _ready() -> void:
 var body: StaticBody2D=StaticBody2D.new()
 body.position=Vector2(0,300)
 body.collision_layer=1
 body.collision_mask=2|256
 var cs: CollisionShape2D=CollisionShape2D.new()
 var shape: RectangleShape2D=RectangleShape2D.new()
 shape.size=Vector2(WIDTHS[index],40)
 cs.shape=shape
 cs.position=shape.size/2
 body.add_child(cs)
 add_child(body)
func snapshot() -> Dictionary: return {}
func disarm() -> void: pass
func reset_encounters() -> void: pass
func _draw() -> void:
 var width: int=WIDTHS[index]
 draw_rect(Rect2(-160,150,width+320,180),Color("1b2930"))
 for x: int in range(-192,width+192,32):
  for y: int in range(150,300,32):
   draw_texture_rect_region(STONE,Rect2(x,y,32,32),Rect2(1070,165,96,96),Color(0.26,0.34,0.36))
 for x: int in range(-192,width+192,48):
  var w: float=48.0
  draw_texture_rect_region(STONE,Rect2(x,300,w,12),Rect2(18,194,364*w/48,186),Color(0.70,0.73,0.70))
 draw_line(Vector2(0,300),Vector2(width,300),Color("adbab0"),1)
 for x: int in [20,width-20]:
  draw_texture_rect_region(STONE,Rect2(x-10,268,20,32),Rect2(1035,13,235,485),Color(0.68,0.73,0.70))
