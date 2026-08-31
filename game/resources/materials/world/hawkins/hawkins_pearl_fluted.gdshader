shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec4 base_color : source_color = vec4(0.86, 0.865, 0.85, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.55;
uniform float flute_pitch_m : hint_range(0.04, 0.08) = 0.064;
uniform float flute_normal_strength : hint_range(0.0, 0.3) = 0.18;
uniform float filter_start_cycles_per_pixel : hint_range(0.01, 0.5) = 0.12;
uniform float filter_end_cycles_per_pixel : hint_range(0.01, 0.5) = 0.28;

varying float facade_u_m;

void vertex() {
	vec3 facade_tangent = normalize(vec3(NORMAL.z, 0.0, -NORMAL.x));
	facade_u_m = dot(VERTEX, facade_tangent);
}

void fragment() {
	float phase_cycles = facade_u_m / flute_pitch_m;
	float cycles_per_pixel = max(fwidth(phase_cycles), 0.00001);
	float filter_weight = 1.0 - smoothstep(
		filter_start_cycles_per_pixel,
		filter_end_cycles_per_pixel,
		cycles_per_pixel
	);
	float tangent_slope = sin(phase_cycles * TAU) * flute_normal_strength * filter_weight;

	ALBEDO = base_color.rgb;
	METALLIC = 0.0;
	ROUGHNESS = roughness_value;
	NORMAL_MAP = vec3(0.5 + tangent_slope * 0.5, 0.5, 1.0);
	NORMAL_MAP_DEPTH = 1.0;
}
