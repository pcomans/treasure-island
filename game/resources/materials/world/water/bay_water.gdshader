shader_type spatial;
// San Francisco Bay around Treasure Island: one plane, one draw.
//
// The mesh is a unit grid (world_root.tscn ContextWorld/Water: a PlaneMesh 2 x 2 m
// with grid_rows quads a side) that the vertex stage spreads into rings around the
// camera. The outermost rings reach far_share of the camera's own far plane and the
// last one stands up to the camera's eye height, so from any camera, at any height
// and with any far plane, the water reaches the horizon with no edge or sky gap
// below it, and only scenery in the last few percent of the view's depth can stand
// behind that ring. Within a few hundred metres of the far plane's own height the
// last ring lies down instead (vertex()). Nothing in the bay collides; the node only
// places the level.
//
// Waves: one baked tile of looping wind waves (tools/bake_water_waves.mjs) played at
// six scales, each turned a little off the wind and run at deep-water speed for its
// size. Its loops divide Godot's one-hour time rollover, so the waves never jump.
// The tile is filtered anisotropically, so chop stays visible far across the water;
// slope that the filtering has averaged away becomes roughness and a tilt toward the
// eye instead (the mip table from the bake), so far water turns to a sheen that
// reflects higher, bluer sky rather than shimmering. The shore map (tools/lib/
// water-shore-map.mjs) gives the distance to the waterline (the shallow toe, the wash,
// the nearshore water's colour), the fetch (calmer water in the islands' lee) and the
// cover under pier decks.
//
// Light: Fresnel reflection of the live sky through Godot's own reflection, and the
// sun's glitter from the live sun in light() (GGX on the rippled surface, scaled by
// the light's specular). The sky reflection takes only a little of the averaged-away
// slope as roughness (Godot's rough reflections fade toward the horizon, where the
// bay should read almost as bright as the sky); the sun's glitter takes all of it, so
// its path widens with distance, held below a soft limit so a grazing path does not
// blow out to a flat white patch. The body colour is lit by the sun's height and the
// sky, not by the ripples. No light, sky or time of day is baked in.
// Premultiplied alpha: the reflection stays whole where the shallow water shows
// the stones under it.
render_mode blend_premul_alpha, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
// The web build: three scales, nearest frame, no gusts or whitecaps.
#define WATER_SIMPLE
// GLES3 reverses depth without remapping it, so the far plane is at NDC z = -1
// (drivers/gles3/rasterizer_scene_gles3.cpp, _setup_environment:
// set_depth_correction(p_flip_y, true, false)).
const float FAR_NDC_Z = -1.0;
#else
// RenderingDevice reverses depth into 0..1, so the far plane is at NDC z = 0
// (servers/rendering/renderer_rd/storage_rd/render_scene_data_rd.cpp:
// set_depth_correction(flip_y) with core/math/projection.h's defaults).
const float FAR_NDC_Z = 0.0;
#endif

uniform sampler2DArray waves : filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D shore_map : filter_linear_mipmap, repeat_disable;
// The shore map's rectangle: west x, north z, width and depth (m); the same numbers
// as SHORE_MAP_ORIGIN_XZ and SHORE_MAP_SIZE_M in tools/lib/water-shore-map.mjs.
uniform vec4 shore_rect = vec4(-1120.0, -1360.0, 2600.0, 3600.0);
uniform float grid_rows = 23.0;
// The outer ring's reach: this share of the camera's far plane.
uniform float far_share = 0.96;

// Waves run toward this bearing (clockwise from north): the prevailing westerly.
uniform float wind_bearing_deg = 80.0;
// Scales every layer's RMS slope (LAYER_SLOPE); slope_micro is the RMS slope of
// the ripples too fine for any layer.
uniform float wave_slope = 1.0;
uniform float slope_micro = 0.06;
// The sky reflection's own roughness (GGX alpha squared) and the share of the
// averaged-away slope variance it takes on top.
uniform float sky_alpha2 = 0.0012;
uniform float sky_lost_share = 0.05;
// How far averaged-away slope tilts far water toward the eye, as a share of its RMS.
uniform float far_tilt = 0.9;
// A layer reaches full strength over about fetch_per_tile * its tile size of open water.
uniform float fetch_per_tile = 25.0;
uniform float lee_floor = 0.3;
// Gusts: patches of rougher and calmer water drifting with the wind. The short
// waves follow gust_range; the finest ripples, which set the sky reflection's
// sheen, follow ripple_range over broader patches (cat's paws and slicks).
uniform vec2 gust_range = vec2(0.6, 1.3);
uniform vec2 ripple_range = vec2(0.2, 1.8);
// Whitecaps: the share of WHITECAP_CELL_M cells that break in a cycle, in a full gust
// on open water.
uniform float whitecap_share = 0.45;

