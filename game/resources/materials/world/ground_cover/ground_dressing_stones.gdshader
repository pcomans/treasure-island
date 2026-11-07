shader_type spatial;
// Small stones and debris round the camera (game/scripts/world/ground_dressing.gd),
// standing on the ground capture like the grass: opaque low-poly rocks, no wind, no
// shadows, near ring only. A rank's first share stands at a distance, so the large
// stones (low ranks) carry on the furthest. stone_mesh() makes the rock: a faceted lump
// and, where UV.x is 1, a skirt lying on the ground, dark under the stone (UV.y) and
// the ground's own colour at its rim: the stone's contact shadow, which needs no sun.
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D ground_surface : filter_linear, repeat_disable;
uniform sampler2D ground_colour : filter_linear, repeat_disable;
uniform vec3 ground_window = vec3(-128.0, -128.0, 0.00390625);

uniform float tile_m = 4.0;
uniform float tile_tufts = 128.0;
uniform float full_density_m = 6.0;
uniform float share_margin = 1.3;
uniform float ring_end_m = 30.0;
uniform float ground_y_m = 4.0;
// A stone's radius from the rarest (largest) to the commonest.
uniform vec2 stone_radius_m = vec2(0.13, 0.018);
uniform float stone_contrast = 0.5;
uniform float skirt_shade = 0.7;

varying vec3 tint;

vec3 hash32(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yxz + 33.33);
	return fract((p3.xxy + p3.yzz) * p3.zyx);
}

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = place.xz;
	float dist = length(vec3(cell.x - CAMERA_POSITION_WORLD.x, ground_y_m - CAMERA_POSITION_WORLD.y, cell.y - CAMERA_POSITION_WORLD.z));
	float ratio = full_density_m / max(dist, full_density_m);
	float share = share_margin * ratio * ratio;
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 5.17);
		vec3 h2 = hash32(cell * 3.73 + vec2(17.1, 9.3));
		vec2 at = cell + (h.xy - 0.5) * (1.3 * tile_m) * inversesqrt(rank * tile_tufts + 1.0);
		vec2 map_uv = (at - ground_window.xy) * ground_window.z;
		vec4 surface = textureLod(ground_surface, map_uv, 0.0);
		float inside = step(0.002, min(map_uv.x, map_uv.y)) * step(max(map_uv.x, map_uv.y), 0.998);
		float amount = max(-surface.b, 0.0) * smoothstep(0.35, 0.75, surface.a) * inside;
		float stand = clamp((share - rank) / (0.3 * share + 0.0001), 0.0, 1.0) * (1.0 - smoothstep(0.7 * ring_end_m, ring_end_m, dist));
		float radius = mix(stone_radius_m.y, stone_radius_m.x, pow(1.0 - rank, 9.0)) * stand * (0.7 + 0.6 * h2.y);
		if (h2.x < amount && radius > 0.002) {
			float yaw = h.z * TAU;
			float cy = cos(yaw);
			float sy = sin(yaw);
			// Most are rounded lumps; some are flat shards of concrete and brick.
			float shard = step(0.82, h2.z);
			vec3 stretch = mix(vec3(1.0, 0.7 + 0.4 * h.x, 0.75 + 0.4 * h.y), vec3(1.7, 0.3, 0.7), shard);
			vec3 local = VERTEX * stretch;
			vec3 stone = vec3(cy * local.x - sy * local.z, local.y, sy * local.x + cy * local.z) * radius;
			vec3 normal = NORMAL / stretch;
			normal = normalize(vec3(cy * normal.x - sy * normal.z, normal.y, sy * normal.x + cy * normal.z));
			vec4 ground = textureLod(ground_colour, map_uv, 0.0);
			vec3 ground_tone = ground.rgb / max(ground.a, 0.02);
			if (UV.x > 0.5) {
				stone.y = 0.012;
				normal = vec3(0.0, 1.0, 0.0);
				tint = ground_tone * mix(1.0, skirt_shade, UV.y);
			} else {
				// Stones lean grey beside the ground they lie on, lighter than it, since
				// their sides turn from the sun.
				float grey = dot(ground_tone, vec3(0.2126, 0.7152, 0.0722));
				tint = mix(ground_tone, vec3(grey * 1.02, grey, grey * 0.94), 0.4) * (1.15 + stone_contrast * (h.x - 0.5)) * (1.0 + 0.1 * shard);
			}
			out_vertex = vec3(at.x, surface.r, at.y) + stone - place;
			out_normal = normal;
		}
	}
	VERTEX = out_vertex;
	NORMAL = out_normal;
}

void fragment() {
	ALBEDO = tint;
	ROUGHNESS = 0.92;
	SPECULAR = 0.2;
}
