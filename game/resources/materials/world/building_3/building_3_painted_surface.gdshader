shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Existing CC0 plaster channels supply fine coating variation, not a claim
// about substrate. Dimensions and bounded staining are production inference.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.78, 0.755, 0.675, 1.0);
uniform float tile_span_m = 1.5;
uniform float relief_strength = 0.13;
uniform float color_variation = 0.22;
uniform float coating_variation = 0.0;
uniform bool coating_all_faces = false;
uniform float roughness_base = 0.86;
uniform float stain_strength = 0.14;
uniform vec3 facade_origin;
uniform vec3 facade_tangent;
uniform vec3 facade_outward;
uniform float facade_length;
uniform float ledge_y = 14.45;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 n = normalize(world_normal);
	// Projection basis is orthonormal in world metres, including scaled
	// MultiMesh boxes. It does not depend on their unit-box UVs or tangents.
	vec3 reference_axis = abs(n.y) > 0.8 ? facade_tangent : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 uv = vec2(dot(world_position, t), dot(world_position, b)) / tile_span_m;
	vec3 field = texture(surface_color, uv).rgb;
	float grain = dot(field, vec3(0.2126, 0.7152, 0.0722));
	float broad = texture(surface_color, uv * 0.173 + vec2(0.31, 0.57)).r;
	float u = dot(world_position - facade_origin, facade_tangent);
	// Coating runoff varies along the facade rather than repeating on each
	// mesh/box. Narrow and broad existing-map samples interrupt the edge dirt.
	float patch = texture(surface_color, vec2(u / 5.3, 0.37)).r;
	float streak = texture(surface_color, vec2(u / 1.1, 0.73)).r;
	float coverage = smoothstep(0.17, 0.39, patch) * mix(0.3, 1.0, smoothstep(0.17, 0.43, streak));
	float runoff_length = mix(0.25, 0.9, smoothstep(0.18, 0.42, streak));
	float below_ledge = ledge_y - world_position.y;
	float ledge_mask = smoothstep(0.0, 0.055, below_ledge)
		* (1.0 - smoothstep(0.12, runoff_length, below_ledge));
	float cap_below = 24.2 - world_position.y;
	float pylon_mask = (1.0 - smoothstep(6.0, 7.5, min(u, facade_length - u)))
		* smoothstep(0.0, 0.07, cap_below)
		* (1.0 - smoothstep(0.2, runoff_length + 0.25, cap_below));
	// Only observed outward faces receive the bounded stain schedule.
	float face_mask = smoothstep(0.85, 0.98, dot(n, facade_outward));
	float stain = max(ledge_mask, pylon_mask) * face_mask * stain_strength * coverage;
	float variation = 1.0 + (grain - 0.30) * color_variation + (broad - 0.30) * color_variation * 0.45;
	// Broad coating variation is separate from dirt: soft, low-contrast
	// changes over several metres, with no added relief, seams or damage.
	vec2 coating_uv = vec2(u, world_position.y) / 12.0;
	float coat_a = textureLod(surface_color, coating_uv + vec2(0.19, 0.43), 5.0).r;
	float coat_b = textureLod(surface_color, coating_uv * 0.61 + vec2(0.67, 0.11), 5.0).r;
	float coating = clamp((coat_a * 0.65 + coat_b * 0.35 - 0.30) * 7.0, -1.0, 1.0);
	variation *= 1.0 + coating * coating_variation * (coating_all_faces ? 1.0 : face_mask);
	ALBEDO = paint_color.rgb * variation * (1.0 - stain);
	ROUGHNESS = clamp(roughness_base + (texture(surface_roughness, uv).r - 0.5) * 0.15 + stain * 0.2, 0.4, 0.98);
	METALLIC = 0.0;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	vec3 perturbed = normalize(n + (t * detail.x + b * detail.y) * relief_strength);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
