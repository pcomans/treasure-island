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
// place in the tuft (a): a stem first, then upright blades, those lying along the ground
// and last the extra blades only the nearest tufts have.
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

// How far a tuft carries, for its height: this far at any height, and this much more a metre.
uniform vec2 reach_m = vec2(30.0, 340.0);
uniform float tuft_radius_m = 0.09;
uniform float blade_width_m = 0.0075;
// Mown turf is finer and closer than long grass: its blades this much wider, so its
// short height still hides the ground.
uniform float turf_width = 1.15;
uniform float width_scale = 1.0;
// How far the blades' feet sink below the drawn ground.
uniform float sink_m = 0.015;
// The blades lying along the ground go between these distances (the far mesh hasn't
// them), and the rest grow wider to make up for it; the extra blades go sooner.
uniform vec2 blade_thin_m = vec2(16.0, 24.0);
uniform vec2 extra_thin_m = vec2(5.0, 8.0);
uniform float sway = 0.16;
// How far blades lie over, as a share of their height: in the slow drifts a lawn takes
// on, more in long grass, which also swirls and mats in patches, and on the blades
// lying along the ground.
uniform float lay = 0.3;
uniform float lay_long = 0.5;
uniform float lay_lying = 0.8;
// Tufts stand a little taller with distance, so grass keeps a broken top: this much
// more, from these distances.
uniform float far_gain = 0.5;
uniform vec2 far_gain_m = vec2(10.0, 35.0);
// Mowers miss what grows against a kerb or a wall: a tuft within edge_tap_m of an edge
// grows up to edge_gain taller and drier. Tufts look only one way, at random, and many
// don't look at all, so the long grass along an edge comes and goes.
uniform float edge_tap_m = 0.5;
uniform float edge_gain = 1.3;
uniform float edge_reach_m = 60.0;
// The player: x, y, z, and the radius blades bend away within.
uniform vec4 bend_centre = vec4(0.0, -1000.0, 0.0, 0.6);
// A tuft takes how it grows and its colour from this far off along a slow wander, so
// the line between two grounds or patches runs ragged, not as drawn.
uniform float wander_m = 1.3;
// Shade along a blade, root to tip, and how much blades differ from each other.
uniform float root_shade = 0.62;
uniform float tip_shade = 1.18;
uniform float blade_contrast = 0.5;
// Neighbouring tufts, as multiples of the ground's colour: some greener, some drier,
// averaging back to it; in straw some darker and some paler instead.
uniform vec3 tuft_lush = vec3(0.66, 0.94, 0.92);
uniform vec3 tuft_dry = vec3(1.36, 1.08, 1.08);
uniform vec3 tuft_straw_dark = vec3(0.66, 0.66, 0.68);
uniform vec3 tuft_straw_pale = vec3(1.34, 1.34, 1.36);
// Blades lying in long grass are its dark thatch, as a multiple of its colour.
uniform float thatch_shade = 0.55;
// On pale ground (sand, graded fill) tufts are dead grass, not the ground's colour.
uniform vec3 dead_grass : source_color = vec3(0.59, 0.51, 0.35);
// A few tufts have gone to seed, in long grass more than in a lawn: their share, in
// a lawn and in long grass, and the colour of a seed head.
uniform vec2 seeded_share = vec2(0.002, 0.07);
uniform vec3 seed_head : source_color = vec3(0.62, 0.55, 0.4);
// How far normals lean to straight up: at the blades' nearest, and past detail_m.
uniform float normal_up_near = 0.6;
uniform vec2 detail_m = vec2(30.0, 80.0);
uniform float roughness = 0.75;
uniform float specular = 0.25;
uniform float translucency = 0.3;

varying vec3 tint;
varying float backlight;
#ifdef GROUND_DRESSING_CARDS
// The fallback's alpha-scissor cards (card_mesh(), card_texture()): the same tufts,
// each a few crossed cards instead of blades. Red is a blade's shade.
uniform sampler2D card_texture : filter_linear_mipmap, repeat_disable;
varying vec2 card_uv;
#endif

