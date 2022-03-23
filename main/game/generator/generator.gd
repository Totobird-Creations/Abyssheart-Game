tool
extends VoxelGeneratorScript



const                        channel    : int              = VoxelBuffer.CHANNEL_SDF

export(OpenSimplexNoise) var wall_map        : OpenSimplexNoise
export(float)            var wall_max        : float            = 64.0
export(float)            var wall_scale      : float            = 64.0
export(Curve)            var wall_curve      : Curve
export(OpenSimplexNoise) var thickness_map   : OpenSimplexNoise
export(float)            var thickness_max   : float            = 10.0
export(float)            var thickness_scale : float            = 256.0
export(Curve)            var thickness_curve : Curve



func _get_used_channels_mask() -> int:
	return 1 << channel



func _generate_block(buffer : VoxelBuffer, origin : Vector3, lod : int) -> void:
	if (lod != 0):
		return
	var size  : Vector3 = buffer.get_size()
	var world : Vector3 = origin

	for ix in range(size.x):
		var x : float = world.x + ix
		for iz in range(size.z):
			var z : float = world.z + iz
			for iy in range(size.y):
				var y : float = world.y + iy

				var tunnels : float = wall_map.get_noise_3dv(Vector3(x, y, z) / wall_scale)
				buffer.set_voxel_f(clamp(tunnels, -1, 1), ix, iy, iz, channel)
