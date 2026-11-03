// A soft round contact shadow under the player character's shoes and chest,
// for the web build, which draws no sun shadows (chest_avatar.gd). A flat disc
// (UV -1..1 across it); `strength` fades it as the chest rises.
shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;

uniform float strength = 0.38;

void fragment() {
	float r = length(UV);
	ALBEDO = vec3(0.05, 0.04, 0.035);
	ALPHA = strength * (1.0 - smoothstep(0.35, 1.0, r));
}
