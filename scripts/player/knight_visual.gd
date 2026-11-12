class_name KnightVisual
extends PixelCanvas
## FIX02 original raster poses. Only observes homologated state; no physics writes.

enum SotnVisualMode {
	ARM_FIX01,  # Versão homologada e aprovada no playtest anterior
	ART_FIX02   # Refinamento visual experimental baseado na prancha artística
}

var sotn_visual_mode: SotnVisualMode = SotnVisualMode.ART_FIX02

func toggle_sotn_visual_mode() -> SotnVisualMode:
	if sotn_visual_mode == SotnVisualMode.ART_FIX02:
		sotn_visual_mode = SotnVisualMode.ARM_FIX01
	else:
		sotn_visual_mode = SotnVisualMode.ART_FIX02
	queue_redraw()
	return sotn_visual_mode

const POSES: Texture2D = preload("res://assets/art/fix02/aren_poses.png")
# Authored sheet regions measured from alpha >= 96; fixed metadata avoids GPU readback.
const FRAME_RECTS: Array[Rect2] = [
	Rect2(86,18,230,386), Rect2(472,39,333,364),
	Rect2(935,38,283,366), Rect2(1387,38,343,362),
	Rect2(27,464,309,282), Rect2(472,460,305,387),
	Rect2(903,496,337,353), Rect2(1355,464,304,385)
]

# Gothic Violet Palette for Passo das Sombras (Abbot inheritance)
const DASH_VIOLET_BRIGHT: Color = Color(0.85, 0.45, 1.0)
const DASH_VIOLET_CORE: Color = Color(1.35, 1.15, 1.45)
const DASH_VIOLET_DEEP: Color = Color(0.55, 0.22, 0.80)
const DASH_SHADOW_SMOKE: Color = Color(0.30, 0.14, 0.42)
const DASH_SPARK_FLOOR: Color = Color(0.92, 0.55, 1.0)
const DASH_DEBRIS_STONE: Color = Color(0.28, 0.24, 0.32)
const DASH_DEBRIS_LIGHT: Color = Color(0.44, 0.38, 0.48)
const DASH_DUST_PUFF: Color = Color(0.52, 0.40, 0.62)

var _time: float = 0.0
var _was_dead: bool = false
var _revive: float = 0.0

# Dash lifecycle & sampling
var _dash_previous: bool = false
var _dash_sample: float = 0.0
var _dash_wisp_sample: float = 0.0

# Dash particles & ghosts
var _dash_ghosts: Array[Dictionary] = []
var _dash_wisps: Array[Dictionary] = []
var _dash_debris: Array[Dictionary] = []
var _dash_dust: Array[Dictionary] = []

# Dash Start burst & lingering origin sigil
var _dash_start_pos: Vector2 = Vector2.ZERO
var _dash_start_facing: int = 1
var _dash_start_timer: float = 0.0
const DASH_START_DURATION: float = 0.28

# Dash End braking impact
var _dash_end_pos: Vector2 = Vector2.ZERO
var _dash_end_facing: int = 1
var _dash_end_timer: float = 0.0
const DASH_END_DURATION: float = 0.20

# Efeitos visuais de impacto localizado (Marco 3 — ATAQUE-SOTN-03)
var _impact_vfx: Array[Dictionary] = []

func _ready() -> void:
	var hero: KnightController = get_parent() as KnightController
	if hero and hero.sword_attack:
		if not hero.sword_attack.hit_landed.is_connected(_on_attack_hit_landed):
			hero.sword_attack.hit_landed.connect(_on_attack_hit_landed)

func _on_attack_hit_landed(_target: Node2D, hit_pos: Vector2, hit_type: String) -> void:
	var local_pos: Vector2 = to_local(hit_pos)
	var hero: KnightController = get_parent() as KnightController
	var dir: float = float(hero.sword_attack.direction) if hero and hero.sword_attack else 1.0
	_impact_vfx.append({
		"pos": local_pos,
		"dir": dir,
		"type": hit_type,
		"time": 0.12,
		"max_time": 0.12
	})
	queue_redraw()

func _update_impact_vfx(delta: float) -> void:
	var i: int = _impact_vfx.size() - 1
	while i >= 0:
		_impact_vfx[i]["time"] -= delta
		if _impact_vfx[i]["time"] <= 0.0:
			_impact_vfx.remove_at(i)
		i -= 1

func _process(delta: float) -> void:
	_time += delta
	var hero: KnightController = get_parent() as KnightController
	var dashing: bool = hero.dash_remaining > 0.0 and not hero.survival.is_dead

	if not _dash_previous and dashing:
		_on_dash_started(hero)
	elif _dash_previous and not dashing:
		_on_dash_ended(hero)
	_dash_previous = dashing

	if hero.survival.is_dead:
		_clear_dash_vfx()
		_impact_vfx.clear()
	else:
		_update_dash_vfx(delta, dashing, hero)
		_update_impact_vfx(delta)

	if _was_dead and not hero.survival.is_dead:
		_revive = 0.55
	_was_dead = hero.survival.is_dead
	_revive = maxf(0.0, _revive - delta)
	queue_redraw()

func _on_dash_started(hero: KnightController) -> void:
	_dash_start_pos = hero.global_position
	_dash_start_facing = hero.dash_direction
	_dash_start_timer = DASH_START_DURATION
	_dash_sample = 0.0
	_dash_wisp_sample = 0.0

	# Spawn start stone pebbles (kicked backward)
	for i in range(5):
		var vel: Vector2 = Vector2(
			-_dash_start_facing * randf_range(28.0, 65.0),
			-randf_range(20.0, 50.0)
		)
		var p_pos: Vector2 = _dash_start_pos + Vector2(-_dash_start_facing * randf_range(2.0, 6.0), -randf_range(1.0, 4.0))
		_dash_debris.append({
			"pos": p_pos,
			"vel": vel,
			"gravity": 220.0,
			"life": randf_range(0.20, 0.28),
			"max_life": 0.28,
			"size": 1 if i % 2 == 0 else 2,
			"color": DASH_DEBRIS_STONE if i % 2 == 0 else DASH_DEBRIS_LIGHT
		})

	# Spawn start dust puffs (curling behind launch foot)
	for i in range(3):
		_dash_dust.append({
			"pos": _dash_start_pos + Vector2(-_dash_start_facing * randf_range(4.0, 10.0), -randf_range(1.0, 4.0)),
			"vel": Vector2(-_dash_start_facing * randf_range(4.0, 14.0), -randf_range(2.0, 6.0)),
			"radius": randf_range(2.2, 3.8),
			"life": 0.24,
			"max_life": 0.24
		})

