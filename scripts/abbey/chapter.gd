extends Node2D
## Isolated chapter test. One persistent hero/HUD, one resident sector, stable CPs.
signal room_changed(id: int)
const CP: PackedScene=preload("res://scenes/props/respawn_checkpoint.tscn")
const DISCOVERIES: Script=preload("res://scripts/abbey/m5e_discoveries.gd")
const SHORTCUTS: Script=preload("res://scripts/abbey/m5e_shortcuts.gd")
const PASSAGE: Script=preload("res://scripts/abbey/m5e_service_passage.gd")
const ABBOT_ARENA: PackedScene=preload("res://scenes/abbey/abbot_arena.tscn")
const ABBEY_PROGRESS: Script=preload("res://scripts/abbey/abbey_progress.gd")
const ABBOT_BOSS_BAR: Script=preload("res://scripts/ui/abbot_boss_bar.gd")
const ARENA_ORIGIN: Vector2=Vector2(80000,0)
var room: Node2D
var current_room: int=-1
var busy: bool=false
var completed: bool=false
var discovered: bool=false
var names_relief_discovered: bool=false
var chapel_discovered: bool=false
var m5e_discovered: Dictionary={}
var m5e_observation_time: float=0.0
var garden_annex: bool=false
var garden_mirador_discovered: bool=false
var forge_annex: bool=false
var forge_discovered: bool=false
var archive_annex: bool=false
var archive_discovered: bool=false
var annex_jump_hold: float=0.0
var stair_annex: bool=false
var stair_discovered: bool=false
var cistern_annex: bool=false
var cistern_discovered: bool=false
var unlocked_shortcuts: Dictionary={}
var forward_completed: Dictionary={}
var arena_active: bool=false
var abbot_won: bool=false
var _abbot_progress_unlocked: bool=false
var _checkpoint_writer: Thread
var passage_index: int=-1
var passage_origin: Vector2=Vector2.ZERO
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
var boss_bar: Node2D
var loading_room: int=-1
@onready var hero: KnightController=$Knight
@onready var camera: Camera2D=$Camera2D
@onready var caption: Label=$ChapterHUD/Caption
@onready var hint: Label=$ChapterHUD/Hint
func _ready() -> void:
 process_physics_priority=2
 boss_bar=Node2D.new()
 boss_bar.set_script(ABBOT_BOSS_BAR)
 boss_bar.name="AbbotBossBar"
 $ChapterHUD.add_child(boss_bar)
 boss_bar.hide()
 for id: int in AbbeyChapterLayout.CP_SECTORS:
  var cp: RespawnCheckpoint=CP.instantiate() as RespawnCheckpoint
  cp.name="AbbeyCP"+str(checkpoints.size()+1)
  cp.position=AbbeyChapterLayout.origin(id)+AbbeyChapterLayout.checkpoint_position(id)
  cp.get_node("RespawnPoint").position=Vector2.ZERO
  cp.set_meta("sector_id",id)
  $Checkpoints.add_child(cp)
  checkpoints.append(cp)
  checkpoint_sectors[cp.get_instance_id()]=id
  cp.activated.connect(_checkpoint_activated.bind(cp))
 hero.survival.died.connect(_on_death)
 hero.survival.respawn_requested.connect(_respawn)
 $HealthHUD.bind(hero.survival)
 ABBEY_PROGRESS.sync_hero_progression(hero)
 _abbot_progress_unlocked=ABBEY_PROGRESS.unlocked()
 states=ABBEY_PROGRESS.load_chapter_states("abbey")
 var metadata: Dictionary=ABBEY_PROGRESS.load_chapter_metadata("abbey")
 unlocked_shortcuts=_restore_indexed_flags(metadata.get("unlocked_shortcuts",{}))
 forward_completed=_restore_indexed_flags(metadata.get("forward_completed",{}))
 m5e_discovered=_restore_indexed_flags(metadata.get("m5e_discovered",{}))
 var arrival: String=ABBEY_PROGRESS.consume_pending_entrance()
 if arrival == "resume":
  var token: String=ABBEY_PROGRESS.campaign_location().checkpoint
  var cp: RespawnCheckpoint=null
  for candidate: RespawnCheckpoint in checkpoints:
   if str(candidate.name)==token: cp=candidate
  if cp!=null:
   await switch_room(int(cp.get_meta("sector_id")))
   hero.set_default_respawn(AbbeyChapterLayout.origin(current_room)+AbbeyChapterLayout.entry(current_room))
   hero.activate_checkpoint(cp)
   if hero.active_checkpoint==cp: hero.reset_to(cp.respawn_point.global_position)
  elif token=="entry_east":
   await switch_room(11,true)
   hero.set_default_respawn(AbbeyChapterLayout.origin(11)+AbbeyChapterLayout.entry(11,true))
  else:
   await switch_room(0)
   hero.set_default_respawn(AbbeyChapterLayout.entry(0))
 elif arrival == "from_forest":
  await switch_room(11, true)
  hero.set_default_respawn(AbbeyChapterLayout.origin(11) + AbbeyChapterLayout.entry(11, true))
  ABBEY_PROGRESS.save_campaign_location("abbey","entry_east")
 else:
  await switch_room(0)
  hero.set_default_respawn(AbbeyChapterLayout.entry(0))
  if arrival=="from_cemetery": ABBEY_PROGRESS.save_campaign_location("abbey","entry_west")
