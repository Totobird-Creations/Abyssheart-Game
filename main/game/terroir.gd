extends Spatial



const CHUNK : PackedScene = preload('res://main/game/chunk.tscn')

export(VoxelGenerator) var generator               : VoxelGenerator
export(int, 1, 100)    var feature_placement_tries : int            = 10

var chunks  : Dictionary = {}
var threads : Array      = []

var Feature : Dictionary = {
	Mushroom = preload('res://main/game/feature/foliage/mushroom.tscn'),
	Spore    = preload('res://main/game/feature/foliage/spore.tscn')
}



func _ready() -> void:
	$terrain.generator = generator



func chunk_loaded(chunk_position : Vector3) -> void:
	var chunk_coordinates : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	# Add chunk to list of loaded chunks.
	if (not chunks.has(chunk_coordinates)):
		chunks[chunk_coordinates] = []
	if (chunks[chunk_coordinates].has(int(chunk_position.y))):
		return
	chunks[chunk_coordinates].append(int(chunk_position.y))
	if (len(chunks[chunk_coordinates]) > 1):
		return

	# Create thread
	var thread : Thread = Thread.new()
	threads.append(thread)

	# Generate features and call add function.
	thread.start($feature_generator, "get_features_in_chunk", {
		chunk_coordinates = chunk_coordinates,
		chunk_size        = $terrain.mesh_block_size
	})


func chunk_generated(features : Dictionary, chunk_coordinates : Vector2) -> void:
	# Build chunk.
	var chunk    : Chunk      = CHUNK.instance()
	chunk.world_coordinates   = chunk_coordinates * $terrain.mesh_block_size
	chunk.coordinates         = chunk_coordinates
	chunk.size                = $terrain.mesh_block_size
	chunk.name                = str(chunk_coordinates.x) + "_" + str(chunk_coordinates.y)

	# Add features.
	for feature_position in features.keys():
		var feature : Feature = features[feature_position]
		chunk.add_child(feature)
		feature.translation = feature_position + Vector3.DOWN * 0.1
	$chunks.call_deferred("add_child", chunk)



func load_scene(path : String) -> PackedScene:
	return load(path) as PackedScene



func get_generator() -> VoxelGenerator:
	return generator

func get_required_height(feature : PackedScene) -> float:
	return feature.get_required_height()

func get_required_radius(feature : PackedScene) -> float:
	return feature.get_required_radius()


func get_elevation_at_coordinates(coordinates : Vector2) -> float:
	return generator.get_elevation(coordinates)

func get_height_at_coordinates(coordinates : Vector2) -> float:
	return generator.get_height(coordinates)



func chunk_unloaded(chunk_position : Vector3) -> void:
	var chunk_coordinates : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	chunks[chunk_coordinates].erase(int(chunk_position.y))
	# If chunk is still loaded, cancel
	if (len(chunks[chunk_coordinates]) >= 1):
		return

	# Unload chunk
	var name : String  = str(chunk_coordinates.x) + "_" + str(chunk_coordinates.y)
	if ($chunks.get_node_or_null(name)):
		$chunks.get_node(name).queue_free()



func _exit_tree() -> void:
	for thread in threads:
		thread.wait_to_finish()
