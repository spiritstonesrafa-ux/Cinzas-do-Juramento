extends SceneTree
## M5-F sampled live sessions, no fixed-fps; sector changes are explicit fixtures.
var last_usec: int=0
var frames_ms: Array[float]=[]
func sample() -> void:
 var now: int=Time.get_ticks_usec()
 if last_usec>0: frames_ms.append((now-last_usec)/1000.0)
 last_usec=now
func stats() -> Dictionary:
 var sorted: Array[float]=frames_ms.duplicate()
 sorted.sort()
 var total: float=0
 for n: float in sorted: total+=n
 if sorted.is_empty(): return {}
 return {"frames":sorted.size(),"fps":sorted.size()/(total/1000.0),"mean_ms":total/sorted.size(),"p95_ms":sorted[int((sorted.size()-1)*0.95)],"max_ms":sorted[-1]}
func run() -> void:
 root.mode=Window.MODE_WINDOWED
 root.size=Vector2i(3840,2160)
 var t0: int=Time.get_ticks_usec()
 var ch: Node=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(ch)
 while ch.busy or ch.current_room<0: await process_frame
 print("BOOTSTRAP_MS=",(Time.get_ticks_usec()-t0)/1000.0)
 process_frame.connect(sample)
 for id: int in [0,3,7,9]:
  var before: int=Time.get_ticks_usec()
  await ch.switch_room(id)
  print("SECTOR_LOAD_MS S",id+1,"=",(Time.get_ticks_usec()-before)/1000.0)
  frames_ms.clear(); last_usec=0
  Input.action_press("move_right")
  var end_usec: int=Time.get_ticks_usec()+5000000
  while Time.get_ticks_usec()<end_usec: await process_frame
  Input.action_release("move_right")
  print("LIVE S",id+1," ",JSON.stringify(stats())," DEAD=",ch.hero.survival.is_dead," ROOM=",ch.current_room)
 process_frame.disconnect(sample)
 ch.queue_free()
 await process_frame
 quit()
func _initialize() -> void: run.call_deferred()
