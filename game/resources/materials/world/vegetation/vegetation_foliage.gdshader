shader_type spatial;
// Street-vegetation foliage (street_vegetation_kit.gd): palm fronds, cypress
// sprays and grass clumps, alpha-scissor cards on generated atlases drawn from
// both sides. The builder authors crown-shaped normals; both faces keep them.
// Fronds and blade tips flutter and the crown sways with the shared breeze.
render_mode cull_disabled, depth_draw_opaque;

#include "res://game/resources/materials/world/vegetation/vegetation_wind.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float alpha_cutoff : hint_range(0.05, 0.95) = 0.45;
uniform float roughness : hint_range(0.0, 1.0) = 0.82;
uniform float specular : hint_range(0.0, 1.0) = 0.3;
uniform vec4 translucency : source_color = vec4(0.16, 0.2, 0.07, 1.0);
uniform vec2 texture_size = vec2(1024.0);
// Alpha gained per sampled mip level. The packed atlases keep about the same
// alpha-test coverage down their mip chain (measured 2026-11-03: unboosted, within
// 6 % of the full-size coverage to mip 5), so only a small boost is needed to hold
// thin tips; 0.25 filled the distant crowns into solid lobes.
uniform float mip_alpha_boost : hint_range(0.0, 0.5) = 0.05;
// A card seen nearly edge-on fades out below this cosine of the angle between the
// view and the card itself (not its authored crown normal), so it can't show as a
// long streak across a crown. 0 keeps every card.
uniform float edge_fade : hint_range(0.0, 0.6) = 0.0;
// Low plants (grasses, perennials, shrubs) dissolve away over fade_length_m
// before their visibility range ends, which the kit stores in the vertex
// colour's alpha in hundreds of metres, so a cell of them never pops out.
uniform bool distance_fade = false;
uniform float fade_length_m = 12.0;

varying float fade;

void vertex() {
	VERTEX += vegetation_wind(VERTEX, NORMAL, UV2, MODEL_MATRIX, TIME);
	fade = 1.0;
	if (distance_fade) {
		fade = clamp((COLOR.a * 100.0 - distance(CAMERA_POSITION_WORLD, MODEL_MATRIX[3].xyz)) / fade_length_m, 0.0, 1.0);
	}
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	// Mipmapping averages thin leaf segments toward transparency. Raise alpha
	// a little with the sampled mip level so their tips hold at a distance.
	vec2 texel = UV * texture_size;
	float lod = max(0.0, 0.5 * log2(max(dot(dFdx(texel), dFdx(texel)), dot(dFdy(texel), dFdy(texel)))));
	ALBEDO = tex.rgb * tint.rgb * COLOR.rgb;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	// The renderer flips NORMAL on back faces of double-sided materials;
	// undo that so a card is lit by its authored crown normal on both sides.
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	BACKLIGHT = translucency.rgb;
	ALPHA = tex.a * (1.0 + lod * mip_alpha_boost);
	if (edge_fade > 0.0) {
		vec3 card = normalize(cross(dFdx(VERTEX), dFdy(VERTEX)));
		ALPHA *= smoothstep(0.0, edge_fade, abs(dot(card, VIEW)));
	}
	if (fade < 1.0) {
		// Blocks of the card drop out one by one as the plant recedes.
		float noise = fract(sin(dot(floor(UV * texture_size / 6.0), vec2(12.9898, 78.233))) * 43758.5453);
		ALPHA *= step(noise, fade);
	}
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
}