func _checkpoint_activated(cp: RespawnCheckpoint) -> void:
 if hero.active_checkpoint==cp:
  if is_instance_valid(room) and current_room>=0 and not arena_active: states[current_room]=room.snapshot()
  _finish_checkpoint_write()
  _checkpoint_writer=Thread.new()
  var metadata: Dictionary={"unlocked_shortcuts":unlocked_shortcuts,"forward_completed":forward_completed,"m5e_discovered":m5e_discovered}
  var job: Callable=Callable(ABBEY_PROGRESS,"save_chapter_checkpoint").bind("abbey",str(cp.name),states.duplicate(true),metadata.duplicate(true))
  if _checkpoint_writer.start(job)!=OK:
   _checkpoint_writer=null
   if not job.call(): push_warning("Checkpoint da Abadia não pôde ser salvo.")
func _finish_checkpoint_write() -> void:
 if _checkpoint_writer!=null:
  if not bool(_checkpoint_writer.wait_to_finish()): push_warning("Checkpoint da Abadia não pôde ser salvo.")
  _checkpoint_writer=null
func _save_resident_states() -> void:
 if is_instance_valid(room) and current_room>=0 and not arena_active:
  states[current_room]=room.snapshot()
 ABBEY_PROGRESS.save_chapter_states("abbey",states,{"unlocked_shortcuts":unlocked_shortcuts,"forward_completed":forward_completed,"m5e_discovered":m5e_discovered})
func _restore_indexed_flags(data: Variant) -> Dictionary:
 var result: Dictionary={}
 if data is Dictionary:
  for key in data:
   if str(key).is_valid_int() and data[key] is bool: result[int(key)]=data[key]
 return result
func _exit_tree() -> void:
 _finish_checkpoint_write()
 if current_room>=0 or (arena_active and not states.is_empty()): _save_resident_states()
func _on_death() -> void:
 if is_instance_valid(room): room.disarm()
