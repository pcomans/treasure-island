shader_type spatial;
// The scene's own distance fog applies at the card's real depth (4.5 km), as it does to
// the nearer Bay Bridge, so the city sits in the same haze (no fog_disabled here).
render_mode unshaded, cull_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
void fragment() {
 vec4 color = texture(art, UV);
 if (color.a < 0.5) { discard; }
 vec4 quiet = textureLod(art, UV, 1.8);
 vec3 detail_matched = mix(color.rgb, mix(quiet.rgb, color.rgb, 0.38), smoothstep(0.95, 0.99, quiet.a));
 // Softer than the raw art at this distance: darks lifted and window detail pulled
 // toward the facade tone, as the distant sectors do.
 detail_matched = mix(vec3(0.22), detail_matched, 0.78);
 ALBEDO = horizon_grade(detail_matched, 4500.0);
}
