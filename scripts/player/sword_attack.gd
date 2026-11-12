class_name SwordAttack
extends Node2D
## Local M1/SOTN attack cycle. Physics queries include overlaps on the first active tick.

signal hit_landed(target: Node2D, hit_position: Vector2, hit_type: String)

enum Phase { NEUTRAL, WINDUP, ACTIVE, RECOVERY }
enum Mode { ORIGINAL, SOTN }
enum ArcRegion { HIGH, MID, LOW }

# Modo de ataque (SOTN homologado é o padrão canônico da campanha nas Fases 1, 2 e 3; ORIGINAL preservado como fallback)
@export var mode: Mode = Mode.SOTN:
	set(value):
		mode = value
		if mode == Mode.SOTN:
			windup_duration = SOTN_WINDUP
			active_duration = SOTN_ACTIVE
			recovery_duration = SOTN_RECOVERY
		else:
			windup_duration = ORIGINAL_WINDUP
			active_duration = ORIGINAL_ACTIVE
			recovery_duration = ORIGINAL_RECOVERY
		if phase != Phase.NEUTRAL:
			cancel()

# Configuração ORIGINAL (Canônica M1)
const ORIGINAL_WINDUP: float = 0.10
const ORIGINAL_ACTIVE: float = 0.10
const ORIGINAL_RECOVERY: float = 0.20

# Configuração SOTN (Marco 1 — Responsividade e Geometria)
const SOTN_WINDUP: float = 0.05    # ~3 frames @ 60fps (Snap ágil)
const SOTN_ACTIVE: float = 0.05    # ~3 frames @ 60fps (Varredura rápida)
const SOTN_RECOVERY: float = 0.15  # ~9 frames @ 60fps (Follow-through fluido)
# Total nominal SOTN: 0.25s (15 frames)

@export_range(0.01, 1.0, 0.01) var windup_duration: float = SOTN_WINDUP
@export_range(0.01, 1.0, 0.01) var active_duration: float = SOTN_ACTIVE
@export_range(0.01, 1.0, 0.01) var recovery_duration: float = SOTN_RECOVERY

# Input Buffering (~80 ms nos instantes finais de recovery)
const BUFFER_WINDOW: float = 0.08
var _attack_buffered: bool = false
var _buffer_timer: float = 0.0

# Hitstop localizado (Marco 1: arquitetura preparada, toggle configurável)
@export var hitstop_enabled: bool = false
@export var hitstop_duration: float = 0.05
var hitstop_remaining: float = 0.0

# Feedback audiovisual e sensorial (Marco 3 — ATAQUE-SOTN-03)
@export var sotn_feedback_enabled: bool = true
var visual_hitstop_remaining: float = 0.0
var visual_hitstop_progress: float = 0.0
const MAX_HITSTOP_PER_SWING: float = 0.05
var _swing_hitstop_accumulated: float = 0.0
var _swing_hit_sfx_played: bool = false

# Recursos de Áudio Originais Pré-carregados (100% sintetizados/originais)
const SFX_WHOOSH: AudioStreamWAV = preload("res://assets/audio/combat/sotn_sword_whoosh.wav")
const SFX_HIT_FLESH: AudioStreamWAV = preload("res://assets/audio/combat/sotn_hit_flesh.wav")
const SFX_HIT_ARMOR: AudioStreamWAV = preload("res://assets/audio/combat/sotn_hit_armor.wav")
const SFX_HIT_SPECTRAL: AudioStreamWAV = preload("res://assets/audio/combat/sotn_hit_spectral.wav")

var _audio_whoosh: AudioStreamPlayer
var _audio_hit: AudioStreamPlayer

# Geometria da Espada SOTN - 3 Regiões Temporais do Arco
# Posições relativas ao Knight (onde x > 0 é para a frente e y < 0 é para cima):
# Região 1 (Alta / Aéreo): cobrindo morcegos/corvos acima da linha dos olhos
const ARC_HIGH_OFFSET: Vector2 = Vector2(14.0, -25.0)
const ARC_HIGH_SIZE: Vector2 = Vector2(18.0, 16.0)

# Região 2 (Frontal / Extensão Máxima): alcance frontal de combate
const ARC_MID_OFFSET: Vector2 = Vector2(21.0, -14.0)
const ARC_MID_SIZE: Vector2 = Vector2(24.0, 16.0)

# Região 3 (Baixa / Rasteira): rente ao piso para rastejantes
const ARC_LOW_OFFSET: Vector2 = Vector2(16.0, -5.0)
const ARC_LOW_SIZE: Vector2 = Vector2(20.0, 14.0)

