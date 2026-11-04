extends Node2D
## One modular room; approved pilot packed scenes are instanced unchanged.
@export_range(0,11,1) var sector_id: int = 0
var pilot: Node2D
var art: Node2D
func _ready() -> void:
 var p: int = AbbeyChapterLayout.pilot_id(sector_id)
 if p>=0:
  pilot=(load("res://scenes/abbey/cloister_pilot.tscn" if p==0 else "res://scenes/abbey/gallery_pilot.tscn") as PackedScene).instantiate()
  add_child(pilot)
 var geometry: Node2D=Node2D.new()
 geometry.name="Geometry"
 add_child(geometry)
 var rects: Array[Rect2]=AbbeyChapterLayout.main_surfaces(sector_id)
 if p>=0: rects=[Rect2(960,228 if p==0 else 300,320,192 if p==0 else 120)]
 rects.append_array(AbbeyChapterLayout.ceilings(sector_id))
 for r: Rect2 in rects:
  var body: StaticBody2D=StaticBody2D.new()
  body.position=r.position
  body.collision_layer=1
  body.collision_mask=2|256
  var collider: CollisionShape2D=CollisionShape2D.new()
  var shape: RectangleShape2D=RectangleShape2D.new()
  shape.size=r.size
  collider.shape=shape
  collider.position=r.size/2
  body.add_child(collider)
  geometry.add_child(body)
 art=Node2D.new()
 art.name="SectorArt"
 art.set_script(load("res://scripts/abbey/chapter_art.gd"))
 art.z_index=-1
 add_child(art)
 # Data markers only: no fake threats or promised rewards.
 var future: Node2D=Node2D.new()
 future.name="FutureIntegration"
 add_child(future)
 var main: Array[Rect2]=AbbeyChapterLayout.main_surfaces(sector_id)
 for i: int in [int(main.size()/3.0),int(main.size()*2/3.0)]:
  var marker: Marker2D=Marker2D.new()
  marker.name="EncounterReserve"+str(i)
  marker.position=main[i].position+Vector2(main[i].size.x/2,0)
  marker.set_meta("scope","M5-C: design and safety validation required")
  future.add_child(marker)
 if sector_id in [1,2,4,6,8,9]:
  var branch: Marker2D=Marker2D.new()
  branch.name="OptionalReserve"
  branch.position=main[int(main.size()/2.0)].position+Vector2(24,-64)
  branch.set_meta("scope","M5-E: reserved envelope; not a playable secret")
  future.add_child(branch)
 if sector_id in [3,7,10]:
  var shortcut: Marker2D=Marker2D.new()
  shortcut.name="ShortcutReserve"
  shortcut.position=main[0].position+Vector2(24,-64)
  shortcut.set_meta("scope","M5-E: no active shortcut or reduced main route")
  future.add_child(shortcut)
func snapshot() -> Dictionary:
 return pilot.snapshot() if is_instance_valid(pilot) else {}
func restore_state(data: Dictionary) -> void:
 if is_instance_valid(pilot): pilot.restore_state(data)
func reset_encounters() -> void:
 if is_instance_valid(pilot): pilot.reset_encounters()
func disarm() -> void:
 if is_instance_valid(pilot): pilot.disarm()
