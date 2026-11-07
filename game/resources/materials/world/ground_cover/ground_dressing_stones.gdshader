shader_type spatial;
// Small stones, debris and rubble round the camera (game/scripts/world/ground_dressing.gd),
// standing on the ground capture like the grass: opaque low-poly rocks, no wind, no
// shadows, near ring only. A rank's first share stands at a distance, so the large
// stones (low ranks) carry on the furthest. stone_mesh() makes the rock: a closed faceted
// lump and, where UV.x is 1, a skirt lying on the ground, dark under the stone (UV.y) and
// the ground's own colour at its rim: the stone's contact shadow, which needs no sun.
// Both follow the ground's slope, and each stone sits part buried in it.
//
// On rubble (the capture's stones past 1) a piece wears the heap's own texture, the skirt
// at the ground's own place in it, so a piece rises out of the heap rather than lying on it.
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

#include "res://game/resources/materials/world/ground_cover/ground_dressing_common.gdshaderinc"

// A stone's radius from the rarest (largest) to the commonest.
uniform vec2 stone_radius_m = vec2(0.13, 0.018);
uniform float stone_contrast = 0.5;
uniform float skirt_shade = 0.7;
// How much of a stone sits below the ground, as a share of its radius.
uniform float buried = 0.25;
uniform float rubble_buried = 0.38;
// On rubble the skirt is fainter (a dark ring reads as a pit in the pale heap), and
// pieces only break the heap's outline further off: near the camera, where its texture
// holds up by itself, they shrink away, to this share of their size, between these
// distances.
uniform float rubble_skirt = 0.95;
uniform float rubble_near_size = 0.0;
uniform vec2 rubble_near_m = vec2(12.0, 28.0);
// The heap's texture, its tint and its tile, as the surface's own material has them.
uniform sampler2D rubble_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec3 rubble_tint : source_color = vec3(1.0);
uniform float rubble_tile_m = 3.0;

