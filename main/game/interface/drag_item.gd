extends ViewportContainer



var item_count : int = 0



func set_item(item : Item, count : int) -> void:
	set_item_count(count)
	for item in $viewport.get_children():
		item.queue_free()
	$viewport.add_child(item)

func set_item_count(count : int) -> void:
	if (count <= 0):
		queue_free()
	else:
		item_count = count
		if (item_count > 1):
			$label.text = str(item_count)
		else:
			$label.text = ""

func get_item() -> Node:
	return $viewport.get_child(0)





func _physics_process(_delta : float) -> void:
	rect_global_position = get_global_mouse_position() - rect_size / 2.0