func _on_dash_ended(hero: KnightController) -> void:
	_dash_end_pos = hero.global_position
	_dash_end_facing = hero.facing
	_dash_end_timer = DASH_END_DURATION

	# Spawn braking stone pebbles (kicked forward/upward)
	for i in range(5):
		var vel: Vector2 = Vector2(
			_dash_end_facing * randf_range(22.0, 55.0),
			-randf_range(25.0, 60.0)
		)
		var p_pos: Vector2 = _dash_end_pos + Vector2(_dash_end_facing * randf_range(2.0, 5.0), -randf_range(1.0, 3.0))
		_dash_debris.append({
			"pos": p_pos,
			"vel": vel,
			"gravity": 240.0,
			"life": randf_range(0.16, 0.22),
			"max_life": 0.22,
			"size": 1 if i % 2 == 0 else 2,
			"color": DASH_DEBRIS_STONE if i % 2 == 0 else DASH_DEBRIS_LIGHT
		})

	# Spawn braking dust puffs (skid point)
	for i in range(3):
		_dash_dust.append({
			"pos": _dash_end_pos + Vector2(_dash_end_facing * randf_range(2.0, 8.0), -randf_range(1.0, 3.0)),
			"vel": Vector2(_dash_end_facing * randf_range(3.0, 10.0), -randf_range(2.0, 5.0)),
			"radius": randf_range(2.5, 4.2),
			"life": 0.20,
			"max_life": 0.20
		})

func _update_dash_vfx(delta: float, dashing: bool, hero: KnightController) -> void:
	_dash_start_timer = maxf(0.0, _dash_start_timer - delta)
	_dash_end_timer = maxf(0.0, _dash_end_timer - delta)

	# Afterimages tick
	for i in range(_dash_ghosts.size() - 1, -1, -1):
		_dash_ghosts[i].age += delta
		if _dash_ghosts[i].age >= 0.20:
			_dash_ghosts.remove_at(i)

	# Afterimages spawn
	_dash_sample -= delta
	if dashing and _dash_sample <= 0.0:
		_dash_ghosts.push_back({
			"pos": hero.global_position,
			"facing": hero.dash_direction,
			"age": 0.0
		})
		if _dash_ghosts.size() > 4:
			_dash_ghosts.pop_front()
		_dash_sample = 0.034

	# Wisps spawn
	_dash_wisp_sample -= delta
	if dashing and _dash_wisp_sample <= 0.0:
		var f: int = hero.dash_direction
		_dash_wisps.append({
			"pos": hero.global_position + Vector2(-f * randf_range(6.0, 16.0), -randf_range(6.0, 20.0)),
			"vel": Vector2(-f * randf_range(6.0, 18.0), -randf_range(3.0, 10.0)),
			"radius": randf_range(3.2, 5.2),
			"life": 0.22,
			"max_life": 0.22
		})
		if _dash_wisps.size() > 8:
			_dash_wisps.pop_front()
		_dash_wisp_sample = 0.026

	# Update wisps
	for i in range(_dash_wisps.size() - 1, -1, -1):
		var w: Dictionary = _dash_wisps[i]
		w.life -= delta
		w.pos += w.vel * delta
		w.radius = minf(w.radius + delta * 3.0, 6.5)
		if w.life <= 0.0:
			_dash_wisps.remove_at(i)

	# Update debris
	for i in range(_dash_debris.size() - 1, -1, -1):
		var deb: Dictionary = _dash_debris[i]
		deb.life -= delta
		deb.pos += deb.vel * delta
		deb.vel.y += deb.gravity * delta
		if deb.life <= 0.0:
			_dash_debris.remove_at(i)

	# Update dust
	for i in range(_dash_dust.size() - 1, -1, -1):
		var dust: Dictionary = _dash_dust[i]
		dust.life -= delta
		dust.pos += dust.vel * delta
		dust.radius += delta * 4.0
		if dust.life <= 0.0:
			_dash_dust.remove_at(i)

func _clear_dash_vfx() -> void:
	_dash_ghosts.clear()
	_dash_wisps.clear()
	_dash_debris.clear()
	_dash_dust.clear()
	_dash_start_timer = 0.0
	_dash_end_timer = 0.0

func _draw() -> void:
	var hero: KnightController = get_parent() as KnightController

	# 1. Draw World-Space Dash VFX (Sigil, Sparks, Scrape, Smoke, Debris, Afterimages)
	_draw_dash_world_vfx(hero)

	# 2. Local space drawing (node transform restored: scale.x = hero.facing)
	if hero.dash_remaining > 0.0 and not hero.survival.is_dead:
		_draw_dash_local_speed_lines()

	# 3. Sword attack drawing
	if hero.sword_attack.phase != SwordAttack.Phase.NEUTRAL and not hero.survival.is_dead:
		_draw_attack(hero)
		_draw_impact_vfx()
		return

	# Draw lingering impact VFX if attack ended during dissipation
	_draw_impact_vfx()

	# 4. Character body pose
	var frame: int = 0 if int(_time * 3) % 2 == 0 else 7
	match hero.state:
		KnightController.MovementState.RUN: frame = [1, 2, 3, 2][int(_time * 11) % 4]
		KnightController.MovementState.JUMP: frame = 4
		KnightController.MovementState.FALL: frame = 5
	if hero.dash_remaining > 0.0: frame = 4
	if hero.survival.invulnerability_remaining > 0.63: frame = 6
	if hero.survival.is_dead: frame = 0

	var region: Rect2 = FRAME_RECTS[frame]
	var dimensions: Vector2 = (region.size * Vector2(1.2, 1) * 36.0 / 386.0).round()
	var destination: Rect2 = Rect2(Vector2(-roundf(dimensions.x * 0.76), -36), dimensions)
	draw_texture_rect_region(POSES, destination, region, Color(1.4, 1.43, 1.38, 1))

	if hero._spectral_jump_fx_timer > 0.0:
		var alpha: float = hero._spectral_jump_fx_timer / 0.20
		var r_val: float = (1.0 - alpha) * 14.0 + 4.0
		draw_arc(Vector2(0, -2), r_val, 0, TAU, 12, Color(0.25, 0.95, 1.0, alpha * 0.85), 1.5)

	# 5. Revive and invulnerability indicators
	if _revive > 0.0:
		l(Vector2(-10, -1), Vector2(10, -1), Color(TEAL, _revive))
		r(-8, -16 - int((0.55 - _revive) * 20), 1, 3, TEAL)
	if hero.survival.invulnerability_remaining > 0.63:
		l(Vector2(-12, -23), Vector2(-16, -27), AMBER)
		l(Vector2(9, -14), Vector2(13, -17), LIGHT)

