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
// How grey the pattern's dark parts are (0: the paint darkened, its own hue; 1: a grey
// groove, as the incised lines read in the owner's 2026-11-20 photos).
uniform float pattern_grey = 0.0;
uniform vec4 paint_color : source_color = vec4(0.845, 0.8, 0.665, 1.0);
uniform float tile_span_m = 2.6;
uniform float relief_strength = 0.12;
uniform float grain_variation = 0.2;
uniform float broad_variation = 0.1;
uniform float roughness_base = 0.84;
uniform float roughness_variation = 0.12;
uniform vec2 roughness_range = vec2(0.45, 0.97);
// Matte paint's specular level (Godot's SPECULAR; its own default is 0.5): low, so
// small ledges seen edge-on do not mirror the sky as blue lines.
uniform float specular_level = 0.25;
// Fine relief kept to what the screen can show (the crescent piers' reeds). Its mesh
// carries in UV its flat face's normal as an angle about Y from +X (x, radians) and
// each point's place across the reeds (y, metres). Where a reed of relief_period_m
// spans fewer pixels across than relief_fade_px.y, down to relief_fade_px.x, its own
// normals give way to one broad wave per relief_coarse_period_m across the same reeds
// (tilting relief_coarse_tilt at most), and that wave in turn to the flat face: a
// calm stripe at every distance, no switch, no pop. A relief_period_m of 0 (the
// default) leaves normals alone.
uniform float relief_period_m = 0.0;
uniform float relief_coarse_period_m = 0.45;
uniform float relief_coarse_tilt = 0.45;
uniform vec2 relief_fade_px = vec2(3.0, 6.0);
// How much less of the sky the relief's hollows see (an occlusion deepening from each
// reed's crest to its grooves, and from the broad wave's crests to its troughs), half
// of it on direct light too, so the fluting reads in shade and in sun; 0 leaves it.
uniform float relief_cavity = 0.0;
// How much less of the sky a whole face sees that stands in a return or recess (the
// crescent piers' sides, the hollow behind the head bands' dentils), half of it on
// direct light too, as relief_cavity: a projection's edge then reads at play distances
// whatever the sun's direction, where its cast shadow is finer than the shadow map's
// texels. 0 (the default) leaves it.
uniform float face_occlusion = 0.0;
// The surface's class: paint and stone are dielectric (0); bare bronze or brass
// is metal (its reflectance is specular_level above).
uniform float metallic_value = 0.0;
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
// showing; each board its own tone; joints the paint has filled in places and that
// step up or down by up to board_step (rows) along their length, so they read as
// broken, uneven lines, each line of its own strength. The marks are shallow relief:
// board_relief tilts the joint's lips, which raking sun picks out and diffuse light
// hardly shows, and board_joint darkens the paint in the joint a little. A joint is
// drawn at least a pixel wide with its effect spread over that pixel; where a board
// is under about five pixels tall the joints give way to their mean darkening and
// below about six the boards' tones fade out, so nothing stripes or shimmers at a
// distance.
uniform float board_pitch_m = 0.0;
uniform float board_pitch_variation = 0.0;
uniform float board_length_m = 2.4;
uniform float board_butt_share = 0.15;
uniform float board_tone = 0.0;
uniform float board_joint = 0.0;
uniform float board_joint_width = 0.05;
uniform float board_relief = 0.0;
uniform float board_step = 0.0;
uniform float board_joint_open = 0.45;

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
// The even grey band at the top (top_band in band_color, fading out between 0.4 and
// 1 times top_band_m below the top: a coping, or the darkest strip under it) and the
// soft wash under it (wash in wash_color, fading out over wash_m, or three times
// top_band_m where wash_m is 0).
uniform vec4 band_color : source_color = vec4(0.56, 0.57, 0.55, 1.0);
uniform float top_band = 0.0;
uniform float top_band_m = 0.5;
// How ragged the band's lower edge is: its depth varies by this share along the wall.
uniform float band_ragged = 0.0;
uniform float wash = 0.0;
uniform float wash_m = 0.0;
uniform vec4 wash_color : source_color = vec4(0.56, 0.57, 0.55, 1.0);
// Short, straight drips hanging from a top (and, shorter, from window sills), in
// streak_color, never drawn thinner than about a pixel and a half. The band, wash and
// drips all apply only where the exposure is above stain_min_exposure and only under
// tops at least stain_min_top_m high (a parapet, not a mid-height ledge).
uniform vec4 streak_color : source_color = vec4(0.45, 0.46, 0.44, 1.0);
uniform float streak_amount = 0.0;
uniform float streak_length_m = 1.2;
uniform float streak_spacing_m = 0.6;
uniform float stain_min_exposure = 0.4;
uniform float stain_min_top_m = 0.0;
uniform float sill_streak_amount = 0.0;
// An even film of dirt and moss on up-facing tops within up_grime_depth_m of the top
// (a coping, not the lines and ledges lower down).
uniform float up_grime = 0.0;
uniform float up_grime_depth_m = 1000.0;
// Dirt on the undersides of exposed projections (copings, bands, the drum's speed
// lines), which no rain washes: down-facing faces go this far toward band_color.
uniform float under_grime = 0.0;
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
// Glass seen at a slant reads darker than face on in the owner's photos (it mirrors
// the street and the buildings opposite, not the sky): its colour, reflectance and
// metalness scaled by down to 1 - oblique_dim as the view grazes it.
uniform float oblique_dim = 0.0;