uniform vec3 bay_color : source_color = vec3(0.19, 0.31, 0.39);
uniform vec3 shore_color : source_color = vec3(0.23, 0.33, 0.32);
uniform float shore_color_reach_m = 100.0;
uniform float shallow_alpha = 0.45;
uniform float clear_reach_m = 1.8;
uniform vec3 foam_color : source_color = vec3(0.86, 0.88, 0.86);
uniform float foam_reach_m = 1.4;
uniform float foam_strength = 0.55;
// The water under a pier deck sees little sky: ambient occlusion at full cover.
uniform float deck_occlusion = 0.85;
uniform float glitter_gain = 2.0;
// Glitter radiance (in units of the sun's colour times energy) where the soft
// limit has halved it.
uniform float glitter_limit = 2.0;

const float WATER_F0 = 0.02;
// FRAMES and TILE_TEXELS are tools/bake_water_waves.mjs's FRAMES and SIZE; the slope
// decode (s.rg - 0.5) * 6.0 is its 2 * CLIP.
const float FRAMES = 64.0;
const float TILE_TEXELS = 128.0;
// The project's anisotropic filtering (rendering/textures/default_filters/
// anisotropic_filtering_level, default 2, which is 4x: servers/rendering_server.cpp
// and material_storage.cpp's 1 << level).
const float ANISO = 4.0;
const float WHITECAP_CELL_M = 12.0;
// Tile sizes (m) and loop periods (s): the period is the bake's LOOP_CYCLES periods of a
// wave BAND[0] times shorter than the tile (6 * sqrt(2 pi (L / 4) / g)), rounded so
// that every loop divides 3600 s. Retune both with the bake's BAND or LOOP_CYCLES.
const float LAYER_M[6] = {69.4, 36.0, 17.4, 9.0, 4.34, 2.25};
const float LAYER_LOOP_S[6] = {20.0, 14.4, 10.0, 7.2, 5.0, 3.6};
const float LAYER_TURN[6] = {0.0, -0.38, 0.26, -0.19, 0.42, -0.10};
const vec2 LAYER_SHIFT[6] = {vec2(0.13, 0.71), vec2(0.47, 0.29), vec2(0.86, 0.05), vec2(0.31, 0.92), vec2(0.62, 0.44), vec2(0.08, 0.37)};
const float LAYER_PHASE[6] = {0.0, 0.37, 0.71, 0.13, 0.55, 0.91};
// RMS slope of each layer: the bay's chop is steepest at 4-17 m.
const float LAYER_SLOPE[6] = {0.035, 0.065, 0.09, 0.095, 0.085, 0.075};
// Share of a layer's slope variance each mip level keeps: the `mip_retained` that
// tools/bake_water_waves.mjs prints. Copy it again whenever the tile is re-baked.
const float MIP_KEPT[8] = {1.0, 0.97, 0.86, 0.5469, 0.1313, 0.0066, 0.0026, 0.0008};

varying vec3 world_pos;
// GGX alpha squared for the sun's glitter: the full averaged-away slope variance.
varying float glitter_alpha2;
// The glitter's share left near the horizon, where a wide path would blow out.
varying float glitter_fade;

void vertex() {
	vec2 grid = VERTEX.xz;
	float c = max(abs(grid.x), abs(grid.y));
	float outer = (grid_rows - 1.0) * 0.5;
	float ring = floor((c * grid_rows - 1.0) * 0.5 + 0.5);
	vec3 camera = CAMERA_POSITION_WORLD;
	float level = NODE_POSITION_WORLD.y;
	// The camera's far plane, unprojected: the outer ring's slant distance stays at
	// far_share of it at any height.
	vec4 far_point = INV_PROJECTION_MATRIX * vec4(0.0, 0.0, FAR_NDC_Z, 1.0);
	float reach = far_share * (-far_point.z / far_point.w);
	float height = max(camera.y - level, 0.0);
	float far_radius = sqrt(max(reach * reach - height * height, 1.0));
	float radius = ring >= outer - 0.5 ? far_radius : far_radius * pow((2.0 * ring + 1.0) / (grid_rows - 2.0), 2.0);
	vec2 dir = normalize(grid);
	// Near the far plane's own height (about 4.7 km up for gameplay's camera) the rings
	// shrink round the camera, and a standing outer ring would wall it in and cover the
	// island, so it lies down at water level as its radius falls from half the reach to
	// a quarter.
	float stand = smoothstep(0.25, 0.5, far_radius / reach);
	world_pos = vec3(camera.x + dir.x * radius, ring > outer - 0.5 ? mix(level, max(camera.y, level), stand) : level, camera.z + dir.y * radius);
	VERTEX = world_pos - NODE_POSITION_WORLD;
}

