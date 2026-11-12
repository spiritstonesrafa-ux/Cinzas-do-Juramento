extends SceneTree
## Isolated, fresh profile required; the mode is set by the launcher.
const PROGRESS=preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void: start.call_deferred()
func start() -> void:
 var isolate: String=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/").simplify_path()
 var actual: String=OS.get_user_data_dir().replace("\\","/").simplify_path()
 if isolate.is_empty() or not actual.begins_with(isolate+"/"):
  printerr("Perfil isolado obrigatório."); quit(2); return
 if OS.get_environment("BOSS_BALANCE_MODE")=="abbot":
  if not PROGRESS.grant_guardian_reward(): printerr("Falha ao preparar perfil."); quit(3); return
  var chapter=load("res://scenes/abbey/abbey_chapter.tscn").instantiate()
  root.add_child(chapter); current_scene=chapter
  while chapter.busy: await process_frame
  await chapter.switch_room(11)
  await chapter._enter_abbot_arena()
  print("ABADE: 6 HP, sem dash. Combate real; recompensa após vitória.")
 else:
  var main=load("res://scenes/main.tscn").instantiate()
  root.add_child(main); current_scene=main
  for i in range(3): await physics_frame
  main.get_node("ForgottenCemetery/Knight").reset_to(Vector2(2300,156))
  print("GUARDIÃO: avance à direita até o selo da catedral.")
