tool
extends Item



export(int, 'Bronze', 'Iron', 'Silver', 'Gold', 'Steel') var material : int = Item.Material.Bronze setget set_material



func _ready() -> void:
	set_material(material)



func set_material(value : int) -> void:
	material = value
	if (get_node_or_null('mesh')):
		$mesh.set_surface_material(0, Item.get_shader_for_material(material))
