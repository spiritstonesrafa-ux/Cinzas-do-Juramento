extends SceneTree
## Supported local fixtures; input-driven approach, jump, and return with threats active.
const DETAILS: Script=preload("res://scripts/abbey/m5e_discoveries.gd")
var chapter: Node2D
var hero: KnightController
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void:
 await physics_frame
 await process_frame
func check(ok: bool, message: String) -> void:
 print(("PASS " if ok else "FAIL ")+message)
 if not ok: failures+=1
func release() -> void:
 for a: String in ["move_left","move_right","jump","attack"]: Input.action_release(a)
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 for id: int in [2,4,6,8,9]:
  await chapter.switch_room(id)
  var spot: Vector2=DETAILS.location(id)
  var origin: Vector2=AbbeyChapterLayout.origin(id)
  var floor_y: float=INF
  for r: Rect2 in AbbeyChapterLayout.main_surfaces(id):
   if spot.x-50>=r.position.x and spot.x-50<r.end.x: floor_y=r.position.y
  var start: Vector2=origin+Vector2(spot.x-50,floor_y)
  check(hero.is_respawn_safe(start),"S%d apoio da fixture" % (id+1))
  hero.reset_to(start)
  for frame: int in range(100): await tick()
  Input.action_press("move_right")
  for frame: int in range(90):
   await tick()
   if hero.global_position.x-origin.x>=spot.x-10 or hero.survival.is_dead: break
  Input.action_release("move_right")
  check(not chapter.m5e_discovered.has(id),"S%d passagem sem leitura automática" % (id+1))
  for frame: int in range(45): await tick()
  check(chapter.hint.text==DETAILS.DATA[id].text,"S%d observação parada exibe inscrição" % (id+1))
  chapter.m5e_discovered.erase(id)
  print("S",id+1," BEFORE jump ",hero.global_position-origin," target=",spot," grounded=",hero.is_on_floor())
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var shown: bool=false
  for frame: int in range(60):
   await tick()
   if chapter.hint.text==DETAILS.DATA[id].text:
    shown=true
    if OS.has_environment("CINZAS_M5E_LOTE02"):
     await RenderingServer.frame_post_draw
     var path: String=OS.get_environment("CINZAS_M5E_LOTE02")+"/setor-%02d.png" % (id+1)
     check(root.get_texture().get_image().save_png(path)==OK,"S%d captura" % (id+1))
    break
  check(shown and chapter.m5e_discovered.has(id),"S%d inscrição acionada por salto real" % (id+1))
  check(not hero.survival.is_dead and chapter.current_room==id,"S%d ameaça ativa sem interrupção" % (id+1))
  Input.action_press("move_left")
  for frame: int in range(100):
   await tick()
   if hero.global_position.x-origin.x<spot.x-35 and hero.is_on_floor(): break
  release()
  check(hero.global_position.x-origin.x<spot.x-35 and hero.is_on_floor() and not hero.survival.is_dead,"S%d retorno físico" % (id+1))
  check(chapter.camera.position.distance_to(chapter.camera_target())<60,"S%d câmera acompanha" % (id+1))
 check(chapter.checkpoints.size()==7,"Sete checkpoints preservados")
 print("M5-E lote 02 failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
