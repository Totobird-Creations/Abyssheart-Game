extends Spatial



enum RenderMode {
	Normal
	XRay
}
var render_mode : int = RenderMode.Normal



func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed('debug_toggle')):
		render_mode += 1
		if (render_mode >= 2):
			render_mode = 0
		match (render_mode):
			RenderMode.Normal : $terroir/terrain.get_material(0).shader = preload('res://assets/shader/terrain/normal.tres')
			RenderMode.XRay   : $terroir/terrain.get_material(0).shader = preload('res://assets/shader/terrain/xray.tres')
