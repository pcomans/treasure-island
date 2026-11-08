shader_type spatial;
// The street-clutter kit (game/scripts/world/street_clutter_kit.gd): parked cars,
// cones and barricades from street_clutter_kit.glb. Every vertex names its part
// in UV.x (part + 0.5) / 16 and carries baked occlusion in UV.y. Part colours and
// the car paints are one small palette texture (source_color, so each renderer
// brings the sRGB colours into its own lighting space); finish (roughness and
// metallic) per part is below. A parked car is a MultiMesh instance whose custom
// data picks its paint (r: palette column) and style (g: bit 0-1 finish, bit 2
// black roof, bit 3 dark rims) and carries its suspension twist (b, metres): the
// front-left and rear-right wheels rise by it, the other two drop by it, so all
// four tyres stand on uneven ground. A dumpster takes the instance paint the same
// way, with finish 3: matte, weathered painted steel; a nonzero a picks its own
// palette column for the roof part (a dumpster's lids).
render_mode depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D palette : source_color, filter_nearest, repeat_disable;

// Parts (tools/lib/street-clutter-kit.mjs CLUTTER_KIT_PARTS): paint, roof,
// glass, tire, rim, hub, trim, chrome, head_lamp, tail_lamp, plate, under,
// grille, orange, white, metal.
const float PART_ROUGHNESS[16] = float[16](0.3, 0.3, 0.05, 0.86, 0.32, 0.55, 0.6, 0.14, 0.07, 0.12, 0.5, 0.95, 0.42, 0.55, 0.45, 0.4);
const float PART_METALLIC[16] = float[16](0.0, 0.0, 0.0, 0.0, 0.85, 0.3, 0.0, 1.0, 0.55, 0.0, 0.0, 0.0, 0.2, 0.0, 0.0, 0.8);
const float PART_SPECULAR[16] = float[16](0.5, 0.5, 0.8, 0.3, 0.5, 0.4, 0.4, 0.5, 0.6, 0.5, 0.4, 0.2, 0.4, 0.5, 0.5, 0.5);

varying flat int part;
varying flat float paint_u;
varying flat float roof_u;
varying flat int style;

void vertex() {
	part = clamp(int(UV.x * 16.0), 0, 15);
	paint_u = INSTANCE_CUSTOM.r;
	roof_u = INSTANCE_CUSTOM.a;
	style = int(INSTANCE_CUSTOM.g * 16.0);
	// Tyre, rim and hub: the wheel follows the ground (front is -Z, right +X).
	if (part >= 3 && part <= 5) {
		VERTEX.y += INSTANCE_CUSTOM.b * sign(VERTEX.x) * sign(VERTEX.z);
	}
}

void fragment() {
	int p = part;
	bool black_roof = (style & 4) != 0;
	bool dark_rims = (style & 8) != 0;
	// Paint and a body-colour roof take the instance paint; the rest the part colour.
	bool painted = p == 0 || (p == 1 && !black_roof);
	vec3 albedo;
	if (painted) {
		albedo = texture(palette, vec2(p == 1 && roof_u > 0.0 ? roof_u : paint_u, 0.75)).rgb;
	} else {
		int colour = p == 1 ? 6 : (p == 4 && dark_rims ? 5 : p);
		albedo = texture(palette, vec2((float(colour) + 0.5) / 16.0 * 0.5, 0.25)).rgb;
	}
	float roughness = PART_ROUGHNESS[p];
	float metallic = PART_METALLIC[p];
	if (painted) {
		int finish = style & 3;
		// 0 solid gloss, 1 metallic, 2 pearl, 3 matte.
		metallic = finish == 1 ? 0.55 : (finish == 2 ? 0.25 : (finish == 3 ? 0.1 : 0.0));
		roughness = finish == 1 ? 0.34 : (finish == 3 ? 0.72 : 0.26);
		// A body-colour roof is one flat panel facing the fixed sun: a touch
		// rougher, so a view low across it (a driven car's, getting out of
		// it) doesn't see it flare white.
		if (p == 1) {
			roughness += 0.14;
		}
	}
	if (p == 4 && dark_rims) {
		metallic = 0.4;
		roughness = 0.45;
	}
	ALBEDO = albedo;
	ROUGHNESS = roughness;
	METALLIC = metallic;
	SPECULAR = PART_SPECULAR[p];
	AO = UV.y;
	AO_LIGHT_AFFECT = 0.45;
}
