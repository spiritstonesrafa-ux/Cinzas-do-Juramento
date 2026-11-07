extends SceneTree
## Short graphical smoke measurement; it is not a 4K or worst-case benchmark.
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var demo: ForestDemo = load("res://scenes/forest/forest_pilots.tscn").instantiate()
 root.add_child(demo)
 while demo.busy or demo.current_room<0: await process_frame
 for id in range(2):
  if id==1: await demo.switch_room(1)
  while demo.busy: await process_frame
  for i in range(60): await process_frame
  var samples: Array[float] = []
  var last := Time.get_ticks_usec()
  var end := last + 5000000
  Input.action_press("move_right")
  while Time.get_ticks_usec()<end:
   await process_frame
   var now := Time.get_ticks_usec()
   samples.append((now-last)/1000.0)
   last=now
  Input.action_release("move_right")
  samples.sort()
  var sum := 0.0
  for n in samples: sum+=n
  print("M6 PERF sector=",id+1," n=",samples.size()," seconds=",sum/1000," fps=",1000.0*samples.size()/sum," mean=",sum/samples.size()," p95=",samples[int((samples.size()-1)*0.95)]," max=",samples[-1]," size=",root.get_texture().get_image().get_size()," renderer=",RenderingServer.get_current_rendering_method()," adapter=",RenderingServer.get_video_adapter_name())
 demo.queue_free()
 await process_frame
 quit()
