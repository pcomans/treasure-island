// The power lines' wires (game/scripts/world/street_furniture_builder.gd): each
// piece is a unit tube along +Z whose instance scales its ring to the wire's
// radius. Far away a wire would shrink below a pixel and break into dashes, so
// the ring grows to keep the wire min_pixels wide on screen at any distance,
// and fades by the share of that width the real wire would cover (no darker
// than min_alpha), as a thin line does against the sky. Unshaded: the faces of
// the four-sided tube would each catch the sun differently and glint in
// dashes along a sagging span; a wire reads as a plain dark line.
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque, unshaded;

uniform vec4 albedo : source_color = vec4(0.07, 0.07, 0.075, 1.0);
uniform float min_pixels = 1.9;
uniform float min_alpha = 0.3;
varying float coverage;

void vertex() {
	vec3 axis_world = (MODEL_MATRIX * vec4(0.0, 0.0, VERTEX.z, 1.0)).xyz;
	float radius = length((MODEL_MATRIX * vec4(1.0, 0.0, 0.0, 0.0)).xyz);
	vec3 camera = INV_VIEW_MATRIX[3].xyz;
	// The size of a pixel at the wire: perspective grows it with distance, an
	// orthographic camera keeps it.
	float pixel = 2.0 / (PROJECTION_MATRIX[1][1] * VIEWPORT_SIZE.y);
	if (PROJECTION_MATRIX[3][3] < 0.5) {
		pixel *= length(axis_world - camera);
	}
	float grow = max(1.0, 0.5 * min_pixels * pixel / max(radius, 1e-5));
	VERTEX.xy *= grow;
	coverage = 1.0 / grow;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ALPHA = mix(min_alpha, 1.0, clamp(coverage, 0.0, 1.0));
}
