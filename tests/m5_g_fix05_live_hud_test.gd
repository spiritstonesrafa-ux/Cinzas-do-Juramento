extends "res://tests/m5_g_abbot_test.gd"
var observed: Dictionary={}
var mismatch: bool=false
var normal_hud_seen: bool=false
func tick(n: int=1) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
  if not is_instance_valid(chapter) or chapter.busy: continue
  if chapter.arena_active and is_instance_valid(chapter.room):
   var boss: Node=chapter.room.boss
   observed[boss.health]=true
   if not chapter.boss_bar.visible or not is_equal_approx(chapter.boss_bar.health_ratio(),clampf(float(boss.health)/boss.max_health,0.0,1.0)): mismatch=true
  elif chapter.current_room==11:
   normal_hud_seen=not chapter.boss_bar.visible and chapter.caption.visible
func check(value: bool,label: String) -> void:
 super.check(value,label)
 if label=="vitória permite revisitar arena concluída":
  super.check(not mismatch and observed.has(10) and observed.has(9) and observed.has(5) and observed.has(1) and observed.has(0),"barra acompanha golpes reais 10, 9, 5, 1 e 0")
  super.check(normal_hud_seen,"barra oculta e HUD do setor restaurado no retorno")
