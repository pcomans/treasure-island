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
// value noise in the same coordinates, offset by each instance's seed (a
// barge's stretched hull and deck modules use metres along the barge instead).
// Heavier weathering spreads and deepens the rust. A rubble pile's fines are
// cells of small broken pieces, and a barge deck shows its steel plates.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;

// Parts (tools/lib/street-yard-kit.mjs YARD_KIT_PARTS), 48 used of 64 slots;
// the arrays below have one entry per part, and the parts the shader treats
// specially are named (tools/validate_godot_world.mjs checks both against
// YARD_KIT_PARTS).
const int PART_COUNT = 48;
const int PART_PAINT = 0;
const int PART_CONTAINER_ROOF = 17;
const int PART_CONTAINER_DOOR = 18;
const int PART_RUBBLE = 29;
const int PART_PLASTIC = 30;
const int PART_HULL = 33;
const int PART_DECK = 35;
// SOURCE: 0 the part's own colour, 1 primary, 2 secondary, 3 tertiary paint.
const int SOURCE[48] = int[48](1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 1, 1, 0, 2, 3, 1, 2, 1, 0, 0, 0, 0, 0, 1, 1, 1, 0, 2, 3, 0, 1, 2, 0, 0, 0, 0, 1, 0, 0, 0);
// PATTERN: 0 none, 1 container wall, 2 container roof, 3 container door,
// 4 roll-up door, 5 ribbed wall, 6 ribbed roof, 7 wood grain, 8 aggregate,
// 9 fabric over frames (a seam every 5 m), 10 wrinkled sheeting, 11 a dirt
// ramp's packed soil.
const int PATTERN[48] = int[48](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	1, 2, 3, 0, 0, 0, 4, 5, 6, 9, 7, 8, 8, 8, 10, 8, 0, 0, 10, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 11);
const float ROUGH[48] = float[48](0.38, 0.38, 0.05, 0.86, 0.35, 0.55, 0.6, 0.14, 0.07, 0.12, 0.5, 0.95, 0.42, 0.55, 0.45, 0.42,
	0.55, 0.62, 0.55, 0.6, 0.45, 0.4, 0.5, 0.5, 0.48, 0.85, 0.9, 0.95, 0.95, 0.92, 0.6, 0.9, 0.5, 0.75, 0.55, 0.85, 0.6, 0.95, 0.25, 0.85, 0.5, 0.8, 0.45, 0.55, 0.6, 0.8, 0.95, 0.95);
const float METAL[48] = float[48](0.0, 0.0, 0.0, 0.0, 0.85, 0.3, 0.0, 1.0, 0.55, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.75,
	0.25, 0.2, 0.25, 0.25, 0.7, 0.0, 0.3, 0.3, 0.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.1, 0.3, 0.0, 0.2, 0.15, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.3, 0.2, 0.0, 0.0, 0.0);
const float SPEC[48] = float[48](0.5, 0.5, 0.8, 0.3, 0.5, 0.4, 0.4, 0.5, 0.6, 0.5, 0.4, 0.2, 0.4, 0.5, 0.5, 0.5,
	0.45, 0.4, 0.45, 0.4, 0.5, 0.5, 0.45, 0.45, 0.45, 0.35, 0.3, 0.25, 0.25, 0.3, 0.45, 0.3, 0.5, 0.4, 0.4, 0.35, 0.45, 0.2, 0.6, 0.35, 0.4, 0.3, 0.45, 0.45, 0.45, 0.3, 0.25, 0.25);
// How strongly each part rusts and gathers grime (scaled by the instance's level).
const float RUST[48] = float[48](0.03, 0.03, 0.0, 0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25,
	1.0, 1.0, 0.8, 1.3, 0.6, 0.03, 0.15, 0.2, 0.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.25, 1.0, 0.0, 0.9, 0.2, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.15, 0.9, 0.0, 0.0, 0.0);
const float GRIME[48] = float[48](0.55, 0.55, 0.0, 0.0, 0.3, 0.0, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.4,
	1.0, 0.6, 1.0, 1.0, 0.6, 0.35, 0.6, 0.8, 0.5, 0.9, 0.5, 0.0, 0.0, 0.0, 0.3, 0.8, 0.6, 0.8, 0.0, 0.6, 0.8, 0.0, 0.4, 0.6, 0.4, 0.0, 0.6, 0.5, 0.8, 0.2, 0.0, 0.0);
