extends Spatial



const CHUNK : PackedScene = preload('res://main/game/chunk.tscn')

export(VoxelGenerator) var generator : VoxelGenerator

var chunks : Dictionary = {}

var Feature : Dictionary = {
	Mushroom = preload('res://main/game/feature/foliage/mushroom.tscn')
}



func chunk_loaded(chunk_position : Vector3) -> void:
	var key : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	if (not chunks.has(key)):
		chunks[key] = []
	if (chunks[key].has(int(chunk_position.y))):
		return
	chunks[key].append(int(chunk_position.y))

	var chunk_size : float   = $terrain.mesh_block_size
	var position   : Vector2 = key * chunk_size

	var name       : String  = str(chunk_position.x) + "_" + str(chunk_position.z)
	if (not $chunks.get_node_or_null(name)):
	
		var chunk : Chunk    = CHUNK.instance()
		chunk.name           = name
		chunk.chunk_position = Vector2(chunk_position.x, chunk_position.z)
		chunk.world_position = position

		var feature_position : Vector2 = position
		for offset in [
			Vector2(chunk_size / 2, 0),
			Vector2(0, chunk_size / 2),
			Vector2(chunk_size / 2, chunk_size / 2)
		]:
			try_spawn_feature(Feature.Mushroom, chunk, feature_position + offset, 4.0)

		$chunks.add_child(chunk)



func try_spawn_feature(feature_scene : PackedScene, chunk : Chunk, position : Vector2, variation : float = 0.0) -> bool:
	if (position.x == 0 and position.y == 0):
		return false
	var feature         : Feature = feature_scene.instance()
	var required_height : float   = feature.required_height
	if (generator.get_height(position) > required_height):
		var rng     : RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed   = hash(position.x) + hash(position.y)
		var angle  = rng.randf_range(-PI, PI)
		var dist   = rng.randf_range(0.0, variation)
		position  += Vector2(sin(angle) * dist, cos(angle) * dist)
		feature.feature_seed = rng.randi()
		chunk.add_child(feature)
		feature.translation = Vector3(position.x, generator.get_elevation(position) + required_height - 0.25, position.y)
		return true
	feature.queue_free()
	return false



func chunk_unloaded(chunk_position : Vector3) -> void:
	var key : Vector2 = Vector2(chunk_position.x, chunk_position.z)
	chunks[key].erase(int(chunk_position.y))
	if (len(chunks[key]) >= 1):
		return

	var name : String  = str(chunk_position.x) + "_" + str(chunk_position.z)
	if ($chunks.get_node_or_null(name)):
		$chunks.get_node(name).queue_free()
