extends Spatial



enum RenderMode {
	Normal
	Debug
}
var render_mode : int = RenderMode.Normal



func _process(_delta : float) -> void:
	if (Input.is_action_just_pressed('debug_toggle')):
		var shader        : Shader = preload('res://assets/shader/terrain/normal.tres')
		var ambient_light : float    = 0.0

		render_mode += 1
		if (render_mode >= 2):
			render_mode = 0
		match (render_mode):
			RenderMode.Debug:
				shader        = preload('res://assets/shader/terrain/debug.tres')
				ambient_light = 0.1

		$terroir/terrain.get_material(0).shader       = shader
		$environment.environment.ambient_light_energy = ambient_light
