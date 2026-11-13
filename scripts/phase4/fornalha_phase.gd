extends Node2D
## Fase 4: um labirinto contínuo de galerias e poços, com rotas em laço.

const PROGRESS: Script = preload("res://scripts/abbey/abbey_progress.gd")
const CHECKPOINT: PackedScene = preload("res://scenes/props/respawn_checkpoint.tscn")
const FURNACE_HAZARD: Script = preload("res://scripts/phase4/furnace_hazard.gd")
const FURNACE_ENEMY: Script = preload("res://scripts/phase4/furnace_enemy.gd")
const FURNACE_ENCOUNTERS: Array[Dictionary] = [
	{"kind":0,"point":Vector2(210,1100),"roam":32}, {"kind":1,"point":Vector2(410,1100),"roam":28},
	{"kind":0,"point":Vector2(610,1080),"roam":42}, {"kind":2,"point":Vector2(720,990),"roam":34},
	{"kind":1,"point":Vector2(835,1300),"roam":35}, {"kind":0,"point":Vector2(1170,1300),"roam":48},
	{"kind":1,"point":Vector2(1370,1300),"roam":42}, {"kind":2,"point":Vector2(1550,1160),"roam":38},
	{"kind":0,"point":Vector2(500,880),"roam":35}, {"kind":1,"point":Vector2(740,860),"roam":40},
	{"kind":0,"point":Vector2(1120,880),"roam":52}, {"kind":2,"point":Vector2(1350,760),"roam":42},
	{"kind":1,"point":Vector2(1520,860),"roam":44}, {"kind":0,"point":Vector2(1740,840),"roam":48},
	{"kind":1,"point":Vector2(1900,910),"roam":40}, {"kind":0,"point":Vector2(2130,860),"roam":45},
	{"kind":2,"point":Vector2(2350,790),"roam":44}, {"kind":1,"point":Vector2(2420,990),"roam":34},
	{"kind":0,"point":Vector2(2580,870),"roam":38}
]

const ZONES: Array[Dictionary] = [
	{"name":"Boca da Mina", "bounds":Rect2(0, 780, 620, 420)},
	{"name":"Poço dos Guinchos", "bounds":Rect2(480, 420, 580, 520)},
	{"name":"Galeria de Cinza", "bounds":Rect2(940, 650, 650, 420)},
	{"name":"Câmara das Caldeiras", "bounds":Rect2(1480, 400, 620, 520)},
	{"name":"Canal de Resfriamento", "bounds":Rect2(900, 1030, 850, 400)},
	{"name":"Arquivo do Juramento", "bounds":Rect2(1900, 650, 560, 420)},
	{"name":"Canal de Resfriamento", "bounds":Rect2(1675, 1030, 715, 400)},
	{"name":"Santuário das Brasas", "bounds":Rect2(2360, 730, 660, 620)}
]

const FLOORS: Array[Rect2] = [
	# Boca da Mina and the lower return corridor.
	Rect2(0, 1100, 300, 220), Rect2(345, 1100, 155, 220), Rect2(545, 1080, 245, 240),
	Rect2(780, 1300, 260, 120), Rect2(1040, 1300, 365, 120), Rect2(1405, 1300, 270, 120),
	Rect2(1675, 1280, 365, 140), Rect2(2040, 1280, 350, 140), Rect2(2390, 1100, 240, 220),
	Rect2(2630, 1100, 410, 220),
	# Mid-level galleries: connected back through two vertical shafts.
	Rect2(410, 880, 205, 16), Rect2(650, 860, 260, 16), Rect2(960, 880, 330, 16),
	Rect2(1350, 860, 270, 16), Rect2(1660, 840, 285, 16), Rect2(1990, 860, 255, 16),
	Rect2(2270, 840, 225, 16),
	# Upper route through the furnace roofs and the archive.
	Rect2(585, 620, 210, 16), Rect2(830, 600, 230, 16), Rect2(1095, 620, 300, 16),
	Rect2(1430, 600, 250, 16), Rect2(1705, 580, 275, 16), Rect2(2010, 600, 250, 16),
	Rect2(2290, 610, 170, 16),
	# Steps and narrow ledges inside the hoist and boiler stacks.
	Rect2(475, 790, 74, 14), Rect2(535, 720, 74, 14), Rect2(600, 680, 78, 14),
	Rect2(890, 780, 78, 14), Rect2(950, 710, 80, 14), Rect2(1010, 650, 80, 14),
	Rect2(1280, 800, 82, 14), Rect2(1340, 730, 82, 14), Rect2(1400, 670, 82, 14),
	Rect2(1760, 770, 80, 14), Rect2(1825, 700, 80, 14), Rect2(1890, 640, 80, 14),
	# Descents to the bottom loop and hidden side path.
	Rect2(650, 1010, 120, 14), Rect2(800, 1080, 115, 14), Rect2(1110, 1010, 130, 14),
	Rect2(1265, 1080, 140, 14), Rect2(1530, 990, 115, 14), Rect2(1670, 1050, 130, 14),
	Rect2(1900, 1000, 130, 14), Rect2(2055, 1060, 130, 14), Rect2(2220, 1020, 135, 14),
	# Canal escape stair: short, overlapping steps remain climbable with the normal jump.
	Rect2(1420, 1270, 64, 14), Rect2(1460, 1240, 64, 14), Rect2(1500, 1210, 64, 14),
	Rect2(1540, 1180, 64, 14), Rect2(1580, 1150, 64, 14), Rect2(1620, 1120, 64, 14),
	Rect2(1660, 1090, 64, 14), Rect2(1700, 1060, 64, 14), Rect2(1740, 1030, 64, 14),
	Rect2(1780, 1000, 64, 14), Rect2(1820, 970, 64, 14), Rect2(1860, 940, 64, 14),
	Rect2(1900, 910, 64, 14), Rect2(1940, 880, 64, 14), Rect2(1980, 850, 70, 14),
	# Continuous climb from the canal stair back to the upper route, without a long drop.
	Rect2(2015, 780, 96, 14), Rect2(2085, 710, 96, 14),
	Rect2(2155, 640, 96, 14), Rect2(2225, 610, 100, 14),
	# Final climb into the boss sanctuary.
	Rect2(2350, 990, 92, 14), Rect2(2430, 930, 92, 14), Rect2(2510, 870, 92, 14),
	Rect2(2600, 810, 110, 14), Rect2(2720, 860, 110, 14), Rect2(2825, 940, 125, 14)
]

