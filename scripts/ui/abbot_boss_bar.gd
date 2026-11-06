extends Node2D
## Reuses the Guardian HUD's geometry, typography and colors unchanged.
var boss: Node
var font: Font=ThemeDB.fallback_font
func _process(_delta: float) -> void:
 queue_redraw()
func health_ratio() -> float:
 if not is_instance_valid(boss): return 0.0
 return clampf(float(boss.health)/maxi(1,boss.max_health),0.0,1.0)
func _center(text: String, y: float, size: int, color: Color) -> void:
 var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
 draw_string(font, Vector2((320.0 - width) * 0.5, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw_conclusion() -> void:
 var ending: Node2D = boss.get_node("Conclusion")
 var clock: float = ending.elapsed
 if clock < 0.55:
  var opacity: float = 1.0 - clock / 0.55
  draw_rect(Rect2(76, 32, 168, 6), Color(0.54, 0.46, 0.37, opacity))
  draw_rect(Rect2(77, 33, 166, 4), Color(0.15, 0.14, 0.22, opacity))
 elif clock >= 1.0 and clock < 9.0:
  var opacity: float = clampf((clock - 1.0) / 0.4, 0.0, 1.0)
  draw_rect(Rect2(28, 18, 264, 58), Color(0.06, 0.07, 0.11, 0.88 * opacity))
  _center(ending.TITLE, 29, 8, Color(0.86, 0.78, 0.63, opacity))
  _center(ending.PHASE_TEXT, 40, 7, Color(0.74, 0.83, 0.79, opacity))
  _center(ending.NARRATIVE, 51, 7, Color(0.77, 0.75, 0.71, opacity))
  if clock >= 1.6:
   _center(ending.REWARD_TITLE, 62, 7, Color(0.75, 0.48, 0.91, opacity))
   _center(ending.REWARD_HINT, 71, 7, Color(1.0, 0.91, 0.69, opacity))
 elif clock >= 9.0:
  draw_rect(Rect2(49, 20, 222, 14), Color("10111f", 0.88))
  _center("Abadia concluída · Abade vencido", 30, 7, Color("c4b99d"))
 if clock >= 1.6:
  draw_rect(Rect2(32, 164, 256, 14), Color("10111f", 0.88))
  _center("Retorne pelo portal à esquerda (E).", 174, 7, Color("e3d2ac"))

func _draw() -> void:
 if not is_instance_valid(boss): return
 if boss.state == boss.State.DEFEATED:
  if is_instance_valid(boss.target) and boss.target.survival.is_dead:
   return
  if boss.has_node("Conclusion") and boss.get_node("Conclusion").played:
   _draw_conclusion()
   return
  draw_rect(Rect2(49, 20, 222, 14), Color("10111f", 0.88))
  _center("Abadia concluída · Abade vencido", 30, 7, Color("c4b99d"))
  return
 var title: String="ABADE DAS CORRENTES"
 var width: float=font.get_string_size(title,HORIZONTAL_ALIGNMENT_LEFT,-1,8).x
 var ratio: float=health_ratio()
 draw_rect(Rect2(62,19,196,24),Color("10111f",0.88))
 draw_string(font,Vector2((320-width)/2,28),title,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("dbc7a0"))
 draw_rect(Rect2(76,32,168,6),Color("89765e"))
 draw_rect(Rect2(77,33,166,4),Color("272337"))
 draw_rect(Rect2(77,33,166*ratio,4),Color("8c3d55"))
 if boss.phase==2: draw_string(font,Vector2(253,38),"II",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("9de6d4"))
