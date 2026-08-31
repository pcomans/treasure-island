shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec4 base_color : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.62, 0.62, 0.62, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.8;
uniform int field_kind : hint_range(0, 5) = 0;
uniform float primary_scale_m : hint_range(0.04, 3.0) = 0.75;
uniform float secondary_scale_m : hint_range(0.04, 1.0) = 0.24;
uniform float relief_strength : hint_range(0.0, 0.3) = 0.04;
uniform float color_variation : hint_range(0.0, 0.16) = 0.025;
uniform float filter_start_cycles_per_pixel : hint_range(0.01, 0.5) = 0.12;
uniform float filter_end_cycles_per_pixel : hint_range(0.01, 0.75) = 0.34;

varying vec2 field_position_m;

float hash21(vec2 value) {
	vec3 p3 = fract(vec3(value.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 position) {
	vec2 cell = floor(position);
	vec2 local = fract(position);
	vec2 blend = local * local * (3.0 - 2.0 * local);
	float bottom = mix(hash21(cell), hash21(cell + vec2(1.0, 0.0)), blend.x);
	float top = mix(hash21(cell + vec2(0.0, 1.0)), hash21(cell + vec2(1.0, 1.0)), blend.x);
	return mix(bottom, top, blend.y) * 2.0 - 1.0;
}

float filtered_noise(vec2 position_m, float scale_m, mat2 orientation) {
	vec2 phase_cycles = orientation * position_m / max(scale_m, 0.04);
	vec2 cycles_per_pixel = abs(fwidth(phase_cycles));
	float sample_rate = max(cycles_per_pixel.x, cycles_per_pixel.y);
	float weight = 1.0 - smoothstep(filter_start_cycles_per_pixel, filter_end_cycles_per_pixel, sample_rate);
	return value_noise(phase_cycles) * weight;
}

float aperiodic_field(vec2 position_m) {
	mat2 rotate_a = mat2(vec2(0.938, 0.346), vec2(-0.346, 0.938));
	mat2 rotate_b = mat2(vec2(0.574, -0.819), vec2(0.819, 0.574));
	mat2 rotate_c = mat2(vec2(-0.259, 0.966), vec2(-0.966, -0.259));
	float middle_scale_m = sqrt(max(primary_scale_m * secondary_scale_m, 0.0016));
	float coarse = filtered_noise(position_m + vec2(17.3, -9.1), primary_scale_m, rotate_a);
	float middle = filtered_noise(position_m + vec2(-4.7, 12.9), middle_scale_m, rotate_b);
	float fine = filtered_noise(position_m + vec2(8.2, 3.6), secondary_scale_m, rotate_c);
	if (field_kind == 5) {
		return coarse * 0.18 + middle * 0.29 + fine * 0.53;
	}
	return coarse * 0.54 + middle * 0.31 + fine * 0.15;
}

void vertex() {
	vec2 horizontal_normal = normalize(NORMAL.xz);
	vec2 wall_tangent = vec2(horizontal_normal.y, -horizontal_normal.x);
	field_position_m = vec2(dot(VERTEX.xz, wall_tangent), VERTEX.y);
}

void fragment() {
	float variation = aperiodic_field(field_position_m);
	float mix_amplitude = field_kind == 5 ? 0.40 : 0.18;
	float color_mix = clamp(0.5 + variation * mix_amplitude, 0.0, 1.0);
	vec3 color = mix(base_color.rgb, secondary_color.rgb, color_mix);
	color *= 1.0 + variation * color_variation * (field_kind == 5 ? 0.75 : 0.35);
	vec2 tangent_slope = vec2(0.0);
	if (relief_strength > 0.0) {
		float epsilon_m = max(secondary_scale_m * 0.08, 0.006);
		float slope_x = aperiodic_field(field_position_m + vec2(epsilon_m, 0.0)) - aperiodic_field(field_position_m - vec2(epsilon_m, 0.0));
		float slope_y = aperiodic_field(field_position_m + vec2(0.0, epsilon_m)) - aperiodic_field(field_position_m - vec2(0.0, epsilon_m));
		tangent_slope = vec2(slope_x, slope_y) * relief_strength * 0.22 / epsilon_m;
	}
	ALBEDO = color;
	METALLIC = 0.0;
	ROUGHNESS = clamp(roughness_value + variation * (field_kind == 5 ? 0.018 : 0.006), 0.0, 1.0);
	NORMAL_MAP = vec3(0.5 + tangent_slope.x * 0.5, 0.5 + tangent_slope.y * 0.5, 1.0);
	NORMAL_MAP_DEPTH = 1.0;
}
