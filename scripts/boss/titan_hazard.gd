class_name TitanHazard
extends DamageSource
## Shared animated fire-wave, lingering trail and delayed furnace-pillar hazard.
const WAVE: Texture2D = preload("res://assets/art/m4a/ossuary_titan/fire_wave_8f.png")
const PILLAR: Texture2D = preload("res://assets/art/m4a/ossuary_titan/fire_pillar_16f.png")
const BG_KEY_SHADER: Shader = preload("res://assets/art/m4a/ossuary_titan/remove_fire_checker.gdshader")
const WAVE_ART_RECT := Rect2(0, 250, 272, 230)
var kind := "wave"
var direction := 1
var guardian: Node2D
var age := 0.0
var warning := 0.0
var lifetime := 2.0
var speed := 235.0
var spent := false
var live := true
var shape_node: CollisionShape2D

func configure(type: String, side: int, owner: Node2D, delay := 0.0) -> void:
	kind = type
	direction = side
	guardian = owner
	warning = delay
	if type == "wave": lifetime = 1.35
	elif type == "breath": lifetime = 0.9
	elif type == "trail": lifetime = 1.65
	elif type == "sweep": lifetime = 0.42
	else: lifetime = 0.8

func _ready() -> void:
	var keyed_material := ShaderMaterial.new()
	keyed_material.shader = BG_KEY_SHADER
	material = keyed_material
	collision_layer = 32
	collision_mask = 16
	monitoring = false
	process_physics_priority = -3
	shape_node = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(48, 46) if kind == "wave" else (Vector2(112, 40) if kind == "breath" else (Vector2(42, 22) if kind == "trail" else (Vector2(92, 40) if kind == "sweep" else Vector2(34, 86))))
	shape_node.shape = shape
	shape_node.position = Vector2(55 * direction, -4) if kind == "breath" else Vector2(0, -22 if kind == "wave" else (-48 if kind == "sweep" else (-12 if kind == "trail" else -34)))
	shape_node.disabled = warning > 0
	add_child(shape_node)

func disarm() -> void:
	live = false
	if is_instance_valid(shape_node): shape_node.set_deferred("disabled", true)

func _physics_process(delta: float) -> void:
	if not live: return
	if not _owner_is_active():
		disarm(); queue_free(); return
	age += delta
	if warning > 0.0:
		warning = maxf(0.0, warning - delta)
		if warning == 0.0: shape_node.set_deferred("disabled", false)
	elif kind in ["wave", "breath"]:
		var max_distance := 310.0 if kind == "wave" else 220.0
		var step := minf(speed * delta, max_distance - absf(global_position.x - guardian.global_position.x))
		position.x += direction * step
	elif kind == "trail" and fposmod(age, 0.24) < delta:
		# Briefly re-arm each flame segment without repeating damage to the same player.
		spent = false
	if age >= lifetime:
		disarm(); queue_free(); return
	queue_redraw()

func _owner_is_active() -> bool:
	if not is_instance_valid(guardian): return false
	if guardian is OathGuardian:
		var oath := guardian as OathGuardian
		return oath.awake and is_instance_valid(oath.target) and not oath.target.survival.is_dead
	if guardian is EmberGuardian:
		var ember := guardian as EmberGuardian
		return ember.active and ember.state != EmberGuardian.Attack.DEAD and is_instance_valid(ember.target) and not ember.target.survival.is_dead
	return false

func contact_damage(receiver_id: int) -> int:
	if not live or warning > 0.0 or spent: return 0
	var player := instance_from_id(receiver_id) as KnightController
	if player == null or player.survival.is_dead: return 0
	spent = true
	return 1

func _draw() -> void:
	if not live: return
	if kind == "pillar":
		var index := mini(15, int(age * 18.0))
		# Let the bottom of the flame overlap the platform slightly so it visibly grows from the floor.
		draw_texture_rect_region(PILLAR, Rect2(-40,-112,80,120), Rect2((index % 4)*272, int(index/4)*362,272,362), Color(1,1,1,0.85 if warning > 0 else 1))
		if warning > 0: draw_arc(Vector2(0,0), 22 + sin(age*18.0)*3.0, 0, TAU, 20, Color(1,0.5,0.16,0.8), 2)
	elif kind == "breath":
		# Break the ground-wave silhouette into animated, overlapping tongues. Their
		# staggered lower edges keep this chest-high plume from reading as a flat strip.
		var index := int(age * 18.0) % 8
		var alpha := clampf(1.0 - age / lifetime, 0.0, 1.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(direction, 1))
		var segments := 14
		var cell_w := 272.0 / segments
		var total_w := 118.0
		for i in range(segments):
			var phase := age * 9.0 + float(i) * 1.43
			var lower_edge := 4.0 + sin(phase) * 5.0 + sin(float(i) * 2.17 + age * 4.0) * 2.2
			var height := 34.0 + sin(phase * 0.73) * 5.0
			var dest := Rect2(float(i) * total_w / segments - 1.0, lower_edge - height, total_w / segments + 2.0, height)
			var source := Rect2(index * 272.0 + float(i) * cell_w, WAVE_ART_RECT.position.y, cell_w + 1.0, WAVE_ART_RECT.size.y)
			draw_texture_rect_region(WAVE, dest, source, Color(1, 1, 1, alpha))
	elif kind == "sweep":
		var index := int(age * 15.0) % 8
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(direction,1))
		draw_texture_rect_region(WAVE, Rect2(-68,-42,136,42), Rect2(index*272, WAVE_ART_RECT.position.y, WAVE_ART_RECT.size.x, WAVE_ART_RECT.size.y), Color(1,0.9,0.62,0.9))
	else:
		var index := int(age * 15.0) % 8
		var alpha := 0.95 if kind == "wave" else clampf(1.0 - age/lifetime,0.0,0.8)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(direction,1))
		var destination := Rect2(-62,-56,124,56) if kind == "wave" else Rect2(-34,-31,68,31)
		draw_texture_rect_region(WAVE, destination, Rect2(index*272, WAVE_ART_RECT.position.y, WAVE_ART_RECT.size.x, WAVE_ART_RECT.size.y), Color(1,1,1,alpha))
