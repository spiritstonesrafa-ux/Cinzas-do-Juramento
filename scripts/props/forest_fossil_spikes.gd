class_name ForestFossilSpikes
extends DamageSource
## Perigo ambiental de solo para a Floresta dos Ossos (M6-C1).
## Ciclo temporizado: SAFE (1.8s) -> WARNING (0.6s) -> ACTIVE (0.8s) -> RECOVER (0.4s).
## Causa dano de contato (1) exclusivamente no estado ACTIVE.

enum State { SAFE, WARNING, ACTIVE, RECOVER }

@export var encounter_id: String = ""
@export_range(0.1, 10.0, 0.1) var safe_duration: float = 1.8
@export_range(0.1, 10.0, 0.1) var warning_duration: float = 0.6
@export_range(0.1, 10.0, 0.1) var active_duration: float = 0.8
@export_range(0.1, 10.0, 0.1) var recovery_duration: float = 0.4

var state: State = State.SAFE
var remaining: float = 1.8

const ROOT_DARK: Color = Color("1a1e1b")
const ROOT_MID: Color = Color("2e3630")
const BONE_PALE: Color = Color("ded8cb")
const BONE_MID: Color = Color("aba190")
const BONE_DARK: Color = Color("6b6255")
const EYE_AMBER: Color = Color("ffb84d")
const EYE_TEAL: Color = Color("4ce0d2")

@onready var shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	process_physics_priority = -2
	reset_hazard()

func reset_hazard() -> void:
	state = State.SAFE
	remaining = maxf(0.1, safe_duration)
	_sync()

func disarm() -> void:
	if is_instance_valid(shape):
		shape.disabled = true

func _physics_process(delta: float) -> void:
	remaining -= delta
	while remaining <= 0.0:
		state = ((int(state) + 1) % 4) as State
		var durations: Array[float] = [safe_duration, warning_duration, active_duration, recovery_duration]
		remaining += maxf(0.1, durations[state])
	_sync()

func _sync() -> void:
	if is_instance_valid(shape):
		shape.disabled = (state != State.ACTIVE)
	queue_redraw()

func contact_damage(_receiver_id: int) -> int:
	return 1 if state == State.ACTIVE else 0

func _draw() -> void:
	# Base de solo fossilizado e raízes petrificadas
	draw_rect(Rect2(-12, -3, 24, 3), ROOT_DARK)
	draw_rect(Rect2(-11, -2, 22, 2), ROOT_MID)
	
	match state:
		State.SAFE:
			# Fissuras discretas no solo com pontas ósseas recolhidas
			for x in [-8, 0, 8]:
				draw_rect(Rect2(x - 1, -3, 2, 1), BONE_DARK)
		
		State.WARNING:
			# Fissuras pulsando em âmbar/turquesa e pequenas espículas começando a brotar
			draw_line(Vector2(-11, -3), Vector2(11, -3), Color(EYE_AMBER, 0.7), 1)
			for x in [-8, 0, 8]:
				draw_line(Vector2(x, -3), Vector2(x, -6), BONE_MID, 2)
				draw_line(Vector2(x, -6), Vector2(x, -8), EYE_AMBER, 1)
			# Tremor e partículas de poeira óssea
			draw_rect(Rect2(-4, -10, 2, 2), Color(BONE_PALE, 0.5))
			draw_rect(Rect2(5, -9, 2, 2), Color(EYE_AMBER, 0.6))
		
		State.ACTIVE:
			# Três grandes espículas ósseas afiadas projetadas para cima (altura 13 px)
			for x in [-8, 0, 8]:
				# Corpo da espícula
				var poly: PackedVector2Array = PackedVector2Array([
					Vector2(x - 3, -3),
					Vector2(x + 3, -3),
					Vector2(x, -14)
				])
				draw_colored_polygon(poly, BONE_PALE)
				# Borda sombreada
				draw_line(Vector2(x - 3, -3), Vector2(x, -14), BONE_MID, 1)
				# Ponta afiada fóssil
				draw_line(Vector2(x, -11), Vector2(x, -14), BONE_PALE, 1)
			# Fissura fóssil na base
			draw_line(Vector2(-11, -3), Vector2(11, -3), BONE_DARK, 1)
		
		State.RECOVER:
			# Espículas retraindo de volta ao solo
			for x in [-8, 0, 8]:
				var poly_rec: PackedVector2Array = PackedVector2Array([
					Vector2(x - 2, -3),
					Vector2(x + 2, -3),
					Vector2(x, -6)
				])
				draw_colored_polygon(poly_rec, BONE_DARK)
			draw_line(Vector2(-10, -3), Vector2(10, -3), Color(ROOT_MID, 0.8), 1)

