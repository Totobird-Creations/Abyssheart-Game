tool
extends VoxelGeneratorScript
class_name Generator



const channel : int = VoxelBuffer.CHANNEL_SDF

export(int)              var world_seed      : int              = 0
export(OpenSimplexNoise) var tunnel_map      : OpenSimplexNoise # Passages
export(float)            var tunnel_scale    : float            = 64.0
export(Curve)            var tunnel_curve    : Curve
export(OpenSimplexNoise) var height_map      : OpenSimplexNoise # Distance between floor and ceiling
export(float)            var height_scale    : float            = 128.0
export(float)            var height_min      : float            = 16.0
export(float)            var height_max      : float            = 64.0
export(OpenSimplexNoise) var elevation_map   : OpenSimplexNoise # Height relative to 0 y world coords
export(float)            var elevation_scale : float            = 512.0
export(float)            var elevation_max   : float            = 32.0
export(OpenSimplexNoise) var roughness_map   : OpenSimplexNoise # Smaller noise layer added to elevation to add bumps to the floor and ceiling
export(float)            var roughness_scale : float            = 4.0
export(float)            var roughness_max   : float            = 1.0



func _get_used_channels_mask() -> int:
	return 1 << channel



func _generate_block(buffer : VoxelBuffer, origin : Vector3, lod : int) -> void:
	# Set correct seeds.
	tunnel_map.seed    = world_seed
	height_map.seed    = world_seed + 1
	elevation_map.seed = world_seed + 2
	roughness_map.seed = world_seed + 3

	# Make sure lod is deactivated.
	if (lod != 0):
		return

	# Generate terrain.
	var size  : Vector3 = buffer.get_size()
	var world : Vector3 = origin

	for ix in range(size.x):
		var x : float = world.x + ix
		for iz in range(size.z):
			var z : float = world.z + iz

			var tunnels   : float = get_tunnel(Vector2(x, z))
			var elevation : float = get_elevation(Vector2(x, z))
			var height    : float = get_height(Vector2(x, z))

			for iy in range(size.y):
				var y : float = world.y + iy
				buffer.set_voxel_f(clamp(min(
					((y - elevation) + (tunnels * height)),
					(1.0 - ((y - elevation - height) + (tunnels * height)))
				), -1.0, 1.0), ix, iy, iz, channel)



func get_tunnel(position : Vector2) -> float:
	var tunnels : float = tunnel_map.get_noise_2dv(position / tunnel_scale)
	tunnels = tunnels / 2.0 + 0.5
	tunnels = tunnel_curve.interpolate(tunnels)
	tunnels = pow(tunnels, 0.5)
	tunnels = tunnels * 2.0 - 1.0
	tunnels = tunnels - 1.0
	return tunnels



func get_elevation(position : Vector2) -> float:
	var elevation : float = elevation_map.get_noise_2dv(position / elevation_scale)
	elevation = elevation * elevation_max
	elevation += roughness_map.get_noise_2dv(position / roughness_scale) * roughness_max
	return elevation



func get_height(position : Vector2) -> float:
	var height : float = height_map.get_noise_2dv(position / height_scale)
	height = height_min + height * (height_max - height_min)
	return height
