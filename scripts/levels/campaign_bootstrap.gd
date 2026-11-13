extends Node2D
## Resume only on a normal launch; physical returns carry an explicit marker.
const PROGRESS = preload("res://scripts/abbey/abbey_progress.gd")
var _arrival: String = ""

func _enter_tree() -> void:
	_arrival = PROGRESS.get_pending_entrance()

func _ready() -> void:
	if _arrival != "":
		return
	var location: Dictionary = PROGRESS.campaign_location()
	var path: String = ""
	match location.chapter:
		"abbey": path = "res://scenes/abbey/abbey_chapter.tscn"
		"forest": path = "res://scenes/forest/forest_pilots.tscn"
		"phase4": path = "res://scenes/phase4/fornalha_phase.tscn"
	if path != "":
		PROGRESS.set_pending_entrance("resume")
		get_tree().change_scene_to_file.call_deferred(path)
