class_name CervoPreview
extends Node2D
## Cena isolada de pré-visualização e homologação visual do Cervo Espectral (ART-BOSS-01).
## Permite inspecionar ciclos de animação, proporção relativa com Aren, contato com solo
## e teste de deslocamento lateral para validação de atrito/deslizamento de cascos.

const CervoVisual = preload("res://scripts/boss/cervo_visual.gd")
const AREN_POSES: Texture2D = preload("res://assets/art/fix02/aren_poses.png")
const AREN_IDLE_RECT: Rect2 = Rect2(86, 18, 230, 386)

const FLOOR_Y: float = 138.0
const SCALES: Array[float] = [0.38, 0.50, 1.00]

var cervo: CervoVisual
var scale_index: int = 0
var moving_enabled: bool = false
var show_aren: bool = true
var show_guides: bool = true
var is_paused: bool = false

# Aren reference position
var aren_pos: Vector2 = Vector2(55.0, FLOOR_Y)

# Cervo movement speeds (calibrated for scale 0.38)
# Stride length per second to prevent ground sliding
const SPEED_WALK_BASE: float = 42.0
const SPEED_GALLOP_BASE: float = 100.0

func _ready() -> void:
	# Instancia o componente visual oficial
	cervo = CervoVisual.new()
	cervo.name = "CervoVisual"
	cervo.position = Vector2(180.0, FLOOR_Y)
	cervo.display_scale = SCALES[scale_index]
	cervo.facing = 1
	add_child(cervo)

	cervo.frame_changed.connect(_on_cervo_frame_changed)
	cervo.animation_finished.connect(_on_cervo_anim_finished)
	cervo.animation_looped.connect(_on_cervo_anim_looped)
	cervo.charge_sequence_completed.connect(_on_cervo_charge_completed)
	cervo.charge_stage_changed.connect(_on_cervo_charge_stage_changed)
	cervo.antler_sequence_completed.connect(_on_cervo_antler_completed)
	cervo.antler_stage_changed.connect(_on_cervo_antler_stage_changed)
	cervo.stomp_sequence_completed.connect(_on_cervo_stomp_completed)
	cervo.stomp_stage_changed.connect(_on_cervo_stomp_stage_changed)

	cervo.play(CervoVisual.AnimState.IDLE)
	queue_redraw()

func _process(delta: float) -> void:
	if moving_enabled and not is_paused:
		_process_movement(delta)
	queue_redraw()

func _process_movement(delta: float) -> void:
	var state: CervoVisual.AnimState = cervo.current_state
	var speed: float = 0.0

	if state == CervoVisual.AnimState.WALK:
		speed = SPEED_WALK_BASE * (cervo.display_scale / 0.38)
	elif state == CervoVisual.AnimState.GALLOP:
		speed = SPEED_GALLOP_BASE * (cervo.display_scale / 0.38)

	if speed > 0.0:
		cervo.position.x += float(cervo.facing) * speed * delta

		# Limites da arena de teste para inversão suave
		var min_x: float = 70.0
		var max_x: float = 275.0

		if cervo.facing > 0 and cervo.position.x >= max_x:
			cervo.position.x = max_x
			cervo.turn_to(-1)
		elif cervo.facing < 0 and cervo.position.x <= min_x:
			cervo.position.x = min_x
			cervo.turn_to(1)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.is_pressed():
		return

	var key: InputEventKey = event as InputEventKey
	match key.keycode:
		KEY_1:
			cervo.play(CervoVisual.AnimState.IDLE)
			_update_pause_state()
		KEY_2:
			cervo.play(CervoVisual.AnimState.WALK)
			_update_pause_state()
		KEY_3:
			cervo.play(CervoVisual.AnimState.GALLOP)
			_update_pause_state()
		KEY_4:
			cervo.play(CervoVisual.AnimState.TURN)
			_update_pause_state()
		KEY_5:
			cervo.start_charge_sequence()
			_update_pause_state()
		KEY_6:
			cervo.start_antler_sequence()
			_update_pause_state()
		KEY_7:
			cervo.start_stomp_sequence()
			_update_pause_state()
		KEY_F, KEY_SPACE:
			cervo.toggle_facing()
			_update_pause_state()
		KEY_S:
			scale_index = (scale_index + 1) % SCALES.size()
			cervo.display_scale = SCALES[scale_index]
		KEY_M:
			moving_enabled = not moving_enabled
		KEY_P:
			is_paused = not is_paused
			cervo.is_playing = not is_paused
		KEY_LEFT:
			if is_paused:
				var prev_f: int = (cervo.current_frame - 1 + cervo.get_total_frames()) % cervo.get_total_frames()
				cervo.set_frame(prev_f)
		KEY_RIGHT:
			if is_paused:
				var next_f: int = (cervo.current_frame + 1) % cervo.get_total_frames()
				cervo.set_frame(next_f)
		KEY_G:
			show_guides = not show_guides
		KEY_A:
			show_aren = not show_aren
		KEY_R:
			cervo.position = Vector2(180.0, FLOOR_Y)
			cervo.facing = 1
			cervo.play(CervoVisual.AnimState.IDLE)
			moving_enabled = false
			is_paused = false
			cervo.is_playing = true
		KEY_ESCAPE:
			get_tree().quit(0)

	queue_redraw()

