extends "res://tests/m5_c3_journey_test.gd"
## One fresh journey by inputs only; no sector or player repositioning.
func run() -> void:
 chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate();root.add_child(chapter);hero=chapter.hero
 while chapter.busy or chapter.current_room<0: await tick()
 var ok: bool=true
 for id: int in range(12):
  if chapter.current_room!=id: ok=false;break
  for i: int in range(3600):
   steer(1)
   for hazard: Node2D in chapter.room.encounters.hazards:
    var center: float=hazard.global_position.x+(38 if hazard.family==2 else 0)
    var distance: float=center-hero.global_position.x
    var hold: float=[64.0,24.0,43.0][hazard.family]
    if distance>=hold and distance<hold+25 and absf(hazard.global_position.y-hero.global_position.y)<60 and hazard.state in [1,2]:
     Input.action_release("move_right");Input.action_release("jump")
   if i%2==0: Input.action_press("attack")
   else: Input.action_release("attack")
   await tick()
   if hero.survival.is_dead or chapter.busy or chapter.current_room!=id: break
  for action: String in ["move_left","move_right","jump","attack"]:Input.action_release(action)
  while chapter.busy: await tick()
  if hero.survival.is_dead or (id<11 and chapter.current_room!=id+1) or (id==11 and not chapter.arena_active):
   print("FAIL S",id+1," room=",chapter.current_room," arena=",chapter.arena_active," dead=",hero.survival.is_dead)
   ok=false;break
  print("PASS entrada após S",id+1," hp=",hero.survival.current_health," arena=",chapter.arena_active)
 print("M5G whole journey success=",ok)
 chapter.queue_free()
 for n: int in range(120):await tick()
 quit(0 if ok else 1)
