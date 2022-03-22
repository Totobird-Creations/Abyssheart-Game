tool
extends Spatial



const MATERIAL : ShaderMaterial = preload('res://assets/shader/feature/stone/gem.tres')



export(int)             var feature_seed    : int    = 0          setget set_feature_seed    # Seed for generating the random crystal.
export(int, 3, 8)       var max_point_count : int    = 8          setget set_max_point_count # Maximum point count (minimum of 3).
export(float)           var bloom_min       : float  = 0.0        setget set_bloom_min       # Minimum angle (radians) for pointing the points outward.
export(float)           var bloom_max       : float  = TAU / 10.0 setget set_bloom_max       # Maximum angle (radians) for pointing the points outward.
export(float)           var length_min      : float  = 0.75       setget set_length_min      # Minimum length of the points.
export(float)           var length_max      : float  = 1.25       setget set_length_max      # Maximum length of the points.
export(float)           var spread_range    : float  = TAU / 7.0  setget set_spread_range    # Amount to allow randomizing the angle of the points.
export(float, 0.0, 1.0) var saturation      : float  = 1.0        setget set_saturation      # Colour saturation of crystal.
export(float, 0.0, 1.0) var alpha           : float  = 0.1        setget set_alpha           # Crystal transperancy.
export(float)           var point_height    : float  = 2.5        setget set_point_height    # Y offset of the points before rotation.
export(int)             var mesh_count      : int    = 5          setget set_mesh_count      # Number of mesh options in the given directory.
export(String, DIR)     var mesh_directory  : String = "res://"   setget set_mesh_directory  # Location to look for meshes.
export(String)          var mesh_extension  : String = ".obj"     setget set_mesh_extension  # File extension of mesh files.
export(bool)            var independent     : bool   = true       setget set_independent     # Don't use a reference to the original shader. (ONLY TURN OFF IF YOU ARE MODIFYING THE SHADER)



func _ready() -> void:
	set_feature_seed(feature_seed)



func set_feature_seed(value : int) -> void:
	feature_seed = value
	if (get_node_or_null('mesh') and get_node_or_null('light')):
		var rng  : RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed                         = feature_seed
		for child in $mesh.get_children():
			child.free()
		var point_count : int   = rng.randi_range(3, max_point_count)
		var colour      : Color = hsv_to_rgb(rng.randf_range(0.0, 254.9), saturation, 1.0, alpha)
		$light.light_color = colour
		var material : ShaderMaterial = MATERIAL
		if (independent):
			material = material.duplicate()
		material.set_shader_param('colour', colour)
		for i in range(point_count):
			var container : Spatial      = Spatial.new()
			var mesh      : MeshInstance = MeshInstance.new()
			container.add_child(mesh)
			mesh.mesh            = load(mesh_directory + str(rng.randi_range(0, mesh_count - 1)) + mesh_extension)
			mesh.translation.y   = point_height
			mesh.scale.y         = length_min + (length_max - length_min) * rng.randf_range(0.0, 1.0)
			mesh.cast_shadow     = false
			mesh.set_surface_material(0, material)
			container.rotation.x = bloom_min + (bloom_max - bloom_min) * rng.randf_range(0.0, 1.0)
			container.rotation.y = i * TAU / point_count + spread_range * rng.randf_range(0.0, 1.0)
			$mesh.add_child(container)


func hsv_to_rgb(h : float, s : float, v : float, a : float) -> Color:
	var i : float = floor(h * 6)
	var f : float = h * 6 - i
	var p : float = v * (1 - s)
	var q : float = v * (1 - f * s)
	var t : float = v * (1 - (1 - f) * s)
	match (int(i) % 6):
		0: return Color(v, t, p, a)
		1: return Color(q, v, p, a)
		2: return Color(p, v, t, a)
		3: return Color(p, q, v, a)
		4: return Color(t, p, v, a)
		5: return Color(v, p, q, a)
	return Color(0.0, 0.0, 0.0, a)



func set_bloom_min(value : float) -> void:
	bloom_min = value
	set_feature_seed(feature_seed)

func set_bloom_max(value : float) -> void:
	bloom_max = value
	set_feature_seed(feature_seed)

func set_length_min(value : float) -> void:
	length_min = value
	set_feature_seed(feature_seed)

func set_length_max(value : float) -> void:
	length_max = value
	set_feature_seed(feature_seed)

func set_spread_range(value : float) -> void:
	spread_range = value
	set_feature_seed(feature_seed)

func set_max_point_count(value : int) -> void:
	max_point_count = value
	set_feature_seed(feature_seed)

func set_point_height(value : float) -> void:
	point_height = value
	set_feature_seed(feature_seed)

func set_mesh_count(value : int) -> void:
	mesh_count = value
	set_feature_seed(feature_seed)

func set_mesh_directory(value : String) -> void:
	mesh_directory = value
	set_feature_seed(feature_seed)

func set_mesh_extension(value : String) -> void:
	mesh_extension = value
	set_feature_seed(feature_seed)

func set_saturation(value : float) -> void:
	saturation = value
	set_feature_seed(feature_seed)

func set_alpha(value : float) -> void:
	alpha = value
	set_feature_seed(feature_seed)

func set_independent(value : bool) -> void:
	independent = value
	# push_warning("Independent shader mode is off. TURN THIS ON UNLESS YOU ARE MODIFYING THE SHADER.")
	set_feature_seed(feature_seed)
