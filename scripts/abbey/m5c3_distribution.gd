extends Node2D
## Local coordinates on the homologated sector spine.
## Each record is [kind, x, surface index]; y comes from the existing geometry.
const PLACEMENTS: Array = [
 [["monk", 320, 2]],
 [["monk", 580, 5]],
 [["pendulum", 340, 4], ["monk", 600, 7]],
 [["acolyte", 550, 5], ["penitent", 900, 8]],
 [["sluice", 780, 9], ["acolyte", 950, 11], ["monk", 380, 4]],
 [["incense", 850, 0], ["monk", 450, 0]],
 [["watchman", 410, 4], ["pendulum", 690, 7], ["monk", 1080, 11], ["acolyte", 850, 9]],
 [["penitent", 550, 5], ["sluice", 850, 8], ["monk", 260, 2]],
 [["acolyte", 510, 5], ["incense", 800, 8], ["watchman", 1060, 11]],
 [["penitent", 450, 4], ["pendulum", 850, 8], ["acolyte", 680, 6]],
 [["watchman", 420, 5], ["sluice", 850, 11], ["monk", 1030, 13]],
 [["monk", 525, 4]]
]
const MONK: PackedScene = preload("res://scenes/enemies/chained_monk.tscn")
const ENEMY: PackedScene = preload("res://scenes/enemies/abbey_experimental_enemy.tscn")
const HAZARDS: Dictionary = {
 "pendulum": preload("res://scenes/props/abbey_pendulum.tscn"),
 "sluice": preload("res://scenes/props/abbey_sluice.tscn"),
 "incense": preload("res://scenes/props/abbey_incense_jet.tscn")
}
var enemies: Array[ChainedMonk] = []
var hazards: Array[Node2D] = []
func install(id: int, hero: KnightController) -> void:
 var surfaces: Array[Rect2] = AbbeyChapterLayout.main_surfaces(id)
 for record: Array in PLACEMENTS[id]:
  var kind: String = record[0]
  var pos: Vector2 = Vector2(record[1], surfaces[record[2]].position.y)
  if kind in ["monk", "acolyte", "penitent", "watchman"]:
   var enemy: ChainedMonk = (MONK if kind == "monk" else ENEMY).instantiate() as ChainedMonk
   if kind != "monk": enemy.set("archetype", ["acolyte", "penitent", "watchman"].find(kind))
   var surface: Rect2 = surfaces[record[2]]
   enemy.patrol_min_x = minf(0.0, maxf(-100.0, surface.position.x + 16.0 - pos.x))
   enemy.patrol_max_x = maxf(0.0, minf(100.0, surface.end.x - 16.0 - pos.x))
   if enemy.patrol_min_x > enemy.patrol_max_x:
    enemy.patrol_min_x = 0.0
    enemy.patrol_max_x = 0.0
   enemy.position = pos
   add_child(enemy)
   enemy.target = hero
   enemies.append(enemy)
  else:
   var hazard: Node2D = (HAZARDS[kind] as PackedScene).instantiate()
   hazard.position = pos
   add_child(hazard)
   hazard.set("target", hero)
   hazards.append(hazard)
func snapshot() -> Array:
 var result: Array = []
 for enemy: ChainedMonk in enemies: result.append(enemy.current_health)
 return result
func restore(health: Array) -> void:
 for i: int in range(mini(health.size(), enemies.size())):
  var enemy: ChainedMonk = enemies[i]
  enemy.current_health = int(health[i])
  if enemy.current_health <= 0:
   enemy.set_state(ChainedMonk.State.DEAD)
   enemy.get_node("SwordReceiver/CollisionShape2D").set_deferred("disabled", true)
   enemy.get_node("CollisionShape2D").set_deferred("disabled", true)
func reset_encounters() -> void:
 for enemy: ChainedMonk in enemies:
  enemy.process_mode = Node.PROCESS_MODE_INHERIT
  enemy.reset_enemy()
 for hazard: Node2D in hazards: hazard.reset_hazard()
func disarm() -> void:
 for enemy: ChainedMonk in enemies:
  enemy.process_mode = Node.PROCESS_MODE_DISABLED
  enemy.source.set_active(false)
 for hazard: Node2D in hazards: hazard.disarm()
 # Acólito projectiles are siblings of their owner; stop them at handoff/death.
 for child: Node in get_children():
  if child.get_script() != null and child.get_script().resource_path == "res://scripts/abbey/m5c1_projectile.gd":
   child.queue_free()
