// Inputs and output are linear RGB; source_color uniforms/textures decode sRGB.
// Neutral atmospheric veil, no directional illumination baked into scenery.
vec3 horizon_grade(vec3 color, float distance_m) {
 float value = dot(color, vec3(0.2126, 0.7152, 0.0722));
 vec3 restrained = mix(vec3(value), color, 0.62);
 restrained *= vec3(0.94, 0.98, 1.0);
 float veil = mix(0.035, 0.19, smoothstep(3500.0, 22000.0, distance_m));
 return mix(restrained, vec3(0.19, 0.245, 0.29), veil);
}