func switch_room(id: int, backwards: bool=false, fresh: bool=false, service_point: Vector2=Vector2(INF,INF)) -> void:
 if busy or id<0 or id>=12: return
 boss_bar.hide()
 caption.show()
 arena_active=false
 passage_index=-1
 garden_annex=false
 forge_annex=false
 archive_annex=false
 stair_annex=false
 cistern_annex=false
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
 room.install_encounters(hero)
 room.encounters.process_mode=Node.PROCESS_MODE_DISABLED
 if not fresh: room.restore_state(states.get(id,{}))
 if is_instance_valid(room.pilot) and is_instance_valid(room.pilot.monk): room.pilot.monk.target=hero
 # A disconnected CP stays stable, but its destination is never trusted until
 # the owning room's physics is installed. Prevent active CPs touching other rooms.
 for cp: RespawnCheckpoint in checkpoints:
  cp.get_node("CollisionShape2D").set_deferred("disabled",int(cp.get_meta("sector_id"))!=id)
 await get_tree().physics_frame
 await get_tree().physics_frame
 var destination: Vector2=AbbeyChapterLayout.origin(id)+AbbeyChapterLayout.entry(id,backwards)
 if service_point.is_finite():
  var requested: Vector2=AbbeyChapterLayout.origin(id)+service_point
  if hero.is_respawn_safe(requested): destination=requested
  else: push_warning("Passagem de serviço sem apoio seguro: usando entrada normal.")
 hero.reset_to(destination)
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
 room.encounters.process_mode=Node.PROCESS_MODE_INHERIT
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
 garden_annex=false
 forge_annex=false
 archive_annex=false
 stair_annex=false
 cistern_annex=false
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
 garden_annex=false
 forge_annex=false
 archive_annex=false
 stair_annex=false
 cistern_annex=false
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
 var right_limit: float=bounds.end.x-160
 # A small preview reveals the lateral masonry before committing to the jump.
 if current_room in [2,4,6,8,9] and p.x>bounds.end.x-100:
  right_limit+=32
 if current_room==9 and garden_annex: right_limit=1296
 if current_room==6 and forge_annex: right_limit=1544
 if current_room==8 and archive_annex: right_limit=1416
 if current_room==2 and stair_annex: right_limit=1288
 if current_room==4 and cistern_annex: right_limit=1440
 return AbbeyChapterLayout.origin(maxi(0,current_room))+Vector2(clampf(p.x+hero.facing*24,160,right_limit),y)
