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
// shader program to the web build's warm-up (one program, many materials). No
// light direction is drawn into any pattern: board joints and pane tilts shade
// through the normal under whatever sun the day has, and weathering changes the
// paint itself (dirt, algae, wash), not its lighting. The smooth noise the
// patterns read is a small mip of the plaster texture, scaled to each pattern's
// own feature size (noise_m).
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
// The plaster read on world axes instead of the face's own: walls along world z
// where they face x and along x where they face z, tops on x and z, blended between.
// The face's own axes turn with its smoothed normal, and on a curved wall far from
// the world's origin that slides the texture by metres within one facet, smearing
// it into vertical streaks; world axes do not move.
uniform bool world_axis_projection = false;

// Board-formed concrete under the paint (the owner's 2026-11-20 photos: horizontal
// form-board lines on every painted wall). Rows about board_pitch_m tall (0: off),
// their heights varying by board_pitch_variation of it; boards of about
// board_length_m whose ends are staggered from row to row, board_butt_share of them
// showing; each board its own small tone; shallow joints the paint has filled in
// places, so they read as broken lines. Detail fades to its mean where a board is
// only a few pixels tall, so it neither shimmers nor repeats at a distance.
uniform float board_pitch_m = 0.0;
uniform float board_pitch_variation = 0.0;
uniform float board_length_m = 2.4;
uniform float board_butt_share = 0.15;
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
// The even grey band under a coping (top_band, fading out by top_band_m below the
// top) and the soft wash below it (wash, fading out over four times that), both in
// band_color.
uniform vec4 band_color : source_color = vec4(0.56, 0.57, 0.55, 1.0);
uniform float top_band = 0.0;
uniform float top_band_m = 0.5;
uniform float wash = 0.0;
// Thin, straight rain streaks hanging from a top (and, shorter, from window sills),
// in streak_color: only where the exposure is above streak_min_exposure and only
// from tops at least streak_min_top_m high (a parapet, not a mid-height ledge).
uniform vec4 streak_color : source_color = vec4(0.45, 0.46, 0.44, 1.0);
uniform float streak_amount = 0.0;
uniform float streak_length_m = 1.2;
uniform float streak_spacing_m = 0.6;
uniform float streak_min_exposure = 0.4;
uniform float streak_min_top_m = 0.0;
uniform float sill_streak_amount = 0.0;
// An even film of dirt and moss on up-facing tops (copings, sills, ledges).
uniform float up_grime = 0.0;
uniform vec4 moss_color : source_color = vec4(0.47, 0.49, 0.43, 1.0);
// Splash and dirt in the lowest base_splash_m above the ground.
uniform float base_splash = 0.0;
uniform float base_splash_m = 0.6;
// North- and east-facing faces stay damp longer: their weathering is scaled by
// 1 + north_east_bias at full facing, 1 - north_east_bias facing south-west.
uniform float north_east_bias = 0.0;
// Old paint is a little duller all over: albedo scaled by 1 - age_dim at full
// weathering.
uniform float age_dim = 0.0;

// Broad soft blotches over the surface, about mottle_scale_m across: algae and dirt
// on old paint, patina on bronze. Applies with or without weathering.
uniform float mottle = 0.0;
uniform vec4 mottle_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform float mottle_scale_m = 3.0;
uniform float mottle_metallic = 0.0;

// Wear near the ground (below wear_height_m above the map's ground): the kick
// plates of a bronze door polished bright by feet, darker at their worn edges.
uniform float wear = 0.0;
uniform vec4 wear_color : source_color = vec4(0.8, 0.66, 0.4, 1.0);
uniform vec4 wear_edge_color : source_color = vec4(0.3, 0.24, 0.15, 1.0);
uniform float wear_height_m = 0.7;

// Opaque glass panes. The mesh's UV2 holds each pane's own coordinates: x = the
// pane's seed (1 or more) + u across it, y = its kind + v up it (kind 1: a dark
// room, 2: a blind drawn down from the top, 3: sheers gathered to both sides);
// (0, 0) where a mesh has none, and then panes draw plain. Each pane tilts by up to
// pane_tilt, so old glass reflects a little differently pane to pane, and shows
// its blind or sheers in interior_color at up to interior_amount.
uniform float pane_tilt = 0.0;
uniform float interior_amount = 0.0;
uniform vec4 interior_color : source_color = vec4(0.82, 0.82, 0.79, 1.0);

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

