shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Public-only painted cement stucco for Building 1's crescent, wings and
// pavilions. Existing CC0 Poly Haven plaster_grey_04 channels supply fine
// aggregate, pores and roughness breakup. Paint colour, physical span and the
// very low-contrast broad coating drift are reversible production inference;
// no shadow, dirt pattern or facade feature is baked into the surface.
//
// The same shader draws Building 1's material set (building_1_m_*.tres, the
// 2026-11-21 material study): board-formed painted concrete, its weathering,
// painted and bare metal, and opaque glass, each through uniforms below that
// default to off, so the materials above draw as before and the set adds no
// shader program to the web build's warm-up (one program, many materials). At
// coarse scales and low mips the plaster texture also supplies the smooth noise
// the patterns read. No light direction is drawn into any pattern: board joints,
// lips and wavy glass shade through the normal under whatever sun the day has,
// and weathering darkens the paint itself (dirt, algae, wash), not its lighting.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
// Fine linear detail (incised lines, the canopy fascia's rolls, dentils) as a
// greyscale multiplier over the paint, read with the mesh's UV; white where unset,
// so the plain stucco materials are unchanged. Mipmapped, it settles to the mean
// tone with distance instead of switching or shimmering.
uniform sampler2D detail_pattern : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.845, 0.8, 0.665, 1.0);
uniform float tile_span_m = 2.6;
uniform float relief_strength = 0.12;
uniform float grain_variation = 0.2;
uniform float broad_variation = 0.1;
uniform float roughness_base = 0.84;
uniform float roughness_variation = 0.12;
uniform vec2 roughness_range = vec2(0.45, 0.97);
// The surface's class: paint and stone are dielectric (0); bare bronze or brass
// is metal. SPECULAR 0.5 is Godot's default 4 % reflectance.
uniform float metallic_value = 0.0;
uniform float specular_value = 0.5;

// Board-formed concrete under the paint (the owner's 2026-11-20 photos: horizontal
// form-board lines on every painted wall). Rows board_pitch_m tall (0: off), boards
// of about board_length_m with staggered butt joints; each board its own small tone
// and tilt; shallow joints the paint has filled in places, so they read as broken
// lines. Detail fades to its mean where a board is only a few pixels tall, so it
// neither shimmers nor repeats at a distance.
uniform float board_pitch_m = 0.0;
uniform float board_length_m = 2.4;
uniform float board_tone = 0.0;
uniform float board_joint = 0.0;
uniform float board_joint_width = 0.05;
uniform float board_relief = 0.0;

// Weathering. weathering (0: off) scales it all. The plan-view map of the building
// (building_1_weathering_map.gd) gives, at a wall's plan position, the top of the
// mass behind it (R, metres), the lowest window sill above it (G, metres, 0 where
// none), the exposure of that part of the building (B: its paint's age and
// shelter, 0 to 1) and the ground at the wall's foot (A, metres); without a map
// (weathering_map_bounds.z == 0) every part is fully exposed and only the
// up-facing grime and the blotches apply.
uniform sampler2D weathering_map : filter_nearest, repeat_disable;
uniform vec4 weathering_map_bounds = vec4(0.0);
uniform float weathering = 0.0;
uniform vec4 grime_color : source_color = vec4(0.33, 0.34, 0.33, 1.0);
// The darkened coping and parapet band: top_band at the top, fading out by
// top_band_m below it, and a softer wash under it.
uniform float top_band = 0.0;
uniform float top_band_m = 0.5;
uniform float wash = 0.0;
// Rain streaks hanging from the top (and, shorter, from window sills).
uniform float streak_amount = 0.0;
uniform float streak_length_m = 2.5;
uniform float streak_spacing_m = 0.7;
uniform float sill_streak_amount = 0.0;
// Dirt and moss on up-facing tops (copings, sills, ledges).
uniform float up_grime = 0.0;
uniform vec4 moss_color : source_color = vec4(0.29, 0.30, 0.24, 1.0);
// Splash and dirt in the lowest base_splash_m above the ground.
uniform float base_splash = 0.0;
uniform float base_splash_m = 0.6;
// North- and east-facing faces stay damp longer: their weathering is scaled by
// 1 + north_east_bias at full facing, 1 - north_east_bias facing south-west.
uniform float north_east_bias = 0.0;
// Old paint is a little duller all over: albedo scaled by 1 - age_dim at full
// weathering.
uniform float age_dim = 0.0;

