shader_type spatial;
// The yard kit (game/scripts/world/street_yard_kit.gd): containers, sheds,
// vehicles, piles and barges from street_yard_kit.glb. Every vertex names its
// part in UV.x ((part + 0.5) / 64) and carries baked occlusion in UV.y. Part
// colours and the named paints are one small palette texture (row 0 the
// parts, row 1 the paints; source_color, so each renderer brings the sRGB
// colours into its own lighting space). A piece is a MultiMesh instance whose
// custom data picks three paints (r primary, g secondary, b tertiary: palette
// columns) and packs its weathering and seed in a ((level + seed) / 16).
//
// Corrugation and ribs are drawn here, from the vertex's model-space
// position: the normal tilts across a trapezoid, sine or rib profile running
// horizontally on walls, along Z on roofs and up a roll-up door; the tilt
// fades out as the profile shrinks below a few pixels, so distant walls keep
// their average shade without shimmering. Weathering (rust patches, streaks
// under the top rail, dirt splashed up from the ground, sun-faded roofs) is
// value noise in the same coordinates, offset by each instance's seed.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;

// Parts (tools/lib/street-yard-kit.mjs YARD_KIT_PARTS), 46 used of 64 slots.
// SOURCE: 0 the part's own colour, 1 primary, 2 secondary, 3 tertiary paint.
const int SOURCE[46] = int[46](1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1, 1, 0, 2, 3, 1, 2, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 2, 3, 0, 1, 2, 0, 0, 0, 0, 1, 0);
// PATTERN: 0 none, 1 container wall, 2 container roof, 3 container door,
// 4 roll-up door, 5 ribbed wall, 6 ribbed roof, 7 wood grain, 8 aggregate.
const int PATTERN[46] = int[46](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 2, 3, 0, 0, 0, 4, 5, 6, 0, 7, 8, 8, 8, 0, 8, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0);
const float ROUGH[46] = float[46](0.38, 0.38, 0.05, 0.86, 0.35, 0.55, 0.6, 0.14, 0.07, 0.12, 0.5, 0.95, 0.42, 0.55, 0.45, 0.42,
	0.55, 0.62, 0.55, 0.6, 0.45, 0.4, 0.5, 0.5, 0.48, 0.85, 0.9, 0.95, 0.95, 0.92, 0.28, 0.9, 0.5, 0.75, 0.6, 0.85, 0.6, 0.95, 0.25, 0.85, 0.5, 0.8, 0.45, 0.55, 0.6, 0.8);
const float METAL[46] = float[46](0.0, 0.0, 0.0, 0.0, 0.85, 0.3, 0.0, 1.0, 0.55, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.75,
	0.25, 0.2, 0.25, 0.25, 0.7, 0.0, 0.3, 0.3, 0.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.3, 0.0, 0.2, 0.15, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.3, 0.2, 0.0);
const float SPEC[46] = float[46](0.5, 0.5, 0.8, 0.3, 0.5, 0.4, 0.4, 0.5, 0.6, 0.5, 0.4, 0.2, 0.4, 0.5, 0.5, 0.5,
	0.45, 0.4, 0.45, 0.4, 0.5, 0.5, 0.45, 0.45, 0.45, 0.35, 0.3, 0.25, 0.25, 0.3, 0.65, 0.3, 0.5, 0.4, 0.4, 0.35, 0.45, 0.2, 0.6, 0.35, 0.4, 0.3, 0.45, 0.45, 0.45, 0.3);
// How strongly each part rusts and gathers grime (scaled by the instance's level).
const float RUST[46] = float[46](0.03, 0.03, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25,
	1.0, 1.0, 0.8, 1.3, 0.6, 0.03, 0.15, 0.2, 0.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 1.0, 0.0, 0.9, 0.2, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.15, 0.5, 0.0);
const float GRIME[46] = float[46](0.35, 0.35, 0.0, 0.0, 0.3, 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.4,
	1.0, 0.6, 1.0, 1.0, 0.6, 0.35, 0.6, 0.8, 0.5, 0.9, 0.5, 0.0, 0.0, 0.0, 0.3, 0.8, 0.6, 0.8, 0.0, 0.6, 0.8, 0.0, 0.4, 0.6, 0.4, 0.0, 0.6, 0.5, 0.8, 0.2);
