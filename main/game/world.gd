extends Spatial



enum RenderMode {
	Normal
	Debug
}
var render_mode : int = RenderMode.Normal



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



func _input(event : InputEvent) -> void:
	if (event is InputEventKey):
		# Close game on escape pressed.
		if (event.scancode == KEY_ESCAPE):
			get_tree().quit(0)
