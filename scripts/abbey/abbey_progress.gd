extends RefCounted
## One explicit campaign reward; malformed existing data is never overwritten.
const PATH: String = "user://cinzas_abbey_progress_v1.json"
static func unlocked() -> bool:
 if not FileAccess.file_exists(PATH): return false
 var file: FileAccess=FileAccess.open(PATH,FileAccess.READ)
 if file==null: return false
 var parsed: Variant=JSON.parse_string(file.get_as_text())
 return parsed is Dictionary and parsed.get("version")==1 and parsed.get("abbot_defeated")==true and parsed.get("dash_unlocked")==true
static func grant() -> bool:
 if unlocked(): return true
 if FileAccess.file_exists(PATH):
  push_warning("Progresso existente inválido ou não reconhecido: recompensa não gravada.")
  return false
 var tmp: String=PATH+".new"
 if FileAccess.file_exists(tmp):
  push_warning("Gravação pendente encontrada; recompensa não sobrescrita.")
  return false
 var file: FileAccess=FileAccess.open(tmp,FileAccess.WRITE)
 if file==null: return false
 file.store_string(JSON.stringify({"version":1,"abbot_defeated":true,"dash_unlocked":true}))
 file.flush()
 var ok: bool=file.get_error()==OK
 file.close()
 if not ok: return false
 return DirAccess.rename_absolute(ProjectSettings.globalize_path(tmp),ProjectSettings.globalize_path(PATH))==OK and unlocked()
