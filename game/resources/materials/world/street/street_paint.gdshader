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
// 8 accessible blue, 9 a legend of the atlas, 10 a lot's tar-sealed joint, 11 a
// lot's patched strip, 12 dark accessible blue, 13 thin rolled white, 14 a white
// line and 15 a double yellow worn nearly back to the road. The variant is the paint's wear
// step, 0 fresh, 3 mostly worn, 4 nearly worn away; for kind 9 it is the atlas cell plus
// legend_cells times the wear step (STREET_LEGEND_ATLAS_CELLS). A legend's
// fraction and UV.y are its local coordinates.
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
// The Johnson St lot's filled bays, near the asphalt's own tone (May 2026 aerial).
uniform vec3 accessible_blue_dark : source_color = vec3(0.160, 0.260, 0.440);
uniform vec3 worn_paint : source_color = vec3(0.560, 0.560, 0.540);
// A parking lot's crack sealant and its patched strips (Sep 2025 photos of the
// lot by Mersea: dark grey joints and darker grey asphalt patches on the pale
// lot asphalt, which renders at about 0.40).
uniform vec3 sealant : source_color = vec3(0.240, 0.240, 0.245);
uniform vec3 patch_asphalt : source_color = vec3(0.360, 0.360, 0.365);
// The Mersea promenade's old paint (owner video, Nov 2026): the crossing's bars rolled
// thin over worn asphalt, about 165,160,156 under the tone map, its white lines gone to
// about 150,142,130, and a double yellow worn to an ochre a shade off the road.
uniform vec3 rolled_white : source_color = vec3(0.52, 0.505, 0.48);
uniform vec3 trace_white : source_color = vec3(0.36, 0.335, 0.3);
uniform vec3 trace_yellow : source_color = vec3(0.275, 0.245, 0.185);
// A tar-sealed crack in an old road (a sealant's wear step 1): dark and dull, so a
// walker's low view doesn't catch the sky in it.
uniform vec3 crack_tar : source_color = vec3(0.16, 0.145, 0.13);

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
	// Step 4 (nearly worn away) also takes the mask's specks at a second scale and
	// dulls the paint further, so little more than a faint broken trace is left.
	float wear = texture(paint_wear, world_position.xz / paint_tile_m).r;
	float wear_fine = texture(paint_wear, world_position.zx / (paint_tile_m * 0.43) + vec2(0.37, 0.71)).r;
	float cell = mod(variant, legend_cells);
	float wear_step = kind > 8.5 && kind < 9.5 ? floor(variant / legend_cells + 0.001) : variant;
	float worn = clamp(wear_step / 3.0, 0.0, 4.0 / 3.0);
	wear = mix(wear, min(wear, wear_fine) * 0.92, step(3.5, wear_step));
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
	} else if (kind < 9.5) {
		// A legend of the atlas, worn like the line paint; the promenade's shared-path
		// mark (cell 6) rolled thin like its crossing's bars.
		float mark = texture(legends, vec2((cell + local.x) / legend_cells, local.y)).r;
		coverage = (wear + 0.25 - worn * 0.3) * mark;
		if (cell > 5.5 && cell < 6.5) {
			albedo = rolled_white * mix(1.05, 1.3, wear_fine);
			coverage = (wear_fine + 0.5) * mark;
		}
	} else if (kind < 10.5) {
		// Tar sealant along a lot joint: dark grey, a little glossy, broken where worn.
		albedo = sealant;
		coverage = wear + 0.1;
		rough = 0.6;
		if (wear_step > 0.5) {
			albedo = crack_tar;
			coverage = wear + 0.2;
			rough = 0.95;
			worn = 0.0;
		}
	} else if (kind < 11.5) {
		// A patched strip of darker asphalt, mottled, never cut through.
		albedo = patch_asphalt * mix(0.88, 1.06, wear);
		coverage = 1.0;
		rough = 0.95;
		// Wear step 1: an old road's dark oval patch, in the crack tar's tone.
		if (wear_step > 0.5) {
			albedo = crack_tar * mix(1.5, 1.8, wear_fine);
			worn = 0.0;
		}
	} else if (kind < 12.5) {
		// A filled accessible bay in the darker blue, mottled where worn.
		albedo = accessible_blue_dark * mix(0.82, 1.0, wear);
		coverage = 1.0 - worn * 0.35 * (1.0 - wear);
	} else if (kind < 13.5) {
		// Rolled white: the road's stones mottle it and only the odd one shows through.
		float stones = texture(paint_wear, world_position.zx / 0.13 + vec2(0.19, 0.53)).r;
		albedo = rolled_white * mix(0.84, 1.08, wear_fine) * mix(0.9, 1.05, wear) * mix(0.76, 1.08, stones);
		coverage = max(wear, wear_fine) + 0.32;
	} else if (kind < 14.5) {
		// A white line nearly gone: dull, broken in soft patches.
		albedo = trace_white * mix(0.85, 1.05, wear);
		coverage = smoothstep(0.18, 0.62, mix(wear, wear_fine, 0.5)) + 0.05;
	} else {
		// A double yellow nearly gone: an ochre stain with the road showing through.
		albedo = trace_yellow * mix(0.85, 1.05, wear_fine);
		coverage = smoothstep(0.38, 0.84, mix(wear, wear_fine, 0.6));
	}
	albedo = mix(albedo, worn_paint, worn * 0.45);
	ALBEDO = albedo;
	ALPHA = coverage;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	ROUGHNESS = rough;
	SPECULAR = 0.35;
}
