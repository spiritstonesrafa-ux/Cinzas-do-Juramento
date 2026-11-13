extends DamageSource
## Ataque curto dos inimigos terrestres da Fornalha.

var owner_enemy: Node2D
var active := false
var damage := 1
var direction := 1
var contacted: Array[int] = []
var hit_shape: CollisionShape2D

func configure(owner: Node2D, shape_size: Vector2) -> void:
	owner_enemy = owner
	collision_layer = 32
	collision_mask = 16
	monitoring = false
	monitorable = true
	var rect := RectangleShape2D.new()
	rect.size = shape_size
	hit_shape = CollisionShape2D.new()
	hit_shape.shape = rect
	hit_shape.disabled = true
	add_child(hit_shape)

func set_active(value: bool, facing: int) -> void:
	active = value
	direction = facing
	position.x = facing * (15.0 if shape_size_is_small() else 21.0)
	if is_instance_valid(hit_shape):
		hit_shape.set_deferred("disabled", not value)
	if not value:
		contacted.clear()

func shape_size_is_small() -> bool:
	return owner_enemy != null and owner_enemy.get("kind") == 1

func contact_damage(receiver_id: int) -> int:
	if not active or contacted.has(receiver_id):
		return 0
	var receiver := instance_from_id(receiver_id) as KnightController
	if receiver == null or receiver.survival.is_dead or not is_instance_valid(owner_enemy):
		return 0
	var dx := receiver.global_position.x - owner_enemy.global_position.x
	if dx * direction <= 0.0:
		return 0
	contacted.append(receiver_id)
	return damage

func _draw() -> void:
	pass
