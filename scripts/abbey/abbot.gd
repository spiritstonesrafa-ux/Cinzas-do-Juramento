extends CharacterBody2D
signal defeated
signal health_changed(current: int, maximum: int)
enum State { INTRO, PURSUIT, WARNING, ACTIVE, RECOVER, TRANSITION, DEFEATED }
enum Pattern { CHAIN, SWEEP, DASH }
@export var max_health: int=10
@export var move_speed: float=42.0
@export var dash_speed: float=180.0
@export var warning_time: float=0.85
@export var dash_warning_time: float=1.15
@export var recovery_time: float=1.05
@export var phase_two_recovery_time: float=0.90
var target: KnightController
var health: int=10
var phase: int=1
var state: State=State.INTRO
var pattern: Pattern=Pattern.CHAIN
var remaining: float=1.2
var facing: int=-1
var attacks: int=0
var flash: float=0.0
var _phase_pending: bool=false
@onready var source: DamageSource=$AttackSource
@onready var visual: Node2D=$Visual
func _ready() -> void:
 process_physics_priority=-2
 health=max_health
 $SwordReceiver.hit_received.connect(_hit)
 health_changed.emit(health,max_health)
func _state(next: State, duration: float) -> void:
 state=next
 remaining=duration
 velocity=Vector2.ZERO
 source.set_active(next==State.ACTIVE)
 if next==State.ACTIVE:
  source.set_direction(facing)
  source.configure(1 if pattern==Pattern.DASH else (2 if pattern==Pattern.SWEEP else 0),0.0,facing)
 visual.queue_redraw()
func _hit() -> void:
 if state in [State.INTRO,State.TRANSITION,State.DEFEATED] or not is_instance_valid(target) or target.survival.is_dead: return
 health=maxi(0,health-1)
 flash=0.14
 health_changed.emit(health,max_health)
 if health==0:
  _state(State.DEFEATED,0.0)
  $SwordReceiver/CollisionShape2D.set_deferred("disabled",true)
  defeated.emit()
 elif phase==1 and health<=max_health/2:
  _phase_pending=true
  if state not in [State.WARNING,State.ACTIVE]: _begin_transition()
func _begin_transition() -> void:
 phase=2
 attacks=1 # First phase-two commitment demonstrates the learned dash.
 _phase_pending=false
 _state(State.TRANSITION,1.0)
func disarm() -> void:
 source.set_active(false)
 velocity=Vector2.ZERO
func _physics_process(delta: float) -> void:
 flash=maxf(0,flash-delta)
 visual.queue_redraw()
 if state==State.DEFEATED: return
 if not is_instance_valid(target) or target.survival.is_dead:
  disarm()
  return
 remaining=maxf(0,remaining-delta)
 match state:
  State.INTRO:
   if remaining<=0: _state(State.PURSUIT,0.0)
  State.PURSUIT:
   var dx: float=target.global_position.x-global_position.x
   facing=1 if dx>0 else -1
   if absf(dx)<75 or (phase==2 and absf(dx)<150):
    attacks+=1
    pattern=Pattern.DASH if phase==2 and attacks%2==0 else (Pattern.SWEEP if attacks%2==0 else Pattern.CHAIN)
    _state(State.WARNING,dash_warning_time if pattern==Pattern.DASH else warning_time)
   else:
    velocity=Vector2(facing*move_speed,40)
    move_and_slide()
    position.x=clampf(position.x,25,295)
  State.WARNING:
   if remaining<=0: _state(State.ACTIVE,0.42 if pattern==Pattern.DASH else 0.22)
  State.ACTIVE:
   if pattern==Pattern.DASH:
    velocity=Vector2(facing*dash_speed,40)
    move_and_slide()
    position.x=clampf(position.x,25,295)
    if is_on_wall(): remaining=0.0
   if remaining<=0:
    if _phase_pending: _begin_transition()
    else: _state(State.RECOVER,phase_two_recovery_time if phase==2 else recovery_time)
  State.RECOVER:
   if remaining<=0: _state(State.PURSUIT,0.0)
  State.TRANSITION:
   if remaining<=0: _state(State.RECOVER,recovery_time)