func _physics_process(delta: float) -> void:
 if _checkpoint_writer!=null and not _checkpoint_writer.is_alive(): _finish_checkpoint_write()
 _poll_backgrounds()
 if arena_active:
  if busy: return
  camera.position=ARENA_ORIGIN+Vector2(160,90)
  var arena_p: Vector2=hero.global_position-ARENA_ORIGIN
  if abbot_won and arena_p.x>=300:
   ABBEY_PROGRESS.set_pending_entrance("from_abbey")
   get_tree().change_scene_to_file.call_deferred("res://scenes/forest/forest_pilots.tscn")
   return
  hint.text="Passo das Sombras assimilado (Shift) · Avance à direita para a Floresta dos Ossos · E retornar" if abbot_won and hero.dash_unlocked else ("Falha ao salvar: E tentar novamente" if abbot_won else "A/D mover · Espaço saltar · J espada")
  return
 if passage_index>=0:
  if busy: return
  var passage_p: Vector2=hero.global_position-passage_origin
  var width: float=PASSAGE.WIDTHS[passage_index]
  camera.position=camera.position.move_toward(passage_origin+Vector2(clampf(passage_p.x,160,maxf(160,width-160)),252),600*delta).round()
  caption.text="ABADIA · passagem de serviço"
  hint.text="A/D mover · Espaço saltar · F7 reiniciar Abadia"
  if hero.survival.is_dead: return
  if passage_p.y>440:
   _alive_fall.call_deferred()
   return
  var pair: Array=SHORTCUTS.LINKS[passage_index]
  if passage_p.x<=8 and hero.facing<0:
   switch_room.call_deferred(pair[0],true,false,SHORTCUTS.point(pair[0],pair[1]))
  elif passage_p.x>=width-8 and hero.facing>0:
   switch_room.call_deferred(pair[2],false,false,SHORTCUTS.point(pair[2],pair[3]))
  return
 if busy or current_room<0: return
 camera.position=camera.position.move_toward(camera_target(),600*delta).round()
 caption.text="ABADIA · %02d/12 · %s" % [current_room+1,AbbeyChapterLayout.NAMES[current_room]]
 hint.text="A/D mover · Espaço saltar · J espada · F7 reiniciar Abadia"
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(current_room)
 if current_room==0 and p.x<80.0:
  hint.text="À esquerda: retornar ao Cemitério Esquecido · À direita: avançar na Abadia"
 # Holding the existing jump input while moving right signals deliberate
 # exploration; a short tap near the normal exit does not open an annex.
 if current_room in [2,4,6,8,9] and not hero.is_on_floor() and Input.is_action_pressed("jump") and hero.velocity.x>0:
  annex_jump_hold+=delta
 else:
  annex_jump_hold=0.0
 var annex_intent: bool=annex_jump_hold>=0.22
 if current_room in [2,4,6,8,9] and p.x>AbbeyChapterLayout.WIDTHS[current_room]-90 and p.x<AbbeyChapterLayout.WIDTHS[current_room]-16 and not (garden_annex or forge_annex or archive_annex or stair_annex or cistern_annex):
  hint.text="Segure salto + direita: passagem opcional"
 # The ordinary grounded exit remains unchanged. A deliberate jump above the
 # exit threshold opens the nearby optional terrace and its local camera bounds.
 if current_room==9:
  if not garden_annex and annex_intent and p.x>=1198 and p.y<260 and hero.velocity.x>0:
   garden_annex=true
  elif garden_annex and p.x<1180:
   garden_annex=false
  if garden_annex and p.distance_to(Vector2(1400,276))<28:
   garden_mirador_discovered=true
   m5e_discovered[9]=true
   hint.text="Mirante da Abadia: raízes guardam os caminhos dos ausentes."
 if current_room==6:
  if not forge_annex and annex_intent and p.x>=1454 and p.y<332 and hero.velocity.x>0:
   forge_annex=true
  elif forge_annex and p.x<1436:
   forge_annex=false
  if forge_annex and p.distance_to(Vector2(1668,300))<28:
   forge_discovered=true
   m5e_discovered[6]=true
   hint.text="Sino mudo: neste molde repousa um chamado que nunca soou."
 if current_room==8:
  if not archive_annex and annex_intent and p.x>=1326 and p.y<212 and hero.velocity.x>0:
   archive_annex=true
  elif archive_annex and p.x<1308:
   archive_annex=false
  if archive_annex and p.distance_to(Vector2(1540,180))<28:
   archive_discovered=true
   m5e_discovered[8]=true
   hint.text="Registro sem assinatura: um juramento foi deixado em branco."
 if current_room==2:
  if not stair_annex and annex_intent and p.x>=1198 and p.y<236 and hero.velocity.x>0:
   stair_annex=true
  elif stair_annex and p.x<1180:
   stair_annex=false
  if stair_annex and p.distance_to(Vector2(1412,204))<28:
   stair_discovered=true
   m5e_discovered[2]=true
   hint.text="Contrapeso partido: alguém rompeu a corrente por dentro."
 if current_room==4:
  if not cistern_annex and annex_intent and p.x>=1326 and p.y<428 and hero.velocity.x>0:
   cistern_annex=true
  elif cistern_annex and p.x<1308:
   cistern_annex=false
  if cistern_annex and p.distance_to(Vector2(1576,420))<28:
   cistern_discovered=true
   m5e_discovered[4]=true
   hint.text="Ossuário votivo: a água guardou os nomes que a pedra perdeu."
 if current_room==1 and p.distance_to(Vector2(936,84))<24: discovered=true
 if current_room==1 and not hero.survival.is_dead and p.distance_to(Vector2(867,108))<27:
  names_relief_discovered=true
  hint.text="Nomes riscados: seus votos ainda sustentam estas pedras."
 if current_room==1 and not hero.survival.is_dead and p.distance_to(Vector2(1148,108))<24:
  chapel_discovered=true
  hint.text="Capela dos nomes: nenhum juramento foi esquecido."
 if not hero.survival.is_dead and DISCOVERIES.DATA.has(current_room):
  var discovery: Dictionary=DISCOVERIES.DATA[current_room]
  var location: Vector2=DISCOVERIES.location(current_room)
  var close: bool=absf(p.x-location.x)<18
  if close and absf(p.y-location.y)<4 and hero.is_on_floor() and absf(hero.velocity.x)<8:
   m5e_observation_time+=delta
  else:
   m5e_observation_time=0.0
  if close and ((p.y<location.y-19 and p.y>location.y-62) or m5e_observation_time>=0.6):
   m5e_discovered[current_room]=true
   hint.text=discovery.text
 else:
  m5e_observation_time=0.0
 var door: int=SHORTCUTS.index_in(current_room)
 if door>=0 and not hero.survival.is_dead:
  var link: Array=SHORTCUTS.LINKS[door]
  var local_door: Vector2=SHORTCUTS.point(current_room,link[1] if current_room==link[0] else link[3])
  if p.distance_to(local_door)<24 and hero.is_on_floor():
   if unlocked_shortcuts.has(door): hint.text="E: passagem de serviço aberta"
   elif current_room==link[2] and _shortcut_requirements(door): hint.text="E: abrir passagem de serviço"
   elif current_room==link[2]: hint.text="Conclua o setor para liberar a passagem"
   else: hint.text="Passagem trancada pelo lado distante"
 if current_room==11 and p.x>AbbeyChapterLayout.WIDTHS[11]-110:
  hint.text="À direita: arena do Abade" if not _abbot_progress_unlocked else "À direita: passagem para a Floresta dos Ossos"
 if hero.survival.is_dead: return
 if p.y>AbbeyChapterLayout.bounds(current_room).end.y+120:
  _alive_fall.call_deferred()
  return
 var side: int=AbbeyChapterLayout.direction(current_room)
 for back: bool in [false,true]:
  if (garden_annex or forge_annex or archive_annex or stair_annex or cistern_annex) and not back: continue
  var target: Vector2=AbbeyChapterLayout.exit_point(current_room,back)
  var moving: int=side*(-1 if back else 1)
  if (p.x-target.x)*moving>=0 and absf(p.y-target.y)<12 and hero.facing==moving:
   var next: int=current_room+(-1 if back else 1)
   if next>=0 and next<12:
    if not back: forward_completed[current_room]=true
    switch_room.call_deferred(next,back)
   elif next==12:
    if _abbot_progress_unlocked:
     ABBEY_PROGRESS.set_pending_entrance("from_abbey")
     get_tree().change_scene_to_file.call_deferred("res://scenes/forest/forest_pilots.tscn")
    else:
     _enter_abbot_arena.call_deferred()
   elif next==-1:
    ABBEY_PROGRESS.set_pending_entrance("from_abbey")
    get_tree().change_scene_to_file.call_deferred("res://scenes/main.tscn")
 var max_x: float=1450 if current_room==9 and garden_annex else AbbeyChapterLayout.WIDTHS[current_room]-6
 if current_room==6 and forge_annex: max_x=1698
 if current_room==8 and archive_annex: max_x=1570
 if current_room==2 and stair_annex: max_x=1442
 if current_room==4 and cistern_annex: max_x=1594
 p.x=clampf(p.x,6,max_x)
 hero.global_position.x=AbbeyChapterLayout.origin(current_room).x+p.x
