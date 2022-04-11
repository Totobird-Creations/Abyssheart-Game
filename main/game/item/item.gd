extends RigidBody
class_name Item



enum State {
	Inventory,
	Ground,
	Hand
}
export(int, 'Inventory', 'Ground') var state : int = State.Inventory setget set_state



enum Material {
	Bronze,
	Iron,
	Silver,
	Gold,
	Steel
}
static func get_shader_for_material(material : int) -> Material:
	match (material):
		Material.Bronze : return preload('res://assets/shader/item/material/bronze.tres')
		Material.Iron   : return preload('res://assets/shader/item/material/iron.tres')
		Material.Silver : return preload('res://assets/shader/item/material/silver.tres')
		Material.Gold   : return preload('res://assets/shader/item/material/gold.tres')
		Material.Steel  : return preload('res://assets/shader/item/material/steel.tres')
	return null



func set_state(value : int) -> void:
	state = value
	var collision_enabled : bool = true
	match (state):
		State.Inventory:
			mode = MODE_STATIC
		State.Ground:
			mode = MODE_RIGID
			remove_camera()
		State.Hand:
			mode = MODE_STATIC
			collision_enabled = false
			remove_camera()
	for child in get_children():
		if (child is CollisionShape || child is CollisionPolygon):
			child.disabled = ! collision_enabled

func remove_camera(node : Node = self) -> void:
	for child in node.get_children():
		if (child is Camera):
			child.queue_free()
		else:
			remove_camera(child)



func _ready() -> void:
	set_state(state)



func left_clicked_world() -> void:
	pass

func right_clicked_world() -> void:
	pass

func left_clicked_hand() -> void:
	pass

func right_clicked_hand() -> void:
	pass

func get_max_stack() -> int:
	return 16



func get_game_world() -> Node:
	match (state):
		State.Inventory:
			return get_parent().get_parent().get_parent().get_parent().get_parent().get_parent().get_parent()
		State.Ground:
			return get_parent().get_parent()
	return null
