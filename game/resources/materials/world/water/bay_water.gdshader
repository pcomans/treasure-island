shader_type spatial;
// San Francisco Bay around Treasure Island: one plane, one draw.
//
// The mesh is a unit grid (world_root.tscn ContextWorld/Water: a PlaneMesh 2 x 2 m
// with grid_rows quads a side) that the vertex stage spreads into rings around the
// camera, out to far_radius_m, and its outermost ring stands up to the camera's
// eye height: from any camera the water reaches the horizon, with no edge or sky
// gap below it. far_radius_m sits just inside the gameplay camera's 5 km far plane;
// opaque scenery farther away than it, below eye height, is hidden behind that
// standing ring (only cameras with a longer far plane, such as the island overview
// shots, can show any). Nothing in the bay collides; the node only places the
// water's level.
//
// Waves: one baked tile of looping wind waves (tools/bake_water_waves.mjs) played at
// six scales, each turned a little off the wind and run at deep-water speed for its
// size. Its loops divide Godot's one-hour time rollover, so the waves never jump.
// Each layer's slope variance that the texture's mip level has averaged away becomes
// roughness instead (the table from the bake), so far water turns to a smooth sheen
// and a widening sun path rather than shimmering. The shore map (tools/lib/
// water-shore-map.mjs) gives the distance to the waterline (the shallow toe, the wash,
// the nearshore water's colour) and the fetch (calmer water in the islands' lee).
//
// Light: Fresnel reflection of the live sky through Godot's own reflection, and the
// sun's glitter from the live sun in light() (GGX on the rippled surface, scaled by
// the light's specular). The sky reflection takes only a little of the averaged-away
// slope as roughness (Godot's rough reflections fade toward the horizon, where the
// bay should read almost as bright as the sky); the sun's glitter takes all of it, so
// its path widens with distance. The body colour is lit by the sun's height and the
// sky, not by the ripples. No light, sky or time of day is baked in.
// Premultiplied alpha: the reflection stays whole where the shallow water shows
// the stones under it.
render_mode blend_premul_alpha, depth_draw_opaque, cull_back, diffuse_lambert, specular_schlick_ggx;

#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
// The web build: three scales, nearest frame, no gusts.
#define WATER_SIMPLE
#endif

uniform sampler2DArray waves : filter_linear_mipmap, repeat_enable;
uniform sampler2D shore_map : filter_linear_mipmap, repeat_disable;
// The shore map's rectangle: west x, north z, width and depth (m).
uniform vec4 shore_rect = vec4(-1120.0, -1360.0, 2600.0, 3600.0);
uniform float grid_rows = 23.0;
uniform float far_radius_m = 4800.0;

// Waves run toward this bearing (clockwise from north): the prevailing westerly.
uniform float wind_bearing_deg = 80.0;
// Scales every layer's RMS slope (LAYER_SLOPE); slope_micro is the RMS slope of
// the ripples too fine for any layer.
uniform float wave_slope = 1.0;
uniform float slope_micro = 0.06;
// The sky reflection's own roughness (GGX alpha squared) and the share of the
// averaged-away slope variance it takes on top.
uniform float sky_alpha2 = 0.0012;
uniform float sky_lost_share = 0.1;
// A layer reaches full strength over about fetch_per_tile * its tile size of open water.
uniform float fetch_per_tile = 25.0;
uniform float lee_floor = 0.3;
// Gusts: patches of rougher and calmer water drifting with the wind. The short
// waves follow gust_range; the finest ripples, which set the sky reflection's
// sheen, follow ripple_range over broader patches (cat's paws and slicks).
uniform vec2 gust_range = vec2(0.6, 1.25);
uniform vec2 ripple_range = vec2(0.2, 1.7);

uniform vec3 bay_color : source_color = vec3(0.23, 0.33, 0.33);
uniform vec3 shore_color : source_color = vec3(0.26, 0.32, 0.29);
uniform float shore_color_reach_m = 140.0;
uniform float shallow_alpha = 0.45;
uniform float clear_reach_m = 1.8;
uniform vec3 foam_color : source_color = vec3(0.86, 0.88, 0.86);
uniform float foam_reach_m = 1.4;
uniform float foam_strength = 0.55;
uniform float glitter_gain = 2.0;

