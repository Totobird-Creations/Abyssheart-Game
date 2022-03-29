extends Spatial



const CHUNK : PackedScene = preload('res://main/game/chunk.tscn')

export(VoxelGenerator) var generator               : VoxelGenerator
export(int, 1, 100)    var feature_placement_tries : int            = 25

var chunks : Dictionary = {}

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

	var position   : Vector2 = key * $terrain.mesh_block_size

	var name       : String  = str(chunk_position.x) + "_" + str(chunk_position.z)
	# Make sure chunk is not loaded.
	if (not $chunks.get_node_or_null(name)):

		# Generate chunk.
		var chunk : Chunk    = CHUNK.instance()
		chunk.name           = name
		chunk.chunk_position = Vector2(chunk_position.x, chunk_position.z)
		chunk.chunk_size     = $terrain.mesh_block_size
		chunk.world_position = position

		var features : Dictionary = get_features_in_chunk(chunk.chunk_position, chunk.chunk_size, true)
		for feature_position in features.keys():
			var feature : Feature = features[feature_position]
			chunk.add_child(feature)
			feature.translation = feature_position

		$chunks.add_child(chunk)



func get_features_in_chunk(chunk_position : Vector2, chunk_size : float, check_neighbors : bool) -> Dictionary:
	var tries_remaining : int        = feature_placement_tries
	var other_features  : Dictionary = {}
	# Get features in neighboring chunks.
	if (check_neighbors):
		other_features = Tool.merge_dictionary(other_features, get_features_in_chunk(
			chunk_position + Vector2(-1, 0),
			chunk_size,
			false
		))
		other_features = Tool.merge_dictionary(other_features, get_features_in_chunk(
			chunk_position + Vector2(0, -1),
			chunk_size,
			false
		))
		other_features = Tool.merge_dictionary(other_features, get_features_in_chunk(
			chunk_position + Vector2(-1, -1),
			chunk_size,
			false
		))

	var rng  : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = hash(chunk_position.x) + hash(chunk_position.y)

	var features        : Dictionary = {}
	while (tries_remaining > 0):
		# Pick a random location.
		var feature_coordinate : Vector2 = chunk_position * chunk_size + Vector2(
			rng.randf_range(0.0, chunk_size),
			rng.randf_range(0.0, chunk_size)
		)
		var feature_position : Vector3 = Vector3(
			feature_coordinate.x,
			generator.get_elevation(feature_coordinate),
			feature_coordinate.y
		)
		# Pick a random feature.
		var feature : Feature = Feature.values()[rng.randi_range(0, len(Feature) - 1)].instance()
		var success : bool    = check_spawn_allowed(
			feature,
			feature_coordinate,
			feature_position,
			Tool.merge_dictionary(features, other_features)
		)

		if (success):
			features[feature_position] = feature

			# Add random clones of the feature around based on spread value.
			for _i in range(rng.randi_range(0, feature.spread_count)):
				var angle             : float   = rng.randf_range(-PI, PI)
				var spread_coordinate : Vector2 = feature_coordinate + Vector2(cos(angle), sin(angle)) * rng.randf_range(0.0, feature.spread_range)
				var spread_position   : Vector3 = Vector3(
					spread_coordinate.x,
					generator.get_elevation(spread_coordinate),
					spread_coordinate.y
				)
				var spread_feature    : Feature = feature.duplicate()
				var spread_success    : bool    = check_spawn_allowed(
					spread_feature,
					spread_coordinate,
					spread_position,
					Tool.merge_dictionary(features, other_features)
				)
				if (spread_success):
					features[spread_position] = spread_feature
				else:
					spread_feature.free()

		else:
			feature.free()
		tries_remaining -= 1
	return features



func check_spawn_allowed(feature : Feature, feature_coordinate : Vector2, feature_position : Vector3, all_features : Dictionary) -> bool:
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

	return success


func check_height_allowed(feature : Feature, position : Vector2) -> bool:
	return generator.get_height(position) > feature.required_height



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
