shader_type spatial;
render_mode depth_draw_opaque, cull_back;

uniform vec4 base_color : source_color = vec4(0.7, 0.7, 0.7, 1.0);
uniform vec4 secondary_color : source_color = vec4(0.62, 0.62, 0.62, 1.0);
uniform float roughness_value : hint_range(0.0, 1.0) = 0.8;
uniform int field_kind : hint_range(0, 5) = 0;
uniform float primary_scale_m : hint_range(0.04, 3.0) = 0.75;
uniform float secondary_scale_m : hint_range(0.04, 1.0) = 0.24;
uniform float relief_strength : hint_range(0.0, 0.3) = 0.08;
uniform float color_variation : hint_range(0.0, 0.16) = 0.035;
uniform float filter_start_cycles_per_pixel : hint_range(0.01, 0.5) = 0.12;
uniform float filter_end_cycles_per_pixel : hint_range(0.01, 0.75) = 0.34;

varying vec2 field_position_m;

float filtered_weight(float phase_cycles) {
	float cycles_per_pixel = max(fwidth(phase_cycles), 0.00001);
	return 1.0 - smoothstep(
		filter_start_cycles_per_pixel,
		filter_end_cycles_per_pixel,
		cycles_per_pixel
	);
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

float broad_variation(vec2 position_m) {
	float first = filtered_wave(position_m.x / max(primary_scale_m, 0.04));
	float second = filtered_wave((position_m.x * 0.43 + position_m.y * 0.91) / max(primary_scale_m * 0.61, 0.04));
	float third = filtered_wave((position_m.x * -0.68 + position_m.y * 0.37) / max(primary_scale_m * 0.29, 0.04));
	return first * 0.48 + second * 0.32 + third * 0.20;
}

void vertex() {
	field_position_m = VERTEX.xy;
}

void fragment() {
	vec3 color = base_color.rgb;
	float roughness = roughness_value;
	vec2 tangent_slope = vec2(0.0);

	if (field_kind == 0) {
		// Diffuse mineral variation without a facade-scale translation period.
		float variation = broad_variation(field_position_m);
		color = mix(base_color.rgb, secondary_color.rgb, variation * 0.5 + 0.5);
		color *= 1.0 + variation * color_variation;
		tangent_slope = vec2(filtered_wave(field_position_m.x / max(secondary_scale_m, 0.04)), filtered_wave(field_position_m.y / max(secondary_scale_m * 1.7, 0.04))) * relief_strength * 0.24;
	} else if (field_kind == 1) {
		// Full-unit thin masonry proof field. The alternating row offset is material-scale only.
		float row = floor(field_position_m.y / max(secondary_scale_m, 0.04));
		float horizontal_phase = field_position_m.y / max(secondary_scale_m, 0.04);
		float vertical_phase = field_position_m.x / max(primary_scale_m, 0.04) + mod(row, 2.0) * 0.5;
		float mortar_h = filtered_ridge(horizontal_phase, 0.075);
		float mortar_v = filtered_ridge(vertical_phase, 0.035);
		float mortar = max(mortar_h, mortar_v);
		float variation = broad_variation(field_position_m * 0.58);
		color = mix(base_color.rgb * (1.0 + variation * color_variation), secondary_color.rgb, mortar);
		roughness = clamp(roughness_value + mortar * 0.07, 0.0, 1.0);
		tangent_slope = vec2(filtered_wave(vertical_phase), filtered_wave(horizontal_phase)) * relief_strength * (1.0 - mortar * 0.55);
	} else if (field_kind == 2) {
		// Fine vertically oriented base texture; phase fades before it can alias.
		float phase = field_position_m.x / max(primary_scale_m, 0.04);
		float directional = filtered_wave(phase);
		float variation = broad_variation(field_position_m * 0.72);
		color = mix(base_color.rgb, secondary_color.rgb, directional * 0.08 + variation * 0.06 + 0.12);
		tangent_slope.x = directional * relief_strength;
	} else if (field_kind == 3) {
		// Fine rib proof field with analytic distance filtering.
		float phase = field_position_m.x / max(primary_scale_m, 0.04);
		float directional = filtered_wave(phase);
		color = mix(base_color.rgb, secondary_color.rgb, directional * color_variation + color_variation);
		tangent_slope.x = directional * relief_strength;
	} else if (field_kind == 4) {
		// Generic painted field: color/finish only, with no invented directional substrate.
		float variation = broad_variation(field_position_m * 0.38);
		color = mix(base_color.rgb, secondary_color.rgb, variation * 0.5 + 0.5);
		color *= 1.0 + variation * color_variation;
	} else {
		// Multiscale exposed-aggregate proof field; every octave is derivative-faded.
		float coarse = broad_variation(field_position_m);
		float medium = filtered_wave(field_position_m.x / max(secondary_scale_m, 0.04)) * filtered_wave(field_position_m.y / max(secondary_scale_m * 1.17, 0.04));
		float fine = filtered_wave((field_position_m.x * 0.71 + field_position_m.y * 0.53) / max(secondary_scale_m * 0.47, 0.04));
		float aggregate = coarse * 0.34 + medium * 0.43 + fine * 0.23;
		color = mix(base_color.rgb, secondary_color.rgb, aggregate * 0.5 + 0.5);
		tangent_slope = vec2(medium, fine) * relief_strength;
		roughness = clamp(roughness_value + aggregate * 0.025, 0.0, 1.0);
	}

	ALBEDO = color;
	METALLIC = 0.0;
	ROUGHNESS = roughness;
	NORMAL_MAP = vec3(0.5 + tangent_slope.x * 0.5, 0.5 + tangent_slope.y * 0.5, 1.0);
	NORMAL_MAP_DEPTH = 1.0;
}
