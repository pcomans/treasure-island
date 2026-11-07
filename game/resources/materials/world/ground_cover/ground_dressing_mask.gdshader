shader_type spatial;
// Where grass must stop, in the ground dressing's surface capture
// (game/scripts/world/ground_dressing.gd): paths, kerbs, paving, buildings and the
// feet of street props drawn from above multiply the capture by factor. The default
// leaves the ground's height but clears its dressing and its alpha, so height stays
// smooth under a road and a blade beside a kerb doesn't climb it. Depth-tested, so a
// lawn drawn over a paved area stays lawn.
render_mode unshaded, blend_mul, depth_draw_never, cull_disabled;

uniform vec4 factor = vec4(1.0, 0.0, 0.0, 0.0);
// A prop masks only below this height of its own, so grass grows on under a street
// light's arm.
uniform float below_m = 100000.0;

varying float prop_y;

void vertex() {
	prop_y = VERTEX.y;
}

void fragment() {
	if (prop_y > below_m) {
		discard;
	}
	ALBEDO = factor.rgb;
	ALPHA = factor.a;
}
