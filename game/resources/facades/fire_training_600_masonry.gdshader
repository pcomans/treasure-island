shader_type spatial;
render_mode diffuse_burley;

uniform vec4 wall_color : source_color = vec4(0.73, 0.70, 0.57, 1.0);
varying vec3 local_position;
varying vec3 local_normal;

float grain(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void vertex() {
	local_position = VERTEX;
	local_normal = NORMAL;
}

void fragment() {
	vec2 p = abs(local_normal.z) > 0.5 ? local_position.xy : local_position.zy;
	float row = floor(p.y / 0.21);
	vec2 cell = vec2(p.x / 0.43 + mod(row, 2.0) * 0.5, p.y / 0.21);
	vec2 edge = min(fract(cell), 1.0 - fract(cell));
	float joint = 1.0 - smoothstep(0.005, 0.035, min(edge.x, edge.y));
	float coarse = grain(floor(p * 54.0));
	float block = grain(floor(cell));
	ALBEDO = wall_color.rgb * (0.93 + block * 0.10 + coarse * 0.11 - joint * 0.13);
	ROUGHNESS = 0.92;
}
