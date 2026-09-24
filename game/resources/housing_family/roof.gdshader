shader_type spatial;
varying vec3 local_position;
void vertex() { local_position = VERTEX; }
void fragment() {
	float row = floor(local_position.x * 5.0);
	float cell = floor(local_position.z * 4.0 + mod(row, 2.0) * 0.5);
	float n = fract(sin(row * 12.9898 + cell * 78.233) * 43758.5453);
	ALBEDO = vec3(0.23, 0.25, 0.23) + (n - 0.5) * 0.075;
	ROUGHNESS = 0.94;
}
