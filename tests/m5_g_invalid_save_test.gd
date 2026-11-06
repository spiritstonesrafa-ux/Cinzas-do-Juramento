extends SceneTree
const PROGRESS: Script=preload("res://scripts/abbey/abbey_progress.gd")
func _initialize() -> void:
 var before: FileAccess=FileAccess.open(PROGRESS.PATH,FileAccess.READ)
 var text: String=before.get_as_text() if before!=null else ""
 var result: bool=PROGRESS.grant()
 var after: FileAccess=FileAccess.open(PROGRESS.PATH,FileAccess.READ)
 var unchanged: bool=after!=null and after.get_as_text()==text
 var ok: bool=not result and not PROGRESS.unlocked() and unchanged
 print("PASS dados inválidos não são sobrescritos nem desbloqueiam" if ok else "FAIL dados inválidos")
 quit(0 if ok else 1)
