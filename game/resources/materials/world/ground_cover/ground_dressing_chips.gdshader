shader_type spatial;
// Loose wood chips on mulch round the camera (game/scripts/world/ground_dressing.gd),
// standing on the chips capture like the stones on the surface capture: a low ridged
// sliver each, lying flat or with one end on another chip, turned any way. The chips
// capture's red is the mulch's height, alpha where it lies; the colour capture gives the
// bed's own colour, which a chip takes weathered grey, brown or dark. No wind, no
// shadows, near ring only: they thin out with distance as the grass does and shrink away
// over the ring's outer part, where the bed's own texture carries the chips.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

#include "res://game/resources/materials/world/ground_cover/ground_dressing_common.gdshaderinc"

// The chips capture: red the mulch's height (metres), alpha where it lies. It covers its
// own, smaller window round the same centre as ground_window: its corner in world x, z
// and one over its size.
uniform sampler2D ground_chips : filter_linear, repeat_disable;
uniform vec3 chips_window = vec3(-48.0, -48.0, 0.0104166667);
// A chip's length, shortest to longest (most are short), and its width and ridge as
// shares of its length (chip_mesh() is unit long, unit wide, its ridge 1 high).
uniform vec2 chip_length_m = vec2(0.03, 0.085);
uniform vec2 chip_width = vec2(0.22, 0.42);
uniform float chip_ridge = 0.14;
// How far a chip's raised end stands, as a share of its length, and how far its foot
// sinks into the bed.
uniform float chip_tilt = 0.28;
uniform float chip_sink_m = 0.002;
// A chip's colour as multiples of the bed's mean (which counts its dark gaps):
// weathered grey (desaturated, about as pale as the bed's own grey chips), brown and
// dark, and the shares of the first two (the rest are dark). The chips cover under a
// tenth of the bed, so where they thin out its tone hardly moves.
uniform vec3 chip_grey = vec3(2.3, 2.28, 2.2);
uniform vec3 chip_brown = vec3(1.0, 0.9, 0.8);
uniform vec3 chip_dark = vec3(0.45, 0.42, 0.4);
uniform vec2 chip_shares = vec2(0.5, 0.32);
// The most green and blue a chip keeps, as shares of its red.
uniform vec3 chip_warmth = vec3(1.0, 0.96, 0.88);
// At a bed's edge the capture's cover falls from 1 to 0 over about a texel: each chip
// lies where the cover passes its own threshold in this range, so the edge is ragged
// and a few chips lie just past it.
uniform vec2 chip_edge = vec2(0.3, 0.95);

varying vec3 tint;
varying vec2 chip_uv;

vec2 chips_uv(vec2 place) {
	return (place - chips_window.xy) * chips_window.z;
}

float mulch_height(vec4 sample_value, float fallback) {
	return sample_value.a > 0.25 ? sample_value.r / sample_value.a : fallback;
}

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = floor(place.xz * 64.0 + 0.5) / 64.0;
	float dist = ground_distance(cell, CAMERA_POSITION_WORLD);
	float share = standing_share(dist);
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
	chip_uv = UV;
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 9.71);
		vec3 h2 = hash32(cell * 4.13 + vec2(7.7, 21.1));
		vec2 at = jittered(cell, h.xy, rank);
		vec2 chip_map = chips_uv(at);
		vec4 chips = textureLod(ground_chips, chip_map, 0.0);
		float cover = chips.a * in_window(chip_map);
		float threshold = mix(chip_edge.x, chip_edge.y, fract(h.z * 17.31 + h2.x * 5.13));
		float stand = clamp((share - rank) / (0.3 * share + 0.0001), 0.0, 1.0) * (1.0 - smoothstep(0.6 * ring_end_m, ring_end_m, dist));
		if (cover > threshold && stand > 0.0) {
			float y = chips.r / chips.a;
			// The bed's slope over half a metre.
			float step_uv = 0.25 * chips_window.z;
			vec2 slope = vec2(mulch_height(textureLod(ground_chips, chip_map + vec2(step_uv, 0.0), 0.0), y) - mulch_height(textureLod(ground_chips, chip_map - vec2(step_uv, 0.0), 0.0), y),
				mulch_height(textureLod(ground_chips, chip_map + vec2(0.0, step_uv), 0.0), y) - mulch_height(textureLod(ground_chips, chip_map - vec2(0.0, step_uv), 0.0), y)) / 0.5;
			slope = clamp(slope, vec2(-1.0), vec2(1.0));
			float length_m = mix(chip_length_m.x, chip_length_m.y, h2.x * h2.x) * stand;
			vec3 stretch = vec3(1.0, chip_ridge, mix(chip_width.x, chip_width.y, h2.y));
			float yaw = h.z * TAU;
			float cy = cos(yaw);
			float sy = sin(yaw);
			// One end lifted onto another chip, about the chip's width.
			float tip = (h2.z - 0.5) * 2.0 * chip_tilt;
			float ct = cos(tip);
			float st = sin(tip);
			vec3 local = VERTEX * stretch;
			local = vec3(ct * local.x - st * local.y, st * local.x + ct * local.y, local.z);
			vec3 chip = vec3(cy * local.x - sy * local.z, local.y, sy * local.x + cy * local.z) * length_m;
			chip.y += abs(tip) * 0.5 * length_m - chip_sink_m;
			// The mesh's normals scaled by the inverse of its stretch, then turned with it.
			vec3 normal = NORMAL / stretch;
			normal = vec3(ct * normal.x - st * normal.y, st * normal.x + ct * normal.y, normal.z);
			normal = normalize(vec3(cy * normal.x - sy * normal.z, normal.y, sy * normal.x + cy * normal.z));
			// It follows the bed's slope.
			chip.y += chip.x * slope.x + chip.z * slope.y;
			normal = normalize(vec3(normal.x - slope.x * normal.y, normal.y, normal.z - slope.y * normal.y));
			out_vertex = vec3(at.x, y, at.y) + chip - place;
			out_normal = normal;
			vec3 tone = ground_tone(ground_uv(at));
			float grey = dot(tone, vec3(0.2126, 0.7152, 0.0722));
			float pick = fract(h.x * 7.31 + h2.z * 3.17 + h2.y * 1.13);
			vec3 colour = pick < chip_shares.x ? vec3(grey) * chip_grey : (pick < chip_shares.x + chip_shares.y ? tone * chip_brown : tone * chip_dark);
			// Wood is never bluer than it is red: a weathered chip stays warm grey under the
			// sky, and one beside paving doesn't take the paving's grey-blue.
			colour = min(colour, colour.r * chip_warmth);
			tint = colour * (0.82 + 0.36 * fract(h2.x * 13.7 + h.y * 5.3));
		}
	}
	VERTEX = out_vertex;
	NORMAL = out_normal;
}

void fragment() {
	// Fibres along the chip, and its long edges a little darker.
	float fibre = 0.88 + 0.12 * sin(chip_uv.y * 37.0 + sin(chip_uv.x * 5.1) * 2.0);
	float edge = 1.0 - 0.25 * smoothstep(0.32, 0.5, abs(chip_uv.y - 0.5));
	ALBEDO = tint * fibre * edge;
	ROUGHNESS = 0.9;
	SPECULAR = 0.2;
}
