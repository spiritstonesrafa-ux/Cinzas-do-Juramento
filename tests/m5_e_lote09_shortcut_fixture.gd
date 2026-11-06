extends SceneTree
## Synthetic placement isolates gating, loaded destinations and session state.
const LINKS: Script=preload("res://scripts/abbey/m5e_shortcuts.gd")
var chapter: Node2D
var hero: KnightController
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func check(ok: bool,label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func press_e() -> void:
 var e: InputEventKey=InputEventKey.new()
 e.keycode=KEY_E
 e.pressed=true
 Input.parse_input_event(e)
 await tick()
 e=InputEventKey.new()
 e.keycode=KEY_E
 e.pressed=false
 Input.parse_input_event(e)
 await tick()
func cross_passage(side: int) -> float:
 for n: int in range(240):
  if chapter.passage_index>=0 and not chapter.busy: break
  await tick()
 var length: float=0.0
 var last: Vector2=hero.global_position
 Input.action_press("move_right" if side>0 else "move_left")
 for n: int in range(1000):
  await tick()
  if chapter.passage_index<0: break
  length+=hero.global_position.distance_to(last)
  last=hero.global_position
 Input.action_release("move_right" if side>0 else "move_left")
 while chapter.busy: await tick()
 for n: int in range(6): await tick()
 return length
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 for i: int in range(3):
  var link: Array=LINKS.LINKS[i]
  for side: int in [0,2]:
   var id: int=link[side]
   await chapter.switch_room(id)
   var pos: Vector2=LINKS.point(id,link[side+1])
   var world: Vector2=AbbeyChapterLayout.origin(id)+pos
   check(hero.is_respawn_safe(world),"A%d suporte e colisão no S%d %s" % [i+1,id+1,pos])
   hero.reset_to(world)
   for f: int in range(5): await tick()
   if side==0:
    await press_e()
    check(not chapter.unlocked_shortcuts.has(i) and chapter.current_room==id,"A%d lado inicial bloqueado" % (i+1))
  # Simulated visit list is strictly a unit fixture, not proof of traversal.
  await press_e()
  check(not chapter.unlocked_shortcuts.has(i),"A%d não abre antes de concluir a sala avançada" % (i+1))
  chapter.forward_completed[link[2]]=true
  if i==2:
   chapter.visits.erase(9)
   while chapter.visits.has(9): chapter.visits.erase(9)
   await press_e()
   check(not chapter.unlocked_shortcuts.has(i),"A3 não abre sem primeira visita S10")
   chapter.visits.append(9)
  await press_e()
  check(chapter.unlocked_shortcuts.has(i),"A%d desbloqueia pelo lado avançado após pré-requisitos" % (i+1))
  await press_e()
  var passage_out: float=await cross_passage(-1)
  check(passage_out>120,"A%d corredor percorrido fisicamente" % (i+1))
  check(chapter.current_room==link[0] and (hero.global_position-AbbeyChapterLayout.origin(link[0])).distance_to(LINKS.point(link[0],link[1]))<3,"A%d chegada segura à porta inicial" % (i+1))
  await press_e()
  var passage_back: float=await cross_passage(1)
  check(passage_back>120,"A%d corredor percorrido no retorno" % (i+1))
  check(chapter.current_room==link[2] and (hero.global_position-AbbeyChapterLayout.origin(link[2])).distance_to(LINKS.point(link[2],link[3]))<3,"A%d retorno à porta avançada" % (i+1))
 # Real damage and normal death/respawn; all three were opened through E.
 check(hero.receive_damage(999),"Dano letal aceito após desbloqueios")
 for f: int in range(6000):
  await tick()
  if not hero.survival.is_dead and not chapter.busy: break
 print("DEATH DEBUG dead=",hero.survival.is_dead," busy=",chapter.busy," mode=",hero.process_mode," room=",chapter.current_room," unlocks=",chapter.unlocked_shortcuts," health=",hero.survival.current_health)
 check(not hero.survival.is_dead and chapter.unlocked_shortcuts.size()==3,"Morte e respawn mantêm os três desbloqueios")
 # Synthetic out-of-bounds position exercises the real live-fall handler.
 hero.global_position.y=AbbeyChapterLayout.bounds(chapter.current_room).end.y+140
 for f: int in range(180):
  await tick()
  if chapter.current_room==0 and not chapter.busy and not chapter.resetting: break
 check(chapter.current_room==0 and chapter.unlocked_shortcuts.size()==3,"Queda viva mantém os três desbloqueios")
 print("Lote09 gate fixture failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
