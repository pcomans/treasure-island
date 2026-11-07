shader_type spatial;
// The Bay Bridge's thin members (cables, suspenders, light masts, truss and bracing
// members; game/scripts/world/bay_bridge_builder.gd) as camera-facing strips. Each
// vertex holds a point of the member's centre line (VERTEX), its direction (NORMAL),
// which edge of the strip it is (UV.x, -1 or 1) and the member's true radius (UV.y).
// The strip is never narrower than MIN_PIXELS on screen; its opacity is the share of
// that width the member really covers, so a suspender far off fades to the faint line
// a photograph shows instead of breaking into dashes. Colours arrive as sRGB vertex
// colours. Lit like a cylinder across the strip.
render_mode skip_vertex_transform, cull_disabled, blend_mix, depth_draw_never, diffuse_lambert, specular_schlick_ggx;

const float MIN_PIXELS = 1.3;

uniform float roughness_value = 0.5;
uniform float specular_value = 0.4;

varying vec3 strip_side;
varying vec3 to_camera;
varying float across;
varying float coverage;

void vertex() {
	vec3 center = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 direction = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	bool orthographic = PROJECTION_MATRIX[3][3] > 0.5;
	to_camera = orthographic ? vec3(0.0, 0.0, 1.0) : normalize(-center);
	vec3 side = cross(direction, to_camera);
	float side_length = length(side);
	// Seen end-on the member has no screen direction: any side will do.
	side = side_length > 0.0001 ? side / side_length : normalize(cross(direction, vec3(0.0, 1.0, 0.0) + vec3(0.0001)));
	float depth = orthographic ? 1.0 : max(-center.z, 0.01);
	float pixel = 2.0 * depth / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
	float radius = UV.y;
	float half_width = max(radius, 0.5 * MIN_PIXELS * pixel);
	coverage = radius / half_width;
	across = UV.x;
	strip_side = side;
	VERTEX = center + side * UV.x * half_width;
	NORMAL = to_camera;
}

vec3 srgb_to_linear(vec3 color) {
	return mix(color / 12.92, pow((color + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
}

void fragment() {
	float a = clamp(across, -1.0, 1.0);
	NORMAL = normalize(to_camera * sqrt(max(1.0 - a * a, 0.0)) + strip_side * a);
	ALBEDO = srgb_to_linear(COLOR.rgb);
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
	ALPHA = clamp(coverage, 0.0, 1.0);
}