func _draw_dash_world_vfx(hero: KnightController) -> void:
	# Switch to pure world coordinate space
	draw_set_transform_matrix(global_transform.affine_inverse())

	# A. Lingering Launch Sigil & Crescent Arc (at _dash_start_pos)
	if _dash_start_timer > 0.0:
		var sigil_a: float = clampf(_dash_start_timer / DASH_START_DURATION, 0.0, 1.0)
		var sf: int = _dash_start_facing
		var arc_center: Vector2 = _dash_start_pos + Vector2(-6 * sf, -16)

		# Crescent Arc
		var start_ang: float = -0.74 * PI if sf == 1 else 0.86 * PI
		var end_ang: float = 0.14 * PI if sf == 1 else 1.74 * PI
		draw_arc(arc_center, 17.0, start_ang, end_ang, 14, Color(0.70, 0.32, 0.88, sigil_a * 0.70), 1.0)
		draw_arc(arc_center, 14.0, start_ang + 0.08, end_ang - 0.08, 12, Color(0.88, 0.52, 1.0, sigil_a * 0.85), 1.0)

		# Ornate Gothic Cross Sigil at Arc Apex
		var apex: Vector2 = _dash_start_pos + Vector2(-8 * sf, -28)
		draw_circle(apex, 5.0, Color(0.72, 0.35, 0.90, sigil_a * 0.18))
		draw_circle(apex, 2.5, Color(0.85, 0.45, 1.0, sigil_a * 0.35))
		# Vertical bar
		draw_line(apex + Vector2(0, -7), apex + Vector2(0, 7), Color(0.85, 0.45, 1.0, sigil_a), 1.0)
		# Horizontal bar
		draw_line(apex + Vector2(-4, -2), apex + Vector2(4, -2), Color(0.85, 0.45, 1.0, sigil_a), 1.0)
		# Flared tip crosslets
		draw_line(apex + Vector2(-1, -6), apex + Vector2(1, -6), Color(0.95, 0.65, 1.0, sigil_a), 1.0)
		draw_line(apex + Vector2(-1, 6), apex + Vector2(1, 6), Color(0.95, 0.65, 1.0, sigil_a), 1.0)
		draw_line(apex + Vector2(-3, -3), apex + Vector2(-3, -1), Color(0.95, 0.65, 1.0, sigil_a), 1.0)
		draw_line(apex + Vector2(3, -3), apex + Vector2(3, -1), Color(0.95, 0.65, 1.0, sigil_a), 1.0)
		# Central diamond
		var c_pts: PackedVector2Array = PackedVector2Array([
			apex + Vector2(0, -4),
			apex + Vector2(2, -2),
			apex + Vector2(0, 0),
			apex + Vector2(-2, -2)
		])
		draw_colored_polygon(c_pts, Color(0.95, 0.70, 1.0, sigil_a * 0.9))
		draw_rect(Rect2(apex + Vector2(-0.5, -2.5), Vector2(1, 1)), Color(1.4, 1.2, 1.5, sigil_a))

		# Start Ground Sparks
		var spark_a: float = clampf(_dash_start_timer / 0.16, 0.0, 1.0)
		if spark_a > 0.0:
			var sp_origin: Vector2 = _dash_start_pos + Vector2(2 * sf, -1)
			draw_line(sp_origin, sp_origin + Vector2(15 * sf, 0), Color(0.95, 0.60, 1.0, spark_a), 1.0)
			draw_line(sp_origin, sp_origin + Vector2(12 * sf, -3), Color(0.85, 0.45, 1.0, spark_a * 0.85), 1.0)
			draw_line(sp_origin, sp_origin + Vector2(8 * sf, -6), Color(0.85, 0.45, 1.0, spark_a * 0.75), 1.0)
			draw_line(sp_origin, sp_origin + Vector2(-6 * sf, -2), Color(0.75, 0.35, 0.90, spark_a * 0.6), 1.0)
			draw_line(sp_origin, sp_origin + Vector2(18 * sf, 1), Color(1.2, 0.9, 1.3, spark_a * 0.9), 1.0)
			draw_line(sp_origin, sp_origin + Vector2(5 * sf, -8), Color(0.80, 0.40, 0.95, spark_a * 0.7), 1.0)
			draw_circle(sp_origin, 1.8, Color(1.3, 1.1, 1.4, spark_a))

	# B. Active Dash Ground Scrape Streak
	if hero.dash_remaining > 0.0 and not hero.survival.is_dead:
		var p1: Vector2 = Vector2(_dash_start_pos.x, _dash_start_pos.y - 1)
		var p2: Vector2 = Vector2(hero.global_position.x, hero.global_position.y - 1)
		draw_line(p1, p2, Color(0.65, 0.25, 0.88, 0.50), 2.0)
		draw_line(p1, p2, Color(1.25, 1.0, 1.35, 0.85), 1.0)
		var mid_x: float = (p1.x + p2.x) * 0.5
		var df: int = hero.dash_direction
		draw_line(Vector2(mid_x - 3 * df, p1.y), Vector2(mid_x + 5 * df, p1.y), Color(1.3, 1.1, 1.4, 0.9), 1.0)

	# C. Billowing Smoke Wisps
	for wisp: Dictionary in _dash_wisps:
		var w_a: float = clampf(wisp.life / wisp.max_life, 0.0, 1.0)
		draw_circle(wisp.pos, wisp.radius, Color(DASH_SHADOW_SMOKE, w_a * 0.28))
		draw_circle(wisp.pos, wisp.radius * 0.6, Color(DASH_VIOLET_DEEP, w_a * 0.45))

	# D. Dust Puffs
	for dust: Dictionary in _dash_dust:
		var dust_a: float = clampf(dust.life / dust.max_life, 0.0, 1.0)
		draw_circle(dust.pos, dust.radius, Color(DASH_DUST_PUFF, dust_a * 0.35))

	# E. Stone Debris
	for deb: Dictionary in _dash_debris:
		var deb_a: float = clampf(deb.life / deb.max_life, 0.0, 1.0)
		draw_rect(Rect2(deb.pos.x, deb.pos.y, deb.size, deb.size), Color(deb.color, deb_a))

	# F. End of Dash Braking Sparks
	if _dash_end_timer > 0.0:
		var brake_a: float = clampf(_dash_end_timer / 0.18, 0.0, 1.0)
		var ef: int = _dash_end_facing
		var b_origin: Vector2 = _dash_end_pos + Vector2(ef * 3, -1)
		draw_line(b_origin, b_origin + Vector2(16 * ef, 0), Color(0.95, 0.60, 1.0, brake_a), 1.0)
		draw_line(b_origin, b_origin + Vector2(14 * ef, -4), Color(0.88, 0.50, 1.0, brake_a * 0.9), 1.0)
		draw_line(b_origin, b_origin + Vector2(10 * ef, -8), Color(0.80, 0.40, 0.95, brake_a * 0.8), 1.0)
		draw_line(b_origin, b_origin + Vector2(6 * ef, -12), Color(0.75, 0.35, 0.90, brake_a * 0.7), 1.0)
		draw_line(b_origin, b_origin + Vector2(18 * ef, 1), Color(1.3, 1.1, 1.4, brake_a * 0.95), 1.0)
		draw_line(b_origin, b_origin + Vector2(-5 * ef, -3), Color(0.70, 0.30, 0.85, brake_a * 0.6), 1.0)
		draw_circle(b_origin, 1.8, Color(1.35, 1.15, 1.45, brake_a))

	# G. Afterimages (Ecos)
	var ghost_region: Rect2 = FRAME_RECTS[4]
	var ghost_size: Vector2 = (ghost_region.size * Vector2(1.2, 1) * 36.0 / 386.0).round()
	for ghost: Dictionary in _dash_ghosts:
		var g_alpha: float = 1.0 - (ghost.age / 0.20)
		if g_alpha <= 0.0:
			continue
		draw_set_transform(ghost.pos, 0.0, Vector2(ghost.facing, 1.0))
		var shadow_dest: Rect2 = Rect2(-roundf(ghost_size.x * 0.76) - 1, -36, ghost_size.x, ghost_size.y)
		draw_texture_rect_region(POSES, shadow_dest, ghost_region, Color(0.25, 0.12, 0.35, g_alpha * 0.28))
		var ghost_dest: Rect2 = Rect2(-roundf(ghost_size.x * 0.76), -36, ghost_size.x, ghost_size.y)
		draw_texture_rect_region(POSES, ghost_dest, ghost_region, Color(0.68, 0.34, 0.98, g_alpha * 0.42))

	# Restore local node transform
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_dash_local_speed_lines() -> void:
	# Local node space: +x is forward facing
	# Subtle speed aura behind torso/cape
	draw_line(Vector2(-8, -24), Vector2(-18, -24), Color(0.85, 0.48, 1.0, 0.65), 1.0)
	draw_line(Vector2(-10, -18), Vector2(-22, -18), Color(0.92, 0.58, 1.0, 0.75), 1.0)
	draw_line(Vector2(-6, -12), Vector2(-16, -12), Color(0.85, 0.48, 1.0, 0.60), 1.0)

