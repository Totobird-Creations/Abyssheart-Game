tool
extends Control



export(bool)    var highlight        : bool    = false                  setget set_highlight
export(Texture) var icon             : Texture                          setget set_icon
export(Color)   var highlight_colour : Color   = Color(0.25, 0.75, 1.0) setget set_highlight_colour

var hovered    : bool = false

var item_count : int  = 0





func _ready() -> void:
	set_hovered(hovered)
	set_highlight(highlight)
	set_icon(icon)



func hover() -> void:
	set_hovered(true)

func unhover() -> void:
	set_hovered(false)



func set_hovered(value : bool) -> void:
	if (get_node_or_null("hover/animation")):
		if (value && ! hovered):
			$hover/animation.play("main")
		elif (hovered && ! value):
			$hover/animation.play_backwards("main")
	hovered = value

func set_highlight(value : bool) -> void:
	highlight = value
	if (get_node_or_null("highlight/animation")):
		if (highlight):
			$highlight/animation.play("main")
		else:
			$highlight/animation.play_backwards("main")

func set_icon(value : Texture) -> void:
	icon = value
	if (get_node_or_null("icon")):
		$icon.texture = icon

func set_highlight_colour(value : Color) -> void:
	highlight_colour = value
	if (get_node_or_null("highlight")):
		$highlight.modulate = highlight_colour



func get_interface() -> Node:
	if (get_parent().get_parent().get_parent() is CanvasLayer):
		return get_parent().get_parent().get_parent()
	else:
		return get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()





func has_item() -> bool:
	return $item/viewport.get_child_count() > 0

func set_item(item : Item, count : int = 1) -> void:
	for item in $item/viewport.get_children():
		item.queue_free()
	if (item == null):
		if (item_count != 0):
			set_item_count(0)
	else:
		$item/viewport.add_child(item)
		set_item_count(count)

func set_item_count(count : int) -> void:
	item_count = count
	if (item_count > 1):
		$item/label.text = str(item_count)
	else:
		$item/label.text = ""
	if (item_count <= 0):
		set_item(null)

func get_item() -> Node:
	if (has_item()):
		return $item/viewport.get_child(0)
	else:
		return null

func get_item_max_stack() -> int:
	if (has_item()):
		return $item/viewport.get_child(0).get_max_stack()
	else:
		return 100





func _input(event : InputEvent) -> void:
	if (hovered):
		if (event is InputEventMouseButton):
			if (event.pressed):
				if (event.button_index == BUTTON_LEFT):
					if (get_interface().has_drag_item()):
						var drag_slot : ViewportContainer = get_interface().get_drag_item()
						if (has_item()):
							if (drag_slot.get_item().filename == get_item().filename):
								var drag_slot_item_count : int = drag_slot.item_count
								drag_slot.set_item_count(drag_slot_item_count - (get_item_max_stack() - item_count))
								set_item_count(int(min(item_count + drag_slot_item_count, get_item_max_stack())))
							else:
								set_item(drag_slot.get_item().duplicate(), drag_slot.item_count)
								drag_slot.set_item(get_item().duplicate(), item_count)
						else:
							set_item(drag_slot.get_item().duplicate(), drag_slot.item_count)
							drag_slot.queue_free()
					else:
						if (has_item()):
							get_interface().add_drag_item($item/viewport.get_child(0).duplicate(), item_count)
							set_item(null)
				if (event.button_index == BUTTON_RIGHT):
					if (get_interface().has_drag_item()):
						var drag_slot : ViewportContainer = get_interface().get_drag_item()
						if (has_item()):
							if (item_count < get_item_max_stack()):
								if (drag_slot.get_item().filename == get_item().filename):
									set_item_count(item_count + 1)
									drag_slot.set_item_count(drag_slot.item_count - 1)
						else:
							set_item(drag_slot.get_item().duplicate(), 1)
							drag_slot.set_item_count(drag_slot.item_count - 1)
					else:
						if (has_item()):
							get_interface().add_drag_item(get_item().duplicate(), int(ceil(item_count / 2.0)))
							set_item_count(int(floor(item_count / 2.0)))
