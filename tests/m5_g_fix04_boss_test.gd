extends "res://tests/m5_g_abbot_test.gd"
## Uses the actual isolated boss scene and attacks with normal inputs.
func run() -> void:
 chapter=load("res://scenes/dev/m5g_boss_playtest.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or not chapter.arena_active: await tick()
 hero=chapter.hero
 check(not hero.dash_unlocked and hero.survival.current_health==5,"perfil novo: Aren sem dash e vida cheia")
 check(chapter.room.boss.health==10 and chapter.room.boss.state!=chapter.room.boss.State.DEFEATED,"Abade vivo com HP completo")
 for i: int in range(12000):
  var boss: Node=chapter.room.boss
  if boss.phase==2: seen_phase2=true
  if boss.phase==2 and boss.pattern==boss.Pattern.DASH and boss.state==boss.State.ACTIVE: seen_boss_dash=true
  var dx: float=boss.global_position.x-hero.global_position.x
  for action: String in ["move_left","move_right","jump","attack"]: Input.action_release(action)
  if absf(dx)>27 or hero.facing!=(1 if dx>0 else -1): Input.action_press("move_right" if dx>0 else "move_left")
  if boss.state==boss.State.WARNING and boss.remaining<0.55 and hero.is_on_floor(): Input.action_press("jump")
  if i%30==0 and hero.is_on_floor() and (boss.phase==1 or seen_boss_dash): Input.action_press("attack")
  await tick()
  if hero.survival.is_dead or chapter.abbot_won: break
 for action: String in ["move_left","move_right","jump","attack"]: Input.action_release(action)
 check(seen_phase2 and seen_boss_dash,"duas fases e dash ofensivo normais")
 check(chapter.abbot_won and hero.dash_unlocked,"vitória com golpes desbloqueia dash")
 print("M5G FIX04 boss failures=",failures," user_dir=",OS.get_user_data_dir())
 chapter.queue_free()
 await tick(90)
 quit(1 if failures else 0)