varying vec3 world_position;
varying vec3 world_normal;
varying vec3 face_normal;
varying float relief_across;

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

// Short straight drips hanging below a drip edge: s runs along the wall (metres),
// below_m down from the edge. Columns spacing_m apart hold at most one drip each, of
// its own width (25 to 55 % of the column), strength and length, soft at its sides,
// strongest near the edge and fading as it runs down. Where a typical drip is under
// about five pixels wide (s_fw: metres per pixel along the wall; a wall seen at a
// grazing angle) the drips settle into their mean, a soft even shade, so they never
// draw as thin hard ticks.
float streak_field(float s, float below_m, float spacing_m, float length_m, float salt, float s_fw) {
	float c = s / spacing_m;
	float ci = floor(c);
	float cf = c - ci;
	float width_m = spacing_m * mix(0.25, 0.55, hash21(vec2(ci, salt + 1.7)));
	float drawn_m = max(width_m, s_fw * 2.0);
	float center = mix(0.3, 0.7, hash21(vec2(ci, salt + 9.2)));
	float across = abs(cf - center) * spacing_m / (0.5 * drawn_m);
	float profile = (1.0 - smoothstep(0.0, 1.0, across)) * (width_m / drawn_m);
	float run = length_m * mix(0.45, 1.0, hash21(vec2(ci, salt + 4.4)));
	float body = smoothstep(0.0, 0.1, below_m) * (1.0 - smoothstep(run * 0.35, run, below_m)) * mix(1.0, 0.6, clamp(below_m / run, 0.0, 1.0));
	float strength = step(0.45, hash21(vec2(ci, salt + 6.1))) * mix(0.55, 1.0, hash21(vec2(ci, salt + 2.9)));
	float mean = 0.12 * smoothstep(0.0, 0.1, below_m) * (1.0 - smoothstep(length_m * 0.3, length_m * 0.9, below_m));
	return mix(mean, profile * body * strength, smoothstep(3.0, 6.0, spacing_m * 0.4 / s_fw));
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
	face_normal = MODEL_NORMAL_MATRIX * vec3(cos(UV.x), 0.0, sin(UV.x));
	relief_across = UV.y;
}

