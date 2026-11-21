shader_type spatial;
// The street-clutter kit (game/scripts/world/street_clutter_kit.gd): parked and
// driven cars, cones, barricades, dumpsters and planters from
// street_clutter_kit.glb and street_car_hero_kit.glb. Every vertex names its
// part in UV.x, (part + 0.5) / 32, and carries baked occlusion in UV.y (a tyre
// vertex its place across the tyre's section instead). Part colours and the car
// paints are one small palette texture (source_color, so each renderer brings
// the sRGB colours into its own lighting space); each part's finish is below.
// A parked car is a MultiMesh instance whose custom data picks its paint (r:
// palette column) and style and body (g: (code + 0.5) / 256, code bit 0-1
// finish, bit 2 black roof, bit 3 dark rims, bits 4-7 the body's index in
// street_clutter_kit.gd CAR_BODIES) and carries its suspension twist (b,
// metres): the front-left and rear-right wheels rise by it, the other two drop
// by it, so all four tyres stand on uneven ground, and how dirty it is (a, 0
// just washed to 1 filthy). A dumpster takes the instance paint the same way,
// with finish 3: matte, weathered painted steel; there a nonzero a picks its
// own palette column for the roof part (a dumpster's lids).
//
// Car paint is a base coat under a clear coat: the clear coat keeps the smooth
// surface normal while the base coat's normal is tilted flake by flake on the
// metallic and pearl finishes (sparkle up close, fading out with distance), a
// pearl also shifting hue toward grazing angles. Road dirt lies where a car's
// own wheels and wake throw it: a film along the lower body, a fan up the panel
// behind each wheel and a haze up its tail, higher and thicker on a dirtier car,
// then dust settled on its hood, roof and trunk, and brake dust on its rims,
// all from the car's own frame; a car with no dirt is clean. Nothing here
// depends on where the sun is.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;
// The large batches of parked cars and yard pieces (street_clutter_builder.gd with
// game/scripts/world/street_detail_batches.gd): a batch can't say which of its
// instances shows, so each one shows only within its level's range street_band
// ([begin, end] in metres; y 0: no test), measured as its small cell measured it,
// from that cell's box centre to the main camera, the same camera in the shadow and
// probe passes. The instance colour carries that centre less the instance's origin
// (xyz, in the world's frame) and 1 plus the metres the cell's far level ran on past
// its end (w): the kit's meshes have no vertex colour, which both renderers then
// take as white, so COLOR here is the instance colour. Outside its range the
// instance collapses to its origin and draws nothing.
uniform vec2 street_band = vec2(0.0);
// A hero wheel's own mesh, its axle along X through the origin: the tyre gets
// its tread and sidewall detail.
uniform bool wheel_local = false;
// A car's day-running and tail lamps: a parked car's are lit by day and go out as
// the sun sets (parked_lamps, 1 by day to 0, game/scripts/world/day_light.gd); the
// car being driven is drawn with a copy of this material with lamps_lit on, so its
// own stay lit (drivable_car.gd set_lamps_lit).
global uniform float parked_lamps;
uniform bool lamps_lit = false;
// Each car body's wheels, in the order of street_clutter_kit.gd CAR_BODIES (the
// kit sets them from its axle markers): x the front axle's z, y the rear axle's
// z (the car's frame: front -Z), z the wheel radius. One slot a body: the kit
// reports an error unless this reads [CAR_BODIES.size()], and fragment()'s
// lookup clamps to the last slot, so a new body changes both.
uniform vec4 car_axles[9];

// Parts (tools/lib/street-car-parts.mjs CAR_PARTS): paint, roof, glass, tire,
// rim, hub, trim, chrome, head_lamp, tail_lamp, plate, under, grille, orange,
// white, metal, gap, cabin, seat, headliner, gloss_black, lamp_housing,
// lamp_drl, lamp_red, lamp_amber, brake_disc, caliper, exhaust, screen, rubber,
// mirror, lamp_white.
const float PART_ROUGHNESS[32] = float[32](
	0.3, 0.3, 0.04, 0.88, 0.3, 0.6, 0.62, 0.12, 0.08, 0.14, 0.45, 0.95, 0.5, 0.55, 0.45, 0.4,
	0.95, 0.8, 0.72, 0.92, 0.06, 0.24, 0.3, 0.25, 0.2, 0.36, 0.45, 0.5, 0.08, 0.8, 0.02, 0.2);
