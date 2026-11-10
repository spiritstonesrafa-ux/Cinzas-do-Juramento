class_name CervoBossAttackSource
extends DamageSource
## Fonte de dano oficial do Cervo Espectral e de suas manifestações (M6-CERVO-BOSS).
## Gerencia hitboxes direcionadas, formato variável por ataque e proteção contra multi-hit por ciclo.

enum AttackType {
	NONE,
	CHARGE,
	ANTLER,
	STOMP,
	LEAP,
	ECHO
}

@export var damage_amount: int = 1

var current_attack: AttackType = AttackType.NONE
var facing: int = -1
var attack_cycle_id: int = 0
var hit_receivers: Dictionary = {}
var is_active: bool = false

@onready var shape_node: CollisionShape2D = get_node_or_null("CollisionShape2D")

func _ready() -> void:
	collision_layer = 32
	collision_mask = 16
	monitoring = false
	monitorable = false
	if shape_node == null:
		shape_node = CollisionShape2D.new()
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.size = Vector2(24, 24)
		shape_node.shape = rect
		add_child(shape_node)
	shape_node.disabled = true

func configure(type: AttackType, p_facing: int, p_cycle: int) -> void:
	current_attack = type
	facing = p_facing
	attack_cycle_id = p_cycle
	hit_receivers.clear()
	
	if shape_node == null or shape_node.shape == null:
		return
	
	var rect: RectangleShape2D = shape_node.shape as RectangleShape2D
	if rect == null:
		rect = RectangleShape2D.new()
		shape_node.shape = rect
	
	match type:
		AttackType.CHARGE:
			# Caixa de impacto frontal na investida
			rect.size = Vector2(64, 38)
			shape_node.position = Vector2(facing * 36, -20)
		AttackType.ANTLER:
			# Arco frontal superior de varredura das galhadas
			rect.size = Vector2(56, 48)
			shape_node.position = Vector2(facing * 34, -28)
		AttackType.STOMP:
			# Onda de choque no piso (apenas rés do solo, não atinge plataformas elevadas)
			rect.size = Vector2(140, 16)
			shape_node.position = Vector2(0, -8)
		AttackType.LEAP:
			# Impacto de aterrissagem do Salto Predatório
			rect.size = Vector2(70, 32)
			shape_node.position = Vector2(0, -16)
		AttackType.ECHO:
			# Corpo translúcido da manifestação em travessia
			rect.size = Vector2(48, 36)
			shape_node.position = Vector2(facing * 16, -20)
		_:
			rect.size = Vector2(10, 10)
			shape_node.position = Vector2.ZERO

func set_active(p_active: bool) -> void:
	is_active = p_active
	set_deferred("monitorable", p_active)
	if shape_node != null:
		shape_node.set_deferred("disabled", not p_active)
	if not p_active:
		current_attack = AttackType.NONE
		hit_receivers.clear()

func contact_damage(receiver_id: int) -> int:
	if not is_active:
		return 0
	if hit_receivers.has(receiver_id):
		# Previne dano repetido dentro da mesma janela/ciclo de ataque
		return 0
	hit_receivers[receiver_id] = true
	return damage_amount

func _draw() -> void:
	# O dano do chefe é invisível / desenhado pelas spritesheets oficiais homologadas
	pass
