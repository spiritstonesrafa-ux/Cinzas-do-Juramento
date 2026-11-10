class_name CervoBossConclusion
extends Node2D
## Conclusão cinematográfica e concessão de recompensa do Cervo Espectral (M6-CERVO-BOSS).
## Concede permanentemente o Salto Espectral (salto duplo) e conclui a Fase 3 de forma idempotente.

signal finished

const DURATION: float = 3.6
const TITLE: String = "CERVO ESPECTRAL DERROTADO"
const PHASE_TEXT: String = "A Floresta dos Ossos reconhece sua força."
const NARRATIVE: String = "A névoa ancestral se dissipa diante da chama do Juramento."
const REWARD_TITLE: String = "NOVA HABILIDADE — SALTO ESPECTRAL"
const REWARD_HINT: String = "Pressione Espaço novamente no ar para executar um segundo salto."

var played: bool = false
var running: bool = false
var settled: bool = false
var elapsed: float = 0.0
var sequence_count: int = 0
var completion_count: int = 0

var _flash_timer: float = 0.0
var _defeat_shake: float = 0.0
var _spectral_motes: Array[Dictionary] = []
var _energy_wisps: Array[Dictionary] = []

@onready var boss: CharacterBody2D = get_parent() as CharacterBody2D

func _ready() -> void:
	if boss != null and boss.has_signal("defeated"):
		boss.defeated.connect(_begin)

func _begin() -> void:
	if played or (boss != null and boss.health != 0):
		return
	if not is_instance_valid(boss.target) or (boss.target.survival != null and boss.target.survival.is_dead):
		return
	if boss.target.survival != null and not boss.target.survival.died.is_connected(_on_player_died):
		boss.target.survival.died.connect(_on_player_died)
	
	played = true
	running = true
	settled = false
	elapsed = 0.0
	sequence_count += 1
	_flash_timer = 0.35
	_defeat_shake = 0.30
	
	# Inicia pose solene de repouso/derrota (antlers baixas tocando o solo)
	if boss != null and is_instance_valid(boss.visual):
		boss.visual.visible = true
		boss.visual.play(CervoVisual.AnimState.ECHO_RECOVER, 8.0)
		boss.visual.modulate = Color(2.4, 2.5, 2.8, 1.0)
		boss.visual.modulate_color = Color.WHITE
	
	_spawn_spectral_motes()
	queue_redraw()

func _on_player_died() -> void:
	if running:
		cancel()

func cancel() -> void:
	played = false
	running = false
	settled = false
	elapsed = 0.0
	_flash_timer = 0.0
	_defeat_shake = 0.0
	_spectral_motes.clear()
	_energy_wisps.clear()
	if boss != null and is_instance_valid(boss.visual):
		boss.visual.visible = true
		boss.visual.position = Vector2.ZERO
		boss.visual.modulate = Color.WHITE
		boss.visual.modulate_color = Color.WHITE
		boss.visual.play_by_name("idle")
	queue_redraw()

func settle(skip_text: bool = false) -> void:
	if not played:
		return
	if not settled:
		settled = true
		running = false
		elapsed = maxf(elapsed, DURATION)
		completion_count += 1
		
		# Concessão oficial da recompensa no sistema de save seguro
		var abbey_script: Script = load("res://scripts/abbey/abbey_progress.gd")
		if abbey_script != null and abbey_script.has_method("grant_cervo_reward"):
			abbey_script.grant_cervo_reward()
		
		# Concessão em sessão para o herói atual
		if is_instance_valid(boss.target):
			boss.target.spectral_jump_unlocked = true
		
		finished.emit()
	
	if boss != null and is_instance_valid(boss.visual):
		boss.visual.visible = false
		boss.visual.position = Vector2.ZERO
	
	if skip_text:
		elapsed = 10.0
	_spectral_motes.clear()
	_energy_wisps.clear()
	queue_redraw()

func _spawn_spectral_motes() -> void:
	_spectral_motes.clear()
	for i in range(18):
		var angle: float = (-0.88 + i * 0.10) * PI
		var speed: float = randf_range(35.0, 90.0)
		_spectral_motes.append({
			"pos": Vector2(randf_range(-24.0, 24.0), randf_range(-55.0, -20.0)),
			"vel": Vector2(cos(angle) * speed, sin(angle) * speed - 20.0),
			"alpha": 1.0,
			"radius": randf_range(1.5, 3.5)
		})

