extends Node2D
## Local M3-A/B1 bindings; homologated terrain, camera and respawn rules retained.

const SECTOR_STARTS: Array[float] = [0.0, 384.0, 768.0, 1152.0, 1536.0, 1984.0]
const SECTOR_NAMES: Array[String] = [
	"1/6 Portões do Cemitério", "2/6 Caminho das Lápides",
	"3/6 Jardim dos Mortos", "4/6 Catacumbas",
	"5/6 Ponte das Almas", "6/6 Portão da Catedral"
]
const FALL_LIMIT: float = 288.0
const ABBEY_PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
var transitioning: bool = false
@onready var knight: KnightController = $Knight
@onready var spawn: Marker2D = $Spawn
@onready var camera: Camera2D = $Camera2D
@onready var sector_label: Label = $StageHUD/Sector
@onready var hint_label: Label = $StageHUD/Hint

func _ready() -> void:
	process_physics_priority = 1
	knight.set_default_respawn(spawn.global_position)
	knight.survival.respawn_requested.connect(knight.respawn_at_checkpoint)
	knight.survival.respawn_requested.connect(_restore_enemies)
	for enemy: Node in $Enemies.get_children():
		if enemy is SkeletonPatrol:
			_configure_skeleton_patrol(enemy as SkeletonPatrol)
			(enemy as SkeletonPatrol).target = knight
		elif enemy is CursedRaven:
			_configure_raven_patrol(enemy as CursedRaven)
			(enemy as CursedRaven).target = knight
	$HealthHUD.bind(knight.survival)
	ABBEY_PROGRESS.sync_hero_progression(knight)
	var arrival: String = ABBEY_PROGRESS.consume_pending_entrance()
	if arrival == "from_abbey":
		knight.reset_to(Vector2(2296, 156))
		knight.facing = -1
		knight.set_default_respawn(Vector2(1936, 156))
		ABBEY_PROGRESS.save_campaign_location("cemetery", "entry_east")
	else:
		knight.reset_to(spawn.global_position)
	for cp: RespawnCheckpoint in [$Mechanisms/Checkpoint1, $Mechanisms/Checkpoint2]:
		cp.activated.connect(_checkpoint_activated.bind(cp))
	if arrival == "" and ABBEY_PROGRESS.campaign_location().chapter == "cemetery":
		var name: String = ABBEY_PROGRESS.campaign_location().checkpoint
		if name in ["Checkpoint1", "Checkpoint2"]:
			await get_tree().physics_frame
			var cp: RespawnCheckpoint = $Mechanisms.get_node(name)
			knight.activate_checkpoint(cp)
			if knight.active_checkpoint == cp: knight.reset_to(cp.respawn_point.global_position)
		elif name == "entry_east":
			knight.reset_to(Vector2(2296, 156))
			knight.facing = -1
			knight.set_default_respawn(Vector2(1936, 156))
	_update_presentation()

func _configure_skeleton_patrol(enemy: SkeletonPatrol) -> void:
	# Use the authored floor under this spawn rather than extending the
	# per-instance interval across a step, gap, wall or nearby mechanism.
	var spawn_pos: Vector2 = enemy.global_position
	for body: Node in $WorldGeometry.get_children():
		if not body is StaticBody2D:
			continue
		var collider := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if collider == null or not collider.shape is RectangleShape2D:
			continue
		var shape := collider.shape as RectangleShape2D
		var floor_rect := Rect2(collider.global_position - shape.size * 0.5, shape.size)
		if absf(floor_rect.position.y - spawn_pos.y) > 2.0 or spawn_pos.x < floor_rect.position.x or spawn_pos.x > floor_rect.end.x:
			continue
		var left: float = maxf(floor_rect.position.x + 12.0, spawn_pos.x - 100.0)
		var right: float = minf(floor_rect.end.x - 12.0, spawn_pos.x + 100.0)
		var local_x: float = to_local(spawn_pos).x
		var sector: int = 0
		for i in range(SECTOR_STARTS.size()):
			if local_x >= SECTOR_STARTS[i]: sector = i
		left = maxf(left, to_global(Vector2(SECTOR_STARTS[sector] + 12.0, 0)).x)
		right = minf(right, to_global(Vector2(SECTOR_STARTS[sector + 1] - 12.0 if sector + 1 < SECTOR_STARTS.size() else 2340.0, 0)).x)
		for mechanism: Node in $Mechanisms.get_children():
			if not mechanism is Node2D:
				continue
			var other: Vector2 = (mechanism as Node2D).global_position
			if absf(other.y - spawn_pos.y) > 40.0:
				continue
			if other.x < spawn_pos.x:
				left = maxf(left, other.x + 36.0)
			elif other.x > spawn_pos.x:
				right = minf(right, other.x - 36.0)
		enemy.patrol_left = minf(0.0, left - spawn_pos.x)
		enemy.patrol_right = maxf(0.0, right - spawn_pos.x)
		return

