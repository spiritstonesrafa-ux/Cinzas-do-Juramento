class_name EmberGuardian
extends SwordReceiver
## Titã Ossuário: five telegraphed attacks and a phase-two super for the Forge.

const TITAN_HAZARD: Script = preload("res://scripts/boss/titan_hazard.gd")
const TITAN_CONTACT_BODY: Script = preload("res://scripts/phase4/titan_contact_body.gd")
const WALK: Texture2D = preload("res://assets/art/m4a/ossuary_titan/walk_8f.png")
const SLAM: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_slam_16f.png")
const CHARGE: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_charge_16f.png")
const SWEEP: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_chain_sweep_16f.png")
const BREATH: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_furnace_breath_16f.png")
const SUPER: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_ossuary_collapse_16f.png")
const ERUPTION: Texture2D = preload("res://assets/art/m4a/ossuary_titan/attack_chain_furnace_eruption_16f.png")
const BG_KEY_SHADER: Shader = preload("res://assets/art/m4a/ossuary_titan/remove_sheet_bg.gdshader")
const FRAME_GROUND_LINES: Dictionary = {
	"walk_8f.png": [343, 342, 342, 342, 343, 343, 343, 343],
	"attack_slam_16f.png": [327, 327, 301, 301, 305, 305, 305, 305, 294, 294, 294, 294, 298, 298, 298, 298],
	"attack_charge_16f.png": [290, 290, 291, 289, 287, 285, 283, 287, 296, 275, 276, 275, 286, 286, 286, 286],
	"attack_chain_sweep_16f.png": [289, 289, 289, 289, 287, 287, 287, 287, 287, 287, 287, 287, 292, 292, 292, 292],
	"attack_furnace_breath_16f.png": [296, 296, 296, 295, 292, 292, 291, 291, 289, 288, 288, 288, 292, 293, 296, 297],
	"attack_ossuary_collapse_16f.png": [281, 282, 311, 311, 311, 300, 262, 227, 280, 283, 285, 283, 279, 278, 279, 279],
	"attack_chain_furnace_eruption_16f.png": [292, 292, 292, 293, 287, 287, 286, 286, 285, 285, 285, 284, 297, 296, 297, 295],
}

signal defeated
enum Attack { IDLE, WARNING, ERUPTION, RECOVERY, DEAD }
var max_health: int = 20
var health: int = 20
var state: Attack = Attack.IDLE
var timer: float = 1.2
var attack_index: int = -1
var contact_damage_enabled: bool = true
var _flash: float = 0.0
var target: KnightController
var active: bool = false
var super_used: bool = false
var _sprite: Sprite2D
var _frame_cache: Dictionary = {}
var _animation_clock: float = 0.0
var _walk_distance: float = 0.0
var _trail_clock: float = 0.0
var _attack_direction: int = -1
var _hazards: Array[TitanHazard] = []
var _home_position := Vector2.ZERO

func _ready() -> void:
	_home_position = global_position
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	collision_layer = 8
	collision_mask = 4
	monitorable = true
	monitoring = false
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 17.0
	capsule.height = 68.0
	shape.shape = capsule
	shape.position = Vector2(0, -34)
	add_child(shape)
	var contact_body := CharacterBody2D.new()
	contact_body.name = "ContactBody"
	contact_body.set_script(TITAN_CONTACT_BODY)
	contact_body.set("titan", self)
	contact_body.collision_layer = 128
	contact_body.collision_mask = 0
	var contact_shape := CollisionShape2D.new()
	var contact_capsule := CapsuleShape2D.new()
	contact_capsule.radius = 17.0
	contact_capsule.height = 68.0
	contact_shape.shape = contact_capsule
	contact_shape.position = Vector2(0, -34)
	contact_body.add_child(contact_shape)
	add_child(contact_body)
	_sprite = Sprite2D.new()
	_sprite.name = "GuardianSprite"
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var keyed_material := ShaderMaterial.new()
	keyed_material.shader = BG_KEY_SHADER
	_sprite.material = keyed_material
	_sprite.scale = Vector2(0.20, 0.20)
	_sprite.position = Vector2(0, -35)
	_sprite.z_index = 1
	add_child(_sprite)
	hit_received.connect(take_damage)
	_set_walk_frame(0)

