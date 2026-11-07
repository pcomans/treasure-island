shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// The Mersea promenade's pavement (owner video IMG_0960, Nov 2026): an old road's
// asphalt worn back to its stones, in long bands. One generated tile of exposed
// aggregate, read at two scales so its repeat never shows down the long view, then
// the wear the footage shows: a broad drift in tone, blotches, long dark wheel tracks
// and pale scuffs running with the road, and a darker lane seaward of its old edge
// line. wear is 1 on the old road and low on the fresh seal. All of it is the
// surface's own colour, so it holds under any sun; the low specular keeps the sky's
// sheen from washing the warm road blue at a walker's grazing angle.

uniform sampler2D aggregate : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 tone : source_color = vec3(0.7, 0.7, 0.7);
uniform float tile_m = 2.4;
uniform float wear = 1.0;
// The road's frame: its origin and direction, x and z (promenade_layout's O and U).
uniform vec2 road_origin = vec2(-346.3, 327.9);
uniform vec2 road_along = vec2(-0.4924, -0.8704);
// How far across the road, toward the land, the darker seaward lane ends.
uniform float lane_edge_m = -2.2;

varying vec2 ground;

float hash12(vec2 p) {
	vec3 q = fract(vec3(p.xyx) * 0.1031);
	q += dot(q, q.yzx + 33.33);
	return fract((q.x + q.y) * q.z);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash12(cell), hash12(cell + vec2(1.0, 0.0)), u.x), mix(hash12(cell + vec2(0.0, 1.0)), hash12(cell + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	ground = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

void fragment() {
	vec2 from_origin = ground - road_origin;
	vec2 road = vec2(dot(from_origin, road_along), dot(from_origin, vec2(-road_along.y, road_along.x)));
	vec3 stones = texture(aggregate, ground / tile_m).rgb;
	vec3 other = texture(aggregate, mat2(vec2(0.799, 0.602), vec2(-0.602, 0.799)) * ground / (tile_m * 1.37) + vec2(0.37, 0.71)).rgb;
	stones = mix(stones, other, smoothstep(0.35, 0.65, value_noise(ground / 6.1 + vec2(3.7, 29.1))));

	float drift = 0.6 * value_noise(ground / 29.0 + vec2(17.3, 5.1)) + 0.4 * value_noise(ground / 9.0 + vec2(5.9, 41.7));
	float blotch = value_noise(ground / 2.7 + vec2(29.3, 11.9));
	float dark_track = smoothstep(0.56, 0.72, 0.7 * value_noise(vec2(road.x / 46.0, road.y / 1.4)) + 0.3 * value_noise(vec2(road.x / 11.0 + 7.1, road.y / 0.5)));
	float pale_track = smoothstep(0.6, 0.76, 0.7 * value_noise(vec2(road.x / 60.0 + 31.0, road.y / 0.8 + 13.0)) + 0.3 * value_noise(vec2(road.x / 13.0, road.y / 0.3 + 3.3)));
	float ragged = 0.7 * (value_noise(vec2(road.x / 7.0, 3.1)) - 0.5);
	float lane = 1.0 - smoothstep(lane_edge_m - 0.35, lane_edge_m + 0.2, road.y + ragged);
	float shade = 1.0 + 0.32 * (drift - 0.5) + 0.2 * (blotch - 0.5);
	shade *= 1.0 - 0.3 * dark_track * (0.6 + 0.4 * lane);
	shade *= 1.0 + 0.16 * pale_track * (1.0 - 0.7 * lane);
	shade *= 1.0 - 0.32 * lane;

	ALBEDO = stones * tone * mix(1.0, shade, wear);
	ROUGHNESS = 0.96;
	SPECULAR = 0.18;
}
