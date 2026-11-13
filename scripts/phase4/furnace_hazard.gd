extends DamageSource
## Hot slag and steam vents use the shared player damage contract.

const FIRE_LOOP: Texture2D = preload("res://assets/art/m7a/furnace_fire_loop.png")
const FRAME_COUNT: int = 4
const FRAME_RATE: float = 12.0
const SOURCE_FRAME_WIDTH: float = 543.0
const SOURCE_FRAME_HEIGHT: float = 724.0
const FIRE_BASELINE: float = 520.0

var vent_width: float = 24.0
var vent_height: float = 10.0
var _clock: float = 0.0
var _fire: Sprite2D

func _ready() -> void:
	_fire = Sprite2D.new()
	_fire.name = "AnimatedFlame"
	_fire.texture = FIRE_LOOP
	_fire.hframes = FRAME_COUNT
	_fire.centered = false
	_fire.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	var scale_x: float = vent_width / SOURCE_FRAME_WIDTH
	var scale_y: float = minf(scale_x * 0.52, 0.05)
	_fire.scale = Vector2(scale_x, scale_y)
	_fire.position = Vector2(-vent_width * 0.5, vent_height * 0.5 - FIRE_BASELINE * scale_y)
	_fire.frame = 0
	_fire.z_index = 1
	add_child(_fire)

func _process(delta: float) -> void:
	_clock += delta
	if is_instance_valid(_fire):
		_fire.frame = int(floor(_clock * FRAME_RATE)) % FRAME_COUNT