func reset_encounter() -> void:
	for hazard: TitanHazard in _hazards:
		if is_instance_valid(hazard):
			hazard.disarm()
			hazard.queue_free()
	_hazards.clear()
	global_position = _home_position
	health = max_health
	state = Attack.IDLE
	timer = 1.2
	attack_index = -1
	active = false
	super_used = false
	contact_damage_enabled = true
	_flash = 0.0
	_walk_distance = 0.0
	_trail_clock = 0.0
	_attack_direction = -1
	if is_instance_valid(_sprite):
		_sprite.visible = true
		_set_walk_frame(0)
	queue_redraw()

func is_contact_dangerous() -> bool:
	return active and state != Attack.DEAD and health > 0

func _process(delta: float) -> void:
	_animation_clock += delta
	_flash = maxf(0.0, _flash - delta)
	if state == Attack.DEAD:
		_sprite.visible = false
		return
	_sprite.visible = true
	_sprite.modulate = Color(1.6, 1.2, 0.9, 1.0) if _flash > 0.0 else Color.WHITE
	if is_instance_valid(target):
		# The Titan art faces right by default, so mirror only when the target is left.
		_sprite.flip_h = target.global_position.x < global_position.x
	var walking := false
	if active and state == Attack.IDLE and is_instance_valid(target):
		var delta_x: float = target.global_position.x - global_position.x
		if absf(delta_x) > 92.0:
			var stop_x: float = target.global_position.x - signf(delta_x) * 80.0
			var old_x := global_position.x
			global_position.x = move_toward(global_position.x, stop_x, 38.0 * delta)
			global_position.x = clampf(global_position.x, 2390.0, 3000.0)
			_walk_distance += absf(global_position.x - old_x)
			walking = absf(global_position.x - old_x) > 0.01
	if walking:
		_set_walk_frame(int(floor(_walk_distance / 3.8)) % 8)
	elif state in [Attack.IDLE, Attack.RECOVERY]:
		_set_walk_frame(0)
	else:
		_set_attack_frame()
	if state == Attack.DEAD or not active: return
	timer -= delta
	if state == Attack.ERUPTION and attack_index == 1:
		var dir := _attack_direction
		var old_x := global_position.x
		global_position.x = clampf(global_position.x + dir * 128.0 * delta, 2390.0, 3000.0)
		_walk_distance += absf(global_position.x - old_x)
		_trail_clock += delta
		if _trail_clock >= 0.18:
			_trail_clock = 0.0
			_spawn_hazard("trail", -dir, global_position + Vector2(-dir * 28, 0), 0.0)
	if timer <= 0.0:
		match state:
			Attack.IDLE:
				if health <= max_health / 2 and not super_used:
					attack_index = 5
					super_used = true
				else:
					attack_index = (attack_index + 1) % 5
				state = Attack.WARNING
				timer = 1.35 if attack_index == 5 else 0.95
			Attack.WARNING:
				state = Attack.ERUPTION
				timer = 2.8 if attack_index == 5 else (0.72 if attack_index == 1 else 0.58)
				_trail_clock = 0.0
				_launch_attack()
			Attack.ERUPTION:
				state = Attack.RECOVERY
				timer = 1.35 if attack_index == 5 else 1.0
			Attack.RECOVERY:
				if attack_index == 5: attack_index = 4
				state = Attack.IDLE
				timer = 0.48
	queue_redraw()

func _set_walk_frame(frame: int) -> void:
	_sprite.texture = _atlas_frame(WALK, frame, 8, 1, true)

func _set_attack_frame() -> void:
	var sheet: Texture2D = SLAM
	match attack_index:
		1: sheet = CHARGE
		2: sheet = SWEEP
		3: sheet = BREATH
		4: sheet = ERUPTION
		5: sheet = SUPER
		_: sheet = SLAM
	var warning_time := 1.35 if attack_index == 5 else 0.95
	var attack_time := 2.8 if attack_index == 5 else (0.72 if attack_index == 1 else 0.58)
	var recovery_time := 1.35 if attack_index == 5 else 1.0
	var progress := 0.0
	if state == Attack.WARNING:
		progress = (1.0 - timer / warning_time) * 0.48
	elif state == Attack.ERUPTION:
		progress = 0.48 + (1.0 - timer / attack_time) * 0.37
	elif state == Attack.RECOVERY:
		progress = 0.85 + (1.0 - timer / recovery_time) * 0.15
	_sprite.texture = _atlas_frame(sheet, mini(15, int(progress * 16.0)), 4, 4)

