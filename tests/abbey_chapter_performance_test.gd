extends "res://tests/abbey_chapter_test.gd"
## Real elapsed-time traversal. Never run with --fixed-fps.
var samples: Array[float]=[]
var memory: Array=[]
var start: int=0
var previous: int=0
var active: bool=false
var nodes_min: int=1000000
var nodes_max: int=0
var traversal_start: int=0
var traversal_samples: Array[float]=[]
var traversal_active: bool=false
func sample() -> void:
 if not active: return
 var now: int=Time.get_ticks_usec()
 if previous>0:
  samples.append((now-previous)/1000.0)
  if traversal_active and previous>=traversal_start: traversal_samples.append((now-previous)/1000.0)
 previous=now
 var nodes: int=int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))
 nodes_min=mini(nodes_min,nodes);nodes_max=maxi(nodes_max,nodes)
 if samples.size()%180==0:
  memory.append({"seconds":(now-start)/1000000.0,"sector":demo.current_room if is_instance_valid(demo) else -1,"nodes":nodes,"orphans":Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT),"static":Performance.get_monitor(Performance.MEMORY_STATIC),"textures":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED)})
func run() -> void:
 output=OS.get_environment("CINZAS_M5B_EVIDENCE")
 if output.is_empty(): output=ProjectSettings.globalize_path("res://.godot/m5b-performance")
 DirAccess.make_dir_recursive_absolute(output)
 root.mode=Window.MODE_FULLSCREEN
 start=Time.get_ticks_usec();previous=start;active=true
 process_frame.connect(sample)
 demo=(load("res://scenes/abbey/abbey_chapter.tscn") as PackedScene).instantiate()
 root.add_child(demo);await wait_room();hero=demo.hero
 traversal_start=Time.get_ticks_usec();traversal_active=true
 var routes: Array=[]
 for id: int in range(12):
  await wait_room();isolate_threats()
  var result: Dictionary=await walk_sector()
  result.erase("trace");routes.append(result)
  check(demo.current_room==id or demo.busy or (id<11 and demo.current_room==id+1),"Benchmark remains on authored sequence S"+str(id+1))
  check(result.success,"Real-time rendered traversal S"+str(id+1))
  if id<11:
   for i: int in range(20):
    if demo.current_room!=id or demo.busy: break
    steer(AbbeyChapterLayout.direction(id));await frames()
   release();await wait_room()
 traversal_active=false
 # Warm return/unload cycles, labelled separately from the physical traversal.
 for cycle: int in range(2):
  for id: int in range(11,-1,-1):
   await demo.switch_room(id,true)
   isolate_threats()
   await frames(4)
 # Exercise live approved encounter in the integrated room for a real 15s sample.
 await demo.switch_room(5)
 hero.reset_to(AbbeyChapterLayout.origin(5)+Vector2(350,300))
 var monk: ChainedMonk=demo.room.pilot.monk
 for i: int in range(900):
  Input.action_release("jump");Input.action_release("attack")
  if monk.state==ChainedMonk.State.WARNING and monk.remaining<=0.30 and hero.is_on_floor(): Input.action_press("jump")
  if monk.state==ChainedMonk.State.RECOVER and hero.is_on_floor(): Input.action_press("attack")
  await frames()
 release()
 active=false
 samples.sort()
 var seconds: float=(Time.get_ticks_usec()-start)/1000000.0
 var data: Dictionary={"checks":checks,"failures":failures,"seconds":seconds,"fps":samples.size()/seconds,"p95_ms":samples[int(samples.size()*0.95)],"p99_ms":samples[int(samples.size()*0.99)],"max_ms":samples[-1],"nodes_min":nodes_min,"nodes_max":nodes_max,"memory":memory,"load_ms":demo.load_times_ms,"entries":demo.transitions,"unloads":demo.unload_count,"routes":routes,"fixed_fps":false,"image":str(root.get_texture().get_image().get_size()),"scope":"continuous forward navigation with threats isolated for measurement, then warm loader cycles and 15s live monk encounter; no TCL human test"}
 traversal_samples.sort()
 var sum_ms: float=0
 for ms: float in traversal_samples: sum_ms+=ms
 data["traversal"]={"fps":traversal_samples.size()/(sum_ms/1000.0),"p95_ms":traversal_samples[int(traversal_samples.size()*0.95)],"max_ms":traversal_samples[-1],"seconds":sum_ms/1000.0,"includes_room_transitions":true,"excludes_initial_bootstrap":true}
 FileAccess.open(output+"/performance.json",FileAccess.WRITE).store_string(JSON.stringify(data,"  "))
 print("M5-B real-time performance: ",JSON.stringify(data))
 quit(0 if failures==0 else 1)
