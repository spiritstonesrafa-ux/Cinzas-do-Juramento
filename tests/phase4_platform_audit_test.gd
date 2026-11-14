extends SceneTree

const PHASE: PackedScene = preload("res://scenes/phase4/fornalha_phase.tscn")
const DOUBLE_JUMP_MARGIN: float = 75.0
const PLAYER_HALF_WIDTH: float = 6.0

var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var phase := PHASE.instantiate()
	root.add_child(phase)
	await physics_frame
	var floors: Array[Rect2] = phase.map_floors()
	_check(floors.size() >= 70, "fase carrega o mapa completo de plataformas")
	_check_route(floors, Rect2(480, 420, 580, 720), Vector2(650, 1080), Vector2(650, 860), "entrada do Poço até galeria intermediária")
	_check_route(floors, Rect2(480, 420, 580, 720), Vector2(650, 860), Vector2(830, 600), "galeria do Poço até rota superior")
	_check_route(floors, Rect2(2300, 580, 740, 600), Vector2(2500, 1100), Vector2(2600, 810), "piso baixo do Santuário até a subida do chefe")
	phase.queue_free()
	await process_frame
	if failures == 0:
		print("PASS: auditoria de plataformas da Fase 4 (3 rotas)")
		quit(0)
	else:
		printerr("FAIL: %d falha(s) na auditoria de plataformas da Fase 4" % failures)
		quit(1)

func _check_route(floors: Array[Rect2], region: Rect2, start: Vector2, goal: Vector2, label: String) -> void:
	var local: Array[Rect2] = []
	for floor: Rect2 in floors:
		if region.intersects(floor):
			local.append(floor)
	var start_index: int = _nearest_floor(local, start)
	var goal_index: int = _nearest_floor(local, goal)
	if start_index < 0 or goal_index < 0:
		_check(false, "%s: plataformas de início e destino existem" % label)
		return
	var visited: Array[bool] = []
	visited.resize(local.size())
	visited.fill(false)
	var queue: Array[int] = [start_index]
	visited[start_index] = true
	var cursor: int = 0
	while cursor < queue.size():
		var current_index: int = queue[cursor]
		cursor += 1
		for next_index: int in range(local.size()):
			if visited[next_index] or not _can_jump_between(local[current_index], local[next_index]):
				continue
			visited[next_index] = true
			queue.append(next_index)
	_check(visited[goal_index], "%s: rota contínua dentro do alcance de salto duplo" % label)

func _nearest_floor(floors: Array[Rect2], point: Vector2) -> int:
	var best_index: int = -1
	var best_distance: float = INF
	for i: int in range(floors.size()):
		var floor: Rect2 = floors[i]
		var dx: float = maxf(maxf(floor.position.x - point.x, 0.0), point.x - floor.end.x)
		var distance: float = dx + absf(floor.position.y - point.y)
		if distance < best_distance:
			best_distance = distance
			best_index = i
	return best_index

func _can_jump_between(from: Rect2, to: Rect2) -> bool:
	if from == to:
		return false
	var rise: float = from.position.y - to.position.y
	if rise > DOUBLE_JUMP_MARGIN:
		return false
	var from_left: float = from.position.x - PLAYER_HALF_WIDTH
	var from_right: float = from.end.x + PLAYER_HALF_WIDTH
	var to_left: float = to.position.x - PLAYER_HALF_WIDTH
	var to_right: float = to.end.x + PLAYER_HALF_WIDTH
	return from_left <= to_right and to_left <= from_right

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: %s" % message)
	else:
		failures += 1
		printerr("FAIL: %s" % message)
