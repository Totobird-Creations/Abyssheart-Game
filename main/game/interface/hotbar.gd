extends HBoxContainer



var selected     : int  = 1     setget set_selected
var off_selected : bool = false setget set_off_selected



func _input(event : InputEvent) -> void:
	if (event is InputEventMouseButton):
		if (event.pressed):
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
		if (value >= get_child_count()):
			value = 1
		elif (value < 1):
			value = get_child_count() - 1
		get_child(selected).set_highlight(false)
		get_child(value).set_highlight(true)
		get_parent().get_parent().get_parent().get_player().set_mainhand_item(get_child(value).get_item())
		selected = value



func set_off_selected(value : bool) -> void:
	if (value != off_selected):
		get_child(0).set_highlight(value)
		get_parent().get_parent().get_parent().get_player().set_offhand_item(get_child(0).get_item())
		off_selected = value
