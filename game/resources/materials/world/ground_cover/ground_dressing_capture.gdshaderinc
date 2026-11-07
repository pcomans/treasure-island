// What the ground draws, read from above for the grass (game/scripts/world/
// ground_dressing.gd). Compiled into ground_cover.gdshader only with
// GROUND_DRESSING_CAPTURE defined, so the capture runs the ground's own map,
// family and patch logic and can't drift from what is drawn.
//
// capture_surface off keeps the ground's colour, which the grass takes on, so a
// blade matches the ground it stands on and the ring's end can't show. On, it
// writes the ground's height (metres), how thickly tufts stand (0-1), and in blue
// how tall they grow (metres) or, negative on bare ground, how thickly stones lie:
// each family's and each map recipe's dressing, mixed by the same weights the
// ground uses for its colours.

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

vec3 ground_dressing_capture(vec3 albedo, vec2 p, vec4 cover, float own, float y, float bare, float pool, float marsh_floor) {
	if (!capture_surface) {
		return albedo;
	}
	vec3 dress = dress_own * own + dress_lawn * cover.r + dress_straw * cover.g + dress_dry_field * cover.b + dress_bare * cover.a;
	// Unmown grass grows in loose clumps, thin and short between them; a mown lawn is
	// even, with only a slow change in height.
	float clump = 0.62 * value_noise(p / 1.7 + vec2(11.7, 3.1)) + 0.38 * value_noise(p / 0.62 + vec2(2.3, 19.9));
	float wave = value_noise(p / 3.1 + vec2(29.3, 41.7));
	float wild = smoothstep(0.1, 0.18, dress.y);
	float thick = min(1.0, dress.x * mix(1.0, 0.4 + 1.2 * smoothstep(0.3, 0.72, clump), wild));
	float tall = min(dress_height_limit, dress.y * mix(0.85 + 0.3 * wave, 0.45 + 1.1 * clump, wild));
	float growing = (1.0 - bare) * (1.0 - pool) * (1.0 - clamp(marsh_floor, 0.0, 1.0));
	return vec3(y, thick * growing, mix(tall, -dress.z, step(0.5, bare)));
}
