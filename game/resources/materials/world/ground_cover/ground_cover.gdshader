shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

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

// The ditch beside the Mersea lot (owner photos, Nov 2026), drawn from the land's
// height and noise over the land and the wetland overlay alike, so neither's edge
// shows and nothing in it is listed by position. marsh_amount switches it on for a
// family, and it fades out between marsh_radii from the ditch's axis (marsh_axis: its
// ends' x, z) and on land too low to drain into it. A wandering height decides what
// grows: a carpet of low succulents in mats of red, brown, olive and dead stems on the
// floor; dull dark straw, pale gravel and stones on the banks (lit, their mean about
// sRGB 126,109,93 and the mats' about 89,68,46). Water stands where the land is
// lowest, in outlines the noise draws.
uniform float marsh_amount = 0.0;
uniform vec4 marsh_axis = vec4(-295.0, 145.0, -345.0, 290.0);
uniform vec2 marsh_radii = vec2(46.0, 66.0);
uniform float marsh_floor_y = 1.78;
uniform vec3 rust_gap : source_color = vec3(0.185, 0.095, 0.045);
uniform vec3 rust_blade : source_color = vec3(0.285, 0.175, 0.065);
uniform vec3 rust_straw : source_color = vec3(0.370, 0.290, 0.190);
uniform vec3 marsh_brown : source_color = vec3(0.300, 0.225, 0.150);
uniform vec3 marsh_olive : source_color = vec3(0.235, 0.205, 0.090);
uniform vec3 bank_gap : source_color = vec3(0.335, 0.295, 0.245);
uniform vec3 bank_blade : source_color = vec3(0.465, 0.410, 0.325);
uniform vec3 bank_straw : source_color = vec3(0.620, 0.560, 0.440);
uniform vec3 bank_gravel : source_color = vec3(0.640, 0.590, 0.510);
uniform vec3 bank_stone : source_color = vec3(0.740, 0.700, 0.620);
uniform vec3 puddle_tint : source_color = vec3(0.30, 0.38, 0.50);

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
// The noise level above which water stands at marsh_floor_y.
const float WATER_LEVEL = 0.56;

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

