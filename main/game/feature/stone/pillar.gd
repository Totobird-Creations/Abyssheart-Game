extends Feature



func get_meshes() -> Node:
	return $mesh



static func get_spawn_chance(_terroir : Spatial, _position : Vector3) -> float:
	return 0.25

static func get_required_height() -> float:
	return 10.0

static func get_required_radius() -> float:
	return 10.0

static func get_spread_count() -> int:
	return 0

static func get_spread_range() -> float:
	return 0.0
