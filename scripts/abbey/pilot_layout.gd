class_name AbbeyPilotLayout
extends RefCounted
## Pilot budgets are independent of the future twelve-sector region.
const ROOM_SIZE: Vector2 = Vector2(960, 420)
const ORIGINS: Array[Vector2] = [Vector2.ZERO, Vector2(1200, 0)]
const NAMES: Array[String] = ["Claustro das Sombras", "Galeria dos Penitentes"]
const MAIN: Array[Rect2] = [
 Rect2(0,300,224,120), Rect2(224,276,64,144), Rect2(288,252,64,168),
 Rect2(352,228,96,192), Rect2(448,204,64,216), Rect2(512,180,160,240),
 Rect2(672,156,96,264), Rect2(768,180,64,240), Rect2(832,204,64,216),
 Rect2(896,228,64,192)
]
const OPTIONAL: Array[Rect2] = [Rect2(792,132,48,12), Rect2(848,108,48,12), Rect2(912,84,48,12)]
static func surfaces(id: int) -> Array[Rect2]:
 var result: Array[Rect2] = []
 if id == 0:
  result.assign(MAIN)
  result.append_array(OPTIONAL)
 else:
  result.assign([Rect2(0,300,960,120), Rect2(80,276,96,12), Rect2(648,276,80,12)])
 return result
static func entry(id: int, from_right: bool = false) -> Vector2:
 if from_right: return ORIGINS[id] + Vector2(904, 228 if id == 0 else 300)
 return ORIGINS[id] + Vector2(48,300)
