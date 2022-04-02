extends HBoxContainer



var selected     : int  = 1     setget set_selected
var off_selected : bool = false setget set_off_selected



func _input(event : InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.pressed):
			var prev_selected : int = selected
			if (event.button_index == BUTTON_WHEEL_UP):
				set_selected(selected - 1)
			elif (event.button_index == BUTTON_WHEEL_DOWN):
				set_selected(selected + 1)
	elif (event is InputEventKey):
		if (event.pressed):
			if (event.scancode >= KEY_1 && event.scancode <= KEY_9):
				set_selected(event.scancode - KEY_1 + 1)
			elif (event.scancode == KEY_QUOTELEFT):
				set_off_selected(not off_selected)



func set_selected(value : int) -> void:
	if (value != selected):
		if (value > get_child_count()):
			value = 1
		elif (value < 1):
			value = get_child_count()
		get_child(selected).hovered = false
		get_child(value).hovered = true
		selected = value



func set_off_selected(value : bool) -> void:
	if (value != off_selected):
		get_child(0).hovered = value
		off_selected = value
