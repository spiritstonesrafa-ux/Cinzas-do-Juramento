extends SceneTree
const PROGRESS: Script=preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void:
 var isolated: String=OS.get_environment("SAVE_SAFETY_ISOLATED_ROOT").replace("\\","/").simplify_path()
 var actual: String=OS.get_user_data_dir().replace("\\","/").simplify_path()
 var personal: String=OS.get_environment("USERPROFILE").path_join("AppData/Roaming/Godot/app_userdata/Cinzas do Juramento").replace("\\","/").simplify_path()
 if isolated.is_empty() or not actual.begins_with(isolated+"/") or actual.to_lower()==personal.to_lower():
  printerr("Teste recusado: perfil isolado não confirmado.")
  quit(2)
  return
 var before: FileAccess=FileAccess.open(PROGRESS.PATH,FileAccess.READ)
 var text: String=before.get_as_text() if before!=null else ""
 var result: bool=PROGRESS.grant()
 var after: FileAccess=FileAccess.open(PROGRESS.PATH,FileAccess.READ)
 var unchanged: bool=after!=null and after.get_as_text()==text
 var ok: bool=not result and not PROGRESS.unlocked() and unchanged
 print("PASS dados inválidos não são sobrescritos nem desbloqueiam" if ok else "FAIL dados inválidos")
 quit(0 if ok else 1)
