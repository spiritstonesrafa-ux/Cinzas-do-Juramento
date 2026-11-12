class_name OathGuardian
extends CharacterBody2D
## M4-B extends the approved encounter; shared M1/M2 contracts remain unchanged.
signal health_changed(current: int, maximum: int)
signal defeated
signal state_changed(value: int)
enum State { IDLE, INTRO, WAKE, PURSUIT, TELEGRAPH, ATTACK, HURT, PUNISH, DEFEATED, RESET, PHASE_TRANSITION, SUPER_WARN, SUPER_ACTIVE, SUPER_RECOVER }
enum Pattern { HEAVY, CHARGE, SWEEP, WAVE }
@export_range(1,99,1) var max_health: int=10
@export var pursuit_speed: float=34.0
@export var intro_duration: float=0.9
@export var wake_duration: float=0.35
@export var telegraph_duration: float=0.8
@export var attack_duration: float=0.18
@export var punish_duration: float=1.1
@export_range(0.1,0.9,0.05) var phase_threshold: float=0.5
@export var transition_duration: float=0.9
var phase: int=1
var pattern: Pattern=Pattern.HEAVY
var attack_count: int=0
var last_pattern: int=-1
var cooldowns: Dictionary={}
var charge_travel: float=0
var phase_pending: bool=false
var elapsed: float=0
var special_wave: Node2D
var super_waves: Array[Node2D]=[]
var super_used: bool=false
var super_second_sent: bool=false
const WAVE_SCRIPT: GDScript=preload("res://scripts/boss/oath_wave.gd")
var state: State=State.IDLE
var current_health: int=10
var target: KnightController
var facing: int=-1
var remaining: float=0
var flash: float=0
var awake: bool=false
var origin: Vector2
var resume_state: State=State.PURSUIT
var resume_time: float=0
var hurt_lockout: float=0
var pressure_window: float=0
var pressure_hits: int=0
var retreat_remaining: float=0
var retreat_cooldown: float=0
@onready var attack_source: DamageSource=$AttackSource
@onready var visual: Node2D=$Visual
@onready var receiver: CollisionShape2D=$SwordReceiver/CollisionShape2D
func _ready() -> void:
 process_physics_priority=-2
 origin=position
 $SwordReceiver.hit_received.connect(receive_hit)
 reset_encounter()
func _set_state(value: State, duration: float=0) -> void:
 state=value
 if value in [State.ATTACK,State.PHASE_TRANSITION,State.DEFEATED,State.RESET]:retreat_remaining=0
 remaining=duration
 velocity=Vector2.ZERO
 attack_source.set_active(value==State.ATTACK and pattern!=Pattern.WAVE)
 if value==State.ATTACK:
  attack_source.set_direction(facing)
  attack_source.configure(pattern,0,facing)
  if pattern==Pattern.WAVE:_spawn_wave()
 state_changed.emit(state)
 visual.queue_redraw()
func reset_encounter() -> void:
 clear_dangers()
 _set_state(State.RESET)
 phase=1
 phase_pending=false
 super_used=false
 super_second_sent=false
 attack_count=0
 last_pattern=-1
 cooldowns.clear()
 elapsed=0
 hurt_lockout=0
 pressure_window=0
 pressure_hits=0
 retreat_remaining=0
 retreat_cooldown=0
 pattern=Pattern.HEAVY
 position=origin
 facing=-1
 current_health=max_health
 awake=false
 flash=0
 receiver.set_deferred("disabled",false)
 health_changed.emit(current_health,max_health)
 _set_state(State.IDLE)
func begin(player: KnightController) -> void:
 target=player
 awake=true
 _set_state(State.INTRO,intro_duration)
