shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec4 base_color : source_color = vec4(0.72, 0.72, 0.70, 1.0);
uniform vec4 seam_color : source_color = vec4(0.60, 0.60, 0.58, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.76;
uniform float course_height_m : hint_range(0.08, 0.30) = 0.17;
uniform float relief_strength : hint_range(0.0, 0.15) = 0.04;
uniform float color_variation : hint_range(0.0, 0.10) = 0.02;
uniform float filter_start_cycles_per_pixel : hint_range(0.01, 0.5) = 0.12;
uniform float filter_end_cycles_per_pixel : hint_range(0.01, 0.75) = 0.34;

varying vec2 field_position_m;

float filtered_weight(float phase_cycles) {
	float cycles_per_pixel = max(fwidth(phase_cycles), 0.00001);
	return 1.0 - smoothstep(filter_start_cycles_per_pixel, filter_end_cycles_per_pixel, cycles_per_pixel);
}

float filtered_wave(float phase_cycles) {
	return sin(phase_cycles * TAU) * filtered_weight(phase_cycles);
}

float filtered_ridge(float phase_cycles, float half_width) {
	float local = abs(fract(phase_cycles + 0.5) - 0.5);
	float pixel_width = max(fwidth(phase_cycles), 0.00001);
	float ridge = 1.0 - smoothstep(half_width - pixel_width, half_width + pixel_width, local);
	return ridge * filtered_weight(phase_cycles);
}

void vertex() {
	field_position_m = VERTEX.xy;
}

void fragment() {
	float course_phase = field_position_m.y / max(course_height_m, 0.08);
	float seam = filtered_ridge(course_phase, 0.055);
	float board_profile = filtered_wave(course_phase);
	float broad_a = filtered_wave((field_position_m.x * 0.39 + field_position_m.y * 0.17) / max(course_height_m * 5.3, 0.08));
	float broad_b = filtered_wave((field_position_m.x * -0.21 + field_position_m.y * 0.43) / max(course_height_m * 9.1, 0.08));
	float broad = broad_a * 0.62 + broad_b * 0.38;
	vec3 color = mix(base_color.rgb, seam_color.rgb, seam * 0.78);
	color *= 1.0 + broad * color_variation;
	vec2 tangent_slope = vec2(0.0, board_profile * relief_strength * (1.0 - seam * 0.55));
	ALBEDO = color;
	METALLIC = 0.0;
	ROUGHNESS = clamp(roughness_value + seam * 0.045, 0.0, 1.0);
	NORMAL_MAP = vec3(0.5 + tangent_slope.x * 0.5, 0.5 + tangent_slope.y * 0.5, 1.0);
	NORMAL_MAP_DEPTH = 1.0;
}
