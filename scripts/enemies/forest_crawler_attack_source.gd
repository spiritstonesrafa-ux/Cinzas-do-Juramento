class_name ForestCrawlerAttackSource
extends DamageSource
## Fonte de dano de curto alcance para o Rastejante Fóssil (M6-C1).
## Entrega dano de contato durante a fase ativa do bote.

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
	# Se a hitbox estiver direcionada para um lado, garante que o alvo está na direção do ataque
	if absf(position.x) > 0.1 and distance * signf(position.x) <= 0.0:
		return 0
	_contacted.append(receiver_id)
	return maxi(0, damage)

func _draw() -> void:
	pass # Visual gerenciado pelo ForestCrawlerVisual