@onready var hero: KnightController = $Knight
@onready var camera: Camera2D = $Camera2D
@onready var title: Label = $HUD/Title
@onready var area_label: Label = $HUD/Area
@onready var hint: Label = $HUD/Hint

var checkpoints: Array[RespawnCheckpoint] = []
var _damage_writer: Thread
var _zone_id: int = -1
var _returning: bool = false
var _boss_defeated: bool = false

func _ready() -> void:
	# Run the camera follow after Knight's physics step, so it tracks the
	# position the player just reached instead of lagging one physics tick.
	process_physics_priority = 1
	for rect: Rect2 in FLOORS:
		_add_floor(rect)
	_add_hot_vent(Rect2(300, 1092, 45, 8))
	_add_hot_vent(Rect2(1040, 1292, 82, 8))
	_add_hot_vent(Rect2(2038, 1272, 74, 8))
	_add_checkpoint(Vector2(1010, 1300), "fornalha_midway")
	_add_checkpoint(Vector2(2110, 860), "fornalha_archive")
	_add_boss()
	_add_phase4_enemies()
	hero.set_default_respawn(Vector2(50, 1100))
	hero.survival.respawn_requested.connect(_on_respawn)
	$HealthHUD.bind(hero.survival)
	var arrival: String = PROGRESS.consume_pending_entrance()
	if arrival == "resume":
		var saved: Dictionary = PROGRESS.campaign_location()
		for checkpoint: RespawnCheckpoint in checkpoints:
			if checkpoint.name == saved.checkpoint:
				hero.activate_checkpoint(checkpoint)
				if hero.active_checkpoint == checkpoint:
					hero.reset_to(checkpoint.respawn_point.global_position)
				break
	if arrival == "from_forest":
		PROGRESS.save_campaign_location("phase4", "FornalhaEntry")
	var boss: EmberGuardian = $Actors/Boss as EmberGuardian
	boss.defeated.connect(_on_boss_defeated)
	$HUD/TitanBossBar.boss = boss
	_update_camera()

