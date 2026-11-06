extends SceneTree
const PROGRESS: Script=preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: run.call_deferred()
func tick() -> void: await physics_frame;await process_frame
func run() -> void:
 var chapter: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 await chapter.switch_room(11)
 var hero: KnightController=chapter.hero
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for n: int in range(150):
  await tick()
  if chapter.arena_active and not chapter.busy: break
 Input.action_release("move_right")
 var boss: Node=chapter.room.boss
 boss.health=1;boss._state(boss.State.RECOVER,2.0)
 boss._hit()
 hero.receive_damage(999)
 for n: int in range(200): await tick()
 var ok: bool=not hero.dash_unlocked and not PROGRESS.unlocked()
 print("PASS derrota simultânea não concede recompensa" if ok else "FAIL recompensa em derrota simultânea")
 chapter.queue_free()
 for n: int in range(120): await tick()
 quit(0 if ok else 1)
