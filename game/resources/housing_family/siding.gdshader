shader_type spatial;
// 155 mm courses: inferred from the existing 1232/1241 construction.
uniform vec4 wall_color : source_color = vec4(0.27, 0.33, 0.34, 1.0);
varying vec3 local_position;
void vertex() { local_position = VERTEX; }
void fragment() {
	float course = local_position.y / 0.155;
	float aa = max(fwidth(course), 0.025);
	float line = 1.0 - smoothstep(0.02, 0.02 + aa, fract(course));
	float subtle = sin(local_position.x * 1.73 + local_position.z * 2.19) * sin(local_position.y * 9.0) * 0.008;
	ALBEDO = wall_color.rgb * (1.0 - line * 0.085) + subtle;
	ROUGHNESS = 0.88;
}
