tool
extends Control



export(bool)    var auto_hover : bool    = true
export(bool)    var hovered    : bool    = false                  setget set_hovered
export(Texture) var icon       : Texture                          setget set_icon
export(Color)   var highlight  : Color   = Color(0.25, 0.75, 1.0) setget set_highlight



func _ready() -> void:
	set_hovered(hovered)
	set_icon(icon)
	set_highlight(highlight)



func hover() -> void:
	if (auto_hover):
		set_hovered(true)

func unhover() -> void:
	if (auto_hover):
		set_hovered(false)



func set_hovered(value : bool) -> void:
	hovered = value
	if (get_node_or_null("highlight/animation")):
		if (hovered):
			$highlight/animation.play("main")
		else:
			$highlight/animation.play_backwards("main")

func set_icon(value : Texture) -> void:
	icon = value
	if (get_node_or_null("icon")):
		$icon.texture = icon

func set_highlight(value : Color) -> void:
	highlight = value
	if (get_node_or_null("highlight")):
		$highlight.modulate = highlight
