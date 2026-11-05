// The power lines' wires (game/scripts/world/street_furniture_builder.gd): each
// piece is a unit tube along +Z whose MultiMesh instance scales its ring to the
// wire's radius, which the instance's custom data also carries (r). Far away a
// wire would shrink below a pixel and break into dashes, so each ring vertex
// moves out along its radial normal until the wire is min_pixels wide on
// screen, and the wire fades by the share of that width the real wire would
// cover (no fainter than min_alpha), as a thin line does against the sky.
// The growth is worked out in world space: Forward+ hands the vertex function a
// VERTEX already moved by the instance transform (MODEL_MATRIX the node's),
// Compatibility may hand it the unit tube (MODEL_MATRIX node and instance), and
// MODEL_MATRIX * VERTEX is the same world point either way. Unshaded: the tube's
// four faces would each catch the sun and glint in dashes along a sagging span.
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, unshaded;

uniform vec4 albedo : source_color = vec4(0.07, 0.07, 0.075, 1.0);
uniform float min_pixels = 1.9;
uniform float min_alpha = 0.3;
varying float coverage;

void vertex() {
	mat3 basis = mat3(MODEL_MATRIX);
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 radial = normalize(basis * NORMAL);
	float radius = max(INSTANCE_CUSTOM.r, 1e-5);
	vec3 camera = INV_VIEW_MATRIX[3].xyz;
	// The size of a pixel at the wire: perspective grows it with distance, an
	// orthographic camera keeps it.
	float pixel = 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
	if (PROJECTION_MATRIX[3][3] < 0.5) {
		pixel *= length(world - camera);
	}
	float grow = max(1.0, 0.5 * min_pixels * pixel / radius);
	VERTEX += inverse(basis) * (radial * radius * (grow - 1.0));
	coverage = 1.0 / grow;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = mix(min_alpha, 1.0, clamp(coverage, 0.0, 1.0));
}
