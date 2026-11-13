extends Node2D
var boss: OathGuardian
var font: Font=ThemeDB.fallback_font
func _process(_delta: float) -> void:queue_redraw()
func _draw() -> void:
 if not is_instance_valid(boss):return
 if boss.state==OathGuardian.State.DEFEATED:
  if is_instance_valid(boss.target) and boss.target.survival.is_dead:return
  if boss.get_node("Conclusion").played:
   _draw_conclusion()
   return
 var name_text: String="TITÃ OSSUÁRIO"
 var width: float=font.get_string_size(name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,8).x
 draw_rect(Rect2(62,19,196,24),Color("10111f",0.88))
 draw_string(font,Vector2((320-width)/2,28),name_text,HORIZONTAL_ALIGNMENT_LEFT,-1,8,Color("dbc7a0"))
 draw_rect(Rect2(76,32,168,6),Color("89765e"))
 draw_rect(Rect2(77,33,166,4),Color("272337"))
 draw_rect(Rect2(77,33,166*float(boss.current_health)/boss.max_health,4),Color("8c3d55"))
 if boss.phase==2:draw_string(font,Vector2(253,38),"II",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("9de6d4"))
 var notice: String=""
 if boss.state==OathGuardian.State.INTRO:notice="O Titã Ossuário desperta."
 elif boss.state==OathGuardian.State.PHASE_TRANSITION:notice="A maldição desperta."
 elif boss.state==OathGuardian.State.DEFEATED:notice="Guardião vencido · retorne pelo selo à esquerda"
 if not notice.is_empty():
  var text_width: float=font.get_string_size(notice,HORIZONTAL_ALIGNMENT_LEFT,-1,7).x
  draw_rect(Rect2(14,164,292,14),Color("10111f",0.9))
  draw_string(font,Vector2((320-text_width)/2,174),notice,HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("e3d2ac"))

func _center(text: String,y: float,size: int,color: Color) -> void:
 var width: float=font.get_string_size(text,HORIZONTAL_ALIGNMENT_LEFT,-1,size).x
 draw_string(font,Vector2((320-width)*0.5,y),text,HORIZONTAL_ALIGNMENT_LEFT,-1,size,color)
func _draw_conclusion() -> void:
 var ending: Node2D=boss.get_node("Conclusion")
 var clock: float=ending.elapsed
 # HP zero fades out; movement/health HUD and fixed camera stay available.
 if clock<0.55:
  var opacity: float=1-clock/0.55
  draw_rect(Rect2(76,32,168,6),Color(0.54,0.46,0.37,opacity))
  draw_rect(Rect2(77,33,166,4),Color(0.15,0.14,0.22,opacity))
 elif clock>=1.1 and clock<9:
  var opacity: float=clampf((clock-1.1)/0.4,0,1)
  var box_h: float=58.0 if ending.reward_granted else 37.0
  draw_rect(Rect2(33,18,254,box_h),Color(0.06,0.07,0.11,0.88*opacity))
  _center(ending.TITLE,29,8,Color(0.86,0.78,0.63,opacity))
  _center(ending.PHASE_TEXT,40,7,Color(0.74,0.83,0.79,opacity))
  _center(ending.NARRATIVE,51,7,Color(0.77,0.75,0.71,opacity))
  if ending.reward_granted:
   _center("RECOMPENSA CONQUISTADA",61,7,Color(0.62,0.90,0.83,opacity))
   _center("VIDA MÁXIMA +1",70,7,Color(1.0,0.91,0.69,opacity))
  elif clock>=2.6:_center(ending.CONTINUATION,65,7,Color("c4b99d"))
 elif clock>=9:
  draw_rect(Rect2(49,20,222,14),Color("10111f",0.88))
  _center("Cemitério concluído · Guardião vencido",30,7,Color("c4b99d"))
 if clock>=1.1:
  draw_rect(Rect2(32,164,256,14),Color("10111f",0.88))
  _center("Retorne pelo selo à esquerda.",174,7,Color("e3d2ac"))