func _draw_impact_vfx() -> void:
	var hero: KnightController = get_parent() as KnightController
	if hero == null or not is_instance_valid(hero.sword_attack):
		return
	if hero.sword_attack.mode != SwordAttack.Mode.SOTN or not hero.sword_attack.sotn_feedback_enabled:
		return

	for vfx: Dictionary in _impact_vfx:
		var p: float = clampf(vfx["time"] / vfx["max_time"], 0.0, 1.0)
		var pt: Vector2 = vfx["pos"]
		var type: String = vfx["type"]
		var dir: float = vfx["dir"]

		match type:
			"armor":
				# Faíscas metálicas cortantes de alta luminosidade (dourado/branco)
				var alpha: float = p * 0.95
				var col_core: Color = Color(2.5, 2.4, 2.0, alpha)
				var col_spark: Color = Color(1.9, 1.5, 0.7, alpha)
				draw_circle(pt, 1.8 * p, col_core)
				var angles: Array[float] = [-0.65, -0.32, 0.0, 0.35, 0.72]
				var lens: Array[float] = [10.0, 14.0, 12.0, 13.0, 9.0]
				for k in range(5):
					var ang: float = angles[k]
					var u: Vector2 = Vector2(cos(ang) * dir, sin(ang))
					var l_start: Vector2 = pt + u * (2.0 * (1.0 - p))
					var l_end: Vector2 = pt + u * (lens[k] * (1.2 - p * 0.2))
					draw_line(l_start, l_end, col_spark, 1.2 * p)

			"spectral":
				# Dissipação etérea translúcida em névoa e anel ciano/lavanda
				var alpha: float = p * 0.85
				var col_mist: Color = Color(0.4, 0.85, 1.0, alpha * 0.6)
				var col_ring: Color = Color(1.2, 1.6, 2.0, alpha)
				draw_arc(pt, 8.0 * (1.0 - p * 0.5), 0, TAU, 10, col_ring, 1.0)
				var s_offsets: Array[Vector2] = [Vector2(6 * dir, -7), Vector2(8 * dir, 4), Vector2(-4 * dir, -5), Vector2(3 * dir, 8)]
				for off: Vector2 in s_offsets:
					draw_circle(pt + off * (1.0 - p * 0.3), 1.2 * p, col_mist)

			_: # "flesh" / default
				# Impacto de corte cortante limpo original de Cinzas do Juramento
				var alpha: float = p * 0.90
				var col_core: Color = Color(2.0, 2.0, 1.8, alpha)
				var col_slash: Color = Color(1.7, 1.35, 0.65, alpha)
				draw_circle(pt, 1.4 * p, col_core)
				var spark_vecs: Array[Vector2] = [
					Vector2(7.0 * dir, -6.0),
					Vector2(9.0 * dir, 2.0),
					Vector2(6.0 * dir, 8.0),
					Vector2(-4.0 * dir, -3.0)
				]
				for sv: Vector2 in spark_vecs:
					draw_line(pt, pt + sv * (1.1 - p * 0.2), col_slash, 1.0 * p)

func _draw_attack(hero: KnightController) -> void:
	var attack: SwordAttack = hero.sword_attack
	var frame: int = ArenAttackArt.pose(attack)

	if attack.mode == SwordAttack.Mode.ORIGINAL:
		# -------------------------------------------------------------
		# MODO ORIGINAL: 100% PRESERVAÇÃO HISTÓRICA DO CANÔNICO M1
		# -------------------------------------------------------------
		if attack.aerial:
			var region: Rect2 = FRAME_RECTS[4 if hero.velocity.y < 0.0 else 5]
			var dimensions: Vector2 = (region.size * Vector2(1.2, 1) * 36.0 / 386.0).round()
			draw_texture_rect_region(POSES, Rect2(Vector2(-roundf(dimensions.x * 0.76), -36), dimensions), region, Color(1.4, 1.43, 1.38, 1))
			var blade: Rect2 = ArenAttackArt.BLADES[frame]
			var blade_rect: Rect2 = Rect2(2, -25, 14, 3)
			if attack.phase == SwordAttack.Phase.ACTIVE: blade_rect = Rect2(6, -23, 22, 3)
			elif attack.phase == SwordAttack.Phase.RECOVERY: blade_rect = Rect2(6, -23, 16, 3)
			draw_texture_rect_region(ArenAttackArt.TEXTURE, blade_rect, blade, Color(1.4, 1.43, 1.38, 1))
		else:
			ArenAttackArt.draw_pose(self, frame)

		if attack.phase == SwordAttack.Phase.ACTIVE:
			l(Vector2(10, -20), Vector2(27, -20), Color("c8d6d1", 0.4))
			l(Vector2(12, -13), Vector2(25, -13), Color("f6ce94", 0.32))
			if not attack._hit_targets.is_empty():
				r(24, -19, 2, 2, LIGHT)
				l(Vector2(24, -16), Vector2(27, -13), AMBER)
	else:
		# -------------------------------------------------------------
		# MODO SOTN: DISPATCH ENTRE ARM-FIX01 (APROVADO) E ART-FIX02 (EXP)
		# -------------------------------------------------------------
		if sotn_visual_mode == SotnVisualMode.ARM_FIX01:
			_draw_sotn_attack_arm_fix01(hero, attack, frame)
		else:
			_draw_sotn_attack_art_fix02(hero, attack, frame)

	if hero.survival.invulnerability_remaining > 0.63:
		l(Vector2(-12, -23), Vector2(-16, -27), AMBER)

