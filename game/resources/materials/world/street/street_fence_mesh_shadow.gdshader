shader_type spatial;
// The shade of see-through fence fabric (game/scripts/world/street_fence_kit.gd).
// street_fence_mesh.gdshader draws the fabric blended, and a blended surface
// casts no shadow, so a shadow-only copy of the fabric draws it again with this
// alpha scissor. Thin wire shrinks below a texel as the mip level rises in the
// shadow map, so its alpha gains a little per mip level and a faint lattice of
// shade stays.
render_mode cull_disabled, depth_draw_opaque, unshaded;

uniform sampler2D wire_texture : filter_linear_mipmap, repeat_enable;
// Alpha gained per mip level above the base texture.
uniform float coverage_boost = 0.2;
uniform float alpha_cut : hint_range(0.0, 1.0) = 0.45;

void fragment() {
	float alpha = texture(wire_texture, UV).a;
	vec2 size = vec2(textureSize(wire_texture, 0));
	vec2 texels_x = dFdx(UV * size);
	vec2 texels_y = dFdy(UV * size);
	float lod = max(0.0, 0.5 * log2(max(dot(texels_x, texels_x), dot(texels_y, texels_y))));
	ALBEDO = vec3(0.0);
	ALPHA = clamp(alpha * (1.0 + lod * coverage_boost), 0.0, 1.0);
	ALPHA_SCISSOR_THRESHOLD = alpha_cut;
}