// Broad blotches over the surface: algae and dirt on old paint, verdigris on
// bronze. Applies with or without weathering.
uniform float mottle = 0.0;
uniform vec4 mottle_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float mottle_scale_m = 6.0;
uniform float mottle_metallic = 0.0;

// Wear near the ground (wear_height_m above the map's ground): the kick plates of
// a bronze door polished bright by feet.
uniform float wear = 0.0;
uniform vec4 wear_color : source_color = vec4(0.8, 0.66, 0.4, 1.0);
uniform float wear_height_m = 0.7;

// Opaque glass: wave_normal tilts the reflection gently, as old drawn glass does,
// and interior_amount shows soft pale bands of curtains and blinds behind it.
uniform float wave_normal = 0.0;
uniform float interior_amount = 0.0;
uniform vec4 interior_color : source_color = vec4(0.45, 0.44, 0.41, 1.0);

varying vec3 world_position;
varying vec3 world_normal;

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);
// The plaster texture's mean luminance (linear), around which its noise varies.
const float PLASTER_MEAN = 0.27;

float hash21(vec2 value) {
	vec3 p3 = fract(vec3(value.xyx) * vec3(0.1031, 0.1030, 0.0973));
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// Smooth noise around 0 (about -1 to 1) from a low mip of the plaster texture.
float soft_noise(vec2 position, float lod) {
	return (dot(textureLod(surface_color, position, lod).rgb, LUMA) - PLASTER_MEAN) * 28.0;
}

// Streaks hanging below a drip edge: along_m runs along the wall, below_m down
// from the edge. Columns spacing_m apart each hold one streak of its own width,
// strength and length, meandering gently as it runs down. A column narrower than a
// few pixels settles to its mean: along_fw is along_m's metres per pixel, taken by
// the caller outside any branch (derivatives inside one are undefined).
float streak_field(float along_m, float below_m, float spacing_m, float length_m, float salt, float along_fw) {
	float meander = soft_noise(vec2(along_m * 0.071 + salt, below_m * 0.043), 5.0) * 0.28;
	float c = along_m / spacing_m + meander;
	float ci = floor(c);
	float cf = c - ci;
	float width = mix(0.3, 0.8, hash21(vec2(ci, salt + 1.7)));
	float center = mix(0.5 * width, 1.0 - 0.5 * width, hash21(vec2(ci, salt + 9.2)));
	float across = abs(cf - center) / (0.5 * width);
	float profile = 1.0 - smoothstep(0.0, 1.0, across);
	float run = length_m * mix(0.18, 1.0, hash21(vec2(ci, salt + 4.4)));
	float body = 1.0 - smoothstep(run * 0.25, run, below_m);
	float strength = mix(0.25, 1.0, hash21(vec2(ci, salt + 2.9)));
	float streak = profile * body * strength;
	float mean = 0.26 * (1.0 - smoothstep(length_m * 0.15, length_m * 0.8, below_m));
	return mix(streak, mean, smoothstep(0.12, 0.35, along_fw / spacing_m));
}

// The boards of one row along s (metres): their tone and tilt (-0.5 to 0.5), how
// open the row's joint is here (0 where paint fills it), and a signed butt joint
// (its strength, + just past it along s). s_fw: s's metres per pixel, from outside
// any branch. Walls draw two of these, along world z and world x, blended by how the
// wall faces, so the pattern runs on unbroken round curved walls of many facets.
void board_pieces(float s, float s_fw, float row, float f, float joint_line, float salt, out float tone, out float tilt, out float open, out float butt) {
	float row_length = board_length_m * mix(0.6, 1.5, hash21(vec2(row, 3.17 + salt)));
	float along = s / row_length + hash21(vec2(row, 7.73 + salt)) * 7.0;
	float piece = floor(along);
	float g = along - piece;
	tone = hash21(vec2(row * 1.37, piece + salt)) - 0.5;
	tilt = hash21(vec2(piece + salt, row + 11.3)) - 0.5;
	open = smoothstep(-0.9, 0.3, soft_noise(vec2(s * 0.29 + salt, joint_line * 0.193), 4.0));
	float end_d = min(g, 1.0 - g) * row_length / board_pitch_m;
	butt = exp(-pow(end_d / (board_joint_width * 0.8), 2.0)) * step(0.85, hash21(vec2(piece, row + 5.1 + salt)));
	butt *= (1.0 - smoothstep(0.32, 0.46, abs(f - 0.5))) * smoothstep(4.0, 9.0, board_pitch_m / s_fw) * sign(g - 0.5);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	vec3 n = normalize(world_normal);
	// Face-aligned world-metre projection keeps one continuous phase across the
	// exact runs and applied modules, independent of their box UVs. V runs
	// downward so the OpenGL normal map's +Y stays world-up on walls.
	vec3 reference_axis = abs(n.y) > 0.8 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 uv = vec2(dot(world_position, t), -dot(world_position, b)) / tile_span_m;
	float grain = dot(texture(surface_color, uv).rgb, LUMA);
	// Broad drift reads a heavily filtered, rotated copy over tens of metres.
	vec2 broad_uv = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.083 + vec2(0.37, 0.61);
	float broad = dot(textureLod(surface_color, broad_uv, 7.0).rgb, LUMA);
	float variation = 1.0 + (grain - PLASTER_MEAN) * grain_variation + (broad - PLASTER_MEAN) * broad_variation * 6.0;
	vec3 albedo = paint_color.rgb * clamp(variation, 0.86, 1.1) * texture(detail_pattern, UV).rgb;
	float roughness = clamp(roughness_base + (texture(surface_roughness, uv).r - 0.5) * roughness_variation, roughness_range.x, roughness_range.y);
	float metallic = metallic_value;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	// The normal's tilt along t (across the face) and b (up a wall).
	vec2 slope = detail.xy * relief_strength;
	// Metres along a wall face, and how much of a wall this face is (1) rather
	// than a top or soffit (0).
	float along_m = dot(world_position, t);
	float wall = 1.0 - smoothstep(0.55, 0.8, abs(n.y));
	// Metres per pixel up the face and along world x and z, taken here, before any
	// branch.
	float height_fw = max(fwidth(world_position.y), 0.00001);
	float x_fw = max(fwidth(world_position.x), 0.00001);
	float z_fw = max(fwidth(world_position.z), 0.00001);
	// Patterns that run along a wall read world z on walls facing +-x and world x on
	// walls facing +-z, blended between: continuous across the facets of a curve,
	// where the face-aligned along_m jumps at every edge.
	vec2 run_w = vec2(n.x * n.x, n.z * n.z) / max(n.x * n.x + n.z * n.z, 0.0001);

	if (board_pitch_m > 0.0 && wall > 0.0) {
		float rows = world_position.y / board_pitch_m;
		float board_px = board_pitch_m / height_fw;
		float show_board = wall * smoothstep(2.0, 4.0, board_px);
		if (show_board > 0.0) {
			float row = floor(rows);
			float f = rows - row;
			// The joint where this row meets the next: e is 0 there, + above.
			float e = f < 0.5 ? f : f - 1.0;
			float joint_line = row + step(0.5, f);
			float x = e / board_joint_width;
			float groove = exp(-x * x);
			float tone_z; float tilt_z; float open_z; float butt_z;
			float tone_x; float tilt_x; float open_x; float butt_x;
			board_pieces(world_position.z, z_fw, row, f, joint_line, 0.0, tone_z, tilt_z, open_z, butt_z);
			board_pieces(world_position.x, x_fw, row, f, joint_line, 19.0, tone_x, tilt_x, open_x, butt_x);
			float tone = tone_z * run_w.x + tone_x * run_w.y;
			float tilt = tilt_z * run_w.x + tilt_x * run_w.y;
			// Where the paint has filled it the joint fades: a broken line.
			float open = open_z * run_w.x + open_x * run_w.y;
			// The butt joints' tilt along the face, as t runs along z or x.
			float butt = butt_z * run_w.x * sign(t.z + 0.0001) + butt_x * run_w.y * sign(t.x + 0.0001);
			float show_joint = wall * smoothstep(4.0, 9.0, board_px);
			albedo *= 1.0 + tone * board_tone * show_board;
			slope.y += tilt * board_relief * 0.15 * show_board;
			float cavity = max(groove * open, abs(butt_z) * run_w.x * 0.35 + abs(butt_x) * run_w.y * 0.35);
			albedo *= 1.0 - cavity * board_joint * show_joint;
			// The groove's walls face down above the joint and up below it.
			slope.y -= 2.0 * x * groove * open * board_relief * show_joint;
			slope.x += butt * board_relief * 0.5 * show_joint;
		}
	}

	float exposure = 1.0;
	float top_d = -1.0;
	float sill_d = -1.0;
	float ground_h = -1.0;
	if (weathering_map_bounds.z > 0.0 && (weathering > 0.0 || wear > 0.0)) {
		vec2 into = wall > 0.5 ? normalize(n.xz) : vec2(0.0);
		vec4 behind = textureLod(weathering_map, (world_position.xz - into * 0.35 - weathering_map_bounds.xy) / weathering_map_bounds.zw, 0.0);
		vec4 at = textureLod(weathering_map, (world_position.xz - into * 0.12 - weathering_map_bounds.xy) / weathering_map_bounds.zw, 0.0);
		top_d = behind.r > 0.0 ? behind.r - world_position.y : -1.0;
		sill_d = at.g > 0.0 ? at.g - world_position.y : -1.0;
		ground_h = at.a > 0.0 ? world_position.y - at.a : -1.0;
		exposure = max(behind.b, at.b);
	}

	if (mottle > 0.0) {
		vec2 m_z = vec2(world_position.z, world_position.y) / mottle_scale_m;
		vec2 m_x = vec2(world_position.x, world_position.y) / mottle_scale_m;
		float blot_z = soft_noise(m_z * 0.37 + vec2(0.13, 0.71), 3.0) * 0.65 + soft_noise(m_z * 1.13 + vec2(0.57, 0.29), 2.0) * 0.35;
		float blot_x = soft_noise(m_x * 0.37 + vec2(0.41, 0.17), 3.0) * 0.65 + soft_noise(m_x * 1.13 + vec2(0.23, 0.83), 2.0) * 0.35;
		// Tops and soffits read their plan position.
		float blot = wall > 0.0 ? blot_z * run_w.x + blot_x * run_w.y : soft_noise(world_position.xz / mottle_scale_m * 0.37, 3.0);
		// On walls the blotches gather under the top, where the water runs longest.
		float upper = top_d > -0.05 ? mix(0.3, 1.0, exp(-max(top_d, 0.0) / 5.0)) : 1.0;
		float mask = smoothstep(0.1, 0.75, blot) * mottle * (weathering > 0.0 ? exposure : 1.0) * upper;
		albedo = mix(albedo, mottle_color.rgb * (0.85 + 0.3 * smoothstep(-1.0, 1.0, blot)), mask);
		metallic = mix(metallic, mottle_metallic, mask);
		roughness = mix(roughness, max(roughness, 0.7), mask);
	}

	if (weathering > 0.0) {
		float facing = wall * dot(normalize(n.xz + vec2(0.0001, 0.0)), vec2(0.6, -0.8));
		float amount = weathering * exposure * max(0.0, 1.0 + north_east_bias * facing);
		albedo *= 1.0 - age_dim * clamp(amount, 0.0, 1.0);
		float dirt = 0.0;
		if (top_d > -0.05) {
			float below = max(top_d, 0.0);
			dirt += top_band * (1.0 - smoothstep(top_band_m * 0.45, top_band_m, below));
			dirt += wash * exp(-below / max(top_band_m * 3.0, 0.1)) * wall;
			dirt += streak_amount * (streak_field(world_position.z, below, streak_spacing_m, streak_length_m, 0.0, z_fw) * run_w.x + streak_field(world_position.x, below, streak_spacing_m, streak_length_m, 7.0, x_fw) * run_w.y) * wall;
		}
		if (sill_d > 0.0 && wall > 0.5) {
			dirt += sill_streak_amount * (streak_field(world_position.z * 1.3 + 17.0, sill_d, streak_spacing_m * 0.55, streak_length_m * 0.3, 5.0, z_fw * 1.3) * run_w.x + streak_field(world_position.x * 1.3 + 17.0, sill_d, streak_spacing_m * 0.55, streak_length_m * 0.3, 11.0, x_fw * 1.3) * run_w.y);
		}
		if (ground_h >= 0.0 && base_splash > 0.0) {
			float splash = 1.0 - smoothstep(base_splash_m * 0.3, base_splash_m, ground_h);
			dirt += base_splash * splash * (0.7 + 0.3 * smoothstep(-1.0, 1.0, soft_noise(vec2(world_position.x + world_position.z, world_position.y) * 0.9, 1.0))) * wall;
		}
		dirt = clamp(dirt * amount, 0.0, 0.88);
		albedo = mix(albedo, grime_color.rgb * (0.85 + 0.3 * smoothstep(-1.0, 1.0, soft_noise(vec2(world_position.x + world_position.z, world_position.y) * 0.31, 2.0))), dirt);
		roughness = min(roughness + 0.08 * dirt, 0.97);
		float up = smoothstep(0.5, 0.85, n.y);
		if (up > 0.0 && up_grime > 0.0) {
			float tufts = smoothstep(-0.6, 0.6, soft_noise(world_position.xz * 0.37, 2.0));
			float moss = clamp(up_grime * up * weathering * mix(1.0, exposure, 0.5) * (0.55 + 0.45 * tufts), 0.0, 0.9);
			albedo = mix(albedo, moss_color.rgb, moss);
			roughness = mix(roughness, 0.95, moss);
		}
	}

	if (wear > 0.0 && ground_h >= 0.0) {
		float worn = wear * (1.0 - smoothstep(wear_height_m * 0.75, wear_height_m, ground_h));
		albedo = mix(albedo, wear_color.rgb, worn);
		metallic = mix(metallic, 1.0, worn);
		roughness = mix(roughness, max(roughness - 0.2, roughness_range.x), worn);
	}

	if (wave_normal > 0.0) {
		// Two smooth noises as the tilt's two components, varying over a few tenths
		// of a metre: each pane reflects a little differently.
		vec2 p = vec2(along_m, world_position.y) * 0.25;
		slope += vec2(soft_noise(p + vec2(0.13, 0.57), 4.0), soft_noise(p.yx + vec2(0.71, 0.29), 4.0)) * wave_normal;
	}
	if (interior_amount > 0.0) {
		// Curtains and blinds hang: soft vertical bands of their own widths along the
		// glass, here and there, with dark room between.
		float folds = soft_noise(vec2(along_m * 0.6 + 0.71, 0.23), 3.0);
		float curtain = smoothstep(0.05, 0.55, folds) * (0.75 + 0.25 * smoothstep(-1.0, 1.0, soft_noise(vec2(along_m * 2.3, world_position.y * 0.4), 2.0)));
		albedo = mix(albedo, interior_color.rgb, interior_amount * curtain);
	}

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular_value;
	vec3 perturbed = normalize(n + t * slope.x + b * slope.y);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
