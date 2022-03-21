tool
extends StaticBody



export(int) var variant : int = 0 setget set_variant



func _ready() -> void:
	set_variant(variant)

func set_variant(value : int) -> void:
	variant = value
	if (get_node_or_null('mesh')):
		$mesh.mesh = load('res://assets/model/feature/tree/swamp/' + str(variant) + '.obj')
