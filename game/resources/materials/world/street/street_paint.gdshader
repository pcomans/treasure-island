shader_type spatial;
// Road paint (generated street-marking records): flat quads draped a few
// millimetres over the road. Opaque, with an alpha-scissor cut-out where the
// paint is worn through, so it is lit, shadowed and depth-sorted exactly like
// the asphalt under it in both renderers; the asphalt wear decals stay blended
// (street_decal.gdshader) and hide under it. Each vertex is pulled a hair toward
// the camera so the quads never z-fight the road.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// UV.x's integer part is kind + 16 * variant (street-ground-generation.mjs
// STREET_PAINT_KINDS and PAINT_VARIANT_STRIDE): kinds 0 white, 1 yellow, 2 red
// lane, 3 green lane, 4 tactile pad, 5 STOP legend, 6 faded yellow, 7 red curb,
// 8 accessible blue, 9 a legend of the atlas. For kind 9 the variant is the atlas
// cell; for the others it is the paint's wear step, 0 fresh to 3 mostly worn
// away. A legend's fraction and UV.y are its local coordinates.
uniform sampler2D paint_wear : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D tactile : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D stop_legend : hint_default_black, filter_linear_mipmap_anisotropic, repeat_disable;
uniform sampler2D legends : hint_default_black, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float legend_cells = 8.0;
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
// Fire-lane red curb paint and accessible-stall blue (Mar and Sep 2025 photos of
// the Villages' curbs and the lot by Mersea), and the grey that worn paint
// fades toward.
uniform vec3 curb_red : source_color = vec3(0.640, 0.230, 0.215);
uniform vec3 accessible_blue : source_color = vec3(0.150, 0.330, 0.600);
uniform vec3 worn_paint : source_color = vec3(0.560, 0.560, 0.540);

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
	float code = floor(UV.x);
	float kind = mod(code, 16.0);
	float variant = floor(code / 16.0 + 0.001);
	vec2 local = vec2(fract(UV.x), UV.y);
	// Grey wear mask tiled in world space: white = paint, dark = worn to asphalt.
	// Fresh line paint is cut through only where the mask is below 0.25 (about 5 %
	// of it); each wear step dulls it toward worn grey and wears more of it through.
	float wear = texture(paint_wear, world_position.xz / paint_tile_m).r;
	float worn = kind > 8.5 ? 0.0 : clamp(variant / 3.0, 0.0, 1.0);
	vec3 albedo = white_paint;
	float coverage = wear + 0.25 - worn * 0.3;
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
		coverage = (wear + 0.25 - worn * 0.3) * texture(stop_legend, local).r;
	} else if (kind < 6.5) {
		// Old residential centre line: dulled yellow, worn half away.
		albedo = faded_yellow;
		coverage = smoothstep(0.25, 0.85, wear);
	} else if (kind < 7.5) {
		// Red curb paint, chipped along the curb.
		albedo = curb_red * mix(0.8, 1.0, wear);
		coverage = wear + 0.4 - worn * 0.3;
	} else if (kind < 8.5) {
		// An accessible stall's blue fill, mottled where worn.
		albedo = accessible_blue * mix(0.82, 1.0, wear);
		coverage = 1.0 - worn * 0.35 * (1.0 - wear);
	} else {
		// A legend of the atlas (cell = variant).
		coverage = (wear + 0.25) * texture(legends, vec2((variant + local.x) / legend_cells, local.y)).r;
	}
	albedo = mix(albedo, worn_paint, worn * 0.45);
	ALBEDO = albedo;
	ALPHA = coverage;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = rough;
	SPECULAR = 0.35;
}
