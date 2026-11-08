shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
// Opaque real-depth mainland floor. Keep the current Environment's distance fog;
// no alpha fade, forced depth, additional fog density or invented inland ridges.
uniform vec4 base_color : source_color = vec4(0.4, 0.48, 0.5, 1.0);
varying vec3 geographic_position;
void vertex() { geographic_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() { ALBEDO = horizon_grade(base_color.rgb, length(geographic_position.xz)); }
