class_name TitanBossBar
extends Node2D
## Barra do Titã Ossuário, no mesmo painel compacto dos outros chefes.

var boss: Node2D
var font: Font = ThemeDB.fallback_font
var display_ratio := 1.0

func _process(delta: float) -> void:
	if is_instance_valid(boss) and "health" in boss and "max_health" in boss:
		var target_ratio := clampf(float(boss.health) / maxi(1, boss.max_health), 0.0, 1.0)
		display_ratio = move_toward(display_ratio, target_ratio, delta * 0.9)
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(boss) or not boss.active or boss.health <= 0:
		return

	var title := "TITÃ OSSUÁRIO"
	var title_width := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	draw_rect(Rect2(62, 4, 196, 24), Color("160d0b", 0.9))
	draw_string(font, Vector2((320.0 - title_width) * 0.5, 13), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("ffd28a"))

	# Brasa escura de atraso e moldura quente, seguindo as proporções das outras barras.
	draw_rect(Rect2(76, 17, 168, 6), Color("70402b"))
	draw_rect(Rect2(77, 18, 166, 4), Color("211414"))
	var ratio := clampf(float(boss.health) / maxi(1, boss.max_health), 0.0, 1.0)
	var fill := 166.0 * ratio
	if display_ratio > ratio:
		draw_rect(Rect2(77, 18, 166.0 * display_ratio, 4), Color("9c4932"))
	if fill > 0.0:
		draw_rect(Rect2(77, 18, fill, 4), Color("ed5527"))
		draw_rect(Rect2(77, 18, fill, 1), Color("ffc15b"))

	# Vinte divisões discretas e pequenas línguas de fogo animadas na borda.
	for i in range(1, 20):
		var x := 77.0 + 166.0 * float(i) / 20.0
		draw_line(Vector2(x, 18), Vector2(x, 22), Color("291513", 0.9), 1.0)
	for i in range(20):
		var x0 := 78.0 + float(i) * 8.2
		if x0 >= 77.0 + fill:
			break
		var flicker := 1.0 + absf(sin(Time.get_ticks_msec() * 0.012 + float(i) * 1.7)) * 2.2
		var flame := PackedVector2Array([
			Vector2(x0, 18), Vector2(x0 + 2.0, 18 - flicker),
			Vector2(x0 + 4.0, 18)
		])
		draw_colored_polygon(flame, Color("ff8a32", 0.82))
	# Brasas piscam no contorno do painel sem competir com o texto.
	var ember_x := 69.0 + sin(Time.get_ticks_msec() * 0.003) * 2.0
	draw_circle(Vector2(ember_x, 6), 1.0, Color("ff9a3c", 0.75))
	draw_circle(Vector2(250.0 - sin(Time.get_ticks_msec() * 0.004) * 2.0, 26), 1.0, Color("ff9a3c", 0.65))
