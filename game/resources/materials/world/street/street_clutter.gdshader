shader_type spatial;
// The street-clutter kit (game/scripts/world/street_clutter_kit.gd): parked and
// driven cars, cones, barricades, dumpsters and planters from
// street_clutter_kit.glb and street_car_hero_kit.glb. Every vertex names its
// part in UV.x, (part + 0.5) / 32, and carries baked occlusion in UV.y (a tyre
// vertex its place across the tyre's section instead). Part colours and the car
// paints are one small palette texture (source_color, so each renderer brings
// the sRGB colours into its own lighting space); each part's finish is below.
// A parked car is a MultiMesh instance whose custom data picks its paint (r:
// palette column) and style (g: bit 0-1 finish, bit 2 black roof, bit 3 dark
// rims) and carries its suspension twist (b, metres): the front-left and
// rear-right wheels rise by it, the other two drop by it, so all four tyres
// stand on uneven ground, and how dirty it is (a, 0 just washed to 1 filthy).
// A dumpster takes the instance paint the same way, with finish 3: matte,
// weathered painted steel; there a nonzero a picks its own palette column for
// the roof part (a dumpster's lids).
//
// Car paint is a base coat under a clear coat: the clear coat keeps the smooth
// surface normal while the base coat's normal is tilted flake by flake on the
// metallic and pearl finishes (sparkle up close, fading out with distance), a
// pearl also shifting hue toward grazing angles. Road dust lies on the lower
// body; a dirtier car has more of it and higher, a film of it on its hood,
// roof and trunk, grime streaking down its sides and brake dust on its rims,
// all from the car's own frame. Nothing here depends on where the sun is.
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;
// A hero wheel's own mesh, its axle along X through the origin: the tyre gets
// its tread and sidewall detail.
uniform bool wheel_local = false;

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
varying flat int style;
varying flat float dirt;
varying vec3 local_position;
varying vec3 local_normal;

void vertex() {
	part = clamp(int(UV.x * 32.0), 0, 31);
	paint_u = INSTANCE_CUSTOM.r;
	style = int(INSTANCE_CUSTOM.g * 16.0);
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
}

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
	if ((painted && finish != 3) || p == P_TRIM || (p == P_ROOF && black_roof)) {
		// Road dust on a car's lower body, thicker low down and in patches,
		// reaching higher on a dirtier car.
		float low = 1.0 - smoothstep(0.1, mix(0.5, 0.95, dirt), local_position.y);
		float patches = value_noise(local_position * vec3(7.0, 3.0, 7.0)) * 0.6 + value_noise(local_position * 31.0) * 0.4;
		float dust = low * low * (0.3 + 0.7 * patches) * mix(0.35, 0.95, dirt);
		vec3 n = normalize(local_normal);
		// A film of it on what faces up (the car's own up), on a dirty car.
		float up = smoothstep(0.55, 0.9, n.y);
		dust = max(dust, up * dirt * dirt * (0.3 + 0.7 * patches) * 0.65);
		// Grime streaking down the sides and the back: fine across, long down.
		float streaks = value_noise(vec3(local_position.x * 13.0, local_position.y * 0.9, local_position.z * 13.0));
		float upright = 1.0 - smoothstep(0.35, 0.7, abs(n.y));
		float grime = upright * dirt * smoothstep(0.45, 0.85, streaks) * (0.35 + 0.65 * patches) * 0.55;
		albedo = mix(albedo, vec3(0.3, 0.27, 0.23), dust * 0.75);
		albedo = mix(albedo, vec3(0.2, 0.18, 0.15), grime);
		float dull = max(dust, grime);
		roughness = mix(roughness, 0.9, dull);
		metallic *= 1.0 - dull;
		clearcoat *= 1.0 - dull;
	}
	if ((p == P_RIM || p == P_HUB) && dirt > 0.0) {
		// Brake dust: rims darken and dull as a car goes unwashed.
		albedo *= 1.0 - 0.45 * dirt;
		roughness = mix(roughness, 0.75, dirt * 0.6);
		metallic *= 1.0 - 0.4 * dirt;
	}
	if (p == P_TIRE && dirt > 0.0) {
		// Dried road dust on the sidewalls.
		albedo = mix(albedo, vec3(0.3, 0.27, 0.23) * 0.6, dirt * 0.35);
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
