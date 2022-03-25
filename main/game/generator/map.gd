tool
extends Control



func _ready() -> void:
	update_rect()



func update_rect() -> void:
	var size : float = min(rect_size.x, rect_size.y)
	$bounds.rect_size = Vector2(size, size)
