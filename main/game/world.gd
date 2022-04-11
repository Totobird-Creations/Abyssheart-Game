extends Spatial



enum RenderMode {
	Normal
	Debug
}
var render_mode : int = RenderMode.Normal

enum MouseMode {
	Game,
	Inventory,
}
var mouse_mode : int = MouseMode.Game setget set_mouse_mode





func set_mouse_mode(value : int) -> void:
	match (mouse_mode):
		MouseMode.Game: pass
		MouseMode.Inventory:
			$canvas/interface/inventory/animation.play_backwards("main")
			if ($canvas.has_drag_item()):
				var scene : PackedScene = load($canvas.get_drag_item().get_item().filename)
				for _i in range($canvas.get_drag_item().item_count):
					get_player().drop_item(scene.instance())
				$canvas.get_drag_item().queue_free()
	mouse_mode = value
	match (mouse_mode):
		MouseMode.Game:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		MouseMode.Inventory:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			$canvas/interface/inventory/animation.play("main")





func _ready() -> void:
	set_mouse_mode(mouse_mode)



func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed("debug_toggle")):
		var ambient_light : float  = 0.0
		var debug_enabled : bool   = false

		render_mode += 1
		if (render_mode >= 2):
			render_mode = 0

		match (render_mode):
			RenderMode.Debug:
				if (! OS.has_feature("standalone")):
					ambient_light = 0.25
				debug_enabled = true

		$terroir/terrain.get_material(0).set_shader_param("debug_mode", debug_enabled)
		$environment.environment.ambient_light_energy = ambient_light
		$canvas/interface/debug.visible               = debug_enabled

	if (Input.is_action_just_pressed("interface_back")):
		match (mouse_mode):
			MouseMode.Game:
				get_tree().quit(0)
			MouseMode.Inventory:
				set_mouse_mode(MouseMode.Game)

	if (Input.is_action_just_pressed("interface_open_inventory")):
		if (mouse_mode == MouseMode.Game):
			set_mouse_mode(MouseMode.Inventory)
		elif (mouse_mode == MouseMode.Inventory):
			set_mouse_mode(MouseMode.Game)





func drop_item(instance : Item) -> void:
	instance.set_state(Item.State.Ground)
	$entities.add_child(instance)



func add_inventory_item(path : String) -> bool:
	var item : Item = load(path).instance()
	item.set_state(Item.State.Inventory)

	var slots : Array = $canvas/interface/hotbar.get_children()
	for row in $canvas/interface/inventory/left/vertical.get_children():
		slots += row.get_children()
	slots.remove(0)

	var drop_slot  : Node
	var drop_count : int = 1
	for slot in slots:
		if (slot.get_item()):
			if (slot.get_item().filename == path):
				if (slot.item_count < slot.get_item_max_stack()):
					drop_slot  = slot
					drop_count = slot.item_count + 1
					break
	if (! drop_slot):
		for slot in slots:
			if (! slot.has_item()):
				drop_slot = slot
				break

	if (drop_slot):
		drop_slot.set_item(item, drop_count)
		return true;
	else:
		item.queue_free()
		return false;



func left_clicked() -> bool:
	return false

func right_clicked() -> bool:
	return false



func get_player() -> Node:
	for entity in $entities.get_children():
		if (entity is PlayerEntity && entity.controlling):
			return entity
	return null
