extends SceneTree
func frames() -> void:
 await physics_frame
 await process_frame
func _initialize() -> void:run.call_deferred()
func run() -> void:
 var iso=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/")
 if iso.is_empty() or not OS.get_user_data_dir().replace("\\","/").begins_with(iso+"/"):quit(2);return
 var main=load("res://scenes/main.tscn").instantiate();root.add_child(main)
 for i in range(5):await frames()
 var hero=main.get_node("ForgottenCemetery/Knight");var encounter=main.get_node("GuardianEncounter")
 encounter.enter()
 for i in range(4):await frames()
 var boss=encounter.arena.get_node("Guardian")
 for jump in [false,true]:
  boss.reset_encounter();hero.survival.restore();boss.position=Vector2(110,156);hero.reset_to(encounter.arena.global_position+boss.position+Vector2(60,0))
  for i in range(4):await frames()
  boss.target=hero;boss.awake=true;boss.facing=1;boss.start_pattern(boss.Pattern.CHARGE)
  var prev=hero.survival.current_health
  for i in range(180):
   if jump and boss.state==boss.State.TELEGRAPH and boss.remaining<=0.1 and hero.is_on_floor():Input.action_press("jump")
   else:Input.action_release("jump")
   await frames()
   if prev!=hero.survival.current_health:
    print("DAMAGE jump=",jump," frame=",i," hp=",hero.survival.current_health," source=",hero.hurtbox.last_damage_type," boss=",boss.position," player=",hero.global_position-encounter.arena.global_position," state=",boss.state)
    prev=hero.survival.current_health
   if boss.state==boss.State.PUNISH and boss.remaining<0.5:break
 Input.action_release("jump");quit()
