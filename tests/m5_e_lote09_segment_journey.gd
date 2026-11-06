extends "res://tests/m5_c3_journey_test.gd"
## Fresh scene per link; real input from earlier sector entry through advanced gate.
const LINKS: Script=preload("res://scripts/abbey/m5e_shortcuts.gd")
var failures: int=0
var captured: Dictionary = {}
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
func await_transition() -> void:
 for i: int in range(120):
  if chapter.busy: break
  await tick()
 while chapter.busy: await tick()
 for i: int in range(6): await tick()
func cross_passage(side: int) -> float:
 for n: int in range(240):
  if chapter.passage_index>=0 and not chapter.busy: break
  await tick()
 if chapter.passage_index<0 or chapter.busy: return -1.0
 var gate_index: int=chapter.passage_index
 var start: Vector2=hero.global_position
 var distance: float=0
 var previous: Vector2=start
 Input.action_press("move_right" if side>0 else "move_left")
 for n: int in range(1000):
  await tick()
  if chapter.passage_index<0: break
  if not captured.has(gate_index) and absf(hero.global_position.x-chapter.passage_origin.x - chapter.room.WIDTHS[gate_index]/2.0)<4.0 and DisplayServer.get_name() != "headless":
   captured[gate_index]=true
   Input.action_release("move_right" if side>0 else "move_left")
   hero.process_mode=Node.PROCESS_MODE_DISABLED
   for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
    DisplayServer.window_set_size(size)
    for wait_frame: int in range(5): await process_frame
    await RenderingServer.frame_post_draw
    get_root().get_texture().get_image().save_png("res://tests/evidencias/m5_e_lote09_A%d_%dx%d.png" % [gate_index+1,size.x,size.y])
   hero.process_mode=Node.PROCESS_MODE_INHERIT
   Input.action_press("move_right" if side>0 else "move_left")
  distance+=hero.global_position.distance_to(previous)
  previous=hero.global_position
 Input.action_release("move_right" if side>0 else "move_left")
 while chapter.busy: await tick()
 for n: int in range(6): await tick()
 return distance
func walk_normal_return(link: Array) -> float:
 var distance: float=0.0
 for id: int in range(link[2],link[0]-1,-1):
  for frame: int in range(3600):
   if chapter.current_room!=id or chapter.busy or hero.survival.is_dead: break
   var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
   if id==link[0] and p.x<=link[1]+10:
    release_all()
    for j: int in range(25):
     await tick()
     if hero.is_on_floor(): break
    break
   var before: Vector2=hero.global_position
   steer(-1)
   for hazard: Node2D in chapter.room.encounters.hazards:
    var strike_center: float=hazard.global_position.x+(38 if hazard.family==2 else 0)
    var separation: float=(strike_center-hero.global_position.x)*-1
    var hold: float=[64.0,24.0,43.0][hazard.family]
    if separation>=hold and separation<hold+25 and absf(hazard.global_position.y-hero.global_position.y)<60 and hazard.state in [1,2]:
     Input.action_release("move_left")
     Input.action_release("jump")
   if frame%2==0: Input.action_press("attack")
   else: Input.action_release("attack")
   await tick()
   if chapter.current_room==id and not chapter.busy:
    distance+=hero.global_position.distance_to(before)
  release_all()
  while chapter.busy: await tick()
  if hero.survival.is_dead:
   print("NORMAL FAILED: death S",id+1," position=",hero.global_position-AbbeyChapterLayout.origin(id))
   return -1.0
  if id>link[0] and chapter.current_room!=id-1:
   print("NORMAL FAILED: room=",chapter.current_room," expected=",id-1," local=",hero.global_position-AbbeyChapterLayout.origin(id))
   return -1.0
 return distance