const float WATER_F0 = 0.02;
const float FRAMES = 64.0;
const float TILE_TEXELS = 128.0;
// Tile sizes (m) and loop periods (s): deep-water speed for each size, rounded so
// that every loop divides 3600 s.
const float LAYER_M[6] = {69.4, 36.0, 17.4, 9.0, 4.34, 2.25};
const float LAYER_LOOP_S[6] = {20.0, 14.4, 10.0, 7.2, 5.0, 3.6};
const float LAYER_TURN[6] = {0.0, -0.38, 0.26, -0.19, 0.42, -0.10};
const vec2 LAYER_SHIFT[6] = {vec2(0.13, 0.71), vec2(0.47, 0.29), vec2(0.86, 0.05), vec2(0.31, 0.92), vec2(0.62, 0.44), vec2(0.08, 0.37)};
const float LAYER_PHASE[6] = {0.0, 0.37, 0.71, 0.13, 0.55, 0.91};
// RMS slope of each layer: about the same per octave, the longest a little gentler.
const float LAYER_SLOPE[6] = {0.030, 0.045, 0.060, 0.070, 0.075, 0.075};
// Share of a layer's slope variance each mip level keeps (tools/bake_water_waves.mjs).
const float MIP_KEPT[8] = {1.0, 0.97, 0.86, 0.5469, 0.1313, 0.0066, 0.0026, 0.0008};

varying vec3 world_pos;
// GGX alpha squared for the sun's glitter: the full averaged-away slope variance.
varying float glitter_alpha2;

void vertex() {
	vec2 grid = VERTEX.xz;
	float c = max(abs(grid.x), abs(grid.y));
	float outer = (grid_rows - 1.0) * 0.5;
	float ring = floor((c * grid_rows - 1.0) * 0.5 + 0.5);
	float radius = ring >= outer - 0.5 ? far_radius_m : far_radius_m * pow((2.0 * ring + 1.0) / (grid_rows - 2.0), 2.0);
	vec2 dir = normalize(grid);
	vec3 camera = CAMERA_POSITION_WORLD;
	float level = NODE_POSITION_WORLD.y;
	world_pos = vec3(camera.x + dir.x * radius, ring > outer - 0.5 ? max(camera.y, level) : level, camera.z + dir.y * radius);
	VERTEX = world_pos - NODE_POSITION_WORLD;
}

float mip_kept(float lod) {
	float l = clamp(lod, 0.0, 7.0);
	int i = int(floor(l));
	int j = min(i + 1, 7);
	return mix(MIP_KEPT[i], MIP_KEPT[j], l - float(i));
}