func receive_hit() -> void:
 if not awake or state in [State.RESET,State.INTRO,State.WAKE,State.DEFEATED,State.PHASE_TRANSITION]:return
 current_health=maxi(0,current_health-1)
 if state in [State.PURSUIT,State.TELEGRAPH] and retreat_cooldown<=0:
  pressure_hits=pressure_hits+1 if pressure_window>0 else 1
  pressure_window=0.65
  if pressure_hits>=2:
   retreat_remaining=0.35
   retreat_cooldown=2.0
   pressure_hits=0
 flash=0.14
 health_changed.emit(current_health,max_health)
 if current_health==0:
  clear_dangers()
  awake=false
  receiver.set_deferred("disabled",true)
  _set_state(State.DEFEATED)
  defeated.emit()
 elif phase==1 and float(current_health)/max_health<=phase_threshold:
  phase_pending=true
  if state not in [State.TELEGRAPH,State.ATTACK]:_start_transition()
 elif state in [State.IDLE,State.PURSUIT,State.PUNISH] and hurt_lockout<=0:
  hurt_lockout=0.8
  resume_state=state
  resume_time=remaining
  _set_state(State.HURT,0.16)
 # Armor does not cancel a committed warning/swing; damage still counts.
func _physics_process(delta: float) -> void:
 flash=maxf(0,flash-delta)
 hurt_lockout=maxf(0,hurt_lockout-delta)
 pressure_window=maxf(0,pressure_window-delta)
 retreat_cooldown=maxf(0,retreat_cooldown-delta)
 visual.scale.x=float(facing)
 visual.queue_redraw()
 if not awake:return
 if not is_instance_valid(target) or target.survival.is_dead:
  clear_dangers()
  velocity=Vector2.ZERO
  return
 elapsed+=delta
 for key: int in cooldowns:cooldowns[key]=maxf(0,float(cooldowns[key])-delta)
 remaining=maxf(0,remaining-delta)
 match state:
  State.INTRO:
   if remaining==0:_set_state(State.WAKE,wake_duration)
  State.WAKE:
   if remaining==0:_set_state(State.IDLE,0.35)
  State.IDLE:
   if remaining==0:_set_state(State.PURSUIT)
  State.PURSUIT:
   if phase==2 and not super_used:
    _start_super()
    return
   var distance: float=target.global_position.x-global_position.x
   facing=1 if distance>0 else -1
   if absf(distance)<=80 or (attack_count>=2 and absf(distance)<=150):
    start_pattern(_choose_pattern(absf(distance)))
   else:
    velocity.x=signf(distance)*pursuit_speed
    velocity.y=40
    move_and_slide()
    position.x=clampf(position.x,28,292)
  State.TELEGRAPH:
   if retreat_remaining>0:
    retreat_remaining=maxf(0,retreat_remaining-delta)
    velocity=Vector2(-facing*100.0,40)
    move_and_slide()
    position.x=clampf(position.x,28,292)
   if remaining==0:_set_state(State.ATTACK,active_seconds())
  State.ATTACK:
   if pattern==Pattern.CHARGE:
    # Reserve the actual forward blade reach inside the 320px camera.
    var space: float=maxf(0,243-position.x if facing>0 else position.x-77)
    var step: float=minf(minf(144*delta,72-charge_travel),space)
    # Do not cross or occupy Aren: his normal jump cannot clear our 62px body.
    # Keep a physical escape gap while allowing the blade to threaten ahead.
    var target_gap: float=(target.global_position.x-global_position.x)*facing
    if target_gap>=0.0: step=minf(step,maxf(0.0,target_gap-28.0))
    var before: float=position.x
    velocity=Vector2(facing*step/delta,40)
    move_and_slide()
    position.x=clampf(position.x,28,292)
    charge_travel+=absf(position.x-before)
   attack_source.configure(pattern,1-remaining/active_seconds(),facing)
   # The blade retracts during the final 0.16 s of the forward movement.
   if pattern==Pattern.CHARGE and remaining<=0.16 and attack_source.active:
    attack_source.set_active(false)
   if remaining==0:
    if phase_pending:_start_transition()
    else:_set_state(State.PUNISH,recovery_seconds())
  State.PUNISH:
   if remaining==0:_set_state(State.PURSUIT)
  State.PHASE_TRANSITION:
   if remaining==0:_set_state(State.PUNISH,1.1)
  State.HURT:
   if remaining==0:_set_state(resume_state,resume_time)
  State.SUPER_WARN:
   if remaining==0:
    _set_state(State.SUPER_ACTIVE,2.8)
    _spawn_super_pair()
  State.SUPER_ACTIVE:
   if remaining<=1.7 and not super_second_sent:
    super_second_sent=true
    _spawn_super_pair()
   if remaining==0:_set_state(State.SUPER_RECOVER,1.4)
  State.SUPER_RECOVER:
   if remaining==0:_set_state(State.PURSUIT)