const vec3 RUST_COLOUR = vec3(0.13, 0.043, 0.016); // linear; about sRGB (0.40, 0.23, 0.13)
const vec3 DIRT_COLOUR = vec3(0.16, 0.12, 0.08); // linear; about sRGB (0.44, 0.38, 0.31)

varying flat int part;
varying vec3 v_pos;
varying vec3 v_normal_model;
varying float v_u;
varying vec3 v_across;
varying flat vec4 v_custom;

float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 w = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash12(i), hash12(i + vec2(1.0, 0.0)), w.x), mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), w.x), w.y);
}

float fbm(vec2 p) {
	return 0.55 * vnoise(p) + 0.3 * vnoise(p * 2.13 + 7.1) + 0.15 * vnoise(p * 4.37 + 3.3);
}

vec3 paint(float column) {
	return texture(palette, vec2(column, 0.75)).rgb;
}

void vertex() {
	part = clamp(int(UV.x * 64.0), 0, 45);
	v_pos = VERTEX;
	v_normal_model = NORMAL;
	v_custom = INSTANCE_CUSTOM;
	// The direction the profile varies along: up a roll-up door, along Z on a
	// roof, horizontally across any wall.
	vec3 across;
	if (PATTERN[part] == 4) {
		across = vec3(0.0, 1.0, 0.0);
	} else if (abs(NORMAL.y) > 0.7) {
		across = vec3(0.0, 0.0, 1.0);
	} else {
		across = normalize(vec3(-NORMAL.z, 0.0, NORMAL.x) + vec3(1e-5, 0.0, 0.0));
	}
	v_u = dot(VERTEX, across);
	v_across = normalize((MODELVIEW_MATRIX * vec4(across, 0.0)).xyz);
}

// A profile's slope (normal tilt) and its height (0 valley .. 1 crest) at u.
vec2 trapezoid(float u, float pitch) {
	float t = fract(u / pitch);
	// crest 0.30, flank 0.15, valley 0.40, flank 0.15
	if (t < 0.30) return vec2(0.0, 1.0);
	if (t < 0.45) return vec2(-1.0, 1.0 - (t - 0.30) / 0.15);
	if (t < 0.85) return vec2(0.0, 0.0);
	return vec2(1.0, (t - 0.85) / 0.15);
}

vec2 sine_profile(float u, float pitch) {
	float a = 6.2831853 * u / pitch;
	return vec2(cos(a), 0.5 + 0.5 * sin(a));
}

vec2 rib_profile(float u, float pitch) {
	float t = fract(u / pitch);
	// A flat pan with a narrow trapezoid rib.
	if (t < 0.06) return vec2(1.0, t / 0.06);
	if (t < 0.14) return vec2(0.0, 1.0);
	if (t < 0.2) return vec2(-1.0, 1.0 - (t - 0.14) / 0.06);
	return vec2(0.0, 0.0);
}

