tool
extends VoxelGeneratorScript



const                        channel    : int              = VoxelBuffer.CHANNEL_SDF

export(OpenSimplexNoise) var height_map      : OpenSimplexNoise
export(float)            var height_max      : float            = 512.0
export(float)            var height_scale    : float            = 2048.0
export(OpenSimplexNoise) var roughness_map   : OpenSimplexNoise
export(float)            var roughness_max   : float            = 32.0
export(float)            var roughness_scale : float            = 16.0
export(OpenSimplexNoise) var flatness_map    : OpenSimplexNoise
export(float)            var flatness_scale  : float            = 256.0
export(Curve)            var flatness_curve  : Curve



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

			var height    : float = (height_map.get_noise_2d(x / height_scale, z / height_scale) + 1) / 2.0 * height_max
			var roughness : float = (roughness_map.get_noise_2d(x / roughness_scale, z / roughness_scale) + 1) / 2.0 * roughness_max
			var flatness  : float = flatness_curve.interpolate((flatness_map.get_noise_2d(x / flatness_scale, z / flatness_scale) + 1) / 2.0)
			var terrain : float = height + (roughness * flatness)

			for iy in range(size.y):
				var y : float = world.y + iy
				buffer.set_voxel_f(clamp(y - terrain, -1, 1), ix, iy, iz, channel)
