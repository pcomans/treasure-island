shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
// The horizon haze: main.tscn's sky horizon and fog light colour. With its darks lifted
// and this share of it, the card's tone sits a little lighter than the nearer Bay Bridge
// in the scene fog (so at least as hazy) and level with the north-shore land beside it,
// which keeps the distant art's light veil (the scene fog itself would wash that land out).
uniform vec3 haze : source_color = vec3(0.74, 0.80, 0.86);
uniform float haze_share = 0.12;
void fragment() {
 vec4 color = texture(art, UV);
 if (color.a < 0.5) { discard; }
 vec4 quiet = textureLod(art, UV, 1.8);
 vec3 detail_matched = mix(color.rgb, mix(quiet.rgb, color.rgb, 0.38), smoothstep(0.95, 0.99, quiet.a));
 // Softer than the raw art at this distance: darks lifted and window detail pulled
 // toward the facade tone, as the distant sectors do.
 detail_matched = mix(vec3(0.22), detail_matched, 0.78);
 ALBEDO = horizon_grade(mix(detail_matched, haze, haze_share), 4500.0);
}
