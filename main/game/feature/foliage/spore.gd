extends Feature



const DROP_ITEM : PackedScene = preload("res://main/game/item/food/spore.tscn")



func get_meshes() -> Node:
	return $mesh



static func get_spawn_chance(terroir : Spatial, position : Vector3) -> float:
	return terroir.generator.get_mushiness(Vector2(position.x, position.z))

static func get_required_height() -> float:
	return 1.0

static func get_required_radius() -> float:
	return 0.4

static func get_spread_count() -> int:
	return 4

static func get_spread_range() -> float:
	return 5.0



func left_clicked_world() -> void:
	queue_free()
	var instance : Item = DROP_ITEM.instance()
	instance.translation = translation + Vector3(0.0, 0.375, 0.0)
	instance.rotation    = rotation
	get_game_world().drop_item(instance)
