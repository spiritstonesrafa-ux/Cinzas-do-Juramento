extends RefCounted
## Reward persistence. Immutable verified backups are retained across updates.
const PATH: String = "user://cinzas_abbey_progress_v1.json"
const BACKUP_PREFIX: String = "cinzas_abbey_progress_v1.json.bak-"
const LOCK_PATH: String = "user://cinzas_abbey_progress_v1.lock"
const REVISION: String = "_save_revision"
const CHECKSUM: String = "_save_checksum"
const FLAGS: Array[String] = ["abbot_defeated", "dash_unlocked", "guardian_defeated", "health_upgrade_unlocked", "cervo_defeated", "spectral_jump_unlocked", "ember_guardian_defeated"]
static var _mutex: Mutex = Mutex.new()
static var _pending_entrance: String = ""

static func set_pending_entrance(val: String) -> void:
	_pending_entrance = val

static func get_pending_entrance() -> String:
	return _pending_entrance

static func consume_pending_entrance() -> String:
	var val: String = _pending_entrance
	_pending_entrance = ""
	return val

static func _load_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path): return {}
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null: return {}
	var raw: String = file.get_as_text()
	file.close()
	var parser: JSON = JSON.new()
	if parser.parse(raw) != OK: return {}
	var parsed: Variant = parser.data
	if not parsed is Dictionary or parsed.get("version") != 1: return {}
	for key: String in FLAGS:
		if parsed.has(key) and typeof(parsed[key]) != TYPE_BOOL: return {}
	if parsed.has(REVISION):
		var number: Variant = parsed[REVISION]
		if typeof(number) not in [TYPE_INT, TYPE_FLOAT] or float(number) < 0 or floorf(float(number)) != float(number): return {}
	if parsed.has(CHECKSUM):
		if typeof(parsed[CHECKSUM]) != TYPE_STRING or parsed[CHECKSUM] != _checksum(parsed): return {}
	return parsed

static func _checksum(data: Dictionary) -> String:
	var payload: Dictionary = data.duplicate(true)
	payload.erase(CHECKSUM)
	var normalized: Variant = JSON.parse_string(JSON.stringify(payload))
	return JSON.stringify(normalized).sha256_text()

static func _best_valid() -> Dictionary:
	var best: Dictionary = _load_valid(PATH)
	var best_revision: int = int(best.get(REVISION, 0)) if not best.is_empty() else -1
	var ambiguous: bool = false
	for name: String in DirAccess.get_files_at("user://"):
		if not name.begins_with(BACKUP_PREFIX): continue
		var candidate: Dictionary = _load_valid("user://" + name)
		if candidate.is_empty(): continue
		var revision: int = int(candidate.get(REVISION, 0))
		if revision > best_revision:
			best = candidate
			best_revision = revision
			ambiguous = false
		elif revision == best_revision and candidate != best:
			ambiguous = true
	if ambiguous:
		push_warning("Progresso ambíguo: cópias válidas da mesma revisão divergem.")
		return {}
	return best

static func read_progress() -> Dictionary:
	return _best_valid()

static func _unique_path(prefix: String) -> String:
	return prefix + str(Time.get_unix_time_from_system()).replace(".", "_") + "-" + str(OS.get_process_id()) + "-" + str(Time.get_ticks_usec())

static func _write_verified(path: String, data: Dictionary) -> bool:
	# The lock serializes cooperating writers; never intentionally reuse a path.
	if FileAccess.file_exists(path): return false
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null: return false
	file.store_string(JSON.stringify(data))
	file.flush()
	var error: Error = file.get_error()
	file.close()
	var loaded: Dictionary = _load_valid(path)
	if error != OK or not _equivalent(loaded, data):
		push_warning("Falha na verificação do arquivo de progresso: erro %d, dados válidos %s." % [error, not loaded.is_empty()])
	return error == OK and _equivalent(loaded, data)

static func _equivalent(first: Dictionary, second: Dictionary) -> bool:
	# JSON parsing normalizes numeric types; compare canonicalized JSON values.
	return JSON.stringify(first) == JSON.stringify(JSON.parse_string(JSON.stringify(second)))

