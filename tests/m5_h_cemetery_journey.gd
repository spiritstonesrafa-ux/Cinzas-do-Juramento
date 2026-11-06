extends "res://tests/distribution_test.gd"
## Same physical traversal as the historical suite, on the actual M5-H scene.

func _run() -> void:
 var main: Node = load("res://scenes/main.tscn").instantiate()
 root.add_child(main)
 _stage = main.get_node("ForgottenCemetery")
 _knight = _stage.get_node("Knight")
 _camera = _stage.get_node("Camera2D")
 _enemies = _stage.get_node("Enemies")
 await _frames(5)
 _check(_enemies.get_child_count() == 12, "actual scene contains 12 live enemies")
 _check(not _knight.dash_unlocked, "fresh progress starts without dash")
 var reached: bool = await _traverse(1, 2290.0)
 _check(reached and not _knight.survival.is_dead, "actual cemetery reached boss approach without dash")
 print("M5-H cemetery journey checks: %d failures: %d" % [_checks,_failures])
 main.queue_free()
 await _frames(2)
 quit(1 if _failures else 0)
