shader_type spatial;
render_mode blend_mix, depth_draw_never, diffuse_burley, specular_schlick_ggx;

// Exact existing LAND triangles; no vertex/depth offset or receiver change.
// Analytic footprint is production inference inside the verified clear LAND.
uniform sampler2D grass_diff : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_nor_gl : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D grass_rough : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D concrete_diff : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D concrete_nor_gl : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D concrete_rough : filter_linear_mipmap_anisotropic, repeat_enable;
varying vec3 world_position;
varying vec3 world_normal;

float inside_distance(vec2 p, vec4 r) {
	return min(min(p.x - r.x, r.z - p.x), min(p.y - r.y, r.w - p.y));
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec2 tangent = vec2(0.470600309, 0.882346502);
	vec2 outward = vec2(-tangent.y, tangent.x);
	vec2 delta = world_position.xz - vec2(232.5345388, 605.9624793);
	vec2 p = vec2(dot(delta, tangent), dot(delta, outward));
	float grass_edge = max(inside_distance(p, vec4(-28.0, 0.05, -3.2, 5.0)), inside_distance(p, vec4(3.2, 0.05, 28.0, 5.0)));
	float concrete_edge = max(inside_distance(p, vec4(-3.2, 0.05, 3.2, 5.0)), inside_distance(p, vec4(-2.9, -1.6, 2.9, 5.0)));
	// Coverage follows the whole footprint; grass/paving joins are not edges.
	float edge = max(inside_distance(p, vec4(-28.0, 0.05, 28.0, 5.0)), inside_distance(p, vec4(-2.9, -1.6, 2.9, 5.0)));
	if (edge <= 0.0) { discard; }
	ALPHA = clamp(edge / 0.025, 0.0, 1.0);
	vec2 uv = p / 2.0;
	bool paving = concrete_edge > grass_edge;
	// Preserve the existing photographic material's chroma and local contrast.
	// The second grass sample supplies broad material variation, not lighting.
	vec3 grass_color = texture(grass_diff, uv).rgb;
	vec3 broad_grass = textureLod(grass_diff, p / 8.0 + vec2(0.31, 0.57), 4.0).rgb;
	float broad_value = dot(broad_grass, vec3(0.2126, 0.7152, 0.0722));
	float dry_fraction = clamp((broad_value - 0.065) * 5.0, 0.0, 0.65);
	vec3 turf_tint = mix(vec3(1.15, 1.65, 0.85), vec3(1.55, 1.55, 0.95), dry_fraction);
	vec3 turf = grass_color * turf_tint * clamp(0.65 + broad_value * 3.0, 0.8, 1.2);
	vec3 mineral = texture(concrete_diff, uv).rgb * vec3(1.15, 1.12, 1.06);
	// The existing 0.3 m transition and recessed threshold share the paving
	// family with a lighter mineral finish; these are not new geometry/joints.
	bool mineral_edge = abs(p.x) > 2.9 && p.y >= 0.05;
	bool threshold = p.y < 0.0;
	if (mineral_edge || threshold) {
		float mineral_value = dot(mineral, vec3(0.2126, 0.7152, 0.0722));
		mineral = mix(mineral, vec3(mineral_value), 0.25) * 1.18;
	}
	ALBEDO = clamp(paving ? mineral : turf, vec3(0.0), vec3(0.85));
	float mapped_roughness = paving ? texture(concrete_rough, uv).r : texture(grass_rough, uv).r;
	ROUGHNESS = paving ? clamp(mapped_roughness, 0.65, 0.95) : clamp(mapped_roughness, 0.82, 1.0);
	METALLIC = 0.0;
	AO = 1.0;
	vec3 n = normalize(world_normal);
	vec3 axis = vec3(tangent.x, 0.0, tangent.y);
	vec3 t = normalize(axis - n * dot(axis, n));
	// Positive GL Y follows this bitangent; image-V/outward has opposite sign.
	// This is the same orientation as the former positive projector basis.
	vec3 b = normalize(cross(n, t));
	vec2 xy = (paving ? texture(concrete_nor_gl, uv).rg : texture(grass_nor_gl, uv).rg) * 2.0 - 1.0;
	xy /= max(1.0, length(xy));
	xy *= paving ? 0.25 : 0.35;
	vec3 perturbed = normalize(t * xy.x + b * xy.y + n * sqrt(max(0.0, 1.0 - dot(xy, xy))));
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