static func _save_locked(data: Dictionary, fault: String = "", previous: Dictionary = {}) -> bool:
	var has_primary: bool = FileAccess.file_exists(PATH)
	var primary: Dictionary = _load_valid(PATH)
	if previous.is_empty() and (has_primary or not _backup_names().is_empty()):
		push_warning("Progresso existente inválido ou ambíguo: gravação recusada.")
		return false
	var next: Dictionary = data.duplicate(true)
	next["version"] = 1
	next[REVISION] = int(previous.get(REVISION, 0)) + 1
	next[CHECKSUM] = _checksum(next)
	if _validate_dict(next).is_empty(): return false
	var temp: String = _unique_path(PATH + ".tmp-")
	if fault == "write": return false
	if fault == "partial_write":
		var partial: FileAccess = FileAccess.open(temp, FileAccess.WRITE)
		if partial != null:
			partial.store_string("{")
			partial.flush()
			partial.close()
		return false
	if not _write_verified(temp, next): return false
	if fault == "after_temp": return false
	# Preserve the latest valid state before touching the primary file.
	if not previous.is_empty():
		var backup: String = _unique_path("user://" + BACKUP_PREFIX)
		if not _write_verified(backup, previous): return false
	if fault == "after_backup": return false
	# Keep malformed primary data for diagnosis; backup remains recoverable.
	if has_primary and primary.is_empty():
		var quarantine: String = _unique_path(PATH + ".invalid-")
		if FileAccess.file_exists(quarantine): return false
		if DirAccess.rename_absolute(ProjectSettings.globalize_path(PATH), ProjectSettings.globalize_path(quarantine)) != OK: return false
	if fault == "replace": return false
	var destination: String = PATH + "/cannot_replace" if fault == "rename_error" else PATH
	var result: Error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temp), ProjectSettings.globalize_path(destination))
	if result != OK: return false
	if not _equivalent(_load_valid(PATH), next): return false
	# A new campaign also gets a recoverable copy after its first commit.
	if previous.is_empty():
		var first_backup: String = _unique_path("user://" + BACKUP_PREFIX)
		if not _write_verified(first_backup, next): return false
	return true

static func _validate_dict(data: Dictionary) -> Dictionary:
	if data.get("version") != 1: return {}
	for key: String in FLAGS:
		if data.has(key) and typeof(data[key]) != TYPE_BOOL: return {}
	return data

static func _backup_names() -> Array[String]:
	var result: Array[String] = []
	for name: String in DirAccess.get_files_at("user://"):
		if name.begins_with(BACKUP_PREFIX): result.append(name)
	return result

static func _has_valid_backup() -> bool:
	for name: String in _backup_names():
		if not _load_valid("user://" + name).is_empty(): return true
	return false

static func _grant_fields(fields: Dictionary, fault: String = "", required_chapter: String = "") -> bool:
	_mutex.lock()
	var lock_abs: String = ProjectSettings.globalize_path(LOCK_PATH)
	# Atomic directory creation is the inter-process coordination mechanism.
	if DirAccess.make_dir_absolute(lock_abs) != OK:
		_mutex.unlock()
		push_warning("Outra gravação ou trava pendente: progresso não alterado.")
		return false
	var data: Dictionary = _best_valid()
	var invalid_existing: bool = data.is_empty() and (FileAccess.file_exists(PATH) or not _backup_names().is_empty())
	if required_chapter == "abbey" and not (data.get("guardian_defeated") == true and data.get("health_upgrade_unlocked") == true) and not (data.get("abbot_defeated") == true and data.get("dash_unlocked") == true): invalid_existing = true
	if required_chapter == "forest" and not (data.get("abbot_defeated") == true and data.get("dash_unlocked") == true): invalid_existing = true
	if required_chapter == "phase4" and not (data.get("cervo_defeated") == true and data.get("spectral_jump_unlocked") == true): invalid_existing = true
	var success: bool = false
	if not invalid_existing:
		var data_before_update: Dictionary = data.duplicate(true)
		var already: bool = true
		for key: String in fields:
			if data.get(key) != fields[key]: already = false
			data[key] = fields[key]
		if already and not fields.is_empty() and _equivalent(_load_valid(PATH), data) and _has_valid_backup(): success = true
		else: success = _save_locked(data, fault, data_before_update)
	var unlock_error: Error = DirAccess.remove_absolute(lock_abs)
	if unlock_error != OK: push_warning("Não foi possível liberar a trava de gravação.")
	_mutex.unlock()
	return success

static func unlocked() -> bool:
	var data: Dictionary = read_progress()
	return data.get("abbot_defeated") == true and data.get("dash_unlocked") == true

static func grant() -> bool:
	return _grant_fields({"abbot_defeated": true, "dash_unlocked": true})

static func guardian_reward_unlocked() -> bool:
	var data: Dictionary = read_progress()
	return data.get("guardian_defeated") == true and data.get("health_upgrade_unlocked") == true

