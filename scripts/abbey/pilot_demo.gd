extends Node2D
## Independent test flow, never referenced by the official campaign.
signal room_changed(id: int)
const ROOM_PATHS: Array[String] = ["res://scenes/abbey/cloister_pilot.tscn","res://scenes/abbey/gallery_pilot.tscn"]
const CP_SCENE: PackedScene = preload("res://scenes/props/respawn_checkpoint.tscn")
var room: Node2D
var current_room: int = -1
var busy: bool = false
var discovered: bool = false
var completed: bool = false
var transitions: int = 0
var unload_count: int = 0
var states: Dictionary = {}
var load_times_ms: Array[float] = []
var checkpoints: Array[RespawnCheckpoint] = []
@onready var hero: KnightController = $Knight
@onready var camera: Camera2D = $Camera2D
@onready var caption: Label = $PilotHUD/Caption
@onready var hint: Label = $PilotHUD/Hint
func _ready() -> void:
 process_physics_priority = 2
 for id: int in range(2):
  var cp: RespawnCheckpoint = CP_SCENE.instantiate() as RespawnCheckpoint
  cp.name = "PilotCheckpoint"+str(id)
  cp.position = AbbeyPilotLayout.ORIGINS[id]+Vector2(96,300)
  $Checkpoints.add_child(cp)
  checkpoints.append(cp)
 hero.survival.respawn_requested.connect(_respawn)
 hero.survival.died.connect(_on_death)
 $HealthHUD.bind(hero.survival)
 await switch_room(0,false)
 hero.set_default_respawn(AbbeyPilotLayout.entry(0))
func _on_death() -> void:
 if is_instance_valid(room): room.disarm()
func switch_room(id: int, from_right: bool = false, resetting: bool = false) -> void:
 if busy or id<0 or id>=ROOM_PATHS.size(): return
 busy = true
 hero.process_mode = Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 hint.text = "Travessia da Abadia..."
 if is_instance_valid(room):
  if not resetting: states[current_room] = room.snapshot()
  room.disarm()
  room.queue_free()
  room = null
  unload_count += 1
  await get_tree().process_frame
 var start: int = Time.get_ticks_usec()
 var scene: PackedScene = load(ROOM_PATHS[id]) as PackedScene
 room = scene.instantiate() as Node2D
 room.position = AbbeyPilotLayout.ORIGINS[id]
 $Rooms.add_child(room)
 current_room = id
 if not resetting: room.restore_state(states.get(id,{}))
 if is_instance_valid(room.monk): room.monk.target = hero
 # Physics support must exist before either entry reset or checkpoint respawn.
 await get_tree().physics_frame
 await get_tree().physics_frame
 hero.reset_to(AbbeyPilotLayout.entry(id,from_right))
 camera.position = camera_target()
 camera.reset_smoothing()
 camera.force_update_scroll()
 load_times_ms.append((Time.get_ticks_usec()-start)/1000.0)
 hero.process_mode = Node.PROCESS_MODE_INHERIT
 busy = false
 transitions += 1
 room_changed.emit(id)
func _respawn() -> void:
 if busy:
  await room_changed
 states.clear()
 var target_room: int = 0
 if is_instance_valid(hero.active_checkpoint):
  target_room = 1 if hero.active_checkpoint==checkpoints[1] else 0
 if current_room != target_room:
  await switch_room(target_room,false,true)
 else:
  room.reset_encounters()
  await get_tree().physics_frame
 hero.respawn_at_checkpoint()
func _alive_fall() -> void:
 states.clear()
 if current_room != 0: await switch_room(0,false,true)
 else: room.reset_encounters()
 hero.reset_to(AbbeyPilotLayout.entry(0))
func camera_target() -> Vector2:
 var origin: Vector2 = AbbeyPilotLayout.ORIGINS[maxi(0,current_room)]
 var local: Vector2 = hero.global_position-origin
 # Keep the framing anchored to the hero so changing direction cannot shift the view.
 return origin+Vector2(clampf(local.x,160,800),clampf(local.y-48,90,330))
func _physics_process(delta: float) -> void:
 if busy or current_room<0: return
 var local: Vector2 = hero.global_position-AbbeyPilotLayout.ORIGINS[current_room]
 camera.position = camera.position.move_toward(camera_target(),600*delta).round()
 caption.text = "ABADIA · PILOTO %d/2 · %s" % [current_room+1,AbbeyPilotLayout.NAMES[current_room]]
 hint.text = "A/D mover · Espaço saltar · J espada · F7 reiniciar pilotos"
 if discovered: hint.text = "Votos sem nome · descoberta preservada nesta sessão"
 if current_room==0 and local.distance_to(Vector2(936,84))<24:
  discovered = true
 if completed: hint.text = "FIM DOS PILOTOS · volte à esquerda para explorar · F7 reinicia"
 if hero.survival.is_dead: return
 if local.y>480:
  _alive_fall.call_deferred()
  return
 if current_room==0 and local.x>=944 and local.y>204 and hero.facing>0:
  switch_room.call_deferred(1,false)
 elif current_room==1 and local.x<=16 and hero.facing<0:
  switch_room.call_deferred(0,true)
 elif current_room==1 and local.x>912:
  completed = true
 if local.x<6 or local.x>954: hero.global_position.x = AbbeyPilotLayout.ORIGINS[current_room].x+clampf(local.x,6,954)
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
  get_tree().reload_current_scene()
