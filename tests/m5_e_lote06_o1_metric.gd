extends SceneTree
## Design reference polyline: centers of optional tops, followed by descent junction.
func _initialize() -> void:
 var points: Array[Vector2]=[Vector2(756,156),Vector2(816,132),Vector2(872,108),Vector2(936,84),Vector2(992,60),Vector2(1052,84),Vector2(1148,108),Vector2(1208,108),Vector2(1219,228)]
 var upper: float=0.0
 for i: int in range(1,points.size()-1): upper+=points[i-1].distance_to(points[i])
 var descent: float=points[-2].distance_to(points[-1])
 print("O1 reference upper_polyline=%.4f descent_chord=%.4f total=%.4f horizontal_projection=%.4f" % [upper,descent,upper+descent,points[-2].x-points[0].x])
 print("Reference chords across jumps and drop are not cumulative player movement or new map width.")
 quit(0)
