extends SceneTree
## Live S2 entry and optional route; only normal player inputs after room entry.
var chapter: Node2D
var hero: KnightController
var failures: int=0
var capture_dir: String=""
var capture_size: Vector2i=Vector2i.ZERO
func _initialize() -> void:
 run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func check(ok: bool, message: String) -> void:
 print(("PASS " if ok else "FAIL ")+message)
 if not ok: failures+=1
func release() -> void:
 for action: String in ["move_left","move_right","jump","attack"]: Input.action_release(action)
func local() -> Vector2:
 return hero.global_position-AbbeyChapterLayout.origin(1)
func capture(moment: String) -> void:
 if capture_dir.is_empty(): return
 await RenderingServer.frame_post_draw
 var img: Image=root.get_texture().get_image()
 var result: Error=img.save_png(capture_dir+"/%s-%dx%d.png" % [moment,capture_size.x,capture_size.y])
 check(result==OK and absf(hero.velocity.x)>1.0,"Captura em movimento %s %dx%d" % [moment,capture_size.x,capture_size.y])
 print("CAPTURE ",moment," p=",local()," velocity=",hero.velocity," floor=",hero.is_on_floor()," size=",img.get_size())
func run() -> void:
 if OS.has_environment("CINZAS_M5E_MOTION"):
  capture_dir=OS.get_environment("CINZAS_M5E_MOTION")
  DirAccess.make_dir_recursive_absolute(capture_dir)
  capture_size=Vector2i(int(OS.get_environment("CINZAS_WIDTH")),int(OS.get_environment("CINZAS_HEIGHT")))
  DisplayServer.window_set_size(capture_size)
  for frame: int in range(10): await process_frame
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(1)
 hero=chapter.hero
 check(chapter.room.encounters.enemies.size()==1 and chapter.room.encounters.enemies[0].target==hero,"Monge ativo e com alvo real")
 # Walk the main stairs from the real room entry, fighting the live monk.
 for i: int in range(1800):
  Input.action_press("move_right")
  Input.action_release("jump")
  var p: Vector2=hero.global_position
  var wall: Dictionary=hero.get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(0,-16),p+Vector2(8,-16),1))
  if hero.is_on_floor() and not wall.is_empty(): Input.action_press("jump")
  if i%3==0: Input.action_press("attack")
  else: Input.action_release("attack")
  await tick()
  if local().x>=710 and local().x<713 and not capture_dir.is_empty(): await capture("aproximacao")
  if local().x>=750 or hero.survival.is_dead: break
 release()
 check(local().x>=750 and not hero.survival.is_dead,"Acesso ao cruzamento por controles e encontro reais")
 for i: int in range(2):
  var edge: float=768 if i==0 else AbbeyPilotLayout.OPTIONAL[i-1].end.x
  Input.action_press("move_right")
  for step: int in range(120):
   if local().x>=edge-12: break
   await tick()
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var landed: bool=false
  for step: int in range(100):
   await tick()
   if i==1 and step==12 and not capture_dir.is_empty(): await capture("salto")
   var dest: Rect2=AbbeyPilotLayout.OPTIONAL[i]
   if hero.is_on_floor() and absf(local().y-dest.position.y)<0.3 and local().x>dest.position.x+8:
    landed=true
    break
  release()
  check(landed,"Salto e pouso físico no patamar %d" % (i+1))
  for step: int in range(3): await tick()
 if not capture_dir.is_empty():
  Input.action_press("move_left")
  for step: int in range(5): await tick()
  await capture("caminhada")
  release()
 for i: int in range(12): await tick()
 print("INSCRIPTION local=",local()," discovered=",chapter.names_relief_discovered," hint=",chapter.hint.text)
 check(chapter.names_relief_discovered and chapter.hint.text.contains("Nomes riscados"),"Inscrição distinta apresentada por proximidade")
 check(not chapter.discovered,"Votos sem Nome não foi ativado indevidamente")
 check(chapter.camera.position.distance_to(chapter.camera_target())<4,"Câmera acompanha a descoberta")
 if OS.has_environment("CINZAS_M5E_CAPTURES"):
  var directory: String=OS.get_environment("CINZAS_M5E_CAPTURES")
  DirAccess.make_dir_recursive_absolute(directory)
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   DisplayServer.window_set_size(size)
   for frame: int in range(10): await process_frame
   var img: Image=root.get_texture().get_image()
   var result: Error=img.save_png(directory+"/descoberta-%dx%d.png" % [size.x,size.y])
   check(result==OK,"Captura da descoberta %dx%d" % [size.x,size.y])
 Input.action_press("move_left")
 for i: int in range(180):
  await tick()
  if local().x<745 and hero.is_on_floor(): break
 release()
 check(local().x<745 and hero.is_on_floor() and not hero.survival.is_dead,"Retorno físico à rota principal")
 # Walk to the existing CP using ordinary movement and leave the optional route.
 Input.action_press("move_right")
 for i: int in range(500):
  await tick()
  if is_instance_valid(hero.active_checkpoint) or hero.survival.is_dead: break
 release()
 check(is_instance_valid(hero.active_checkpoint) and int(hero.active_checkpoint.get_meta("sector_id"))==1,"Checkpoint S2 ativado por contato")
 check(chapter.checkpoints.size()==7 and chapter.current_room==1,"Sete checkpoints e progressão preservados")
 print("M5-E lote 01: failures=",failures," local=",local())
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
