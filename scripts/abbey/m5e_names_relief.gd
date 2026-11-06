extends Node2D
## A quiet, non-colliding trace beside the existing upper route.
func _draw() -> void:
 var light: Color=Color("c6b488")
 var shadow: Color=Color("273643")
 # Weathered carved plaque on the platform's face; no light, collider or UI.
 var rim: PackedVector2Array=PackedVector2Array([Vector2(859,109),Vector2(862,107),Vector2(872,107),Vector2(875,109),Vector2(874,117),Vector2(860,117)])
 draw_colored_polygon(rim,shadow)
 draw_polyline(rim,Color("899088"),0.8)
 draw_line(Vector2(862,110),Vector2(872,110),light,0.7)
 draw_line(Vector2(862,112),Vector2(870,112),light,0.7)
 draw_line(Vector2(863,114),Vector2(872,114),light,0.7)
 draw_line(Vector2(862,115),Vector2(873,108),Color("45535b"),0.7)
