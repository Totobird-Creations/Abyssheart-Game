extends Control



func _input(event : InputEvent) -> void:
	if (get_parent().get_parent().get_parent().mouse_mode == get_parent().get_parent().get_parent().MouseMode.Game):
		if (event is InputEventMouseButton):
			if (event.pressed):
				if (event.button_index == BUTTON_LEFT):
					for part in get_children():
						part.left()
				elif (event.button_index == BUTTON_RIGHT):
					for part in get_children():
						part.right()
