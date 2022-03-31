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
		var features : Dictionary = $feature_generator.get_features_in_chunk(coordinates, $terrain.mesh_block_size)
		for feature_position in features.keys():
			var feature : Feature = features[feature_position]
			chunk.add_child(feature)
			feature.translation = (feature_position / $terrain.mesh_block_size) + Vector3.UP * 0.1
		$chunks.add_child(chunk)



func load_scene(path : String) -> PackedScene:
	return load(path) as PackedScene



"""func check_spawn_allowed(feature : Feature, feature_coordinate : Vector2, feature_position : Vector3, all_features : Dictionary) -> bool:
	var success : bool = true

	if (success):
		# Check if the ceiling is high enough for this feature.
		success = check_height_allowed(feature, feature_coordinate)

	if (success):
		# Check if the feature is far enough from all nearby features.
		for other_position in all_features.keys():
			var other_feature : Feature = all_features[other_position]
			if (other_position.distance_to(feature_position) <= max(other_feature.required_radius, feature.required_radius)):
				success = false

	return success"""


func get_elevation_at_coordinates(position : Vector2) -> bool:
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