// Godot's environment reflection weight (its env_brdf_approx), so the body takes
// what the sky reflection leaves.
float sky_fresnel(float roughness, float n_dot_v) {
	vec4 r = roughness * vec4(-1.0, -0.0275, -0.572, 0.022) + vec4(1.0, 0.0425, 1.04, -0.04);
	float a004 = min(r.x * r.x, exp2(-9.28 * n_dot_v)) * r.x + r.y;
	vec2 env = vec2(-1.04, 1.04) * a004 + r.zw;
	return WATER_F0 * env.x + env.y;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
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

void fragment() {
	float level = NODE_POSITION_WORLD.y;
	vec3 to_camera = CAMERA_POSITION_WORLD - world_pos;
	vec3 v = normalize(to_camera);
	bool skirt = world_pos.y > level + 0.01;
	vec2 xz = world_pos.xz;

	// The shore: distance to the waterline (+ over the water), distance offshore, fetch.
	vec2 suv = (xz - shore_rect.xy) / shore_rect.zw;
	vec4 sm = texture(shore_map, suv);
	float inside = smoothstep(0.0, 0.05, min(min(suv.x, suv.y), min(1.0 - suv.x, 1.0 - suv.y)));
	float d_fine = mix(16.0, (sm.r - 0.5) * 32.0, inside);
	float d_coarse = mix(1024.0, sm.g * sm.g * 1024.0, inside);
	float fetch = mix(4096.0, sm.b * sm.b * 4096.0, inside);
	if (skirt) {
		d_fine = 16.0;
		d_coarse = 1024.0;
		fetch = 4096.0;
	}

	float wind = radians(wind_bearing_deg);
	vec2 wind_dir = vec2(sin(wind), -cos(wind));
	// Screen derivatives of the plan position, taken once: the layers' texture reads
	// sit in a loop that skips faded layers, so they take explicit gradients. The
	// larger is the metres per pixel that sets each layer's mip level.
	vec2 dx = dFdx(xz);
	vec2 dy = dFdy(xz);
	float footprint = max(length(dx), length(dy));
	float wind_turn = atan(wind_dir.y, wind_dir.x);

	float gust = 1.0;
	float ripple = 1.0;
#ifndef WATER_SIMPLE
	// Wind frame: along and across the wind; each drift wraps with the hour.
	vec2 wf = vec2(dot(xz, wind_dir), dot(xz, vec2(-wind_dir.y, wind_dir.x)));
	float g1 = wrap_noise(vec2(wf.x / 140.0 - TIME * 64.0 / 3600.0, wf.y / 140.0), 64.0);
	float g2 = wrap_noise(vec2(wf.x / 47.0 - TIME * 192.0 / 3600.0, wf.y / 47.0 + 17.3), 192.0);
	float g3 = wrap_noise(vec2(wf.x / 380.0 - TIME * 24.0 / 3600.0, wf.y / 380.0 + 5.1), 24.0);
	gust = mix(gust_range.x, gust_range.y, g1 * 0.65 + g2 * 0.35);
	ripple = mix(ripple_range.x, ripple_range.y, smoothstep(0.15, 0.85, g3 * 0.55 + g1 * 0.45));
#endif
	// The islands' lee is calmer: less wind reaches it, so the finest ripples drop too.
	float lee = mix(lee_floor, 1.0, 1.0 - exp(-fetch / (fetch_per_tile * 4.0)));
	ripple *= lee;

	vec2 slope = vec2(0.0);
	float lost = slope_micro * slope_micro * ripple;
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
		float lod = log2(max(footprint * TILE_TEXELS / size, 1e-6));
		float kept = skirt ? 0.0 : mip_kept(lod);
		lost += k * k * (1.0 - kept);
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
	vec3 n = normalize(vec3(-slope.x, 1.0, -slope.y));
	// Keep facets that face away from a grazing eye from going black.
	n = normalize(n + max(0.0, 0.05 - dot(n, v)) * v);
	if (skirt) {
		n = vec3(0.0, 1.0, 0.0);
	}
	glitter_alpha2 = clamp(lost, 0.0002, 0.25);
	float roughness = sqrt(sqrt(clamp(sky_alpha2 * ripple + sky_lost_share * lost, 0.0002, 0.25)));

	// Water body: a little greener and murkier near the shore, clearer over the
	// stones at the toe.
	float near = 1.0 - smoothstep(10.0, shore_color_reach_m, d_coarse);
	vec3 body = mix(bay_color, shore_color, near);
	float fresnel = sky_fresnel(roughness, max(dot(n, v), 1e-4));
	float opacity = mix(shallow_alpha, 1.0, smoothstep(0.0, clear_reach_m, d_fine));

	// Wash at the waterline: a thin, broken band that comes and goes with the waves.
	float wash = 1.0 - smoothstep(0.1, foam_reach_m, d_fine);
	float surge = 0.5 + 0.5 * sin(TIME * 1.3 - d_fine * 2.6 + swell * 6.0);
	float foam = foam_strength * wash * smoothstep(0.55, 0.95, crest * 0.5 + swell * 0.45 + surge * 0.35);
	foam *= step(-0.3, d_fine);

	float alpha = mix(opacity, 1.0, foam);
	ALBEDO = mix(body * (1.0 - fresnel), foam_color, foam) * alpha;
	ALPHA = alpha;
	METALLIC = 0.0;
	SPECULAR = mix(0.354, 0.1, foam);
	ROUGHNESS = mix(roughness, 0.8, foam);
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
	SPECULAR_LIGHT += LIGHT_COLOR * ATTENUATION * n_dot_l * ggx * vis * f * SPECULAR_AMOUNT * glitter_gain;
}
