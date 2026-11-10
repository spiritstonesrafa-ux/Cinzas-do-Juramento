class_name CervoBossEcho
extends Node2D
## Entidade funcional de manifestação espectral (Ecos da Floresta - M6-CERVO-BOSS).
## Contém componente visual homolgado, hitbox ofensiva temporária e contrajogo por espada/esquiva.

const CervoEchoVisual = preload("res://scripts/boss/cervo_echo_visual.gd")
const CervoBossAttackSource = preload("res://scripts/boss/cervo_boss_attack_source.gd")
const SwordReceiver = preload("res://scripts/combat/sword_receiver.gd")

signal dissolved

@export var move_speed: float = 75.0
@export var duration: float = 2.4

var facing: int = -1
var cycle_id: int = 0
var bounds_left: float = 160.0
var bounds_right: float = 800.0

@onready var visual: CervoEchoVisual = $Visual
@onready var attack_source: CervoBossAttackSource = $AttackSource
@onready var receiver: SwordReceiver = $SwordReceiver

func _ready() -> void:
	if visual == null:
		visual = CervoEchoVisual.new()
		visual.name = "Visual"
		add_child(visual)
	
	if attack_source == null:
		attack_source = CervoBossAttackSource.new()
		attack_source.name = "AttackSource"
		add_child(attack_source)
	
	if receiver == null:
		receiver = SwordReceiver.new()
		receiver.name = "SwordReceiver"
		receiver.collision_layer = 8
		receiver.collision_mask = 4
		var shape_rec: CollisionShape2D = CollisionShape2D.new()
		var rect: RectangleShape2D = RectangleShape2D.new()
		rect.size = Vector2(48, 36)
		shape_rec.shape = rect
		shape_rec.position = Vector2(0, -18)
		receiver.add_child(shape_rec)
		add_child(receiver)
	
	receiver.hit_received.connect(_on_sword_hit)
	visual.echo_dissolved.connect(_on_visual_dissolved)

func launch(start_pos: Vector2, p_facing: int, p_cycle: int, p_bounds_left: float = 160.0, p_bounds_right: float = 800.0) -> void:
	global_position = start_pos
	facing = p_facing
	cycle_id = p_cycle
	bounds_left = p_bounds_left
	bounds_right = p_bounds_right
	
	visual.spawn_active(Vector2.ZERO, facing, duration, move_speed)
	attack_source.configure(CervoBossAttackSource.AttackType.ECHO, facing, cycle_id)
	attack_source.set_active(true)
	set_process(true)

func _process(delta: float) -> void:
	if visual.echo_state == CervoEchoVisual.EchoState.ACTIVE:
		position.x += float(facing) * move_speed * delta
		# Ao atingir as bordas da arena, inicia dissipação natural
		if (facing < 0 and position.x <= bounds_left) or (facing > 0 and position.x >= bounds_right):
			disarm()
			visual.start_dissolve()

func _on_sword_hit() -> void:
	# Contrajogo legítimo: golpe de espada dissipa a manifestação fantasmagórica
	disarm()
	visual.start_dissolve()

func disarm() -> void:
	if is_instance_valid(attack_source):
		attack_source.set_active(false)
	if is_instance_valid(receiver):
		receiver.set_deferred("monitoring", false)
		receiver.set_deferred("monitorable", false)

func dismiss() -> void:
	disarm()
	if is_instance_valid(visual):
		visual.dismiss()
	queue_free()

func _on_visual_dissolved() -> void:
	dissolved.emit()
	queue_free()
