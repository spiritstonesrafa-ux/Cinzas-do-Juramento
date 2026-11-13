extends Node2D
## Local, interruptible presentation only. Combat parameters and life system stay untouched.
signal finished
const DURATION: float=2.6
const TITLE: String="JURAMENTO ROMPIDO"
const PHASE_TEXT: String="O Cemitério dos Esquecidos — concluído"
const NARRATIVE: String="Um elo da maldição se rompe."
const CONTINUATION: String="A jornada de Aren continua."
var played: bool=false
var running: bool=false
var settled: bool=false
var elapsed: float=0
var sequence_count: int=0
var completion_count: int=0
var reward_granted: bool=false
@onready var boss: OathGuardian=get_parent() as OathGuardian
func _ready() -> void:
 boss.defeated.connect(_begin)
 boss.state_changed.connect(_on_state)
func _on_state(value: int) -> void:
 if value in [OathGuardian.State.RESET,OathGuardian.State.INTRO]:
  cancel()
func _begin() -> void:
 if played or boss.current_health!=0:return
 # Death wins a simultaneous event; M2 will reset this encounter on respawn.
 if not is_instance_valid(boss.target) or boss.target.survival.is_dead:return
 if not boss.target.survival.died.is_connected(_on_player_died):boss.target.survival.died.connect(_on_player_died)
 played=true;running=true;settled=false;elapsed=0
 sequence_count+=1
 queue_redraw()
func _on_player_died() -> void:
 # Once back in the cemetery, M4-A/B session victory must remain persistent.
 if boss.get_parent().get_parent().active:cancel()
func cancel() -> void:
 played=false;running=false;settled=false;elapsed=0;reward_granted=false
 queue_redraw()
 boss.visual.queue_redraw()
 get_parent().get_parent().get_node("Backdrop").queue_redraw()
func settle(skip_text: bool=false) -> void:
 if not played:return
 if not settled:
  settled=true;running=false
  elapsed=maxf(elapsed,DURATION)
  completion_count+=1
  finished.emit()
 if skip_text:elapsed=10
 queue_redraw()
func _physics_process(delta: float) -> void:
 if not played:return
 elapsed=minf(12,elapsed+delta)
 if running and elapsed>=DURATION:settle()
 scale.x=float(boss.facing)
 queue_redraw()
 boss.visual.queue_redraw()
 get_parent().get_parent().get_node("Backdrop").queue_redraw()
func pose() -> int:
 if elapsed<0.4:return 0
 if elapsed<1.1:return 1
 if elapsed<1.9:return 2
 return 3
func _draw() -> void:
 if not played or boss.state!=OathGuardian.State.DEFEATED:return
 if elapsed<1.9:
  var release: float=sin(elapsed/1.9*PI)
  for i: int in range(12):
   var angle: float=float(i)*TAU/12.0+elapsed*1.8
   var radius: float=8.0+elapsed*18.0+sin(elapsed*7.0+i)*3.0
   var ember: Vector2=Vector2(cos(angle)*radius,-44.0-sin(angle)*radius-elapsed*8.0)
   draw_circle(ember,1.0+fposmod(float(i)*0.73+elapsed*3.0,2.4),Color(1.0,0.34+fposmod(float(i)*0.11,0.4),0.08,release*0.88))