func _unhandled_key_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
  get_tree().reload_current_scene()
 elif event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_E:
  if arena_active and abbot_won:
   if hero.dash_unlocked: switch_room.call_deferred(11,true,false)
   else: _on_abbot_defeated()
  else: _use_shortcut()
func _shortcut_requirements(index: int) -> bool:
 var link: Array=SHORTCUTS.LINKS[index]
 if current_room!=link[2] or not visits.has(link[0]) or not visits.has(link[2]) or not forward_completed.has(link[2]): return false
 # S11 → S9 never permits a first-time bypass of the intervening Jardim.
 if index==2 and not visits.has(9): return false
 return true
func _use_shortcut() -> void:
 if busy or hero.survival.is_dead or not hero.is_on_floor(): return
 var index: int=SHORTCUTS.index_in(current_room)
 if index<0: return
 var link: Array=SHORTCUTS.LINKS[index]
 var source: Vector2=SHORTCUTS.point(current_room,link[1] if current_room==link[0] else link[3])
 var p: Vector2=hero.global_position-AbbeyChapterLayout.origin(current_room)
 if p.distance_to(source)>=24: return
 if not unlocked_shortcuts.has(index):
  if _shortcut_requirements(index): unlocked_shortcuts[index]=true
  return
 _enter_passage.call_deferred(index,current_room==link[0])