float mip_kept(float lod) {
	float l = clamp(lod, 0.0, 7.0);
	int i = int(floor(l));
	int j = min(i + 1, 7);
	return mix(MIP_KEPT[i], MIP_KEPT[j], l - float(i));
}

// The environment reflection weight of Compatibility's env_brdf_approx
// (drivers/gles3/shaders/scene.glsl), so the body takes what the sky reflection
// leaves. Forward+ looks its weight up in a DFG table (integrate_dfg.glsl) that sits
// a little lower at grazing angles; the body's share is set from this one in both.
float sky_fresnel(float roughness, float n_dot_v) {
	vec4 r = roughness * vec4(-1.0, -0.0275, -0.572, 0.022) + vec4(1.0, 0.0425, 1.04, -0.04);
	float a004 = min(r.x * r.x, exp2(-9.28 * n_dot_v)) * r.x + r.y;
	vec2 env = vec2(-1.04, 1.04) * a004 + r.zw;
	return WATER_F0 * env.x + env.y;
}

// Dave Hoskins' "hash without sine": no sin() of a large argument, which loses
// precision on some GPUs, and no wrap that would repeat whole cells.
float hash(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

// Value noise that repeats every `period` cells along x, so its drift can wrap.
float wrap_noise(vec2 p, float period) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	float x0 = mod(i.x, period);
	float x1 = mod(i.x + 1.0, period);
	return mix(mix(hash(vec2(x0, i.y)), hash(vec2(x1, i.y)), u.x), mix(hash(vec2(x0, i.y + 1.0)), hash(vec2(x1, i.y + 1.0)), u.x), u.y);
}

// A noise cell, faded to its mean once a pixel spans a good part of it (no
// aliased streaks toward the horizon).
float faded_noise(vec2 p, float period, float cell_m, float footprint) {
	return mix(wrap_noise(p, period), 0.5, smoothstep(cell_m * 0.1, cell_m * 0.35, footprint));
}

// Whitecaps: each WHITECAP_CELL_M cell of the wind frame holds at most one breaking
// crest, at its own spot, size and moment in a 9 s cycle (which divides 3600 s); the
// cells drift downwind 300 cells an hour. `crest` breaks up the outline.
float whitecap(vec2 wf, float crest) {
	vec2 p = vec2(wf.x / WHITECAP_CELL_M - TIME * 300.0 / 3600.0, wf.y / WHITECAP_CELL_M);
	vec2 cell = floor(p);
	vec2 f = fract(p);
	vec2 key = vec2(mod(cell.x, 300.0), cell.y);
	float pick = hash(key);
	float r1 = hash(key + vec2(31.7, -7.3));
	float r2 = hash(key + vec2(-13.1, 19.9));
	float r3 = hash(key + vec2(5.3, 41.1));
	// Along the wind 0.8-1.4 m, along the crest 1.8-3.2 m (half sizes).
	vec2 half_size = vec2(mix(0.8, 1.4, r3), mix(1.8, 3.2, r1)) / WHITECAP_CELL_M;
	vec2 offset = (f - vec2(0.3 + 0.4 * r1, 0.3 + 0.4 * r2)) / half_size;
	float life = fract(TIME / 9.0 + r2);
	float bloom = smoothstep(0.0, 0.06, life) * (1.0 - smoothstep(0.15, 0.45, life));
	float shape = 1.0 - smoothstep(0.5, 1.0, length(offset) + 0.45 * (0.5 - crest));
	return step(pick, whitecap_share) * bloom * shape;
}

