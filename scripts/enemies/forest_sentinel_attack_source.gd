class_name ForestSentinelAttackSource
extends DamageSource
## Fonte de dano de impacto pesado para o Sentinela Ósseo (M6-C1).
## Alcance de 26 px com verificação de desobstrução de cenário no corredor de ataque.

var damage: int = 1
var active: bool = false
var _contacted: Array[int] = []

@onready var shape: CollisionShape2D = $CollisionShape2D

func set_active(value: bool) -> void:
	active = value
	if is_instance_valid(shape):
		shape.disabled = not value
	if not value:
		_contacted.clear()

func contact_damage(receiver_id: int) -> int:
	if not active or _contacted.has(receiver_id):
		return 0
	var receiver: KnightController = instance_from_id(receiver_id) as KnightController
	if receiver == null or receiver.survival.is_dead:
		return 0
	var start: Vector2 = get_parent().global_position
	var distance: float = receiver.global_position.x - start.x
	# Confirma alinhamento com a direção do golpe
	if distance * signf(position.x) <= 0.0:
		return 0
	
	# Verificação de corredor livre de paredes sólidas
	var corridor: RectangleShape2D = RectangleShape2D.new()
	corridor.size = Vector2(absf(distance), 20.0)
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = corridor
	query.transform = Transform2D(0.0, Vector2(start.x + distance * 0.5, start.y - 16.0))
	query.collision_mask = 1
	if not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
		return 0
	
	_contacted.append(receiver_id)
	return maxi(0, damage)

func _draw() -> void:
	pass # O visual do Sentinela desenha o cutelo e o impacto

