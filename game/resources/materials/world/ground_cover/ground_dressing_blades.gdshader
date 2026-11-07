shader_type spatial;
// Grass blades round the camera (game/scripts/world/ground_dressing.gd). The
// MultiMesh instances only carry a place in a repeating tile and a rank (its y).
// Everything else comes from the ground's capture here, where a tuft stands
// on the drawn ground, how thick and tall it grows, its colour, so there are no
// stored plants and nothing to go stale when the ground changes.
//
// The mesh (tuft_mesh()) is one tuft at unit height, its blades' centre lines in
// VERTEX, UV.x a blade's half width (signed) and UV.y its length so far, UV2 a blade's
// root in the unit disc, COLOR its side direction (rg), a random number (b) and its
// place in the tuft (a; the first blade is a stem).
//
// Tufts thin out with distance by rank, shrinking away before they go, so nothing
// pops: only the first standing_share() of them stand at a distance, and those grow
// wider so the grass keeps its coverage. Past the ring the ground's own texture carries
// the look: the blades' colour is that ground's, their normals lean to straight up with
// distance, and their ends sink into it.
//
// Grass is never even. On top of the patches in the capture, each tuft takes its own
// size, blade width and colour from a hash of its place: most much alike, a few far
// taller, some greener and some drier, averaging back to the ground's colour so the fade
// stays hidden. A few go to seed, more in long grass, and tufts against an edge run long.
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

#include "res://game/resources/materials/world/vegetation/vegetation_wind.gdshaderinc"
#include "res://game/resources/materials/world/ground_cover/ground_dressing_common.gdshaderinc"

// How far a tuft of a given height carries before it is under a pixel tall.
uniform float reach_per_m = 560.0;
uniform float tuft_radius_m = 0.09;
uniform float blade_width_m = 0.0075;
uniform float width_scale = 1.0;
// How far the blades' feet sink below the drawn ground.
uniform float sink_m = 0.015;
// The last blades of a tuft go between these distances (the far mesh hasn't them), and
// the rest grow wider to make up for it.
uniform vec2 blade_thin_m = vec2(16.0, 24.0);
uniform float sway = 0.16;
// How far blades lie over in the slow drifts a lawn takes on, as a share of their height.
uniform float lay = 0.35;
// Tufts stand a little taller with distance, so grass keeps a broken top: this much
// more, from these distances.
uniform float far_gain = 0.5;
uniform vec2 far_gain_m = vec2(10.0, 35.0);
// Mowers miss what grows against a kerb or a wall: a tuft that much of this away from
// an edge grows up to edge_gain taller and drier. Tufts look only one way, at random,
// so the long grass along an edge comes and goes.
uniform float edge_tap_m = 0.5;
uniform float edge_gain = 1.3;
uniform float edge_reach_m = 60.0;
// The player: x, y, z, and the radius blades bend away within.
uniform vec4 bend_centre = vec4(0.0, -1000.0, 0.0, 1.1);
// Shade along a blade, root to tip, and how much blades differ from each other.
uniform float root_shade = 0.62;
uniform float tip_shade = 1.18;
uniform float blade_contrast = 0.5;
// Neighbouring tufts, as multiples of the ground's colour: some greener, some drier,
// averaging back to it.
uniform vec3 tuft_lush = vec3(0.66, 0.94, 0.92);
uniform vec3 tuft_dry = vec3(1.36, 1.08, 1.08);
// On pale ground (sand, graded fill) tufts are dead grass, not the ground's colour.
uniform vec3 dead_grass : source_color = vec3(0.59, 0.51, 0.35);
// A few tufts have gone to seed, in long grass more than in a lawn: their share, in
// a lawn and in long grass, and the colour of a seed head.
uniform vec2 seeded_share = vec2(0.02, 0.13);
uniform vec3 seed_head : source_color = vec3(0.62, 0.55, 0.4);
// How far normals lean to straight up: at the blades' nearest, and past detail_m.
uniform float normal_up_near = 0.6;
uniform vec2 detail_m = vec2(30.0, 80.0);
uniform float roughness = 0.75;
uniform float specular = 0.25;
uniform float translucency = 0.3;

varying vec3 tint;
#ifdef GROUND_DRESSING_CARDS
// The fallback's alpha-scissor cards (card_mesh(), card_texture()): the same tufts,
// each a few crossed cards instead of blades. Red is a blade's shade.
uniform sampler2D card_texture : filter_linear_mipmap, repeat_disable;
varying vec2 card_uv;
#endif

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	vec2 cell = place.xz;
	float dist = ground_distance(cell, CAMERA_POSITION_WORLD);
	float share = standing_share(dist);
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
#ifdef GROUND_DRESSING_CARDS
	card_uv = vec2(sign(UV.x) * 0.5 + 0.5, 1.0 - UV.y);
