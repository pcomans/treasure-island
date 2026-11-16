// Wood-chip mulch on a bed's flat ground (game/scripts/world/mulch_ground.gd): the
// shared chip tile (tools/bake_mulch_chips.mjs: colour in RGB, the pile's height in
// alpha) laid twice in world metres, the second copy turned and larger, and the two
// mixed chip by chip by their heights, so the tile's repeat doesn't show and chips of
// both sizes lie on each other. The height's slope bends the normal, so chips catch
// the sun and their edges shade with it (nothing about the light is painted in). Over
// metres the bed varies a little: fresher, browner patches and a soft mottle. Each
// material grades the chips: a tint, how much of their colour shows, and how damp
// they are.

uniform sampler2D mulch_chips : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
// The tile's width on the ground, metres (MulchGround.TILE_M).
uniform float chip_tile_m = 1.25;
// The grade: a linear multiplier, the share of the chips' own colour kept (0 grey),
// and how damp the bed is (darker, a little glossier).
uniform vec3 mulch_tint = vec3(1.0);
uniform float mulch_saturation = 1.0;
uniform float mulch_damp = 0.0;
// The pile's relief, metres from its gaps to its highest chips.
uniform float mulch_relief_m = 0.008;
// Fresher mulch in patches a few metres across: its colour as a multiple of the rest,
// and how much of it shows.
uniform vec3 mulch_fresh = vec3(0.86, 0.8, 0.74);
uniform float mulch_fresh_share = 0.35;
// The soft mottle over a metre or two, as a share of the tone either way.
uniform float mulch_mottle = 0.12;

float mulch_hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float mulch_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(mulch_hash(cell), mulch_hash(cell + vec2(1.0, 0.0)), u.x), mix(mulch_hash(cell + vec2(0.0, 1.0)), mulch_hash(cell + vec2(1.0, 1.0)), u.x), u.y);
}

// One copy of the tile at world point p (metres), turned by angle and scaled: its
// colour, height and the height's slope per metre along world x and z. foot_m is the
// pixel's footprint on the ground, so the slope is taken at the scale the texture is
// read at and never aliases.
void mulch_layer(vec2 p, float angle, float scale, vec2 offset, float foot_m, out vec3 colour, out float height, out vec2 slope) {
	float c = cos(angle);
	float s = sin(angle);
	vec2 turned = vec2(c * p.x - s * p.y, s * p.x + c * p.y);
	float tile = chip_tile_m * scale;
	vec2 uv = turned / tile + offset;
	vec4 here = texture(mulch_chips, uv);
	float step_uv = max(foot_m / tile, 1.0 / 1024.0);
	float east = texture(mulch_chips, uv + vec2(step_uv, 0.0)).a;
	float south = texture(mulch_chips, uv + vec2(0.0, step_uv)).a;
	vec2 turned_slope = vec2(east - here.a, south - here.a) / (step_uv * tile);
	// Back from the turned frame to the world's.
	slope = vec2(c * turned_slope.x + s * turned_slope.y, -s * turned_slope.x + c * turned_slope.y);
	colour = here.rgb;
	height = here.a;
}

// The mulch at world point p: colour (linear), height (0 gaps to 1 the highest chips),
// slope per metre and roughness.
void mulch_sample(vec2 p, float foot_m, out vec3 albedo, out float height, out vec2 slope, out float roughness) {
	vec3 colour_a;
	vec3 colour_b;
	float height_a;
	float height_b;
	vec2 slope_a;
	vec2 slope_b;
	mulch_layer(p, 0.0, 1.0, vec2(0.0), foot_m, colour_a, height_a, slope_a);
	mulch_layer(p, 0.83, 1.37, vec2(0.37, 0.71), foot_m, colour_b, height_b, slope_b);
	// Which copy lies on top wanders over a couple of metres; where they meet, the
	// higher chips of either show.
	float lean = smoothstep(0.2, 0.8, mulch_noise(p / 2.3 + vec2(17.3, 4.1)));
	float top_a = height_a + 0.7 * (1.0 - lean);
	float top_b = height_b + 0.7 * lean;
	float top = max(top_a, top_b) - 0.12;
	float weight_a = max(top_a - top, 0.0);
	float weight_b = max(top_b - top, 0.0);
	float total = weight_a + weight_b;
	vec3 colour = (colour_a * weight_a + colour_b * weight_b) / total;
	height = (height_a * weight_a + height_b * weight_b) / total;
	slope = (slope_a * weight_a + slope_b * weight_b) / total;
	// The grade.
	float grey = dot(colour, vec3(0.2126, 0.7152, 0.0722));
	colour = mix(vec3(grey), colour, mulch_saturation) * mulch_tint;
	// Fresher patches and a soft mottle.
	float patches = 0.65 * mulch_noise(p / 6.7 + vec2(5.3, 1.7)) + 0.35 * mulch_noise(p / 2.1 + vec2(2.1, 9.4));
	float fresh = smoothstep(0.5, 0.68, patches) * mulch_fresh_share;
	colour *= mix(vec3(1.0), mulch_fresh, fresh);
	float mottle = 0.6 * mulch_noise(p / 1.4 + vec2(31.7, 7.9)) + 0.4 * mulch_noise(p / 0.55 + vec2(3.1, 27.3));
	colour *= 1.0 + mulch_mottle * (2.0 * mottle - 1.0);
	colour *= mix(1.0, 0.6, mulch_damp);
	albedo = colour;
	roughness = mix(0.97, 0.86, smoothstep(0.25, 0.7, height)) - 0.18 * mulch_damp;
}

// A world normal bent by the mulch's slope from the surface's own.
vec3 mulch_normal(vec3 surface_normal, vec2 slope) {
	vec2 rise = slope * mulch_relief_m;
	return normalize(surface_normal + vec3(-rise.x, 0.0, -rise.y));
}
