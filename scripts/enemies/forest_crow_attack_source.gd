class_name ForestCrowAttackSource
extends DamageSource
## Fonte de dano de mergulho para o Corvo Espectral (M6-C1).
## Dano de contato único consumido no primeiro impacto durante o DIVE.

var damage: int = 1
var active: bool = false
var _consumed: bool = false

@onready var shape: CollisionShape2D = $CollisionShape2D

func set_active(value: bool) -> void:
	active = value
	if is_instance_valid(shape):
		shape.disabled = not value
	if not value:
		_consumed = false

func contact_damage(receiver_id: int) -> int:
	if not active or _consumed:
		return 0
	var receiver: KnightController = instance_from_id(receiver_id) as KnightController
	if receiver == null or receiver.survival.is_dead:
		return 0
	var ray: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(
		global_position, receiver.global_position + Vector2(0, -12), 1)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		return 0
	_consumed = true
	return maxi(0, damage)

func _draw() -> void:
	pass # Visual gerenciado pelo ForestSpectralCrowVisual

