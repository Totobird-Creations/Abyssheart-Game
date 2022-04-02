extends Spatial



const CHUNK : PackedScene = preload('res://main/game/chunk.tscn')

export(VoxelGenerator) var generator               : VoxelGenerator
export(int, 1, 100)    var feature_placement_tries : int            = 10

var chunks  : Dictionary = {}

var Feature : Dictionary = {
	Mushroom = preload('res://main/game/feature/foliage/mushroom.tscn'),
	Spore    = preload('res://main/game/feature/foliage/spore.tscn')
}



func _ready() -> void:
	$terrain.generator = generator



func chunk_loaded(chunk_position : Vector3) -> void:
	var key : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	# Add chunk to list of loaded chunks.
	if (not chunks.has(key)):
		chunks[key] = []
	if (chunks[key].has(int(chunk_position.y))):
		return
	chunks[key].append(int(chunk_position.y))

	var coordinates : Vector2 = key * $terrain.mesh_block_size

	var name : String  = str(chunk_position.x) + "_" + str(chunk_position.z)
	# Make sure chunk is not loaded.
	if (not $chunks.get_node_or_null(name)):
		# Create chunk.
		var chunk    : Chunk      = CHUNK.instance()
		chunk.world_coordinates   = coordinates
		chunk.coordinates         = key
		chunk.size                = $terrain.mesh_block_size
		chunk.name                = name

		# Add features.
		var features : Dictionary = $feature_generator.get_features_in_chunk(key, $terrain.mesh_block_size)
		for feature_position in features.keys():
			var feature : Feature = features[feature_position]
			chunk.add_child(feature)
			feature.translation = feature_position + Vector3.DOWN * 0.1
		$chunks.add_child(chunk)



func load_scene(path : String) -> PackedScene:
	return load(path) as PackedScene



func get_generator() -> VoxelGenerator:
	return generator

func get_required_height(feature : PackedScene) -> float:
	return feature.get_required_height()

func get_required_radius(feature : PackedScene) -> float:
	return feature.get_required_radius()


func get_elevation_at_coordinates(position : Vector2) -> float:
	return generator.get_elevation(position)

func get_height_at_coordinates(position : Vector2) -> float:
	return generator.get_height(position)



func chunk_unloaded(chunk_position : Vector3) -> void:
	var key : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	chunks[key].erase(int(chunk_position.y))
	# If chunk is still loaded, ancel
	if (len(chunks[key]) >= 1):
		return

	# Unload chunk
	var name : String  = str(chunk_position.x) + "_" + str(chunk_position.z)
	if ($chunks.get_node_or_null(name)):
		$chunks.get_node(name).queue_free()
