shader_type spatial;
// The planted beds of a park zone (park_mulch records of
// tools/lib/street-ground-generation.mjs): shredded mulch near the camera,
// where the beds' plants stand on it, blending to the beds' planted colour
// further out, where the low plants have faded away (street_vegetation_kit.gd
// draws them to 40-70 m), so a planted bed seen from afar or from above does not
// read as bare mulch. The planted colour varies in soft patches like the drifts,
// a little mulch still showing. Colours are production inference from the
// park's dated photos and the kit's late-November plants.

uniform sampler2D mulch : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float uv_scale = 5.0;
uniform vec3 planted_green : source_color = vec3(0.36, 0.42, 0.25);
uniform vec3 planted_grey : source_color = vec3(0.47, 0.5, 0.42);
uniform vec3 planted_straw : source_color = vec3(0.55, 0.45, 0.3);
uniform float blend_start_m = 32.0;
uniform float blend_end_m = 58.0;
uniform float mulch_show = 0.2;

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
	vec3 planted = mix(planted_green, planted_grey, noise(p / 4.0));
	planted = mix(planted, planted_straw, smoothstep(0.6, 0.85, noise(p / 7.0 + 31.0)) * 0.7);
	planted *= 0.85 + 0.3 * noise(p / 1.3 + 7.0);
	planted = mix(planted, ground, mulch_show);
	ALBEDO = mix(ground, planted, far);
	ROUGHNESS = 1.0;
}
