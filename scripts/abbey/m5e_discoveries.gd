extends Node2D
## Narrative details on existing surfaces; zero-based room IDs.
const DATA: Dictionary={
 2: {"x":820.0,"text":"Contrapeso partido: alguém rompeu a corrente por dentro.","accent":Color("b7aaa0")},
 4: {"x":550.0,"text":"Ossuário votivo: a água guardou os nomes que a pedra perdeu.","accent":Color("9bbeb6")},
 6: {"x":885.0,"text":"Sino mudo: neste molde repousa um chamado que nunca soou.","accent":Color("c6a66f")},
 8: {"x":1120.0,"text":"Registro sem assinatura: um juramento foi deixado em branco.","accent":Color("c4b99b")},
 9: {"x":700.0,"text":"Mirante da Abadia: raízes guardam os caminhos dos ausentes.","accent":Color("a4bb92")}
}
static func location(id: int) -> Vector2:
 var x: float=DATA[id].x
 for r: Rect2 in AbbeyChapterLayout.main_surfaces(id):
  if x>=r.position.x and x<r.end.x: return Vector2(x,r.position.y)
 return Vector2(x,INF)
func _draw() -> void:
 var id: int=get_parent().sector_id
 if not DATA.has(id): return
 var p: Vector2=location(id)
 var edge: PackedVector2Array=PackedVector2Array([p+Vector2(-8,1),p+Vector2(-5,-1),p+Vector2(5,-1),p+Vector2(8,1),p+Vector2(7,9),p+Vector2(-7,9)])
 draw_colored_polygon(edge,Color("273643"))
 draw_polyline(edge,Color("899088"),0.8)
 var color: Color=DATA[id].accent
 draw_line(p+Vector2(-5,2),p+Vector2(5,2),color,0.7)
 draw_line(p+Vector2(-5,4),p+Vector2(3,4),color,0.7)
 draw_line(p+Vector2(-4,6),p+Vector2(5,6),color,0.7)
 draw_line(p+Vector2(-5,7),p+Vector2(6,0),Color("45535b"),0.7)
