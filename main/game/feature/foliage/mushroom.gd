extends Feature



func get_meshes() -> Node:
	return $mesh



static func get_spawn_chance(terroir : Spatial, position : Vector3) -> float:
	return terroir.generator.get_mushiness(Vector2(position.x, position.z))

static func get_required_height() -> float:
	return 5.0

static func get_required_radius() -> float:
	return 3.0

static func get_spread_count() -> int:
	return 0

static func get_spread_range() -> float:
	return 0.0