func _enter_passage(index: int, from_initial: bool) -> void:
 if busy or passage_index>=0: return
 busy=true
 hero.process_mode=Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 if is_instance_valid(room):
  states[current_room]=room.snapshot()
  room.disarm()
  room.queue_free()
  room=null
  unload_count+=1
  await get_tree().process_frame
 for cp: RespawnCheckpoint in checkpoints:
  cp.get_node("CollisionShape2D").set_deferred("disabled",true)
 var passage: Node2D=Node2D.new()
 passage.set_script(PASSAGE)
 passage.configure(index)
 passage_origin=Vector2(60000+index*1024,0)
 passage.position=passage_origin
 $Rooms.add_child(passage)
 room=passage
 current_room=-1
 passage_index=index
 await get_tree().physics_frame
 await get_tree().physics_frame
 hero.reset_to(passage_origin+Vector2(24 if from_initial else PASSAGE.WIDTHS[index]-24,300))
 hero.facing=1 if from_initial else -1
 var spawn_x: float=24 if from_initial else PASSAGE.WIDTHS[index]-24
 camera.position=passage_origin+Vector2(clampf(spawn_x,160,maxf(160,PASSAGE.WIDTHS[index]-160)),252)
 camera.reset_smoothing()
 camera.force_update_scroll()
 hero.process_mode=Node.PROCESS_MODE_INHERIT
 busy=false

func _enter_abbot_arena() -> void:
 if busy or arena_active or current_room!=11 or hero.survival.is_dead: return
 busy=true
 hero.process_mode=Node.PROCESS_MODE_DISABLED
 hero.sword_attack.cancel()
 if is_instance_valid(room):
  states[current_room]=room.snapshot()
  room.disarm()
  room.queue_free()
  room=null
  await get_tree().process_frame
 for cp: RespawnCheckpoint in checkpoints:
  cp.get_node("CollisionShape2D").set_deferred("disabled",true)
 var arena: Node2D=ABBOT_ARENA.instantiate()
 arena.position=ARENA_ORIGIN
 var already_defeated: bool=ABBEY_PROGRESS.unlocked()
 arena.configure(hero,already_defeated)
 $Rooms.add_child(arena)
 room=arena
 current_room=-1
 arena_active=true
 caption.hide()
 boss_bar.boss=arena.boss
 boss_bar.show()
 abbot_won=already_defeated
 completed=already_defeated
 arena.boss_defeated.connect(_on_abbot_defeated)
 await get_tree().physics_frame
 await get_tree().physics_frame
 hero.reset_to(ARENA_ORIGIN+Vector2(48,156))
 camera.position=ARENA_ORIGIN+Vector2(160,90)
 camera.reset_smoothing()
 camera.force_update_scroll()
 hero.process_mode=Node.PROCESS_MODE_INHERIT
 busy=false
func _on_abbot_defeated() -> void:
 if hero.survival.is_dead or not arena_active: return
 var defeated_arena: Node2D=room
 abbot_won=true
 if ABBEY_PROGRESS.grant():
  hero.dash_unlocked=true
  _abbot_progress_unlocked=true
  completed=true
 if is_instance_valid(defeated_arena) and is_instance_valid(defeated_arena.boss) and defeated_arena.boss.has_node("Conclusion"):
  var ending: Node2D = defeated_arena.boss.get_node("Conclusion")
  if not ending.played:
   ending._begin()
 await get_tree().create_timer(0.8).timeout
 if not is_instance_valid(hero) or hero.survival.is_dead or not arena_active or room!=defeated_arena: return
 if hero.dash_unlocked:
  hint.text="Passo das Sombras assimilado: Shift deslizar · Avance à direita para a Floresta dos Ossos · E retornar"
 else:
  hint.text="Vitória! Não foi possível salvar o deslizamento."