static func grant_guardian_reward() -> bool:
	return _grant_fields({"guardian_defeated": true, "health_upgrade_unlocked": true})

static func is_flag_set(flag: String) -> bool:
	var data: Dictionary = read_progress()
	return data.get(flag) == true

static func is_cervo_defeated() -> bool:
	return is_flag_set("cervo_defeated")

static func spectral_jump_unlocked() -> bool:
	var data: Dictionary = read_progress()
	return data.get("cervo_defeated") == true and data.get("spectral_jump_unlocked") == true

static func grant_cervo_reward() -> bool:
	return _grant_fields({"cervo_defeated": true, "spectral_jump_unlocked": true})

static func grant_ember_guardian_reward() -> bool:
	return _grant_fields({"ember_guardian_defeated": true})

# Campaign location metadata is optional: legacy saves continue to use the
# original cemetery start. Callers must only store authored, safe checkpoints.
static func campaign_location() -> Dictionary:
	var data: Dictionary = read_progress()
	var chapter: Variant = data.get("current_chapter", "cemetery")
	if chapter not in ["cemetery", "abbey", "forest", "phase4"]:
		chapter = "cemetery"
	var checkpoint: Variant = data.get("campaign_checkpoint", "")
	if typeof(checkpoint) != TYPE_STRING:
		checkpoint = ""
	var highest: int = 0
	if data.get("guardian_defeated") == true and data.get("health_upgrade_unlocked") == true: highest = 1
	if data.get("abbot_defeated") == true and data.get("dash_unlocked") == true: highest = 2
	if data.get("cervo_defeated") == true and data.get("spectral_jump_unlocked") == true: highest = 3
	if data.get("ember_guardian_defeated") == true: highest = 4
	var requested: int = ["cemetery", "abbey", "forest", "phase4"].find(chapter)
	if requested > highest:
		chapter = "cemetery"
		checkpoint = ""
	return {"chapter": chapter, "highest_unlocked": highest, "checkpoint": checkpoint}

static func save_campaign_location(chapter: String, checkpoint: String) -> bool:
	if chapter not in ["cemetery", "abbey", "forest", "phase4"] or checkpoint.length() > 128:
		return false
	var location: Dictionary = campaign_location()
	if ["cemetery", "abbey", "forest", "phase4"].find(chapter) > location.highest_unlocked:
		return false
	return _grant_fields({"current_chapter": chapter, "campaign_checkpoint": checkpoint})

static func load_chapter_states(chapter: String) -> Dictionary:
	var value: Variant = read_progress().get("chapter_states_" + chapter, {})
	if not value is Dictionary: return {}
	var result: Dictionary = {}
	for key in value:
		if str(key).is_valid_int() and value[key] is Dictionary:
			result[int(key)] = value[key]
	return result

static func save_chapter_states(chapter: String, states: Dictionary, metadata: Dictionary = {}) -> bool:
	if chapter not in ["abbey", "forest", "phase4"]: return false
	var encoded: Dictionary = {}
	for key in states:
		if states[key] is Dictionary: encoded[str(key)] = states[key]
	return _grant_fields({"chapter_states_" + chapter: encoded, "chapter_metadata_" + chapter: metadata})

static func save_chapter_checkpoint(chapter: String, checkpoint: String, states: Dictionary, metadata: Dictionary = {}) -> bool:
	if chapter not in ["abbey", "forest", "phase4"] or checkpoint.length() > 128: return false
	var encoded: Dictionary = {}
	for key in states:
		if states[key] is Dictionary: encoded[str(key)] = states[key]
	return _grant_fields({"chapter_states_" + chapter: encoded, "chapter_metadata_" + chapter: metadata, "current_chapter": chapter, "campaign_checkpoint": checkpoint}, "", chapter)

static func load_chapter_metadata(chapter: String) -> Dictionary:
	var value: Variant = read_progress().get("chapter_metadata_" + chapter, {})
	return value if value is Dictionary else {}

static func sync_hero_progression(hero: Node) -> void:
	if hero == null: return
	if guardian_reward_unlocked():
		var survival = hero.get("survival")
		if survival != null and survival.get("max_health") != null and survival.max_health < 6:
			survival.max_health = 6
			if survival.has_method("restore"):
				survival.restore()
	if is_flag_set("dash_unlocked"):
		hero.set("dash_unlocked", true)
	if spectral_jump_unlocked():
		hero.set("spectral_jump_unlocked", true)

