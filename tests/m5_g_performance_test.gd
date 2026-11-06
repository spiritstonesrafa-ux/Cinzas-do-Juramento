extends "res://tests/m5_g_abbot_test.gd"
var previous_time: int=0
var timings: Array[float]=[]
func tick(n: int=1) -> void:
 for j: int in range(n):
  await physics_frame
  await process_frame
  if is_instance_valid(chapter) and chapter.arena_active and not chapter.busy:
   var now: int=Time.get_ticks_usec()
   if previous_time>0: timings.append((now-previous_time)/1000.0)
   previous_time=now
func check(v: bool, label: String) -> void:
 super.check(v,label)
 if label=="vitória por golpes reais e controles" and not timings.is_empty():
  var sorted: Array[float]=timings.duplicate();sorted.sort()
  var sum: float=0
  for x: float in sorted:sum+=x
  print("M5G PERF frames=",sorted.size()," fps=",sorted.size()/(sum/1000.0)," mean_ms=",sum/sorted.size()," p95_ms=",sorted[int((sorted.size()-1)*0.95)]," max_ms=",sorted[-1])
