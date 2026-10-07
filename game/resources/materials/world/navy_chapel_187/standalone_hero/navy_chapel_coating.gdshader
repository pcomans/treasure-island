shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Chapel-specific coating variant of the existing Building 3 world-space PBR
// treatment. Source texture colour is normalized, not multiplied into paint.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.82, 0.79, 0.69, 1.0);
uniform float tile_span_m = 1.5;
uniform float relief_strength = 0.08;
uniform float roughness_base = 0.85;
uniform float variation_strength = 0.03;
uniform float wear_strength = 0.01;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 reference_axis = abs(n.y) > 0.8 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 uv = vec2(dot(world_position, t), dot(world_position, b)) / tile_span_m;
	float field = dot(texture(surface_color, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	float normalized_field = clamp((field - 0.3) * 5.0, -1.0, 1.0);
	// Very faint coating wear below the observed nave eave. No rear modules,
	// architectural seam pattern, coarse grime or new substrate claim.
	float below_eave = 9.8 - world_position.y;
	float wear = smoothstep(0.0, 0.05, below_eave) * (1.0 - smoothstep(0.1, 0.45, below_eave));
	wear *= wear_strength * (0.5 + normalized_field * 0.5) * (1.0 - abs(n.y));
	ALBEDO = paint_color.rgb * (1.0 + normalized_field * variation_strength - wear);
	ROUGHNESS = clamp(roughness_base + (texture(surface_roughness, uv).r - 0.5) * 0.10, 0.4, 0.98);
	METALLIC = 0.0;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	NORMAL = normalize((VIEW_MATRIX * vec4(normalize(n + (t * detail.x + b * detail.y) * relief_strength), 0.0)).xyz);
}
