shader_type spatial;



uniform float     slope_factor    = 8.0;
uniform float     snow_min        = 100.0;
uniform float     snow_max        = 125.0;

uniform sampler2D texture_grass;
uniform sampler2D texture_dirt;
uniform sampler2D texture_stone;
uniform sampler2D texture_snow;
uniform vec2      texture_scale   = vec2(1.0, 1.0);

varying vec3      world_vertex;
varying vec3      world_normal;
varying vec3      world_position;



uniform int u_transition_mask;

vec3 get_transvoxel_position(vec3 vertex_pos, vec4 vertex_col) {
	int border_mask = int(vertex_col.a);
	int cell_border_mask = border_mask & 63;
	int vertex_border_mask = (border_mask >> 6) & 63;
	int m = u_transition_mask & (cell_border_mask & 63);
	float t = float(m != 0);
	t *= float((vertex_border_mask & ~u_transition_mask) == 0);
	vec3 secondary_position = vertex_col.rgb;
	return mix(vertex_pos, secondary_position, t);
}



float get_slope(float height_normal) {
	float slope = 1.0 - height_normal;
	slope *= slope;
	return slope * slope_factor;
}

float interpolate(float height, float min_height, float max_height) {
	return clamp((height - min_height) / (max_height - min_height), 0.0, 1.0);
}



void vertex() {
	VERTEX   = get_transvoxel_position(VERTEX, COLOR);
	world_vertex   = VERTEX;
	world_normal   = NORMAL;
	world_position = (WORLD_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3  grass = vec3(texture( texture_grass , UV * texture_scale).rgb);
	vec3  snow  = vec3(texture( texture_snow  , UV * texture_scale).rgb);
	vec3  stone = vec3(texture( texture_stone , UV * texture_scale).rgb);

	float slope = clamp(get_slope(world_normal.y), 0.0, 1.0);

	vec3  mixin_grass_snow = mix(grass, snow, interpolate(world_position.y, snow_min, snow_max));
	vec3  mixin            = mix(mixin_grass_snow, stone, slope);

	ALBEDO = mixin;
}
