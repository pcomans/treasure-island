shader_type spatial;
// Small stones and debris round the camera (game/scripts/world/ground_dressing.gd),
// standing on the ground capture like the grass: opaque low-poly rocks, no wind, no
// shadows, near ring only. A rank's first share stands at a distance, so the large
// stones (low ranks) carry on the furthest. stone_mesh() makes the rock: a faceted lump
// and, where UV.x is 1, a skirt lying on the ground, dark under the stone (UV.y) and
// the ground's own colour at its rim: the stone's contact shadow, which needs no sun.
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

#include "res://game/resources/materials/world/ground_cover/ground_dressing_common.gdshaderinc"

// A stone's radius from the rarest (largest) to the commonest.
uniform vec2 stone_radius_m = vec2(0.13, 0.018);
uniform float stone_contrast = 0.5;
uniform float skirt_shade = 0.7;

varying vec3 tint;

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = place.xz;
	float dist = ground_distance(cell, CAMERA_POSITION_WORLD);
	float share = standing_share(dist);
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 5.17);
		vec3 h2 = hash32(cell * 3.73 + vec2(17.1, 9.3));
		vec2 at = jittered(cell, h.xy, rank);
		vec2 map_uv = ground_uv(at);
		vec4 surface = textureLod(ground_surface, map_uv, 0.0);
		float amount = max(-surface.b, 0.0) * smoothstep(0.35, 0.75, surface.a) * in_window(map_uv);
		float stand = clamp((share - rank) / (0.3 * share + 0.0001), 0.0, 1.0) * (1.0 - smoothstep(0.7 * ring_end_m, ring_end_m, dist));
		// Rubble lies in pieces of every size, up to well over the stones in a field.
		float rubble = smoothstep(0.6, 0.85, amount);
		float radius = mix(stone_radius_m.y, stone_radius_m.x, pow(1.0 - rank, mix(9.0, 2.5, rubble))) * stand * (0.7 + 0.6 * h2.y) * (1.0 + 1.3 * rubble);
		if (h2.x < amount && radius > 0.002) {
			float yaw = h.z * TAU;
			float cy = cos(yaw);
			float sy = sin(yaw);
			// Most are rounded lumps; some are flat shards of concrete and brick.
			float shard = step(0.82, h2.z);
			vec3 stretch = mix(vec3(1.0, 0.7 + 0.4 * h.x, 0.75 + 0.4 * h.y), vec3(1.7, 0.3, 0.7), shard);
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
			// A piece of rubble is lit much like the pale heap it lies in.
			normal = normalize(mix(normal, vec3(0.0, 1.0, 0.0), 0.6 * rubble));
			vec3 tone = ground_tone(map_uv);
			if (UV.x > 0.5) {
				// Rubble lies heaped on itself, with no ground for a skirt to lie on.
				stone *= 1.0 - step(0.3, rubble);
				stone.y = 0.012;
				normal = vec3(0.0, 1.0, 0.0);
				tint = tone * mix(1.0, skirt_shade, UV.y);
			} else {
				// Stones lean grey beside the ground they lie on, lighter than it, since
				// their sides turn from the sun.
				float grey = dot(tone, vec3(0.2126, 0.7152, 0.0722));
				// Each broken face catches its own tone.
				float face = fract(dot(NORMAL, vec3(12.9, 78.2, 37.7)));
				tint = mix(tone, vec3(grey * 1.02, grey, grey * 0.94), 0.4) * (1.15 + 0.35 * rubble + stone_contrast * (h.x - 0.5)) * (1.0 + 0.1 * shard) * (0.86 + 0.28 * face);
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
