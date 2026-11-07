shader_type spatial;
// The worked yard surfaces in the ground dressing's surface capture
// (game/scripts/world/ground_dressing.gd), which carry no ground-cover family:
// the same channels as ground_dressing_capture.gdshaderinc, the ground's height,
// how thickly tufts stand and how tall they grow or, negative, how thickly stones lie.
// Dry tufts come up in scattered patches and stones lie everywhere else; on rubble
// (z over 1) what is over 1 lies in piles, and the capture's blue stays past -1 to say so.
render_mode unshaded, depth_draw_opaque, cull_back;

// x how thickly tufts stand in their patches, y their height, z how thickly stones lie.
uniform vec3 dress = vec3(0.0);
// The share of the surface the tufts' patches cover.
uniform float tuft_share = 0.25;

varying vec3 world;

void vertex() {
	world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash12(cell), hash12(cell + vec2(1.0, 0.0)), u.x), mix(hash12(cell + vec2(0.0, 1.0)), hash12(cell + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	float patches = 0.6 * value_noise(world.xz / 4.3 + vec2(7.1, 31.9)) + 0.4 * value_noise(world.xz / 1.1 + vec2(23.3, 5.7));
	float tufts = smoothstep(0.62 - 0.3 * tuft_share, 0.68 - 0.3 * tuft_share, 1.0 - patches);
	float piles = smoothstep(0.42, 0.6, 0.65 * value_noise(world.xz / 3.3 + vec2(41.3, 13.7)) + 0.35 * value_noise(world.xz / 1.2 + vec2(3.9, 57.1)));
	float stones = dress.z > 1.0 ? 1.0 + (dress.z - 1.0) * (0.06 + 0.94 * piles) : dress.z;
	ALBEDO = vec3(world.y, dress.x * tufts, mix(-stones, dress.y, step(0.5, tufts)));
}
