extends "res://tests/abbey_chapter_performance_test.gd"
## Diagnostic override preserves original inputs and conditions; logs S8 only.
func walk_sector(back: bool=false, record: bool=false) -> Dictionary:
 var id: int=demo.current_room
 var side: int=AbbeyChapterLayout.direction(id)*(-1 if back else 1)
 var end: Vector2=AbbeyChapterLayout.exit_point(id,back)
 var previous: Vector2=hero.global_position
 var length: float=0
 var horizontal: float=0
 var vertical: float=0
 var jumps: int=0
 var ticks: int=0
 var success: bool=false
 if id==7:
  print("DIAG ENTER S8 p=",hero.global_position-AbbeyChapterLayout.origin(id)," hp=",hero.survival.current_health," checkpoint=",hero.active_checkpoint," side=",side," end=",end," enemies=",demo.room.encounters.enemies.size()," hazards=",demo.room.encounters.hazards.size())
 for i: int in range(3600):
  if demo.busy or demo.current_room!=id: success=true;break
  var local: Vector2=hero.global_position-AbbeyChapterLayout.origin(id)
  if (local.x-end.x)*side>=0: success=true;break
  var on_floor: bool=hero.is_on_floor()
  steer(side)
  if id==7 and (i%60==0 or Input.is_action_pressed("jump")):
   print("DIAG tick=",i," p=",local," vel=",hero.velocity," floor=",on_floor," jump=",Input.is_action_pressed("jump")," hp=",hero.survival.current_health," dead=",hero.survival.is_dead," room=",demo.current_room)
  await frames()
  ticks+=1
  if demo.busy or demo.current_room!=id: success=true;break
  var now: Vector2=hero.global_position
  var d: Vector2=now-previous
  length+=d.length();horizontal+=absf(d.x);vertical+=absf(d.y)
  if on_floor and hero.velocity.y<0: jumps+=1
  previous=now
  if hero.survival.is_dead or hero.position.y>AbbeyChapterLayout.bounds(id).end.y+80:
   if id==7: print("DIAG BREAK tick=",i," p=",now-AbbeyChapterLayout.origin(id)," global=",hero.position," bounds=",AbbeyChapterLayout.bounds(id)," hp=",hero.survival.current_health," dead=",hero.survival.is_dead)
   break
 release()
 return {"sector":id+1,"backwards":back,"success":success,"length":length,"horizontal":horizontal,"vertical":vertical,"jumps":jumps,"ticks":ticks,"trace":[]}
