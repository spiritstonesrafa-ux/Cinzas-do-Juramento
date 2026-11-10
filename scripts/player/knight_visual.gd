extends PixelCanvas
## FIX02 original raster poses. Only observes homologated state; no physics writes.
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
	else:
		_update_dash_vfx(delta, dashing, hero)

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
		return

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

func _draw_attack(hero: KnightController) -> void:
	var attack: SwordAttack = hero.sword_attack
	var frame: int = ArenAttackArt.pose(attack)
	if attack.aerial:
		# Airborne body posture and a registered sword, with three distinct phases.
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
		# Horizontal, short and inside the original x=6..28/y=-21..-7 corridor.
		l(Vector2(10, -20), Vector2(27, -20), Color("c8d6d1", 0.4))
		l(Vector2(12, -13), Vector2(25, -13), Color("f6ce94", 0.32))
		if not attack._hit_targets.is_empty():
			r(24, -19, 2, 2, LIGHT)
			l(Vector2(24, -16), Vector2(27, -13), AMBER)
	if hero.survival.invulnerability_remaining > 0.63:
		l(Vector2(-12, -23), Vector2(-16, -27), AMBER)
