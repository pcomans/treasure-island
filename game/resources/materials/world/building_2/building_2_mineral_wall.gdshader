shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Target-only coating variant. Existing approved maps, aligned metre UVs
// supplied by Building2HeroModel; fine relief is not a substrate survey.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 cream_color : source_color = vec4(0.82, 0.79, 0.69, 1.0);
uniform float tile_span_m = 1.5;
uniform float base_roughness = 0.84;
uniform float normal_strength = 0.16;
uniform float coating_coverage = 0.98;
uniform float grain_contrast = 0.08;
uniform float broad_contrast = 0.025;

void fragment() {
	vec2 uv = UV / tile_span_m;
	vec3 mapped_color = texture(surface_color, uv).rgb;
	float grain = dot(mapped_color, vec3(0.2126, 0.7152, 0.0722));
	float local_average = dot(textureLod(surface_color, uv, 4.0).rgb, vec3(0.2126, 0.7152, 0.0722));
	float broad_grain = dot(textureLod(surface_color, UV / 7.5, 5.0).rgb, vec3(0.2126, 0.7152, 0.0722));
	// Opaque mineral paint covers the substrate's color clouds. The existing
	// fine normal/roughness still describe its physical surface below paint.
	vec3 substrate = cream_color.rgb * clamp(mapped_color / 0.27, vec3(0.55), vec3(1.35));
	vec3 coated = mix(substrate, cream_color.rgb, coating_coverage);
	float fine_grain = clamp(grain - local_average, -0.15, 0.15);
	float quiet_variation = 1.0 + fine_grain * grain_contrast + clamp(broad_grain - 0.27, -0.15, 0.15) * broad_contrast;
	ALBEDO = coated * quiet_variation;
	ROUGHNESS = clamp(base_roughness + (texture(surface_roughness, uv).r - 0.5) * 0.12, 0.45, 0.96);
	METALLIC = 0.0;
	NORMAL_MAP = texture(surface_normal, uv).rgb;
	NORMAL_MAP_DEPTH = normal_strength;
}
