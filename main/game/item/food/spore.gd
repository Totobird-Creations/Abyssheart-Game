extends Item



func right_clicked_world() -> void:
	if (get_game_world().add_inventory_item(self.filename)):
		queue_free()