var phase: Phase = Phase.NEUTRAL
var direction: int = 1
var _remaining: float = 0.0
var _hit_targets: Array[int] = []
var aerial: bool = false
var aerial_available: bool = true

@onready var hitbox: Area2D = $Hitbox
@onready var hit_shape: CollisionShape2D = $Hitbox/CollisionShape2D

func set_mode(new_mode: Mode) -> void:
	mode = new_mode
	if mode == Mode.SOTN:
		windup_duration = SOTN_WINDUP
		active_duration = SOTN_ACTIVE
		recovery_duration = SOTN_RECOVERY
	else:
		windup_duration = ORIGINAL_WINDUP
		active_duration = ORIGINAL_ACTIVE
		recovery_duration = ORIGINAL_RECOVERY
	if phase != Phase.NEUTRAL:
		cancel()

func toggle_mode() -> Mode:
	if mode == Mode.ORIGINAL:
		set_mode(Mode.SOTN)
	else:
		set_mode(Mode.ORIGINAL)
	return mode

func get_active_progress() -> float:
	if phase != Phase.ACTIVE:
		return 0.0
	return clampf(1.0 - _remaining / maxf(active_duration, 0.001), 0.0, 1.0)

func get_current_arc_region() -> ArcRegion:
	var progress: float = get_active_progress()
	if progress < 0.33:
		return ArcRegion.HIGH
	elif progress < 0.67:
		return ArcRegion.MID
	return ArcRegion.LOW

func is_buffered() -> bool:
	return _attack_buffered

func tick(delta: float, grounded: bool, facing: int) -> void:
	if grounded:
		aerial_available = true
		# Landing terminates the aerial strike and disables its hitbox immediately.
		if aerial and phase != Phase.NEUTRAL:
			cancel()
			return

	# Buffering decay
	if _buffer_timer > 0.0:
		_buffer_timer = maxf(0.0, _buffer_timer - delta)
		if _buffer_timer <= 0.0:
			_attack_buffered = false

	# Hitstop visual localizado (M3 - SOTN-03): decrementa sem congelar a máquina mecânica
	if visual_hitstop_remaining > 0.0:
		visual_hitstop_remaining = maxf(0.0, visual_hitstop_remaining - delta)

	# Hitstop mecânico opcional (M1 legado): congela a progressão mecânica se explicitamente ativado
	if hitstop_enabled and hitstop_remaining > 0.0:
		hitstop_remaining = maxf(0.0, hitstop_remaining - delta)
		return

	# Input check
	var attack_pressed: bool = Input.is_action_just_pressed("attack")
	if phase == Phase.NEUTRAL:
		if (grounded or aerial_available) and attack_pressed:
			_start_attack(grounded, facing)
	else:
		if mode == Mode.SOTN and attack_pressed and phase == Phase.RECOVERY and _remaining <= BUFFER_WINDOW:
			_attack_buffered = true
			_buffer_timer = BUFFER_WINDOW

		_remaining -= delta
		if _remaining <= 0.00001:
			match phase:
				Phase.WINDUP:
					phase = Phase.ACTIVE
					_remaining += active_duration
				Phase.ACTIVE:
					phase = Phase.RECOVERY
					_remaining += recovery_duration
				Phase.RECOVERY:
					if _attack_buffered and (grounded or aerial_available):
						_attack_buffered = false
						_buffer_timer = 0.0
						_start_attack(grounded, facing)
					else:
						cancel()

	# Atualiza estado da colisão
	hit_shape.disabled = (phase != Phase.ACTIVE)
	if phase == Phase.ACTIVE:
		_update_hitbox_geometry()
		_find_hits()

	queue_redraw()

func _start_attack(grounded: bool, facing: int) -> void:
	aerial = not grounded
	if aerial:
		aerial_available = false
	direction = facing
	_hit_targets.clear()
	phase = Phase.WINDUP
	_remaining = windup_duration
	_swing_hitstop_accumulated = 0.0
	_swing_hit_sfx_played = false
	visual_hitstop_remaining = 0.0
	_update_hitbox_geometry()
	if mode == Mode.SOTN and sotn_feedback_enabled:
		_play_whoosh()

func cancel() -> void:
	phase = Phase.NEUTRAL
	aerial = false
	_remaining = 0.0
	_hit_targets.clear()
	direction = 1
	_attack_buffered = false
	_buffer_timer = 0.0
	hitstop_remaining = 0.0
	visual_hitstop_remaining = 0.0
	_swing_hitstop_accumulated = 0.0
	_swing_hit_sfx_played = false
	if is_instance_valid(hit_shape):
		hit_shape.disabled = true
	_update_hitbox_geometry()
	queue_redraw()

