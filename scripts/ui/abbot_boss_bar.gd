extends Node2D
## Reuses the Guardian HUD's geometry, typography and colors unchanged.
var boss: Node
var font: Font=ThemeDB.fallback_font
func _process(_delta: float) -> void:
 queue_redraw()
func health_ratio() -> float:
 if not is_instance_valid(boss): return 0.0
 return clampf(float(boss.health)/maxi(1,boss.max_health),0.0,1.0)
func _draw() -> void:
 if not is_instance_valid(boss): return
 var title: String="ABADE DAS CORRENTES"
 var width: float=font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,8).x
 var ratio: float=health_ratio()
 draw_rect(Rect2(62,19,196,24),Color("10111f",0.88))
 draw_string(font,Vector2((320-width)/2,28),title,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("dbc7a0"))
 draw_rect(Rect2(76,32,168,6),Color("89765e"))
 draw_rect(Rect2(77,33,166,4),Color("272337"))
 draw_rect(Rect2(77,33,166*ratio,4),Color("8c3d55"))
 if boss.phase==2: draw_string(font,Vector2(253,38),"II",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("9de6d4"))