func _update_pause_state() -> void:
	if is_paused:
		cervo.is_playing = false

func _on_cervo_frame_changed(_anim: String, _frame: int) -> void:
	queue_redraw()

func _on_cervo_anim_finished(anim: String) -> void:
	if anim == "turn" and moving_enabled:
		# Retorna à movimentação na nova direção após virar
		cervo.play(CervoVisual.AnimState.WALK)
	queue_redraw()

func _on_cervo_anim_looped(_anim: String) -> void:
	queue_redraw()

func _on_cervo_charge_completed() -> void:
	queue_redraw()

func _on_cervo_charge_stage_changed(_stage: String) -> void:
	queue_redraw()

func _on_cervo_antler_completed() -> void:
	queue_redraw()

func _on_cervo_antler_stage_changed(_stage: String) -> void:
	queue_redraw()

func _on_cervo_stomp_completed() -> void:
	queue_redraw()

func _on_cervo_stomp_stage_changed(_stage: String) -> void:
	queue_redraw()

func _draw() -> void:
	# 1. Fundo atmosférico da Floresta dos Ossos (Setor 10 / Clareira da Bruma)
	_draw_background()

	# 2. Piso e marcadores de alinhamento
	_draw_floor()

	# 3. Aren de referência para proporção
	if show_aren:
		_draw_aren_reference()

	# 4. Guias visuais e réguas de contato
	if show_guides:
		_draw_guides()

	# 5. Painel HUD de informações e controles
	_draw_hud()

func _draw_background() -> void:
	# Céu noturno espectral
	draw_rect(Rect2(0, 0, 320, 180), Color("080a10"), true)

	# Névoa azulada ao fundo
	for i in range(8):
		var y: float = 60.0 + i * 10.0
		var alpha: float = 0.02 + i * 0.015
		draw_rect(Rect2(0, y, 320, 180 - y), Color(0.1, 0.45, 0.55, alpha), true)

	# Silhuetas de árvores e galhos fossilizados ao fundo
	draw_line(Vector2(20, 140), Vector2(35, 70), Color("151a24"), 3)
	draw_line(Vector2(35, 70), Vector2(18, 45), Color("121620"), 2)
	draw_line(Vector2(35, 70), Vector2(50, 48), Color("121620"), 2)

	draw_line(Vector2(295, 140), Vector2(285, 65), Color("151a24"), 4)
	draw_line(Vector2(285, 65), Vector2(270, 40), Color("121620"), 2)
	draw_line(Vector2(285, 65), Vector2(305, 42), Color("121620"), 2)

func _draw_floor() -> void:
	# Solo rochoso fossilizado (y=FLOOR_Y a y=180)
	draw_rect(Rect2(0, FLOOR_Y, 320, 180 - FLOOR_Y), Color("11141c"), true)
	# Borda superior do solo
	draw_line(Vector2(0, FLOOR_Y), Vector2(320, FLOOR_Y), Color("263242"), 1)
	draw_line(Vector2(0, FLOOR_Y + 1), Vector2(320, FLOOR_Y + 1), Color("1b222c"), 1)

