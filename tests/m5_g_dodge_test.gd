extends SceneTree
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame; await process_frame
func check(v: bool, label: String) -> void:
 print(("PASS " if v else "FAIL ")+label)
 if not v: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(11)
 chapter.hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 if not chapter.arena_active: print("FAIL arena");quit(1);return
 var hero: KnightController=chapter.hero
 var boss: Node=chapter.room.boss
 hero.reset_to(chapter.ARENA_ORIGIN+Vector2(80,156))
 boss.position=Vector2(150,156)
 boss.phase=2;boss.attacks=1;boss._state(boss.State.PURSUIT,0)
 var jumped: bool=false
 var active_seen: bool=false
 var start_health: int=hero.survival.current_health
 var first: float=boss.position.x
 for n: int in range(300):
  if boss.state==boss.State.WARNING and boss.pattern==boss.Pattern.DASH and boss.remaining<=0.20 and not jumped:
   Input.action_press("jump");jumped=true
  else: Input.action_release("jump")
  await tick()
  if jumped and n%6==0: print("TRACE frame=",n," state=",boss.state," remain=",boss.remaining," hero=",hero.global_position-chapter.ARENA_ORIGIN," boss=",boss.position," hp=",hero.survival.current_health)
  if boss.state==boss.State.ACTIVE and boss.pattern==boss.Pattern.DASH: active_seen=true
  if active_seen and boss.state==boss.State.RECOVER: break
 Input.action_release("jump")
 check(not hero.dash_unlocked,"jogador sem dash no ensaio")
 check(jumped and active_seen,"aviso e dash observados")
 check(absf(boss.position.x-first)>5,"avanço físico do chefe")
 check(hero.survival.current_health==start_health,"salto evita dano no caso ensaiado")
 check(boss.state==boss.State.RECOVER and not boss.source.active,"hitbox encerrada na recuperação")
 print("M5G dodge failures=",failures," hero_hp=",hero.survival.current_health," boss_x=",boss.position.x)
 chapter.queue_free()
 for n: int in range(120): await tick()
 quit(1 if failures else 0)