#endif
	if (rank < share && dist < ring_end_m) {
		vec3 h = hash32(cell * 7.31);
		vec2 tuft = jittered(cell, h.xy, rank);
		float yaw = h.z * TAU;
		float cy = cos(yaw);
		float sy = sin(yaw);
		vec2 root = tuft + vec2(cy * UV2.x - sy * UV2.y, sy * UV2.x + cy * UV2.y) * tuft_radius_m;
		vec2 map_uv = ground_uv(root);
		vec4 surface = textureLod(ground_surface, map_uv, 0.0);
		float thick = surface.g * smoothstep(0.35, 0.75, surface.a) * in_window(map_uv);
		float kept = min(share, share_margin * thick);
		float stand = clamp((kept - rank) / (0.3 * kept + 0.0001), 0.0, 1.0);
		if (stand > 0.0 && surface.b > 0.0) {
			vec3 g = hash32(cell * 3.17 + vec2(11.3, 5.9));
			float edge = 0.0;
			if (dist < edge_reach_m) {
				vec2 look = vec2(cy, sy) * edge_tap_m;
				edge = step(0.4, h.y) * (1.0 - min(textureLod(ground_surface, ground_uv(tuft + look), 0.0).a, textureLod(ground_surface, ground_uv(tuft - look), 0.0).a));
			}
			float tall = surface.b * (1.0 + edge * edge_gain * (0.3 + 0.7 * g.y));
			float wild = max(smoothstep(0.1, 0.18, tall), edge);
			float reach = min(ring_end_m, reach_per_m * tall);
			float thin_out = smoothstep(blade_thin_m.x, blade_thin_m.y, dist);
			// Most tufts are much of a size; a few stand far above the rest.
			float size = 0.72 + 0.56 * h.x + 1.2 * pow(g.x, 7.0);
			// Only a tuft gone to seed shows its stem's length and head.
			float is_stem = 1.0 - step(0.06, COLOR.a);
			float seeded = step(1.0 - mix(seeded_share.x, seeded_share.y, wild), fract(5.7 * g.z + 3.1 * g.x));
			float height = tall * size * mix(1.0 - 0.35 * is_stem, 1.0, seeded) * stand * (1.0 - thin_out * step(0.62, COLOR.a))
				* (1.0 - smoothstep(0.7 * reach, reach, dist)) * (1.0 + far_gain * smoothstep(far_gain_m.x, far_gain_m.y, dist));
			if (height > 0.003) {
				float t = UV.y;
				float head = is_stem * smoothstep(0.66, 0.74, t);
				float grow = max(dist, full_density_m) / full_density_m;
				vec3 shape = VERTEX;
				vec2 side = COLOR.rg * 2.0 - 1.0;
				vec3 lean = vec3(cy * shape.x - sy * shape.z, shape.y, sy * shape.x + cy * shape.z);
				float width = blade_width_m * width_scale * (0.72 + 0.95 * g.y * g.y) * (1.0 + 0.5 * thin_out) * grow;
				// A seed head doesn't swell with distance as a blade does; an unseeded stem ends thin.
				width *= mix(1.0, mix(0.35, inversesqrt(grow), seeded), head);
				vec3 blade = vec3(root.x, surface.r - sink_m, root.y) + lean * height
					+ vec3(cy * side.x - sy * side.y, 0.0, sy * side.x + cy * side.y) * (UV.x * width);
				// Grass lies over in slow drifts, each tuft its own way within them.
				vec2 over = vec2(sin(root.y * 0.23 + 2.1 * sin(root.x * 0.11)), sin(root.x * 0.19 + 1.7 * sin(root.y * 0.13))) + g.xy - 0.5;
				blade.xz += over * (lay * height * t * t);
				blade += vegetation_wind(blade, vec3(0.0, 1.0, 0.0), vec2(sway * height * t * t, 0.0), MODEL_MATRIX, TIME);
				// Blades lean away from the player and lie down under its feet.
				vec2 away = root - bend_centre.xz;
				float from_player = length(away);
				float press = (1.0 - smoothstep(0.35 * bend_centre.w, bend_centre.w, from_player)) * (1.0 - smoothstep(0.6, 1.6, abs(surface.r - bend_centre.y)));
				blade.xz += away / max(from_player, 0.05) * (press * 0.9 * height * t);
				blade.y -= press * 0.55 * height * t;
				out_vertex = blade - place;

				float detail = 1.0 - smoothstep(detail_m.x, detail_m.y, dist);
				vec3 facing = vec3(cy * NORMAL.x - sy * NORMAL.z, NORMAL.y, sy * NORMAL.x + cy * NORMAL.z) + vec3(over.x, 0.0, over.y) * 0.4;
				out_normal = normalize(mix(normalize(facing), vec3(0.0, 1.0, 0.0), mix(1.0, normal_up_near, detail)));

				float one_blade = fract(COLOR.b + 3.7 * h.x);
				float along = mix(root_shade, tip_shade, pow(t, 0.7));
				vec3 colour = ground_tone(map_uv);
				colour = mix(colour, dead_grass, 0.8 * smoothstep(0.22, 0.4, dot(colour, vec3(0.2126, 0.7152, 0.0722))));
				colour *= mix(vec3(1.0), mix(tuft_lush, tuft_dry, g.z), 0.4 + 0.6 * detail);
				colour *= mix(vec3(1.0), tuft_dry, 0.6 * edge);
				colour *= mix(1.0, along, 0.35 + 0.65 * detail) * (1.0 + (one_blade - 0.5) * blade_contrast * detail);
				tint = mix(colour, seed_head * (0.8 + 0.4 * h.y), 0.8 * head * seeded);
			}
		}
	}
	VERTEX = out_vertex;
	NORMAL = out_normal;
}

void fragment() {
	ALBEDO = tint;
#ifdef GROUND_DRESSING_CARDS
	vec4 card = texture(card_texture, card_uv);
	ALBEDO *= 1.25 * card.r;
	ALPHA = card.a;
	ALPHA_SCISSOR_THRESHOLD = 0.4;
#endif
	ROUGHNESS = roughness;
	SPECULAR = specular;
	// The renderer flips NORMAL on back faces of double-sided materials; a blade is
	// lit the same on both sides.
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	BACKLIGHT = tint * translucency;
}