# =====================================================================
# VERSÃO ARM-FIX01 (HOMOLOGADA E APROVADA EM PLAYTEST HUMANO)
# 100% PRESERVADA — NENHUMA ALTERAÇÃO FUNCIONAL OU VISUAL NESTE RAMO
# =====================================================================

func _draw_sotn_attack_arm_fix01(hero: KnightController, attack: SwordAttack, frame: int) -> void:
	var aerial: bool = attack.aerial
	var progress: float = 0.0
	match attack.phase:
		SwordAttack.Phase.WINDUP:
			progress = clampf(1.0 - attack._remaining / maxf(attack.windup_duration, 0.001), 0.0, 1.0)
		SwordAttack.Phase.ACTIVE:
			progress = attack.get_active_progress()
		SwordAttack.Phase.RECOVERY:
			progress = clampf(1.0 - attack._remaining / maxf(attack.recovery_duration, 0.001), 0.0, 1.0)

	if attack.mode == SwordAttack.Mode.SOTN and attack.sotn_feedback_enabled and attack.visual_hitstop_remaining > 0.0:
		progress = attack.visual_hitstop_progress

	var lunge_offset: Vector2 = Vector2.ZERO
	if not aerial and attack.phase == SwordAttack.Phase.ACTIVE:
		lunge_offset = Vector2(roundf(lerpf(0.0, 2.0, progress)), 0.0)
	elif aerial:
		lunge_offset = Vector2(1.0, -1.0 if hero.velocity.y < 0.0 else 0.0)

	var reg_data: Dictionary = ArenAttackArt.registration(frame)
	var hand: Vector2 = reg_data["blade"].position + lunge_offset
	var blade_angle: float

	match attack.phase:
		SwordAttack.Phase.WINDUP:
			blade_angle = lerpf(-1.85, -1.65, progress)
		SwordAttack.Phase.ACTIVE:
			blade_angle = lerpf(-1.40, 0.56, progress)
		SwordAttack.Phase.RECOVERY:
			blade_angle = lerpf(0.56, -0.20, progress)

	_draw_sotn_cloak_arm_fix01(hero, attack.phase, progress, aerial)
	_draw_sotn_body_integrated(frame, lunge_offset)
	_draw_sotn_sword_arm_fix01(hand, blade_angle)

	match attack.phase:
		SwordAttack.Phase.WINDUP:
			_draw_sotn_windup_sparkle_arm_fix01(hand, blade_angle, progress)
		SwordAttack.Phase.ACTIVE:
			_draw_sotn_slash_arc_arm_fix01(hand, blade_angle, progress, not attack._hit_targets.is_empty())
		SwordAttack.Phase.RECOVERY:
			_draw_sotn_recovery_fade_arm_fix01(hand, progress)

func _draw_sotn_cloak_arm_fix01(hero: KnightController, phase: SwordAttack.Phase, progress: float, aerial: bool) -> void:
	if not aerial:
		match phase:
			SwordAttack.Phase.WINDUP:
				var pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(-7.0, -20.0),
					Vector2(-10.0, -10.0),
					Vector2(-7.0, -2.0),
					Vector2(-3.0, -4.0)
				]
				draw_colored_polygon(pts, Color("141624"))
				draw_line(Vector2(-5.0, -20.0), Vector2(-8.0, -8.0), Color("282b40"), 1.0)
			SwordAttack.Phase.ACTIVE:
				var top_x: float = lerpf(-8.0, -19.0, progress)
				var top_y: float = lerpf(-21.0, -15.0, progress)
				var tail_x: float = lerpf(-12.0, -23.0, progress)
				var tail_y: float = lerpf(-14.0, -7.0, progress)
				var bot_x: float = lerpf(-7.0, -13.0, progress)
				var bot_y: float = -3.0

				var main_pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(bot_x, bot_y),
					Vector2(-2.0, -8.0)
				]
				draw_colored_polygon(main_pts, Color("141624"))

				var lining_pts: PackedVector2Array = [
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(tail_x + 3.0, tail_y + 3.5),
					Vector2(top_x + 2.0, top_y + 2.5)
				]
				draw_colored_polygon(lining_pts, Color("6c2e42"))
				draw_line(Vector2(-3.0, -22.0), Vector2(top_x, top_y), Color("3d465c"), 1.0)
			SwordAttack.Phase.RECOVERY:
				var top_x: float = lerpf(-19.0, -7.0, progress)
				var top_y: float = lerpf(-15.0, -20.0, progress)
				var tail_x: float = lerpf(-23.0, -9.0, progress)
				var tail_y: float = lerpf(-7.0, -3.0, progress)

				var main_pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(-5.0, -2.0),
					Vector2(-2.0, -8.0)
				]
				draw_colored_polygon(main_pts, Color("141624"))
				if progress < 0.45:
					var lining_pts: PackedVector2Array = [
						Vector2(top_x, top_y),
						Vector2(tail_x, tail_y),
						Vector2(tail_x + 2.0, tail_y + 2.5),
						Vector2(top_x + 1.5, top_y + 1.5)
					]
					draw_colored_polygon(lining_pts, Color("6c2e42"))
	else:
		if hero.velocity.y < 0.0:
			var pts: PackedVector2Array = [
				Vector2(-3.0, -22.0),
				Vector2(-8.0, -14.0),
				Vector2(-13.0, 3.0),
				Vector2(-7.0, 5.0),
				Vector2(-2.0, -8.0)
			]
			draw_colored_polygon(pts, Color("141624"))
			draw_line(Vector2(-5.0, -16.0), Vector2(-10.0, 0.0), Color("282b40"), 1.0)
		else:
			var pts: PackedVector2Array = [
				Vector2(-3.0, -22.0),
				Vector2(-13.0, -27.0),
				Vector2(-20.0, -18.0),
				Vector2(-13.0, -9.0),
				Vector2(-2.0, -8.0)
			]
			draw_colored_polygon(pts, Color("141624"))
			var lining_pts: PackedVector2Array = [
				Vector2(-13.0, -27.0),
				Vector2(-20.0, -18.0),
				Vector2(-17.0, -16.0),
				Vector2(-11.0, -25.0)
			]
			draw_colored_polygon(lining_pts, Color("6c2e42"))
			draw_line(Vector2(-3.0, -22.0), Vector2(-13.0, -27.0), Color("3d465c"), 1.0)