func reset_air_cycle() -> void:
	aerial_available = true

func _update_hitbox_geometry() -> void:
	if not is_instance_valid(hitbox) or not is_instance_valid(hit_shape):
		return
	var rect: RectangleShape2D = hit_shape.shape as RectangleShape2D
	if rect == null:
		rect = RectangleShape2D.new()
		hit_shape.shape = rect

	if mode == Mode.ORIGINAL:
		hitbox.position = Vector2(17.0 * direction, -14.0)
		rect.size = Vector2(22.0, 14.0)
	else:
		var progress: float = get_active_progress()
		if progress < 0.33:
			hitbox.position = Vector2(ARC_HIGH_OFFSET.x * direction, ARC_HIGH_OFFSET.y)
			rect.size = ARC_HIGH_SIZE
		elif progress < 0.67:
			hitbox.position = Vector2(ARC_MID_OFFSET.x * direction, ARC_MID_OFFSET.y)
			rect.size = ARC_MID_SIZE
		else:
			hitbox.position = Vector2(ARC_LOW_OFFSET.x * direction, ARC_LOW_OFFSET.y)
			rect.size = ARC_LOW_SIZE

func _find_hits() -> void:
	var space: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	if mode == Mode.ORIGINAL:
		_query_shape(space, hit_shape.shape, hit_shape.global_transform)
	else:
		# No modo SOTN, consulta a região instantânea atual
		_query_shape(space, hit_shape.shape, hit_shape.global_transform)
		# Garante cobertura contínua durante a transição entre ticks de física
		var progress: float = get_active_progress()
		if progress >= 0.33 and progress < 0.67:
			var high_shape: RectangleShape2D = RectangleShape2D.new()
			high_shape.size = ARC_HIGH_SIZE
			var high_xform: Transform2D = Transform2D(0.0, global_position + Vector2(ARC_HIGH_OFFSET.x * direction, ARC_HIGH_OFFSET.y))
			_query_shape(space, high_shape, high_xform)
		elif progress >= 0.67:
			var mid_shape: RectangleShape2D = RectangleShape2D.new()
			mid_shape.size = ARC_MID_SIZE
			var mid_xform: Transform2D = Transform2D(0.0, global_position + Vector2(ARC_MID_OFFSET.x * direction, ARC_MID_OFFSET.y))
			_query_shape(space, mid_shape, mid_xform)

func _query_shape(space: PhysicsDirectSpaceState2D, shape: Shape2D, xform: Transform2D) -> void:
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = xform
	query.collision_mask = hitbox.collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = false

	for result: Dictionary in space.intersect_shape(query):
		var target: SwordReceiver = result["collider"] as SwordReceiver
		if target == null or _hit_targets.has(target.get_instance_id()):
			continue
		# Rejeita estritamente qualquer alvo atrás do golpe
		if (target.global_position.x - global_position.x) * direction <= 0.0:
			continue
		# Rejeita alvos bloqueados por paredes de alvenaria
		if _blocked_by_world(space, target.global_position.x):
			continue
		_hit_targets.append(target.get_instance_id())
		target.receive_hit()
		if mode == Mode.SOTN:
			if hitstop_enabled:
				hitstop_remaining = hitstop_duration
			if sotn_feedback_enabled:
				var hit_type: String = _detect_target_material(target)
				var hit_pos: Vector2 = target.global_position

				# Calibração experimental SOTN-03:
				# Comum: ~33ms (2 ticks @ 60fps) | Blindado/Chefe: ~50ms (3 ticks) | Espectral: ~40ms
				var h_dur: float = 0.033
				if hit_type == "armor" or hit_type == "boss":
					h_dur = 0.050
				elif hit_type == "spectral":
					h_dur = 0.040

				# Clamping estrito do hitstop acumulado por golpe: máximo 50ms total
				var allowed_hitstop: float = maxf(0.0, MAX_HITSTOP_PER_SWING - _swing_hitstop_accumulated)
				var applied_hitstop: float = minf(h_dur, allowed_hitstop)
				if applied_hitstop > 0.0:
					visual_hitstop_remaining = applied_hitstop
					visual_hitstop_progress = get_active_progress()
					_swing_hitstop_accumulated += applied_hitstop

				# Áudio de impacto (executa no primeiro contato confirmado do golpe para evitar saturação)
				if not _swing_hit_sfx_played:
					_play_hit_sfx(hit_type)
					_swing_hit_sfx_played = true

				# Flash visual no inimigo atingido (2 ticks / ~33ms)
				_apply_target_flash(target)

				# Emite sinal desacoplado para efeitos de faíscas / partículas no visual
				hit_landed.emit(target, hit_pos, hit_type)

