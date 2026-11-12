extends SceneTree

func _initialize() -> void:
 run.call_deferred()

func run() -> void:
 var world := Node2D.new()
 root.add_child(world)
 var ground := StaticBody2D.new()
 ground.collision_layer = 1
 var collision := CollisionShape2D.new()
 var shape := RectangleShape2D.new()
 shape.size = Vector2(160, 20)
 collision.shape = shape
 collision.position = Vector2(0, 10)
 ground.add_child(collision)
 world.add_child(ground)
 var enemies: Array[ChainedMonk] = []
 for kind in range(4):
  var path := "res://scenes/enemies/chained_monk.tscn" if kind == 0 else "res://scenes/enemies/abbey_experimental_enemy.tscn"
  var enemy: ChainedMonk = load(path).instantiate()
  if kind > 0: enemy.set("archetype", kind - 1)
  enemy.position = Vector2(0, 0)
  world.add_child(enemy)
  enemies.append(enemy)
 for i in range(90): await physics_frame
 var failed := false
 for enemy in enemies:
  var moved := absf(enemy.global_position.x) > 8.0
  var safe := absf(enemy.global_position.x) < 72.0 and enemy.global_position.y < 5.0
  print("abbey patrol ", enemy.get("archetype") if "archetype" in enemy else "monk", ": moved=", moved, " safe=", safe, " position=", enemy.global_position)
  if not moved or not safe: failed = true
 world.queue_free()
 quit(1 if failed else 0)
