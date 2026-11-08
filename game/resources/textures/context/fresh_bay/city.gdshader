shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
uniform sampler2D art : source_color, filter_linear_mipmap, repeat_disable;
void fragment() {
 vec4 color = texture(art, UV);
 if (color.a < 0.5) { discard; }
 vec4 quiet = textureLod(art, UV, 1.8);
 vec3 detail_matched = mix(color.rgb, mix(quiet.rgb, color.rgb, 0.38), smoothstep(0.95, 0.99, quiet.a));
 ALBEDO = horizon_grade(detail_matched, 4500.0);
}
