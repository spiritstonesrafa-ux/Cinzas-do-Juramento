extends "res://tests/m5_e_lote07_o6_test.gd"
## Five full sector-entry journeys. A one-frame jump must keep the normal exit.
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 for id: int in [2,4,6,8,9]:
  await chapter.switch_room(id)
  var origin: Vector2=AbbeyChapterLayout.origin(id)
  var start_x: float=AbbeyChapterLayout.WIDTHS[id]-48
  for i: int in range(3000):
   steer()
   if i%2==0: Input.action_press("attack")
   else: Input.action_release("attack")
   await tick()
   if hero.global_position.x-origin.x>=start_x or hero.survival.is_dead or chapter.current_room!=id: break
  release()
  check(chapter.current_room==id and not hero.survival.is_dead and hero.global_position.x-origin.x>=start_x,"S%d aproximação real ao limiar" % (id+1))
  check(chapter.hint.text.contains("Segure salto"),"S%d indicação contextual de entrada" % (id+1))
  Input.action_press("move_right")
  Input.action_press("jump")
  await tick()
  Input.action_release("jump")
  var diverted: bool=false
  for frame: int in range(180):
   await tick()
   diverted=diverted or chapter.forge_annex or chapter.archive_annex or chapter.garden_annex or chapter.stair_annex or chapter.cistern_annex
   if chapter.busy or chapter.current_room!=id or hero.survival.is_dead: break
  release()
  while chapter.busy: await tick()
  check(not diverted and chapter.current_room==id+1 and not hero.survival.is_dead,"S%d toque breve segue saída sem desvio" % (id+1))
 print("M5-E lote08 short taps failures=",failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