func complete_and_return_to_gate(id: int, x_gate: float) -> bool:
 # Finish the advanced sector, enter its successor, and physically return.
 for frame: int in range(3600):
  steer(1)
  if frame%2==0: Input.action_press("attack")
  else: Input.action_release("attack")
  await tick()
  if chapter.busy or chapter.current_room!=id or hero.survival.is_dead: break
 release_all()
 while chapter.busy: await tick()
 if chapter.current_room!=id+1 or hero.survival.is_dead: return false
 Input.action_press("move_left")
 for frame: int in range(120):
  await tick()
  if chapter.busy or chapter.current_room!=id+1: break
 release_all()
 while chapter.busy: await tick()
 if chapter.current_room!=id: return false
 for frame: int in range(3600):
  var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
  if p.x<=x_gate+12:
   release_all()
   for j: int in range(30):
    await tick()
    if hero.is_on_floor(): break
   return (hero.global_position-AbbeyChapterLayout.origin(id)).distance_to(LINKS.point(id,x_gate))<24 and not hero.survival.is_dead
  steer(-1)
  if frame%2==0: Input.action_press("attack")
  else: Input.action_release("attack")
  await tick()
  if hero.survival.is_dead or chapter.current_room!=id: break
 release_all()
 return false
func run() -> void:
 for index: int in range(3):
  chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
  root.add_child(chapter)
  hero=chapter.hero
  while chapter.busy or chapter.current_room<0: await tick()
  var link: Array=LINKS.LINKS[index]
  await chapter.switch_room(link[0])
  var segment_ok: bool=true
  for id: int in range(link[0],link[2]+1):
   var at_gate: bool=id!=link[0] and id!=link[2]
   var x_gate: float=link[1] if id==link[0] else (link[3] if id==link[2] else INF)
   for frame: int in range(3600):
    if not at_gate and hero.global_position.x-AbbeyChapterLayout.origin(id).x>=x_gate-12:
     release_all()
     for j: int in range(25):
      await tick()
      if hero.is_on_floor(): break
     var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
     if hero.is_on_floor() and p.distance_to(LINKS.point(id,x_gate))<24:
      at_gate=true
      if id==link[0]:
       await press_e()
       check(not chapter.unlocked_shortcuts.has(index),"A%d lado inicial bloqueado na travessia real" % (index+1))
      else:
       if index==2: check(chapter.visits.has(9),"A3 passou S10 antes do desbloqueio")
       await press_e()
       check(not chapter.unlocked_shortcuts.has(index),"A%d permanece fechado antes da saída do setor avançado" % (index+1))
       var completed: bool=await complete_and_return_to_gate(id,x_gate)
       check(completed and chapter.forward_completed.has(id),"A%d setor avançado concluído e retorno real ao portão" % (index+1))
       if not completed:
        segment_ok=false
        break
       await press_e()
       check(chapter.unlocked_shortcuts.has(index),"A%d desbloqueio após trecho real" % (index+1))
       var normal: float=await walk_normal_return(link)
       check(normal>0 and chapter.current_room==link[0],"A%d retorno normal medido fisicamente" % (index+1))
       if normal<=0 or chapter.current_room!=link[0]:
        segment_ok=false
        break
       await press_e()
       var path_back: float=await cross_passage(1)
       check(path_back>100 and chapter.current_room==link[2],"A%d volta pela porta" % (index+1))
       await press_e()
       var path_out: float=await cross_passage(-1)
       check(path_out>100 and chapter.current_room==link[0],"A%d ida pela porta" % (index+1))
       await press_e()
       var path_again: float=await cross_passage(1)
       check(path_again>100 and chapter.current_room==link[2],"A%d retorno repetido pela porta" % (index+1))
       print("A%d DISTANCES normal=%.2f corridor_back=%.2f corridor_out=%.2f repeated=%.2f" % [index+1,normal,path_back,path_out,path_again])
       break
    steer(1)
    if frame%2==0: Input.action_press("attack")
    else: Input.action_release("attack")
    await tick()
    if hero.survival.is_dead or chapter.busy or chapter.current_room!=id: break
   release_all()
   if chapter.busy:
    while chapter.busy: await tick()
   if not at_gate or hero.survival.is_dead or (id<link[2] and chapter.current_room!=id+1):
    check(false,"A%d segmento interrompido S%d posição %s HP=%d" % [index+1,id+1,hero.global_position-AbbeyChapterLayout.origin(id),hero.survival.current_health])
    segment_ok=false
    break
  check(segment_ok,"A%d trecho físico com ameaças ativas" % (index+1))
  chapter.queue_free()
  await tick()
 print("Lote09 segment journeys failures=",failures)
 quit(1 if failures else 0)
