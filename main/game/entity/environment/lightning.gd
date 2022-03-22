tool
extends Spatial



export(Vector3) var start_pos        : Vector3 = Vector3.ZERO            setget set_start_pos
export(Vector3) var end_pos          : Vector3 = Vector3.ZERO            setget set_end_pos
export(Color)   var colour           : Color   = Color(10.0, 10.0, 10.0) setget set_colour
export(float)   var segment_division : float   = 5.0                     setget set_segment_division
export(float)   var randomness       : float   = 2.5                     setget set_randomness
export(bool)    var runtime_only     : bool    = false                   setget set_runtime_only



func update_bolt() -> void:
	if (get_node_or_null('geometry')):
		$geometry.clear()
		if ((not Engine.is_editor_hint()) or (not runtime_only)):
			var rng : RandomNumberGenerator = RandomNumberGenerator.new()
			rng.randomize()
			$geometry.begin(Mesh.PRIMITIVE_LINES)
			var distance : float = start_pos.distance_to(end_pos)
			var segments : int   = int(distance / segment_division)
			$geometry.add_vertex(start_pos)
			for i in range(segments):
				var position : Vector3 = start_pos.move_toward(end_pos, distance / (segments + 1) * (i + 1))
				var offset   : Vector3 = Vector3(randomness * rng.randf_range(-1.0, 1.0), randomness * rng.randf_range(-1.0, 1.0), randomness * rng.randf_range(-1.0, 1.0))
				$geometry.add_vertex(position + offset)
				$geometry.add_vertex(position + offset)
			$geometry.add_vertex(end_pos)
			$geometry.end()
			if ($geometry.material_override is Material):
				$geometry.material_override.set_shader_param('colour', colour)



func set_start_pos(value : Vector3) -> void:
	start_pos = value
	update_bolt()

func set_end_pos(value : Vector3) -> void:
	end_pos = value
	update_bolt()

func set_colour(value : Color) -> void:
	colour = value
	update_bolt()

func set_segment_division(value : float) -> void:
	segment_division = value
	update_bolt()

func set_randomness(value : float) -> void:
	randomness = value
	update_bolt()

func set_runtime_only(value : bool) -> void:
	runtime_only = value
	update_bolt()
