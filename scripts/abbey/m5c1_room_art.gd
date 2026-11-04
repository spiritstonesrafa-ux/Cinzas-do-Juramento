extends Node2D
const BACKGROUND: Texture2D = preload("res://assets/art/m5a/gallery.png")
const MATERIAL: Texture2D = preload("res://assets/art/m5a/architecture.png")
var view: Rect2
func _ready() -> void:
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
func _process(_delta: float) -> void:
 var camera: Camera2D=get_viewport().get_camera_2d()
 if camera:
  view=Rect2(camera.get_screen_center_position()-global_position-Vector2(160,90),Vector2(320,180))
  queue_redraw()
func _draw() -> void:
 var parallax: Vector2=(view.get_center()-Vector2(480,210))*Vector2(0.12,0.08)
 draw_texture_rect(BACKGROUND,Rect2(view.position-Vector2(80,30)-parallax,Vector2(480,240)),false,Color(0.78,0.83,0.87))
 for x in range(0,960,96):
  draw_texture_rect_region(MATERIAL,Rect2(x,300,96,22),Rect2(18,194,728,186))
 if get_meta("archetype",0)==1:
  draw_texture_rect_region(MATERIAL,Rect2(672,276,128,12),Rect2(18,194,728,186))
 for x in range(0,960,32):
  for y in range(320,420,32):
   draw_texture_rect_region(MATERIAL,Rect2(x,y,32,32),Rect2(1070+posmod(x/32+y/32,3)*24,165,96,96),Color(0.62,0.69,0.75))
