shader_type spatial;
render_mode cull_back;
uniform vec4 wall_color : source_color = vec4(0.73,0.72,0.68,1.0);
uniform vec4 graphite_color : source_color = vec4(0.115,0.135,0.142,1.0);
uniform float upper_start_y = 7.93;
uniform float rib_period_m = 0.065;
uniform float rib_albedo_amplitude = 0.025;
uniform float sse_corner_start_m = 37.8490905115;
varying vec3 source_world_position;
varying vec3 source_world_normal;
void vertex() {
    source_world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
    source_world_normal = MODEL_NORMAL_MATRIX * NORMAL;
}
void fragment() {
    float upper = step(upper_start_y,source_world_position.y);
    float station = dot(source_world_position.xz-vec2(-145.544,361.382),vec2(0.6551326027,-0.7555139131));
    float sse = step(0.99,dot(normalize(source_world_normal),normalize(vec3(0.756,0.0,0.655))));
    float field = sse*(1.0-step(sse_corner_start_m,station))*upper;
    float cycle = station/rib_period_m;
    float coverage = 1.0-smoothstep(0.35,1.0,fwidth(cycle));
    float ribs = cos(cycle*6.28318530718)*rib_albedo_amplitude*coverage*field;
    ALBEDO = mix(graphite_color.rgb,wall_color.rgb,upper)*(1.0+ribs);
    ROUGHNESS = 0.88;
    METALLIC = 0.0;
}
