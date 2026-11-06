extends Node2D
## Local, interruptible presentation only. Combat parameters and life system stay untouched.
signal finished
const ART: Texture2D=preload("res://assets/art/m4c/guardian_defeat.png")
const FLAME: Texture2D=preload("res://assets/art/m4b/oath_flame.png")
const DURATION: float=2.6
const TITLE: String="JURAMENTO ROMPIDO"
const PHASE_TEXT: String="O Cemitério dos Esquecidos — concluído"
const NARRATIVE: String="Um elo da maldição se rompe."
const CONTINUATION: String="A jornada de Aren continua."
const ROOTS: Array[Vector2]=[Vector2(300,565),Vector2(940,565),Vector2(310,1165),Vector2(940,1165)]
const REGIONS: Array[Rect2]=[Rect2(0,0,632,622),Rect2(632,0,632,622),Rect2(0,622,632,622),Rect2(632,622,632,622)]
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
 var frame: int=pose()
 var offset: Vector2=Vector2.ZERO
 if elapsed<0.4:offset.x=-sin(elapsed/0.4*PI)*2
 elif elapsed<1.1:offset.y=-sin((elapsed-0.4)/0.7*PI)*1.2
 var tint: Color=Color(1.2,1.2,1.25)
 if settled:tint=Color(0.74,0.78,0.82)
 draw_texture_rect_region(ART,Rect2(((REGIONS[frame].position-ROOTS[frame])*0.125).round()+offset,(REGIONS[frame].size*0.125).round()),REGIONS[frame],tint)
 if elapsed<1.9:
  var release: float=sin(elapsed/1.9*PI)
  draw_set_transform(Vector2(-2,-34-elapsed*9),-PI/2)
  draw_texture_rect_region(FLAME,Rect2(-10,-8,28,16),Rect2(40,238,1432,550),Color(0.85,1.1,1.05,release*0.8))
  draw_set_transform(Vector2.ZERO)
  # Original bronze/steel fragments from the new atlas, not colored debug geometry.
  for i: int in range(3):
   var x: float=(i-1)*elapsed*9
   var y: float=-24+elapsed*elapsed*9-i*2
   var alpha: float=clampf((1.9-elapsed)*1.6,0,1)
   draw_texture_rect_region(ART,Rect2(x,y,4,4),Rect2(177+i*9,230,32,32),Color(1,1,1,alpha))
