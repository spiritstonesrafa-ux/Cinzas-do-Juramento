extends "res://tests/abbey_pilot_test.gd"
## Real wall-clock benchmark. No fixed-fps. Transition-inclusive frames retained.
func run() -> void:
 var output: String=OS.get_environment("CINZAS_M5_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5a-performance")
 DirAccess.make_dir_recursive_absolute(output)
 root.mode=Window.MODE_FULLSCREEN
 demo=(load("res://scenes/abbey/abbey_pilots.tscn") as PackedScene).instantiate()
 root.add_child(demo)
 await wait_room()
 hero=demo.hero
 await frames(120)
 var samples: Array[float]=[]
 var start: int=Time.get_ticks_usec()
 var previous: int=start
 var nodes_min: int=100000
 var nodes_max: int=0
 var memories: Array=[]
 var last_switch: int=start
 var pending: bool=false
 while Time.get_ticks_usec()-start<60000000:
  var now: int=Time.get_ticks_usec()
  if now-last_switch>2500000 and not demo.busy and not pending:
   pending=true
   demo.switch_room(1-demo.current_room)
   last_switch=now
  if pending and not demo.busy:
   pending=false
   hero.reset_to(AbbeyPilotLayout.ORIGINS[demo.current_room]+Vector2(535 if demo.current_room==1 else 420,300 if demo.current_room==1 else 228))
  await process_frame
  now=Time.get_ticks_usec()
  samples.append((now-previous)/1000.0)
  previous=now
  var count: int=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
  nodes_min=mini(nodes_min,count);nodes_max=maxi(nodes_max,count)
  if samples.size()%180==0:memories.append({"nodes":count,"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),"static":Performance.get_monitor(Performance.MEMORY_STATIC),"textures":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})
 if demo.busy: await demo.room_changed
 samples.sort()
 var data: Dictionary={"seconds":(previous-start)/1000000.0,"fps":samples.size()/((previous-start)/1000000.0),"p95_ms":samples[int(samples.size()*0.95)],"p99_ms":samples[int(samples.size()*0.99)],"max_ms":samples[-1],"nodes_min":nodes_min,"nodes_max":nodes_max,"memory":memories,"transitions":demo.transitions,"unloads":demo.unload_count,"load_ms":demo.load_times_ms,"image":str(root.get_texture().get_image().get_size()),"fixed_fps":false,"scope":"two-room transitions inclusive; one resident room; no human playtest"}
 FileAccess.open(output+"/performance.json",FileAccess.WRITE).store_string(JSON.stringify(data,"  "))
 print("M5-A performance: ",JSON.stringify(data))
 quit()
