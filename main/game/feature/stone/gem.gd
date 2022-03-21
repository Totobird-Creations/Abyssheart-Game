tool
extends Spatial



const MATERIAL : SpatialMaterial = preload('res://assets/shader/feature/stone/gem.tres')



export(int)             var feature_seed    : int   = 0          setget set_feature_seed
export(float)           var bloom_min       : float = 0.0        setget set_bloom_min
export(float)           var bloom_max       : float = TAU / 10.0 setget set_bloom_max
export(float)           var length_min      : float = 0.75       setget set_length_min
export(float)           var length_max      : float = 1.25       setget set_length_max
export(float)           var spread_range    : float = TAU / 7.0  setget set_spread_range
export(int, 3, 8)       var max_point_count : int   = 8          setget set_max_point_count
export(float)           var point_height    : float = 2.5        setget set_point_height
export(int)             var mesh_count      : int   = 5          setget set_mesh_count
export(float, 0.0, 1.0) var saturation      : float = 1.0        setget set_saturation
export(float, 0.0, 1.0) var alpha           : float = 0.1        setget set_alpha



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
		var material : SpatialMaterial = MATERIAL.duplicate()
		material.albedo_color = colour
		material.emission     = colour
		for i in range(point_count):
			var container : Spatial      = Spatial.new()
			var mesh      : MeshInstance = MeshInstance.new()
			container.add_child(mesh)
			mesh.mesh            = load('res://assets/model/feature/stone/gem/' + str(rng.randi_range(0, mesh_count - 1)) + '.obj')
			mesh.translation.y   = point_height
			mesh.scale.y         = length_min + (length_max - length_min) * rng.randf_range(0.0, 1.0)
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

func set_saturation(value : float) -> void:
	saturation = value
	set_feature_seed(feature_seed)

func set_alpha(value : float) -> void:
	alpha = value
	set_feature_seed(feature_seed)