const vec3 RUST_COLOUR = vec3(0.235, 0.075, 0.025); // linear; about sRGB (0.52, 0.30, 0.17)
const vec3 DIRT_COLOUR = vec3(0.16, 0.12, 0.08); // linear; about sRGB (0.44, 0.38, 0.31)

varying flat int part;
varying vec3 v_pos;
varying vec3 v_normal_model;
varying float v_u;
varying float v_w;
varying vec3 v_across;
varying vec3 v_along;
varying flat vec4 v_custom;
// A barge's surface coordinates in world metres: along the profile direction
// and the second direction (one varying, to stay well inside the
// Compatibility renderer's varying budget).
varying vec2 v_barge;

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

// Cells of packed broken pieces round x (unit cells): the gap to the nearest
// cell border (0 on it) and the cell's own random value.
vec2 cells(vec2 x) {
	vec2 n = floor(x);
	vec2 f = fract(x);
	float d1 = 8.0;
	float d2 = 8.0;
	vec2 id = n;
	for (int j = -1; j <= 1; j++) {
		for (int i = -1; i <= 1; i++) {
			vec2 g = vec2(float(i), float(j));
			vec2 r = g + vec2(hash12(n + g), hash12(n + g + 17.3)) - f;
			float d = dot(r, r);
			if (d < d1) {
				d2 = d1;
				d1 = d;
				id = n + g;
			} else if (d < d2) {
				d2 = d;
			}
		}
	}
	return vec2(sqrt(d2) - sqrt(d1), hash12(id + 3.1));
}

vec3 paint(float column) {
	return texture(palette, vec2(column, 0.75)).rgb;
}