// Smooth noise round 0 (spread about 1) with features about feature_m across: the
// plaster texture's 32 x 32 mip, one texel a feature, repeating every 32 features.
float noise_m(vec2 position_m, float feature_m) {
	return (dot(textureLod(surface_color, position_m / (32.0 * feature_m), 5.0).rgb, LUMA) - PLASTER_MEAN) * 28.0;
}

// Thin straight streaks hanging below a drip edge: s runs along the wall (metres),
// below_m down from the edge. Columns spacing_m apart hold at most one streak each,
// of its own width (a tenth to a quarter of the column), strength and length; where
// a streak is narrower than about three pixels (s_fw: metres per pixel along the
// wall) the field settles to its mean, a soft even shade.
float streak_field(float s, float below_m, float spacing_m, float length_m, float salt, float s_fw) {
	float c = s / spacing_m;
	float ci = floor(c);
	float cf = c - ci;
	float width = mix(0.1, 0.25, hash21(vec2(ci, salt + 1.7)));
	float center = mix(0.5 * width, 1.0 - 0.5 * width, hash21(vec2(ci, salt + 9.2)));
	float across = abs(cf - center) / (0.5 * width);
	float profile = 1.0 - smoothstep(0.25, 1.0, across);
	float run = length_m * mix(0.35, 1.0, hash21(vec2(ci, salt + 4.4)));
	float body = 1.0 - smoothstep(run * 0.5, run, below_m);
	float strength = step(0.4, hash21(vec2(ci, salt + 6.1))) * mix(0.5, 1.0, hash21(vec2(ci, salt + 2.9)));
	float mean = 0.06 * (1.0 - smoothstep(length_m * 0.2, length_m * 0.8, below_m));
	return mix(profile * body * strength, mean, smoothstep(0.35, 1.0, s_fw / (spacing_m * 0.12)));
}

