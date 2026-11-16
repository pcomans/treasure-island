// The resting birds on the ferry breakwater (game/scripts/world/breakwater_birds.gd):
// one material for every bird and pose. Plumage is vertex colour, authored in
// sRGB (converted here, so 8-bit vertex colours keep their dark tones); the
// vertex colour's alpha is how glossy a part is (0 feathers, 1 bill and legs).
// Each MultiMesh instance's custom data holds its world position (xyz) and its
// scale (w): a bird's distance and its own small tone come from those, the same
// in Forward+ and Compatibility (Forward+ hands the vertex function a VERTEX
// already moved by the instance, Compatibility the bird's own; MODEL_MATRIX *
// VERTEX is the same world point either way, as in street_wire.gdshader).
// Legs and feet carry UV2 (1, height): past thin_start_m they draw in to one
// point inside the body, that height (bird units) over the bird's feet, so a
// bird far off shows no sub-pixel legs that would sparkle as the camera moves;
// drawn in, their triangles have no area and are not drawn at all.
shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform float thin_start_m = 30.0;
uniform float thin_end_m = 40.0;
// How far one bird's plumage may sit lighter or darker than another's.
uniform float tone_spread = 0.06;
uniform float feather_roughness = 0.86;
uniform float gloss_roughness = 0.45;

varying float tone;

vec3 srgb_to_linear(vec3 c) {
	return mix(pow((c + vec3(0.055)) / 1.055, vec3(2.4)), c / 12.92, lessThan(c, vec3(0.04045)));
}

void vertex() {
	vec3 origin = INSTANCE_CUSTOM.xyz;
	float scale = max(INSTANCE_CUSTOM.w, 1e-3);
	float noise = fract(sin(dot(origin.xz, vec2(12.9898, 78.233))) * 43758.5453);
	tone = 1.0 + tone_spread * (noise * 2.0 - 1.0);
	if (UV2.x > 0.5) {
		float hide = smoothstep(thin_start_m, thin_end_m, distance(CAMERA_POSITION_WORLD, origin));
		vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		vec3 inside = origin + vec3(0.0, UV2.y * scale, 0.0);
		VERTEX += inverse(mat3(MODEL_MATRIX)) * ((inside - world) * hide);
	}
}

void fragment() {
	ALBEDO = srgb_to_linear(COLOR.rgb) * tone;
	ROUGHNESS = mix(feather_roughness, gloss_roughness, COLOR.a);
	SPECULAR = 0.3;
}
