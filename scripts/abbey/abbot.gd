extends CharacterBody2D
signal defeated
signal health_changed(current: int, maximum: int)
enum State { INTRO, PURSUIT, WARNING, ACTIVE, RECOVER, TRANSITION, DEFEATED, ASCEND, JUDGMENT, DESCEND, DEATH_DESCEND }
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
var last_pattern: int=-1
var contact_damage_enabled: bool=true
var judgment_used: bool=false
var judgment_index: int=0
var judgment_clock: float=0.0
var flight_start: Vector2
var flight_end: Vector2
var ground_y: float=156.0
var judgment_hazards: Array[Node]=[]
const JUDGMENT_CHAIN: GDScript=preload("res://scripts/abbey/judgment_chain.gd")
@onready var source: DamageSource=$AttackSource
@onready var visual: Node2D=$Visual
func _ready() -> void:
 process_physics_priority=-2
 health=max_health
 $SwordReceiver.hit_received.connect(_hit)
 health_changed.emit(health,max_health)
func _state(next: State, duration: float) -> void:
 state=next
 contact_damage_enabled=next not in [State.ASCEND,State.JUDGMENT,State.DESCEND,State.DEATH_DESCEND,State.DEFEATED]
 remaining=duration
 velocity=Vector2.ZERO
 source.set_active(next==State.ACTIVE)
 if next==State.ACTIVE:
  source.set_direction(facing)
  source.configure(1 if pattern==Pattern.DASH else (2 if pattern==Pattern.SWEEP else 0),0.0,facing)
 visual.queue_redraw()
func _hit() -> void:
 if state in [State.INTRO,State.TRANSITION,State.DEFEATED,State.DEATH_DESCEND] or not is_instance_valid(target) or target.survival.is_dead: return
 health=maxi(0,health-1)
 flash=0.14
 health_changed.emit(health,max_health)
 if health==0:
  _clear_judgment()
  $SwordReceiver/CollisionShape2D.set_deferred("disabled",true)
  if state in [State.ASCEND,State.JUDGMENT,State.DESCEND]:
   flight_start=position
   flight_end=Vector2(position.x,ground_y)
   _state(State.DEATH_DESCEND,0.6)
  else:
   _state(State.DEFEATED,0.0)
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
 _clear_judgment()
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
    pattern=_choose_pattern(absf(dx))
    last_pattern=pattern
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
   if remaining<=0:
    if not judgment_used: _start_judgment()
    else: _state(State.RECOVER,recovery_time)
  State.ASCEND:
   var t: float=1.0-remaining/1.0
   position=flight_start.lerp(flight_end,smoothstep(0.0,1.0,t))
   if remaining<=0: _state(State.JUDGMENT,7.0)
  State.JUDGMENT:
   judgment_clock-=delta
   if judgment_clock<=0 and judgment_index<7:
    _launch_judgment_chain()
    judgment_clock=0.9
   if remaining<=0:
    flight_start=position
    flight_end=Vector2(position.x,ground_y)
    _state(State.DESCEND,0.9)
  State.DESCEND:
   position=flight_start.lerp(flight_end,smoothstep(0.0,1.0,1.0-remaining/0.9))
   if remaining<=0: _state(State.RECOVER,1.3)
  State.DEATH_DESCEND:
   position=flight_start.lerp(flight_end,smoothstep(0.0,1.0,1.0-remaining/0.6))
   if remaining<=0:
    _state(State.DEFEATED,0.0)
    defeated.emit()

func _choose_pattern(distance: float) -> Pattern:
 var space: float=295-position.x if facing>0 else position.x-25
 if phase==2 and distance>90 and space>90 and last_pattern!=Pattern.DASH: return Pattern.DASH
 if target.global_position.y<global_position.y-30 and last_pattern!=Pattern.SWEEP: return Pattern.SWEEP
 if distance<55 and last_pattern!=Pattern.SWEEP: return Pattern.SWEEP
 return Pattern.CHAIN if last_pattern!=Pattern.CHAIN else Pattern.SWEEP

func _start_judgment() -> void:
 judgment_used=true
 judgment_index=0
 judgment_clock=0.2
 ground_y=position.y
 flight_start=position
 flight_end=Vector2(160,ground_y-62)
 _state(State.ASCEND,1.0)

func _launch_judgment_chain() -> void:
 var x: float
 # Alternate edges, traverse the arena, then snapshot Aren for aimed strikes.
 if judgment_index<2: x=70.0 if judgment_index==0 else 250.0
 elif judgment_index<5: x=55.0+(judgment_index-2)*105.0
 else: x=clampf(get_parent().to_local(target.global_position).x,32.0,288.0)
 var chain: Node2D=JUDGMENT_CHAIN.new()
 chain.position=Vector2(x,ground_y)
 chain.owner_boss=self
 get_parent().add_child(chain)
 judgment_hazards.append(chain)
 judgment_index+=1

func _clear_judgment() -> void:
 for hazard: Node in judgment_hazards:
  if is_instance_valid(hazard): hazard.disarm(); hazard.queue_free()
 judgment_hazards.clear()