const float PART_METALLIC[32] = float[32](
	0.0, 0.0, 0.0, 0.0, 0.9, 0.3, 0.0, 1.0, 0.6, 0.0, 0.0, 0.0, 0.1, 0.0, 0.0, 0.8,
	0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.9, 0.3, 0.8, 0.0, 0.0, 1.0, 0.0);
const float PART_SPECULAR[32] = float[32](
	0.5, 0.5, 0.5, 0.3, 0.5, 0.4, 0.4, 0.5, 0.6, 0.5, 0.4, 0.2, 0.4, 0.5, 0.5, 0.5,
	0.1, 0.3, 0.3, 0.2, 0.6, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5, 0.4, 0.6, 0.3, 0.5, 0.5);
const int P_PAINT = 0;
const int P_ROOF = 1;
const int P_GLASS = 2;
const int P_TIRE = 3;
const int P_RIM = 4;
const int P_HUB = 5;
const int P_TRIM = 6;
const int P_GRILLE = 12;
const int P_GAP = 16;
const int P_GLOSS_BLACK = 20;
const int P_DRL = 22;
const int P_LAMP_RED = 23;
const int P_SCREEN = 28;

varying flat int part;
varying flat float paint_u;
varying flat float roof_u;
// The style code (finish, black roof, dark rims) with the body above it.
varying flat int style;
varying flat float dirt;
varying vec3 local_position;
varying vec3 local_normal;

void vertex() {
	part = clamp(int(UV.x * 32.0), 0, 31);
	paint_u = INSTANCE_CUSTOM.r;
	style = int(INSTANCE_CUSTOM.g * 256.0);
	// a: a matte instance's lid paint, a car's dirt.
	bool matte = (style & 3) == 3;
	roof_u = matte ? INSTANCE_CUSTOM.a : 0.0;
	dirt = matte ? 0.0 : clamp(INSTANCE_CUSTOM.a, 0.0, 1.0);
	local_position = VERTEX;
	local_normal = NORMAL;
	// Tyre, rim and hub: the wheel follows the ground (front is -Z, right +X).
	if (part >= P_TIRE && part <= P_HUB) {
		VERTEX.y += INSTANCE_CUSTOM.b * sign(VERTEX.x) * sign(VERTEX.z);
	}
	if (street_band.y > 0.0) {
		float away = distance(MAIN_CAM_INV_VIEW_MATRIX[3].xyz, MODEL_MATRIX[3].xyz + COLOR.xyz);
		if (away < street_band.x || away > street_band.y + COLOR.a - 1.0) {
			VERTEX = vec3(0.0);
		}
	}
}

// A rotation that turns a noise lattice off the car's own axes.
const mat3 TURN = mat3(vec3(0.0, 0.8, 0.6), vec3(-0.8, 0.36, -0.48), vec3(-0.6, -0.48, 0.64));

float hash13(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.zyx + 31.32);
	return fract((p.x + p.y) * p.z);
}

vec3 hash33(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yxz + 33.33);
	return fract((p.xxy + p.yxx) * p.zyx);
}

float value_noise(vec3 p) {
	vec3 cell = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = mix(mix(hash13(cell), hash13(cell + vec3(1.0, 0.0, 0.0)), f.x), mix(hash13(cell + vec3(0.0, 1.0, 0.0)), hash13(cell + vec3(1.0, 1.0, 0.0)), f.x), f.y);
	float b = mix(mix(hash13(cell + vec3(0.0, 0.0, 1.0)), hash13(cell + vec3(1.0, 0.0, 1.0)), f.x), mix(hash13(cell + vec3(0.0, 1.0, 1.0)), hash13(cell + vec3(1.0, 1.0, 1.0)), f.x), f.y);
	return mix(a, b, f.z);
}

// Road dirt's colours (linear): dry dust, pale on dark paint, and the darker,
// browner road film that shows on light paint.
const vec3 DUST_PALE = vec3(0.42, 0.39, 0.33);
const vec3 DUST_DARK = vec3(0.1, 0.088, 0.068);

