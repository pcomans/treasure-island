shader_type spatial;
uniform vec4 roof_color : source_color = vec4(0.52,0.54,0.52,1.0);
varying vec3 local_position;
void vertex() { local_position = VERTEX; }
void fragment() {
	float row = floor(local_position.x * 5.0);
	float cell = floor(local_position.z * 4.0 + mod(row, 2.0) * 0.5);
	float n = fract(sin(row * 12.9898 + cell * 78.233) * 43758.5453);
	ALBEDO = roof_color.rgb + (n - 0.5) * 0.045;
	ROUGHNESS = 0.94;
}
