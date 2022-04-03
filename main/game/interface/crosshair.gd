extends Control



func _input(event : InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.button_index == BUTTON_LEFT):
			for part in get_children():
				part.left()
		elif (event.button_index == BUTTON_RIGHT):
			for part in get_children():
				part.right()
