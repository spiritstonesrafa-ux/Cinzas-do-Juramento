class_name KnightHurtbox
extends Area2D
## Defensive contact query; never shares the sword's layer or shape.
## COMBATE-CONTACT-DAMAGE-01: Detects both DamageSource hazards/swings (layer 32)
## and living dangerous enemy bodies (layers 128 | 256).

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

@export var contact_damage_enabled: bool = true
@export var enemy_body_mask: int = 128 | 256 # Layers 8 and 9 (Cemetery, Forest, Abbey enemies & Bosses)

var last_source_position: Vector2 = Vector2.ZERO
var last_damage_source: Node = null
var last_damage_type: String = "" # "hazard", "attack", "body"

func _is_body_dangerous(body: Node) -> bool:
	if body == null or not is_instance_valid(body):
		return false
	if "contact_damage_enabled" in body and not body.get("contact_damage_enabled"):
		return false
	if "state" in body:
		var st = body.get("state")
		var s_class = body.get("State")
		if s_class != null:
			if "DEAD" in s_class and st == s_class.DEAD:
				return false
			if "DEFEATED" in s_class and st == s_class.DEFEATED:
				return false
			if "RESET" in s_class and st == s_class.RESET:
				return false
			if "INTRO" in s_class and st == s_class.INTRO:
				return false
			if "DORMANT" in s_class and st == s_class.DORMANT:
				return false
	if "current_health" in body and body.get("current_health") <= 0:
		return false
	if "health" in body and body.get("health") <= 0:
		return false
	if "awake" in body and not body.get("awake"):
		return false
	if "is_dead" in body and body.get("is_dead"):
		return false
	if body.has_method("is_dead") and body.is_dead():
		return false
	return true

func contact_damage() -> int:
	last_source_position = Vector2.ZERO
	last_damage_source = null
	last_damage_type = ""

	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = collision_shape.global_transform

	if not contact_damage_enabled:
		query.collision_mask = collision_mask
		query.collide_with_areas = true
		query.collide_with_bodies = false
	else:
		query.collision_mask = collision_mask | enemy_body_mask
		query.collide_with_areas = true
		query.collide_with_bodies = true

	var results: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(query, 32)

	# Pass 1: Prioritize explicit weapon attacks and hazards (DamageSource on layer 32)
	for result: Dictionary in results:
		var source: DamageSource = result["collider"] as DamageSource
		if source != null:
			var amount: int = source.contact_damage(get_parent().get_instance_id())
			if amount > 0:
				last_source_position = source.global_position
				last_damage_source = source
				last_damage_type = "hazard"
				return amount

	# Pass 2: Body contact with active, living enemies (CharacterBody2D on layers 128 | 256)
	if contact_damage_enabled:
		for result: Dictionary in results:
			var body: CharacterBody2D = result["collider"] as CharacterBody2D
			if body != null and body != get_parent():
				if _is_body_dangerous(body):
					last_source_position = body.global_position
					last_damage_source = body
					last_damage_type = "body"
					var dmg: int = body.get("contact_damage") if "contact_damage" in body else 1
					return maxi(1, dmg)

	return 0
