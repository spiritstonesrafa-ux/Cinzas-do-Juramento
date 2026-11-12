extends Node2D
## Portal adapter: M3 scene, physics, checkpoints and camera code remain untouched.
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
var arena: Node2D
var active: bool=false
var completed: bool=false
var exit_unlocked: bool=false
var transitioning: bool=false
var stage: Node2D
var hero: KnightController
var old_camera: Camera2D
var old_z: int
var enemy_mode: Node.ProcessMode
var hazard_mode: Node.ProcessMode
var entry: Area2D
func _ready() -> void:
 stage=get_parent().get_node("ForgottenCemetery") as Node2D
 hero=stage.get_node("Knight") as KnightController
 old_camera=stage.get_node("Camera2D") as Camera2D
 entry=Area2D.new()
 entry.name="CathedralSeal"
 entry.position=Vector2(2344,138)
 entry.collision_layer=0
 entry.collision_mask=2
 var collision: CollisionShape2D=CollisionShape2D.new()
 var rectangle: RectangleShape2D=RectangleShape2D.new()
 rectangle.size=Vector2(24,36)
 collision.shape=rectangle
 entry.add_child(collision)
 add_child(entry)
 entry.body_entered.connect(_on_entry)
 hero.survival.respawn_requested.connect(_on_respawn)
 hero.survival.died.connect(_on_death)
 if ABBEY_PROGRESS.guardian_reward_unlocked():
  completed=true
  exit_unlocked=true
func _on_entry(body: Node2D) -> void:
 if body==hero and not active and not hero.survival.is_dead and not completed:enter.call_deferred()
func enter() -> void:
 if active or hero.survival.is_dead:return
 if arena==null:
  arena=(load("res://scenes/boss/guardian_arena.tscn") as PackedScene).instantiate()
  arena.position=Vector2(2560,0)
  add_child(arena)
  arena.get_node("Guardian").defeated.connect(_on_defeated)
  if arena.has_node("Guardian/Conclusion"):
   arena.get_node("Guardian/Conclusion").finished.connect(_on_conclusion_finished)
  arena.get_node("BossHUD/Presentation").boss=arena.get_node("Guardian")
 active=true
 transitioning=false
 exit_unlocked=completed and arena.has_node("Guardian/Conclusion") and arena.get_node("Guardian/Conclusion").settled
 old_z=hero.z_index
 hero.z_index=2
 enemy_mode=stage.get_node("Enemies").process_mode
 hazard_mode=stage.get_node("Mechanisms").process_mode
 stage.get_node("Enemies").process_mode=Node.PROCESS_MODE_DISABLED
 stage.get_node("Mechanisms").process_mode=Node.PROCESS_MODE_DISABLED
 stage.get_node("StageHUD").hide()
 hero.reset_to(arena.global_position+Vector2(48,156))
 arena.get_node("ArenaCamera").enabled=true
 arena.get_node("ArenaCamera").make_current()
 arena.get_node("BossHUD").show()
 arena.get_node("LeftGate/CollisionShape2D").set_deferred("disabled",exit_unlocked)
 if arena.has_node("RightWall/CollisionShape2D"):
  arena.get_node("RightWall/CollisionShape2D").set_deferred("disabled",exit_unlocked)
 if not completed:arena.get_node("Guardian").begin(hero)
func _on_defeated() -> void:
 completed=true
 var is_settled: bool = arena!=null and arena.has_node("Guardian/Conclusion") and arena.get_node("Guardian/Conclusion").settled
 exit_unlocked = is_settled
 if not ABBEY_PROGRESS.guardian_reward_unlocked():
  if ABBEY_PROGRESS.grant_guardian_reward():
   hero.survival.grant_health_upgrade(1)
   if arena!=null and arena.has_node("Guardian/Conclusion"):
    arena.get_node("Guardian/Conclusion").reward_granted=true
func _on_conclusion_finished() -> void:
 exit_unlocked=true
 if arena!=null:
  if arena.has_node("LeftGate/CollisionShape2D"):
   arena.get_node("LeftGate/CollisionShape2D").set_deferred("disabled",true)
  if arena.has_node("RightWall/CollisionShape2D"):
   arena.get_node("RightWall/CollisionShape2D").set_deferred("disabled",true)
func _on_death() -> void:
 if active:arena.get_node("Guardian").clear_dangers()
func _on_respawn() -> void:
 if active:leave(false)
func leave(return_from_victory: bool) -> void:
 active=false
 hero.z_index=old_z
 stage.get_node("Enemies").process_mode=enemy_mode
 stage.get_node("Mechanisms").process_mode=hazard_mode
 stage.get_node("StageHUD").show()
 arena.get_node("BossHUD").hide()
 arena.get_node("ArenaCamera").enabled=false
 if return_from_victory:
  if arena!=null and arena.has_node("Guardian/Conclusion"):
   arena.get_node("Guardian/Conclusion").settle(true)
  exit_unlocked=true
  hero.reset_to(Vector2(2296,156))
 else:
  completed=false
  exit_unlocked=false
  arena.get_node("Guardian").reset_encounter()
 stage._update_presentation()
 old_camera.make_current()
func _physics_process(_delta: float) -> void:
 if not active:return
 if hero.survival.is_dead:
  arena.get_node("Guardian/AttackSource").set_active(false)
  return
 if hero.global_position.x<2500 or hero.global_position.y>288:
  leave(false)
 elif completed and exit_unlocked and hero.global_position.x<arena.global_position.x+22:
  leave(true)
 elif completed and exit_unlocked and hero.global_position.x>arena.global_position.x+310 and not transitioning:
  transitioning=true
  ABBEY_PROGRESS.set_pending_entrance("from_cemetery")
  var tree: SceneTree=get_tree()
  if tree!=null:
   if tree.current_scene==null:
    var main_root: Node=self
    while main_root.get_parent()!=null and main_root.get_parent()!=tree.root:
     main_root=main_root.get_parent()
    tree.current_scene=main_root
   tree.change_scene_to_file.call_deferred("res://scenes/abbey/abbey_chapter.tscn")
func _draw() -> void:
 if completed:return
 # Small original seal on the existing final gate; never changes world geometry.
 var center: Vector2=Vector2(2344,120)
 draw_rect(Rect2(center-Vector2(11,32),Vector2(22,68)),Color("14222f",0.8))
 draw_arc(center,13,0,TAU,24,Color("72b9b3"),1)
 draw_line(center+Vector2(-8,0),center+Vector2(8,0),Color("ba9865"),1)
 draw_line(center+Vector2(0,-8),center+Vector2(0,8),Color("ba9865"),1)
 draw_string(ThemeDB.fallback_font,Vector2(2300,77),"Selo do Guardião",HORIZONTAL_ALIGNMENT_LEFT,-1,7,Color("c4b99d"))

func _process(_delta: float) -> void:
 # Replace only the obsolete finish hint after this encounter's victory.
 if completed and not active and hero.position.x>=2256:
  stage.hint_label.text="Portão da Catedral aberto: avance à direita para a Abadia Silenciosa"
  stage.get_node("StageHUD/Presentation").queue_redraw()
