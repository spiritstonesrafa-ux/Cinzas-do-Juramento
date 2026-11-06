class_name KnightSurvival
extends Node
## Local health and death timers, independent of movement and sword timings.

signal health_changed(current: int, maximum: int)
signal died
signal respawn_requested

@export_range(1, 99, 1) var max_health: int = 5:
	set(value):
		max_health = maxi(1, value)
		if is_node_ready():
			_health = clampi(_health, 0, max_health)
			health_changed.emit(_health, max_health)
@export_range(0.01, 3.0, 0.01) var invulnerability_duration: float = 0.8
@export_range(0.01, 3.0, 0.01) var death_delay: float = 0.6

var current_health: int:
	get:
		return _health
var is_dead: bool = false
var invulnerability_remaining: float = 0.0
var _health: int = 5
var _death_remaining: float = 0.0
var _respawn_sent: bool = false

func _ready() -> void:
	_health = maxi(1, max_health)
	health_changed.emit(_health, max_health)

func receive_damage(amount: int = 1) -> bool:
	if amount <= 0 or is_dead or invulnerability_remaining > 0.0:
		return false
	_health = clampi(_health - amount, 0, maxi(1, max_health))
	if _health == 0:
		# Set the guard before emitting either signal, including reentrant listeners.
		is_dead = true
		invulnerability_remaining = 0.0
		_death_remaining = death_delay
		_respawn_sent = false
	else:
		invulnerability_remaining = invulnerability_duration
	health_changed.emit(_health, max_health)
	if is_dead:
		died.emit()
	return true

func tick(delta: float) -> void:
	if is_dead:
		_death_remaining = maxf(0.0, _death_remaining - delta)
		if _death_remaining == 0.0 and not _respawn_sent:
			_respawn_sent = true
			respawn_requested.emit()
	else:
		invulnerability_remaining = maxf(0.0, invulnerability_remaining - delta)

func restore() -> void:
	_health = maxi(1, max_health)
	is_dead = false
	invulnerability_remaining = 0.0
	_death_remaining = 0.0
	_respawn_sent = false
	health_changed.emit(_health, max_health)

func grant_health_upgrade(bonus: int = 1) -> void:
	if bonus <= 0:
		return
	max_health = maxi(1, max_health + bonus)
	_health = clampi(_health + bonus, 1, max_health)
	health_changed.emit(_health, max_health)
