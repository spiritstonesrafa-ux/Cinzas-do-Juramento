extends SceneTree
## S10 legitimate entry, live threats, physical annex and return; no resets in route.
var chapter: Node2D
var hero: KnightController
var failures: int=0
var camera_clips: int=0
var record: bool=false
var distance: float=0.0
var horizontal: float=0.0
var previous: Vector2
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
 if record:
  var d: Vector2=hero.global_position-previous
  distance+=d.length()
  horizontal+=absf(d.x)
  previous=hero.global_position
  var camera_delta: Vector2=(hero.global_position-chapter.camera.get_screen_center_position()).abs()
  if camera_delta.x>154 or camera_delta.y>85: camera_clips+=1
func local() -> Vector2: return hero.global_position-AbbeyChapterLayout.origin(9)
func check(ok: bool, message: String) -> void:
 print(("PASS " if ok else "FAIL ")+message)
 if not ok: failures+=1
func release() -> void:
 for a: String in ["move_left","move_right","jump","attack"]: Input.action_release(a)
func steer() -> void:
 Input.action_release("jump")
 Input.action_press("move_right")
 if hero.is_on_floor():
  var p: Vector2=hero.global_position
  var world: PhysicsDirectSpaceState2D=hero.get_world_2d().direct_space_state
  var wall: Dictionary=world.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(0,-16),p+Vector2(8,-16),1))
  var floor_ahead: Dictionary=world.intersect_ray(PhysicsRayQueryParameters2D.create(p+Vector2(13,-2),p+Vector2(13,32),1))
  if not wall.is_empty() or floor_ahead.is_empty(): Input.action_press("jump")
 for hazard: Node2D in chapter.room.encounters.hazards:
  var strike_center: float=hazard.global_position.x+(38 if hazard.family==2 else 0)
  var distance_to: float=strike_center-hero.global_position.x
  var hold: float=[64.0,24.0,43.0][hazard.family]
  if distance_to>=hold and distance_to<hold+25 and absf(hazard.global_position.y-hero.global_position.y)<60 and hazard.state in [1,2]:
   Input.action_release("move_right")
   Input.action_release("jump")
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(9)
 hero=chapter.hero
 check(chapter.room.encounters.enemies.size()>0 and chapter.room.encounters.hazards.size()>0,"Ameaças do Jardim instaladas")
 for i: int in range(3000):
  steer()
  if i%2==0: Input.action_press("attack")
  else: Input.action_release("attack")
  await tick()
  if local().x>=1170 or hero.survival.is_dead or chapter.current_room!=9: break
 release()
 check(local().x>=1170 and not hero.survival.is_dead and chapter.current_room==9,"Entrada até bifurcação com ameaças ativas")
 # Enter by a normal jump, avoiding the ordinary grounded sector exit.
 previous=hero.global_position
 record=true
 Input.action_press("move_right")
 Input.action_press("jump")
 await tick()
 Input.action_release("jump")
 for i: int in range(300):
  await tick()
  if chapter.garden_mirador_discovered or hero.survival.is_dead or chapter.current_room!=9: break
 release()
 check(chapter.garden_annex and chapter.garden_mirador_discovered and chapter.current_room==9,"Acesso físico e descoberta no mirante")
 check(chapter.hint.text.contains("Mirante"),"Mensagem do mirante")
 print("ANNEX destination=",local()," trace=",distance," horizontal=",horizontal)
 if OS.has_environment("CINZAS_M5E_LOTE07"):
  var dir: String=OS.get_environment("CINZAS_M5E_LOTE07")
  DirAccess.make_dir_recursive_absolute(dir)
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   DisplayServer.window_set_size(size)
   for frame: int in range(10): await process_frame
   await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   check(img.get_size()==size and img.save_png(dir+"/mirante-%dx%d.png" % [size.x,size.y])==OK,"Captura do mirante %s" % size)
 var outbound: float=distance
 Input.action_press("move_left")
 for i: int in range(400):
  await tick()
  if not chapter.garden_annex or hero.survival.is_dead or chapter.current_room!=9: break
 release()
 record=false
 check(not chapter.garden_annex and chapter.current_room==9 and local().x<1180,"Retorno físico ao corredor")
 check(camera_clips==0,"Câmera acompanha o percurso opcional")
 print("ANNEX return_distance=",distance-outbound," total=",distance," camera_clips=",camera_clips)
 Input.action_press("move_right")
 for i: int in range(150):
  await tick()
  if chapter.busy or chapter.current_room!=9: break
 release()
 while chapter.busy: await tick()
 check(chapter.current_room==10 and not hero.survival.is_dead,"Saída normal para S11 após retorno")
 check(chapter.checkpoints.size()==7,"Sete checkpoints preservados")
 print("M5-E lote 07 O6 failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
