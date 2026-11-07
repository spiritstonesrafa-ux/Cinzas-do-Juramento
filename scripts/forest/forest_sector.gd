class_name ForestSector
extends Node2D
## Instancia corpos físicos e gerencia limites locais para os setores piloto da Floresta dos Ossos.

@export_range(0, 7, 1) var sector_id: int = 0

var world_geometry: Node2D

func _ready() -> void:
	world_geometry = Node2D.new()
	world_geometry.name = "Geometry"
	add_child(world_geometry)
	_build_surfaces()

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
		
		body.add_child(collider)
		world_geometry.add_child(body)
		index += 1

func snapshot() -> Dictionary:
	return {"sector_id": sector_id}

func restore_state(_data: Dictionary) -> void:
	pass

func reset_encounters() -> void:
	pass

func disarm() -> void:
	pass

