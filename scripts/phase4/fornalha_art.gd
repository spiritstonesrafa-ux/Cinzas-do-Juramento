extends Node2D
## Layered scene artwork for the continuous Fornalha world.

const MASONRY: Texture2D = preload("res://assets/art/m5a/architecture.png")
const ZONE_BACKGROUNDS: Array[Texture2D] = [
	preload("res://assets/art/m7a/fornalha_entrance.png"),
	preload("res://assets/art/m7a/fornalha_hoist.png"),
	preload("res://assets/art/m7a/fornalha_ash_gallery.png"),
	preload("res://assets/art/m7a/fornalha_bg.png"),
	preload("res://assets/art/m7a/fornalha_cooling_canal.png"),
	preload("res://assets/art/m7a/fornalha_ash_gallery.png"),
	preload("res://assets/art/m7a/fornalha_cooling_canal.png"),
	preload("res://assets/art/m7a/fornalha_sanctuary.png")
]
const PLATFORM_SOURCE: Rect2 = Rect2(18, 194, 728, 186)
const STONE_SOURCE: Vector2 = Vector2(1070, 165)
const PILLAR_SOURCE: Rect2 = Rect2(1035, 15, 238, 485)

var _view: Rect2 = Rect2(0, 0, 320, 180)
var _last_camera_center: Vector2 = Vector2(INF, INF)
var _background_current: int = -1
var _background_previous: int = -1
var _background_transition: float = 1.0
var _clock: float = 0.0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	z_index = -1

func _process(delta: float) -> void:
	_clock += delta
	var camera: Camera2D = get_viewport().get_camera_2d()
	if camera == null:
		return
	# The project enables pixel snapping, so align the painted layers to the same
	# pixel grid as the camera instead of mixing fractional and snapped transforms.
	var center: Vector2 = camera.get_screen_center_position().round()
	var camera_moved: bool = center.distance_squared_to(_last_camera_center) > 0.000001
	if camera_moved:
		_last_camera_center = center
		_view = Rect2(center - Vector2(160, 90), Vector2(320, 180))
	var phase: Node = get_parent()
	var hero: Node2D = phase.get_node_or_null("Knight") as Node2D
	if is_instance_valid(hero):
		var zone_index: int = int(phase.call("_zone_for", hero.global_position))
		if zone_index >= 0 and zone_index != _background_current:
			_background_previous = _background_current
			_background_current = zone_index
			_background_transition = 0.0 if _background_previous >= 0 else 1.0
	if _background_transition < 1.0:
		_background_transition = minf(1.0, _background_transition + delta / 0.38)
	if camera_moved or _background_transition < 1.0 or fmod(_clock, 0.12) < delta:
		queue_redraw()

func _draw() -> void:
	draw_rect(_view, Color("11171e"))
	_draw_backgrounds()
	_draw_foundry_silhouette()
	_draw_surfaces()
	_draw_embers()

func _draw_backgrounds() -> void:
	var zones: Array[Dictionary] = get_parent().map_zones()
	# Keep one stable room image between area transitions. Continuously blending
	# the two nearest images made the entire backdrop change as the camera moved.
	if zones.is_empty():
		return
	if _background_current < 0:
		_background_current = 0
	if _background_previous >= 0 and _background_transition < 1.0:
		draw_texture_rect(ZONE_BACKGROUNDS[_background_previous], _view, false, _background_tint(_background_previous, 1.0 - _background_transition))
	draw_texture_rect(ZONE_BACKGROUNDS[_background_current], _view, false, _background_tint(_background_current, _background_transition if _background_previous >= 0 else 1.0))
	if _background_transition >= 1.0:
		_background_previous = -1

func _background_tint(zone_index: int, alpha: float) -> Color:
	var tint: Color = Color(0.83, 0.87, 0.87, alpha)
	if zone_index in [4, 6]: tint = Color(0.68, 0.88, 0.88, alpha)
	elif zone_index == 7: tint = Color(0.88, 0.78, 0.67, alpha)
	return tint

