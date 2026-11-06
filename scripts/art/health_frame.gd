extends PixelCanvas
## Thematic HUD ornament; the existing Life label and health signal are retained.
var current: int = 5
var maximum: int = 5
var pulse: float = 0.0
const PORTRAIT: Texture2D = preload("res://assets/art/fix02/aren_poses.png")

func _process(delta: float) -> void:
	if pulse > 0:
		pulse = maxf(0,pulse-delta)
		queue_redraw()

func _draw() -> void:
	var extra: float = maxf(0, maximum - 5) * 7.0
	var right_edge: float = 105.0 + extra
	var poly_edge: float = 107.0 + extra
	p([Vector2(3,3),Vector2(8,0),Vector2(15,2),Vector2(19,4),Vector2(poly_edge,4),Vector2(poly_edge+2,7),Vector2(poly_edge,13),Vector2(17,13),Vector2(12,16),Vector2(4,13)],Color("11141e",0.93))
	l(Vector2(19,3),Vector2(right_edge,3),Color("a28b65"))
	l(Vector2(20,14),Vector2(right_edge-1,14),Color("665347"))
	for side: int in [4,int(right_edge)]:
		l(Vector2(side,5),Vector2(side+3,2),GOLD)
		l(Vector2(side,11),Vector2(side+3,14),Color("84715b"))
	var size: Vector2 = PORTRAIT.get_size()
	draw_texture_rect_region(PORTRAIT,Rect2(3,0,15,16),Rect2(size*Vector2(0.103,0.018),size*Vector2(0.085,0.17)),Color(1.4,1.4,1.35,1))
	r(16,5,1,6,Color("b5a073"))
	for index: int in range(mini(maximum,8)):
		var x: int = 70+index*7
		var fill: Color = Color("9c4354") if index < current else Color("252a36")
		r(x,5,6,7,Color("69594e"))
		r(x+1,6,4,5,fill)
		if index < current:
			r(x+1,6,4,1,Color("e19b8c"))
			r(x+1,7,1,2,Color("bf6a72"))
			r(x+2,10,3,1,Color("612d46"))
	if pulse > 0:
		l(Vector2(19,14),Vector2(right_edge-2,14),Color(AMBER,pulse))
