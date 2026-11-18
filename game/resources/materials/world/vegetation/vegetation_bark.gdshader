shader_type spatial;
// Street-vegetation bark (street_vegetation_kit.gd): palm trunks, knobs, roots
// and cypress limbs. A tiled bark texture times a tint and the builder's
// vertex-colour shading; the trunk sways with the shared breeze.

#include "res://game/resources/materials/world/vegetation/vegetation_wind.gdshaderinc"
#include "res://game/resources/materials/world/vegetation/vegetation_band.gdshaderinc"

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float roughness : hint_range(0.0, 1.0) = 0.95;
uniform float specular : hint_range(0.0, 1.0) = 0.25;
// The time of day's scale on the specular, as vegetation_foliage.gdshader's.
global uniform float vegetation_sheen;

void vertex() {
	VERTEX += vegetation_wind(VERTEX, NORMAL, UV2, MODEL_MATRIX, TIME);
	vec3 band_origin = street_band_by_vertex ? (MODEL_MATRIX * vec4(CUSTOM0.xyz, 1.0)).xyz : MODEL_MATRIX[3].xyz;
	vec4 band_custom = street_band_by_vertex ? vec4(0.0, 0.0, 0.0, 1.0) : INSTANCE_CUSTOM;
	if (street_band_hides(band_origin, band_custom, MAIN_CAM_INV_VIEW_MATRIX[3].xyz)) {
		VERTEX = vec3(0.0);
	}
}

void fragment() {
	ALBEDO = texture(albedo_texture, UV).rgb * tint.rgb * COLOR.rgb;
	ROUGHNESS = roughness;
	SPECULAR = specular * vegetation_sheen;
}
