extends SceneTree
var failures: int = 0
var checks: int = 0
func _initialize() -> void: run.call_deferred()
func check(ok: bool, label: String) -> void:
 checks += 1
 if ok: print("PASS: ", label)
 else:
  failures += 1
  printerr("FAIL: ", label)
func frames(n: int) -> void:
 for i in range(n):
  await physics_frame
  await process_frame
func wait_room(chapter: Node2D) -> void:
 var started: int = Time.get_ticks_msec()
 while (chapter.busy or chapter.current_room < 0) and Time.get_ticks_msec()-started < 15000:
  await process_frame
func run() -> void:
 var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 await frames(2)
 await wait_room(chapter)
 for id in range(12):
  if id != 0:
   await chapter.switch_room(id)
  await frames(3)
  var room: Node2D = chapter.room
  var encounters: Node2D = room.encounters
  var expected: Array = encounters.PLACEMENTS[id]
  check(chapter.current_room == id and chapter.get_node("Rooms").get_child_count() == 1, "sector %d resident alone" % (id+1))
  check(encounters.enemies.size()+encounters.hazards.size() == expected.size(), "sector %d placement count" % (id+1))
  for record: Array in expected:
   var surface: Rect2 = AbbeyChapterLayout.main_surfaces(id)[record[2]]
   check(record[1] > surface.position.x and record[1] < surface.end.x, "sector %d support %s" % [id+1, record[0]])
   check(record[1] > 180 and record[1] < AbbeyChapterLayout.WIDTHS[id]-180, "sector %d entry clearance %s" % [id+1,record[0]])
   if id in AbbeyChapterLayout.CP_SECTORS:
    check(absf(float(record[1])-AbbeyChapterLayout.checkpoint_position(id).x)>180, "sector %d checkpoint clearance" % (id+1))
  for enemy: ChainedMonk in encounters.enemies:
   check(enemy.target == chapter.hero, "sector %d enemy targets Aren" % (id+1))
  for hazard: Node2D in encounters.hazards:
   check(hazard.target == chapter.hero, "sector %d hazard targets Aren" % (id+1))
  var hp: int = chapter.hero.survival.current_health
  await frames(45)
  check(chapter.hero.survival.current_health == hp, "sector %d entry remains safe for 45 physics frames" % (id+1))
  room.disarm()
  room.reset_encounters()
  await frames(2)
  for enemy: ChainedMonk in encounters.enemies:
   check(enemy.process_mode != Node.PROCESS_MODE_DISABLED, "sector %d enemy rearmed" % (id+1))
  for hazard: Node2D in encounters.hazards:
   check(hazard.state == 0, "sector %d hazard reset safe" % (id+1))
 # Reverse entries use real physics frames with all threats enabled.
 for id in range(11, -1, -1):
  await chapter.switch_room(id, true, true)
  await frames(2)
  chapter.hero.survival.restore()
  var hp_before: int = chapter.hero.survival.current_health
  await frames(45)
  check(chapter.hero.survival.current_health == hp_before, "sector %d reverse entry safe" % (id+1))
 # Checkpoint positions are fixtures; ordinary damage and chapter respawn remain real.
 for cp: RespawnCheckpoint in chapter.checkpoints:
  var id: int = int(cp.get_meta("sector_id"))
  await chapter.switch_room(id, false, true)
  chapter.hero.survival.restore()
  chapter.hero.reset_to(cp.global_position)
  await frames(12)
  check(chapter.hero.active_checkpoint == cp, "checkpoint %d physically activated" % (id+1))
  chapter.hero.receive_damage(999)
  await frames(120)
  check(not chapter.hero.survival.is_dead and chapter.hero.survival.current_health == 5, "checkpoint %d death and respawn" % (id+1))
  check(chapter.current_room == id, "checkpoint %d respawns in owning sector" % (id+1))
 # Real sword collisions against one actual placement of each archetype.
 for id in [1,3,6,7]:
  await chapter.switch_room(id, false, true)
  await frames(4)
  chapter.hero.survival.restore()
  var enemy: ChainedMonk = chapter.room.encounters.enemies[0]
  chapter.hero.reset_to(enemy.global_position + Vector2(-24,0))
  chapter.hero.facing = 1
  chapter.camera.position = chapter.camera_target()
  chapter.camera.force_update_scroll()
  await frames(3)
  enemy.set_state(ChainedMonk.State.RECOVER,5.0)
  var initial_hp: int = enemy.current_health
  for hit in range(initial_hp):
   Input.action_press("attack")
   await frames(1)
   Input.action_release("attack")
   await frames(28)
  check(enemy.state == ChainedMonk.State.DEAD, "sector %d sword defeats actual placed enemy" % (id+1))
 print("M5-C3 checks: %d failures: %d" % [checks, failures])
 chapter.queue_free()
 await frames(2)
 quit(1 if failures else 0)
