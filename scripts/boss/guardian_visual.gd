extends Node2D
## Animated sprite atlases for the Ossuary Titan. Every attack uses its own 16-frame cycle.
const WALK: Texture2D = preload("res://assets/art/m4a/ossuary_titan/walk_8f.png")
const SLAM: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_slam_16f.png")
const CHARGE: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_charge_16f.png")
const SWEEP: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_chain_sweep_16f.png")
const BREATH: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_furnace_breath_16f.png")
const SUPER: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_ossuary_collapse_16f.png")
const ERUPTION: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_chain_furnace_eruption_16f.png")
var walk_distance: float = 0.0
var previous_x: float
var initialized := false

func _process(_delta: float) -> void:
	var boss := get_parent() as OathGuardian
	if boss == null: return
	if not initialized:
		previous_x = boss.global_position.x
		initialized = true
	if boss.state == OathGuardian.State.PURSUIT:
		walk_distance += absf(boss.global_position.x - previous_x)
	previous_x = boss.global_position.x
	queue_redraw()

func _draw() -> void:
	var boss := get_parent() as OathGuardian
	if boss == null: return
	if boss.state == OathGuardian.State.DEFEATED and boss.get_node("Conclusion").played: return
	var sheet: Texture2D = WALK
	var frame := int(floor(walk_distance / 3.8)) % 8 if boss.state == OathGuardian.State.PURSUIT else 0
	var cols := 8
	var rows := 1
	var cell := Vector2i(272, 724)
	var attacking := boss.state in [OathGuardian.State.TELEGRAPH, OathGuardian.State.ATTACK, OathGuardian.State.PUNISH, OathGuardian.State.SUPER_WARN, OathGuardian.State.SUPER_ACTIVE, OathGuardian.State.SUPER_RECOVER]
	if attacking:
		cols = 4
		rows = 4
		var progress := 0.0
		var total := maxf(0.01, boss.warning_seconds() + boss.active_seconds() + boss.recovery_seconds())
		if boss.state == OathGuardian.State.TELEGRAPH: progress = 1.0 - boss.remaining / maxf(0.01, boss.warning_seconds())
		elif boss.state == OathGuardian.State.ATTACK: progress = 0.55 + (1.0 - boss.remaining / maxf(0.01, boss.active_seconds())) * 0.3
		elif boss.state == OathGuardian.State.PUNISH: progress = 0.85 + (1.0 - boss.remaining / maxf(0.01, boss.recovery_seconds())) * 0.15
		elif boss.state == OathGuardian.State.SUPER_WARN: progress = (1.0 - boss.remaining / 1.3) * 0.25
		elif boss.state == OathGuardian.State.SUPER_ACTIVE: progress = 0.25 + (1.0 - boss.remaining / 2.8) * 0.55
		else: progress = 0.8 + (1.0 - boss.remaining / 1.4) * 0.2
		frame = mini(15, int(progress * 16.0))
		match boss.state:
			OathGuardian.State.SUPER_WARN, OathGuardian.State.SUPER_ACTIVE, OathGuardian.State.SUPER_RECOVER:
				sheet = SUPER
			_:
				match boss.pattern:
					OathGuardian.Pattern.HEAVY: sheet = SLAM
					OathGuardian.Pattern.CHARGE: sheet = CHARGE
					OathGuardian.Pattern.SWEEP: sheet = SWEEP
					OathGuardian.Pattern.WAVE: sheet = BREATH
					OathGuardian.Pattern.ERUPTION: sheet = ERUPTION
			cell = Vector2i(int(sheet.get_width() / cols), int(sheet.get_height() / rows))
	elif boss.state in [OathGuardian.State.HURT, OathGuardian.State.DEFEATED]:
		frame = 0
	var src := Rect2(Vector2((frame % cols) * cell.x, int(frame / cols) * cell.y), Vector2(cell))
	if sheet == WALK:
		# The walk strip has tall transparent margins; crop to the Titan so it matches the attack atlas scale.
		src = Rect2(frame * 272, 184, 272, 350)
	var alpha := 1.0
	if boss.state == OathGuardian.State.DEFEATED: alpha = clampf(boss.remaining / 0.7, 0.15, 1.0)
	var dest := Rect2(-76.0, -174.0, 152.0, 174.0)
	draw_texture_rect_region(sheet, dest, src, Color(1, 1, 1, alpha), false)