func _configure_raven_patrol(enemy: CursedRaven) -> void:
	var local_x: float = to_local(enemy.global_position).x
	var sector: int = 0
	for i in range(SECTOR_STARTS.size()):
		if local_x >= SECTOR_STARTS[i]: sector = i
	enemy.flight_min_x = to_global(Vector2(SECTOR_STARTS[sector] + 12.0, 0)).x
	enemy.flight_max_x = to_global(Vector2(SECTOR_STARTS[sector + 1] - 12.0 if sector + 1 < SECTOR_STARTS.size() else 2340.0, 0)).x
	enemy.flight_scan_enabled = true

func _checkpoint_activated(cp: RespawnCheckpoint) -> void:
	if knight.active_checkpoint == cp:
		ABBEY_PROGRESS.save_campaign_location("cemetery", str(cp.name))

func _physics_process(_delta: float) -> void:
	# Same alive-fall semantics as M0/M2; lower boundary accommodates the crypt.
	if knight.global_position.y > FALL_LIMIT and not knight.survival.is_dead:
		knight.reset_to(spawn.global_position)
		_restore_enemies()
	var encounter = get_parent().get_node_or_null("GuardianEncounter")
	var in_boss_arena: bool = encounter != null and encounter.active
	if not in_boss_arena and not transitioning and not knight.survival.is_dead and knight.position.x >= 2340.0 and knight.position.x <= 2375.0 and ABBEY_PROGRESS.guardian_reward_unlocked():
		transitioning = true
		ABBEY_PROGRESS.set_pending_entrance("from_cemetery")
		var tree: SceneTree = get_tree()
		if tree != null:
			if tree.current_scene == null:
				var main_root: Node = self
				while main_root.get_parent() != null and main_root.get_parent() != tree.root:
					main_root = main_root.get_parent()
				tree.current_scene = main_root
			tree.change_scene_to_file.call_deferred("res://scenes/abbey/abbey_chapter.tscn")
		return
	_update_presentation()

func _restore_enemies() -> void:
	for enemy: Node in $Enemies.get_children():
		if enemy is SkeletonPatrol:
			(enemy as SkeletonPatrol).reset_enemy()
		elif enemy is CursedRaven:
			(enemy as CursedRaven).reset_enemy()
	if has_node("Mechanisms"):
		for mechanism: Node in $Mechanisms.get_children():
			if mechanism is OscillatingBlade:
				(mechanism as OscillatingBlade).reset_hazard()
			elif mechanism is TimedSpikes:
				(mechanism as TimedSpikes).reset_hazard()

func sector_at(x: float) -> int:
	for index: int in range(SECTOR_STARTS.size() - 1, -1, -1):
		if x >= SECTOR_STARTS[index]:
			return index
	return 0

func _update_presentation() -> void:
	# Vertical follow is limited to 64 px for the underground section.
	# Reveal the next descending tread before stepping off either crypt entrance.
	var crypt_weight: float = minf(clampf((knight.position.x - 1056.0) / 32.0, 0.0, 1.0),
		clampf((1600.0 - knight.position.x) / 32.0, 0.0, 1.0))
	var vertical_offset: float = lerpf(66.0, 54.0, crypt_weight)
	camera.position = Vector2(
		clampf(roundf(knight.position.x), 160.0, 2208.0),
		clampf(roundf(knight.position.y - vertical_offset), 90.0, 154.0))
	var sector: int = sector_at(knight.position.x)
	sector_label.text = SECTOR_NAMES[sector]
	hint_label.text = ""
	if sector == 0:
		hint_label.text = "INÍCIO  |  A/D: andar  Espaço: pular  J: espada"
	elif absf(knight.position.x - $FutureCheckpoint1.position.x) < 64.0:
		hint_label.text = "CP1 — retorno após morte"
	elif absf(knight.position.x - $FutureCheckpoint2.position.x) < 48.0:
		hint_label.text = "CP2 — retorno após morte"
	elif knight.position.x >= $Finish.position.x - 32.0:
		if ABBEY_PROGRESS.guardian_reward_unlocked():
			hint_label.text = "Portão da Catedral aberto: avance à direita para a Abadia Silenciosa"
		else:
			hint_label.text = "Portão da Catedral selado pelo Guardião"
