extends Control



func left_click() -> void:
	if (get_parent().get_parent().has_drag_item()):
		for _i in range(get_parent().get_parent().get_drag_item().item_count):
			get_parent().get_parent().get_parent().get_player().drop_item(
				load(get_parent().get_parent().get_drag_item().get_item().filename).instance()
			)
			get_parent().get_parent().get_drag_item().queue_free()
