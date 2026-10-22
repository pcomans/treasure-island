shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Island ground cover: maintained lawn, dry grass and bare soil from one set of
// existing CC0 Poly Haven sparse_grass maps. Each family material only changes
// how much of each layer it shows (game/scripts/world/ground_cover.gd).
//
// The albedo is read raw (no source_color) and split into a grass-tuft mask and
// a straw mask; the palettes below then supply the colour, so the photo's red
// soil never shows. Generated ground UVs are world XZ / 10.

uniform sampler2D detail_albedo : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D detail_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D detail_roughness : filter_linear_mipmap_anisotropic, repeat_enable;

// Late-spring palettes: gap (ground between tufts), blade (tufts), straw.
// The lawn colours match the dated March 2025 sunlit lawns under the SSE sun.
uniform vec3 lawn_gap : source_color = vec3(0.334, 0.41, 0.131);
uniform vec3 lawn_blade : source_color = vec3(0.431, 0.537, 0.182);
uniform vec3 lawn_straw : source_color = vec3(0.537, 0.575, 0.248);
uniform vec3 dry_gap : source_color = vec3(0.48, 0.42, 0.29);
uniform vec3 dry_blade : source_color = vec3(0.55, 0.53, 0.32);
uniform vec3 dry_straw : source_color = vec3(0.76, 0.69, 0.50);
uniform vec3 soil_gap : source_color = vec3(0.52, 0.45, 0.34);
uniform vec3 soil_blade : source_color = vec3(0.49, 0.44, 0.32);
uniform vec3 soil_straw : source_color = vec3(0.555, 0.485, 0.375);

// Family mix. A point turns dry where the patch noise exceeds dry_threshold and
// bare where the bare noise exceeds bare_threshold; above 1 disables a layer,
// below 0 fills the family with it. green_dryness pulls the green toward olive.
uniform float dry_threshold = 0.63;
uniform float bare_threshold = 2.0;
uniform float green_dryness = 0.0;
uniform float patch_scale_m = 24.0;
uniform float bare_scale_m = 23.0;
uniform float patch_softness = 0.08;

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

vec3 cover_layer(vec3 gap, vec3 blade, vec3 straw, vec3 m, float grain_gain, float fade) {
	vec3 detail = mix(mix(gap, blade, m.x), straw, m.y) * (1.0 + m.z * grain_gain);
	vec3 mean = gap * LAYER_SHARE.x + blade * LAYER_SHARE.y + straw * LAYER_SHARE.z;
	return mix(detail, mean, fade);
}

void fragment() {
	vec2 p = UV * 10.0;
	float n_patch = value_noise(p / patch_scale_m);
	float n_fine = value_noise(p / (patch_scale_m * 0.31) + vec2(17.31, 5.13));
	float n_blend = value_noise(p / 7.3 + vec2(3.71, 29.17));
	float patch_level = 0.65 * n_patch + 0.35 * n_fine;
	float dry_w = smoothstep(dry_threshold - patch_softness, dry_threshold + patch_softness, patch_level);
	float bare_w = 0.0;
	if (bare_threshold <= 1.0) {
		float bare = 0.7 * value_noise(p / bare_scale_m + vec2(41.7, 9.2)) + 0.3 * n_fine;
		bare_w = smoothstep(bare_threshold - patch_softness, bare_threshold + patch_softness, bare);
	}

	// Two detail samples at unrelated scales and angles hide the 5 m repeat.
	vec2 uv_a = p / detail_repeat_m;
	vec2 uv_b = mat2(vec2(0.799, 0.602), vec2(-0.602, 0.799)) * p / (detail_repeat_m * 2.71) + vec2(0.37, 0.71);
	vec3 m = mix(tuft_masks(texture(detail_albedo, uv_a).rgb), tuft_masks(texture(detail_albedo, uv_b).rgb), smoothstep(0.3, 0.7, n_blend));
	float fade = smoothstep(fade_start_m, fade_end_m, length(VERTEX));

	vec3 dry = cover_layer(dry_gap, dry_blade, dry_straw, m, 0.6, fade);
	vec3 green = mix(cover_layer(lawn_gap, lawn_blade, lawn_straw, m, 0.25, fade), dry, green_dryness);
	vec3 soil = cover_layer(soil_gap, soil_blade, soil_straw, m, 0.4, fade);
	ALBEDO = mix(mix(green, dry, dry_w), soil, bare_w) * (0.94 + 0.12 * n_fine);
	// Matte, with a gentle normal fade, so distant ground does not turn paler
	// than near ground through grazing-angle sky reflection or flatter normals.
	ROUGHNESS = mix(clamp(texture(detail_roughness, uv_a).r, 0.85, 1.0), 1.0, fade);
	SPECULAR = 0.2;
	METALLIC = 0.0;
	NORMAL_MAP = texture(detail_normal, uv_a).rgb;
	NORMAL_MAP_DEPTH = normal_strength * (1.0 - 0.5 * fade);
}
