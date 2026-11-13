extends Node2D
## Three isolated encounters; never referenced by the campaign.
const ENEMY: PackedScene = preload("res://scenes/enemies/abbey_experimental_enemy.tscn")
const CP: PackedScene = preload("res://scenes/props/respawn_checkpoint.tscn")
const NAMES: Array[String] = ["Acólito do Turíbulo", "Penitente das Arcadas", "Vigia do Sino"]
var current_room: int = -1
var busy: bool = false
var room: Node2D
var enemy: ChainedMonk
var checkpoints: Array[RespawnCheckpoint] = []
var defeated: Dictionary = {}
@onready var hero: KnightController = $Knight
@onready var camera: Camera2D = $Camera2D
@onready var caption: Label = $PilotHUD/Caption
@onready var hint: Label = $PilotHUD/Hint
func _ready() -> void:
 for id in range(3):
  var cp: RespawnCheckpoint = CP.instantiate()
  cp.position = Vector2(id*1200+96,300)
  $Checkpoints.add_child(cp)
  checkpoints.append(cp)
 hero.survival.respawn_requested.connect(_respawn)
 hero.survival.died.connect(_on_death)
 $HealthHUD.bind(hero.survival)
 await switch_room(0)
 hero.set_default_respawn(Vector2(48,300))
func switch_room(id: int, from_right: bool = false, resetting: bool = false) -> void:
 if busy or id<0 or id>=3: return
 busy=true
 hero.process_mode=Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 if is_instance_valid(room):
  if not resetting: defeated[current_room] = enemy.state==ChainedMonk.State.DEAD
  enemy.source.set_active(false)
  room.queue_free()
  await get_tree().process_frame
 room=Node2D.new()
 room.position=Vector2(id*1200,0)
 $Rooms.add_child(room)
 var art: Node2D=Node2D.new()
 art.set_script(load("res://scripts/abbey/m5c1_room_art.gd"))
 art.set_meta("archetype",id)
 room.add_child(art)
 var floor_body: StaticBody2D=StaticBody2D.new()
 floor_body.collision_layer=1
 var shape: CollisionShape2D=CollisionShape2D.new()
 var rect: RectangleShape2D=RectangleShape2D.new()
 rect.size=Vector2(960,120)
 shape.shape=rect
 shape.position=Vector2(480,360)
 floor_body.add_child(shape)
 room.add_child(floor_body)
 if id==1:
  var platform: StaticBody2D=StaticBody2D.new()
  platform.collision_layer=1
  var platform_shape: CollisionShape2D=CollisionShape2D.new()
  var platform_rect: RectangleShape2D=RectangleShape2D.new()
  platform_rect.size=Vector2(128,12)
  platform_shape.shape=platform_rect
  platform_shape.position=Vector2(736,282)
  platform.add_child(platform_shape)
  room.add_child(platform)
 enemy=ENEMY.instantiate()
 enemy.set("archetype",id)
 enemy.position=Vector2(736,276) if id==1 else Vector2(480,300)
 room.add_child(enemy)
 enemy.target=hero
 if defeated.get(id,false) and not resetting:
  enemy.set_state(ChainedMonk.State.DEAD)
  enemy.get_node("SwordReceiver/CollisionShape2D").set_deferred("disabled",true)
 await get_tree().physics_frame
 await get_tree().physics_frame
 current_room=id
 hero.reset_to(Vector2(id*1200+(912 if from_right else 48),300))
 camera.position=camera_target()
 camera.reset_smoothing()
 camera.force_update_scroll()
 hero.process_mode=Node.PROCESS_MODE_INHERIT
 busy=false
func camera_target() -> Vector2:
 var x: float = current_room*1200
 return Vector2(x+clampf(hero.global_position.x-x,160,800),252)
func _physics_process(delta: float) -> void:
 if busy or current_room<0: return
 camera.position=camera.position.move_toward(camera_target(),600*delta).round()
 caption.text="M5-C1 · %d/3 · %s" % [current_room+1,NAMES[current_room]]
 hint.text="A/D mover · Espaço saltar · J espada · F7 reiniciar"
 if hero.survival.is_dead: return
 var x: float=hero.global_position.x-current_room*1200
 if x>=944 and current_room<2 and hero.facing>0: switch_room.call_deferred(current_room+1)
 elif x<=16 and current_room>0 and hero.facing<0: switch_room.call_deferred(current_room-1,true)
 hero.global_position.x=clampf(hero.global_position.x,current_room*1200+6,current_room*1200+954)
func _on_death() -> void:
 if is_instance_valid(enemy): enemy.source.set_active(false)
func _respawn() -> void:
 defeated.clear()
 var id: int=0
 if is_instance_valid(hero.active_checkpoint): id=maxi(0,checkpoints.find(hero.active_checkpoint))
 if busy:
  while busy: await get_tree().process_frame
 await switch_room(id,false,true)
 hero.respawn_at_checkpoint()
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
  get_tree().reload_current_scene()
