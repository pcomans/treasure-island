shader_type spatial;
#ifdef GROUND_DRESSING_CAPTURE
render_mode unshaded, depth_draw_opaque, cull_back;
#else
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;
#endif

// Island ground cover: maintained lawn, dry grass and bare soil from one set of
// existing CC0 Poly Haven sparse_grass maps. Each family material only changes
// how much of each layer it shows (game/scripts/world/ground_cover.gd).
//
// The albedo is read raw (no source_color) and split into a grass-tuft mask and
// a straw mask; the palettes below then supply the colour, so the photo's red
// soil never shows. Generated ground UVs are world XZ / 10.
//
// The world ground-cover map (tools/lib/ground-cover-map.mjs) draws recipe
// families over a family's own mix where its rules place them: its red, green,
// blue and alpha are the weights of the lawn, straw, dry-field and bare recipes
// (each a dry threshold, bare threshold and green dryness), and whatever weight
// is left keeps the family's own settings.

uniform sampler2D detail_albedo : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D detail_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D detail_roughness : filter_linear_mipmap_anisotropic, repeat_enable;

// Late-spring palettes: gap (ground between tufts), blade (tufts), straw.
// The lawn colours follow the 2026-05-26 aerial's sunlit lawns from above
// (about sRGB 92,113,74) and the ferry plaza lawn in the Sep 2025 photos
// (about 85,108,70); the earlier March-photo tuning drew them 40-50 % brighter
// and yellower than the aerial in a top-down render.
uniform vec3 lawn_gap : source_color = vec3(0.233, 0.300, 0.112);
uniform vec3 lawn_blade : source_color = vec3(0.303, 0.394, 0.156);
uniform vec3 lawn_straw : source_color = vec3(0.378, 0.422, 0.212);
// Dry grass: the 2026-05-26 aerial's late-spring straw from above (about sRGB
// 122-155, 110-133, 81-101; the residential grounds darker, the mown GAA B
// paler), drawn about a tenth lighter than the aerial so the flat ground
// reads like the sunlit straw of the Nov 2025 street photos (about 160,148,105).
uniform vec3 dry_gap : source_color = vec3(0.399, 0.340, 0.239);
uniform vec3 dry_blade : source_color = vec3(0.459, 0.432, 0.264);
uniform vec3 dry_straw : source_color = vec3(0.637, 0.565, 0.418);
// Bare soil: the grey-brown dirt of the 2026-05-26 aerial's fields from above
// in sun (May 2026 z19 tiles: about sRGB 150-165, 145-157, 120-140), drawn
// lighter on wholly bare ground toward its pale graded fill (about 178, 178,
// 158; see soil_tone below). Gap is the dirt, blade its clods and shade where
// the detail photo has its tufts, straw the dead blades lying on it. The
// earlier pale cream with little texture read as near white from a distance
// and as spilled flour close up.
uniform vec3 soil_gap : source_color = vec3(0.500, 0.480, 0.400);
uniform vec3 soil_blade : source_color = vec3(0.400, 0.385, 0.320);
uniform vec3 soil_straw : source_color = vec3(0.600, 0.560, 0.440);

// Family mix. A point turns dry where the patch noise exceeds dry_threshold and
// bare where the bare level (bare_level) exceeds bare_threshold; above 1
// disables a layer, below 0 fills the family with it. green_dryness pulls the
// green toward olive.
uniform float dry_threshold = 0.63;
uniform float bare_threshold = 2.0;
uniform float green_dryness = 0.0;
uniform float patch_scale_m = 24.0;
uniform float bare_scale_m = 23.0;
uniform float patch_softness = 0.08;

// The world map of recipe weights and its rectangle: origin x, z and the
// inverse of its width and depth in metres. A black map leaves every family as is.
// Anisotropic, so the map's lawn edges stay put on ground seen at a grazing angle.
uniform sampler2D cover_map : hint_default_black, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec4 cover_map_rect = vec4(-720.0, -960.0, 0.000694444, 0.000520833);
uniform vec3 recipe_lawn = vec3(2.0, 2.0, 0.0);
uniform vec3 recipe_straw = vec3(2.0, 2.0, 0.0);
uniform vec3 recipe_dry_field = vec3(2.0, 2.0, 0.0);
uniform vec3 recipe_bare = vec3(2.0, 2.0, 0.0);

