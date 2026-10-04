shader_type spatial;
render_mode diffuse_burley;
uniform vec4 base_color : source_color = vec4(0.73,0.73,0.69,1.0);
uniform float grain = 0.07;
uniform float weathering = 0.05;
varying vec3 local_pos;
float hash(vec3 p) { return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453); }
float noise(vec3 p) {
 vec3 i=floor(p); vec3 f=fract(p); f=f*f*(3.0-2.0*f);
 return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);
}
void vertex(){local_pos=VERTEX;}
void fragment(){
 float fine=noise(local_pos*38.0)-0.5;
 float broad=noise(local_pos*0.77);
 float stain=smoothstep(0.30,0.70,broad)*0.60+noise(local_pos*3.1)*0.23+noise(local_pos*11.0)*0.10;
 ALBEDO=base_color.rgb*(1.0+fine*grain-stain*weathering);
 ROUGHNESS=0.96;
}
