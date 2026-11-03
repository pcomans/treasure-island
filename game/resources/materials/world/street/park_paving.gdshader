shader_type spatial;
// Painted concrete plazas of a park zone (tools/lib/street-ground-generation.mjs,
// park_plaza_* records): UV is the plaza's own frame in metres, x along its
// axis and y across it. pattern 0 draws broad zig-zag bands (Cityside's north
// BBQ plaza), pattern 1 rows of split half-oval lenses on charcoal (its south
// event plaza). Shapes are anti-aliased over one pixel's footprint, and a
// concrete detail map breaks up the flat paint. Production inference for game
// art from the dated photos, not a measured layout.

uniform int pattern = 0;
uniform vec3 color_light : source_color = vec3(0.86, 0.86, 0.84);
uniform vec3 color_mid : source_color = vec3(0.62, 0.63, 0.62);
uniform vec3 color_dark : source_color = vec3(0.25, 0.25, 0.26);
// Zig-zag: band period along the axis, the zig period across it and how far a
// band swings along the axis over half a zig (metres).
uniform float band_m = 5.0;
uniform float zig_m = 7.0;
uniform float swing_m = 3.5;
// Lenses: one lens's length (across the axis) and width (along it), and the gap.
uniform float lens_length_m = 2.1;
uniform float lens_width_m = 0.95;
uniform float lens_gap_m = 0.07;
uniform sampler2D detail : hint_default_white, filter_linear_mipmap, repeat_enable;
uniform float detail_m = 2.5;
uniform float detail_strength = 0.18;

float tri_wave(float x) {
	return abs(fract(x) - 0.5) * 4.0 - 1.0;
}

// Coverage of an edge at signed distance d (metres) over a footprint w.
float cover(float d, float w) {
	return clamp(0.5 - d / max(w, 1e-5), 0.0, 1.0);
}

void fragment() {
	vec2 p = UV;
	float pixel = max(length(fwidth(p)), 1e-4);
	vec3 color;
	if (pattern == 0) {
		float w = p.x + swing_m * tri_wave(p.y / zig_m);
		float t = fract(w / band_m) * band_m;
		// White, light grey and charcoal bands of uneven width in each period.
		float white_end = band_m * 0.24;
		float mid_end = band_m * 0.58;
		float to_white = min(t, white_end - t);
		float to_mid = min(t - white_end, mid_end - t);
		float edge = pixel * (1.0 + swing_m / zig_m);
		float in_white = cover(-to_white, edge);
		float in_mid = cover(-to_mid, edge) * (1.0 - in_white);
		color = mix(color_dark, color_mid, in_mid);
		color = mix(color, color_light, in_white);
	} else {
		// Rows of lenses along the axis; every other row shifts half a lens.
		float row = floor(p.x / lens_width_m);
		float across = p.y + mod(row, 2.0) * lens_length_m * 0.5;
		vec2 local = vec2(fract(across / lens_length_m) - 0.5, fract(p.x / lens_width_m) - 0.5) * vec2(lens_length_m, lens_width_m);
		vec2 radii = vec2(lens_length_m, lens_width_m) * 0.5 - vec2(lens_gap_m);
		float ellipse = (length(local / radii) - 1.0) * min(radii.x, radii.y);
		float split = lens_gap_m * 0.5 - abs(local.x);
		float inside = cover(ellipse, pixel) * cover(split, pixel);
		color = mix(color_dark, color_light, inside);
	}
	float grain = texture(detail, p / detail_m).r;
	color *= 1.0 + (grain - 0.5) * detail_strength;
	ALBEDO = color;
	ROUGHNESS = 0.88;
}
