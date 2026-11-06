extends SceneTree
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame; await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter);current_scene=chapter
 while chapter.busy or chapter.current_room<0: await tick()
 var hero: KnightController=chapter.hero
 check(hero.dash_unlocked,"dash carregado em nova sessão")
 hero.receive_damage(999)
 for n: int in range(3000):
  await tick()
  if not hero.survival.is_dead and not chapter.busy: break
 check(not hero.survival.is_dead and hero.dash_unlocked,"morte e respawn mantêm dash")
 hero.global_position.y=AbbeyChapterLayout.bounds(chapter.current_room).end.y+140
 for n: int in range(500):
  await tick()
  if chapter.current_room==0 and not chapter.resetting and hero.global_position.y<400: break
 check(hero.dash_unlocked and chapter.current_room==0,"queda mantém dash")
 var old_id: int=chapter.get_instance_id()
 var ev: InputEventKey=InputEventKey.new();ev.keycode=KEY_F7;ev.pressed=true;Input.parse_input_event(ev)
 await tick()
 ev=InputEventKey.new();ev.keycode=KEY_F7;ev.pressed=false;Input.parse_input_event(ev)
 for n: int in range(3000):
  await tick()
  if is_instance_valid(current_scene) and current_scene.get_instance_id()!=old_id and current_scene.current_room>=0 and not current_scene.busy: break
 check(is_instance_valid(current_scene) and current_scene.get_instance_id()!=old_id and current_scene.hero.dash_unlocked,"F7 preserva habilidade desbloqueada")
 print("M5G session failures=",failures)
 for n: int in range(180): await tick()
 quit(1 if failures else 0)