func _draw_foundry_silhouette() -> void:
	# The hoist remains a visual landmark between the upper and lower routes.
	for x: int in [540, 850, 1530, 2050, 2350, 2630, 3000]:
		var beam: Rect2 = Rect2(x, 300, 10, 820)
		if not beam.intersects(_view.grow(16)):
			continue
		draw_line(Vector2(x, 300), Vector2(x, 1100), Color("191a20", 0.88), 8.0)
		draw_line(Vector2(x + 2, 300), Vector2(x + 2, 1100), Color("987450", 0.42), 1.0)
		for y: int in range(340, 1080, 42):
			draw_circle(Vector2(x, y), 1.1, Color("c18b50", 0.64))
	for x: int in [640, 1070, 1460, 1860, 2230, 2540, 2840]:
		var chain: Rect2 = Rect2(x, 240, 4, 110)
		if chain.intersects(_view.grow(16)):
			for y: int in range(245, 350, 8):
				draw_arc(Vector2(x + 2, y), 2.1, 0, TAU, 8, Color("8c694c", 0.86), 1.0)
	for point: Vector2 in [Vector2(455,570), Vector2(1190,800), Vector2(1780,530), Vector2(2150,790), Vector2(2700,1035)]:
		if _view.grow(20).has_point(point):
			var glow: float = 0.65 + 0.18 * sin(_clock * 2.4 + point.x)
			draw_circle(point, 7, Color(1.0,0.35,0.08,0.08 * glow))
			draw_circle(point, 2.0, Color(1.0,0.62,0.25,glow))

func _draw_surfaces() -> void:
	var floors: Array[Rect2] = get_parent().map_floors()
	for rect: Rect2 in floors:
		if not rect.intersects(_view.grow(48)):
			continue
		_draw_masonry(rect)

func _draw_masonry(rect: Rect2) -> void:
	var visible: Rect2 = rect.intersection(_view.grow(32))
	if not visible.has_area():
		return
	var lip_shadow: Rect2 = Rect2(visible.position.x, rect.position.y + 2.0, visible.size.x, minf(3.0, rect.size.y))
	draw_rect(lip_shadow, Color("090d12", 0.58))
	# Recessed stone courses use the same detailed architecture atlas as the abbey.
	var x0: int = floori(visible.position.x / 32.0) * 32
	var x1: int = ceili(visible.end.x / 32.0) * 32
	var y0: int = floori(maxf(rect.position.y + 18.0, visible.position.y) / 32.0) * 32
	var y1: int = ceili(visible.end.y / 32.0) * 32
	for x: int in range(x0, x1, 32):
		for y: int in range(y0, y1, 32):
			var patch: Rect2 = Rect2(x, y, 32, 32).intersection(rect).intersection(_view.grow(32))
			if not patch.has_area():
				continue
			var sx: float = STONE_SOURCE.x + float(absi(x / 32) % 3) * 24.0
			var sy: float = STONE_SOURCE.y + float(absi(y / 32) % 3) * 48.0
			draw_texture_rect_region(MASONRY, patch, Rect2(sx, sy, 96, 96), Color(0.58,0.50,0.43))
	# Main tread: full carved masonry lip rather than the previous flat colored bar.
	var tread: Rect2 = Rect2(rect.position.x, rect.position.y - 1.0, rect.size.x, minf(21.0, rect.size.y))
	var visible_tread: Rect2 = tread.intersection(_view.grow(12))
	if visible_tread.has_area():
		var source: Rect2 = Rect2(
			PLATFORM_SOURCE.position + Vector2(PLATFORM_SOURCE.size.x * (visible_tread.position.x - tread.position.x) / tread.size.x, 0.0),
			Vector2(PLATFORM_SOURCE.size.x * visible_tread.size.x / tread.size.x, PLATFORM_SOURCE.size.y * visible_tread.size.y / tread.size.y)
		)
		draw_texture_rect_region(MASONRY, visible_tread, source, Color(0.75,0.69,0.58))
	# Heavy ground slabs hang from occasional carved buttresses.
	if rect.size.y > 90.0:
		for x: int in range(int(rect.position.x) + 56, int(rect.end.x) - 32, 144):
			var height: float = minf(rect.size.y - 20.0, 92.0)
			var support: Rect2 = Rect2(x, rect.position.y + 25, 42, height)
			if support.intersects(_view.grow(8)):
				draw_texture_rect_region(MASONRY, support, PILLAR_SOURCE, Color(0.58,0.52,0.45))

func _draw_embers() -> void:
	for i: int in range(28):
		var seed: float = float(i * 97 + 31)
		var x: float = fposmod(seed * 19.7 + _clock * (5.0 + float(i % 4)), 3200.0)
		var y: float = fposmod(seed * 13.1 - _clock * (9.0 + float(i % 3)), 1410.0)
		var point: Vector2 = Vector2(x, y)
		if _view.has_point(point):
			draw_circle(point, 0.7 + float(i % 2) * 0.45, Color(1.0,0.55,0.22,0.5))
