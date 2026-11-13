extends DamageSource
## Ember projectile spat by the smoke crow.

var velocity := Vector2.ZERO
var lifetime := 2.2
var age := 0.0
var spent := false

func configure(start: Vector2, aim: Vector2) -> void:
	global_position = start
	velocity = aim.normalized() * 112.0
	collision_layer = 32
	collision_mask = 0
	monitoring = false
	monitorable = true
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	var shape := CollisionShape2D.new()
	shape.shape = circle
	add_child(shape)

func _physics_process(delta: float) -> void:
	age += delta
	global_position += velocity * delta
	if age >= lifetime or spent:
		queue_free()
	queue_redraw()

func contact_damage(receiver_id: int) -> int:
	if spent:
		return 0
	var receiver := instance_from_id(receiver_id) as KnightController
	if receiver == null or receiver.survival.is_dead:
		return 0
	spent = true
	return 1

func _draw() -> void:
	var pulse := 1.0 + 0.2 * sin(age * 26.0)
	draw_circle(Vector2.ZERO, 5.0 * pulse, Color("e9481d"))
	draw_circle(Vector2.ZERO, 2.2 * pulse, Color("ffd06b"))
	draw_circle(Vector2(-2.0, 2.0), 1.2, Color("fff1b4"))
