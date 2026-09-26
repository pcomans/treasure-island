shader_type spatial;
// 155 mm courses: inferred from the existing 1232/1241 construction.
uniform vec4 wall_color : source_color = vec4(0.27, 0.33, 0.34, 1.0);
// Optional dated wear, kept at zero for every previously shipped instance.
uniform float weathering_strength = 0.0;
uniform float weathering_base_y = 0.0;
varying vec3 local_position;
float wear_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}
float wear_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(wear_hash(cell), wear_hash(cell + vec2(1.0, 0.0)), f.x),
		mix(wear_hash(cell + vec2(0.0, 1.0)), wear_hash(cell + vec2(1.0, 1.0)), f.x), f.y);
}
void vertex() { local_position = VERTEX; }
void fragment() {
	float course = local_position.y / 0.155;
	float aa = max(fwidth(course), 0.025);
	float line = 1.0 - smoothstep(0.02, 0.02 + aa, fract(course));
	float subtle = sin(local_position.x * 1.73 + local_position.z * 2.19) * sin(local_position.y * 9.0) * 0.008;
	ALBEDO = wall_color.rgb * (1.0 - line * 0.085) + subtle;
	if (weathering_strength > 0.0) {
		float height = local_position.y - weathering_base_y;
		float along_wall = local_position.x * 0.73 + local_position.z * 0.91;
		float patch = wear_noise(vec2(along_wall * 1.4, height * 3.0));
		float fine = wear_noise(vec2(along_wall * 7.0, height * 13.0));
		float lower_edge = 1.0 - smoothstep(0.12, 0.5 + patch * 0.65, height);
		ALBEDO = mix(ALBEDO, vec3(0.19, 0.22, 0.15), weathering_strength * lower_edge * (0.22 + patch * 0.32 + fine * 0.2));
	}
	ROUGHNESS = 0.88;
}
