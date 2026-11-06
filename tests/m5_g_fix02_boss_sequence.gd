extends "res://tests/m5_g_abbot_test.gd"
## Unpaused captures from the existing controls-driven fight.
var count: int=0
func tick(n: int=1) -> void:
 for i: int in range(n):
  await physics_frame
  await process_frame
  if not is_instance_valid(chapter) or not chapter.arena_active or chapter.busy or not is_instance_valid(chapter.room): continue
  var boss: Node=chapter.room.boss
  # Slow the rendering capture only; the same physical dash is still simulated.
  if count<8 and boss.phase==2 and boss.pattern==boss.Pattern.DASH and boss.state==boss.State.WARNING:
   Engine.time_scale=0.2
  elif count>=8 or (count>0 and boss.state!=boss.State.ACTIVE):
   Engine.time_scale=1.0
  if boss.phase!=2 or boss.pattern!=boss.Pattern.DASH or boss.state!=boss.State.ACTIVE or count>=12: continue
  var folder: String=ProjectSettings.globalize_path("res://.godot/m5g-fix02-boss-sequence")
  DirAccess.make_dir_recursive_absolute(folder)
  await RenderingServer.frame_post_draw
  root.get_texture().get_image().save_png(folder+"/abade_%02d.png" % count)
  count+=1