varying vec3 tint;
varying float on_rubble;
varying vec3 at_world;
varying vec3 stone_normal;

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = floor(place.xz * 64.0 + 0.5) / 64.0;
	float dist = ground_distance(cell, CAMERA_POSITION_WORLD);
	float share = standing_share(dist);
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
	on_rubble = 0.0;
	at_world = vec3(0.0);
	stone_normal = vec3(0.0, 1.0, 0.0);
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 5.17);
		vec3 h2 = hash32(cell * 3.73 + vec2(17.1, 9.3));
		vec2 at = jittered(cell, h.xy, rank);
		vec2 map_uv = ground_uv(at);
		vec4 surface = textureLod(ground_surface, map_uv, 0.0);
		float lying = max(-surface.b, 0.0) * smoothstep(0.35, 0.75, surface.a) * in_window(map_uv);
		float rubble = step(1.0, lying);
		float amount = lying - rubble;
		float stand = clamp((share - rank) / (0.3 * share + 0.0001), 0.0, 1.0) * (1.0 - smoothstep(0.7 * ring_end_m, ring_end_m, dist));
		// Rubble lies in pieces of every size, up to well over the stones in a field.
		float radius = mix(stone_radius_m.y, stone_radius_m.x, pow(1.0 - rank, mix(9.0, 5.0, rubble))) * stand * mix(0.7 + 0.6 * h2.y, 0.45 + 1.1 * h2.y, rubble) * (1.0 + 1.6 * rubble);
		radius *= mix(1.0, mix(rubble_near_size, 1.0, smoothstep(rubble_near_m.x, rubble_near_m.y, dist)), rubble);
		if (h2.x < amount && radius > 0.002) {
			float yaw = h.z * TAU;
			float cy = cos(yaw);
			float sy = sin(yaw);
			// The ground's slope over a metre.
			float step_uv = 0.5 * ground_window.z;
			vec2 slope = vec2(textureLod(ground_surface, map_uv + vec2(step_uv, 0.0), 0.0).r - textureLod(ground_surface, map_uv - vec2(step_uv, 0.0), 0.0).r,
				textureLod(ground_surface, map_uv + vec2(0.0, step_uv), 0.0).r - textureLod(ground_surface, map_uv - vec2(0.0, step_uv), 0.0).r);
			// Most are rounded lumps; some are flat shards of concrete and brick.
			float shard = step(0.82, h2.z);
			vec3 stretch = mix(vec3(1.0, 0.7 + 0.4 * h.x, 0.75 + 0.4 * h.y), vec3(1.7, 0.42, 0.8), shard);
			// It lies as it fell, tipped to one side.
			float tip = (h2.y - 0.5) * 1.1;
			float ct = cos(tip);
			float st = sin(tip);
			vec3 local = VERTEX * stretch;
			local = vec3(local.x, ct * local.y - st * local.z, st * local.y + ct * local.z);
			vec3 stone = vec3(cy * local.x - sy * local.z, local.y, sy * local.x + cy * local.z) * radius;
			vec3 normal = NORMAL / stretch;
			normal = vec3(normal.x, ct * normal.y - st * normal.z, st * normal.y + ct * normal.z);
			normal = normalize(vec3(cy * normal.x - sy * normal.z, normal.y, sy * normal.x + cy * normal.z));
			vec3 tone = ground_tone(map_uv);
			// Each broken face catches its own tone.
			float face = fract(dot(NORMAL, vec3(12.9, 78.2, 37.7)));
			if (UV.x > 0.5) {
				stone.y = 0.012;
				normal = vec3(0.0, 1.0, 0.0);
				tint = mix(tone * mix(1.0, skirt_shade, UV.y), vec3(mix(1.0, rubble_skirt, UV.y)), rubble);
			} else {
				stone.y -= mix(buried, rubble_buried, rubble) * radius * stretch.y;
				// Its foot sits in its own shade.
				float foot = mix(mix(0.6, 0.82, rubble), 1.0, smoothstep(-0.1, 0.45, local.y));
				// Stones lean grey beside the ground they lie on, lighter than it, since
				// their sides turn from the sun.
				float grey = dot(tone, vec3(0.2126, 0.7152, 0.0722));
				vec3 rock = mix(tone, vec3(grey * 1.02, grey, grey * 0.94), 0.4) * (1.15 + stone_contrast * (h.x - 0.5)) * (1.0 + 0.1 * shard) * (0.86 + 0.28 * face);
				tint = mix(rock, vec3((1.05 + 0.3 * h.y) * (0.9 + 0.2 * face)), rubble) * foot;
			}
			// The stone and its skirt follow the slope, and a piece of rubble is lit much
			// like the heap it lies in.
			stone.y += stone.x * slope.x + stone.z * slope.y;
			normal = normalize(mix(normal, vec3(0.0, 1.0, 0.0), 0.6 * rubble));
			normal = normalize(vec3(normal.x - slope.x * normal.y, normal.y, normal.z - slope.y * normal.y));
			out_vertex = vec3(at.x, surface.r, at.y) + stone - place;
			out_normal = normal;
			on_rubble = rubble;
			at_world = vec3(at.x, surface.r, at.y) + stone;
			stone_normal = normal;
		}
	}
	VERTEX = out_vertex;
	NORMAL = out_normal;
}

void fragment() {
	// On rubble, the heap's texture from above, where the skirt meets the heap's own, and
	// laid along a steep face from the side.
	vec3 above = texture(rubble_albedo, at_world.xz / rubble_tile_m).rgb;
	vec3 beside = texture(rubble_albedo, vec2(at_world.x + at_world.z, at_world.y) / rubble_tile_m).rgb;
	ALBEDO = tint * mix(vec3(1.0), rubble_tint * mix(beside, above, smoothstep(0.35, 0.75, abs(stone_normal.y))), on_rubble);
	ROUGHNESS = 0.92;
	SPECULAR = 0.2;
}