void fragment() {
	int p = part;
	float level = floor(v_custom.a * 16.0) / 15.0;
	float seed = fract(v_custom.a * 16.0);
	// Colour.
	int source = SOURCE[p];
	vec3 albedo;
	if (source == 1) {
		albedo = paint(v_custom.r);
	} else if (source == 2) {
		albedo = paint(v_custom.g);
	} else if (source == 3) {
		albedo = paint(v_custom.b);
	} else {
		albedo = texture(palette, vec2((float(p) + 0.5) / 64.0, 0.25)).rgb;
	}
	// Two boxes of one paint are never quite the same shade.
	if (source != 0) {
		albedo *= 0.95 + 0.1 * fract(seed * 7.13 + 0.37);
	}
	bool roof = abs(v_normal_model.y) > 0.7;
	// Weathering coordinates: along the face and up, or the plan on a roof.
	vec2 w = roof ? v_pos.xz : vec2(v_u, v_pos.y);
	vec2 ws = w + vec2(seed * 137.0, seed * 59.0);
	// Profiles.
	int pattern = PATTERN[p];
	vec2 profile = vec2(0.0, 0.5);
	float pitch = 1.0;
	float tilt = 0.0;
	if (pattern == 1) {
		pitch = 0.278;
		profile = trapezoid(v_u, pitch);
		tilt = 0.75;
	} else if (pattern == 2) {
		pitch = 0.46;
		profile = sine_profile(v_u, pitch);
		tilt = 0.22;
	} else if (pattern == 3) {
		pitch = 0.3;
		profile = trapezoid(v_u + 0.07, pitch);
		tilt = 0.6;
	} else if (pattern == 4) {
		pitch = 0.075;
		profile = sine_profile(v_u, pitch);
		tilt = 0.45;
	} else if (pattern == 5) {
		pitch = 0.305;
		profile = rib_profile(v_u, pitch);
		tilt = 0.7;
	} else if (pattern == 6) {
		pitch = 0.305;
		profile = rib_profile(v_u, pitch);
		tilt = 0.55;
	}
	if (pattern >= 1 && pattern <= 6) {
		// Fade the profile out where it shrinks below a few pixels.
		float footprint = fwidth(v_u) / pitch;
		float keep = 1.0 - smoothstep(0.18, 0.45, footprint);
		NORMAL = normalize(NORMAL + v_across * profile.x * tilt * keep);
		// Valleys and flanks hold a little shade; far away, their average.
		float shade = mix(0.86, 1.0, profile.y);
		albedo *= mix(0.93, shade, keep);
	}
	if (pattern == 7) {
		// Wood grain along the length and plank-to-plank shade.
		float grain = vnoise(vec2(v_pos.x * 40.0 + v_pos.y * 40.0, v_pos.z * 1.5) + seed * 9.0);
		albedo *= 0.82 + 0.3 * grain;
	} else if (pattern == 8) {
		// Aggregate, soil and broken concrete: coarse and fine variation.
		vec2 g = v_pos.xz + v_pos.y;
		float coarse = fbm(g * 0.6 + seed * 13.0);
		float fine = vnoise(g * 9.0);
		float keep = 1.0 - smoothstep(0.3, 1.2, fwidth(g.x) * 9.0);
		albedo *= 0.75 + 0.4 * coarse + 0.25 * (fine - 0.5) * keep;
	}
	// Container door markings: two small blocks of dark text near the top.
	if (p == 18) {
		vec2 d = v_pos.xy;
		bool block = (d.x > 0.28 && d.x < 0.98 && d.y > 2.0 && d.y < 2.2) || (d.x > 0.28 && d.x < 0.7 && d.y > 1.84 && d.y < 1.94);
		if (block) {
			float glyph = step(0.42, hash12(floor(vec2(d.x * 42.0, d.y * 22.0)) + seed * 31.0));
			float keep = 1.0 - smoothstep(0.3, 0.8, fwidth(d.x) * 42.0);
			albedo = mix(albedo, vec3(0.012), glyph * keep * 0.85 + (1.0 - keep) * 0.25);
		}
	}
	// Sun-faded container roofs (the May 2026 aerial: red boxes read salmon from above).
	if (p == 17) {
		albedo = mix(albedo, vec3(0.45), 0.35);
	}
	// Rust: patches, streaks running down from the top rail, and the bottom edge.
	float rust_amount = RUST[p] * level;
	if (rust_amount > 0.0) {
		float patches = smoothstep(0.6, 0.78, fbm(ws * 0.8));
		float spots = smoothstep(0.72, 0.86, fbm(ws * 3.3 + 5.0)) * 0.7;
		float streak = roof ? 0.0 : smoothstep(0.55, 0.9, vnoise(vec2(ws.x * 7.0, 0.5))) * smoothstep(0.9, 2.45, v_pos.y) * (0.6 + 0.4 * vnoise(vec2(ws.x * 7.0, ws.y * 1.5)));
		float edge = roof ? 0.0 : smoothstep(0.32, 0.0, v_pos.y) * 0.7;
		float rust = clamp((patches * 0.75 + spots + streak * 0.8 + edge) * rust_amount, 0.0, 0.92);
		albedo = mix(albedo, RUST_COLOUR * (0.75 + 0.5 * vnoise(ws * 5.0)), rust);
	}
	// Grime: dirt splashed up from the ground and a broad, uneven film.
	float grime = GRIME[p] * (0.35 + 0.65 * level);
	if (grime > 0.0) {
		float splash = roof ? 0.0 : smoothstep(0.75, 0.0, v_pos.y) * (0.6 + 0.4 * vnoise(ws * 2.0));
		albedo = mix(albedo, DIRT_COLOUR, clamp(splash * 0.55 * grime, 0.0, 0.6));
		albedo *= 1.0 - 0.12 * grime * fbm(ws * 0.35);
	}
	ALBEDO = albedo;
	ROUGHNESS = ROUGH[p];
	METALLIC = METAL[p];
	SPECULAR = SPEC[p];
	AO = UV.y;
	AO_LIGHT_AFFECT = 0.45;
}
