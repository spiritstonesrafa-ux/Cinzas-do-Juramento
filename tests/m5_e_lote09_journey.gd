extends "res://tests/m5_c3_journey_test.gd"
const LINKS: Script=preload("res://scripts/abbey/m5e_shortcuts.gd")
var failures: int=0
func check(ok: bool, label: String) -> void:
 print(("PASS " if ok else "FAIL ")+label)
 if not ok: failures+=1
func release_all() -> void:
 for a: String in ["move_left","move_right","jump","attack"]: Input.action_release(a)
func press_e() -> void:
 var ev: InputEventKey=InputEventKey.new()
 ev.keycode=KEY_E
 ev.pressed=true
 Input.parse_input_event(ev)
 await tick()
 ev=InputEventKey.new()
 ev.keycode=KEY_E
 ev.pressed=false
 Input.parse_input_event(ev)
 await tick()
func wait_transition() -> void:
 for i: int in range(300):
  if chapter.busy: break
  await tick()
 while chapter.busy: await tick()
 for i: int in range(6): await tick()
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 hero=chapter.hero
 while chapter.busy or chapter.current_room<0: await tick()
 for id: int in range(12):
  var link_index: int=LINKS.index_in(id)
  var gate_checked: bool=link_index<0
  var link: Array=LINKS.LINKS[link_index] if link_index>=0 else []
  var gate_x: float=link[1] if link_index>=0 and id==link[0] else (link[3] if link_index>=0 else INF)
  for frame: int in range(3600):
   if not gate_checked and hero.global_position.x-AbbeyChapterLayout.origin(id).x>=gate_x-12:
    release_all()
    for settle: int in range(25):
     await tick()
     if hero.is_on_floor(): break
    var local: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
    if hero.is_on_floor() and local.distance_to(LINKS.point(id,gate_x))<24:
     gate_checked=true
     if id==link[0]:
      await press_e()
      check(not chapter.unlocked_shortcuts.has(link_index),"A%d bloqueado na primeira visita pelo lado inicial" % (link_index+1))
     else:
      if link_index==2: check(chapter.visits.has(9),"S10 visitado antes de desbloquear A3")
      await press_e()
      check(chapter.unlocked_shortcuts.has(link_index),"A%d aberto após progressão no lado avançado" % (link_index+1))
      await press_e()
      await wait_transition()
      check(chapter.current_room==link[0],"A%d travessia ao lado inicial por porta" % (link_index+1))
      await press_e()
      await wait_transition()
      check(chapter.current_room==id,"A%d retorno pela porta" % (link_index+1))
     if hero.survival.is_dead: break
   steer(1)
   if frame%2==0: Input.action_press("attack")
   else: Input.action_release("attack")
   await tick()
   if chapter.busy or chapter.current_room!=id or hero.survival.is_dead or (id==11 and chapter.completed): break
  release_all()
  check(gate_checked and not hero.survival.is_dead,"S%d alcançado, passagem e saída sem morte" % (id+1))
  if chapter.busy:
   while chapter.busy: await tick()
  if hero.survival.is_dead or (id<11 and chapter.current_room!=id+1):
   check(false,"Jornada interrompida em S%d, posição %s" % [id+1,hero.global_position-AbbeyChapterLayout.origin(id)])
   break
 check(chapter.completed and chapter.unlocked_shortcuts.size()==3,"Fim da jornada com três passagens abertas")
 print("M5-E lote 09 journey failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