func _draw_aren_reference() -> void:
	# Aren desenhado com precisão 1:1 ao knight_visual.gd
	var dims: Vector2 = (AREN_IDLE_RECT.size * Vector2(1.2, 1.0) * 36.0 / 386.0).round()
	var dest: Rect2 = Rect2(aren_pos + Vector2(-roundf(dims.x * 0.76), -36.0), dims)
	draw_texture_rect_region(AREN_POSES, dest, AREN_IDLE_RECT, Color(1.4, 1.43, 1.38, 0.9))

	# Rótulo de escala do Aren
	var font = ThemeDB.fallback_font
	draw_string(font, aren_pos + Vector2(-15, 12), "Aren (24px)", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("9ec5cf"))

func _draw_guides() -> void:
	var font = ThemeDB.fallback_font

	# Linha verde de contato com o solo
	draw_line(Vector2(0, FLOOR_Y), Vector2(320, FLOOR_Y), Color(0.2, 0.8, 0.4, 0.5), 1)

	# Ponto focal do casco do Cervo (pivô local 0, 0)
	var c_pos: Vector2 = cervo.position
	draw_line(c_pos + Vector2(-6, 0), c_pos + Vector2(6, 0), Color("00f0ff"), 1)
	draw_line(c_pos + Vector2(0, -6), c_pos + Vector2(0, 6), Color("00f0ff"), 1)

	# Altura do Aren (24px)
	draw_line(aren_pos + Vector2(-18, 0), aren_pos + Vector2(-18, -24), Color("9ec5cf", 0.7), 1)
	draw_line(aren_pos + Vector2(-21, 0), aren_pos + Vector2(-15, 0), Color("9ec5cf", 0.7), 1)
	draw_line(aren_pos + Vector2(-21, -24), aren_pos + Vector2(-15, -24), Color("9ec5cf", 0.7), 1)

	# Altura aproximada do Cervo no mundo (~75px com galhadas no scale 0.38)
	var boss_h: float = 200.0 * cervo.display_scale
	var ruler_x: float = c_pos.x + (50.0 if cervo.facing > 0 else -50.0)
	draw_line(Vector2(ruler_x, FLOOR_Y), Vector2(ruler_x, FLOOR_Y - boss_h), Color("00f0ff", 0.6), 1)
	draw_line(Vector2(ruler_x - 3, FLOOR_Y), Vector2(ruler_x + 3, FLOOR_Y), Color("00f0ff", 0.6), 1)
	draw_line(Vector2(ruler_x - 3, FLOOR_Y - boss_h), Vector2(ruler_x + 3, FLOOR_Y - boss_h), Color("00f0ff", 0.6), 1)
	draw_string(font, Vector2(ruler_x + (4 if cervo.facing > 0 else -35), FLOOR_Y - boss_h * 0.5), "%.0fpx" % boss_h, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("00f0ff"))