// One world-axis projection of the plaster: its luminance, roughness, normal tilt
// and broad drift, read with explicit gradients so that a branch may take it.
void plaster_at(vec2 uv, vec2 ddx, vec2 ddy, out float lum, out float rough, out vec2 tilt, out float broad) {
	lum = dot(textureGrad(surface_color, uv, ddx, ddy).rgb, LUMA);
	rough = textureGrad(surface_roughness, uv, ddx, ddy).r;
	tilt = textureGrad(surface_normal, uv, ddx, ddy).rg * 2.0 - 1.0;
	// Broad drift reads a heavily filtered, rotated copy over tens of metres.
	vec2 broad_uv = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.083 + vec2(0.37, 0.61);
	broad = dot(textureLod(surface_color, broad_uv, 7.0).rgb, LUMA);
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
	// Every derivative is taken here, before any branch (inside one they are
	// undefined): metres per pixel up the face and along world x and z, and the
	// world-axis projections' gradients.
	float height_fw = max(fwidth(world_position.y), 0.00001);
	float x_fw = max(fwidth(world_position.x), 0.00001);
	float z_fw = max(fwidth(world_position.z), 0.00001);
	vec2 uv_z = vec2(world_position.z, -world_position.y) / tile_span_m;
	vec2 uv_x = vec2(world_position.x, -world_position.y) / tile_span_m + vec2(0.43, 0.17);
	vec2 uv_y = vec2(world_position.z, -world_position.x) / tile_span_m + vec2(0.71, 0.29);
	vec2 uv_z_dx = dFdx(uv_z);
	vec2 uv_z_dy = dFdy(uv_z);
	vec2 uv_x_dx = dFdx(uv_x);
	vec2 uv_x_dy = dFdy(uv_x);
	vec2 uv_y_dx = dFdx(uv_y);
	vec2 uv_y_dy = dFdy(uv_y);
	// How much of a wall this face is (1) rather than a top or soffit (0), and how
	// much a wall runs along world z (1: it faces x) rather than x (0).
	float wall = 1.0 - smoothstep(0.55, 0.8, abs(n.y));
	float along_z = n.x * n.x / max(n.x * n.x + n.z * n.z, 0.0001);
	// Metres along the wall on the world axis it mostly runs along: continuous over a
	// facet and round a curve, stepping only where a curve turns through 45 degrees.
	bool runs_z = along_z >= 0.5;
	float s = runs_z ? world_position.z : world_position.x;
	float s_fw = runs_z ? z_fw : x_fw;

	float grain;
	float broad;
	float rough_sample;
	vec2 tilt;
	if (world_axis_projection) {
		float wy = smoothstep(0.55, 0.8, abs(n.y));
		float wz = (1.0 - wy) * smoothstep(0.3, 0.7, along_z);
		float wx = 1.0 - wy - wz;
		// Two independent samples mixed half and half lose contrast: dividing by the
		// weights' length keeps it.
		float keep = 1.0 / max(length(vec3(wx, wy, wz)), 0.0001);
		float lum;
		float rough;
		vec2 tl;
		float br;
		grain = 0.0;
		broad = 0.0;
		rough_sample = 0.0;
		tilt = vec2(0.0);
		if (wz > 0.0) {
			plaster_at(uv_z, uv_z_dx, uv_z_dy, lum, rough, tl, br);
			grain += (lum - PLASTER_MEAN) * wz;
			rough_sample += (rough - 0.5) * wz;
			tilt += tl * wz;
			broad += (br - PLASTER_MEAN) * wz;
		}
		if (wx > 0.0) {
			plaster_at(uv_x, uv_x_dx, uv_x_dy, lum, rough, tl, br);
			grain += (lum - PLASTER_MEAN) * wx;
			rough_sample += (rough - 0.5) * wx;
			tilt += tl * wx;
			broad += (br - PLASTER_MEAN) * wx;
		}
		if (wy > 0.0) {
			plaster_at(uv_y, uv_y_dx, uv_y_dy, lum, rough, tl, br);
			grain += (lum - PLASTER_MEAN) * wy;
			rough_sample += (rough - 0.5) * wy;
			tilt += tl * wy;
			broad += (br - PLASTER_MEAN) * wy;
		}
		grain = PLASTER_MEAN + grain * keep;
		broad = PLASTER_MEAN + broad * keep;
		rough_sample = 0.5 + rough_sample * keep;
		tilt *= keep;
	} else {
		vec2 uv = vec2(dot(world_position, t), -dot(world_position, b)) / tile_span_m;
		grain = dot(texture(surface_color, uv).rgb, LUMA);
		// Broad drift reads a heavily filtered, rotated copy over tens of metres.
		vec2 broad_uv = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8)) * uv * 0.083 + vec2(0.37, 0.61);
		broad = dot(textureLod(surface_color, broad_uv, 7.0).rgb, LUMA);
		rough_sample = texture(surface_roughness, uv).r;
		tilt = (texture(surface_normal, uv).rgb * 2.0 - 1.0).xy;
	}
	float variation = 1.0 + (grain - PLASTER_MEAN) * grain_variation + (broad - PLASTER_MEAN) * broad_variation * 6.0;
	vec3 albedo = paint_color.rgb * clamp(variation, 0.86, 1.1) * texture(detail_pattern, UV).rgb;
	float roughness = clamp(roughness_base + (rough_sample - 0.5) * roughness_variation, roughness_range.x, roughness_range.y);
	float metallic = metallic_value;
	// The normal's tilt along t (across the face) and b (up a wall).
	vec2 slope = tilt * relief_strength;

	if (board_pitch_m > 0.0 && wall > 0.0) {
		// Rows of varied height: the row coordinate is warped along the height only,
		// so every joint stays a level line.
		float warp = noise_m(vec2(world_position.y, 3.7), 0.45) * board_pitch_variation * board_pitch_m;
		float rows = (world_position.y + warp) / board_pitch_m;
		float board_px = board_pitch_m / height_fw;
		float show_board = wall * smoothstep(2.0, 4.0, board_px);
		if (show_board > 0.0) {
			float row = floor(rows);
			float f = rows - row;
			// The boards of this row along the wall, each row's ends staggered.
			float row_length = board_length_m * mix(0.6, 1.5, hash21(vec2(row, 3.17)));
			float along = s / row_length + hash21(vec2(row, 7.73)) * 7.0;
			float piece = floor(along);
			float g = along - piece;
			float tone = hash21(vec2(row * 1.37, piece)) - 0.5;
			albedo *= 1.0 + tone * board_tone * show_board;
			// The joint where this row meets the next: e is 0 there, + above.
			float e = f < 0.5 ? f : f - 1.0;
			float joint_line = row + step(0.5, f);
			float x = e / board_joint_width;
			float groove = exp(-x * x);
			// Where the paint has filled it the joint fades: a line broken in places.
			float open = smoothstep(-0.6, 0.4, noise_m(vec2(s, joint_line * 0.9), 0.7));
			float show_joint = wall * smoothstep(6.0, 14.0, board_px);
			// Butt joints at the boards' ends, some of them showing.
			float end_d = min(g, 1.0 - g) * row_length / board_pitch_m;
			float butt = exp(-pow(end_d / (board_joint_width * 0.8), 2.0)) * step(1.0 - board_butt_share, hash21(vec2(piece, row + 5.1)));
			butt *= (1.0 - smoothstep(0.32, 0.46, abs(f - 0.5))) * smoothstep(4.0, 9.0, board_pitch_m / s_fw);
			float cavity = max(groove * open, butt * 0.35);
			albedo *= 1.0 - cavity * board_joint * show_joint;
			// The groove's walls face down above the joint and up below it.
			slope.y -= 2.0 * x * groove * open * board_relief * show_joint;
		}
	}

	float exposure = 1.0;
	float top_y = -1.0;
	float top_d = -1.0;
	float sill_d = -1.0;
	float ground_h = -1.0;
	if (weathering_map_bounds.z > 0.0 && (weathering > 0.0 || wear > 0.0)) {
		vec2 into = wall > 0.5 ? normalize(n.xz) : vec2(0.0);
		vec4 behind = textureLod(weathering_map, (world_position.xz - into * 0.35 - weathering_map_bounds.xy) / weathering_map_bounds.zw, 0.0);
		vec4 at = textureLod(weathering_map, (world_position.xz - into * 0.12 - weathering_map_bounds.xy) / weathering_map_bounds.zw, 0.0);
		top_y = behind.r;
		top_d = behind.r > 0.0 ? behind.r - world_position.y : -1.0;
		sill_d = at.g > 0.0 ? at.g - world_position.y : -1.0;
		ground_h = at.a > 0.0 ? world_position.y - at.a : -1.0;
		exposure = max(behind.b, at.b);
	}

	if (mottle > 0.0) {
		// Two noises along the wall's two world axes, blended by its facing, so the
		// blotches run unbroken round a curve; tops read their plan position.
		vec2 pz = vec2(world_position.z, world_position.y);
		vec2 px = vec2(world_position.x, world_position.y) + vec2(37.0, 11.0);
		float blot_z = noise_m(pz, mottle_scale_m) * 0.7 + noise_m(pz + vec2(5.3, 2.9), mottle_scale_m * 0.35) * 0.3;
		float blot_x = noise_m(px, mottle_scale_m) * 0.7 + noise_m(px + vec2(5.3, 2.9), mottle_scale_m * 0.35) * 0.3;
		float blot = wall > 0.0 ? mix(blot_x, blot_z, smoothstep(0.3, 0.7, along_z)) : noise_m(world_position.xz, mottle_scale_m);
		// On walls the blotches gather under the top, where the water runs longest,
		// and they belong to old, exposed paint: they fall away fast with exposure.
		float upper = top_d > -0.05 ? mix(0.15, 1.0, exp(-max(top_d, 0.0) / 5.0)) : 1.0;
		float mask = smoothstep(0.1, 0.75, blot) * mottle * (weathering > 0.0 ? exposure * exposure : 1.0) * upper;
		albedo = mix(albedo, mottle_color.rgb, mask);
		metallic = mix(metallic, mottle_metallic, mask);
		roughness = mix(roughness, max(roughness, 0.7), mask);
	}

	if (weathering > 0.0) {
		float facing = wall * dot(normalize(n.xz + vec2(0.0001, 0.0)), vec2(0.6, -0.8));
		float amount = weathering * exposure * max(0.0, 1.0 + north_east_bias * facing);
		albedo *= 1.0 - age_dim * clamp(amount, 0.0, 1.0);
		float band = 0.0;
		float streak = 0.0;
		if (top_d > -0.05) {
			float below = max(top_d, 0.0);
			band = top_band * (1.0 - smoothstep(top_band_m * 0.5, top_band_m, below));
			band += wash * (1.0 - smoothstep(0.0, top_band_m * 4.0, below)) * wall;
			if (top_y >= streak_min_top_m) {
				streak = streak_amount * streak_field(s, below, streak_spacing_m, streak_length_m, 0.0, s_fw) * wall;
			}
		}
		if (sill_d > 0.0 && wall > 0.5) {
			streak += sill_streak_amount * streak_field(s + 17.0, sill_d, streak_spacing_m * 0.6, streak_length_m * 0.4, 5.0, s_fw);
		}
		streak *= smoothstep(streak_min_exposure, streak_min_exposure + 0.3, exposure);
		if (ground_h >= 0.0 && base_splash > 0.0) {
			float splash = 1.0 - smoothstep(base_splash_m * 0.3, base_splash_m, ground_h);
			band += base_splash * splash * (0.75 + 0.25 * smoothstep(-1.0, 1.0, noise_m(vec2(s, world_position.y), 0.3))) * wall;
		}
		band = clamp(band * amount, 0.0, 0.85);
		albedo = mix(albedo, band_color.rgb, band);
		streak = clamp(streak * amount, 0.0, 0.7);
		albedo = mix(albedo, streak_color.rgb, streak);
		roughness = min(roughness + 0.08 * max(band, streak), 0.97);
		float up = smoothstep(0.5, 0.85, n.y);
		if (up > 0.0 && up_grime > 0.0) {
			float film = clamp(up_grime * up * weathering * mix(1.0, exposure, 0.5), 0.0, 0.85);
			albedo = mix(albedo, moss_color.rgb, film);
			roughness = mix(roughness, 0.95, film);
		}
	}

	if (wear > 0.0 && ground_h >= 0.0) {
		float worn = wear * (1.0 - smoothstep(wear_height_m - 0.015, wear_height_m, ground_h));
		// The worn edges, darker: a band at the plate's top and one at its foot.
		float edge = max(1.0 - smoothstep(0.02, 0.07, wear_height_m - ground_h), 1.0 - smoothstep(0.02, 0.06, ground_h));
		albedo = mix(albedo, mix(wear_color.rgb, wear_edge_color.rgb, edge), worn);
		metallic = mix(metallic, 1.0, worn);
		roughness = mix(roughness, mix(max(roughness - 0.2, roughness_range.x), roughness, edge), worn);
	}

	if (pane_tilt > 0.0 || interior_amount > 0.0) {
		float seed = floor(UV2.x);
		if (seed >= 1.0) {
			float pu = fract(UV2.x);
			float kind = floor(UV2.y);
			float pv = fract(UV2.y);
			slope += (vec2(hash21(vec2(seed, 1.3)), hash21(vec2(seed, 7.9))) - 0.5) * 2.0 * pane_tilt;
			float panel = 0.0;
			if (kind > 1.5 && kind < 2.5) {
				// A blind drawn down from the top to its own depth.
				float depth = mix(0.2, 0.75, hash21(vec2(seed, 3.1)));
				panel = smoothstep(1.0 - depth - 0.03, 1.0 - depth + 0.03, pv);
			} else if (kind > 2.5 && kind < 3.5) {
				// Sheers gathered to both sides, soft at their inner edges.
				float side = mix(0.18, 0.32, hash21(vec2(seed, 5.3)));
				panel = 1.0 - smoothstep(side * 0.55, side, min(pu, 1.0 - pu));
			}
			albedo = mix(albedo, interior_color.rgb, panel * interior_amount * mix(0.35, 1.0, hash21(vec2(seed, 9.7))));
		}
	}

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular_value;
	vec3 perturbed = normalize(n + t * slope.x + b * slope.y);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
