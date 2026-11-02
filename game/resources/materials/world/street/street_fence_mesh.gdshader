shader_type spatial;
// See-through fence fabric (game/scripts/world/street_fence_kit.gd): chain-link
// mesh and barbed wire, drawn from a tiled texture whose alpha is the wire and
// alpha blended straight from its mipmaps. Up close the wire is crisp; as it
// shrinks below a pixel the mipmaps average it into the faint, even haze a real
// fence is at that distance, so neither speckle, moire nor bare frames show.
// Seen obliquely a woven mesh closes up, so the haze thickens toward grazing
// views, as if the light crossed up to max_layers layers of fabric.
// Both faces are drawn. The fabric writes no depth and casts no shadow: its
// shadow is a shadow-only copy cut out by street_fence_mesh_shadow.gdshader.
render_mode blend_mix, depth_draw_never, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D wire_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float metallic_value : hint_range(0.0, 1.0) = 0.45;
uniform float roughness_value : hint_range(0.0, 1.0) = 0.5;
uniform float max_layers = 4.0;

void fragment() {
	vec4 texel = texture(wire_texture, UV);
	float facing = max(abs(dot(NORMAL, VIEW)), 1.0 / max_layers);
	ALBEDO = texel.rgb * tint.rgb;
	METALLIC = metallic_value;
	ROUGHNESS = roughness_value;
	ALPHA = 1.0 - pow(1.0 - clamp(texel.a, 0.0, 0.999), 1.0 / facing);
}
