extends "res://scripts/abbey/chapter.gd"
## Development-only entry point. Fail closed if launched outside the isolated launcher.
func _ready() -> void:
 var expected: String=OS.get_environment("CINZAS_M5G_ISOLATED")
 var actual: String=OS.get_user_data_dir().replace("\\","/").to_lower()
 if expected.is_empty() or not actual.begins_with(expected.replace("\\","/").to_lower()+"/"):
  push_error("Use o inicializador isolado M5-G; o perfil normal não será alterado.")
  get_tree().quit(1)
  return
 await super._ready()
 await switch_room(11)
 await _enter_abbot_arena()
 print("M5G PLAYTEST arena=",arena_active," dash=",hero.dash_unlocked," hp=",hero.survival.current_health," boss=",room.boss.health)
