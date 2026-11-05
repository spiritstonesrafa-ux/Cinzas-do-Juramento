extends SceneTree

var chapter: Node2D
var failures: int = 0
var checks: int = 0

func _initialize() -> void:
 run.call_deferred()

func tick() -> void:
 await physics_frame
 await process_frame

func check(ok: bool, label: String) -> void:
 checks += 1
 if not ok: failures += 1
 print("PASS: " if ok else "FAIL: ", label)

func fire() -> Node2D:
 var enemy: ChainedMonk = chapter.room.encounters.enemies[0]
 chapter.hero.reset_to(enemy.global_position + Vector2(-55, 0))
 chapter.camera.position = chapter.camera_target()
 chapter.camera.force_update_scroll()
 for frame in range(100):
  await tick()
  var missile: Node2D = enemy.get("missile")
  if is_instance_valid(missile):
   return missile
 return null

func run() -> void:
 chapter = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room < 0: await tick()
 var hero: KnightController = chapter.hero
 var hud: Node = chapter.get_node("HealthHUD")
 var death_connections: int = hero.survival.died.get_connections().size()
 for i in range(24):
  await chapter.switch_room(3, false, true)
  hero.survival.restore()
  var room: WeakRef = weakref(chapter.room)
  var missile: Node2D = await fire()
  check(is_instance_valid(missile), "S4 real acolyte shot %d" % i)
  if not is_instance_valid(missile):
   break
  var shot: WeakRef = weakref(missile)
  var initial_x: float = missile.global_position.x
  await tick()
  check(is_instance_valid(missile) and missile.global_position.x < initial_x, "Shot moves toward Aren %d" % i)
  if i == 0:
   var hp: int = hero.survival.current_health
   for frame in range(65):
    await tick()
    if shot.get_ref() == null: break
   check(hero.survival.current_health == hp - 1 and shot.get_ref() == null, "Actual hurtbox contact deals exactly one and consumes shot")
  elif i == 1:
   hero.reset_to(AbbeyChapterLayout.origin(3) + AbbeyChapterLayout.entry(3))
   for frame in range(110):
    await tick()
    if shot.get_ref() == null: break
   check(hero.survival.current_health == 5 and shot.get_ref() == null, "Miss is removed without damaging Aren")
  elif i == 2:
   hero.receive_damage(999)
   await tick()
   check(hero.survival.is_dead and shot.get_ref() == null, "Death removes live shot")
   for frame in range(6000):
    if not hero.survival.is_dead and not chapter.busy: break
    await tick()
   check(not hero.survival.is_dead and hero.survival.current_health == 5, "Respawn after projectile cleanup")
  await chapter.switch_room(4, false, true)
  await tick()
  check(room.get_ref() == null and shot.get_ref() == null, "Room and projectile freed %d" % i)
  check(chapter.get_node("Rooms").get_child_count() == 1 and chapter.hero == hero and chapter.get_node("HealthHUD") == hud and hero.survival.died.get_connections().size() == death_connections, "Single room and stable persistent identities/signals %d" % i)
  if i in [5, 23]:
   print("COUNTS cycle=", i+1, " objects=", Performance.get_monitor(Performance.OBJECT_COUNT), " nodes=", Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
 await chapter.switch_room(2, false, true)
 var active_room: WeakRef = weakref(chapter.room)
 var pendulum: Node2D = chapter.room.encounters.hazards[0]
 for frame in range(220):
  if pendulum.state == 2: break
  await tick()
 check(pendulum.state == 2 and not pendulum.shape.disabled, "Pêndulo chega a fase ativa com colisão ligada")
 var danger: WeakRef = weakref(pendulum.shape)
 await chapter.switch_room(3, false, true)
 await tick()
 check(active_room.get_ref() == null and danger.get_ref() == null, "Descarga libera a hitbox ativa")
 var acolyte: ChainedMonk = chapter.room.encounters.enemies[0]
 hero.reset_to(acolyte.global_position + Vector2(-55, 0))
 chapter.camera.position = chapter.camera_target()
 chapter.camera.force_update_scroll()
 for frame in range(30):
  if acolyte.state == ChainedMonk.State.WARNING: break
  await tick()
 check(acolyte.state == ChainedMonk.State.WARNING, "Acólito prepara ataque por IA real")
 var pending: WeakRef = weakref(acolyte)
 await chapter.switch_room(4, false, true)
 for frame in range(80): await tick()
 check(pending.get_ref() == null and chapter.room.encounters.get_child_count() == 2, "Preparação descarregada sem disparo na sala seguinte")
 print("FIX02 lifecycle checks=", checks, " failures=", failures)
 chapter.queue_free()
 await tick()
 quit(1 if failures else 0)
