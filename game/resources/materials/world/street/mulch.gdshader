shader_type spatial;
// A bed's wood-chip mulch (game/scripts/world/mulch_ground.gd): the shared chips of
// mulch.gdshaderinc, graded per material. A mesh's vertex colour darkens it (a tree
// pit's rim and trunk); meshes without one are white.
//
// A planted bed (planted_far: a park zone's park_mulch records) blends to its planted
// colour further out, where the low plants have faded away (street_vegetation_kit.gd
// draws them to 40-70 m), so a planted bed seen from afar or from above does not read
// as bare mulch. The planted colour comes in drift-sized patches of deep green,
// grey-green and a few straw and copper accents, with a per-plant grain and a little
// mulch between, like the beds in cmg01 and the 2026 aerial. Colours are production
// inference from those photos and the kit's late-November plants.
//
// The ground dressing (game/scripts/world/ground_dressing.gd) compiles two capture
// variants, read from straight above: MULCH_CAPTURE_COLOUR draws the mulch's own colour
// unshaded, never the planted colour (its colour capture, which loose chips take on),
// MULCH_CAPTURE_PLACE its height in red, opaque, so the capture's alpha is where the
// mulch lies (the chips capture).
#ifdef MULCH_CAPTURE_COLOUR
render_mode unshaded, depth_draw_opaque, cull_back;
#endif
#ifdef MULCH_CAPTURE_PLACE
render_mode unshaded, depth_draw_opaque, cull_back;
#endif

#include "res://game/resources/materials/world/street/mulch.gdshaderinc"

uniform bool planted_far = false;
uniform vec3 planted_green : source_color = vec3(0.2, 0.31, 0.12);
uniform vec3 planted_grey : source_color = vec3(0.33, 0.4, 0.27);
uniform vec3 planted_straw : source_color = vec3(0.46, 0.4, 0.24);
uniform float blend_start_m = 32.0;
uniform float blend_end_m = 58.0;
// Drift patches about this size (m), and the per-plant grain's size.
uniform float drift_m = 3.5;
uniform float plant_m = 0.55;

varying vec3 world_position;
varying vec3 world_normal;

float planted_hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float planted_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(planted_hash(i), planted_hash(i + vec2(1.0, 0.0)), u.x), mix(planted_hash(i + vec2(0.0, 1.0)), planted_hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
#ifdef MULCH_CAPTURE_PLACE
	ALBEDO = vec3(world_position.y, 0.0, 0.0);
#else
	float foot_m = max(fwidth(world_position.x), fwidth(world_position.z));
	float along_x = length(dFdx(world_position.xz));
	float along_y = length(dFdy(world_position.xz));
	float read_m = max(min(along_x, along_y), 0.25 * max(along_x, along_y));
	vec3 albedo;
	float height;
	vec2 slope;
	float roughness;
	float ao;
	mulch_sample(world_position.xz, foot_m, read_m, albedo, height, slope, roughness, ao);
	albedo *= COLOR.rgb;
#ifdef MULCH_CAPTURE_COLOUR
	ALBEDO = albedo;
#else
	float far = planted_far ? smoothstep(blend_start_m, blend_end_m, distance(world_position, CAMERA_POSITION_WORLD)) : 0.0;
	if (far > 0.0) {
		vec2 p = world_position.xz;
		// Drift patches with hard-ish edges, a few straw accents (not on the web's
		// cheaper mulch), then each plant's crown lighter on top and mulch showing in the
		// darkest gaps.
		float patch = smoothstep(0.35, 0.65, planted_noise(p / drift_m));
		vec3 planted = mix(planted_green, planted_grey, patch);
#if CURRENT_RENDERER != RENDERER_COMPATIBILITY
		planted = mix(planted, planted_straw, smoothstep(0.68, 0.8, planted_noise(p / (drift_m * 1.7) + 31.0)) * 0.8);
#endif
		float grain = planted_noise(p / plant_m + 7.0);
		planted *= 0.7 + 0.6 * grain;
		planted = mix(albedo, planted, smoothstep(0.08, 0.3, grain));
		albedo = mix(albedo, planted, far);
	}
	ALBEDO = albedo;
	// The planted colour keeps the plain rough surface it was tuned on.
	ROUGHNESS = mix(roughness, 1.0, far);
	SPECULAR = mix(0.2, 0.5, far);
	AO = mix(ao, 1.0, far);
	AO_LIGHT_AFFECT = mulch_gap_light * (1.0 - far);
	NORMAL = normalize((VIEW_MATRIX * vec4(mulch_normal(normalize(world_normal), slope * (1.0 - far)), 0.0)).xyz);
#endif
#endif
}
