shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
uniform bool eastern_blockout_cut = false;
uniform bool north_left_join = false;
uniform float sector_start_deg = 0.0;
uniform float art_waterline = 0.934;
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
uniform float atmosphere = 0.0;
uniform bool restore_bridge_cables = false;
uniform bool south_right_backing = false;
uniform bool western_blockout_cut = false;
uniform vec3 haze : source_color = vec3(0.60, 0.70, 0.78);
void fragment() {
	float geographic_bearing = mod(sector_start_deg + UV.x * 94.0, 360.0);
	if (eastern_blockout_cut && geographic_bearing >= 30.0 && geographic_bearing <= 135.0) { discard; }
	// Normal cutout depth keeps elevated water and all foreground geometry coherent.
	// Sample the compressed terrain per fragment on the unchanged cylinder.
	// Sparse top/bottom vertex tapering shears UVs across triangle diagonals.
	vec2 art_uv = UV;
	if (eastern_blockout_cut) {
		float scale_y = 1.0;
		if (geographic_bearing >= 20.0 && geographic_bearing <= 30.0) {
			scale_y = mix(1.0, 0.224874, smoothstep(20.0, 30.0, geographic_bearing));
		} else if (geographic_bearing >= 135.0 && geographic_bearing <= 145.0) {
			scale_y = mix(0.198708, 1.0, smoothstep(135.0, 145.0, geographic_bearing));
		}
		art_uv.y = art_waterline + (UV.y - art_waterline) / scale_y;
		if (art_uv.y < 0.0 || art_uv.y > 1.0) { discard; }
	}
	// SF urban overlap: lower only the legacy rear ridge, not the city card.
	// The mapped wooded coast owns everything beyond the existing232deg cut.
	if (south_right_backing && geographic_bearing >= 196.0 && geographic_bearing < 232.0) {
		float urban_weight = smoothstep(196.0, 201.0, geographic_bearing);
		float urban_scale = mix(1.0, 0.28, urban_weight);
		art_uv.y = art_waterline + (UV.y - art_waterline) / urban_scale;
		if (art_uv.y < 0.0 || art_uv.y > 1.0) { discard; }
	}
	// Physical Marin/North junction: shared10m top at14km, not an alpha-cut cliff.
	if (north_left_join && UV.x < 4.0 / 94.0) {
		float join_scale = mix(0.156356083, 1.0, smoothstep(0.0, 4.0 / 94.0, UV.x));
		art_uv.y = art_waterline + (UV.y - art_waterline) / join_scale;
		if (art_uv.y < 0.0 || art_uv.y > 1.0) { discard; }
	}
	vec4 color = texture(art, art_uv);
	// Registered SF northshore replaces the old south-sector western tail.
	if (western_blockout_cut && UV.x >= (232.0 - 155.882136) / 94.0) { discard; }
	// Land-only bank contours. Preserve existing visible bridge pixels.
	if (restore_bridge_cables) {
		vec2 land_px = UV * vec2(2172.0, 724.0);
		if (land_px.x >= 290.0 && land_px.x <= 302.0 && land_px.y > 664.0 && land_px.y <= 679.0 && color.a < 0.35) {
			// A short shore toe widens downward, sampled from this same bank.
			float toe = 10.0 * smoothstep(664.0, 677.0, land_px.y);
			vec4 shore = texture(art, vec2(land_px.x - toe, land_px.y) / vec2(2172.0, 724.0));
			float toe_edge = 1.0 - smoothstep(289.5 + toe, 290.5 + toe, land_px.x);
			shore.a *= toe_edge;
			if (shore.a > color.a) { color = shore; }
		} else if (land_px.x > 454.0 && land_px.x <= 470.0) {
			float upper_nose = 14.0 * (1.0 - smoothstep(646.0, 661.0, land_px.y));
			float bank_edge = 454.0 + upper_nose;
			color.a *= smoothstep(bank_edge - 0.5, bank_edge + 0.5, land_px.x);
		}
	}
	// West artwork's subpixel cable edge loses contrast under mip filtering.
	// Follow its existing tower tops/sag in native pixel space; no land fill.
	if (restore_bridge_cables) {
		vec2 p = UV * vec2(2172.0, 724.0);
		float cable_y = -100.0;
		if (p.x >= 290.0 && p.x < 326.0) {
			cable_y = 652.0 - 23.0 * pow((p.x - 290.0) / 36.0, 2.0);
		} else if (p.x >= 326.0 && p.x <= 414.0) {
			cable_y = 629.0 + 25.0 * (1.0 - pow((p.x - 370.0) / 44.0, 2.0));
		} else if (p.x > 414.0 && p.x <= 454.0) {
			cable_y = 652.0 - 23.0 * pow((454.0 - p.x) / 40.0, 2.0);
		}
		float aa = max(fwidth(p.y), 0.5);
		float cable = 1.0 - smoothstep(1.1, 1.1 + aa, abs(p.y - cable_y));
		color.rgb = mix(color.rgb, vec3(0.11697, 0.18782, 0.25818), cable);
		color.a = max(color.a, cable);
	}
	// Four-degree shared strips: no landmarks at edges; remove abrupt cut ends.
	// South supplies opaque land beneath west's left fade: avoid double-fade sky leak.
	float right_fade = south_right_backing ? 1.0 : smoothstep(0.0, 4.0 / 94.0, 1.0 - UV.x);
	float fade = smoothstep(0.0, 4.0 / 94.0, UV.x) * right_fade;
	if (north_left_join) { fade = right_fade; }
	// One distant atmosphere across regional sectors; source palette compensates it.
	float local_atmosphere = atmosphere;
	vec4 quiet = textureLod(art, art_uv, 2.0);
 vec3 detail_matched = mix(color.rgb, mix(quiet.rgb, color.rgb, 0.5), smoothstep(0.95, 0.99, quiet.a));
 detail_matched = mix(vec3(0.22), detail_matched, 0.78);
 ALBEDO = horizon_grade(mix(detail_matched, haze, local_atmosphere * 0.35), 8500.0);
	ALPHA = smoothstep(0.35, 0.65, color.a) * fade;
	ALPHA_SCISSOR_THRESHOLD = 0.5;
}
