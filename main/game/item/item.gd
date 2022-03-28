extends RigidBody
class_name Item



enum State {
	InHand,
	OnGround
}
export(int, 'In Hand', 'On Ground') var state : int = State.OnGround



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
