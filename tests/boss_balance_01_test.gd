extends SceneTree
var failures: int=0
var checks: int=0
func check(ok: bool, label: String) -> void:
 checks+=1
 if ok: print("PASS ",label)
 else: failures+=1; printerr("FAIL ",label)
func frames(n: int) -> void:
 for i in range(n): await physics_frame
func _initialize() -> void: run.call_deferred()
func run() -> void:
 var isolated: String=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if isolated.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(isolated+"/"):
  printerr("isolamento ausente"); quit(2); return
 var world:=Node2D.new(); root.add_child(world)
 var hero: KnightController=load("res://scenes/player/knight.tscn").instantiate()
 world.add_child(hero); hero.position=Vector2(20,156)
 var arena=load("res://scenes/abbey/abbot_arena.tscn").instantiate()
 arena.configure(hero,false); world.add_child(arena)
 await frames(4)
 var boss=arena.boss
 check(not hero.dash_unlocked,"Aren sem dash")
 boss._state(boss.State.PURSUIT,0)
 for i in range(5):boss._hit()
 check(boss.phase==2,"transição em 50%")
 var saw_ascent=false; var saw_judgment=false; var saw_descent=false; var saw_warning=false; var saw_active=false
 var impact_x: Array[float]=[]
 var previous_index=0
 for i in range(720):
  await physics_frame
  if boss.state==boss.State.ASCEND:saw_ascent=true
  if boss.state==boss.State.JUDGMENT:saw_judgment=true
  if boss.state==boss.State.DESCEND:saw_descent=true
  if boss.judgment_index>previous_index:
   previous_index=boss.judgment_index
   var h=boss.judgment_hazards.back()
   impact_x.append(h.position.x)
  for h in boss.judgment_hazards:
   if is_instance_valid(h):
    if h.age<h.WARNING:saw_warning=true
    if h.age>=h.WARNING and h.age<h.WARNING+h.ACTIVE:saw_active=true
 check(saw_ascent and saw_judgment and saw_descent,"ascensão, chuva e descida executadas")
 check(saw_warning and saw_active,"aviso precede janela ativa")
 check(impact_x.size()==7 and impact_x[0]!=impact_x[1] and impact_x[2]!=impact_x[3],"sete impactos com regiões variadas")
 check(boss.judgment_used and boss.state not in [boss.State.ASCEND,boss.State.JUDGMENT,boss.State.DESCEND],"sequência finita retorna ao solo")
 check(absf(boss.position.y-156)<1,"retorno à altura do chão")
 check(boss.health==5,"HP não inflado")
 var chain=load("res://scripts/abbey/judgment_chain.gd").new()
 chain.owner_boss=boss; chain.position=Vector2(100,156); arena.add_child(chain)
 await frames(2)
 check(chain.contact_damage(hero.get_instance_id())==0,"aviso sem dano antecipado")
 chain.age=chain.WARNING+0.01
 check(chain.contact_damage(hero.get_instance_id())==1 and chain.contact_damage(hero.get_instance_id())==0,"um dano por impacto")
 chain.disarm(); chain.queue_free()
 boss._start_judgment()
 await frames(5)
 boss.health=1; boss._hit()
 check(boss.state==boss.State.DEATH_DESCEND and boss.judgment_hazards.is_empty(),"morte durante subida encerra perigo")
 await frames(40)
 check(boss.state==boss.State.DEFEATED and absf(boss.position.y-156)<1,"morte aérea desce antes da conclusão")
 boss._state(boss.State.PURSUIT,0)
 boss.last_pattern=boss.Pattern.CHAIN
 check(boss._choose_pattern(40)==boss.Pattern.SWEEP,"seleção contextual terrestre")
 var guardian_arena=load("res://scenes/boss/guardian_arena.tscn").instantiate()
 guardian_arena.position=Vector2(400,0); world.add_child(guardian_arena)
 await frames(3)
 var guardian: OathGuardian=guardian_arena.get_node("Guardian")
 guardian.begin(hero)
 guardian._set_state(guardian.State.PURSUIT)
 guardian.receive_hit()
 check(guardian.state==guardian.State.HURT,"primeiro impacto interrompe brevemente")
 await frames(11)
 guardian.receive_hit()
 check(guardian.state!=guardian.State.HURT and guardian.current_health==8,"segundo impacto causa dano sem renovar stun")
 guardian.attack_count=1
 guardian.last_pattern=guardian.Pattern.HEAVY
 guardian.cooldowns.clear()
 guardian.position.x=160; guardian.facing=1
 check(guardian._choose_pattern(110)==guardian.Pattern.CHARGE,"guardião responde à distância")
 check(guardian.max_health==10,"HP original do guardião")
 world.queue_free(); await frames(3)
 print("BOSS_BALANCE checks=",checks," failures=",failures)
 quit(1 if failures else 0)
