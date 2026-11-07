shader_type spatial;
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// The Mersea promenade's pavement (owner video IMG_0960, Nov 2026): an old road's
// asphalt worn back to its stones. One tile of aggregate, read at two scales so its
// repeat never shows down the long view, then the wear the footage shows: a low drift
// in tone, one or two narrow scuffs, and a darker lane seaward of its old edge line
// that gives out toward the road's north end. wear is 1 on the old road and low on the
// fresh seal, whose grain is the same tile read fine and flat (contrast). All of it is
// the surface's own colour, so it holds under any sun; the low specular keeps the
// sky's sheen from washing the warm road blue at a walker's grazing angle.

uniform sampler2D aggregate : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 tone : source_color = vec3(0.7, 0.7, 0.7);
uniform float tile_m = 1.15;
uniform float wear = 1.0;
uniform float contrast = 1.0;
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
	stones = mix(textureLod(aggregate, vec2(0.5), 11.0).rgb, stones, contrast);

	float drift = 0.6 * value_noise(ground / 29.0 + vec2(17.3, 5.1)) + 0.4 * value_noise(ground / 9.0 + vec2(5.9, 41.7));
	float blotch = value_noise(ground / 2.7 + vec2(29.3, 11.9));
	// A dark wheel scuff seaward of the old line and a fainter one by the crown, each
	// about 0.4 m wide, wandering a little and broken along their length.
	float wander = value_noise(vec2(road.x / 31.0, 2.7)) - 0.5;
	float scuff_sea = (1.0 - smoothstep(0.08, 0.3, abs(road.y + 3.5 + 0.7 * wander))) * smoothstep(0.34, 0.56, value_noise(vec2(road.x / 17.0, 9.1)));
	float scuff_crown = (1.0 - smoothstep(0.05, 0.2, abs(road.y - 3.1 - 0.5 * wander))) * smoothstep(0.5, 0.68, value_noise(vec2(road.x / 13.0, 5.3)));
	float ragged = 0.7 * (value_noise(vec2(road.x / 7.0, 3.1)) - 0.5);
	float lane = (1.0 - smoothstep(lane_edge_m - 0.35, lane_edge_m + 0.2, road.y + ragged)) * (1.0 - smoothstep(130.0, 176.0, road.x));
	float shade = 1.0 + 0.2 * (drift - 0.5) + 0.14 * (blotch - 0.5);
	shade *= 1.0 - 0.3 * scuff_sea - 0.14 * scuff_crown;
	shade *= 1.0 - 0.45 * lane;

	ALBEDO = stones * tone * mix(1.0, shade, wear);
	ROUGHNESS = 0.96;
	SPECULAR = 0.18;
}