void fragment() {
	vec3 n = normalize(world_normal);
	if (face_occlusion > 0.0) {
		AO = 1.0 - face_occlusion;
		AO_LIGHT_AFFECT = 0.5;
	}
	if (relief_period_m > 0.0) {
		vec3 face = normalize(face_normal);
		vec3 across = vec3(-face.z, 0.0, face.x);
		float metres_per_pixel = max(fwidth(relief_across), 1e-5);
		float fine = smoothstep(relief_fade_px.x, relief_fade_px.y, relief_period_m / metres_per_pixel);
		float coarse = smoothstep(relief_fade_px.x, relief_fade_px.y, relief_coarse_period_m / metres_per_pixel);
		vec3 wave = normalize(face + across * (relief_coarse_tilt * sin(6.2831853 * relief_across / relief_coarse_period_m)));
		float hollow = fine * clamp((1.0 - dot(n, face)) / 0.36, 0.0, 1.0) + (1.0 - fine) * coarse * 0.6 * clamp((1.0 - dot(wave, face)) / 0.09, 0.0, 1.0);
		AO = (1.0 - face_occlusion) * (1.0 - relief_cavity * hollow);
		AO_LIGHT_AFFECT = 0.5;
		n = normalize(mix(mix(face, wave, coarse), n, fine));
	}
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
	vec3 painted = paint_color.rgb * clamp(variation, 0.86, 1.1);
	vec3 pattern = texture(detail_pattern, UV).rgb;
	vec3 albedo = mix(painted, mix(vec3(dot(painted, LUMA)), painted, dot(pattern, LUMA)), pattern_grey) * pattern;
	float roughness = clamp(roughness_base + (rough_sample - 0.5) * roughness_variation, roughness_range.x, roughness_range.y);
	float metallic = metallic_value;
	// The normal's tilt along t (across the face) and b (up a wall).
	vec2 slope = tilt * relief_strength;

	if (board_pitch_m > 0.0 && wall > 0.0) {
		// Rows of varied height: the row coordinate is warped along the height only,
		// so every joint stays a level line.
		float warp = noise_m(vec2(world_position.y, 3.7), 0.45) * board_pitch_variation * board_pitch_m;
		float rows = (world_position.y + warp) / board_pitch_m;
		float rows_fw = height_fw / board_pitch_m;
		float board_px = 1.0 / max(rows_fw, 0.0001);
		float show_board = wall * smoothstep(5.0, 9.0, board_px);
		float show_joint = smoothstep(5.0, 8.0, board_px);
		float row = floor(rows);
		// The boards of this row along the wall, each row's ends staggered.
		float row_length = board_length_m * mix(0.6, 1.5, hash21(vec2(row, 3.17)));
		float along = s / row_length + hash21(vec2(row, 7.73)) * 7.0;
		float piece = floor(along);
		float g = along - piece;
		float tone = hash21(vec2(row * 1.37, piece)) - 0.5 + 0.35 * noise_m(vec2(s, row * 0.7), 0.6);
		albedo *= 1.0 + tone * board_tone * show_board;
		// The nearest joint, read from its own line so both its sides agree: it
		// steps up or down along its length, is filled by the paint in places and
		// is fainter in others.
		float line = floor(rows + 0.5);
		float run_m = board_length_m * 0.8;
		float stretch = floor(s / run_m + hash21(vec2(line, 1.9)) * 5.0);
		float wobble = noise_m(vec2(s, line * 1.7), 0.9) * 0.06;
		float e = rows - line - (hash21(vec2(stretch, line)) - 0.5) * board_step - wobble;
		float jw = max(board_joint_width, rows_fw);
		float groove = exp(-(e * e) / (jw * jw)) * (board_joint_width / jw);
		float breaks = noise_m(vec2(s, line * 0.9), 0.35) * 0.7 + noise_m(vec2(s + 13.0, line * 1.3), 0.12) * 0.3;
		float line_strength = mix(0.35, 1.0, hash21(vec2(line, 13.7)));
		float open = smoothstep(-0.5, 0.5, breaks + board_joint_open - 0.45) * mix(0.3, 1.0, hash21(vec2(stretch, line + 4.1))) * line_strength;
		// Butt joints at the boards' ends, some of them showing.
		float end_d = min(g, 1.0 - g) * row_length / board_pitch_m;
		float butt = exp(-pow(end_d / max(board_joint_width * 0.8, s_fw / board_pitch_m), 2.0)) * step(1.0 - board_butt_share, hash21(vec2(piece, row + 5.1)));
		butt *= (1.0 - smoothstep(0.32, 0.46, abs(rows - row - 0.5))) * smoothstep(4.0, 9.0, board_pitch_m / s_fw);
		float cavity = max(groove * open, butt * 0.25);
		// Past the joints' last pixels their mean darkening stays.
		float mean_cavity = board_joint_width * 1.77 * 0.5;
		albedo *= 1.0 - board_joint * wall * mix(mean_cavity, cavity, show_joint);
		// The groove's walls face down above the joint and up below it.
		slope.y -= 2.0 * (e / jw) * groove * open * board_relief * show_joint * wall;
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
		float washed = 0.0;
		float streak = 0.0;
		// Stains belong to the exposed parts and to real parapets only.
		float stain = smoothstep(stain_min_exposure, stain_min_exposure + 0.3, exposure) * step(stain_min_top_m, top_y);
		if (top_d > -0.05) {
			float below = max(top_d, 0.0);
			float ragged = 1.0 + band_ragged * clamp(noise_m(vec2(s, top_y * 3.1), 1.3), -1.0, 1.0);
			band = top_band * (1.0 - smoothstep(top_band_m * 0.4 * ragged, top_band_m * ragged, below));
			washed = wash * (1.0 - smoothstep(0.0, wash_m > 0.0 ? wash_m : top_band_m * 3.0, below));
			streak = streak_amount * streak_field(s, below, streak_spacing_m, streak_length_m, 0.0, s_fw) * wall;
		}
		band *= stain;
		washed *= stain;
		streak *= stain;
		if (sill_d > 0.0 && wall > 0.5) {
			streak += sill_streak_amount * streak_field(s + 17.0, sill_d, streak_spacing_m * 0.6, streak_length_m * 0.4, 5.0, s_fw) * smoothstep(stain_min_exposure, stain_min_exposure + 0.3, exposure);
		}
		if (ground_h >= 0.0 && base_splash > 0.0) {
			float splash = 1.0 - smoothstep(base_splash_m * 0.3, base_splash_m, ground_h);
			band += base_splash * splash * (0.75 + 0.25 * smoothstep(-1.0, 1.0, noise_m(vec2(s, world_position.y), 0.3))) * wall;
		}
		washed = clamp(washed * amount, 0.0, 0.85);
		albedo = mix(albedo, wash_color.rgb, washed);
		band = clamp(band * amount, 0.0, 0.85);
		albedo = mix(albedo, band_color.rgb, band);
		streak = clamp(streak * amount, 0.0, 0.7);
		albedo = mix(albedo, streak_color.rgb, streak);
		roughness = min(roughness + 0.08 * max(max(band, washed), streak), 0.97);
		float down = smoothstep(0.5, 0.85, -n.y);
		if (down > 0.0 && under_grime > 0.0) {
			albedo = mix(albedo, band_color.rgb, clamp(under_grime * down * weathering * smoothstep(0.2, 0.6, exposure), 0.0, 0.85));
		}
		float up = smoothstep(0.5, 0.85, n.y);
		if (up > 0.0 && up_grime > 0.0) {
			float near_top = top_d >= 0.0 ? 1.0 - smoothstep(up_grime_depth_m * 0.6, up_grime_depth_m, top_d) : 1.0;
			float film = clamp(up_grime * up * near_top * weathering * mix(1.0, exposure, 0.5), 0.0, 0.85);
			albedo = mix(albedo, moss_color.rgb, film);
			roughness = mix(roughness, 0.95, film);
		}
	}

	if (wear > 0.0 && ground_h >= 0.0) {
		float worn = wear * (1.0 - smoothstep(wear_height_m - 0.04, wear_height_m, ground_h));
		// The worn edges, darker: a soft band at the plate's top and one at its foot.
		float edge = 0.7 * max(1.0 - smoothstep(0.03, 0.12, wear_height_m - ground_h), 1.0 - smoothstep(0.02, 0.08, ground_h));
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

	// At a slant: less colour, and a lower reflectance; below a reflectance of about
	// 2 % Godot also scales down the grazing reflection of the sky (its f90 is
	// 50 x F0), so the glass mirrors less sky edge-on, as the photos' oblique windows
	// mirror the darker street.
	float specular = specular_level;
	if (oblique_dim > 0.0) {
		float facing_view = clamp(dot(normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz), VIEW), 0.0, 1.0);
		float slant = oblique_dim * smoothstep(0.97, 0.55, facing_view);
		albedo *= 1.0 - slant;
		specular *= 1.0 - slant;
		metallic *= 1.0 - slant;
	}

	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;
	vec3 perturbed = normalize(n + t * slope.x + b * slope.y);
	NORMAL = normalize((VIEW_MATRIX * vec4(perturbed, 0.0)).xyz);
}
