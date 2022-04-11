extends Node



func is_player_entity(object : Object) -> bool:
	return object is PlayerEntity



func merge_dictionary(a : Dictionary, b : Dictionary) -> Dictionary:
	var result : Dictionary = b.duplicate()
	for key in a:
		b[key] = a[key]
	return result