func _draw_sotn_sword_arm_fix01(hand: Vector2, blade_angle: float) -> void:
	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var v: Vector2 = Vector2(-sin(blade_angle), cos(blade_angle))

	draw_line(hand - u * 2.0, hand, Color("1c1e28"), 2.2)
	draw_line(hand - v * 3.0, hand + v * 3.0, Color("ba9865"), 1.8)
	draw_rect(Rect2(hand - Vector2(1.0, 1.0), Vector2(2.0, 2.0)), Color("f3ce8e"))

	draw_circle(hand - u * 0.5, 1.6, Color("202438"))
	draw_circle(hand - u * 0.5, 1.2, Color("444957"))
	draw_rect(Rect2(hand - u * 0.5 - Vector2(0.5, 0.5), Vector2(1.0, 1.0)), Color("737d86"))

	draw_line(hand + u * 1.0, hand + u * 21.0, Color("b6c7cb"), 1.5)
	draw_line(hand + u * 1.0 + v * 0.4, hand + u * 20.8 + v * 0.2, Color("f5f7f2"), 1.1)
	draw_circle(hand + u * 21.0, 0.9, Color(1.9, 1.9, 2.0))

func _draw_sotn_windup_sparkle_arm_fix01(hand: Vector2, blade_angle: float, progress: float) -> void:
	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var tip: Vector2 = hand + u * 20.5
	var glint_size: float = progress * 3.0
	draw_line(tip - Vector2(glint_size, 0), tip + Vector2(glint_size, 0), Color(1.6, 1.6, 1.8, 0.9), 1.0)
	draw_line(tip - Vector2(0, glint_size), tip + Vector2(0, glint_size), Color(1.6, 1.6, 1.8, 0.9), 1.0)
	draw_circle(tip, 1.0, Color(2.0, 2.0, 2.0))

func _draw_sotn_slash_arc_arm_fix01(hand: Vector2, blade_angle: float, progress: float, has_hit: bool) -> void:
	var start_ang: float = -1.85 # -106°
	var max_sweep: float = 2.48 # 142°
	var current_end_ang: float = start_ang + max_sweep * clampf(progress * 1.30, 0.25, 1.0)
	var trail_start: float = start_ang + maxf(0.0, (progress - 0.30) * 1.8)

	draw_arc(hand, 22.0, trail_start, current_end_ang, 14, Color(0.42, 0.70, 1.0, 0.32), 4.5)
	draw_arc(hand, 20.8, trail_start + 0.06, current_end_ang, 14, Color(0.86, 0.94, 1.05, 0.88), 2.2)
	draw_arc(hand, 19.8, trail_start + 0.12, current_end_ang, 12, Color(1.5, 1.5, 1.6, 0.98), 1.2)

	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var tip: Vector2 = hand + u * 21.0
	draw_line(hand + u * 12.0, tip, Color(1.6, 1.6, 1.7, 0.95), 1.2)

	if has_hit:
		var imp: Vector2 = tip
		draw_line(imp, imp + Vector2(7.0, -5.0), Color(1.6, 1.35, 0.85, 1.0), 1.0)
		draw_line(imp, imp + Vector2(8.0, 2.0), Color(1.6, 1.45, 0.95, 1.0), 1.0)
		draw_line(imp, imp + Vector2(5.0, 7.0), Color(1.4, 1.15, 0.75, 0.85), 1.0)
		draw_line(imp, imp + Vector2(-4.0, -4.0), Color(1.2, 0.95, 0.65, 0.65), 1.0)
		draw_rect(Rect2(imp - Vector2(1.0, 1.0), Vector2(2.0, 2.0)), Color(2.0, 2.0, 2.0, 1.0))

func _draw_sotn_recovery_fade_arm_fix01(hand: Vector2, progress: float) -> void:
	if progress < 0.40:
		var fade_alpha: float = (1.0 - progress / 0.40) * 0.45
		draw_arc(hand, 20.8, -0.2, 0.62, 8, Color(0.85, 0.92, 1.0, fade_alpha), 1.2)

# =====================================================================
# VERSÃO ART-FIX02 (EXPERIMENTAL — REFINAMENTO ARTÍSTICO BASEADO NA PRANCHA)
# =====================================================================

func _draw_sotn_attack_art_fix02(hero: KnightController, attack: SwordAttack, frame: int) -> void:
	var aerial: bool = attack.aerial
	var progress: float = 0.0
	match attack.phase:
		SwordAttack.Phase.WINDUP:
			progress = clampf(1.0 - attack._remaining / maxf(attack.windup_duration, 0.001), 0.0, 1.0)
		SwordAttack.Phase.ACTIVE:
			progress = attack.get_active_progress()
		SwordAttack.Phase.RECOVERY:
			progress = clampf(1.0 - attack._remaining / maxf(attack.recovery_duration, 0.001), 0.0, 1.0)

	if attack.mode == SwordAttack.Mode.SOTN and attack.sotn_feedback_enabled and attack.visual_hitstop_remaining > 0.0:
		progress = attack.visual_hitstop_progress

	# Deslocamento sutil de avanço atlético no solo durante o golpe ativo conforme prancha
	var lunge_offset: Vector2 = Vector2.ZERO
	if not aerial:
		if attack.phase == SwordAttack.Phase.WINDUP:
			# Recuo de prontidão na antecipação
			lunge_offset = Vector2(-roundf(lerpf(0.0, 1.0, progress)), 0.0)
		elif attack.phase == SwordAttack.Phase.ACTIVE:
			# Estocada/passo a fundo atlético em direção ao golpe
			lunge_offset = Vector2(roundf(lerpf(0.0, 2.5, progress)), 0.0)
		elif attack.phase == SwordAttack.Phase.RECOVERY:
			# Sustenta avanço na primeira metade e acomoda de volta
			var rec_lunge: float = lerpf(2.5, 0.0, clampf((progress - 0.3) / 0.7, 0.0, 1.0))
			lunge_offset = Vector2(roundf(rec_lunge), 0.0)
	else:
		# No ar, leve avanço aerodinâmico
		lunge_offset = Vector2(1.0, -1.0 if hero.velocity.y < 0.0 else 0.0)

	# Coordenada exata da manopla / punho de Aren a partir do registro canônico
	var reg_data: Dictionary = ArenAttackArt.registration(frame)
	var hand: Vector2 = reg_data["blade"].position + lunge_offset
	var blade_angle: float

	match attack.phase:
		SwordAttack.Phase.WINDUP:
			# Preparação conforme a prancha: espada armada para trás na diagonal alta (-135° a -125°)
			blade_angle = lerpf(-2.35, -2.18, progress)
		SwordAttack.Phase.ACTIVE:
			# Varredura contínua do arco em meia-lua: do alto (-75°) ao corte horizontal/baixo (+22°)
			blade_angle = lerpf(-1.31, 0.38, progress)
		SwordAttack.Phase.RECOVERY:
			# Conclusão do corte e recuperação suave da guarda (+28° até -12°)
			if progress < 0.35:
				blade_angle = 0.49 # Sustenta o follow-through na baixa
			else:
				blade_angle = lerpf(0.49, -0.20, (progress - 0.35) / 0.65)

	# 1. Manto dinâmico com forro vináceo e ondulação fluida (camada de fundo)
	_draw_sotn_cloak_art_fix02(hero, attack.phase, progress, aerial)

	# 2. Corpo integrado: armadura, ombreira (pauldron), braço e manopla 100% autênticos
	_draw_sotn_body_integrated(frame, lunge_offset)

	# 3. Espada nobre física: guarda-mão dourado, manopla e lâmina espelhada
	_draw_sotn_sword_art_fix02(hand, blade_angle)

	# 4. Efeitos visuais conforme a prancha de direção de arte
	match attack.phase:
		SwordAttack.Phase.WINDUP:
			_draw_sotn_windup_sparkle_art_fix02(hand, blade_angle, progress)
		SwordAttack.Phase.ACTIVE:
			_draw_sotn_slash_arc_art_fix02(hand, blade_angle, progress, not attack._hit_targets.is_empty())
		SwordAttack.Phase.RECOVERY:
			_draw_sotn_recovery_fade_art_fix02(hand, progress)