func _physics_process(delta: float) -> void:
	if not played:
		return
	
	elapsed = minf(12.0, elapsed + delta)
	_flash_timer = maxf(0.0, _flash_timer - delta)
	_defeat_shake = maxf(0.0, _defeat_shake - delta)
	
	# Controle dinâmico do visual do chefe durante a conclusão cinematográfica
	if boss != null and is_instance_valid(boss.visual):
		if elapsed < 0.85:
			# Fase 1: Repouso / Colapso solene sobre a vegetação
			if boss.visual.current_state != CervoVisual.AnimState.ECHO_RECOVER:
				boss.visual.play(CervoVisual.AnimState.ECHO_RECOVER, 8.0)
			var flash_ratio: float = clampf(_flash_timer / 0.35, 0.0, 1.0)
			boss.visual.modulate = Color.WHITE.lerp(Color(2.2, 2.4, 2.8, 1.0), flash_ratio)
			boss.visual.modulate_color = Color.WHITE
			# Shudder suave de impacto
			if _defeat_shake > 0.0:
				boss.visual.position.x = sin(elapsed * 45.0) * 1.5 * (_defeat_shake / 0.30)
			else:
				boss.visual.position.x = 0.0
		elif elapsed < 2.2:
			# Fase 2: Dissolução em névoa espectral
			boss.visual.position.x = 0.0
			if boss.visual.current_state != CervoVisual.AnimState.ECHO_DISSOLVE:
				boss.visual.play(CervoVisual.AnimState.ECHO_DISSOLVE, 6.0)
			var dissolve_alpha: float = clampf((2.15 - elapsed) / 1.30, 0.0, 1.0)
			boss.visual.modulate = Color(1.0, 1.0, 1.0, dissolve_alpha)
			boss.visual.modulate_color = Color(0.85, 1.2, 1.4, dissolve_alpha)
			boss.visual.visible = (dissolve_alpha > 0.01)
		else:
			# Fase 3 & 4: Totalmente dissolvido e pacificado
			boss.visual.position.x = 0.0
			boss.visual.visible = false
			boss.visual.modulate_color = Color(1.0, 1.0, 1.0, 0.0)
	
	if running and elapsed >= DURATION:
		settle()
	
	# Atualiza partículas espectrais em dispersão ascendente
	for p: Dictionary in _spectral_motes:
		p.pos += p.vel * delta
		p.vel.y += 35.0 * delta # flutuação ascendente
		p.alpha = maxf(0.0, p.alpha - delta * 0.55)
	
	# Cria feixes de luz espectral convergindo para Aren
	if running and elapsed >= 0.70 and elapsed <= 2.60 and is_instance_valid(boss.target):
		if randf() < 0.55:
			var start_local: Vector2 = Vector2(randf_range(-25.0, 25.0), randf_range(-45.0, -15.0))
			var target_local: Vector2 = to_local(boss.target.global_position + Vector2(0, -16))
			var dir: Vector2 = (target_local - start_local).normalized()
			_energy_wisps.append({
				"pos": start_local,
				"vel": dir * randf_range(80.0, 150.0),
				"target": target_local,
				"life": 1.0,
				"max_life": 1.0
			})
	
	# Atualiza feixes
	for i: int in range(_energy_wisps.size() - 1, -1, -1):
		var w: Dictionary = _energy_wisps[i]
		w.life -= delta * 1.3
		if is_instance_valid(boss.target):
			w.target = to_local(boss.target.global_position + Vector2(0, -16))
			var dir_to_target: Vector2 = (w.target - w.pos).normalized()
			w.vel = w.vel.lerp(dir_to_target * 140.0, delta * 4.5)
		w.pos += w.vel * delta
		if w.life <= 0.0 or w.pos.distance_to(w.target) < 6.0:
			_energy_wisps.remove_at(i)
	
	queue_redraw()

func _draw() -> void:
	if not played:
		return
	
	# Partículas turquesas ascendentes
	for p: Dictionary in _spectral_motes:
		if p.alpha > 0.01:
			draw_circle(p.pos, p.radius, Color(0.25, 0.95, 1.0, p.alpha * 0.85))
			draw_circle(p.pos, p.radius * 0.5, Color(0.9, 1.0, 1.0, p.alpha))
	
	# Feixes de absorção convergindo para Aren
	for w: Dictionary in _energy_wisps:
		var w_alpha: float = clampf(w.life / w.max_life, 0.0, 1.0)
		draw_circle(w.pos, 2.2, Color(0.20, 0.90, 1.0, w_alpha * 0.85))
		draw_circle(w.pos, 1.1, Color(1.0, 1.0, 1.2, w_alpha))
	
	# Aura do Salto Espectral em expansão ao redor de Aren (feedback visual da bênção)
	if running and elapsed >= 1.0 and elapsed <= 3.3 and is_instance_valid(boss.target):
		var hero_local: Vector2 = to_local(boss.target.global_position + Vector2(0, -16))
		var shimmer_pulse: float = sin((elapsed - 1.0) / 2.3 * PI)
		draw_circle(hero_local, 16.0 * shimmer_pulse, Color(0.20, 0.90, 1.0, 0.18 * shimmer_pulse))
		draw_arc(hero_local, 12.0 + 4.0 * shimmer_pulse, 0, TAU, 20, Color(0.35, 1.0, 1.0, 0.45 * shimmer_pulse), 1.2)
		if elapsed >= 1.8:
			var second_pulse: float = sin((elapsed - 1.8) / 1.5 * PI)
			draw_arc(hero_local, 18.0 * second_pulse, 0, TAU, 16, Color(0.70, 1.0, 1.0, 0.35 * second_pulse), 1.0)
	
	# Bruma suave no solo onde o Cervo repousou
	if elapsed >= 1.2 and elapsed <= 5.0:
		var mist_alpha: float = sin(clampf((elapsed - 1.2) / 3.8, 0.0, 1.0) * PI) * 0.30
		draw_circle(Vector2(0, -4), 28.0, Color(0.15, 0.85, 0.95, mist_alpha * 0.25))
		draw_circle(Vector2(0, -3), 16.0, Color(0.40, 0.95, 1.0, mist_alpha * 0.40))
