shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Original homogeneous rolled/diffusing glass field, with role-specific bulk tint.
// UV is the producer's metre-scaled face tangent/bitangent coordinate. Architectural
// pane boundaries, frames and sash bands remain entirely in the native geometry.
// Opaque exterior approximation: no transmitted room, sky image or painted light.
uniform vec4 bulk_color : source_color = vec4(0.82, 0.835, 0.79, 1.0);
uniform float surface_roughness : hint_range(0.0, 1.0) = 0.46;
uniform float diffusion : hint_range(0.0, 1.0) = 1.0;

float filtered_wave(vec2 metres, vec2 direction, float frequency, float phase) {
	float cycles = dot(metres, direction) * frequency;
	float visibility = 1.0 - smoothstep(0.18, 0.48, fwidth(cycles));
	return sin(cycles * 6.2831853 + phase) * visibility;
}

void fragment() {
	// Weak, continuous bulk-density variation avoids randomly colored panes.
	// The three incommensurate scales are not a facade grid or a lighting pattern.
	float density = filtered_wave(UV, vec2(0.93, 0.37), 1.31, 0.7)
		* filtered_wave(UV, vec2(-0.24, 0.97), 2.17, 1.9);
	ALBEDO = bulk_color.rgb * (1.0 + density * 0.025 * diffusion);
	METALLIC = 0.0;
	SPECULAR = 0.5;
	ROUGHNESS = clamp(surface_roughness + density * 0.025 * diffusion, 0.12, 0.8);
	CLEARCOAT = 0.65;
	CLEARCOAT_ROUGHNESS = 0.28;

	// Submillimetre rolled relief affects reflected light only. Metre-based waves
	// fade before undersampling; they must not become a visible moire/grid.
	float roll = filtered_wave(UV, vec2(0.999, 0.045), 37.0, 0.6);
	float grain = filtered_wave(UV, vec2(0.18, 0.984), 83.0, 2.4);
	vec2 slope = vec2(roll * 0.045, grain * 0.028) * diffusion;
	NORMAL_MAP = vec3(0.5 + slope * 0.5, 1.0);
	NORMAL_MAP_DEPTH = 1.0;
}
