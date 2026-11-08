shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

// Yerba Buena Island's ground: non-playable context seen mostly from 300-1500 m.
// The YBI ground-cover map (generated/world/context.json ybi_ground_cover, drawn by
// tools/lib/ybi-context-generation.mjs from the 2026-05-26 aerial's cover classes and
// its rules) weighs four layers over a default of dry straw: red the dark ground under
// the trees and scrub, green the green grass, blue bare soil, sand and graded fill,
// alpha rock (cuts, cliffs and the wave-washed shore). The straw, lawn and soil
// palettes are Treasure Island's own (ground_cover.gdshader's), copied into this
// material at load (game/scripts/world/ybi_ground.gd), so both islands share one season.
// Steep faces (the shore's sides, cuts) turn to rock whatever the map says. Generated
// ground UVs are world XZ / 10.

uniform sampler2D detail_albedo : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D detail_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D cover_map : hint_default_black, filter_linear_mipmap, repeat_disable;
// x0, z0 and the inverse of the map's width and depth in metres.
uniform vec4 cover_map_rect = vec4(-180.0, 920.0, 0.000793651, 0.001041667);

uniform vec3 lawn_gap : source_color = vec3(0.233, 0.300, 0.112);
uniform vec3 lawn_blade : source_color = vec3(0.303, 0.394, 0.156);
uniform vec3 lawn_straw : source_color = vec3(0.378, 0.422, 0.212);
uniform vec3 dry_gap : source_color = vec3(0.399, 0.340, 0.239);
uniform vec3 dry_blade : source_color = vec3(0.459, 0.432, 0.264);
uniform vec3 dry_straw : source_color = vec3(0.637, 0.565, 0.418);
uniform vec3 soil_gap : source_color = vec3(0.500, 0.480, 0.400);
uniform vec3 soil_blade : source_color = vec3(0.400, 0.385, 0.320);
uniform vec3 soil_straw : source_color = vec3(0.600, 0.560, 0.440);
// The ground under the eucalyptus groves (leaf litter, ivy and shade) and the dark
// olive of the coyote brush and broom: the dark masses of the Sep 2025 and May 2025
// views from Treasure Island.
uniform vec3 forest_floor : source_color = vec3(0.105, 0.105, 0.072);
uniform vec3 forest_ivy : source_color = vec3(0.115, 0.15, 0.075);
uniform vec3 scrub_olive : source_color = vec3(0.17, 0.2, 0.1);
// Weathered grey-brown rock and shotcrete.
uniform vec3 rock_light : source_color = vec3(0.45, 0.43, 0.38);
uniform vec3 rock_dark : source_color = vec3(0.25, 0.24, 0.22);
// Share of the open grass drawn green rather than straw, in patches.
uniform float green_patches = 0.18;
// From grade_start_m to grade_end_m away the open grass deepens to the warm olive-gold
// and the groves and scrub to the near-black olive of the 2025-05-27 profile photo, as
// seen through the game's haze (about sRGB 86,81,44 and 49,50,35 there): the island's
// own pigment at a distance, not a change to the haze.
uniform vec3 far_grass_grade = vec3(0.8, 0.72, 0.42);
uniform vec3 far_dark_grade = vec3(0.7, 0.7, 0.55);
uniform vec3 far_rock_grade = vec3(0.78, 0.74, 0.66);
uniform float grade_start_m = 140.0;
uniform float grade_end_m = 900.0;
uniform float detail_repeat_m = 5.0;
uniform float normal_strength = 0.3;
uniform float fade_start_m = 25.0;
uniform float fade_end_m = 110.0;

// The sparse_grass detail's gap, blade and straw shares (ground_cover.gdshader).
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
	vec4 cover = texture(cover_map, (p - cover_map_rect.xy) * cover_map_rect.zw);
	float view_m = length(VERTEX);
	float fade = smoothstep(fade_start_m, fade_end_m, view_m);
	float n_patch = value_noise(p / 26.0);
	float n_mid = value_noise(p / 9.0 + vec2(13.1, 7.7));
	float n_fine = value_noise(p / 3.3 + vec2(5.3, 31.9));
	vec2 uv_a = p / detail_repeat_m;
	vec3 m = tuft_masks(texture(detail_albedo, uv_a).rgb);
	vec3 dry = cover_layer(dry_gap, dry_blade, dry_straw, m, 0.6, fade);
	vec3 lawn = cover_layer(lawn_gap, lawn_blade, lawn_straw, m, 0.25, fade);
	vec3 soil = cover_layer(soil_gap, soil_blade, soil_straw, m, 1.0, fade);
	// Open slopes: straw with patches going olive and green.
	float green_w = green_patches * smoothstep(0.45, 0.75, 0.7 * n_patch + 0.3 * n_mid);
	vec3 grass = mix(dry, mix(dry, lawn, 0.55), green_w * 2.0);
	vec3 green = mix(lawn, dry, 0.2 + 0.25 * n_mid);
	// Under the trees: litter and ivy in shade; scrub a dark olive.
	vec3 dark = mix(mix(forest_floor, forest_ivy, smoothstep(0.35, 0.7, n_mid)), scrub_olive, 0.35 * smoothstep(0.55, 0.85, n_fine));
	dark *= 0.9 + 0.2 * m.x * (1.0 - fade);
	vec3 rock = mix(rock_dark, rock_light, smoothstep(0.25, 0.75, 0.6 * n_fine + 0.4 * n_mid));
	float grade = smoothstep(grade_start_m, grade_end_m, view_m);
	grass *= mix(vec3(1.0), far_grass_grade, grade);
	green *= mix(vec3(1.0), far_grass_grade, grade * 0.6);
	dark *= mix(vec3(1.0), far_dark_grade, grade);
	rock *= mix(vec3(1.0), far_rock_grade, grade);
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
	float steep = 1.0 - smoothstep(0.42, 0.62, world_normal.y);
	float dry_w = clamp(1.0 - cover.r - cover.g - cover.b - cover.a, 0.0, 1.0);
	vec3 ground = grass * dry_w + green * cover.g + soil * cover.b + dark * cover.r + rock * cover.a;
	ground = mix(ground, rock, steep);
	ALBEDO = ground * (0.94 + 0.12 * n_fine);
	ROUGHNESS = 0.95;
	SPECULAR = 0.2;
	NORMAL_MAP = texture(detail_normal, uv_a).rgb;
	NORMAL_MAP_DEPTH = normal_strength * (1.0 - fade) * (1.0 - steep);
}
