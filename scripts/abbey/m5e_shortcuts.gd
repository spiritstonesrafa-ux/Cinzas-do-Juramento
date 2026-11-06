extends Node2D
## Paired service doors reuse the chapter's asynchronous room handoff.
## [earlier sector, local x, later sector, local x]
const LINKS: Array = [[2,1040.0,3,250.0],[6,1360.0,7,280.0],[8,1270.0,10,270.0]]
const STONE: Texture2D=preload("res://assets/art/m5a/architecture.png")
static func point(id: int, x: float) -> Vector2:
 for r: Rect2 in AbbeyChapterLayout.main_surfaces(id):
  if x>=r.position.x and x<r.end.x: return Vector2(x,r.position.y)
 return Vector2(x,INF)
static func index_in(id: int) -> int:
 for i: int in range(LINKS.size()):
  if id==LINKS[i][0] or id==LINKS[i][2]: return i
 return -1
func _draw() -> void:
 var id: int=get_parent().sector_id
 var index: int=index_in(id)
 if index<0: return
 var pair: Array=LINKS[index]
 var x: float=pair[1] if id==pair[0] else pair[3]
 var p: Vector2=point(id,x)
 draw_texture_rect_region(STONE,Rect2(p+Vector2(-10,-32),Vector2(20,32)),Rect2(1035,13,235,485),Color(0.74,0.78,0.75,0.9))
 draw_line(p+Vector2(-6,-23),p+Vector2(6,-23),Color("c6b488"),1)
 draw_line(p+Vector2(0,-28),p+Vector2(0,-19),Color("c6b488"),1)
