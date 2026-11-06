extends "res://tests/m5_e_lote07_o6_test.gd"
## Escadaria: same input/physics harness with a distinct ascending workshop.
func local() -> Vector2: return hero.global_position-AbbeyChapterLayout.origin(2)
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(2)
 hero=chapter.hero
 check(chapter.room.encounters.enemies.size()==0 and chapter.room.encounters.hazards.size()==1,"Ameaças da Escadaria instaladas")
 for i: int in range(3000):
  steer()
  if i%2==0: Input.action_press("attack")
  else: Input.action_release("attack")
  await tick()
  if local().x>=1168 or hero.survival.is_dead or chapter.current_room!=2: break
 release()
 check(local().x>=1168 and not hero.survival.is_dead and chapter.current_room==2,"Entrada até bifurcação com ameaças ativas")
 check(is_instance_valid(hero.active_checkpoint) and int(hero.active_checkpoint.get_meta("sector_id"))==2,"Checkpoint da Escadaria ativado")
 previous=hero.global_position
 record=true
 Input.action_press("move_right")
 Input.action_press("jump")
 await tick()
 for frame: int in range(120):
  await tick()
  if local().x>=1254: Input.action_release("move_right")
  if hero.is_on_floor() and local().x>=1224: break
 release()
 check(chapter.stair_annex and hero.is_on_floor() and local().x>=1224,"Entrada física no galeria")
 var floors: Array[Rect2]=[Rect2(1216,252,80,32),Rect2(1304,228,64,12),Rect2(1376,204,72,12)]
 for i: int in range(2):
  var src: Rect2=floors[i]
  var dest: Rect2=floors[i+1]
  Input.action_press("move_right")
  for frame: int in range(100):
   if local().x>=src.end.x-13: break
   await tick()
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var landed: bool=false
  for frame: int in range(100):
   await tick()
   if local().x>=dest.get_center().x-5: Input.action_release("move_right")
   if hero.is_on_floor() and absf(local().y-dest.position.y)<0.5 and local().x>dest.position.x+6:
    landed=true
    break
  release()
  check(landed,"Subida física %d" % (i+1))
  for frame: int in range(4): await tick()
 check(chapter.stair_discovered and chapter.hint.text.contains("Contrapeso partido"),"Descoberta do molde acessível")
 print("STAIR destination=",local()," outbound=",distance)
 if OS.has_environment("CINZAS_M5E_LOTE07"):
  var dir: String=OS.get_environment("CINZAS_M5E_LOTE07")
  DirAccess.make_dir_recursive_absolute(dir)
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   DisplayServer.window_set_size(size)
   for frame: int in range(10): await process_frame
   await RenderingServer.frame_post_draw
   var img: Image=root.get_texture().get_image()
   check(img.get_size()==size and img.save_png(dir+"/escadaria-%dx%d.png" % [size.x,size.y])==OK,"Captura do galeria %s" % size)
 var outbound: float=distance
 for i: int in range(2):
  var src: Rect2=floors[2-i]
  var dest: Rect2=floors[1-i]
  Input.action_press("move_left")
  for frame: int in range(100):
   if local().x<=src.position.x+13: break
   await tick()
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var landed: bool=false
  for frame: int in range(100):
   await tick()
   if local().x<=dest.get_center().x+5: Input.action_release("move_left")
   if hero.is_on_floor() and absf(local().y-dest.position.y)<0.5 and local().x<dest.end.x-6:
    landed=true
    break
  release()
  check(landed,"Retorno físico %d" % (i+1))
  for frame: int in range(4): await tick()
 Input.action_press("move_left")
 for frame: int in range(200):
  await tick()
  if not chapter.stair_annex: break
 release()
 record=false
 check(not chapter.stair_annex and chapter.current_room==2 and local().x<1180,"Retorno físico ao corredor")
 check(camera_clips==0,"Câmera acompanha o galeria")
 print("STAIR return=",distance-outbound," total=",distance," camera_clips=",camera_clips)
 Input.action_press("move_right")
 for frame: int in range(180):
  await tick()
  if chapter.busy or chapter.current_room!=2: break
 release()
 while chapter.busy: await tick()
 check(chapter.current_room==3 and not hero.survival.is_dead,"Saída normal para S4 após retorno")
 print("M5-E lote 07 O2 failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