void fragment() {
	float level = NODE_POSITION_WORLD.y;
	vec3 to_camera = CAMERA_POSITION_WORLD - world_pos;
	vec3 v = normalize(to_camera);
	bool skirt = world_pos.y > level + 0.01;
	vec2 xz = world_pos.xz;

	// The shore: distance to the waterline (+ over the water), distance offshore,
	// fetch and deck cover, decoded with tools/lib/water-shore-map.mjs's ranges.
	vec2 suv = (xz - shore_rect.xy) / shore_rect.zw;
	vec4 sm = texture(shore_map, suv);
	float inside = skirt ? 0.0 : smoothstep(0.0, 0.05, min(min(suv.x, suv.y), min(1.0 - suv.x, 1.0 - suv.y)));
	float d_fine = mix(16.0, (sm.r - 0.5) * 32.0, inside);
	float d_coarse = mix(1024.0, sm.g * sm.g * 1024.0, inside);
	float fetch = mix(4096.0, sm.b * sm.b * 4096.0, inside);
	float cover = sm.a * inside;

	float wind = radians(wind_bearing_deg);
	vec2 wind_dir = vec2(sin(wind), -cos(wind));
	// Screen derivatives of the plan position, taken once: the layers' texture reads
	// sit in a loop that skips faded layers, so they take explicit gradients. The
	// longer sets the isotropic footprint (m per pixel); the anisotropic filter
	// keeps detail down to the longer over ANISO, or the shorter.
	vec2 dx = dFdx(xz);
	vec2 dy = dFdy(xz);
	float footprint = skirt ? 1e4 : max(length(dx), length(dy));
	float footprint_aniso = skirt ? 1e4 : max(footprint / ANISO, min(length(dx), length(dy)));
	float wind_turn = atan(wind_dir.y, wind_dir.x);
	// Wind frame: along and across the wind; each drift wraps with the hour.
	vec2 wf = vec2(dot(xz, wind_dir), dot(xz, vec2(-wind_dir.y, wind_dir.x)));

	float gust = 1.0;
	float ripple = 1.0;
#ifndef WATER_SIMPLE
	float g1 = faded_noise(vec2(wf.x / 140.0 - TIME * 64.0 / 3600.0, wf.y / 140.0), 64.0, 140.0, footprint);
	float g2 = faded_noise(vec2(wf.x / 47.0 - TIME * 192.0 / 3600.0, wf.y / 47.0 + 17.3), 192.0, 47.0, footprint);
	float g3 = faded_noise(vec2(wf.x / 380.0 - TIME * 24.0 / 3600.0, wf.y / 380.0 + 5.1), 24.0, 380.0, footprint);
	gust = mix(gust_range.x, gust_range.y, g1 * 0.65 + g2 * 0.35);
	ripple = mix(ripple_range.x, ripple_range.y, smoothstep(0.15, 0.85, g3 * 0.55 + g1 * 0.45));
#endif
	// The islands' lee is calmer: less wind reaches it, so the finest ripples drop too.
	float lee = mix(lee_floor, 1.0, 1.0 - exp(-fetch / (fetch_per_tile * 4.0)));
	ripple *= lee;

	vec2 slope = vec2(0.0);
	float micro = slope_micro * slope_micro * ripple;
	// Slope variance averaged away: by the anisotropic filter (what the normal lacks)
	// and isotropically (what the sun's glitter spreads over).
	float lost = 0.0;
	float lost_iso = 0.0;
	float crest = 0.0;
	float swell = 0.5;
#ifdef WATER_SIMPLE
	const int FIRST = 1;
	const int STEP = 2;
#else
	const int FIRST = 0;
	const int STEP = 1;
#endif
	for (int i = FIRST; i < 6; i += STEP) {
		float size = LAYER_M[i];
		float exposure = mix(lee_floor, 1.0, 1.0 - exp(-fetch / (fetch_per_tile * size)));
		float k = LAYER_SLOPE[i] * wave_slope * exposure * (i >= 3 ? gust : 1.0);
#ifdef WATER_SIMPLE
		k *= 1.41;
#endif
		float kept = mip_kept(log2(max(footprint_aniso * TILE_TEXELS / size, 1e-6)));
		lost += k * k * (1.0 - kept);
		lost_iso += k * k * (1.0 - mip_kept(log2(max(footprint * TILE_TEXELS / size, 1e-6))));
		if (kept < 0.002) {
			continue;
		}
		float turn = wind_turn + LAYER_TURN[i];
		vec2 along = vec2(cos(turn), sin(turn));
		vec2 across = vec2(-along.y, along.x);
		vec2 uv = vec2(dot(xz, along), dot(xz, across)) / size + LAYER_SHIFT[i];
		vec2 uv_dx = vec2(dot(dx, along), dot(dx, across)) / size;
		vec2 uv_dy = vec2(dot(dy, along), dot(dy, across)) / size;
		float frame = fract(TIME / LAYER_LOOP_S[i] + LAYER_PHASE[i]) * FRAMES;
		float f0 = floor(frame);
#ifdef WATER_SIMPLE
		vec4 s = textureGrad(waves, vec3(uv, f0), uv_dx, uv_dy);
#else
		vec4 s = mix(textureGrad(waves, vec3(uv, f0), uv_dx, uv_dy), textureGrad(waves, vec3(uv, mod(f0 + 1.0, FRAMES)), uv_dx, uv_dy), frame - f0);
#endif
		// Tile slopes (normalized, clipped at 3 RMS) back to world axes.
		vec2 ts = (s.rg - 0.5) * 6.0;
		slope += k * (ts.x * along + ts.y * across);
		crest = max(crest, s.a * (i >= 3 ? 1.0 : 0.0));
		swell = i == 2 ? s.b : swell;
	}
	vec3 n = skirt ? vec3(0.0, 1.0, 0.0) : normalize(vec3(-slope.x, 1.0, -slope.y));
	// Seen low, the facets that face the eye fill more of each pixel, so averaged-away
	// slope leans far water toward the eye and it mirrors higher, bluer sky.
	vec2 toward = normalize(v.xz + vec2(1e-6, 0.0));
	n = normalize(n + vec3(toward.x, 0.0, toward.y) * far_tilt * sqrt(lost) * (1.0 - smoothstep(0.05, 0.6, v.y)));
	// Keep facets that face away from a grazing eye from going black.
	n = normalize(n + max(0.0, 0.05 - dot(n, v)) * v);
	glitter_alpha2 = clamp(micro + lost_iso, 0.0002, 0.25);
	glitter_fade = mix(0.35, 1.0, smoothstep(0.0, 0.15, v.y));
	float roughness = sqrt(sqrt(clamp(sky_alpha2 * ripple + sky_lost_share * (micro + lost), 0.0002, 0.25)));

	// Water body: a little greener and murkier near the shore, clearer over the
	// stones at the toe.
	float near = 1.0 - smoothstep(10.0, shore_color_reach_m, d_coarse);
	vec3 body = mix(bay_color, shore_color, near);
	float fresnel = sky_fresnel(roughness, max(dot(n, v), 1e-4));
	float opacity = mix(shallow_alpha, 1.0, smoothstep(0.0, clear_reach_m, d_fine));

	// Wash at the waterline: a thin, broken band that comes and goes with the waves
	// (745 surges an hour, so it wraps with TIME).
	float wash = 1.0 - smoothstep(0.1, foam_reach_m, d_fine);
	float surge = 0.5 + 0.5 * sin(TIME * TAU * 745.0 / 3600.0 - d_fine * 2.6 + swell * 6.0);
	float foam = foam_strength * wash * smoothstep(0.55, 0.95, crest * 0.5 + swell * 0.45 + surge * 0.35);
	foam *= step(-0.3, d_fine);
#ifndef WATER_SIMPLE
	// Whitecaps in the gusts on open water, gone once they shrink below a few pixels.
	float open_water = 1.0 - exp(-fetch / 1500.0);
	float gusting = smoothstep(0.85, 1.15, gust);
	float visible = 1.0 - smoothstep(0.35, 0.8, footprint_aniso);
	foam = max(foam, 0.85 * open_water * gusting * visible * (1.0 - cover) * whitecap(wf, crest));
#endif

	float alpha = mix(opacity, 1.0, foam);
	ALBEDO = mix(body * (1.0 - fresnel), foam_color, foam) * alpha;
	ALPHA = alpha;
	METALLIC = 0.0;
	SPECULAR = mix(0.354, 0.1, foam);
	ROUGHNESS = mix(roughness, 0.8, foam);
	AO = 1.0 - deck_occlusion * cover;
	NORMAL = normalize((VIEW_MATRIX * vec4(n, 0.0)).xyz);
}