func warning_seconds() -> float:
 match pattern:
  Pattern.CHARGE:return 0.9
  Pattern.SWEEP:return 0.85
  Pattern.WAVE:return 1.05
 return telegraph_duration
func active_seconds() -> float:
 match pattern:
  Pattern.CHARGE:return 0.5
  Pattern.SWEEP:return 0.25
  Pattern.WAVE:return 0.22
 return attack_duration
func recovery_seconds() -> float:
 var duration: float=punish_duration
 if pattern==Pattern.CHARGE:duration=1.3
 elif pattern==Pattern.SWEEP:duration=1.2
 elif pattern==Pattern.WAVE:duration=2.15 # Wave expires before another offensive pattern.
 return maxf(0.95,duration-(0.1 if phase==2 else 0))
func _choose_pattern(distance: float) -> Pattern:
 # The opening teaches the heavy swing; subsequent choices depend on position.
 if attack_count<1:return Pattern.HEAVY
 if target.global_position.y<global_position.y-30 and last_pattern!=Pattern.SWEEP and float(cooldowns.get(Pattern.SWEEP,0))==0:return Pattern.SWEEP
 if phase==2 and last_pattern!=Pattern.WAVE and float(cooldowns.get(Pattern.WAVE,0))==0:return Pattern.WAVE
 var space: float=292-position.x if facing>0 else position.x-28
 if distance>=96 and space>=121 and last_pattern!=Pattern.CHARGE and float(cooldowns.get(Pattern.CHARGE,0))==0:return Pattern.CHARGE
 if (320-position.x if facing>0 else position.x)>=86 and last_pattern!=Pattern.SWEEP and float(cooldowns.get(Pattern.SWEEP,0))==0:return Pattern.SWEEP
 return Pattern.HEAVY
func start_pattern(value: Pattern) -> void:
 pattern=value
 last_pattern=value
 attack_count+=1
 charge_travel=0
 cooldowns[value]=5.0 if value==Pattern.WAVE else 2.0
 _set_state(State.TELEGRAPH,warning_seconds())
func _start_transition() -> void:
 phase_pending=false
 clear_dangers()
 phase=2
 _set_state(State.PHASE_TRANSITION,transition_duration)
func _start_super() -> void:
 super_used=true
 super_second_sent=false
 _set_state(State.SUPER_WARN,1.3)
func _spawn_super_pair() -> void:
 for side: int in [-1,1]:
  var wave: Node2D=WAVE_SCRIPT.new()
  wave.direction=side
  wave.guardian=self
  get_parent().add_child(wave)
  wave.global_position=global_position+Vector2(28*side,0)
  super_waves.append(wave)
func clear_dangers() -> void:
 attack_source.set_active(false)
 for wave: Node2D in super_waves:
  if is_instance_valid(wave):wave.disarm();wave.queue_free()
 super_waves.clear()
 if is_instance_valid(special_wave):
  special_wave.disarm()
  special_wave.queue_free()
 special_wave=null
func _spawn_wave() -> void:
 if is_instance_valid(special_wave):special_wave.disarm();special_wave.queue_free()
 special_wave=WAVE_SCRIPT.new()
 special_wave.direction=facing
 special_wave.guardian=self
 get_parent().add_child(special_wave)
 special_wave.global_position=global_position+Vector2(28*facing,0)