void fragment() {
	vec2 p = UV * 10.0;
	// The family's own mix, with the map's recipes drawn over it.
	vec4 cover = texture(cover_map, (p - cover_map_rect.xy) * cover_map_rect.zw);
	float own = clamp(1.0 - (cover.r + cover.g + cover.b + cover.a), 0.0, 1.0);
	vec3 mix_settings = vec3(dry_threshold, bare_threshold, green_dryness) * own
		+ recipe_lawn * cover.r + recipe_straw * cover.g + recipe_dry_field * cover.b + recipe_bare * cover.a;
	float fade = smoothstep(fade_start_m, fade_end_m, length(VERTEX));
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
	if (marsh_amount > 0.0) {
		vec2 axis = marsh_axis.zw - marsh_axis.xy;
		vec2 from_start = p - marsh_axis.xy;
		float along_axis = clamp(dot(from_start, axis) / dot(axis, axis), 0.0, 1.0);
		float reach = length(from_start - axis * along_axis) + 26.0 * (value_noise(p / 29.0 + vec2(5.1, 77.7)) - 0.5);
		float region = (1.0 - smoothstep(marsh_radii.x, marsh_radii.y, reach)) * smoothstep(1.2, 1.6, ground_y) * marsh_amount;
		if (region > 0.0) {
			float n_mid = value_noise(p / 5.7 + vec2(23.7, 11.1));
			float n_small = mix(value_noise(p / 2.1 + vec2(3.3, 47.9)), 0.5, fade);
			float n_wide = value_noise(p / 23.0 + vec2(71.3, 37.9));
			float n_patch8 = value_noise(p / 8.0 + vec2(19.3, 83.1));
			float h = ground_y + 0.6 * (n_wide - 0.5) + 0.5 * (n_mid - 0.5) + 0.3 * (n_small - 0.5);

			vec3 bank = cover_layer(bank_gap, bank_blade, bank_straw, m, 0.8, fade);
			bank *= mix(0.74 + 0.52 * smoothstep(0.34, 0.66, 0.6 * n_mid + 0.4 * n_patch8), 1.0, fade);
			float gravel_w = 0.7 * smoothstep(3.4, 4.0, h) * smoothstep(0.52, 0.64, 0.55 * n_patch8 + 0.45 * n_small);
			bank = mix(bank, bank_gravel * (0.86 + 0.28 * n_small), gravel_w);
			float bank_w = 1.0 - smoothstep(3.95, 4.55, h);

			// Mats a few metres to a few tens across, every edge broken by finer noise.
			float mat_level = 0.4 * value_noise(p / 19.0 + vec2(7.3, 51.9)) + 0.33 * n_mid + 0.27 * n_small;
			float olive_w = smoothstep(0.54, 0.6, mat_level);
			float dark_w = 1.0 - smoothstep(0.37, 0.43, mat_level);
			float brown_w = smoothstep(0.5, 0.62, 0.55 * value_noise(p / 11.0 + vec2(61.3, 17.7)) + 0.45 * n_mid);
			float straw_w = smoothstep(0.6, 0.72, 0.5 * value_noise(p / 9.0 + vec2(37.1, 3.3)) + 0.5 * n_small);
			vec3 red = cover_layer(rust_gap, rust_blade, rust_straw, m, 0.6, fade);
			vec3 brown = marsh_brown * mix(0.72 + 0.56 * m.x, 1.0, fade);
			vec3 olive = marsh_olive * mix(0.72 + 0.56 * m.x, 1.0, fade);
			vec3 marsh = mix(mix(mix(red, brown, 0.65 * brown_w) * (1.0 - 0.35 * dark_w), olive, olive_w), bank, 0.5 * straw_w);
			float carpet = 1.0 - smoothstep(2.3, 2.85, h);

			ground = mix(ground, mix(bank, marsh, carpet), region * max(bank_w, carpet));

			// Pale stones in loose scatters, gone with distance.
			if (fade < 1.0) {
				vec2 stone_cell = floor(p / 1.3);
				vec2 inner = fract(p / 1.3) - 0.5;
				vec2 place = (vec2(hash12(stone_cell + vec2(7.1, 2.3)), hash12(stone_cell + vec2(1.7, 13.7))) - 0.5) * 0.7;
				float size = 0.03 + 0.05 * hash12(stone_cell + vec2(3.3, 9.1));
				float scatter = smoothstep(0.5, 0.66, 0.6 * value_noise(p / 15.0 + vec2(13.1, 29.3)) + 0.4 * n_mid);
				float stone = (1.0 - smoothstep(size * 0.7, size, length(inner - place))) * step(hash12(stone_cell + vec2(23.3, 5.9)), 0.6 * scatter);
				ground = mix(ground, bank_stone, stone * (1.0 - fade) * region * max(bank_w, carpet));
			}

			vec2 along = vec2(0.643 * p.x + 0.766 * p.y, 0.643 * p.y - 0.766 * p.x);
			float water = 0.5 * value_noise(along / vec2(19.0, 6.0) + vec2(3.7, 19.1)) + 0.34 * value_noise(along / vec2(8.0, 3.0) + vec2(41.3, 7.9)) + 0.16 * n_small;
			water -= WATER_LEVEL + 0.75 * (ground_y - marsh_floor_y);
			ground *= 1.0 - 0.45 * smoothstep(-0.05, 0.0, water) * region;
			pool = smoothstep(0.0, 0.012, water) * region;
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
		bare_w *= 1.0 - smoothstep(0.35, 0.65, m.x) * mix(1.0, 0.3, inside) * (1.0 - fade);
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
	}
	ALBEDO = mix(ground * (0.94 + 0.12 * n_fine), puddle_tint, pool);
	// Matte, with a gentle normal fade, so distant ground does not turn paler
	// than near ground through grazing-angle sky reflection or flatter normals;
	// standing water alone holds the sky.
	ROUGHNESS = mix(mix(clamp(texture(detail_roughness, uv_a).r, 0.85, 1.0), 1.0, fade), 0.05, pool);
	SPECULAR = mix(0.2, 0.5, pool);
	METALLIC = 0.45 * pool;
	NORMAL_MAP = texture(detail_normal, uv_a).rgb;
	NORMAL_MAP_DEPTH = normal_strength * (1.0 - 0.5 * fade) * (1.0 - pool);
}