// How much dirt a wheel throws up the side behind it, 0 to 1, at q (the car's
// frame, front -Z) for a wheel on axle_z of this radius: a fan from the top of
// its arch back along the panel, highest just behind the arch and lower further
// back, reaching further and higher on a dirtier car (d).
float wheel_spray(vec3 q, float axle_z, float radius, float d) {
	float behind = q.z - axle_z;
	float reach = radius + mix(0.35, 1.2, d);
	float along = smoothstep(-0.25 * radius, 0.45 * radius, behind) * (1.0 - smoothstep(0.55 * radius, reach, behind));
	float top = max(0.05, mix(1.55, 2.3, d) * radius - 0.3 * max(0.0, behind - radius));
	return along * (1.0 - smoothstep(0.45 * top, top, q.y));
}

void fragment() {
	int p = part;
	bool black_roof = (style & 4) != 0;
	bool dark_rims = (style & 8) != 0;
	int finish = style & 3;
	// Paint and a body-colour roof take the instance paint; the rest the part colour.
	bool painted = p == P_PAINT || (p == P_ROOF && !black_roof);
	vec3 albedo;
	if (painted) {
		albedo = texture(palette, vec2(p == P_ROOF && roof_u > 0.0 ? roof_u : paint_u, 0.75)).rgb;
	} else {
		int colour = p == P_ROOF ? P_GLOSS_BLACK : (p == P_RIM && dark_rims ? P_HUB : p);
		albedo = texture(palette, vec2((float(colour) + 0.5) / 32.0, 0.25)).rgb;
	}
	float roughness = PART_ROUGHNESS[p];
	float metallic = PART_METALLIC[p];
	float specular = PART_SPECULAR[p];
	float occlusion = p == P_TIRE ? 1.0 : UV.y;
	float clearcoat = 0.0;
	vec3 emission = vec3(0.0);
	// How many metres one pixel covers here: detail finer than that fades out.
	float pixel = length(fwidth(local_position));
	float facing = clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0);
	if (p == P_GAP) {
		// A shut line or panel gap (12 mm across at the near level) fades into
		// the paint it is cut in once it is narrower than a pixel or so: the
		// far level has none, so a near car's lines are gone before it hands
		// over to the far level (from 43 m), not at the hand-over.
		float gone = smoothstep(0.012, 0.028, pixel);
		albedo = mix(albedo, texture(palette, vec2(paint_u, 0.75)).rgb, gone);
		roughness = mix(roughness, 0.5, gone);
		// Its darkening goes with it (the gap's own occlusion kept a grey
		// line), and past halfway it takes the paint's finish (clear coat,
		// flakes, dust) as the paint round it does.
		occlusion = mix(occlusion, 1.0, gone);
		painted = painted || gone > 0.5;
	}
	if (p == P_ROOF && black_roof) {
		roughness = 0.08;
		clearcoat = 1.0;
	}
	if (painted && finish != 3) {
		// 0 solid, 1 metallic, 2 pearl under one clear coat.
		clearcoat = 1.0;
		metallic = finish == 1 ? 0.62 : (finish == 2 ? 0.22 : 0.0);
		roughness = finish == 1 ? 0.38 : (finish == 2 ? 0.3 : 0.5);
		if (finish != 0) {
			// Flakes: each small cell of the base coat tilts its own way.
			float size = finish == 1 ? 0.0016 : 0.0011;
			vec3 cell = floor(local_position / size);
			vec3 tilt = hash33(cell) - 0.5;
			float fade = 1.0 - smoothstep(0.6, 2.5, pixel / size);
			NORMAL = normalize(NORMAL + tilt * (finish == 1 ? 0.2 : 0.11) * fade);
			albedo *= 1.0 + (hash13(cell + 7.0) - 0.5) * (finish == 1 ? 0.12 : 0.06) * fade;
		}
		if (finish == 2) {
			// Pearl: a warm sheen face on, cooler and lighter toward the edges.
			float edge = pow(1.0 - facing, 2.0);
			albedo = mix(albedo * vec3(1.03, 1.0, 0.96), albedo * vec3(0.9, 0.98, 1.12) + vec3(0.035, 0.04, 0.06), edge);
		} else if (finish == 1) {
			// Metallic: the flakes' flop, darker toward the edges.
			albedo *= mix(1.0, 0.78, pow(1.0 - facing, 1.5));
		}
	} else if (painted) {
		// Matte, weathered painted steel (a dumpster).
		metallic = 0.1;
		roughness = 0.72;
	}
	if (p == P_RIM && dark_rims) {
		metallic = 0.5;
		roughness = 0.42;
	}
	if (dirt > 0.0) {
		// A car's dirt (only a car carries any: every other instance's a is 0,
		// a dumpster's is its lids' paint and reads as none), all in the car's
		// own frame (front -Z, ground at y 0). How thick it lies where it lies
		// thickest rises fast at the low end, so a lightly dusty car reads from
		// the street; how far it reaches grows with the dirt. The glass stays
		// clean.
		float dense = smoothstep(0.02, 0.12, dirt) * mix(0.6, 1.0, smoothstep(0.1, 0.8, dirt));
		if ((painted && finish != 3) || p == P_TRIM || (p == P_ROOF && black_roof)) {
			vec3 q = local_position;
			vec3 n = normalize(local_normal);
			// The patterns' own seed: from the car's dirt, but two cars a little
			// apart in dirt get unrelated patterns.
			vec3 seed = hash33(vec3(dirt * 8191.0, dirt * 127.0, 3.7)) * 59.0;
			// Road film from the sills to an uneven top, higher on a dirtier car
			// and toward the rear, in soft blotches near its top and spattered
			// finely low down (the spatter's lattice turned off the car's axes,
			// so its cells don't line up into squares along the panels).
			float film_top = mix(0.36, 0.88, dirt) + 0.12 * dirt * smoothstep(-1.5, 2.0, q.z) + 0.12 * (value_noise(q * vec3(1.4, 0.0, 1.4) + seed) - 0.5);
			float up = clamp((q.y - 0.1) / max(0.05, film_top - 0.1), 0.0, 1.0);
			float blot = smoothstep(0.3, 0.7, value_noise(q * vec3(2.6, 3.4, 2.6) + seed));
			float spatter = (value_noise(TURN * q * 27.0 + seed) - 0.5) * (1.0 - smoothstep(0.012, 0.04, pixel));
			float film = (1.0 - smoothstep(mix(0.3, 0.5, dirt), 1.0, up)) * mix(1.0, blot, smoothstep(0.3, 0.9, up)) * (1.0 + 0.35 * spatter);
			// A fan up the side behind each wheel (its body's axles; a radius kept
			// above zero, so a missing marker can't make the fan's ramps undefined).
			vec4 axles = car_axles[clamp(style >> 4, 0, 8)];
			float radius = max(axles.z, 0.2);
			float spray = smoothstep(0.25, 0.6, abs(n.x)) * max(wheel_spray(q, axles.x, radius, dirt), wheel_spray(q, axles.y, radius, dirt)) * mix(0.7, 1.0, blot);
			// A haze up the tail, where the wake lays it.
			float up_tail = clamp((q.y - 0.1) / max(0.05, film_top + mix(0.1, 0.35, dirt)), 0.0, 1.0);
			float tail = smoothstep(0.35, 0.85, n.z) * (1.0 - smoothstep(0.3, 1.0, up_tail)) * (0.7 + 0.3 * value_noise(q * 3.0 + seed)) * 0.8;
			float low = clamp(max(film, max(spray, tail)) * dense, 0.0, 1.0);
			// Dust settled on what faces up, from a moderately dirty car on: light,
			// in patches about a metre across with clear paint between, so the
			// paint and its gloss still read (not a wash over the whole top).
			float patches = smoothstep(0.35, 0.8, value_noise(q * 1.2 + seed.zxy));
			float settled = smoothstep(0.5, 0.9, n.y) * smoothstep(0.25, 0.95, dirt) * 0.2 * patches;
			// The same dirt reads pale on dark paint and as a darker, browner film
			// on light paint (white, pearl, silver, light grey): one colour a car,
			// from its paint, so its trim takes the film its paint does.
			float light_paint = smoothstep(0.12, 0.3, dot(texture(palette, vec2(paint_u, 0.75)).rgb, vec3(0.2126, 0.7152, 0.0722)));
			albedo = mix(albedo, mix(DUST_PALE, DUST_DARK, light_paint), low * mix(0.75, 0.92, light_paint));
			albedo = mix(albedo, DUST_PALE, settled);
			float dust = clamp(max(low, 2.0 * settled), 0.0, 1.0);
			roughness = mix(roughness, 0.88, dust);
			metallic *= 1.0 - dust;
			// And a dusty car's clear coat dulls a little all over.
			clearcoat *= (1.0 - dust) * (1.0 - 0.2 * dirt);
		}
		if (p == P_RIM || p == P_HUB) {
			// Brake dust: rims darken and dull as a car goes unwashed.
			albedo *= 1.0 - 0.5 * dense;
			roughness = mix(roughness, 0.75, dense * 0.6);
			metallic *= 1.0 - 0.4 * dense;
		}
		if (p == P_TIRE) {
			// Dried road dust on the sidewalls.
			albedo = mix(albedo, vec3(0.3, 0.27, 0.23) * 0.6, dense * 0.4);
		}
	}
	if (p == P_GRILLE) {
		// Slats across a grille or an intake.
		float slat = fract(local_position.y / 0.024);
		float bar = smoothstep(0.3, 0.42, slat) * (1.0 - smoothstep(0.8, 0.92, slat));
		float fade = 1.0 - smoothstep(0.012, 0.05, pixel);
		albedo *= mix(1.0, mix(0.25, 2.4, bar), fade);
		roughness = mix(roughness, mix(0.9, 0.3, bar), fade);
	}
	if (p == P_TIRE && wheel_local) {
		// Across the section (UV.y): sidewall, shoulder, tread, shoulder, sidewall.
		float across = UV.y;
		float turn = atan(local_position.y, local_position.z) / TAU;
		float fade = 1.0 - smoothstep(0.004, 0.02, pixel);
		float tread = smoothstep(0.34, 0.37, across) * (1.0 - smoothstep(0.63, 0.66, across));
		float grooves = 1.0 - smoothstep(0.006, 0.012, min(min(abs(across - 0.435), abs(across - 0.5)), abs(across - 0.565)));
		float sipe = step(0.78, fract(turn * 56.0 + abs(across - 0.5) * 9.0)) * step(0.02, abs(across - 0.5));
		float cut = clamp(tread * max(grooves, sipe * 0.8), 0.0, 1.0) * fade;
		albedo *= 1.0 - 0.75 * cut;
		// Raised ribs and lettering blocks on the sidewall.
		float wall = abs(across - 0.5);
		float ribs = (1.0 - smoothstep(0.004, 0.008, abs(wall - 0.37))) + (1.0 - smoothstep(0.004, 0.008, abs(wall - 0.25)));
		float letters = step(0.29, wall) * step(wall, 0.335) * step(0.45, hash13(vec3(floor(turn * 90.0), 3.0, 1.0))) * step(fract(turn * 5.0), 0.34);
		albedo *= 1.0 + 0.28 * clamp(ribs + letters, 0.0, 1.0) * fade;
		roughness = mix(roughness, 0.7, clamp(ribs + letters, 0.0, 1.0) * fade);
	}
	if (p == P_DRL) {
		emission = vec3(1.0, 0.97, 0.92) * 2.2;
	} else if (p == P_LAMP_RED) {
		emission = vec3(1.0, 0.04, 0.02) * 1.3;
	} else if (p == P_SCREEN) {
		emission = vec3(0.05, 0.09, 0.14);
	}
	if ((p == P_DRL || p == P_LAMP_RED) && !lamps_lit && parked_lamps < 1.0) {
		emission *= parked_lamps;
	}
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = specular;
	CLEARCOAT = clearcoat;
	CLEARCOAT_ROUGHNESS = 0.05;
	EMISSION = emission;
	AO = occlusion;
	AO_LIGHT_AFFECT = 0.45;
}