// Artificial turf: turf_amount pulls the green layer to an even dark pitch green
// (the 2026-05-26 aerial's pitch reads about sRGB 32,61,37 from above; drawn a
// little lighter).
uniform float turf_amount = 0.0;
uniform vec3 turf_color : source_color = vec3(0.08, 0.17, 0.065);

// The ditch beside the Mersea lot (owner video IMG_0960, 2026-11-06, and photos, Nov
// 2026), drawn from the marsh map, the land's height and noise over the land and the
// wetland overlay alike, so neither's edge shows and nothing in it is listed by
// position. marsh_amount switches it on for a family, and it fades out between
// marsh_radii from the ditch's axis (marsh_axis: its ends' x, z) and on land too low to
// drain into it. marsh_map's red holds the signed distance from the wetland's outline
// (0.5 on it, MARSH_MAP_RANGE_M metres to white inside), its green the distance from the
// lots' paving and its blue the floor's mapped low ground. Inside the frayed outline
// lies the floor, a mat of low succulents: a stipple of crimson tips through warm litter,
// thick in some drifts and thin in others, with lenses of straw and dull green. The footage
// reads about sRGB 88,62,49 with R over 1.3 G in about 78% of its pixels, 1.45 G in 50%, 1.6 G
// in 30% and 1.9 G in 8%: red by the mix, never a sheet. Flopped dead grass climbs from it
// to crushed rock at the lots' edges. Water stands in the low ground alone, a shallow arm
// with ragged edges and a little mud round it.
uniform sampler2D marsh_map : hint_default_black, filter_linear, repeat_disable;
// Four grain patterns from above, one per channel (generated: a fine red mat, straw litter,
// crushed rock and flopped dead grass, each normalised to a mean of about a half;
// marsh_grain.png): the ground's colours are the palette's, picked by these, so it stays
// fine to a walker's feet.
uniform sampler2D marsh_grain : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float marsh_amount = 0.0;
uniform vec4 marsh_axis = vec4(-295.0, 145.0, -345.0, 290.0);
uniform vec2 marsh_radii = vec2(46.0, 66.0);
uniform float marsh_floor_y = 1.95;
uniform vec3 marsh_wine : source_color = vec3(0.15, 0.085, 0.07);
uniform vec3 marsh_crimson : source_color = vec3(0.27, 0.14, 0.115);
uniform vec3 marsh_flare : source_color = vec3(0.33, 0.165, 0.13);
uniform vec3 marsh_ruddy : source_color = vec3(0.165, 0.122, 0.088);
uniform vec3 marsh_straw : source_color = vec3(0.36, 0.27, 0.19);
uniform vec3 marsh_green : source_color = vec3(0.12, 0.13, 0.075);
uniform vec3 marsh_olive : source_color = vec3(0.235, 0.215, 0.125);
uniform vec3 marsh_mud : source_color = vec3(0.25, 0.2, 0.16);
uniform vec3 marsh_wet_mud : source_color = vec3(0.16, 0.13, 0.105);
uniform vec3 marsh_cobble : source_color = vec3(0.62, 0.58, 0.51);
uniform vec3 bank_gap : source_color = vec3(0.115, 0.092, 0.08);
uniform vec3 bank_blade : source_color = vec3(0.255, 0.21, 0.18);
uniform vec3 bank_straw : source_color = vec3(0.44, 0.385, 0.33);
uniform vec3 bank_gravel : source_color = vec3(0.33, 0.32, 0.29);
uniform vec3 bank_sand : source_color = vec3(0.31, 0.27, 0.225);
uniform vec3 marsh_far_red : source_color = vec3(0.31, 0.2, 0.115);
uniform vec3 marsh_far_olive : source_color = vec3(0.29, 0.26, 0.12);
uniform vec3 marsh_far_straw : source_color = vec3(0.45, 0.39, 0.25);
// Standing water's own colour: a neutral murk, so its blue is the sky it reflects.
uniform vec3 puddle_tint : source_color = vec3(0.08, 0.085, 0.09);