void vertex() {
	part = clamp(int(UV.x * 64.0), 0, PART_COUNT - 1);
	v_pos = VERTEX;
	v_normal_model = NORMAL;
	v_custom = INSTANCE_CUSTOM;
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
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
	v_barge.x = dot(world, normalize((MODEL_MATRIX * vec4(across, 0.0)).xyz));
	v_across = normalize((MODELVIEW_MATRIX * vec4(across, 0.0)).xyz);
	// The second direction in the surface, for sheeting wrinkles.
	vec3 along = normalize(cross(NORMAL, across) + vec3(0.0, 1e-5, 0.0));
	v_w = dot(VERTEX, along);
	v_barge.y = dot(world, normalize((MODEL_MATRIX * vec4(along, 0.0)).xyz));
	v_along = normalize((MODELVIEW_MATRIX * vec4(along, 0.0)).xyz);
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
	// Weathering coordinates: along the face and up, or the plan on a roof. A
	// barge's hull and deck are modules stretched per instance, so they take
	// metres along the barge instead, or their weathering would stretch with them.
	vec2 w = roof ? v_pos.xz : vec2(v_u, v_pos.y);
	bool barge = p == PART_HULL || p == PART_DECK;
	if (barge) {
		w = roof ? v_barge.yx : vec2(v_barge.x, v_pos.y);
	}
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
		// Sharp up close; a sine of the same pitch once a period spans a few
		// pixels (a sharp flank there aliases into arcs at grazing angles);
		// gone below about 2.5 pixels a period, leaving its average shade.
		float footprint = fwidth(v_u) / pitch;
		vec2 wave = sine_profile(v_u, pitch);
		vec2 shape = mix(profile, vec2(wave.x * 0.6, wave.y), smoothstep(0.05, 0.16, footprint));
		float keep = 1.0 - smoothstep(0.26, 0.4, footprint);
		NORMAL = normalize(NORMAL + v_across * shape.x * tilt * keep);
		// Valleys and flanks hold a little shade; far away, their average.
		float shade = mix(0.88, 1.0, shape.y);
		albedo *= mix(0.94, shade, keep);
	}
	// Vehicle paint: a little tone from panel to panel and dirt runs down
	// from the roof line (RV sidewalls especially).
	if (p == PART_PAINT) {
		albedo *= 0.96 + 0.06 * hash12(floor(vec2(v_u / 1.4, v_pos.y / 0.9)) + seed * 3.0);
		float run = roof ? 0.0 : smoothstep(0.6, 0.9, vnoise(vec2(ws.x * 2.5, 0.0))) * smoothstep(0.4, 2.2, v_pos.y);
		albedo *= 1.0 - (0.08 + 0.15 * level) * run * (1.0 - smoothstep(0.3, 0.8, fwidth(ws.x) * 2.5));
	}
	if (pattern == 9) {
		// The membrane's seams over the portal frames, every 5 m.
		float frame = abs(fract((v_u + 2.5) / 5.0 + 0.5) - 0.5) * 5.0;
		float seam = 1.0 - smoothstep(0.04, 0.09 + fwidth(v_u), frame);
		albedo *= 1.0 - 0.22 * seam;
	} else if (pattern == 10) {
		// Plastic sheeting and tarps: folds and wrinkles tilt the normal (the
		// berms' sheeting is stretched tighter than a loose tarp).
		vec2 q = vec2(v_u, v_w) * 0.9 + seed * 17.0;
		float e = 0.07;
		float n0 = fbm(q);
		vec2 g = vec2(fbm(q + vec2(e, 0.0)) - n0, fbm(q + vec2(0.0, e)) - n0) / e;
		float keep = 1.0 - smoothstep(0.6, 2.4, fwidth(v_u) * 0.9);
		NORMAL = normalize(NORMAL + (v_across * g.x + v_along * g.y) * (p == PART_PLASTIC ? 0.14 : 0.22) * keep);
		albedo *= 0.85 + 0.3 * n0;
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
		if (p == PART_RUBBLE) {
			// A rubble pile's fines are small broken pieces in soil: cells of
			// about 0.17 m, each its own shade and tilt (some dark soil), with
			// shadow between.
			vec2 x = v_pos.xz * 6.0;
			vec2 c = cells(x);
			float near = 1.0 - smoothstep(0.12, 0.35, fwidth(x.x));
			float gap = smoothstep(0.0, 0.06, c.x);
			float tone = c.y < 0.28 ? 0.66 : 0.84 + 0.36 * c.y;
			albedo *= mix(0.9, mix(0.8, tone, gap), near);
			vec2 tilt = vec2(hash12(vec2(c.y, 1.7)), hash12(vec2(c.y, 5.3))) - 0.5;
			NORMAL = normalize(NORMAL + (v_across * tilt.x + v_along * tilt.y) * 0.6 * near * gap);
		}
	} else if (pattern == 11) {
		// A dirt car ramp (stunt_ramp, tools/lib/street-yard-meshes.mjs): its
		// run and top, and the spoil round its foot, dry and dusty with a fine
		// grain, small stones and two darker bands worn by tyres along Z; its
		// sides (facing across, or the back slope) fresher and darker, rills
		// running down them and clods. Fine detail gives way to its average
		// with distance.
		vec2 g = v_pos.xz + seed * 23.0;
		float fw = max(fwidth(g.x), fwidth(g.y));
		float near = 1.0 - smoothstep(0.015, 0.07, fw);
		float fine = 1.0 - smoothstep(0.005, 0.018, fw);
		float coarse = fbm(g * 0.8);
		float grain = vnoise(g * 26.0);
		vec2 c = cells(g * 6.5);
		if (abs(v_normal_model.x) > 0.3 || v_normal_model.z < -0.2) {
			float rill = vnoise(vec2(v_pos.z * 3.5 + seed * 11.0, (v_pos.y + abs(v_pos.x)) * 0.7));
			float clod = smoothstep(0.0, 0.12, c.x) * near;
			albedo *= vec3(0.82, 0.76, 0.7) * (0.8 + 0.3 * rill) * (0.85 + 0.3 * coarse) * mix(1.0, 0.82 + 0.3 * c.y, clod) * (1.0 + 0.16 * (grain - 0.5) * fine);
		} else {
			float worn = 1.0 - smoothstep(0.16, 0.42, abs(abs(v_pos.x) - 0.82));
			float streak = vnoise(vec2(v_pos.x * 10.0, v_pos.z * 0.6) + seed * 7.0);
			float stone = smoothstep(0.86, 0.97, c.y) * smoothstep(0.02, 0.1, c.x) * near;
			albedo *= vec3(1.06, 1.05, 1.03) * (0.84 + 0.26 * coarse) * (1.0 - 0.16 * worn * (0.55 + 0.45 * streak)) * (1.0 + 0.2 * (grain - 0.5) * fine) * (1.0 + 0.35 * stone);
			if (v_pos.y < 0.06 && v_normal_model.y > 0.98) {
				// The spoil round the foot: looser, a touch lighter, in clods.
				albedo *= 1.05 * mix(1.0, 0.88 + 0.3 * c.y, smoothstep(0.0, 0.15, c.x) * near);
			}
		}
		// The grain tilts the normal a little near the camera.
		vec2 dg = vec2(vnoise(g * 26.0 + vec2(0.04, 0.0)) - grain, vnoise(g * 26.0 + vec2(0.0, 0.04)) - grain) / 0.04;
		NORMAL = normalize(NORMAL + (v_across * dg.x + v_along * dg.y) * 0.006 * fine);
	}
	// Container door markings: two small blocks of dark text near the top.
	if (p == PART_CONTAINER_DOOR) {
		vec2 d = v_pos.xy;
		bool block = (d.x > 0.28 && d.x < 0.98 && d.y > 2.0 && d.y < 2.2) || (d.x > 0.28 && d.x < 0.7 && d.y > 1.84 && d.y < 1.94);
		if (block) {
			float glyph = step(0.42, hash12(floor(vec2(d.x * 42.0, d.y * 22.0)) + seed * 31.0));
			float keep = 1.0 - smoothstep(0.3, 0.8, fwidth(d.x) * 42.0);
			albedo = mix(albedo, vec3(0.012), glyph * keep * 0.85 + (1.0 - keep) * 0.25);
		}
	}
	// A barge deck's steel plates: seams and a little tone plate to plate.
	if (p == PART_DECK && roof) {
		vec2 plate = vec2(v_barge.x / 9.1, v_barge.y / 2.44);
		vec2 to_seam = abs(fract(plate + 0.5) - 0.5) * vec2(9.1, 2.44);
		vec2 fw = fwidth(plate) * vec2(9.1, 2.44);
		float seam = 1.0 - smoothstep(0.0, 0.03 + fw.x, to_seam.x) * smoothstep(0.0, 0.03 + fw.y, to_seam.y);
		float near = 1.0 - smoothstep(0.1, 0.4, max(fw.x, fw.y));
		albedo *= (0.94 + 0.12 * hash12(floor(plate) + seed * 5.0)) * (1.0 - 0.3 * seam * near);
	}
	// Sun-faded container roofs (the May 2026 aerial: red boxes read salmon from above).
	if (p == PART_CONTAINER_ROOF) {
		albedo = mix(albedo, vec3(0.45), 0.35);
	}
	// Rust: a few patches, thin streaks running down from the top rail, and
	// the bottom edge. The fine noise gives way to its average with distance,
	// so it never aliases into arcs.
	float rust_amount = RUST[p] * level;
	if (rust_amount > 0.0) {
		// Heavier weathering spreads the patches and deepens them.
		float cover = clamp(rust_amount, 0.0, 1.0);
		float detail = 1.0 - smoothstep(0.25, 0.6, fwidth(ws.x) * 7.0);
		float patches = smoothstep(0.7 - 0.22 * cover, 0.84 - 0.16 * cover, fbm(ws * 0.7));
		float spots = smoothstep(0.78, 0.9, fbm(ws * 3.3 + 5.0)) * 0.5 * detail;
		float streak_noise = mix(0.35, vnoise(vec2(ws.x * 7.0, 0.5)), detail);
		float streak = roof ? 0.0 : smoothstep(0.55, 0.9, streak_noise) * smoothstep(0.9, 2.45, v_pos.y) * 0.8;
		float edge = roof ? 0.0 : smoothstep(0.3, 0.0, v_pos.y) * 0.6;
		float rust = clamp(patches * (0.1 + 1.05 * cover * cover) + (spots + streak * 0.7 + edge) * rust_amount, 0.0, 0.88);
		// A barge's rust is old and dark; a container's fresh and orange.
		vec3 rust_colour = barge ? RUST_COLOUR * 0.5 : RUST_COLOUR;
		albedo = mix(albedo, rust_colour * (0.85 + 0.3 * mix(0.5, vnoise(ws * 5.0), detail)), rust);
	}
	// Grime: dirt splashed up from the ground and a light, uneven film.
	float grime = GRIME[p] * (0.35 + 0.65 * level);
	if (grime > 0.0) {
		float splash = roof ? 0.0 : smoothstep(0.6, 0.0, v_pos.y) * (0.6 + 0.4 * vnoise(ws * 2.0));
		albedo = mix(albedo, DIRT_COLOUR, clamp(splash * 0.4 * grime, 0.0, 0.45));
		albedo *= 1.0 - 0.06 * grime * fbm(ws * 0.35);
	}
	ALBEDO = albedo;
	ROUGHNESS = ROUGH[p];
	METALLIC = METAL[p];
	SPECULAR = SPEC[p];
	AO = UV.y;
	AO_LIGHT_AFFECT = 0.45;
}
