shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled, depth_draw_opaque;
#include "res://game/resources/textures/context/fresh_bay/family_grade.gdshaderinc"
uniform vec4 base_color : source_color = vec4(0.4, 0.48, 0.5, 1.0);
// Zero on structures/shore strips; differentiated on broad land regions only.
uniform sampler2D landcover_art : source_color, filter_linear_mipmap, repeat_disable;
uniform float cover_strength = 0.0;
uniform float cover_scale = 450.0;
uniform float cover_seed = 0.0;
varying vec3 geographic_position;
void vertex() { geographic_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
float cover_hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float cover_field(vec2 p) {
 vec2 cell = floor(p); vec2 f = fract(p); f = f*f*(3.0-2.0*f);
 return mix(mix(cover_hash(cell), cover_hash(cell+vec2(1.0,0.0)),f.x),mix(cover_hash(cell+vec2(0.0,1.0)),cover_hash(cell+vec2(1.0)),f.x),f.y);
}
void fragment() {
 vec3 color = base_color.rgb;
 if (cover_strength > 0.0) {
  // Stable origin-angle projection: same apparent texel aspect on slopes and curtains.
  vec2 surface_metres = vec2(atan(geographic_position.x, -geographic_position.z), atan(geographic_position.y, length(geographic_position.xz))) * 12000.0;
  vec2 p = surface_metres / cover_scale + vec2(cover_seed);
  float broad = cover_field(p)*0.68 + cover_field(p*2.17+vec2(7.2,3.1))*0.32;
  // Reuse only the original authored raster's opaque inland cover, never its silhouette.
  // Mirrored coordinates remain continuous; large repeats keep fine crowns sub-landmark scale.
  vec2 metres = surface_metres;
  vec2 tile = abs(fract(metres/vec2(18000.0,540.0)+vec2(cover_seed*0.17))*2.0-1.0);
  vec2 cover_uv = mix(vec2(600.0,620.0),vec2(1500.0,647.0),tile)/vec2(2172.0,724.0);
  vec3 cover = texture(landcover_art,cover_uv).rgb;
  float value = dot(cover,vec3(0.2126,0.7152,0.0722));
  float detail = clamp((value-0.193)*2.4,-0.24,0.24);
  float variation = (broad-0.5)*0.38 + detail;
  color *= 1.0 + variation * cover_strength;
  color = mix(color,color*vec3(0.95,1.02,0.94),smoothstep(0.4,0.7,broad)*0.55*cover_strength);

 }
 ALBEDO = horizon_grade(color, length(geographic_position.xz));
}
