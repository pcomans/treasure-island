// The resting birds on the ferry breakwater (game/scripts/world/breakwater_birds.gd):
// one material for every bird and pose, lit as everything else is (no emission).
// Plumage is vertex colour, authored in sRGB (converted here, so 8-bit vertex
// colours keep their dark tones); the vertex colour's alpha is how glossy a part
// is (0 feathers, 1 bill and legs). The MultiMeshes carry white instance colours:
// the Compatibility renderer multiplies COLOR by an instance colour whether or not
// the MultiMesh has any (black without), and white leaves it as it is.
// Each instance's custom data holds the bird's own tone (r) and its size (a),
// numbers near 1 that the Compatibility renderer's half-float custom data keeps
// closely enough; no positions, which it would round to a quarter metre out here.
// Legs and feet carry UV2 (1, rise): from thin_start_m out they slide straight up
// by rise (bird units) to a height inside the body, so a bird far off shows no
// sub-pixel legs that would sparkle as the camera moves. The move is worked out
// in world space from the vertex's own world position and turned back through
// MODEL_MATRIX, which is right whether the renderer hands the vertex function
// the bird's own VERTEX with a MODEL_MATRIX that includes its instance, or a
// VERTEX already moved by the instance with the node's MODEL_MATRIX (see
// street_wire.gdshader): MODEL_MATRIX * VERTEX is the same world point either
// way, and a turn about +Y leaves "up" as it is. Under an orthographic
// projection (a directional light's shadow pass, an orthographic camera) the
// legs stay, so they cast their shadows.
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
		vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		float hide = smoothstep(thin_start_m, thin_end_m, distance(CAMERA_POSITION_WORLD, world));
		VERTEX += inverse(mat3(MODEL_MATRIX)) * vec3(0.0, UV2.y * INSTANCE_CUSTOM.a * hide, 0.0);
	}
}

void fragment() {
	ALBEDO = srgb_to_linear(COLOR.rgb) * tone;
	ROUGHNESS = mix(feather_roughness, gloss_roughness, COLOR.a);
	SPECULAR = mix(feather_specular, gloss_specular, COLOR.a);
}
