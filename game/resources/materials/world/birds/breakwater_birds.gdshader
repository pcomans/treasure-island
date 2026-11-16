// The resting birds on the ferry breakwater (game/scripts/world/breakwater_birds.gd):
// one material for every bird and pose, lit as everything else is (no emission).
// Plumage is vertex colour, authored in sRGB (converted here, so 8-bit vertex
// colours keep their dark tones); the vertex colour's alpha is how glossy a part
// is (0 feathers, 1 bill and legs). The MultiMeshes carry white instance colours:
// the Compatibility renderer multiplies COLOR by an instance colour whether or not
// the MultiMesh has any (black without), and white leaves it as it is.
// The colour is clamped to 0..1 before use: with MSAA the renderers take a pixel's
// varyings at its centre even when only one of its samples lies in a triangle, so
// on a far bird's sub-pixel triangle that runs from one colour to another (a
// bill's yellow into its red spot, an eye) the colour is extrapolated far past
// both, and the sRGB curve turned that into a pixel many times brighter than the
// scene's light allows (2026-11-16, both renderers, at noon, dusk and night).
// Each instance's custom data holds the bird's own tone (r) and its size (a),
// numbers near 1 that the Compatibility renderer's half-float custom data keeps
// closely enough; no positions, which it would round to a quarter metre out here.
// Legs and feet carry UV2 (1, height): from thin_start_m out they draw in to one
// point inside the body, that height (bird units) over the bird's feet, so a bird
// far off shows no sub-pixel legs that would sparkle as the camera moves; drawn
// in, their triangles have no area and are not drawn at all. Both renderers hand
// the vertex function the bird's own VERTEX, with MODEL_MATRIX the node's and the
// instance's together (Godot 4.7.2's Forward+ and Compatibility scene shaders put
// a MultiMesh instance's transform into MODEL_MATRIX before this code runs), so
// that point is (0, height, 0) and the bird's feet are MODEL_MATRIX's origin.
// Under an orthographic projection (a directional light's shadow pass, an
// orthographic camera) the legs stay, so they cast their shadows.
shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform float thin_start_m = 30.0;
uniform float thin_end_m = 40.0;
uniform float feather_roughness = 0.9;
uniform float gloss_roughness = 0.45;
uniform float feather_specular = 0.15;
uniform float gloss_specular = 0.4;

varying float tone;

vec3 srgb_to_linear(vec3 c) {
	return mix(pow((c + vec3(0.055)) / 1.055, vec3(2.4)), c / 12.92, lessThan(c, vec3(0.04045)));
}

void vertex() {
	tone = INSTANCE_CUSTOM.r;
	if (UV2.x > 0.5 && PROJECTION_MATRIX[3][3] < 0.5) {
		float hide = smoothstep(thin_start_m, thin_end_m, distance(CAMERA_POSITION_WORLD, MODEL_MATRIX[3].xyz));
		VERTEX = mix(VERTEX, vec3(0.0, UV2.y, 0.0), hide);
	}
}

void fragment() {
	vec4 paint = clamp(COLOR, vec4(0.0), vec4(1.0));
	ALBEDO = min(srgb_to_linear(paint.rgb) * tone, vec3(1.0));
	ROUGHNESS = mix(feather_roughness, gloss_roughness, paint.a);
	SPECULAR = mix(feather_specular, gloss_specular, paint.a);
}
