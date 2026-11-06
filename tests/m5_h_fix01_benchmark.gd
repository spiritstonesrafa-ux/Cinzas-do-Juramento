extends SceneTree
## Comparable graphical samples in real S7, all authored threats remain enabled.
func _initialize() -> void: run.call_deferred()
func run() -> void:
 root.mode = Window.MODE_FULLSCREEN
 DisplayServer.window_set_size(Vector2i(3840,2160))
 for i in range(10): await process_frame
 var chapter: Node2D = load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or chapter.current_room < 0: await process_frame
 await chapter.switch_room(6)
 while chapter.busy: await process_frame
 for i in range(120): await process_frame
 var entries: Array[float] = []
 var last := Time.get_ticks_usec()
 var end := last + 8000000
 while Time.get_ticks_usec() < end:
  await process_frame
  var now := Time.get_ticks_usec()
  entries.append((now-last)/1000.0)
  last = now
 var sorted := entries.duplicate()
 sorted.sort()
 var sum := 0.0
 for value in sorted: sum += value
 var active := 0
 for enemy in chapter.room.encounters.enemies:
  if enemy.can_process(): active += 1
 var img := root.get_texture().get_image()
 var screenshot := ProjectSettings.globalize_path("user://fix01_benchmark.png")
 var err := img.save_png(screenshot)
 print("FIX01_BENCH n=",sorted.size()," seconds=",sum/1000," fps=",1000.0*sorted.size()/sum," mean=",sum/sorted.size()," p95=",sorted[int((sorted.size()-1)*0.95)]," p99=",sorted[int((sorted.size()-1)*0.99)]," max=",sorted[-1])
 print("FIX01_ENV screen=",DisplayServer.screen_get_size()," window=",DisplayServer.window_get_size()," viewport=",root.get_texture().get_size()," image=",img.get_size()," method=",RenderingServer.get_current_rendering_method()," device=",RenderingServer.get_video_adapter_name()," enemies=",chapter.room.encounters.enemies.size()," processing=",active," hazards=",chapter.room.encounters.hazards.size()," hp=",chapter.hero.survival.current_health," screenshot=",screenshot," error=",err)
 chapter.queue_free()
 await process_frame
 quit()
