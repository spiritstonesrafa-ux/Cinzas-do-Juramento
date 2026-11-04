extends Node2D
## Isolated chapter test. One persistent hero/HUD, one resident sector, stable CPs.
signal room_changed(id: int)
const CP: PackedScene=preload("res://scenes/props/respawn_checkpoint.tscn")
var room: Node2D
var current_room: int=-1
var busy: bool=false
var completed: bool=false
var discovered: bool=false
var states: Dictionary={}
var visits: Array[int]=[]
var transitions: int=0
var unload_count: int=0
var load_times_ms: Array[float]=[]
var checkpoints: Array[RespawnCheckpoint]=[]
var checkpoint_sectors: Dictionary={}
var resetting: bool=false
var requested_backgrounds: Dictionary={}
var warm_backgrounds: Dictionary={}
var loading_room: int=-1
@onready var hero: KnightController=$Knight
@onready var camera: Camera2D=$Camera2D
@onready var caption: Label=$ChapterHUD/Caption
@onready var hint: Label=$ChapterHUD/Hint
func _ready() -> void:
 process_physics_priority=2
 for id: int in AbbeyChapterLayout.CP_SECTORS:
  var cp: RespawnCheckpoint=CP.instantiate() as RespawnCheckpoint
  cp.name="AbbeyCP"+str(checkpoints.size()+1)
  cp.position=AbbeyChapterLayout.origin(id)+AbbeyChapterLayout.checkpoint_position(id)
  cp.get_node("RespawnPoint").position=Vector2.ZERO
  cp.set_meta("sector_id",id)
  $Checkpoints.add_child(cp)
  checkpoints.append(cp)
  checkpoint_sectors[cp.get_instance_id()]=id
 hero.survival.died.connect(_on_death)
 hero.survival.respawn_requested.connect(_respawn)
 $HealthHUD.bind(hero.survival)
 await switch_room(0)
 hero.set_default_respawn(AbbeyChapterLayout.entry(0))
func _on_death() -> void:
 if is_instance_valid(room): room.disarm()
func switch_room(id: int, backwards: bool=false, fresh: bool=false) -> void:
 if busy or id<0 or id>=12: return
 busy=true
 loading_room=id
 hero.process_mode=Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 hint.text="Travessia da Abadia..."
 if is_instance_valid(room):
  if not fresh: states[current_room]=room.snapshot()
  room.disarm()
  room.queue_free()
  room=null
  unload_count+=1
  await get_tree().process_frame
 var start: int=Time.get_ticks_usec()
 # A directly requested/rapid-return room may outrun anticipatory loading. Wait
 # without blocking a rendered frame; Aren remains disabled on the safe handoff.
 _request_background(id)
 if requested_backgrounds.has(id):
  var path: String=requested_backgrounds[id]
  while ResourceLoader.load_threaded_get_status(path)==ResourceLoader.THREAD_LOAD_IN_PROGRESS:
   await get_tree().process_frame
  _poll_backgrounds()
 room=(load(AbbeyChapterLayout.room_path(id)) as PackedScene).instantiate()
 room.position=AbbeyChapterLayout.origin(id)
 $Rooms.add_child(room)
 current_room=id
 if not fresh: room.restore_state(states.get(id,{}))
 if is_instance_valid(room.pilot) and is_instance_valid(room.pilot.monk): room.pilot.monk.target=hero
 # A disconnected CP stays stable, but its destination is never trusted until
 # the owning room's physics is installed. Prevent active CPs touching other rooms.
 for cp: RespawnCheckpoint in checkpoints:
  cp.get_node("CollisionShape2D").set_deferred("disabled",int(cp.get_meta("sector_id"))!=id)
 await get_tree().physics_frame
 await get_tree().physics_frame
 hero.reset_to(AbbeyChapterLayout.origin(id)+AbbeyChapterLayout.entry(id,backwards))
 hero.facing=AbbeyChapterLayout.direction(id)*(-1 if backwards else 1)
 camera.position=camera_target()
 camera.reset_smoothing()
 camera.force_update_scroll()
 load_times_ms.append((Time.get_ticks_usec()-start)/1000.0)
 visits.append(id)
 transitions+=1
 busy=false
 loading_room=-1
 hero.process_mode=Node.PROCESS_MODE_INHERIT
 room_changed.emit(id)
 # Warm the adjacent backdrops while Aren is on supported entry ground. The
 # current room owns its texture; only adjacent warm references are retained.
 for old: int in warm_backgrounds.keys():
  if absi(old-id)>1: warm_backgrounds.erase(old)
 for adjacent: int in [id-1,id+1]:
  _request_background(adjacent)
