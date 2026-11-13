extends Node2D
const CP: PackedScene=preload("res://scenes/props/respawn_checkpoint.tscn")
const PRESS: PackedScene=preload("res://scenes/props/abbey_counterweight.tscn")
const NEW_HAZARDS: Array[PackedScene]=[preload("res://scenes/props/abbey_pendulum.tscn"),preload("res://scenes/props/abbey_sluice.tscn"),preload("res://scenes/props/abbey_incense_jet.tscn")]
const NAMES: Array[String]=["Prensa de Contrapeso", "Contrapeso pendular", "Comporta votiva", "Jato de incenso abrasivo"]
var current_room: int=-1
var busy: bool=false
var room: Node2D
var hazard: DamageSource
var checkpoints: Array[RespawnCheckpoint]=[]
@onready var hero: KnightController=$Knight
@onready var camera: Camera2D=$Camera2D
@onready var caption: Label=$PilotHUD/Caption
@onready var hint: Label=$PilotHUD/Hint
func _ready() -> void:
 for id in range(4):
  var cp: RespawnCheckpoint=CP.instantiate()
  cp.position=Vector2(id*1200+96,300)
  $Checkpoints.add_child(cp)
  checkpoints.append(cp)
 hero.survival.died.connect(_on_death)
 hero.survival.respawn_requested.connect(_respawn)
 $HealthHUD.bind(hero.survival)
 await switch_room(0)
 hero.set_default_respawn(Vector2(48,300))
func switch_room(id: int, from_right: bool=false) -> void:
 if busy or id<0 or id>=4: return
 busy=true
 hero.process_mode=Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 if is_instance_valid(room):
  _on_death()
  room.queue_free()
  await get_tree().process_frame
 room=Node2D.new()
 room.position=Vector2(id*1200,0)
 $Rooms.add_child(room)
 var art: Node2D=Node2D.new()
 art.set_script(load("res://scripts/abbey/m5c1_room_art.gd"))
 room.add_child(art)
 var floor_body: StaticBody2D=StaticBody2D.new()
 floor_body.collision_layer=1
 var collision: CollisionShape2D=CollisionShape2D.new()
 var rect: RectangleShape2D=RectangleShape2D.new()
 rect.size=Vector2(960,120)
 collision.shape=rect
 collision.position=Vector2(480,360)
 floor_body.add_child(collision)
 room.add_child(floor_body)
 if id==0: hazard=PRESS.instantiate()
 else: hazard=NEW_HAZARDS[id-1].instantiate() as DamageSource
 hazard.position=Vector2(480,300)
 room.add_child(hazard)
 if id>0: hazard.set("target",hero)
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
 var x: float=current_room*1200
 return Vector2(x+clampf(hero.global_position.x-x,160,800),252)
func _physics_process(delta: float) -> void:
 if busy or current_room<0: return
 camera.position=camera.position.move_toward(camera_target(),600*delta).round()
 caption.text="M5-C2 · %d/4 · %s" % [current_room+1,NAMES[current_room]]
 hint.text="A/D mover · Espaço saltar · J espada · F7 reiniciar"
 if hero.survival.is_dead: return
 var x: float=hero.global_position.x-current_room*1200
 if x>=944 and current_room<3 and hero.facing>0: switch_room.call_deferred(current_room+1)
 elif x<=16 and current_room>0 and hero.facing<0: switch_room.call_deferred(current_room-1,true)
 hero.global_position.x=clampf(hero.global_position.x,current_room*1200+6,current_room*1200+954)
func _on_death() -> void:
 if not is_instance_valid(hazard): return
 hazard.process_mode=Node.PROCESS_MODE_DISABLED
 var col: CollisionShape2D=hazard.get_node_or_null("CollisionShape2D")
 if col: col.set_deferred("disabled",true)
 if hazard.has_method("disarm"): hazard.call("disarm")
func _respawn() -> void:
 var id: int=0
 if is_instance_valid(hero.active_checkpoint): id=maxi(0,checkpoints.find(hero.active_checkpoint))
 while busy: await get_tree().process_frame
 await switch_room(id)
 hero.respawn_at_checkpoint()
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
  get_tree().reload_current_scene()
