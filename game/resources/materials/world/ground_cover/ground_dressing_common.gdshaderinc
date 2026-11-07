// What the grass and the stones share (game/scripts/world/ground_dressing.gd): the
// ground captures, where a tile's points stand, and how they thin with distance.

// Surface capture: height, tuft thickness, tuft height (stones where negative), alpha
// open ground.
uniform sampler2D ground_surface : filter_linear, repeat_disable;
// Colour capture: the ground's albedo, alpha where there is ground.
uniform sampler2D ground_colour : filter_linear, repeat_disable;
// The window both captures cover: its corner in world x, z and one over its size.
uniform vec3 ground_window = vec3(-128.0, -128.0, 0.00390625);

// Tile size and points per tile at full density.
uniform float tile_m = 4.0;
uniform float tile_points = 2560.0;
// Full density stands out to this distance; past it density falls as distance squared.
uniform float full_density_m = 6.0;
// A little over 1, so the last points in rank reach full size before they thin.
uniform float share_margin = 1.15;
uniform float ring_end_m = 104.0;
// The ground's typical height, for distances the CPU can match without the capture.
uniform float ground_y_m = 4.0;

vec3 hash32(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yxz + 33.33);
	return fract((p3.xxy + p3.yzz) * p3.zyx);
}

float ground_distance(vec2 place, vec3 camera) {
	return length(vec3(place.x - camera.x, ground_y_m - camera.y, place.y - camera.z));
}

// The first share of a tile's points stands at a distance (share_at() on the CPU).
float standing_share(float dist) {
	float ratio = full_density_m / max(dist, full_density_m);
	return share_margin * ratio * ratio;
}

// A point of rank rank moves up to about its spacing, so the tile's pattern never shows.
vec2 jittered(vec2 place, vec2 random, float rank) {
	return place + (random - 0.5) * (1.3 * tile_m) * inversesqrt(rank * tile_points + 1.0);
}

vec2 ground_uv(vec2 place) {
	return (place - ground_window.xy) * ground_window.z;
}

// 1 inside the captured window, 0 outside it.
float in_window(vec2 uv) {
	return step(0.002, min(uv.x, uv.y)) * step(max(uv.x, uv.y), 0.998);
}

// The ground's colour from its capture.
vec3 ground_tone(vec2 uv) {
	vec4 ground = textureLod(ground_colour, uv, 0.0);
	return ground.rgb / max(ground.a, 0.02);
}
