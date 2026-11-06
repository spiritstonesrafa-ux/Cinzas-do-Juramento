extends SceneTree
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame; await process_frame
func check(v: bool,label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(11)
 var hero: KnightController=chapter.hero
 var cp: RespawnCheckpoint=chapter.checkpoints[-1]
 hero.activate_checkpoint(cp)
 check(hero.active_checkpoint==cp,"CP7 ativado no setor 12")
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 check(chapter.arena_active,"entrada em arena")
 hero.receive_damage(999)
 for n: int in range(3000):
  await tick()
  if not hero.survival.is_dead and not chapter.busy and chapter.current_room==11: break
 check(not hero.survival.is_dead and chapter.current_room==11 and hero.active_checkpoint==cp,"morte retorna ao CP7 com setor carregado")
 check(not hero.dash_unlocked,"derrota não concede dash")
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 check(chapter.arena_active and chapter.room.boss.health==10,"reentrada reinicia Abade")
 print("M5G respawn failures=",failures)
 chapter.queue_free()
 for n: int in range(120): await tick()
 quit(1 if failures else 0)
