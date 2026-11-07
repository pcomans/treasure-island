// What the ground draws, read from above for the grass (game/scripts/world/
// ground_dressing.gd). Compiled into ground_cover.gdshader only with
// GROUND_DRESSING_CAPTURE defined, so the capture runs the ground's own map,
// family and patch logic and can't drift from what is drawn.
//
// capture_surface off gives the ground's colour, which the grass takes on, mottled
// in patches a metre or so across that average back to that colour, so the grass
// differs from place to place and its end still can't show. On, it writes the ground's
// height (metres), how thickly tufts stand (0-1), and in blue how tall they grow
// (metres) or, negative on bare ground, how thickly stones lie: each family's and each
// map recipe's dressing, mixed by the same weights the ground uses for its colours.
//
// Nothing here is even. A warped noise a few metres across makes thin places, where the
// ground shows, and long ones; another tens of metres across makes the drifts they
// lie in; and unmown grass gathers into clumps a metre or so across.

uniform bool capture_surface = false;
// Dressing, x how thickly tufts stand, y their height in metres and z how thickly
// stones lie on bare ground: the family's own, then the map's four recipes.
uniform vec3 dress_own = vec3(0.0);
uniform vec3 dress_lawn = vec3(0.0);
uniform vec3 dress_straw = vec3(0.0);
uniform vec3 dress_dry_field = vec3(0.0);
uniform vec3 dress_bare = vec3(0.0);
// A kerb verge is kept low whatever grows behind it.
uniform float dress_height_limit = 100.0;
// The colour of the lushest and the driest patches, as multiples of the ground's: on
// green ground, and on straw, which goes greyer and darker rather than more golden.
uniform vec3 patch_lush = vec3(0.66, 0.88, 0.9);
uniform vec3 patch_dry = vec3(1.34, 1.1, 1.1);
uniform vec3 straw_dark = vec3(0.62, 0.62, 0.64);
uniform vec3 straw_pale = vec3(1.34, 1.34, 1.42);
// How much of a lawn's cover its thin places lose, and how much longer its long ones grow.
uniform float lawn_thin = 0.2;
uniform float lawn_long = 0.4;

vec3 ground_dressing_capture(vec3 albedo, vec2 p, vec4 cover, float own, float y, float bare, float pool, float marsh_floor) {
	vec2 warp = vec2(value_noise(p / 6.1 + vec2(3.3, 61.7)), value_noise(p / 6.1 + vec2(47.1, 9.9))) - 0.5;
	vec2 q = p + 7.0 * warp;
	float drift = value_noise(q / 21.0 + vec2(13.1, 77.3));
	float patches = 0.55 * value_noise(q / 6.3 + vec2(83.9, 21.1)) + 0.3 * value_noise(q / 2.7 + vec2(5.7, 39.3)) + 0.15 * value_noise(q / 1.1 + vec2(71.3, 2.9));
	float clump = 0.62 * value_noise(p / 1.7 + vec2(11.7, 3.1)) + 0.38 * value_noise(p / 0.62 + vec2(2.3, 19.9));
	if (!capture_surface) {
		float tone = smoothstep(0.34, 0.66, 0.5 * patches + 0.32 * clump + 0.18 * drift);
		float straw = smoothstep(0.92, 1.12, albedo.r / max(albedo.g, 0.001));
		return albedo * mix(vec3(1.0), mix(mix(patch_lush, patch_dry, tone), mix(straw_dark, straw_pale, tone), straw), 1.0 - bare);
	}
	vec3 dress = dress_own * own + dress_lawn * cover.r + dress_straw * cover.g + dress_dry_field * cover.b + dress_bare * cover.a;
	float wild = smoothstep(0.1, 0.18, dress.y);
	float thin = smoothstep(0.5, 0.64, patches);
	float long_grass = smoothstep(0.44, 0.68, 0.55 * drift + 0.45 * (1.0 - patches));
	float lawn_thick = 1.0 - lawn_thin * thin;
	float lawn_tall = (0.78 + 0.48 * clump) * (1.0 + lawn_long * long_grass);
	float field_thick = (0.35 + 1.25 * smoothstep(0.3, 0.72, clump)) * (1.0 - 0.6 * thin);
	float field_tall = (0.3 + 1.4 * clump) * (0.55 + 0.9 * long_grass);
	float thick = min(1.0, dress.x * mix(lawn_thick, field_thick, wild));
	float tall = min(dress_height_limit, dress.y * mix(lawn_tall, field_tall, wild));
	float growing = (1.0 - bare) * (1.0 - pool) * (1.0 - clamp(marsh_floor, 0.0, 1.0));
	return vec3(y, thick * growing, mix(tall, -dress.z, step(0.5, bare)));
}
