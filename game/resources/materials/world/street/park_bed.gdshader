shader_type spatial;
// The planted beds of a park zone (park_mulch records of
// tools/lib/street-ground-generation.mjs): shredded mulch near the camera,
// where the beds' plants stand on it, blending to the beds' planted colour
// further out, where the low plants have faded away (street_vegetation_kit.gd
// draws them to 40-70 m), so a planted bed seen from afar or from above does not
// read as bare mulch. The planted colour comes in drift-sized patches of deep
// green, grey-green and a few straw and copper accents, with a per-plant grain
// and a little mulch between, like the beds in cmg01 and the 2026 aerial.
// Colours are production inference from those photos and the kit's
// late-November plants.

uniform sampler2D mulch : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float uv_scale = 5.0;
uniform vec3 planted_green : source_color = vec3(0.2, 0.31, 0.12);
uniform vec3 planted_grey : source_color = vec3(0.33, 0.4, 0.27);
uniform vec3 planted_straw : source_color = vec3(0.46, 0.4, 0.24);
uniform float blend_start_m = 32.0;
uniform float blend_end_m = 58.0;
// Drift patches about this size (m), and the per-plant grain's size.
uniform float drift_m = 3.5;
uniform float plant_m = 0.55;

varying vec3 world_position;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 ground = texture(mulch, UV * uv_scale).rgb;
	float far = smoothstep(blend_start_m, blend_end_m, distance(world_position, CAMERA_POSITION_WORLD));
	vec2 p = world_position.xz;
	// Drift patches with hard-ish edges, a few straw accents, then each plant's
	// crown lighter on top and mulch showing in the darkest gaps.
	float patch = smoothstep(0.35, 0.65, noise(p / drift_m));
	vec3 planted = mix(planted_green, planted_grey, patch);
	planted = mix(planted, planted_straw, smoothstep(0.68, 0.8, noise(p / (drift_m * 1.7) + 31.0)) * 0.8);
	float grain = noise(p / plant_m + 7.0);
	planted *= 0.7 + 0.6 * grain;
	planted = mix(ground, planted, smoothstep(0.08, 0.3, grain));
	ALBEDO = mix(ground, planted, far);
	ROUGHNESS = 1.0;
}
