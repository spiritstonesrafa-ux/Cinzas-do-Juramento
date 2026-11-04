extends Node2D
## Geometry and local state only. The demo owns player, camera and stable checkpoints.
@export_range(0,1,1) var room_id: int = 0
const MONK: PackedScene = preload("res://scenes/enemies/chained_monk.tscn")
const HAZARD: PackedScene = preload("res://scenes/props/abbey_counterweight.tscn")
var monk: ChainedMonk
var hazard: AbbeyCounterweight
func _ready() -> void:
 var world: Node2D = Node2D.new()
 world.name = "Geometry"
 add_child(world)
 var index: int = 0
 for rect: Rect2 in AbbeyPilotLayout.surfaces(room_id):
  var body: StaticBody2D = StaticBody2D.new()
  body.name = "Surface"+str(index)
  body.position = rect.position
  body.collision_layer = 1
  body.collision_mask = 2|256
  var collider: CollisionShape2D = CollisionShape2D.new()
  var shape: RectangleShape2D = RectangleShape2D.new()
  shape.size = rect.size
  collider.shape = shape
  collider.position = rect.size*0.5
  body.add_child(collider)
  world.add_child(body)
  index += 1
 if room_id == 1:
  monk = MONK.instantiate() as ChainedMonk
  monk.position = Vector2(388,300)
  add_child(monk)
  hazard = HAZARD.instantiate() as AbbeyCounterweight
  hazard.position = Vector2(588,300)
  add_child(hazard)
func snapshot() -> Dictionary:
 return {"health":monk.current_health} if is_instance_valid(monk) else {}
func restore_state(data: Dictionary) -> void:
 if is_instance_valid(monk):
  monk.current_health = int(data.get("health",3))
  if monk.current_health == 0:
   monk.set_state(ChainedMonk.State.DEAD)
   monk.get_node("SwordReceiver/CollisionShape2D").set_deferred("disabled",true)
   monk.get_node("CollisionShape2D").set_deferred("disabled",true)
func reset_encounters() -> void:
 if is_instance_valid(monk): monk.reset_enemy()
 if is_instance_valid(hazard): hazard.reset_hazard()
func disarm() -> void:
 if is_instance_valid(monk): monk.source.set_active(false)
 if is_instance_valid(hazard):
  hazard.process_mode = Node.PROCESS_MODE_DISABLED
  hazard.shape.set_deferred("disabled",true)
