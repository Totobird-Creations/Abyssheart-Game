tool
extends Spatial



export(Color)            var colour    : Color            setget set_colour
export(float)            var threshold : float            setget set_threshold
export(OpenSimplexNoise) var noise     : OpenSimplexNoise

var time : float = 0.0



func _ready() -> void:
	update_colour(colour)
	if (not Engine.is_editor_hint()):
		var rng : RandomNumberGenerator = RandomNumberGenerator.new()
		rng.randomize()
		noise      = noise.duplicate()
		noise.seed = rng.randi()

func _physics_process(delta : float) -> void:
	time += delta
	# Randomly interpolate brightness (Flickering).
	update_colour(colour * (noise.get_noise_1d(time) / 2.0 + 1.5))

func update_colour(col : Color) -> void:
	if (get_node_or_null('radius_light') and get_node_or_null('glow')):
		$radius_light.light_color = col
		$glow.get_surface_material(0).albedo_color = col * threshold



func set_colour(value : Color) -> void:
	colour = value
	update_colour(colour)



func set_threshold(value : float) -> void:
	threshold = value
	set_colour(colour)
