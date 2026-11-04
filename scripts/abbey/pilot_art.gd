extends Node2D
## Imported original art; only the backdrop uses Linear. Ground follows real solids.
const BACKGROUNDS: Array[Texture2D] = [preload("res://assets/art/m5a/cloister.png"),preload("res://assets/art/m5a/gallery.png")]
const MATERIAL: Texture2D = preload("res://assets/art/m5a/architecture.png")
var view: Rect2
var last_cell: Vector2i = Vector2i(-999,-999)
func _ready() -> void:
 texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
func _process(_delta: float) -> void:
 var camera: Camera2D = get_viewport().get_camera_2d()
 if camera == null: return
 var local: Vector2 = camera.get_screen_center_position()-global_position
 var cell: Vector2i = Vector2i(local.round())
 if cell != last_cell:
  last_cell = cell
  view = Rect2(local-Vector2(160,90),Vector2(320,180))
  queue_redraw()
func _draw() -> void:
 var room_id: int = get_parent().room_id
 # Keep source detail at the same 480px canvas scale used by the approved M3 art.
 var parallax: Vector2 = (view.get_center()-Vector2(480,210))*Vector2(0.12,0.08)
 draw_texture_rect(BACKGROUNDS[room_id],Rect2(view.position-Vector2(80,30)-parallax,Vector2(480,240)),false,Color(0.78,0.83,0.87))
 for rect: Rect2 in AbbeyPilotLayout.surfaces(room_id):
  if not rect.intersects(view.grow(48)): continue
  # A modular carved cap, plus narrow masonry patches inside the solid only.
  var visible: Rect2 = rect.intersection(view.grow(32))
  if rect.size.y>24:
   for x: int in range(int(visible.position.x/32)*32,int(visible.end.x)+32,32):
    for y: int in range(int(rect.position.y)+8,int(visible.end.y)+32,32):
     var patch: Rect2 = Rect2(x,y,32,32).intersection(rect)
     var variant: int = posmod(x/32+y/32,3)
     if patch.has_area(): draw_texture_rect_region(MATERIAL,patch,Rect2(1070+variant*24,165+posmod(y/32,3)*48,96,96),Color(0.62,0.69,0.75))
  for cap_x: int in range(int(rect.position.x),int(rect.end.x),96):
   var width: float = minf(96,rect.end.x-cap_x)
   draw_texture_rect_region(MATERIAL,Rect2(cap_x,rect.position.y,width,minf(rect.size.y,22)),Rect2(18,194,728*width/96,186))
  draw_line(rect.position,rect.position+Vector2(rect.size.x,0),Color("b7c4bd"),1)
 if room_id == 0:
  draw_texture_rect_region(MATERIAL,Rect2(926,49,25,35),Rect2(992,600,310,390))
  draw_line(Vector2(771,148),Vector2(787,132),Color("c9b68c"),1)
  draw_string(ThemeDB.fallback_font,Vector2(899,45),"Votos sem nome",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("dcc596"))
 else:
  draw_string(ThemeDB.fallback_font,Vector2(520,239),"AGUARDE O CONTRAPESO",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("d3be8b"))
 for x: int in [28,936]:
  var y: float = 228 if x==936 and room_id==0 else 300
  draw_line(Vector2(x,y-34),Vector2(x,y-8),Color("c9af78"),1)
  draw_line(Vector2(x-4,y-12),Vector2(x,y-8),Color("c9af78"),1)
  draw_line(Vector2(x+4,y-12),Vector2(x,y-8),Color("c9af78"),1)
