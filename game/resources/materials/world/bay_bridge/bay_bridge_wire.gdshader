shader_type spatial;
// The Bay Bridge's thin members (cables, suspenders, light masts, truss and bracing
// members; game/scripts/world/bay_bridge_builder.gd) as camera-facing strips. Each
// vertex holds a point of the member's centre line (VERTEX), its direction (NORMAL),
// which edge of the strip it is (UV.x, -1 or 1) and the member's true radius (UV.y).
// The strip is never narrower than MIN_PIXELS on screen and fades out over its outer
// pixel on each side, so it never breaks into dashes as it crosses the pixel grid;
// its opacity keeps the ink the member really covers, so a suspender far off is the
// faint line a photograph shows. Colours arrive as sRGB vertex colours. Lit like a
// cylinder across the strip.
// The vertex colour's alpha marks a bright strand (1, else 0; game/scripts/world/
// bay_bridge_builder.gd's BRIGHT_STRAND_ROLES): the self-anchored span's white main
// cable and suspenders, which the dated photographs show as a dense fan of lines
// brighter than the sky. A bright strand takes STRAND_PRESENCE times the ink its true
// width would give (until it is a full line), and while it is only a few pixels wide
// its side away from the sun takes the sun as backlight, as a thin strand lit all
// round reads at that size. Both are production inference for gameplay distance; up
// close the strand keeps its true width and its shading as a cylinder.
render_mode skip_vertex_transform, cull_disabled, blend_mix, depth_draw_never, diffuse_lambert, specular_schlick_ggx;

const float MIN_PIXELS = 2.0;
const float STRAND_PRESENCE = 2.0;

uniform float roughness_value = 0.5;
uniform float specular_value = 0.4;

varying vec3 strip_side;
varying vec3 to_camera;

// One screen pixel's size in metres at view-space depth `depth`. The projection's
// [1][1] is negative where the renderer flips Y (Forward+'s RenderingDevice), so
// take its size.
float pixel_size(float depth, mat4 projection, vec2 viewport) {
	bool orthographic = projection[3][3] > 0.5;
	return 2.0 * (orthographic ? 1.0 : max(depth, 0.01)) / (abs(projection[1][1]) * viewport.y);
}

void vertex() {
	vec3 center = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 direction = normalize((MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz);
	bool orthographic = PROJECTION_MATRIX[3][3] > 0.5;
	to_camera = orthographic ? vec3(0.0, 0.0, 1.0) : normalize(-center);
	vec3 side = cross(direction, to_camera);
	float side_length = length(side);
	// Seen end-on the member has no screen direction: any side will do.
	side = side_length > 0.0001 ? side / side_length : normalize(cross(direction, vec3(0.0, 1.0, 0.0) + vec3(0.0001)));
	float half_width = max(UV.y, 0.5 * MIN_PIXELS * pixel_size(-center.z, PROJECTION_MATRIX, VIEWPORT_SIZE));
	strip_side = side;
	VERTEX = center + side * UV.x * half_width;
	NORMAL = to_camera;
}

vec3 srgb_to_linear(vec3 color) {
	return mix(color / 12.92, pow((color + 0.055) / 1.055, vec3(2.4)), step(vec3(0.04045), color));
}

void fragment() {
	// The strip's own across position and the member's radius come in the built-in UV,
	// its width in pixels from this fragment's depth.
	float a = clamp(UV.x, -1.0, 1.0);
	float strand = COLOR.a;
	float pixel = pixel_size(-VERTEX.z, PROJECTION_MATRIX, VIEWPORT_SIZE);
	float half_pixels = max(UV.y / pixel, 0.5 * MIN_PIXELS);
	NORMAL = normalize(to_camera * sqrt(max(1.0 - a * a, 0.0)) + strip_side * a);
	ALBEDO = srgb_to_linear(COLOR.rgb);
	// Backlight while the strand is thin: in full up to MIN_PIXELS wide, gone by four times that.
	float thin = 1.0 - smoothstep(0.5 * MIN_PIXELS, 2.0 * MIN_PIXELS, UV.y / pixel);
	BACKLIGHT = vec3(strand * thin);
	ROUGHNESS = roughness_value;
	SPECULAR = specular_value;
	// Full inside, falling to nothing over the outer pixel: the strip then holds
	// about (2 * half_pixels - 1) pixels of ink, scaled to the member's own width.
	float edge = clamp((1.0 - abs(a)) * half_pixels, 0.0, 1.0);
	float ink = clamp(mix(1.0, STRAND_PRESENCE, strand) * 2.0 * UV.y / pixel / max(2.0 * half_pixels - 1.0, 1.0), 0.0, 1.0);
	ALPHA = edge * ink;
}
