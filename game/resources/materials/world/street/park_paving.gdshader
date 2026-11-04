shader_type spatial;
// Painted concrete plazas of a park zone (tools/lib/street-ground-generation.mjs,
// park_plaza_* records): UV is the plaza's own frame in metres, x along its
// axis and y across it. pattern 0 draws broad zig-zag bands (Cityside's north
// BBQ plaza), pattern 1 interlocking rows of pointed leaf (vesica) shapes on
// charcoal, each row shifted half a leaf (its south event plaza; ph10, cmg14). Shapes are anti-aliased over one pixel's footprint, and a
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
// Leaves: one leaf's length (across the axis) and width (along it), and the gap
// between neighbours.
uniform float lens_length_m = 1.6;
uniform float lens_width_m = 0.6;
uniform float lens_gap_m = 0.1;
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
		// Rows of leaves lying across the plaza (cmg14); every other row shifts
		// half a leaf, so the points of one row meet the middles of the next. A
		// leaf is the overlap of two circles of radius r set (r - b) either side
		// of its long axis.
		vec2 q = p.yx;
		float pitch_x = lens_length_m + lens_gap_m;
		float pitch_y = lens_width_m + lens_gap_m;
		float row = floor(q.y / pitch_y);
		float along = q.x + mod(row, 2.0) * pitch_x * 0.5;
		vec2 local = (vec2(fract(along / pitch_x), fract(q.y / pitch_y)) - 0.5) * vec2(pitch_x, pitch_y);
		float a = lens_length_m * 0.5;
		float b = lens_width_m * 0.5;
		float r = (a * a + b * b) / (2.0 * b);
		float leaf = max(length(local - vec2(0.0, r - b)), length(local + vec2(0.0, r - b))) - r;
		color = mix(color_dark, color_light, cover(leaf, pixel));
	}
	float grain = texture(detail, p / detail_m).r;
	color *= 1.0 + (grain - 0.5) * detail_strength;
	ALBEDO = color;
	ROUGHNESS = 0.88;
}
