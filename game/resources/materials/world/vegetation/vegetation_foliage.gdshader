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

void vertex() {
	VERTEX += vegetation_wind(VERTEX, NORMAL, UV2, MODEL_MATRIX, TIME);
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	// Mipmapping averages thin leaf segments toward transparency. Raise alpha
	// with the sampled mip level so distant crowns keep their density.
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
	ALPHA = tex.a * (1.0 + lod * 0.25);
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
}