// A watered pitch's sprinkler grid: dry patches midway between the heads of a
// grid_m square grid turned grid_angle radians from world +X, at grid_amount.
uniform float grid_m = 18.0;
uniform float grid_angle = 0.0;
uniform float grid_amount = 0.0;

uniform float detail_repeat_m = 5.0;
uniform float normal_strength = 0.3;
// Beyond fade_end_m every layer shows its average colour, so mipmapped detail
// cannot drift the family's colour with distance.
uniform float fade_start_m = 25.0;
uniform float fade_end_m = 110.0;

// Average share of gap, blade and straw pixels in sparse_grass_diff_1k under
// the masks in tuft_masks(); the distance fade lands on these layer means.
// Measured on the lossless (compress/mode=0) import; recompute if that changes.
const vec3 LAYER_SHARE = vec3(0.6108, 0.3586, 0.0305);
// The noise level above which water stands on the floor and how fast it climbs with the land.
const float WATER_LEVEL = 0.8;
const float WATER_RISE_PER_M = 2.0;
// How much the marsh map's pool mask (blue: the floor's mapped low ground) lifts the water,
// and how far the floor outside that mask is held under it.
const float WATER_POOL = 0.68;
const float WATER_DRY = 0.3;
const float MARSH_TILE_M = 1.8;
// The flopped grass's and the crushed rock's repeats, and the red and straw grains' means.
const float BANK_TILE_M = 3.0;
const float BANK_ROCK_TILE_M = 1.67;
const float RED_GRAIN_MEAN = 0.455;
const float STRAW_GRAIN_MEAN = 0.485;
// marsh_map's reach either side of the outline (tools/lib/ground-cover-map.mjs).
const float MARSH_MAP_RANGE_M = 32.0;

// The ground's height, for the marsh's standing water.
varying float ground_y;