func _draw_sotn_cloak_art_fix02(hero: KnightController, phase: SwordAttack.Phase, progress: float, aerial: bool) -> void:
	if not aerial:
		match phase:
			SwordAttack.Phase.WINDUP:
				var pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(-8.0, -21.0),
					Vector2(-12.0, -12.0),
					Vector2(-9.0, -3.0),
					Vector2(-3.0, -5.0)
				]
				draw_colored_polygon(pts, Color("11131d"))
				var lining_pts: PackedVector2Array = [
					Vector2(-8.0, -21.0),
					Vector2(-12.0, -12.0),
					Vector2(-10.0, -10.0),
					Vector2(-6.0, -19.0)
				]
				draw_colored_polygon(lining_pts, Color("752639"))
				draw_line(Vector2(-3.0, -22.0), Vector2(-8.0, -21.0), Color("2c344a"), 1.0)
			SwordAttack.Phase.ACTIVE:
				var top_x: float = lerpf(-12.0, -24.0, progress)
				var top_y: float = lerpf(-21.0, -18.0, progress)
				var tail_x: float = lerpf(-16.0, -28.0, progress)
				var tail_y: float = lerpf(-15.0, -10.0, progress)
				var bot_x: float = lerpf(-9.0, -18.0, progress)
				var bot_y: float = -3.0

				var main_pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(bot_x, bot_y),
					Vector2(-2.0, -8.0)
				]
				draw_colored_polygon(main_pts, Color("11131d"))

				# Forro vináceo interior vibrante (amostrado da prancha oficial #752639)
				var lining_pts: PackedVector2Array = [
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(tail_x + 3.0, tail_y + 3.5),
					Vector2(top_x + 2.5, top_y + 2.5)
				]
				draw_colored_polygon(lining_pts, Color("752639"))
				draw_line(Vector2(tail_x, tail_y), Vector2(tail_x + 3.0, tail_y + 3.5), Color("943448"), 1.0)
				draw_line(Vector2(-3.0, -22.0), Vector2(top_x, top_y), Color("2c344a"), 1.0)
			SwordAttack.Phase.RECOVERY:
				var top_x: float = lerpf(-24.0, -6.0, progress)
				var top_y: float = lerpf(-18.0, -21.0, progress)
				var tail_x: float = lerpf(-28.0, -8.0, progress)
				var tail_y: float = lerpf(-10.0, -2.0, progress)

				var main_pts: PackedVector2Array = [
					Vector2(-3.0, -22.0),
					Vector2(top_x, top_y),
					Vector2(tail_x, tail_y),
					Vector2(-5.0, -2.0),
					Vector2(-2.0, -8.0)
				]
				draw_colored_polygon(main_pts, Color("11131d"))
				if progress < 0.40:
					var lining_pts: PackedVector2Array = [
						Vector2(top_x, top_y),
						Vector2(tail_x, tail_y),
						Vector2(tail_x + 2.0, tail_y + 2.5),
						Vector2(top_x + 1.5, top_y + 1.5)
					]
					draw_colored_polygon(lining_pts, Color("752639"))
	else:
		if hero.velocity.y < 0.0:
			var pts: PackedVector2Array = [
				Vector2(-3.0, -22.0),
				Vector2(-9.0, -15.0),
				Vector2(-15.0, 4.0),
				Vector2(-8.0, 6.0),
				Vector2(-2.0, -8.0)
			]
			draw_colored_polygon(pts, Color("11131d"))
			var lining_pts: PackedVector2Array = [
				Vector2(-9.0, -15.0),
				Vector2(-15.0, 4.0),
				Vector2(-12.0, 5.0),
				Vector2(-7.0, -13.0)
			]
			draw_colored_polygon(lining_pts, Color("752639"))
			draw_line(Vector2(-5.0, -16.0), Vector2(-11.0, 1.0), Color("2c344a"), 1.0)
		else:
			var pts: PackedVector2Array = [
				Vector2(-3.0, -22.0),
				Vector2(-15.0, -28.0),
				Vector2(-23.0, -19.0),
				Vector2(-14.0, -8.0),
				Vector2(-2.0, -8.0)
			]
			draw_colored_polygon(pts, Color("11131d"))
			var lining_pts: PackedVector2Array = [
				Vector2(-15.0, -28.0),
				Vector2(-23.0, -19.0),
				Vector2(-19.0, -17.0),
				Vector2(-12.0, -26.0)
			]
			draw_colored_polygon(lining_pts, Color("752639"))
			draw_line(Vector2(-3.0, -22.0), Vector2(-15.0, -28.0), Color("2c344a"), 1.0)

