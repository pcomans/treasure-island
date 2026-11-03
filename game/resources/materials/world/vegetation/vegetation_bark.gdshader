shader_type spatial;
// Street-vegetation bark (street_vegetation_kit.gd): palm trunks, knobs, roots
// and cypress limbs. A tiled bark texture times a tint and the builder's
// vertex-colour shading; the trunk sways with the shared breeze.

#include "res://game/resources/materials/world/vegetation/vegetation_wind.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.95;
uniform float specular : hint_range(0.0, 1.0) = 0.25;

void vertex() {
	VERTEX += vegetation_wind(VERTEX, NORMAL, UV2, MODEL_MATRIX, TIME);
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * tint.rgb * COLOR.rgb;
	ROUGHNESS = roughness;
	SPECULAR = specular;
}
