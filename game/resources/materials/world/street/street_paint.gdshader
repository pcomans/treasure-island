shader_type spatial;
// Road paint (generated street-marking records): flat quads draped a few
// millimetres over the road. Opaque, with an alpha-scissor cut-out where the
// paint is worn through, so it is lit, shadowed and depth-sorted exactly like
// the asphalt under it in both renderers; the asphalt wear decals stay blended
// (street_decal.gdshader) and hide under it. Each vertex is pulled a hair toward
// the camera so the quads never z-fight the road.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// UV.x's integer part is the paint kind (street-ground-generation.mjs
// STREET_PAINT_KINDS: 0 white, 1 yellow, 2 red lane, 3 green lane, 4 tactile pad,
// 5 STOP legend, 6 faded yellow); a legend's fraction and UV.y are its local
// coordinates.
uniform sampler2D paint_wear : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tactile : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D stop_legend : hint_default_black, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float view_pull = 0.9995;
uniform float paint_tile_m = 1.7;
uniform float tactile_tile_m = 0.6;
// The photographed paints as colour uniforms (sRGB, like any material colour), so
// each renderer brings them into its lighting space itself: thermoplastic white
// and yellow, the sun-faded transit-lane red (Sep 2025: about 54/34/38 %), the
// green bike-lane conflict paint and a worn residential centre line. Written as
// linear constants they rendered right in Forward+ but far too dark in the
// Compatibility renderer of the web build (the red lane read as dark plum).
uniform vec3 white_paint : source_color = vec3(0.896, 0.896, 0.881);
uniform vec3 yellow_paint : source_color = vec3(0.906, 0.715, 0.221);
uniform vec3 red_lane : source_color = vec3(0.410, 0.215, 0.229);
uniform vec3 green_lane : source_color = vec3(0.272, 0.517, 0.323);
uniform vec3 faded_yellow : source_color = vec3(0.674, 0.566, 0.306);

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec4 view_position = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);
	// Perspective: scaling along the view ray keeps the point on screen.
	// Orthographic: the rays are parallel, so only the depth moves.
	if (PROJECTION_MATRIX[3][3] == 0.0) {
		view_position.xyz *= view_pull;
	} else {
		view_position.z *= view_pull;
	}
	POSITION = PROJECTION_MATRIX * view_position;
}

void fragment() {
	float kind = floor(UV.x);
	vec2 local = vec2(fract(UV.x), UV.y);
	// Grey wear mask tiled in world space: white = paint, dark = worn to asphalt.
	// Line paint is cut through only where the mask is below 0.25 (about 5 % of it).
	float wear = texture(paint_wear, world_position.xz / paint_tile_m).r;
	vec3 albedo = white_paint;
	float coverage = wear + 0.25;
	float rough = 0.75;
	// Lane fills are never cut through, only mottled where worn.
	if (kind < 0.5) {
		albedo = white_paint;
	} else if (kind < 1.5) {
		albedo = yellow_paint;
	} else if (kind < 2.5) {
		albedo = red_lane * mix(0.8, 1.0, wear);
		coverage = 1.0;
	} else if (kind < 3.5) {
		albedo = green_lane * mix(0.8, 1.0, wear);
		coverage = 1.0;
	} else if (kind < 4.5) {
		albedo = texture(tactile, world_position.xz / tactile_tile_m).rgb;
		coverage = 1.0;
		rough = 0.6;
	} else if (kind < 5.5) {
		coverage = (wear + 0.25) * texture(stop_legend, local).r;
	} else {
		// Old residential centre line: dulled yellow, worn half away.
		albedo = faded_yellow;
		coverage = smoothstep(0.25, 0.85, wear);
	}
	ALBEDO = albedo;
	ALPHA = coverage;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = rough;
	SPECULAR = 0.35;
}
