extends SceneTree
var failures: int=0
func _initialize() -> void:run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n):await physics_frame;await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v:failures+=1
func dash() -> void:
 Input.action_press("move_right")
 var e: InputEventKey=InputEventKey.new();e.keycode=KEY_SHIFT;e.pressed=true;Input.parse_input_event(e)
 await tick(1)
 var active: bool=chapter.hero.dash_remaining>0
 e=InputEventKey.new();e.keycode=KEY_SHIFT;e.pressed=false;Input.parse_input_event(e)
 check(active,"dash realmente iniciado")
var chapter: Node2D
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0:await tick()
 var hero: KnightController=chapter.hero
 check(hero.dash_unlocked,"progresso isolado com recompensa de vitória")
 # Normal sector boundary: real movement and authored room handoff.
 hero.reset_to(AbbeyChapterLayout.origin(0)+Vector2(978,300));await tick(5)
 await dash()
 for n: int in range(120):
  await tick()
  if chapter.current_room==1 and not chapter.busy:break
 Input.action_release("move_right")
 check(chapter.current_room==1 and not chapter.busy,"dash atravessa apenas transição normal S1→S2")
 check(hero.dash_remaining==0.0,"dash cancelado na troca de sala")
 # Actual checkpoint trigger while dashing, position prepared inside S2.
 var cp: RespawnCheckpoint=chapter.checkpoints[0]
 hero.reset_to(cp.global_position-Vector2(42,0));await tick(60)
 await dash();await tick(16);Input.action_release("move_right")
 check(hero.active_checkpoint==cp,"dash ativa checkpoint existente por contato")
 # Small authored gap in S8, no invented solid or teleport during the move.
 await chapter.switch_room(7)
 hero.reset_to(AbbeyChapterLayout.origin(7)+Vector2(290,284));await tick(60)
 var start_y: float=hero.global_position.y
 await dash();await tick(12);Input.action_release("move_right")
 var local: Vector2=hero.global_position-AbbeyChapterLayout.origin(7)
 print("EDGE local=",local," start_y=",start_y," floor=",hero.is_on_floor()," velocity=",hero.velocity)
 check(chapter.current_room==7 and local.x>320 and local.y>=start_y-0.2,"borda S8 atravessada pela física sem subir ou mudar de setor")
 # S5 real sluice is put in active phase, no invulnerability or disabled threats.
 await chapter.switch_room(4)
 var hazard: Node2D=chapter.room.encounters.hazards[0]
 hero.survival.restore();hero.reset_to(hazard.global_position+Vector2(-38,-24));await tick(60)
 hazard.state=hazard.State.ACTIVE;hazard.elapsed=0;hazard.remaining=1.0;hazard.contacts.clear();hazard.update_shape();hazard.shape.disabled=false
 var hp: int=hero.survival.current_health
 await dash();await tick(16);Input.action_release("move_right")
 print("HAZARD hp=",hero.survival.current_health," expected_before=",hp," hero=",hero.global_position-hazard.global_position)
 check(hero.survival.current_health<hp,"dash recebe dano de comporta ativa")
 print("M5G FIX01 dash integration failures=",failures)
 chapter.queue_free();await tick(120);quit(1 if failures else 0)
