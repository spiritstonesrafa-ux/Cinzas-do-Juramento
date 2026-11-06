extends Node2D
## Gothic cinematic conclusion for the Abbot of Chains (M5-G homologated boss).
## Pure presentation: preserves physical combat rules, floor alignment and dash persistence.
signal finished

const DURATION: float = 3.2
const TITLE: String = "VÍNCULO QUEBRADO"
const PHASE_TEXT: String = "A Abadia Silenciosa — concluída"
const NARRATIVE: String = "As correntes sucumbem e dissipam-se em cinzas."
const REWARD_TITLE: String = "NOVA HABILIDADE — PASSO DAS SOMBRAS"
const REWARD_HINT: String = "Pressione Shift para deslizar."
const CONTINUATION: String = "A jornada de Aren continua."

var played: bool = false
var running: bool = false
var settled: bool = false
var elapsed: float = 0.0
var sequence_count: int = 0
var completion_count: int = 0

# Visual particles for broken chains and absorbed energy
var _chain_particles: Array[Dictionary] = []
var _energy_wisps: Array[Dictionary] = []

@onready var boss: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	if boss and boss.has_signal("defeated"):
		boss.defeated.connect(_begin)

func _begin() -> void:
	if played or (boss and boss.health != 0):
		return
	if not is_instance_valid(boss.target) or boss.target.survival.is_dead:
		return
	if not boss.target.survival.died.is_connected(_on_player_died):
		boss.target.survival.died.connect(_on_player_died)
	played = true
	running = true
	settled = false
	elapsed = 0.0
	sequence_count += 1
	_spawn_chain_particles()
	queue_redraw()

func _on_player_died() -> void:
	if running:
		cancel()

func cancel() -> void:
	played = false
	running = false
	settled = false
	elapsed = 0.0
	_chain_particles.clear()
	_energy_wisps.clear()
	queue_redraw()

func settle(skip_text: bool = false) -> void:
	if not played:
		return
	if not settled:
		settled = true
		running = false
		elapsed = maxf(elapsed, DURATION)
		completion_count += 1
		finished.emit()
	if skip_text:
		elapsed = 10.0
	_chain_particles.clear()
	_energy_wisps.clear()
	queue_redraw()

func _spawn_chain_particles() -> void:
	_chain_particles.clear()
	# 8 discrete broken chain links bursting outward and falling
	for i in range(8):
		var angle: float = (-0.8 + i * 0.22) * PI
		var speed: float = randf_range(35.0, 75.0)
		_chain_particles.append({
			"pos": Vector2(randf_range(-10.0, 10.0), randf_range(-45.0, -15.0)),
			"vel": Vector2(cos(angle) * speed, sin(angle) * speed - 20.0),
			"rot": randf_range(0.0, TAU),
			"spin": randf_range(-8.0, 8.0),
			"alpha": 1.0
		})

func _physics_process(delta: float) -> void:
	if not played:
		return
	elapsed = minf(12.0, elapsed + delta)
	if running and elapsed >= DURATION:
		settle()

	# Update broken chain particles
	for p: Dictionary in _chain_particles:
		p.pos += p.vel * delta
		p.vel.y += 180.0 * delta # gravity
		p.rot += p.spin * delta
		p.alpha = maxf(0.0, p.alpha - delta * 0.7)

	# Spawn shadow energy wisps moving towards Aren
	if running and elapsed >= 0.6 and elapsed <= 2.4 and is_instance_valid(boss.target):
		if randf() < 0.45:
			var start_local: Vector2 = Vector2(randf_range(-12.0, 12.0), randf_range(-40.0, -20.0))
			var target_local: Vector2 = to_local(boss.target.global_position + Vector2(0, -18))
			var dir: Vector2 = (target_local - start_local).normalized()
			_energy_wisps.append({
				"pos": start_local,
				"vel": dir * randf_range(70.0, 130.0),
				"target": target_local,
				"life": 1.0,
				"max_life": 1.0
			})

	# Update wisps
	for i: int in range(_energy_wisps.size() - 1, -1, -1):
		var w: Dictionary = _energy_wisps[i]
		w.life -= delta * 1.4
		if is_instance_valid(boss.target):
			w.target = to_local(boss.target.global_position + Vector2(0, -18))
			var dir_to_target: Vector2 = (w.target - w.pos).normalized()
			w.vel = w.vel.lerp(dir_to_target * 120.0, delta * 4.0)
		w.pos += w.vel * delta
		if w.life <= 0.0 or w.pos.distance_to(w.target) < 6.0:
			_energy_wisps.remove_at(i)

	queue_redraw()

func _draw() -> void:
	if not played:
		return

	# Draw broken chain link fragments
	for p: Dictionary in _chain_particles:
		if p.alpha > 0.01:
			draw_set_transform(p.pos, p.rot)
			# Metallic chain fragment with darker inner link
			draw_rect(Rect2(-2, -1, 4, 2), Color(0.72, 0.70, 0.78, p.alpha))
			draw_rect(Rect2(-1, 0, 2, 1), Color(0.35, 0.28, 0.42, p.alpha))
			draw_set_transform(Vector2.ZERO, 0)

	# Draw shadow energy wisps transferring to Aren
	for w: Dictionary in _energy_wisps:
		var w_alpha: float = clampf(w.life / w.max_life, 0.0, 1.0)
		draw_circle(w.pos, 2.0, Color(0.75, 0.48, 0.91, w_alpha * 0.75))
		draw_circle(w.pos, 1.0, Color(1.2, 0.9, 1.3, w_alpha * 0.9))

	# Aren absorption shimmer (subtle violet aura when energy is assimilated)
	if running and elapsed >= 1.0 and elapsed <= 2.8 and is_instance_valid(boss.target):
		var hero_local: Vector2 = to_local(boss.target.global_position + Vector2(0, -16))
		var shimmer_pulse: float = sin((elapsed - 1.0) / 1.8 * PI)
		draw_circle(hero_local, 14.0 * shimmer_pulse, Color(0.62, 0.35, 0.85, 0.15 * shimmer_pulse))
		draw_arc(hero_local, 10.0 + 3.0 * shimmer_pulse, 0, TAU, 16, Color(0.75, 0.48, 0.91, 0.35 * shimmer_pulse), 1.0)
