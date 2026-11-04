extends Node2D
const ART: Array[Texture2D]=[preload("res://assets/art/m5c/acolyte.png"),preload("res://assets/art/m5c/penitent.png"),preload("res://assets/art/m5c/watcher.png")]
func _draw() -> void:
 var enemy=get_parent()
 var frame: int=0
 match enemy.state:
  ChainedMonk.State.PATROL,ChainedMonk.State.CHASE: frame=1+int(enemy.age*7)%2
  ChainedMonk.State.WARNING: frame=3
  ChainedMonk.State.ACTIVE: frame=4
  ChainedMonk.State.RECOVER: frame=5
  ChainedMonk.State.HURT: frame=6
  ChainedMonk.State.DEAD: frame=7
 var texture: Texture2D=ART[enemy.archetype]
 var cell: Vector2=texture.get_size()/Vector2(4,2)
 draw_set_transform(Vector2.ZERO,0,Vector2(enemy.facing,1))
 draw_texture_rect_region(texture,Rect2(-24,-40,60,44),Rect2(Vector2(frame%4,floori(frame/4.0))*cell,cell),Color(1.6,1.5,1.4) if enemy.flash>0 else Color.WHITE)
 if enemy.state==ChainedMonk.State.WARNING:
  var length: float=50 if enemy.archetype==2 else (90 if enemy.archetype==0 else 72)
  var start: float=6 if enemy.archetype==2 else 8
  draw_line(Vector2(start,-3),Vector2(length,-3),Color("f5d286"),1)
  draw_string(ThemeDB.fallback_font,Vector2(0,-42),"!",HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("fff1c4"))