func _draw_sotn_sword_art_fix02(hand: Vector2, blade_angle: float) -> void:
	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var v: Vector2 = Vector2(-sin(blade_angle), cos(blade_angle))

	# 1. Base da empunhadura e pomo dourado
	draw_line(hand - u * 3.0, hand, Color("141620"), 2.2)
	draw_circle(hand - u * 3.0, 1.2, Color("ba9865"))

	# 2. Guarda-mão refinado em ouro nobre girando solidário com a lâmina
	draw_line(hand - v * 3.6, hand + v * 3.6, Color("ba9865"), 2.0)
	draw_line(hand - v * 2.8, hand + v * 2.8, Color("dfb776"), 1.2)
	draw_rect(Rect2(hand - Vector2(1.2, 1.2), Vector2(2.4, 2.4)), Color("f3ce8e"))

	# 3. Reforço de placas da manopla: dedos e articulação segurando o punho da espada
	draw_circle(hand - u * 0.7, 1.8, Color("1e2232"))
	draw_circle(hand - u * 0.7, 1.3, Color("3b4152"))
	draw_rect(Rect2(hand - u * 0.7 - Vector2(0.5, 0.5), Vector2(1.0, 1.0)), Color("707b8b"))

	# 4. Lâmina física de aço nobre com dorso resistente e gume afiado
	draw_line(hand + u * 1.0, hand + u * 21.0, Color("a4b8bf"), 1.6)
	draw_line(hand + u * 1.0 + v * 0.45, hand + u * 20.8 + v * 0.25, Color("f6f8f5"), 1.2)
	draw_circle(hand + u * 21.0, 1.0, Color(2.1, 2.1, 2.2))

func _draw_sotn_windup_sparkle_art_fix02(hand: Vector2, blade_angle: float, progress: float) -> void:
	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var tip: Vector2 = hand + u * 20.5
	var glint_size: float = 1.5 + progress * 2.8
	draw_line(tip - Vector2(glint_size, 0), tip + Vector2(glint_size, 0), Color(1.7, 1.7, 2.0, 0.95), 1.0)
	draw_line(tip - Vector2(0, glint_size), tip + Vector2(0, glint_size), Color(1.7, 1.7, 2.0, 0.95), 1.0)
	draw_circle(tip, 1.1, Color(2.2, 2.2, 2.2))

func _draw_sotn_slash_arc_art_fix02(hand: Vector2, blade_angle: float, progress: float, has_hit: bool) -> void:
	var start_ang: float = -1.95 # -112°
	var max_sweep: float = 2.60 # 149°
	var current_end_ang: float = start_ang + max_sweep * clampf(progress * 1.32, 0.28, 1.0)
	var trail_start: float = start_ang + maxf(0.0, (progress - 0.28) * 1.9)

	# 1. Aura espectral exterior (azul gelo/ciano translúcido amostrado da prancha)
	draw_arc(hand, 23.0, trail_start, current_end_ang, 16, Color(0.38, 0.68, 1.0, 0.32), 6.0)

	# 2. Corpo do feixe em meia-lua luminoso
	draw_arc(hand, 21.8, trail_start + 0.05, current_end_ang, 16, Color(0.70, 0.88, 1.0, 0.78), 3.2)

	# 3. Lâmina prateada
	draw_arc(hand, 20.8, trail_start + 0.09, current_end_ang, 14, Color(0.92, 0.96, 1.05, 0.95), 1.8)

	# 4. Núcleo cortante branco puro
	draw_arc(hand, 19.9, trail_start + 0.15, current_end_ang, 12, Color(1.85, 1.85, 2.05, 1.0), 1.1)

	# 5. Traço dinâmico da lâmina conectando a mão à ponta no arco
	var u: Vector2 = Vector2(cos(blade_angle), sin(blade_angle))
	var tip: Vector2 = hand + u * 21.0
	draw_line(hand + u * 12.0, tip, Color(1.7, 1.7, 1.9, 0.95), 1.2)

	# 6. Faíscas cortantes em caso de impacto com o inimigo
	if has_hit:
		var imp: Vector2 = tip
		draw_line(imp, imp + Vector2(8.0, -6.0), Color(1.7, 1.4, 0.85, 1.0), 1.0)
		draw_line(imp, imp + Vector2(9.0, 1.0), Color(1.7, 1.5, 0.95, 1.0), 1.0)
		draw_line(imp, imp + Vector2(6.0, 7.0), Color(1.5, 1.2, 0.75, 1.0), 1.0)
		draw_line(imp, imp + Vector2(-5.0, -4.0), Color(1.3, 1.0, 0.65, 0.8), 1.0)
		draw_line(imp, imp + Vector2(2.0, -9.0), Color(1.8, 1.6, 1.0, 1.0), 1.0)
		draw_circle(imp, 1.5, Color(2.2, 2.2, 2.2, 1.0))

func _draw_sotn_recovery_fade_art_fix02(hand: Vector2, progress: float) -> void:
	if progress < 0.40:
		var fade_alpha: float = (1.0 - progress / 0.40) * 0.50
		draw_arc(hand, 21.0, -0.22, 0.65, 10, Color(0.78, 0.90, 1.0, fade_alpha), 1.4)
		draw_arc(hand, 19.8, -0.10, 0.55, 8, Color(1.4, 1.5, 1.8, fade_alpha * 0.8), 0.8)

# =====================================================================
# DESENHO INTEGRADO DO CORPO (COMPARTILHADO ENTRE AS VERSÕES)
# =====================================================================

func _draw_sotn_body_integrated(frame: int, lunge_offset: Vector2) -> void:
	var full: Rect2 = ArenAttackArt.FRAMES[frame]
	var blade: Rect2 = ArenAttackArt.BLADES[frame]
	var data: Dictionary = ArenAttackArt.registration(frame)
	var root: Vector2 = data["root"]
	var scale_val: Vector2 = data["scale"]

	# As 4 fatias anatômicas preservam o torso, cabeça, pernas, ombreira (pauldron),
	# braço e manopla originais de Aren desenhados em pixel art de alta fidelidade,
	# omitindo cirurgicamente apenas os pixels da antiga lâmina horizontal rígida.
	var pieces: Array[Rect2] = [
		Rect2(full.position, Vector2(full.size.x, blade.position.y - full.position.y)),
		Rect2(Vector2(full.position.x, blade.end.y), Vector2(full.size.x, full.end.y - blade.end.y)),
		Rect2(Vector2(full.position.x, blade.position.y), Vector2(blade.position.x - full.position.x, blade.size.y)),
		Rect2(Vector2(blade.end.x, blade.position.y), Vector2(full.end.x - blade.end.x, blade.size.y))
	]

	for piece: Rect2 in pieces:
		if piece.has_area():
			var target: Rect2 = Rect2(((piece.position - root) * scale_val).round() + lunge_offset, (piece.size * scale_val).round())
			draw_texture_rect_region(ArenAttackArt.TEXTURE, target, piece, Color(1.4, 1.43, 1.38, 1))
