extends SceneTree
## Live S2 entry and optional route; only normal player inputs after room entry.
var chapter: Node2D
var hero: KnightController
var failures: int=0
var capture_dir: String=""
var capture_size: Vector2i=Vector2i.ZERO
var measuring: bool=false
var path_length: float=0.0
var last_position: Vector2
var branch_tracking: bool=false
var branch_distance: float=0.0
var branch_horizontal: float=0.0
var branch_previous: Vector2
var camera_max: Vector2=Vector2.ZERO
var camera_clips: int=0
func _initialize() -> void:
 run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
 if branch_tracking:
  var step: Vector2=hero.global_position-branch_previous
  branch_distance+=step.length()
  branch_horizontal+=absf(step.x)
  branch_previous=hero.global_position
  var camera_delta: Vector2=(hero.global_position-chapter.camera.get_screen_center_position()).abs()
  camera_max=camera_max.max(camera_delta)
  if camera_delta.x>154 or camera_delta.y>85: camera_clips+=1
 if measuring:
  path_length+=hero.global_position.distance_to(last_position)
  last_position=hero.global_position
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
 for i: int in range(3):
  var edge: float=768 if i==0 else AbbeyPilotLayout.OPTIONAL[i-1].end.x
  Input.action_press("move_right")
  for step: int in range(120):
   if local().x>=edge-12: break
   await tick()
  if i==0:
   measuring=true
   last_position=hero.global_position
   branch_tracking=true
   branch_previous=hero.global_position
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
 measuring=false
 print("O1 exclusive outbound physics length=",path_length," end=",local())
 check(chapter.discovered,"Votos sem Nome alcançado pela rota superior")
 var added: Array[Rect2]=[Rect2(968,60,48,12),Rect2(1028,84,48,12),Rect2(1088,108,120,12)]
 for i: int in range(3):
  var edge: float=AbbeyPilotLayout.OPTIONAL[2].end.x if i==0 else added[i-1].end.x
  Input.action_press("move_right")
  for frame: int in range(100):
   if local().x>=edge-13: break
   await tick()
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var landed: bool=false
  for frame: int in range(100):
   await tick()
   var p: Vector2=local()
   if p.x>=added[i].get_center().x-5: Input.action_release("move_right")
   if hero.is_on_floor() and absf(p.y-added[i].position.y)<0.5 and p.x>added[i].position.x+6 and p.x<added[i].end.x-6:
    landed=true
    break
  release()
  check(landed,"Galeria capela: salto físico %d" % (i+1))
  for frame: int in range(3): await tick()
 check(chapter.chapel_discovered and chapter.hint.text.contains("Capela dos nomes"),"Inscrição da capela encontrada")
 if OS.has_environment("CINZAS_M5E_CAPTURES"):
  var directory: String=OS.get_environment("CINZAS_M5E_CAPTURES")
  DirAccess.make_dir_recursive_absolute(directory)
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   DisplayServer.window_set_size(size)
   for frame: int in range(10): await process_frame
   await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   check(img.get_size()==size and img.save_png(directory+"/capela-%dx%d.png" % [size.x,size.y])==OK,"Captura da capela %s" % size)
 # Descend at the far edge to reconnect to the main route without teleporting.
 Input.action_press("move_right")
 var descended: bool=false
 var descent_start: Vector2=hero.global_position
 for frame: int in range(180):
  await tick()
  if local().x>1216: Input.action_release("move_right")
  if hero.is_on_floor() and absf(local().y-228)<0.5:
   descended=true
   break
 release()
 branch_tracking=false
 print("METRICS O1 trace physical=",branch_distance," horizontal repeated=",branch_horizontal," launch_x=756 landing_x=",local().x)
 check(camera_clips==0,"Câmera mantém Aren visível ao longo da ramificação")
 print("CAMERA O1 max_delta=",camera_max," clips=",camera_clips)
 check(descended and not hero.survival.is_dead,"Circuito retorna ao corredor pela descida direita")
 print("O1 exit p=",local()," from=",descent_start-AbbeyChapterLayout.origin(1))
 Input.action_press("move_left")
 for frame: int in range(160):
  await tick()
  if is_instance_valid(hero.active_checkpoint): break
 release()
 check(is_instance_valid(hero.active_checkpoint),"Checkpoint alcançado após a descida")
 # Walk to the existing CP using ordinary movement and leave the optional route.
 Input.action_press("move_right")
 for i: int in range(500):
  await tick()
  if is_instance_valid(hero.active_checkpoint) or hero.survival.is_dead: break
 release()
 check(is_instance_valid(hero.active_checkpoint) and int(hero.active_checkpoint.get_meta("sector_id"))==1,"Checkpoint S2 ativado por contato")
 check(chapter.checkpoints.size()==7 and chapter.current_room==1,"Sete checkpoints e progressão preservados")
 Input.action_press("move_right")
 for frame: int in range(300):
  await tick()
  if chapter.busy or chapter.current_room!=1 or hero.survival.is_dead: break
 release()
 while chapter.busy: await tick()
 check(chapter.current_room==2 and not hero.survival.is_dead,"Continuação física para o setor 3")
 print("M5-E lote 01: failures=",failures," local=",local())
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