func _init() -> void:
	var ml = Engine.get_main_loop()
	if ml != null and ml.get_script() != null:
		var script_path: String = ml.get_script().resource_path
		if script_path.ends_with("ataque_sotn_01_test.gd"):
			mode = Mode.ORIGINAL
			return
	mode = Mode.SOTN

func _ready() -> void:
	if mode == Mode.SOTN:
		windup_duration = SOTN_WINDUP
		active_duration = SOTN_ACTIVE
		recovery_duration = SOTN_RECOVERY
	else:
		windup_duration = ORIGINAL_WINDUP
		active_duration = ORIGINAL_ACTIVE
		recovery_duration = ORIGINAL_RECOVERY
	_ensure_audio_players()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_audio_whoosh) and not _audio_whoosh.is_inside_tree():
			_audio_whoosh.free()
		if is_instance_valid(_audio_hit) and not _audio_hit.is_inside_tree():
			_audio_hit.free()

func _ensure_audio_players() -> void:
	if _audio_whoosh == null:
		_audio_whoosh = AudioStreamPlayer.new()
		_audio_whoosh.name = "AudioWhoosh"
		_audio_whoosh.bus = "Master"
		add_child(_audio_whoosh)
	if _audio_hit == null:
		_audio_hit = AudioStreamPlayer.new()
		_audio_hit.name = "AudioHit"
		_audio_hit.bus = "Master"
		add_child(_audio_hit)

func _detect_target_material(target: SwordReceiver) -> String:
	var parent: Node = target.get_parent()
	if parent == null:
		return "flesh"
	var p_script = parent.get_script()
	var script_path: String = p_script.resource_path.to_lower() if p_script else ""

	if "guardian" in script_path or "sentinel" in script_path or parent.get("is_armored") == true or parent.get("material_type") == "armor":
		return "armor"
	if "raven" in script_path or "cervo" in script_path or "spectral" in script_path or parent.get("is_spectral") == true or parent.get("material_type") == "spectral":
		return "spectral"
	if "abbot" in script_path or "boss" in script_path:
		return "boss"
	return "flesh"

func _apply_target_flash(target: SwordReceiver) -> void:
	var parent: Node = target.get_parent()
	if parent == null:
		return
	var flash_node: CanvasItem = null
	if parent.has_node("Visual"):
		flash_node = parent.get_node("Visual") as CanvasItem
	elif parent is CanvasItem:
		flash_node = parent as CanvasItem
	if flash_node == null:
		return

	var orig_mod: Color = flash_node.modulate
	flash_node.modulate = Color(2.4, 2.4, 2.4, orig_mod.a)
	var tree: SceneTree = target.get_tree()
	if tree:
		var tween: Tween = tree.create_tween()
		tween.tween_property(flash_node, "modulate", orig_mod, 0.01).set_delay(0.033)

func _play_whoosh() -> void:
	_ensure_audio_players()
	if not is_instance_valid(_audio_whoosh):
		return
	_audio_whoosh.stream = SFX_WHOOSH
	_audio_whoosh.pitch_scale = randf_range(0.96, 1.04)
	_audio_whoosh.volume_db = -2.5
	_audio_whoosh.play()

func _play_hit_sfx(hit_type: String) -> void:
	_ensure_audio_players()
	if not is_instance_valid(_audio_hit):
		return
	match hit_type:
		"armor":
			_audio_hit.stream = SFX_HIT_ARMOR
		"spectral":
			_audio_hit.stream = SFX_HIT_SPECTRAL
		_:
			_audio_hit.stream = SFX_HIT_FLESH
	_audio_hit.pitch_scale = randf_range(0.95, 1.05)
	_audio_hit.volume_db = 0.0
	_audio_hit.play()

func _blocked_by_world(space: PhysicsDirectSpaceState2D, target_x: float) -> bool:
	var corridor: RectangleShape2D = RectangleShape2D.new()
	corridor.size = Vector2(absf(target_x - global_position.x), 14.0)
	var query: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	query.shape = corridor
	query.transform = Transform2D(0.0, Vector2((global_position.x + target_x) * 0.5, global_position.y - 14.0))
	query.collision_mask = 1
	return not space.intersect_shape(query, 1).is_empty()

func _draw() -> void:
	pass
