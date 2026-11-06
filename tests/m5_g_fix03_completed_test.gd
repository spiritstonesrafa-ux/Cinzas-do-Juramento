extends SceneTree
## Requires a profile created by the controls-driven fresh campaign test.
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n): await physics_frame; await process_frame
func check(value: bool,label: String) -> void:
 print(("PASS " if value else "FAIL ")+label)
 if not value: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 var hero: KnightController=chapter.hero
 check(hero.dash_unlocked,"dash reconhecido ao reabrir")
 await chapter.switch_room(11)
 var cp: Node=chapter.checkpoints[6]
 hero.reset_to(cp.global_position)
 await tick(15)
 check(hero.active_checkpoint==cp,"checkpoint 7 ativado")
 hero.receive_damage(1)
 var hp: int=hero.survival.current_health
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for i: int in range(180):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 check(chapter.arena_active and chapter.abbot_won and chapter.completed,"entrada física em arena já concluída")
 if chapter.arena_active:
  check(chapter.room.boss.health==0 and chapter.room.boss.state==chapter.room.boss.State.DEFEATED and not chapter.room.boss.source.active,"Abade continua derrotado e sem dano")
  check(hero.survival.current_health==hp and hero.active_checkpoint==cp and hero.dash_unlocked,"HP, checkpoint e dash preservados na entrada")
  var ev: InputEventKey=InputEventKey.new();ev.keycode=KEY_E;ev.pressed=true;Input.parse_input_event(ev)
  await tick()
  ev=InputEventKey.new();ev.keycode=KEY_E;ev.pressed=false;Input.parse_input_event(ev)
  for i: int in range(300):
   await tick()
   if chapter.current_room==11 and not chapter.busy and not chapter.arena_active: break
  check(chapter.current_room==11 and not chapter.arena_active and hero.survival.current_health==hp and hero.active_checkpoint==cp,"retorno ao Coro preserva estado")
  await tick(30)
  check(chapter.current_room==11 and not chapter.arena_active,"retorno não reentra automaticamente")
  check(not chapter.hint.text.contains("M5-B"),"mensagem provisória não aparece")
 print("M5G FIX03 completed failures=",failures)
 chapter.queue_free(); await tick(90); quit(1 if failures else 0)
