class_name CervoVisual
extends PixelCanvas
## Visual oficial em pixel-art animado do chefe Cervo Espectral (ART-BOSS-01).
## Gerencia a exibição e transição das 4 animações canônicas de alta fidelidade:
## 1. IDLE (Repouso): 8 quadros, 4x2
## 2. WALK (Caminhada): 8 quadros, 4x2
## 3. GALLOP (Galope): 12 quadros, 4x3
## 4. TURN (Virada de direção): 8 quadros, 4x2

enum AnimState {
	IDLE,
	WALK,
	GALLOP,
	TURN
}

signal animation_finished(anim_name: String)
signal animation_looped(anim_name: String)
signal frame_changed(anim_name: String, frame_index: int)
signal facing_changed(new_facing: int)

# Texturas oficiais pré-carregadas (4 spritesheets processadas)
const TEX_IDLE: Texture2D = preload("res://assets/art/cervo/cervo_idle.png")
const TEX_WALK: Texture2D = preload("res://assets/art/cervo/cervo_walk.png")
const TEX_GALLOP: Texture2D = preload("res://assets/art/cervo/cervo_gallop.png")
const TEX_TURN: Texture2D = preload("res://assets/art/cervo/cervo_turn.png")

# Configurações de grade das animações
const ANIM_CONFIG: Dictionary = {
	AnimState.IDLE: {
		"name": "idle",
		"texture": TEX_IDLE,
		"columns": 4,
		"rows": 2,
		"total_frames": 8,
		"fps": 8.0,
		"loop": true
	},
	AnimState.WALK: {
		"name": "walk",
		"texture": TEX_WALK,
		"columns": 4,
		"rows": 2,
		"total_frames": 8,
		"fps": 8.0,
		"loop": true
	},
	AnimState.GALLOP: {
		"name": "gallop",
		"texture": TEX_GALLOP,
		"columns": 4,
		"rows": 3,
		"total_frames": 12,
		"fps": 12.0,
		"loop": true
	},
	AnimState.TURN: {
		"name": "turn",
		"texture": TEX_TURN,
		"columns": 4,
		"rows": 2,
		"total_frames": 8,
		"fps": 10.0,
		"loop": false
	}
}

# Calibração geométrica canônica:
# Cada célula das spritesheets possui 256 x 256 px.
# O ponto de contato dos cascos com o solo está calibrado em y = 225 px e centro x = 128 px.
const CELL_SIZE: Vector2 = Vector2(256.0, 256.0)
const PIVOT_HOOF: Vector2 = Vector2(128.0, 225.0)

# Escala canônica de renderização no mundo 320x180 (3.5x altura do Aren, ~75-88px altura total com galhadas)
const DEFAULT_SCALE: float = 0.38

# Estado público de reprodução
@export var current_state: AnimState = AnimState.IDLE
@export var facing: int = 1: # 1 = Direita, -1 = Esquerda
	set(value):
		var target: int = 1 if value >= 0 else -1
		if facing != target:
			facing = target
			facing_changed.emit(facing)
			queue_redraw()

@export var display_scale: float = DEFAULT_SCALE:
	set(value):
		display_scale = maxf(0.05, value)
		queue_redraw()

@export var is_playing: bool = true
@export var modulate_color: Color = Color.WHITE:
	set(value):
		modulate_color = value
		queue_redraw()

# Variáveis internas de tempo de quadro
var current_frame: int = 0
var _anim_time: float = 0.0
var _current_fps: float = 8.0
var _turn_initial_facing: int = 1

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	_apply_anim_config(current_state)

func _process(delta: float) -> void:
	if not is_playing:
		return

	var config: Dictionary = ANIM_CONFIG[current_state]
	var fps: float = _current_fps if _current_fps > 0.0 else float(config["fps"])
	var frame_duration: float = 1.0 / fps

	_anim_time += delta
	if _anim_time >= frame_duration:
		_anim_time -= frame_duration
		_advance_frame()