func _add_floor(rect: Rect2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.collision_layer = 1
	body.collision_mask = 2
	body.position = rect.position + rect.size * 0.5
	var shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	if rect.size.y <= 16.0:
		shape.one_way_collision = true
	body.add_child(shape)
	$Geometry.add_child(body)

func _add_hot_vent(rect: Rect2) -> void:
	var vent: DamageSource = FURNACE_HAZARD.new()
	vent.name = "EscoriaViva"
	vent.collision_layer = 32
	vent.collision_mask = 0
	vent.set("vent_width", rect.size.x)
	vent.set("vent_height", rect.size.y)
	vent.position = rect.position + rect.size * 0.5
	var shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = rect.size
	shape.shape = box
	vent.add_child(shape)
	$Hazards.add_child(vent)

func _add_checkpoint(spawn: Vector2, token: String) -> void:
	var checkpoint: RespawnCheckpoint = CHECKPOINT.instantiate() as RespawnCheckpoint
	checkpoint.name = token
	checkpoint.position = spawn
	checkpoint.get_node("RespawnPoint").position = Vector2(-24, 0)
	checkpoint.activated.connect(_on_checkpoint.bind(checkpoint, token))
	$Checkpoints.add_child(checkpoint)
	checkpoints.append(checkpoint)

func _add_boss() -> void:
	var boss: EmberGuardian = EmberGuardian.new()
	boss.name = "Boss"
	boss.position = Vector2(2890, 1100)
	boss.target = hero
	$Actors.add_child(boss)
	var hazard: DamageSource = FURNACE_HAZARD.new()
	hazard.name = "Brasas do Titã"
	hazard.collision_layer = 32
	hazard.position = Vector2(2800, 1087)
	var shape: CollisionShape2D = CollisionShape2D.new()
	var box: RectangleShape2D = RectangleShape2D.new()
	box.size = Vector2(20, 8)
	shape.shape = box
	hazard.add_child(shape)
	$Hazards.add_child(hazard)

func _add_phase4_enemies() -> void:
	for index: int in range(FURNACE_ENCOUNTERS.size()):
		var data: Dictionary = FURNACE_ENCOUNTERS[index]
		var enemy := FURNACE_ENEMY.new() as CharacterBody2D
		enemy.name = "InimigoForja_%02d" % (index + 1)
		enemy.call("configure", int(data.kind), hero, data.point.x - float(data.roam), data.point.x + float(data.roam))
		enemy.position = data.point
		$Actors.add_child(enemy)

func _on_checkpoint(checkpoint: RespawnCheckpoint, token: String) -> void:
	if hero.active_checkpoint != checkpoint:
		return
	_finish_save()
	_damage_writer = Thread.new()
	var job: Callable = Callable(PROGRESS, "save_chapter_checkpoint").bind("phase4", token, {}, {})
	if _damage_writer.start(job) != OK:
		_damage_writer = null
		if not job.call(): push_warning("Checkpoint da Fornalha não pôde ser salvo.")

func _finish_save() -> void:
	if _damage_writer != null:
		if not bool(_damage_writer.wait_to_finish()): push_warning("Checkpoint da Fornalha não pôde ser salvo.")
		_damage_writer = null

func _exit_tree() -> void:
	_finish_save()

func _on_respawn() -> void:
	hero.respawn_at_checkpoint()
	var boss: EmberGuardian = $Actors/Boss as EmberGuardian
	if not _boss_defeated and is_instance_valid(boss):
		boss.reset_encounter()

func _on_boss_defeated() -> void:
	_boss_defeated = true
	PROGRESS.grant_ember_guardian_reward()
	hint.text = "O Titã Ossuário caiu. O elevador antigo voltou a funcionar."

func _physics_process(_delta: float) -> void:
	_update_camera()
	queue_redraw()
	if hero.survival.is_dead:
		return
	var boss: EmberGuardian = $Actors/Boss as EmberGuardian
	if not boss.active and absf(hero.global_position.x - boss.global_position.x) < 250.0:
		boss.activate()
	elif boss.active and absf(hero.global_position.x - boss.global_position.x) > 330.0:
		boss.active = false
		if boss.state != EmberGuardian.Attack.DEAD:
			boss.state = EmberGuardian.Attack.IDLE
			boss.timer = 0.65
	if hero.global_position.y > 1460.0:
		hero.reset_to(hero.active_checkpoint.respawn_point.global_position if is_instance_valid(hero.active_checkpoint) else Vector2(50, 1100))
	var next_zone: int = _zone_for(hero.global_position)
	if next_zone != _zone_id:
		_zone_id = next_zone
		if _zone_id >= 0: area_label.text = str(ZONES[_zone_id].name)
	if hero.global_position.x < 4.0 and hero.facing < 0 and not _returning:
		_return_to_forest()
	elif _boss_defeated and hero.global_position.x > 3030.0 and hero.facing > 0:
		hint.text = "A saída para a Fortaleza Central estará acessível na próxima etapa."

func _zone_for(point: Vector2) -> int:
	for i: int in range(ZONES.size()):
		if (ZONES[i].bounds as Rect2).has_point(point): return i
	return -1

func _update_camera() -> void:
	camera.position = Vector2(clampf(hero.global_position.x, 160.0, 2880.0), clampf(hero.global_position.y - 32.0, 90.0, 1330.0)).round()

func _return_to_forest() -> void:
	_returning = true
	PROGRESS.set_pending_entrance("from_phase4")
	PROGRESS.save_campaign_location("forest", "entry_east")
	get_tree().change_scene_to_file.call_deferred("res://scenes/forest/forest_pilots.tscn")

func map_floors() -> Array[Rect2]:
	return FLOORS

func map_zones() -> Array[Dictionary]:
	return ZONES
