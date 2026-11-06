extends SceneTree
## Geometry screening only, no jump or live traversal claims.
const CASES: Dictionary={
 2:[Rect2(830,336,48,12),Rect2(890,312,48,12),Rect2(950,288,48,12)],
 4:[Rect2(540,380,48,12),Rect2(600,404,48,12),Rect2(660,428,48,12)],
 6:[Rect2(860,284,48,12),Rect2(920,260,48,12),Rect2(980,236,48,12)],
 8:[Rect2(1100,212,48,12),Rect2(1160,188,48,12),Rect2(1220,188,48,12)],
 9:[Rect2(680,260,48,12),Rect2(740,284,48,12),Rect2(800,284,48,12)]
}
func _initialize() -> void:
 for id: int in CASES:
  for proposed: Rect2 in CASES[id]:
   for floor: Rect2 in AbbeyChapterLayout.main_surfaces(id):
    if proposed.position.x<floor.end.x and proposed.end.x>floor.position.x:
     var clearance: float=floor.position.y-proposed.end.y
     print("S%d candidate=%s main=%s underside_clearance=%.1f safe_body_24_plus_margin=%s" % [id+1,proposed,floor,clearance,clearance>=27])
   for ceiling: Rect2 in AbbeyChapterLayout.ceilings(id):
    if proposed.intersects(ceiling): print("S%d DIRECT CEILING OVERLAP %s" % [id+1,proposed])
 print("GEOMETRIC SCREEN ONLY; no physics and no production nodes")
 quit()
