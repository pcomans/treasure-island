// The power lines' wires (game/scripts/world/street_furniture_builder.gd): each
// piece is a unit tube along +Z whose instance scales its ring to the wire's
// radius. Far away a wire would shrink below a pixel and break into dashes, so
// the ring grows to keep the wire min_pixels wide on screen at any distance.
shader_type spatial;
render_mode cull_disabled;

uniform vec4 albedo : source_color = vec4(0.07, 0.07, 0.075, 1.0);
uniform float min_pixels = 1.15;

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
	VERTEX.xy *= max(1.0, 0.5 * min_pixels * pixel / max(radius, 1e-5));
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = 0.55;
}