func _advance_frame() -> void:
	var config: Dictionary = ANIM_CONFIG[current_state]
	var total: int = int(config["total_frames"])
	var is_loop: bool = bool(config["loop"])
	var next_frame: int = current_frame + 1

	if next_frame >= total:
		if is_loop:
			current_frame = 0
			animation_looped.emit(String(config["name"]))
			frame_changed.emit(String(config["name"]), current_frame)
			queue_redraw()
		else:
			# Fim de animação one-shot (como TURN)
			current_frame = total - 1
			var finished_anim: String = String(config["name"])
			if current_state == AnimState.TURN:
				# Conclui a virada invertendo a orientação canônica
				facing = -_turn_initial_facing
				play(AnimState.IDLE)
			animation_finished.emit(finished_anim)
	else:
		current_frame = next_frame
		frame_changed.emit(String(config["name"]), current_frame)
		queue_redraw()

func _apply_anim_config(state: AnimState, custom_fps: float = -1.0) -> void:
	current_state = state
	var config: Dictionary = ANIM_CONFIG[state]
	current_frame = 0
	_anim_time = 0.0
	_current_fps = custom_fps if custom_fps > 0.0 else float(config["fps"])
	queue_redraw()

func play(state: AnimState, custom_fps: float = -1.0) -> void:
	if current_state == state and is_playing:
		return

	if state == AnimState.TURN:
		_turn_initial_facing = facing

	_apply_anim_config(state, custom_fps)
	is_playing = true

func play_by_name(anim_name: String, custom_fps: float = -1.0) -> void:
	var lower: String = anim_name.to_lower().strip_edges()
	match lower:
		"idle", "repouso":
			play(AnimState.IDLE, custom_fps)
		"walk", "caminhada":
			play(AnimState.WALK, custom_fps)
		"gallop", "galope":
			play(AnimState.GALLOP, custom_fps)
		"turn", "virada":
			play(AnimState.TURN, custom_fps)
		_:
			push_warning("CervoVisual: Animação desconhecida '%s'" % anim_name)

func turn_to(target_facing: int) -> void:
	var tgt: int = 1 if target_facing >= 0 else -1
	if tgt == facing:
		return
	# Inicia animação de virada oficial
	play(AnimState.TURN)

func toggle_facing() -> void:
	turn_to(-facing)

func set_frame(frame_index: int) -> void:
	var config: Dictionary = ANIM_CONFIG[current_state]
	var total: int = int(config["total_frames"])
	current_frame = clampi(frame_index, 0, total - 1)
	queue_redraw()

func get_current_anim_name() -> String:
	return String(ANIM_CONFIG[current_state]["name"])

func get_total_frames() -> int:
	return int(ANIM_CONFIG[current_state]["total_frames"])

func get_current_texture() -> Texture2D:
	return ANIM_CONFIG[current_state]["texture"] as Texture2D

func get_ground_offset() -> Vector2:
	# Retorna o vetor em pixels do pivô dos cascos no espaço de destino
	return -PIVOT_HOOF * display_scale

func _draw() -> void:
	var config: Dictionary = ANIM_CONFIG[current_state]
	var tex: Texture2D = config["texture"] as Texture2D
	if tex == null:
		return

	var cols: int = int(config["columns"])
	var col: int = current_frame % cols
	var row: int = current_frame / cols
	var src_rect: Rect2 = Rect2(Vector2(col, row) * CELL_SIZE, CELL_SIZE)

	# Determina se a textura deve ser espelhada horizontalmente
	# A spritesheet base está voltada para a DIREITA.
	# Na virada (TURN), a animação original vira da DIREITA para a ESQUERDA.
	var flip_h: bool = false
	if current_state == AnimState.TURN:
		# Se começou virando a partir da esquerda (-1), espelha a animação de virada para virar da esquerda para a direita
		if _turn_initial_facing < 0:
			flip_h = true
	else:
		# Em IDLE, WALK e GALLOP, espelha se estiver virado para a esquerda
		if facing < 0:
			flip_h = true

	var w: float = CELL_SIZE.x * display_scale
	var h: float = CELL_SIZE.y * display_scale

	# Ponto de ancoragem: o pivô (128, 225) deve cair exatamente na posição local (0, 0)
	var x_offset: float = -PIVOT_HOOF.x * display_scale
	var y_offset: float = -PIVOT_HOOF.y * display_scale

	if flip_h:
		# Desenha com escala X invertida centralizada no pivô
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
		var dest_rect: Rect2 = Rect2(x_offset, y_offset, w, h)
		draw_texture_rect_region(tex, dest_rect, src_rect, modulate_color)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		var dest_rect: Rect2 = Rect2(x_offset, y_offset, w, h)
		draw_texture_rect_region(tex, dest_rect, src_rect, modulate_color)
