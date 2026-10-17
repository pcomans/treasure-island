shader_type spatial;
// Running-bond brick for garage-bank piers: modular courses (67 mm) and
// brick lengths (203 mm) in metres, measured along each vertical face.
uniform vec4 brick_color : source_color = vec4(0.55, 0.26, 0.2, 1.0);
uniform vec4 mortar_color : source_color = vec4(0.72, 0.7, 0.66, 1.0);
uniform float course_height = 0.067;
uniform float brick_length = 0.203;
uniform float joint = 0.009;
varying vec3 local_position;
varying vec3 local_normal;
float brick_hash(vec2 p) {
	return fract(sin(dot(p, vec2(41.3, 289.1))) * 43758.5453);
}
void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}
void fragment() {
	vec2 across = normalize(vec2(-local_normal.z, local_normal.x) + vec2(1e-5, 0.0));
	float u = dot(local_position.xz, across);
	float course = floor(local_position.y / course_height);
	float shifted = u / brick_length + 0.5 * mod(course, 2.0);
	vec2 cell = vec2(floor(shifted), course);
	float bed = fract(local_position.y / course_height) * course_height;
	float head = fract(shifted) * brick_length;
	float mortar = step(bed, joint) + step(head, joint);
	vec3 tone = brick_color.rgb * (0.88 + 0.24 * brick_hash(cell));
	ALBEDO = mix(tone, mortar_color.rgb, clamp(mortar, 0.0, 1.0));
	ROUGHNESS = 0.9;
}
