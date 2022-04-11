extends KinematicBody
class_name Entity



func get_game_world() -> Node:
	return get_parent().get_parent()

func get_entities() -> Node:
	return get_game_world().get_node("entities")

func get_interface() -> Node:
	return get_game_world().get_node("canvas")
