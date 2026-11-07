shader_type spatial;
render_mode cull_disabled, diffuse_burley, specular_schlick_ggx;

// A photographed Yerba Buena Island building's coarse façade at L1 (game/scripts/world/
// ybi_detail_materials.gd sets each one's look from its dated photos): white render
// with dark window or balcony bands on each floor, broken into bays by light piers, over
// a board-formed concrete podium where the wall runs below the building's base. The
// generator measures the façade (tools/lib/ybi-context-generation.mjs, its storey
// height and each building's bay width): UV.x counts bays along each face, centred on
// it, and UV.y storeys above the base. Bands fade to their mean once they are finer
// than a pixel, so the far façade reads as a banded block without shimmering.

uniform vec3 wall_color : source_color = vec3(0.86, 0.85, 0.82);
uniform vec3 band_color : source_color = vec3(0.17, 0.18, 0.19);
uniform vec3 podium_color : source_color = vec3(0.58, 0.56, 0.52);
// The dark band's start and end within a storey, as fractions of it.
uniform float band_from = 0.3;
uniform float band_to = 0.86;
// The light pier's share of a bay.
uniform float pier_share = 0.24;
// Floors that carry bands; above them, the parapet.
uniform float floors = 6.0;
// The podium's vertical form-board ribs per bay.
uniform float ribs_per_bay = 16.0;

// The share of x's pixel footprint (width w, in periods) that falls in the band [a, b)
// of each unit period: the box-filtered pulse, and its mean once a period is finer
// than a pixel.
float pulse_integral(float t, float a, float b) {
	return floor(t) * (b - a) + clamp(fract(t), a, b) - a;
}

float band_cover(float x, float a, float b, float w) {
	float width = max(w, 1e-4);
	float cover = (pulse_integral(x + 0.5 * width, a, b) - pulse_integral(x - 0.5 * width, a, b)) / width;
	return mix(cover, b - a, smoothstep(0.5, 1.0, w));
}

void fragment() {
	float bay_x = UV.x;
	float storey_x = UV.y;
	// Derivatives first, outside the branches.
	float rib_x = bay_x * ribs_per_bay;
	float rib_w = fwidth(rib_x);
	float storey_w = fwidth(storey_x);
	float bay_w = fwidth(bay_x);
	vec3 color = wall_color;
	if (storey_x < 0.0) {
		float rib = mix(smoothstep(0.3, 0.5, abs(fract(rib_x) - 0.5)), 0.4, smoothstep(0.3, 0.8, rib_w));
		color = podium_color * (0.9 + 0.12 * rib);
	} else if (storey_x < floors) {
		float band = band_cover(storey_x, band_from, band_to, storey_w);
		float bay = band_cover(bay_x, pier_share * 0.5, 1.0 - pier_share * 0.5, bay_w);
		color = mix(wall_color, band_color, band * bay);
	}
	ALBEDO = color;
	ROUGHNESS = 0.82;
	SPECULAR = 0.35;
}
