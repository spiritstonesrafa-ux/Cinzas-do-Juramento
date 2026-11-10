class_name CervoBossBar
extends Node2D
## Barra de vida e interface visual do Cervo Espectral (M6-CERVO-BOSS).
## Segue rigorosamente a identidade artística pixel-art 320x180 de Cinzas do Juramento.

var boss: Node2D
var font: Font = ThemeDB.fallback_font
var display_ratio: float = 1.0

func _process(delta: float) -> void:
	if is_instance_valid(boss) and "health" in boss and "max_health" in boss:
		var target_ratio: float = clampf(float(boss.health) / maxi(1, boss.max_health), 0.0, 1.0)
		display_ratio = move_toward(display_ratio, target_ratio, delta * 0.8)
	queue_redraw()

func _center(text: String, y: float, size: int, color: Color) -> void:
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(font, Vector2((320.0 - width) * 0.5, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _draw_conclusion() -> void:
	if not boss.has_node("Conclusion"):
		return
	var ending: Node2D = boss.get_node("Conclusion")
	var clock: float = ending.get("elapsed") if "elapsed" in ending else 0.0
	
	if clock < 0.55:
		var opacity: float = 1.0 - clock / 0.55
		draw_rect(Rect2(62, 19, 196, 24), Color(0.06, 0.07, 0.11, 0.88 * opacity))
		draw_rect(Rect2(76, 32, 168, 6), Color(0.35, 0.50, 0.52, opacity))
		draw_rect(Rect2(77, 33, 166, 4), Color(0.10, 0.14, 0.18, opacity))
	elif clock >= 1.0 and clock < 9.0:
		var opacity: float = clampf((clock - 1.0) / 0.4, 0.0, 1.0)
		draw_rect(Rect2(20, 16, 280, 68), Color(0.05, 0.08, 0.10, 0.90 * opacity))
		_center("CERVO ESPECTRAL DERROTADO", 28, 8, Color(0.70, 0.95, 0.98, opacity))
		_center("A Floresta dos Ossos reconhece sua força.", 39, 7, Color(0.78, 0.85, 0.84, opacity))
		_center("A névoa ancestral se dissipa diante da chama do Juramento.", 50, 7, Color(0.72, 0.76, 0.75, opacity))
		if clock >= 1.6:
			_center("NOVA HABILIDADE — SALTO ESPECTRAL", 62, 7, Color(0.30, 0.95, 1.0, opacity))
			_center("Pressione Espaço novamente no ar para executar um segundo salto.", 73, 7, Color(1.0, 0.92, 0.70, opacity))
	elif clock >= 9.0:
		draw_rect(Rect2(42, 18, 236, 14), Color("0d1217", 0.88))
		_center("Floresta dos Ossos concluída · Cervo Espectral pacificado", 28, 7, Color("a2d2d0"))
	
	if clock >= 1.6:
		draw_rect(Rect2(32, 164, 256, 14), Color("0d1217", 0.88))
		_center("Explore o Setor 10 ou retorne à esquerda para revisitar a floresta.", 174, 7, Color("cde8e5"))

func _draw() -> void:
	if not is_instance_valid(boss):
		return
	
	if "state" in boss and "State" in boss and boss.state == boss.State.DEFEATED:
		if is_instance_valid(boss.get("target")) and boss.target.survival.is_dead:
			return
		if boss.has_node("Conclusion"):
			_draw_conclusion()
			return
		draw_rect(Rect2(42, 18, 236, 14), Color("0d1217", 0.88))
		_center("Floresta dos Ossos concluída · Cervo Espectral pacificado", 28, 7, Color("a2d2d0"))
		return
	
	var title: String = "CERVO ESPECTRAL"
	var width: float = font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8).x
	var current_hp: int = boss.health if "health" in boss else 10
	var max_hp: int = boss.max_health if "max_health" in boss else 10
	var ratio: float = clampf(float(current_hp) / maxi(1, max_hp), 0.0, 1.0)
	
	# Painel superior
	draw_rect(Rect2(62, 19, 196, 24), Color("0c1117", 0.88))
	draw_string(font, Vector2((320.0 - width) * 0.5, 28), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("9ee4eb"))
	
	# Moldura da barra
	draw_rect(Rect2(76, 32, 168, 6), Color("2d464d"))
	# Fundo da barra
	draw_rect(Rect2(77, 33, 166, 4), Color("12181f"))
	# Barra de atraso (dano recebido)
	if display_ratio > ratio:
		draw_rect(Rect2(77, 33, 166.0 * display_ratio, 4), Color("a84b5e"))
	# Barra de vida real (ciano espectral turquesa)
	draw_rect(Rect2(77, 33, 166.0 * ratio, 4), Color("26b5b5"))
	
	# Marcadores de fase
	var p2_x: float = 77.0 + 166.0 * (9.0 / 14.0)
	var p3_x: float = 77.0 + 166.0 * (4.0 / 14.0)
	draw_line(Vector2(p2_x, 33), Vector2(p2_x, 37), Color("0c1117", 0.9), 1.0)
	draw_line(Vector2(p3_x, 33), Vector2(p3_x, 37), Color("0c1117", 0.9), 1.0)
	
	# Indicador da fase atual
	var phase_num: int = boss.phase if "phase" in boss else 1
	var phase_str: String = "I" if phase_num == 1 else ("II" if phase_num == 2 else "III")
	draw_string(font, Vector2(251, 38), phase_str, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("9ee4eb"))

