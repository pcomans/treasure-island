shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Public-only painted cement stucco for Building 1's crescent, wings and
// pavilions. Existing CC0 Poly Haven plaster_grey_04 channels supply fine
// aggregate, pores and roughness breakup. Paint colour, physical span and the
// very low-contrast broad coating drift are reversible production inference;
// no shadow, dirt pattern or facade feature is baked into the surface.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.845, 0.8, 0.665, 1.0);
uniform float tile_span_m = 2.6;
uniform float relief_strength = 0.12;
uniform float grain_variation = 0.2;
uniform float broad_variation = 0.1;
uniform float roughness_base = 0.84;
uniform float roughness_variation = 0.12;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 n = normalize(world_normal);
	// Face-aligned world-metre projection keeps one continuous phase across the
	// exact runs and applied modules, independent of their box UVs. V runs
	// downward so the OpenGL normal map's +Y stays world-up on walls.
	vec3 reference_axis = abs(n.y) > 0.8 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 uv = vec2(dot(world_position, t), -dot(world_position, b)) / tile_span_m;
	float grain = dot(texture(surface_color, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	// Broad drift reads a heavily filtered, rotated copy over tens of metres.
	vec2 broad_uv = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.083 + vec2(0.37, 0.61);
	float broad = dot(textureLod(surface_color, broad_uv, 7.0).rgb, vec3(0.2126, 0.7152, 0.0722));
	float variation = 1.0 + (grain - 0.27) * grain_variation + (broad - 0.27) * broad_variation * 6.0;
	ALBEDO = paint_color.rgb * clamp(variation, 0.86, 1.1);
	ROUGHNESS = clamp(roughness_base + (texture(surface_roughness, uv).r - 0.5) * roughness_variation, 0.45, 0.97);
	METALLIC = 0.0;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	vec3 perturbed = normalize(n + (t * detail.x + b * detail.y) * relief_strength);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
