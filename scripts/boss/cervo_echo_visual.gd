class_name CervoEchoVisual
extends CervoVisual
## Componente visual oficial para as manifestações espectrais independentes (Ecos da Floresta - ART-BOSS-06).
## Renderiza de forma autônoma manifestação (ECHO_MANIFEST), demonstração ativa espectral e dissipação (ECHO_DISSOLVE).
## Totalmente visual, sem dano, colisão, área de ataque ou IA de combate.

enum EchoState {
	INACTIVE,
	MANIFESTING,
	ACTIVE,
	DISSOLVING
}

signal echo_manifested()
signal echo_dissolved()
signal echo_state_changed(new_state: String)

var echo_state: EchoState = EchoState.INACTIVE
var echo_duration: float = 2.0
var echo_timer: float = 0.0
var move_speed: float = 0.0
var base_offset: Vector2 = Vector2.ZERO

# Cor espectral ciano/turquesa suave para diferenciar visualmente o eco do Cervo verdadeiro
const DEFAULT_SPECTRAL_COLOR: Color = Color(0.25, 0.95, 1.0, 0.82)

func _ready() -> void:
	super._ready()
	modulate_color = DEFAULT_SPECTRAL_COLOR
	visible = false

func spawn_echo(target_position: Vector2, initial_facing: int, duration: float = 2.0, speed: float = 0.0) -> void:
	position = target_position
	facing = 1 if initial_facing >= 0 else -1
	echo_duration = maxf(0.1, duration)
	echo_timer = 0.0
	move_speed = speed
	echo_state = EchoState.MANIFESTING
	visible = true
	modulate_color = DEFAULT_SPECTRAL_COLOR
	is_playing = true
	echo_state_changed.emit("manifesting")
	play(AnimState.ECHO_MANIFEST, 8.0)

func spawn_active(target_position: Vector2, initial_facing: int, duration: float = 2.0, speed: float = 0.0) -> void:
	position = target_position
	facing = 1 if initial_facing >= 0 else -1
	echo_duration = maxf(0.1, duration)
	echo_timer = 0.0
	move_speed = speed
	echo_state = EchoState.ACTIVE
	visible = true
	modulate_color = DEFAULT_SPECTRAL_COLOR
	is_playing = true
	echo_state_changed.emit("active")
	# No estado ativo, utiliza o galope espectral modulado para demonstração de travessia visual
	play(AnimState.GALLOP, 12.0)

func _process(delta: float) -> void:
	if echo_state == EchoState.INACTIVE or not visible:
		return

	super._process(delta)

	if echo_state == EchoState.ACTIVE:
		echo_timer += delta
		if move_speed != 0.0 and is_playing:
			position.x += float(facing) * move_speed * delta

		if echo_timer >= echo_duration:
			start_dissolve()

func _advance_frame() -> void:
	var config: Dictionary = ANIM_CONFIG[current_state]
	var total: int = int(config["total_frames"])
	var next_frame: int = current_frame + 1

	if next_frame >= total:
		if current_state == AnimState.ECHO_MANIFEST and echo_state == EchoState.MANIFESTING:
			# Conclui manifestação e entra no estado ativo
			current_frame = total - 1
			echo_state = EchoState.ACTIVE
			echo_timer = 0.0
			echo_manifested.emit()
			echo_state_changed.emit("active")
			play(AnimState.GALLOP, 12.0)
			return
		elif current_state == AnimState.ECHO_DISSOLVE and echo_state == EchoState.DISSOLVING:
			# Conclui dissipação e desativa
			current_frame = total - 1
			echo_state = EchoState.INACTIVE
			visible = false
			echo_dissolved.emit()
			echo_state_changed.emit("inactive")
			return

	super._advance_frame()

func start_dissolve() -> void:
	if echo_state == EchoState.DISSOLVING or echo_state == EchoState.INACTIVE:
		return
	echo_state = EchoState.DISSOLVING
	echo_state_changed.emit("dissolving")
	play(AnimState.ECHO_DISSOLVE, 8.0)

func dismiss() -> void:
	echo_state = EchoState.INACTIVE
	visible = false
	is_playing = false
	echo_state_changed.emit("inactive")

func is_manifesting() -> bool:
	return echo_state == EchoState.MANIFESTING

func is_active_echo() -> bool:
	return echo_state == EchoState.ACTIVE

func is_dissolving() -> bool:
	return echo_state == EchoState.DISSOLVING

func is_inactive() -> bool:
	return echo_state == EchoState.INACTIVE
