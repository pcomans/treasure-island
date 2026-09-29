shader_type spatial;
render_mode cull_back;
uniform vec4 base_color : source_color = vec4(0.68,0.66,0.56,1.0);
uniform float variation_gain = 1.0;
uniform float weathering = 0.035;
uniform bool horizontal_courses = false;
varying vec3 world_p;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){world_p=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
void fragment(){float grain=(noise(world_p*23.0)-0.5)*0.015;float field=(noise(world_p*0.6)-0.5)*weathering;float seam=0.0;if(horizontal_courses){float phase=fract(world_p.y/0.19);float aa=fwidth(world_p.y/0.19);seam=1.0-smoothstep(0.0,max(aa,0.025),min(phase,1.0-phase));}ALBEDO=base_color.rgb*(1.0+(field+grain-seam*0.10)*variation_gain);ROUGHNESS=0.93;METALLIC=0.0;SPECULAR=0.2;}