void vertex() {
	vec3 place = MODEL_MATRIX[3].xyz;
	float rank = place.y;
	// A point's place to the 1/64 m, so a cell of any size hashes it alike.
	vec2 cell = floor(place.xz * 64.0 + 0.5) / 64.0;
	float dist = ground_distance(cell, CAMERA_POSITION_WORLD);
	float share = standing_share(dist);
	vec3 out_vertex = vec3(0.0);
	vec3 out_normal = vec3(0.0, 1.0, 0.0);
	tint = vec3(0.0);
	backlight = 0.0;
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
		// How it grows comes from a little way off, unless that is across an edge.
		vec2 wander = wander_m * vec2(sin(tuft.y * 2.3 + 1.7 * sin(tuft.x * 1.1)), sin(tuft.x * 1.9 + 1.3 * sin(tuft.y * 1.3)));
		vec2 growth_uv = ground_uv(root + wander);
		vec4 growth = textureLod(ground_surface, growth_uv, 0.0);
		float over_edge = 1.0 - step(0.75, growth.a);
		growth_uv = mix(growth_uv, map_uv, over_edge);
		growth = mix(growth, surface, over_edge);
		float thick = growth.g * smoothstep(0.35, 0.75, surface.a) * in_window(map_uv);
		float kept = min(share, share_margin * thick);
		float stand = clamp((kept - rank) / (0.3 * kept + 0.0001), 0.0, 1.0);
		if (stand > 0.0 && growth.b > 0.0) {
			vec3 g = hash32(cell * 3.17 + vec2(11.3, 5.9));
			float edge = 0.0;
			if (dist < edge_reach_m) {
				vec2 look = vec2(cy, sy) * edge_tap_m;
				edge = step(0.4, h.y) * (1.0 - min(textureLod(ground_surface, ground_uv(tuft + look), 0.0).a, textureLod(ground_surface, ground_uv(tuft - look), 0.0).a));
			}
			float long_grass = smoothstep(0.1, 0.18, growth.b);
			float tall = growth.b * (1.0 + edge * edge_gain * (0.3 + 0.7 * g.y));
			float reach = min(ring_end_m, reach_m.x + reach_m.y * tall);
			float thin_out = smoothstep(blade_thin_m.x, blade_thin_m.y, dist);
			// Turf is even; in long grass most tufts are low and a few stand far above the rest.
			float size = mix(0.88 + 0.24 * h.x + 0.15 * pow(g.x, 7.0), 0.45 + 0.8 * h.x + 1.5 * pow(g.x, 5.0), long_grass);
			float is_stem = 1.0 - step(0.04, COLOR.a);
			float is_extra = step(0.62, COLOR.a);
			float is_lying = step(0.4, COLOR.a) * (1.0 - is_extra);
			// Only a tuft gone to seed shows its stem's length and head.
			float seeded = step(1.0 - mix(seeded_share.x, seeded_share.y, long_grass), fract(5.7 * g.z + 3.1 * g.x));
			float height = tall * size * mix(1.0 - 0.35 * is_stem, 1.0, seeded) * stand * (1.0 - thin_out * is_lying) * (1.0 - smoothstep(extra_thin_m.x, extra_thin_m.y, dist) * is_extra)
				* (1.0 - smoothstep(0.7 * reach, reach, dist)) * (1.0 + far_gain * smoothstep(far_gain_m.x, far_gain_m.y, dist));
			if (height > 0.003) {
				float t = UV.y;
				float head = is_stem * smoothstep(0.66, 0.74, t);
				float grow = max(dist, full_density_m) / full_density_m;
				vec3 shape = VERTEX;
				vec2 side = COLOR.rg * 2.0 - 1.0;
				vec3 lean = vec3(cy * shape.x - sy * shape.z, shape.y, sy * shape.x + cy * shape.z);
				float width = blade_width_m * width_scale * mix(turf_width, 1.0, long_grass) * (0.72 + 0.95 * g.y * g.y) * (1.0 + 0.5 * thin_out) * grow;
				// A seed head doesn't swell with distance as a blade does; an unseeded stem ends thin.
				width *= mix(1.0, mix(0.35, inversesqrt(grow), seeded), head);
				vec3 blade = vec3(root.x, surface.r - sink_m, root.y) + lean * height
					+ vec3(cy * side.x - sy * side.y, 0.0, sy * side.x + cy * side.y) * (UV.x * width);
				// Grass lies over in slow drifts, each tuft its own way within them, and long
				// grass swirls and mats besides, bowing as it goes.
				vec2 drift = vec2(sin(root.y * 0.23 + 2.1 * sin(root.x * 0.11)), sin(root.x * 0.19 + 1.7 * sin(root.y * 0.13)));
				vec2 swirl = vec2(sin(root.y * 1.1 + 2.3 * sin(root.x * 0.7)), sin(root.x * 0.9 + 1.9 * sin(root.y * 0.8)));
				vec2 over = drift + long_grass * swirl + g.xy - 0.5;
				float bow = (lay + lay_long * long_grass + lay_lying * is_lying) * height * t * t;
				blade.xz += over * bow;
				blade.y -= 0.3 * long_grass * length(over) * bow;
				blade += vegetation_wind(blade, vec3(0.0, 1.0, 0.0), vec2(sway * height * t * t, 0.0), MODEL_MATRIX, TIME);
				// Blades part round the player: each lean its own, so it leaves no ring.
				vec2 away = root - bend_centre.xz + (g.xy - 0.5) * (0.8 * bend_centre.w);
				float from_player = length(away);
				float press = (1.0 - smoothstep(0.3 * bend_centre.w, bend_centre.w, from_player)) * (1.0 - smoothstep(0.6, 1.6, abs(surface.r - bend_centre.y))) * (0.4 + 0.9 * h.y);
				blade.xz += away / max(from_player, 0.05) * (press * 0.55 * height * t);
				blade.y -= press * 0.25 * height * t;
				out_vertex = blade - place;

				float detail = 1.0 - smoothstep(detail_m.x, detail_m.y, dist);
				vec3 facing = vec3(cy * NORMAL.x - sy * NORMAL.z, NORMAL.y, sy * NORMAL.x + cy * NORMAL.z) + vec3(over.x, 0.0, over.y) * 0.4;
				out_normal = normalize(mix(normalize(facing), vec3(0.0, 1.0, 0.0), mix(1.0, normal_up_near, detail)));

				float one_blade = fract(COLOR.b + 3.7 * h.x);
				float along = mix(root_shade, tip_shade, pow(t, 0.7));
				vec3 colour = ground_tone(growth_uv);
				colour = mix(colour, dead_grass, 0.8 * smoothstep(0.22, 0.4, dot(colour, vec3(0.2126, 0.7152, 0.0722))));
				float straw = smoothstep(0.92, 1.12, colour.r / max(colour.g, 0.001));
				// Mown turf differs less from tuft to tuft than long grass.
				colour *= mix(vec3(1.0), mix(mix(tuft_lush, tuft_dry, g.z), mix(tuft_straw_dark, tuft_straw_pale, g.z), straw), (0.4 + 0.6 * detail) * mix(0.55, 1.0, long_grass));
				colour *= mix(vec3(1.0), tuft_dry, 0.6 * edge * (1.0 - straw));
				colour *= mix(1.0, along, 0.35 + 0.65 * detail) * (1.0 + (one_blade - 0.5) * blade_contrast * detail);
				colour *= 1.0 - (1.0 - thatch_shade) * is_lying * long_grass;
				tint = mix(colour, seed_head * (0.8 + 0.4 * h.y), 0.8 * head * seeded);
				// Sun through a blade lifts it off the ground's colour, so it fades with the detail,
				// and before the tuft's reach, so tufts shrinking away don't glow.
				backlight = translucency * detail * (1.0 - smoothstep(0.4 * reach, 0.7 * reach, dist));
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
	BACKLIGHT = tint * backlight;
}