void vertex() {
	ground_y = (MODEL_MATRIX * vec4(VERTEX, 1.0)).y;
}

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float value_noise(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float a = hash12(cell);
	float b = hash12(cell + vec2(1.0, 0.0));
	float c = hash12(cell + vec2(0.0, 1.0));
	float d = hash12(cell + vec2(1.0, 1.0));
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// x: grass tuft, y: straw blade, z: signed soil grain. The thresholds are
// calibrated on the lossless (compress/mode=0) sparse_grass_diff_1k import.
vec3 tuft_masks(vec3 s) {
	float tuft = clamp((s.g - 0.72 * s.r + 0.02) / 0.10, 0.0, 1.0);
	float lum = dot(s, vec3(0.2126, 0.7152, 0.0722));
	float straw = clamp((lum - 0.27) / 0.12, 0.0, 1.0) * (1.0 - tuft);
	float grain = clamp((lum - 0.244) * 2.5, -0.25, 0.25);
	return vec3(tuft, straw, grain);
}

// Bare ground: patches of many sizes with irregular outlines (three octaves of
// warped noise) that cluster by region, some stretches of a field barer than
// others, and near the camera a fine term that frays their edges. Its
// distribution matches the single-octave noise it replaced (median 0.5, about
// 27 % above 0.6 and 10 % above 0.7), so the families' thresholds keep their
// shares.
float bare_level(vec2 p, float fade) {
	vec2 s = p / bare_scale_m;
	vec2 warp = vec2(value_noise(s / 1.7 + vec2(3.1, 7.7)), value_noise(s / 1.7 + vec2(11.3, 1.9))) - 0.5;
	vec2 q = s + 0.9 * warp;
	float level = 0.6 * value_noise(q + vec2(41.7, 9.2)) + 0.28 * value_noise(2.2 * q + vec2(5.3, 17.9)) + 0.12 * value_noise(4.9 * q + vec2(29.1, 3.7));
	level += 0.3 * (value_noise(s / 6.0 + vec2(13.7, 71.3)) - 0.5);
	if (fade < 1.0) {
		level += 0.1 * (value_noise(p / 1.3 + vec2(61.1, 2.3)) - 0.5) * (1.0 - fade);
	}
	return level;
}

vec3 cover_layer(vec3 gap, vec3 blade, vec3 straw, vec3 m, float grain_gain, float fade) {
	vec3 detail = mix(mix(gap, blade, m.x), straw, m.y) * (1.0 + m.z * grain_gain);
	vec3 mean = gap * LAYER_SHARE.x + blade * LAYER_SHARE.y + straw * LAYER_SHARE.z;
	return mix(detail, mean, fade);
}

// game/scripts/world/ground_dressing.gd compiles this shader once more with
// GROUND_DRESSING_CAPTURE defined, to read what the ground draws from above.
#ifdef GROUND_DRESSING_CAPTURE
#include "res://game/resources/materials/world/ground_cover/ground_dressing_capture.gdshaderinc"
#endif

void fragment() {
	vec2 p = UV * 10.0;
	// The family's own mix, with the map's recipes drawn over it.
	vec4 cover = texture(cover_map, (p - cover_map_rect.xy) * cover_map_rect.zw);
	float own = clamp(1.0 - (cover.r + cover.g + cover.b + cover.a), 0.0, 1.0);
	vec3 mix_settings = vec3(dry_threshold, bare_threshold, green_dryness) * own
		+ recipe_lawn * cover.r + recipe_straw * cover.g + recipe_dry_field * cover.b + recipe_bare * cover.a;
#ifdef GROUND_DRESSING_CAPTURE
	// The capture's camera recentres as the player moves, so a distance from it would
	// move what the grass grows by; the capture reads the near ground's, where it stands.
	float view_m = 0.0;
#else
	float view_m = length(VERTEX);
#endif
	float fade = smoothstep(fade_start_m, fade_end_m, view_m);
	float n_patch = value_noise(p / patch_scale_m);
	float n_fine = value_noise(p / (patch_scale_m * 0.31) + vec2(17.31, 5.13));
	float n_blend = value_noise(p / 7.3 + vec2(3.71, 29.17));
	float patch_level = 0.65 * n_patch + 0.35 * n_fine;
	if (grid_amount > 0.0) {
		vec2 axis = vec2(cos(grid_angle), sin(grid_angle));
		vec2 q = vec2(dot(p, axis), dot(p, vec2(-axis.y, axis.x))) * (TAU / grid_m);
		// 0 at a sprinkler head, 1 midway between four.
		float between = 0.5 - 0.25 * (cos(q.x) + cos(q.y));
		patch_level = mix(patch_level, 0.75 * between + 0.25 * n_fine, grid_amount);
	}
	float dry_w = smoothstep(mix_settings.x - patch_softness, mix_settings.x + patch_softness, patch_level);

	// Two detail samples at unrelated scales and angles hide the 5 m repeat.
	vec2 uv_a = p / detail_repeat_m;
	vec2 uv_b = mat2(vec2(0.799, 0.602), vec2(-0.602, 0.799)) * p / (detail_repeat_m * 2.71) + vec2(0.37, 0.71);
	vec3 m = mix(tuft_masks(texture(detail_albedo, uv_a).rgb), tuft_masks(texture(detail_albedo, uv_b).rgb), smoothstep(0.3, 0.7, n_blend));

	vec3 dry = cover_layer(dry_gap, dry_blade, dry_straw, m, 0.6, fade);
	vec3 lawn = cover_layer(lawn_gap, lawn_blade, lawn_straw, m, 0.25, fade);
	lawn = mix(lawn, turf_color * (0.92 + 0.16 * m.x), turf_amount);
	vec3 green = mix(lawn, dry, mix_settings.z);
	vec3 ground = mix(green, dry, dry_w);
	float pool = 0.0;
	float pool_depth = 1.0;
	float marsh_cover = 0.0;
	float rough = 0.0;
	float bare_cover = 0.0;
	if (marsh_amount > 0.0) {
		vec2 axis = marsh_axis.zw - marsh_axis.xy;
		vec2 from_start = p - marsh_axis.xy;
		float off_axis = length(from_start - axis * clamp(dot(from_start, axis) / dot(axis, axis), 0.0, 1.0));
		float region = 0.0;
		if (off_axis < marsh_radii.y + 13.0) {
			float reach = off_axis + 26.0 * (value_noise(p / 29.0 + vec2(5.1, 77.7)) - 0.5);
			region = (1.0 - smoothstep(marsh_radii.x, marsh_radii.y, reach)) * smoothstep(1.2, 1.6, ground_y) * marsh_amount;
		}
		if (region > 0.0) {
			float dist = view_m;
			float n_mid = value_noise(p / 5.7 + vec2(23.7, 11.1));
			float n_wide = value_noise(p / 23.0 + vec2(71.3, 37.9));
			float n_patch8 = value_noise(p / 8.0 + vec2(19.3, 83.1));
			// The small noises hold out to the ditch's far side, so its edges stay ragged,
			// and settle to their mean past that.
			float ragged = 1.0 - smoothstep(130.0, 260.0, dist);
			float n_small = mix(0.5, value_noise(p / 2.1 + vec2(3.3, 47.9)), ragged);
			float n_tiny = mix(0.5, value_noise(p / 0.8 + vec2(29.9, 13.3)), ragged);
			float fine = 1.0 - smoothstep(60.0, 150.0, dist);
			float n_fine = mix(0.5, value_noise(p / 0.37 + vec2(37.3, 5.9)), fine);
			float far_off = smoothstep(150.0, 420.0, dist);
			// The marsh map: red the signed distance from the wetland's outline, green the
			// distance from the lots' paving, blue the floor's low ground.
			vec3 marsh_read = texture(marsh_map, (p - cover_map_rect.xy) * cover_map_rect.zw).rgb;
			float outline_m = (marsh_read.r - 0.5) * 2.0 * MARSH_MAP_RANGE_M;
			float paved_m = marsh_read.g * MARSH_MAP_RANGE_M;
			// A straw bank climbs to the lots' edges, so no lot's slab drops onto the mat.
			float bank_rise = 1.0 - smoothstep(1.5, 9.5, paved_m + 7.0 * (n_mid - 0.5) + 4.0 * (n_small - 0.5));
			float h_land = ground_y + 0.6 * (n_wide - 0.5) + 0.5 * (n_mid - 0.5) + 0.3 * (n_small - 0.5);
			float h = h_land + 1.6 * bank_rise;

			// The grain, read at two scales so its repeat never shows.
			vec2 tile_uv = mat2(vec2(0.82, 0.57), vec2(-0.57, 0.82)) * p / MARSH_TILE_M;
			vec2 grain_near = texture(marsh_grain, tile_uv).rg;
			vec2 grain_mid = texture(marsh_grain, mat2(vec2(0.31, -0.95), vec2(0.95, 0.31)) * p / (MARSH_TILE_M * 2.9) + vec2(0.37, 0.71)).rg;
			vec2 grain = mix(grain_near, grain_mid, 0.3);
			float green_grain = texture(marsh_grain, vec2(tile_uv.y, -tile_uv.x) * 1.37 + vec2(0.21, 0.63)).r;

			// The slopes: dead grass flopped in swathes over dark thatch, hollowed between
			// its tussocks (a hollow, not a shadow: it holds under any sun).
			float flopped = mix(texture(marsh_grain, mat2(vec2(0.96, 0.28), vec2(-0.28, 0.96)) * p / BANK_TILE_M).a, texture(marsh_grain, mat2(vec2(0.55, -0.83), vec2(0.83, 0.55)) * p / (BANK_TILE_M * 2.63) + vec2(0.13, 0.57)).a, 0.35);
			vec3 bank = mix(mix(bank_gap, bank_blade, smoothstep(0.3, 0.52, flopped)), bank_straw, smoothstep(0.52, 0.74, flopped));
			float hollow = smoothstep(0.5, 0.7, 0.6 * value_noise(p / 1.9 + vec2(67.1, 31.7)) + 0.4 * n_small);
			bank *= (1.0 - 0.45 * hollow) * (0.86 + 0.28 * smoothstep(0.3, 0.7, 0.55 * n_mid + 0.45 * n_patch8));
			// The slope falls away a little darker to its foot, pale at the top.
			bank *= mix(0.9, 1.06, smoothstep(2.6, 3.7, h));
			// Sand lies along the lots' edges before the grass takes over, and crushed rock
			// spills from their shoulders over it, each ragged into the next.
			float rock_grain = texture(marsh_grain, p / BANK_ROCK_TILE_M).b;
			float sand_w = 1.0 - smoothstep(1.0, 5.0, paved_m + 3.0 * (n_small - 0.5) + 2.0 * (n_mid - 0.5) + 1.2 * (n_tiny - 0.5) + 1.6 * (flopped - 0.5));
			bank = mix(bank, bank_sand * (0.5 + rock_grain), 0.85 * sand_w);
			float rock_w = 1.0 - smoothstep(0.2, 1.6, paved_m + 1.8 * (n_small - 0.5) + 1.2 * (n_tiny - 0.5) + 1.0 * (flopped - 0.5));
			bank = mix(bank, bank_gravel * (0.2 + 1.6 * smoothstep(0.15, 0.85, rock_grain)), rock_w);
			float bank_w = 1.0 - smoothstep(4.7, 5.3, h_land);

			// The mat: a stipple of crimson tips through warm litter, thick in some drifts and
			// thin in others, with flecks of straw through it all, never a sheet. Each stipple
			// is its grain at four scales, each taking over as the finer ones average out, so
			// it holds from a walker's feet to the far bank; each runs about -2 to 2.
			vec2 along = vec2(0.643 * p.x + 0.766 * p.y, 0.643 * p.y - 0.766 * p.x);
			vec2 fine_grain = texture(marsh_grain, mat2(vec2(0.6, 0.8), vec2(-0.8, 0.6)) * p / 19.0 + vec2(0.11, 0.83)).rg;
			vec2 wide_grain = texture(marsh_grain, mat2(vec2(-0.38, 0.92), vec2(-0.92, -0.38)) * p / 61.0 + vec2(0.57, 0.29)).rg;
			vec2 stipples = (0.3 * grain_near + 0.25 * grain_mid + 0.25 * fine_grain + 0.2 * wide_grain - vec2(RED_GRAIN_MEAN, STRAW_GRAIN_MEAN)) * mix(12.0, 32.0, smoothstep(8.0, 90.0, dist));
			float thick = smoothstep(0.34, 0.66, 0.5 * value_noise(along / vec2(19.0, 8.0) + vec2(7.3, 51.9)) + 0.34 * value_noise(along / vec2(7.0, 3.6) + vec2(23.7, 11.1)) + 0.1 * n_small + 0.06 * n_tiny);
			// Close to, the tips stand apart: fewer of them fill a walker's view.
			float red_w = smoothstep(-0.3, 0.3, stipples.x - mix(1.3, -0.5, thick) - 0.7 * (1.0 - smoothstep(10.0, 40.0, dist)));
			float straw_w = smoothstep(0.57, 0.67, 0.42 * value_noise(along / vec2(11.0, 3.4) + vec2(61.7, 43.9)) + 0.22 * n_mid + 0.18 * n_small + 0.18 * n_tiny + 0.14 * (grain.y - 0.5) * fine);
			float green_w = smoothstep(0.61, 0.66, 0.6 * value_noise(along / vec2(14.0, 4.6) + vec2(11.7, 23.1)) + 0.22 * n_small + 0.18 * n_tiny);
			vec3 red = mix(marsh_wine, marsh_crimson, smoothstep(0.34, 0.62, grain.x));
			red = mix(red, marsh_flare, 0.5 * smoothstep(0.66, 0.86, grain.x));
			vec3 marsh = mix(marsh_ruddy, marsh_straw, 0.06 + 0.4 * smoothstep(0.5, 0.8, grain.y));
			marsh = mix(marsh, mix(marsh_green, marsh_olive, smoothstep(0.34, 0.62, green_grain)), green_w);
			marsh = mix(marsh, mix(marsh_ruddy, marsh_straw, smoothstep(0.34, 0.62, grain.y)), straw_w);
			marsh = mix(marsh, red, red_w * (1.0 - 0.6 * max(straw_w, green_w)));
			marsh = mix(marsh, marsh_straw, 0.85 * smoothstep(0.7, 1.1, stipples.y));
			marsh *= (1.0 + 0.45 * (fine_grain.x + wide_grain.x - 2.0 * RED_GRAIN_MEAN) * mix(1.0, 2.2, smoothstep(20.0, 90.0, dist))) * (1.0 - 0.4 * smoothstep(0.6, 1.2, -stipples.x));
			// The floor: inside the wetland's frayed outline, and any lower land round it.
			float wet = smoothstep(-1.5, 3.0, outline_m + 7.0 * (n_mid - 0.5) + 5.0 * (n_wide - 0.5) + 2.5 * (n_small - 0.5)) * (1.0 - bank_rise);
			float carpet = max(1.0 - smoothstep(2.45, 2.8, h), wet);

			// From far off the mats would average to a dark stain under the haze: they lift
			// to red-brown and olive, broken by straw, and the bank goes back to the ground
			// round it.
			if (far_off > 0.0) {
				float far_mats = 0.6 * value_noise(p / 27.0 + vec2(17.3, 3.9)) + 0.4 * n_mid;
				vec3 far_marsh = mix(marsh_far_red, marsh_far_olive, smoothstep(0.46, 0.68, far_mats));
				far_marsh = mix(far_marsh, marsh_far_straw, smoothstep(0.5, 0.76, 0.7 * value_noise(p / 15.0 + vec2(51.1, 29.7)) + 0.3 * n_mid));
				marsh = mix(marsh, far_marsh, far_off);
				bank = mix(bank, ground, far_off);
			}

			// Water stands in the floor's mapped low ground alone, a shallow arm with ragged
			// edges and islets, and a thin line of mud round it.
			float water = 0.38 * value_noise(along / vec2(15.0, 5.0) + vec2(3.7, 19.1)) + 0.38 * value_noise(along / vec2(5.5, 2.4) + vec2(41.3, 7.9)) + 0.24 * n_small;
			water -= WATER_LEVEL + WATER_RISE_PER_M * max(0.0, ground_y - marsh_floor_y);
			water += WATER_POOL * marsh_read.b - WATER_DRY * (1.0 - smoothstep(0.0, 0.2, marsh_read.b));
			water += 0.1 * (n_fine - 0.5) + 0.2 * (n_tiny - 0.5) + 0.24 * (n_small - 0.5) + 0.12 * (n_mid - 0.5);
			float flat_w = smoothstep(-0.07, -0.01, water + 0.12 * (grain.y - 0.5) + 0.1 * (n_small - 0.5));
			vec3 mud = mix(marsh_wet_mud, marsh_mud, smoothstep(0.32, 0.6, grain.y) * (1.0 - 0.5 * smoothstep(-0.05, 0.02, water)));
			marsh = mix(marsh, mud, 0.92 * flat_w * (1.0 - far_off));

			// Stones near the walker are real forms (the marsh_stones rows); past their reach
			// they leave pale flecks in the mat, the same all round.
			float flecks = smoothstep(45.0, 62.0, dist) * (1.0 - fade);
			if (flecks > 0.0) {
				vec2 cell = floor(p / 1.1);
				vec2 inside = fract(p / 1.1) - (0.25 + 0.5 * vec2(hash12(cell + 31.0), hash12(cell + 53.0)));
				float size = (0.045 + 0.1 * hash12(cell + 71.0) * hash12(cell + 97.0) * 2.0) / 1.1;
				float drift = smoothstep(0.42, 0.62, value_noise(p / 13.0 + vec2(91.3, 5.7)));
				float here = step(1.0 - 0.62 * drift, hash12(cell + 17.0)) * flecks * (1.0 - smoothstep(-0.02, 0.05, water));
				marsh = mix(marsh, marsh_cobble * (0.8 + 0.4 * hash12(cell + 7.0)), (1.0 - smoothstep(size * 0.8, size, length(inside))) * here);
			}

			ground = mix(ground, mix(bank, marsh, carpet), region * max(bank_w, carpet));
			marsh_cover = region * max(bank_w, carpet);
			rough = region * (1.0 - carpet) * bank_w;

			// Plants and mud stand through the water's edge, so it never ends in a line; the
			// shallows show their mud, the deep the sky.
			float reeds = smoothstep(0.42, 0.62, 0.5 * n_tiny + 0.5 * n_small);
			pool = smoothstep(0.0, 0.02, water) * (1.0 - reeds * (1.0 - smoothstep(0.05, 0.2, water))) * region * (1.0 - 0.75 * far_off);
			pool_depth = smoothstep(0.02, 0.3, water);
		}
	}
	if (mix_settings.y <= 1.0 + patch_softness) {
		float bare = bare_level(p, fade);
		// A crisp edge near the camera, a little softer where the fraying has faded out.
		float edge = mix(0.02, 0.05, fade);
		float bare_w = smoothstep(mix_settings.y - edge, mix_settings.y + edge, bare);
		// The detail photo's grass tufts, kept crisp, grow on into a patch's edge
		// and sparsely in its middle.
		float inside = smoothstep(mix_settings.y, mix_settings.y + 0.12, bare);
		bare_w *= (1.0 - smoothstep(0.35, 0.65, m.x) * mix(1.0, 0.3, inside) * (1.0 - fade)) * (1.0 - marsh_cover);
		// soil_tone: the more of the ground is bare, the paler its soil, from the
		// fields' dirt patches to wholly graded fill.
		float soil_tone = mix(1.3, 1.0, smoothstep(0.35, 0.6, mix_settings.y));
		vec3 soil = cover_layer(soil_gap, soil_blade, soil_straw, m, 1.0, fade) * soil_tone;
		// Compacted and crusted ground in light and dark mottles, settling to its
		// mean with distance.
		if (fade < 1.0) {
			soil *= mix(0.84 + 0.32 * value_noise(p / 3.7 + vec2(23.9, 47.3)), 1.0, fade);
		}
		ground = mix(ground, soil, bare_w);
		bare_cover = bare_w;
	}
	ALBEDO = mix(ground * (0.94 + 0.12 * n_fine), mix(mix(ground, puddle_tint, 0.6), puddle_tint, pool_depth), pool);
#ifdef GROUND_DRESSING_CAPTURE
	ALBEDO = ground_dressing_capture(ALBEDO, p, cover, own, ground_y, bare_cover, pool, marsh_cover - rough);
#endif
	// Matte, with a gentle normal fade, so distant ground does not turn paler
	// than near ground through grazing-angle sky reflection or flatter normals;
	// standing water alone holds the sky.
	ROUGHNESS = mix(mix(clamp(texture(detail_roughness, uv_a).r, 0.85, 1.0), 1.0, fade), 0.08, pool);
	SPECULAR = mix(0.2, 0.5, pool);
	NORMAL_MAP = texture(detail_normal, uv_a).rgb;
	NORMAL_MAP_DEPTH = normal_strength * (1.0 - 0.5 * fade) * (1.0 - pool) * (1.0 + 1.5 * rough);
	// Standing water lies level: the land's facets under it must not show in its sky.
	NORMAL = normalize(mix(NORMAL, (VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz, pool));
}
