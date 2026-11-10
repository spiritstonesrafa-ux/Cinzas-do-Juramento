class_name ForestSector
extends Node2D
## Instancia corpos físicos, gerencia limites e controla encontros/persistência
## para os setores da Floresta dos Ossos (M6-A a M6-C1).

@export_range(0, 9, 1) var sector_id: int = 0

const ForestEncounterLayout = preload("res://scripts/forest/forest_encounter_layout.gd")
const ForestCrawler = preload("res://scripts/enemies/forest_crawler.gd")
const ForestSentinel = preload("res://scripts/enemies/forest_sentinel.gd")
const ForestSpectralCrow = preload("res://scripts/enemies/forest_spectral_crow.gd")
const ForestFossilSpikes = preload("res://scripts/props/forest_fossil_spikes.gd")

const CRAWLER_SCENE: PackedScene = preload("res://scenes/enemies/forest_crawler.tscn")
const SENTINEL_SCENE: PackedScene = preload("res://scenes/enemies/forest_sentinel.tscn")
const CROW_SCENE: PackedScene = preload("res://scenes/enemies/forest_spectral_crow.tscn")
const SPIKES_SCENE: PackedScene = preload("res://scenes/props/forest_fossil_spikes.tscn")
const CervoBossArena = preload("res://scripts/boss/cervo_boss_arena.gd")

var world_geometry: Node2D
var encounters: Node2D
var enemies: Array = []
var hazards: Array = []
var hero: KnightController = null
var arena: CervoBossArena = null

func _ready() -> void:
	world_geometry = Node2D.new()
	world_geometry.name = "Geometry"
	add_child(world_geometry)
	_build_surfaces()
	
	encounters = Node2D.new()
	encounters.name = "Encounters"
	add_child(encounters)
	_build_encounters()
	
	var boss_arena_node: Node = get_node_or_null("ClearingEncounter")
	if boss_arena_node == null:
		boss_arena_node = get_node_or_null("BossArena")
	if boss_arena_node != null:
		arena = boss_arena_node as CervoBossArena
	
	if hero == null:
		var parent_node: Node = get_parent()
		if parent_node != null and parent_node.get_parent() != null:
			var demo = parent_node.get_parent()
			if "hero" in demo and demo.hero != null:
				set_hero(demo.hero)

func set_hero(p_hero: KnightController) -> void:
	hero = p_hero
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.target = hero
	if is_instance_valid(arena):
		arena.set_hero(hero)

func _build_surfaces() -> void:
	var index: int = 0
	for rect: Rect2 in ForestLayout.surfaces(sector_id):
		var body: StaticBody2D = StaticBody2D.new()
		body.name = "Surface%02d" % index
		body.position = rect.position
		body.collision_layer = 1
		body.collision_mask = 2 | 256
		
		var collider: CollisionShape2D = CollisionShape2D.new()
		collider.name = "Collision"
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = rect.size
		collider.shape = shape
		collider.position = rect.size * 0.5
		if rect.size.y <= 16.0:
			collider.one_way_collision = true
		
		body.add_child(collider)
		world_geometry.add_child(body)
		index += 1

func _build_encounters() -> void:
	enemies.clear()
	hazards.clear()
	var configs: Array[Dictionary] = ForestEncounterLayout.get_encounters_for_sector(sector_id)
	for item: Dictionary in configs:
		var mob_id: String = item.get("id", "")
		var mob_type: String = item.get("type", "")
		var pos: Vector2 = item.get("position", Vector2.ZERO)
		match mob_type:
			"crawler":
				var crawler: ForestCrawler = CRAWLER_SCENE.instantiate() as ForestCrawler
				crawler.encounter_id = mob_id
				crawler.name = mob_id
				crawler.position = pos
				crawler.patrol_left = item.get("patrol_left", -40.0)
				crawler.patrol_right = item.get("patrol_right", 40.0)
				crawler.facing = item.get("facing", -1)
				if hero != null:
					crawler.target = hero
				encounters.add_child(crawler)
				enemies.append(crawler)
			"sentinel":
				var sentinel: ForestSentinel = SENTINEL_SCENE.instantiate() as ForestSentinel
				sentinel.encounter_id = mob_id
				sentinel.name = mob_id
				sentinel.position = pos
				sentinel.patrol_left = item.get("patrol_left", -40.0)
				sentinel.patrol_right = item.get("patrol_right", 40.0)
				sentinel.facing = item.get("facing", -1)
				if hero != null:
					sentinel.target = hero
				encounters.add_child(sentinel)
				enemies.append(sentinel)
			"spectral_crow":
				var crow: ForestSpectralCrow = CROW_SCENE.instantiate() as ForestSpectralCrow
				crow.encounter_id = mob_id
				crow.name = mob_id
				crow.position = pos
				crow.patrol_half_width = item.get("patrol_half_width", 25.0)
				crow.facing = item.get("facing", -1)
				if hero != null:
					crow.target = hero
				encounters.add_child(crow)
				enemies.append(crow)
			"fossil_spikes":
				var spikes: ForestFossilSpikes = SPIKES_SCENE.instantiate() as ForestFossilSpikes
				spikes.encounter_id = mob_id
				spikes.name = mob_id
				spikes.position = pos
				encounters.add_child(spikes)
				hazards.append(spikes)

func snapshot() -> Dictionary:
	var enemy_data: Dictionary = {}
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy_data[enemy.encounter_id] = {
				"alive": enemy.state != enemy.State.DEAD,
				"hp": enemy.current_health,
				"pos_x": enemy.position.x,
				"pos_y": enemy.position.y,
				"facing": enemy.facing
			}
	var hazard_data: Dictionary = {}
	for hazard in hazards:
		if is_instance_valid(hazard):
			hazard_data[hazard.encounter_id] = {
				"state": int(hazard.state),
				"remaining": hazard.remaining
			}
	return {
		"sector_id": sector_id,
		"enemies": enemy_data,
		"hazards": hazard_data
	}

func restore_state(data: Dictionary) -> void:
	if data.is_empty():
		return
	var enemy_data: Dictionary = data.get("enemies", {})
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy_data.has(enemy.encounter_id):
			var ed: Dictionary = enemy_data[enemy.encounter_id]
			if not ed.get("alive", true):
				enemy.force_dead()
			else:
				enemy.current_health = ed.get("hp", enemy.max_health)
				if ed.has("pos_x") and ed.has("pos_y"):
					enemy.position = Vector2(ed["pos_x"], ed["pos_y"])
				if ed.has("facing"):
					enemy.facing = ed["facing"]
				if enemy.has_method("_sync_visual"):
					enemy._sync_visual()
	var hazard_data: Dictionary = data.get("hazards", {})
	for hazard in hazards:
		if not is_instance_valid(hazard):
			continue
		if hazard_data.has(hazard.encounter_id):
			var hd: Dictionary = hazard_data[hazard.encounter_id]
			hazard.state = hd.get("state", 0)
			hazard.remaining = hd.get("remaining", hazard.safe_duration)
			hazard._sync()

func reset_encounters() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.reset_enemy()
	for hazard in hazards:
		if is_instance_valid(hazard):
			hazard.reset_hazard()
	if is_instance_valid(arena):
		arena.reset_encounter()

func disarm() -> void:
	for enemy in enemies:
		if is_instance_valid(enemy):
			enemy.disarm()
	for hazard in hazards:
		if is_instance_valid(hazard):
			hazard.disarm()
	if is_instance_valid(arena):
		arena.disarm()
