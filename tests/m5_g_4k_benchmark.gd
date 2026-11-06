extends "res://tests/m5_g_abbot_test.gd"
## Graphical benchmark: actual frame intervals, controls-driven battle, isolated save.
var samples: Dictionary={}
var last_usec: int=0
var collecting: bool=true
var dash_scene: bool=false
var dimensions: Vector2i
var pattern_counts: Dictionary={}
var dashes: Array[int]=[]
func _initialize() -> void:
 dimensions=Vector2i(3840,2160) if OS.get_environment("M5G_BENCH_SIZE")!="1080" else Vector2i(1920,1080)
 root.mode=Window.MODE_WINDOWED
 begin.call_deferred()
func begin() -> void:
 for i: int in range(4): await process_frame
 DisplayServer.window_set_size(dimensions)
 root.size=dimensions
 for i: int in range(8): await process_frame
 sample_loop.call_deferred()
 run.call_deferred()
func sample_loop() -> void:
 while collecting:
  await process_frame
  var now: int=Time.get_ticks_usec()
  if last_usec>0 and is_instance_valid(chapter) and chapter.arena_active and not chapter.busy:
   var b: Node=chapter.room.boss
   if b.state==b.State.ACTIVE:
    var pattern_key: String=str(b.phase)+"_"+str(b.pattern)
    pattern_counts[pattern_key]=int(pattern_counts.get(pattern_key,0))+1
   var label: String="D_dash_aren" if dash_scene else ("E_vitoria" if chapter.abbot_won or b.state==b.State.DEFEATED else ("A_repouso" if b.state==b.State.INTRO else ("C_fase2" if b.phase==2 else "B_fase1")))
   if not samples.has(label):samples[label]=[]
   samples[label].append((now-last_usec)/1000.0)
  last_usec=now
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter)
 while chapter.busy or chapter.current_room<0: await tick()
 hero=chapter.hero
 check(not hero.dash_unlocked,"progressão nova sem dash")
 await chapter.switch_room(11)
 hero.reset_to(AbbeyChapterLayout.origin(11)+Vector2(AbbeyChapterLayout.WIDTHS[11]-30,300))
 Input.action_press("move_right")
 for i: int in range(180):
  await tick()
  if chapter.arena_active and not chapter.busy:break
 Input.action_release("move_right")
 if not chapter.arena_active:check(false,"entrada na arena");collecting=false;quit(1);return
 for i: int in range(12000):
  var boss: Node=chapter.room.boss
  if boss.phase==2:seen_phase2=true
  if boss.phase==2 and boss.pattern==boss.Pattern.DASH and boss.state==boss.State.ACTIVE:seen_boss_dash=true
  var dx: float=boss.global_position.x-hero.global_position.x
  for action: String in ["move_left","move_right","jump","attack"]:Input.action_release(action)
  if absf(dx)>27 or hero.facing!=(1 if dx>0 else -1):Input.action_press("move_right" if dx>0 else "move_left")
  if boss.state==boss.State.WARNING and boss.remaining<0.55 and hero.is_on_floor():Input.action_press("jump")
  if i%30==0 and hero.is_on_floor() and (boss.phase==1 or seen_boss_dash):Input.action_press("attack")
  await tick()
  if hero.survival.is_dead or chapter.abbot_won:break
 for action: String in ["move_left","move_right","jump","attack"]:Input.action_release(action)
 check(seen_phase2 and seen_boss_dash and chapter.abbot_won and hero.dash_unlocked,"vitória real e dash adquirido")
 if chapter.abbot_won:
  dash_scene=true
  for side: int in [1,-1,1,-1]:
   Input.action_press("move_right" if side==1 else "move_left")
   await tick(1)
   var e: InputEventKey=InputEventKey.new();e.keycode=KEY_SHIFT;e.pressed=true;Input.parse_input_event(e)
   await tick(1)
   if hero.dash_remaining>0: dashes.append(hero.dash_direction)
   e=InputEventKey.new();e.keycode=KEY_SHIFT;e.pressed=false;Input.parse_input_event(e)
   Input.action_release("move_right" if side==1 else "move_left")
   await tick(60)
  dash_scene=false
 _report()
 chapter.queue_free();await tick(30);quit(1 if failures else 0)
func _report() -> void:
 collecting=false
 print("BENCH_ENV requested=",dimensions," window=",DisplayServer.window_get_size()," viewport=",root.get_texture().get_size()," adapter=",RenderingServer.get_video_adapter_name()," renderer=",RenderingServer.get_current_rendering_method()," vsync=",DisplayServer.window_get_vsync_mode()," fps_limit=",Engine.max_fps)
 print("BENCH attack_frames=",pattern_counts)
 print("BENCH player_dashes=",dashes)
 for key: String in ["A_repouso","B_fase1","C_fase2","D_dash_aren","E_vitoria"]:
  var a: Array=samples.get(key,[])
  if a.is_empty():print("BENCH ",key," sem amostras");continue
  var sorted: Array=a.duplicate();sorted.sort()
  var total: float=0.0
  var over: int=0
  for ms: float in a:
   total+=ms
   if ms>33.333:over+=1
  print("BENCH ",key," n=",a.size()," seconds=",total/1000.0," fps_avg=",1000.0*a.size()/total," fps_min_sample=",1000.0/sorted[-1]," mean_ms=",total/a.size()," p95_ms=",sorted[int((sorted.size()-1)*0.95)]," p99_ms=",sorted[int((sorted.size()-1)*0.99)]," max_ms=",sorted[-1]," over_33ms=",over)
 var out: String=ProjectSettings.globalize_path("res://.godot/m5g-4k-benchmark")
 DirAccess.make_dir_recursive_absolute(out)
 var img: Image=root.get_texture().get_image()
 print("BENCH captured_image=",img.get_size())
 var err: Error=img.save_png(out+"/benchmark_%dx%d.png" % [dimensions.x,dimensions.y])
 print("BENCH screenshot=",err)