func _request_background(id: int) -> void:
 if id<0 or id>=12 or requested_backgrounds.has(id) or warm_backgrounds.has(id): return
 var path: String="res://assets/art/m5b/"+AbbeyChapterLayout.KEYS[id]+".png"
 var type: String="Texture2D"
 if id in [1,5]:
  path="res://scenes/abbey/cloister_pilot.tscn" if id==1 else "res://scenes/abbey/gallery_pilot.tscn"
  type="PackedScene"
 if ResourceLoader.load_threaded_request(path,type)==OK: requested_backgrounds[id]=path
func _poll_backgrounds() -> void:
 for id: int in requested_backgrounds.keys():
  var path: String=requested_backgrounds[id]
  var status: ResourceLoader.ThreadLoadStatus=ResourceLoader.load_threaded_get_status(path)
  if status==ResourceLoader.THREAD_LOAD_LOADED:
   var resource: Resource=ResourceLoader.load_threaded_get(path)
   if id==loading_room or absi(id-current_room)<=1: warm_backgrounds[id]=resource
   requested_backgrounds.erase(id)
  elif status==ResourceLoader.THREAD_LOAD_FAILED or status==ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
   requested_backgrounds.erase(id)
func _respawn() -> void:
 if busy: await room_changed
 states.clear()
 var id: int=0
 if is_instance_valid(hero.active_checkpoint): id=int(checkpoint_sectors.get(hero.active_checkpoint.get_instance_id(),0))
 if current_room!=id: await switch_room(id,false,true)
 else:
  room.reset_encounters()
  await get_tree().physics_frame
 hero.respawn_at_checkpoint()
 camera.position=camera_target()
 camera.force_update_scroll()
func _alive_fall() -> void:
 if resetting or busy: return
 resetting=true
 states.clear()
 if current_room!=0: await switch_room(0,false,true)
 else: room.reset_encounters()
 hero.reset_to(AbbeyChapterLayout.entry(0))
 camera.position=camera_target()
 camera.force_update_scroll()
 resetting=false
func camera_target() -> Vector2:
 var bounds: Rect2=AbbeyChapterLayout.bounds(maxi(0,current_room))
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(maxi(0,current_room))
 var y: float=clampf(p.y-48,bounds.position.y+90,bounds.end.y-90)
 if current_room in [1,5] and p.x<960: y=clampf(p.y-48,90,330)
 return AbbeyChapterLayout.origin(maxi(0,current_room))+Vector2(clampf(p.x+hero.facing*24,160,bounds.end.x-160),y)
func _physics_process(delta: float) -> void:
 _poll_backgrounds()
 if busy or current_room<0: return
 camera.position=camera.position.move_toward(camera_target(),600*delta).round()
 caption.text="ABADIA · %02d/12 · %s" % [current_room+1,AbbeyChapterLayout.NAMES[current_room]]
 hint.text="A/D mover · Espaço saltar · J espada · F7 reiniciar Abadia"
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(current_room)
 if current_room==1 and p.distance_to(Vector2(936,84))<24: discovered=true
 if completed: hint.text="Fim da versão estrutural da Abadia — M5-B."
 if hero.survival.is_dead: return
 if p.y>AbbeyChapterLayout.bounds(current_room).end.y+120:
  _alive_fall.call_deferred()
  return
 var side: int=AbbeyChapterLayout.direction(current_room)
 for back: bool in [false,true]:
  var target: Vector2=AbbeyChapterLayout.exit_point(current_room,back)
  var moving: int=side*(-1 if back else 1)
  if (p.x-target.x)*moving>=0 and absf(p.y-target.y)<12 and hero.facing==moving:
   var next: int=current_room+(-1 if back else 1)
   if next>=0 and next<12: switch_room.call_deferred(next,back)
   elif next==12: completed=true
 p.x=clampf(p.x,6,AbbeyChapterLayout.WIDTHS[current_room]-6)
 hero.global_position.x=AbbeyChapterLayout.origin(current_room).x+p.x
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
  get_tree().reload_current_scene()
