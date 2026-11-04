extends Node2D
## Original raster backdrops and atlas materials; no collision in decoration.
const MATERIAL: Texture2D=preload("res://assets/art/m5a/architecture.png")
var background: Texture2D
var view: Rect2
var last_cell: Vector2i=Vector2i(-99999,-99999)
var id: int
func _ready() -> void:
 id=get_parent().sector_id
 texture_filter=CanvasItem.TEXTURE_FILTER_LINEAR
 var dir: String="m5a" if id in [1,5] else "m5b"
 background=load("res://assets/art/"+dir+"/"+AbbeyChapterLayout.KEYS[id]+".png") as Texture2D
func owns_backdrop() -> bool:
 return id not in [1,5]
func _process(_delta: float) -> void:
 var cam: Camera2D=get_viewport().get_camera_2d()
 if cam==null: return
 var cell: Vector2i=Vector2i((cam.get_screen_center_position()-global_position).round())
 if cell!=last_cell:
  last_cell=cell
  view=Rect2(Vector2(cell)-Vector2(160,90),Vector2(320,180))
  queue_redraw()
func _draw() -> void:
 if background==null: return
 # The pilot already paints the complete visible background, including X>960.
 # A second crop with a different anchor/parallax caused the seam at X=960.
 # Keep one original pilot backdrop across its full 1280px integrated sector.
 if owns_backdrop():
  var b: Rect2=AbbeyChapterLayout.bounds(id)
  var progress: Vector2=(view.get_center()-b.get_center())/b.size
  var parallax: Vector2=Vector2(clampf(progress.x*120,-58,58),clampf(progress.y*40,-20,20))
  var dest: Rect2=Rect2(view.position-Vector2(80,30)-parallax,Vector2(480,240))
  var clipped: Rect2=dest.intersection(Rect2(960,-1000,320,3000)) if id in [1,5] else dest
  if clipped.has_area():
   var source: Rect2=Rect2((clipped.position-dest.position)/dest.size*background.get_size(),clipped.size/dest.size*background.get_size())
   draw_texture_rect_region(background,clipped,source,Color(0.78,0.83,0.87))
 for r: Rect2 in AbbeyChapterLayout.main_surfaces(id):
  if id in [1,5]:
   r=r.intersection(Rect2(960,-1000,320,3000))
  if not r.has_area() or not r.intersects(view.grow(32)): continue
  var visible: Rect2=r.intersection(view.grow(32))
  var tint: Color=Color("8396a4")
  if id==4: tint=Color("698f8b")
  elif id==6: tint=Color("a29580")
  elif id==9: tint=Color("899b85")
  for x: int in range(int(visible.position.x/32)*32,int(visible.end.x)+32,32):
   for y: int in range(int(r.position.y)+8,int(visible.end.y)+32,32):
    var patch: Rect2=Rect2(x,y,32,32).intersection(r)
    if patch.has_area(): draw_texture_rect_region(MATERIAL,patch,Rect2(1070+posmod(x/32,3)*24,165+posmod(y/32,3)*48,96,96),tint)
  for x: int in range(int(r.position.x),int(r.end.x),96):
   var w: float=minf(96,r.end.x-x)
   draw_texture_rect_region(MATERIAL,Rect2(x,r.position.y,w,22),Rect2(18,194,728*w/96,186))
  draw_line(r.position,r.position+Vector2(r.size.x,0),Color("bdc6b6"),1)
 # Dark intrados are ceilings, with no bright walkable cap. Clearance is physical.
 for r: Rect2 in AbbeyChapterLayout.ceilings(id):
  var top: float=AbbeyChapterLayout.bounds(id).position.y-180
  var stone: Rect2=Rect2(r.position.x,top,r.size.x,r.end.y-top)
  if not stone.intersects(view): continue
  var visible: Rect2=stone.intersection(view.grow(32))
  for x: int in range(floori(visible.position.x/32)*32,ceili(visible.end.x/32)*32,32):
   for y: int in range(floori(visible.position.y/32)*32,ceili(visible.end.y/32)*32,32):
    var tile: Rect2=Rect2(x,y,32,32)
    var patch: Rect2=tile.intersection(stone)
    var source: Rect2=Rect2(Vector2(1070+posmod(x/32,3)*24,165+posmod(y/32,3)*48)+(patch.position-tile.position)*3,patch.size*3)
    if patch.has_area(): draw_texture_rect_region(MATERIAL,patch,source,Color(0.35,0.43,0.46))
  draw_set_transform(Vector2(r.position.x,r.end.y),0,Vector2(1,-1))
  for x: int in range(0,int(r.size.x),96):
   var w: float=minf(96,r.size.x-x)
   draw_texture_rect_region(MATERIAL,Rect2(x,0,w,12),Rect2(18,194,728*w/96,186),Color(0.42,0.49,0.51))
  draw_set_transform(Vector2.ZERO)
 # Small material signatures foreground the route without masking the next tread.
 for r: Rect2 in AbbeyChapterLayout.main_surfaces(id):
  var p: Vector2=Vector2(r.get_center().x,r.position.y)
  if id in [1,5] and p.x<960: continue
  if not view.grow(40).has_point(p): continue
  if id in [2,10]:
   draw_line(p+Vector2(0,-88),p+Vector2(0,-48),Color("736c5b"),1)
   draw_texture_rect_region(MATERIAL,Rect2(p+Vector2(-10,-55),Vector2(20,26)),Rect2(225,648,310,370),Color(0.5,0.57,0.61))
  elif id==4:
   for i: int in range(3): draw_line(p+Vector2(-22+i*6,12),p+Vector2(6+i*6,12),Color("5f9693"),1)
  elif id==9:
   for i: int in range(5): draw_line(p+Vector2(i*3,-2),p+Vector2(i*3-2,-7-i%3),Color("7f8f78"),1)
  elif id in [0,8,11]:
   draw_texture_rect_region(MATERIAL,Rect2(p+Vector2(-8,-22),Vector2(16,22)),Rect2(992,600,310,390),Color(0.7,0.74,0.72))
 # Door marks stay in the authored room and are distinct from landing edges.
 for backwards: bool in [false,true]:
  var p: Vector2=AbbeyChapterLayout.exit_point(id,backwards)
  var side: int=AbbeyChapterLayout.direction(id)*(-1 if backwards else 1)
  draw_line(p+Vector2(-side*7,-24),p+Vector2(side*3,-24),Color("dcc394"),1)
  draw_line(p+Vector2(0,-27),p+Vector2(side*3,-24),Color("dcc394"),1)
  draw_line(p+Vector2(0,-21),p+Vector2(side*3,-24),Color("dcc394"),1)