func _draw_hud() -> void:
	var font = ThemeDB.fallback_font

	# Painel de topo semi-transparente
	draw_rect(Rect2(0, 0, 320, 32), Color(0.04, 0.06, 0.09, 0.88), true)
	draw_line(Vector2(0, 32), Vector2(320, 32), Color(0.18, 0.28, 0.35, 0.7), 1)

	# Título
	draw_string(font, Vector2(6, 11), "CERVO ESPECTRAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("00f0ff"))
	draw_string(font, Vector2(98, 11), "| ART-BOSS-04 PREVIEW", HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color("769aa8"))

	# Barra de seleção de animações (1 a 7)
	var anim_names = ["1:IDLE", "2:WALK", "3:GALLOP", "4:TURN", "5:INVEST", "6:CORTE", "7:PISADA"]
	var anim_widths = [25.0, 26.0, 33.0, 26.0, 31.0, 29.0, 32.0]
	var bx: float = 4.0
	for i in range(7):
		var is_active: bool = false
		var btn_w: float = anim_widths[i]
		if i == 0:
			is_active = cervo.current_state == CervoVisual.AnimState.IDLE
		elif i == 1:
			is_active = cervo.current_state == CervoVisual.AnimState.WALK
		elif i == 2:
			is_active = cervo.current_state == CervoVisual.AnimState.GALLOP
		elif i == 3:
			is_active = cervo.current_state == CervoVisual.AnimState.TURN
		elif i == 4:
			is_active = cervo.current_state in [
				CervoVisual.AnimState.CHARGE_PREP,
				CervoVisual.AnimState.CHARGE_EXEC,
				CervoVisual.AnimState.CHARGE_RECOVER
			]
		elif i == 5:
			is_active = cervo.current_state in [
				CervoVisual.AnimState.ANTLER_PREP,
				CervoVisual.AnimState.ANTLER_EXEC,
				CervoVisual.AnimState.ANTLER_RECOVER
			]
		elif i == 6:
			is_active = cervo.current_state in [
				CervoVisual.AnimState.STOMP_PREP,
				CervoVisual.AnimState.STOMP_EXEC,
				CervoVisual.AnimState.STOMP_RECOVER
			]

		var col: Color = Color("00f0ff") if is_active else Color("5a7585")
		if is_active:
			draw_rect(Rect2(bx - 2, 16, btn_w, 12), Color(0.0, 0.4, 0.45, 0.35), true)
			draw_rect(Rect2(bx - 2, 16, btn_w, 12), Color("00f0ff"), false, 1)
		draw_string(font, Vector2(bx, 25), anim_names[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 7, col)
		bx += btn_w + 2.0

	# Status detalhado na direita do topo
	var facing_txt: String = "DIR" if cervo.facing > 0 else "ESQ"
	var frame_txt: String = "Q:%d/%d" % [cervo.current_frame + 1, cervo.get_total_frames()]
	var scale_txt: String = "%.2fx" % cervo.display_scale
	var stage_txt: String = ""
	if cervo.current_state == CervoVisual.AnimState.CHARGE_PREP:
		stage_txt = "[C-PREP] "
	elif cervo.current_state == CervoVisual.AnimState.CHARGE_EXEC:
		stage_txt = "[C-EXEC] "
	elif cervo.current_state == CervoVisual.AnimState.CHARGE_RECOVER:
		stage_txt = "[C-REC] "
	elif cervo.current_state == CervoVisual.AnimState.ANTLER_PREP:
		stage_txt = "[A-PREP] "
	elif cervo.current_state == CervoVisual.AnimState.ANTLER_EXEC:
		stage_txt = "[A-EXEC] "
	elif cervo.current_state == CervoVisual.AnimState.ANTLER_RECOVER:
		stage_txt = "[A-REC] "
	elif cervo.current_state == CervoVisual.AnimState.STOMP_PREP:
		stage_txt = "[S-PREP] "
	elif cervo.current_state == CervoVisual.AnimState.STOMP_EXEC:
		stage_txt = "[S-EXEC] "
	elif cervo.current_state == CervoVisual.AnimState.STOMP_RECOVER:
		stage_txt = "[S-REC] "

	var pause_txt: String = " [P]" if is_paused else ""

	var status_line: String = "%s%s | %s | %s%s" % [stage_txt, frame_txt, facing_txt, scale_txt, pause_txt]
	draw_string(font, Vector2(220, 25), status_line, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("e5f2f5"))

	# Rodapé de controles
	draw_rect(Rect2(0, 168, 320, 12), Color(0.04, 0.06, 0.09, 0.85), true)
	draw_line(Vector2(0, 168), Vector2(320, 168), Color(0.18, 0.28, 0.35, 0.5), 1)
	var help_txt: String = "[1-7]Anim  [F/Espaço]Virar  [S]Escala  [M]Movimento  [P]Pausa  [G]Guias  [A]Aren  [R]Reset  [Esc]Sair"
	draw_string(font, Vector2(6, 176), help_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color("7b9fae"))