void light() {
	// The body: light entering the water depends on the sun's height, not the ripples.
	vec3 up = normalize((VIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz);
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * max(dot(up, LIGHT), 0.0) / PI;
	// Sun glitter: GGX on the rippled surface.
	vec3 h = normalize(VIEW + LIGHT);
	float n_dot_l = max(dot(NORMAL, LIGHT), 0.0);
	float n_dot_v = max(dot(NORMAL, VIEW), 1e-4);
	float n_dot_h = max(dot(NORMAL, h), 0.0);
	float a2 = glitter_alpha2;
	float d = n_dot_h * n_dot_h * (a2 - 1.0) + 1.0;
	float ggx = a2 / (PI * d * d);
	float vis = 0.5 / (n_dot_l * sqrt(n_dot_v * n_dot_v * (1.0 - a2) + a2) + n_dot_v * sqrt(n_dot_l * n_dot_l * (1.0 - a2) + a2) + 1e-5);
	float l_dot_h = max(dot(LIGHT, h), 0.0);
	float f = WATER_F0 + (1.0 - WATER_F0) * pow(1.0 - l_dot_h, 5.0);
	float glint = n_dot_l * ggx * vis * f * SPECULAR_AMOUNT * glitter_gain * glitter_fade;
	// Soft limit: half strength where the glint reaches glitter_limit.
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * glint / (1.0 + glint / glitter_limit);
}
