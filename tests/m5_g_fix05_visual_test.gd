extends SceneTree
var failures: int=0
func _initialize() -> void: run.call_deferred()
func tick(n: int=1) -> void:
 for i: int in range(n): await physics_frame; await process_frame
func check(value: bool,label: String) -> void:
 print(("PASS " if value else "FAIL ")+label)
 if not value: failures+=1
func run() -> void:
 var chapter: Node=load("res://scenes/dev/m5g_boss_playtest.tscn").instantiate()
 root.add_child(chapter)
 while chapter.busy or not chapter.arena_active: await tick()
 var boss: Node=chapter.room.boss
 var hero: KnightController=chapter.hero
 await tick(8)
 check(absf(boss.position.y-156.0)<0.2,"corpo alinhado ao piso y=156")
 check(chapter.boss_bar.visible and not chapter.caption.visible,"HUD do Abade substitui texto")
 var image: Image=load("res://assets/art/m5g/abbot_fix02.png").get_image()
 var cell: Vector2i=Vector2i(image.get_width()/4,image.get_height()/3)
 for frame: int in range(12):
  var bottom: int=-1
  for y: int in range(cell.y-1,-1,-1):
   for x: int in range(0,cell.x,2):
    if image.get_pixel((frame%4)*cell.x+x,floori(frame/4.0)*cell.y+y).a>=0.5:
     bottom=y
     break
   if bottom>=0: break
  var rendered_bottom: float=-70.0+boss.visual.FOOT_OFFSETS[frame]+70.0*float(bottom+1)/cell.y
  check(bottom>=0 and absf(rendered_bottom)<=0.7,"pose %d contato calculado %.2f px" % [frame,rendered_bottom])
 var cases: Array=[
  ["parado",boss.State.INTRO,boss.Pattern.CHAIN,10,1,0.0],
  ["caminhando",boss.State.PURSUIT,boss.Pattern.CHAIN,10,1,0.0],
  ["aviso_corrente",boss.State.WARNING,boss.Pattern.CHAIN,9,1,0.0],
  ["corrente",boss.State.ACTIVE,boss.Pattern.CHAIN,9,1,0.0],
  ["aviso_varredura",boss.State.WARNING,boss.Pattern.SWEEP,5,1,0.0],
  ["varredura",boss.State.ACTIVE,boss.Pattern.SWEEP,5,1,0.0],
  ["aviso_dash",boss.State.WARNING,boss.Pattern.DASH,5,2,0.0],
  ["dash",boss.State.ACTIVE,boss.Pattern.DASH,5,2,0.0],
  ["recuperacao",boss.State.RECOVER,boss.Pattern.DASH,1,2,0.0],
  ["dano",boss.State.RECOVER,boss.Pattern.CHAIN,1,2,1.0],
  ["transicao",boss.State.TRANSITION,boss.Pattern.CHAIN,5,2,0.0],
  ["derrota",boss.State.DEFEATED,boss.Pattern.CHAIN,0,2,0.0]
 ]
 var output: String=ProjectSettings.globalize_path("res://.godot/m5g-fix05-evidencias")
 DirAccess.make_dir_recursive_absolute(output)
 for c: Array in cases:
  boss.position=Vector2(230,156)
  hero.reset_to(chapter.ARENA_ORIGIN+Vector2(50,156))
  boss.health=c[3];boss.phase=c[4];boss.pattern=c[2];boss.facing=-1
  boss._state(c[1],20.0);boss.flash=c[5]
  await tick(20 if c[0]=="derrota" else 1)
  chapter.process_mode=Node.PROCESS_MODE_DISABLED
  boss.visual.queue_redraw();chapter.boss_bar.queue_redraw()
  check(is_equal_approx(chapter.boss_bar.health_ratio(),float(c[3])/10.0),"barra "+c[0])
  for size: Vector2i in [Vector2i(1280,720),Vector2i(1920,1080),Vector2i(2560,1440),Vector2i(3840,2160)]:
   root.mode=Window.MODE_WINDOWED;root.size=size
   for i: int in range(3): await process_frame
   await RenderingServer.frame_post_draw
   var err: Error=root.get_texture().get_image().save_png(output+"/%s_%dx%d.png" % [c[0],size.x,size.y])
   if err!=OK: failures+=1
  chapter.process_mode=Node.PROCESS_MODE_INHERIT
 chapter.queue_free();await tick(5)
 print("M5G FIX05 visual fixture failures=",failures)
 quit(1 if failures else 0)