func _atlas_frame(atlas: Texture2D, frame: int, columns: int, rows: int, walking := false) -> AtlasTexture:
	var walk_crop := Rect2(float(frame) * 272.0, 184.0, 272.0, 350.0) if walking else Rect2()
	var cell := Vector2(float(atlas.get_width()) / columns, float(atlas.get_height()) / rows)
	var region := walk_crop if walking else Rect2(Vector2(frame % columns, int(frame / columns)) * cell, cell)
	var key := "%s:%d:%d:%d:%s" % [atlas.resource_path, frame, columns, rows, str(walking)]
	if _frame_cache.has(key):
		_anchor_frame_to_floor(atlas, frame, region)
		return _frame_cache[key] as AtlasTexture
	_anchor_frame_to_floor(atlas, frame, region)
	var texture := AtlasTexture.new()
	texture.atlas = atlas
	texture.region = region
	_frame_cache[key] = texture
	return texture

func _anchor_frame_to_floor(atlas: Texture2D, frame: int, region: Rect2) -> void:
	var sheet_name := atlas.resource_path.get_file()
	var lines: Array = FRAME_GROUND_LINES.get(sheet_name, [])
	var bottom: float = float(lines[frame]) if frame < lines.size() else region.size.y - 1.0
	# Align the lowest opaque boot pixel in every pose to the boss's ground position.
	_sprite.position.y = (region.size.y * 0.5 - bottom - 0.5) * _sprite.scale.y

func activate() -> void:
	if state == Attack.DEAD: return
	active = true

func _launch_attack() -> void:
	if not is_instance_valid(target): return
	var dir := 1 if target.global_position.x > global_position.x else -1
	_attack_direction = dir
	match attack_index:
		0:
			_spawn_hazard("wave", dir, global_position + Vector2(62 * dir, 0), 0.0)
		1:
			# Charge movement leaves a chain of short-lived animated fire patches.
			_spawn_hazard("trail", -dir, global_position + Vector2(-28 * dir, 0), 0.0)
		2:
			_spawn_hazard("sweep", dir, global_position + Vector2(66 * dir, 0), 0.0)
		3:
			for i: int in range(3):
				_spawn_hazard("breath", dir, global_position + Vector2(36 * dir, -58), float(i) * 0.22)
		4:
			# Two columns flank the player's position, leaving a visible escape gap.
			var center_x: float = clampf(target.global_position.x, 2420.0, 2970.0)
			_spawn_hazard("pillar", 1, Vector2(center_x - 72, global_position.y), 0.45)
			_spawn_hazard("pillar", 1, Vector2(center_x + 72, global_position.y), 0.78)
		5:
			# Super: paired fire waves plus delayed pillars make the double jump matter.
			_spawn_hazard("wave", -1, global_position + Vector2(-58, 0), 0.0)
			_spawn_hazard("wave", 1, global_position + Vector2(58, 0), 0.12)
			_spawn_hazard("pillar", 1, Vector2(target.global_position.x - 82, global_position.y), 0.55)
			_spawn_hazard("pillar", 1, Vector2(target.global_position.x + 82, global_position.y), 0.9)

func _spawn_hazard(kind: String, direction: int, at: Vector2, delay: float) -> void:
	var hazard: TitanHazard = TITAN_HAZARD.new()
	hazard.configure(kind, direction, self, delay)
	get_tree().current_scene.add_child(hazard)
	hazard.global_position = at
	_hazards.append(hazard)

func take_damage() -> void:
	if state == Attack.DEAD or state == Attack.ERUPTION: return
	health -= 1
	_flash = 0.12
	if health <= 0:
		state = Attack.DEAD
		for hazard: TitanHazard in _hazards:
			if is_instance_valid(hazard): hazard.disarm(); hazard.queue_free()
		_hazards.clear()
		defeated.emit()
	queue_redraw()

func _draw() -> void:
	if state == Attack.DEAD: return
	if state == Attack.WARNING:
		var buildup: float = 1.0 - timer / (1.35 if attack_index == 5 else 0.95)
		var color := Color("ff9839") if attack_index in [0, 1, 4, 5] else Color("e3a55a")
		draw_arc(Vector2(0,-7), 32.0 + buildup * 9.0, 0.0, TAU, 36, Color(color,0.5 + buildup*0.35), 2.0)
		if attack_index in [0, 5]:
			for side: int in [-1,1]:
				draw_line(Vector2(side*14,0),Vector2(side*(35+buildup*42),-2),Color(color,0.35+buildup*0.45),2.0)
