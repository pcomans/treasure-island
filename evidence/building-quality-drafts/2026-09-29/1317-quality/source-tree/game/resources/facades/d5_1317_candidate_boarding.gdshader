shader_type spatial;
render_mode cull_back;

// Candidate-only weathered timber sheet, not repeated planks or painted lighting.
// World-plane coordinates keep one unit equal to one metre on both retained
// ground boards and the reused1308 upper boxes; no camera-dependent scale.
uniform vec4 warm_color : source_color = vec4(0.29,0.205,0.12,1.0);
uniform vec4 faded_color : source_color = vec4(0.49,0.375,0.235,1.0);
varying vec2 sheet_m;
float hash2(vec2 p) {
	return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}
float value_noise(vec2 p) {
	vec2 cell=floor(p);
	vec2 f=fract(p);
	f=f*f*(3.0-2.0*f);
	return mix(mix(hash2(cell),hash2(cell+vec2(1.0,0.0)),f.x),
		mix(hash2(cell+vec2(0.0,1.0)),hash2(cell+vec2(1.0,1.0)),f.x),f.y);
}
float resolved(vec2 frequency) {
	float footprint=max(length(dFdx(sheet_m)*frequency),length(dFdy(sheet_m)*frequency));
	return 1.0-smoothstep(0.35,0.85,footprint);
}
void vertex() {
	vec2 tangent=vec2(NORMAL.z,-NORMAL.x);
	if(length(tangent)<0.1) { tangent=vec2(1.0,0.0); }
	sheet_m=vec2(dot(VERTEX.xz,normalize(tangent)),VERTEX.y);
}
void fragment() {
	// Irregular exposure/stain fields survive ordinary play distance without
	// leaving the old smooth sine-wave stripe across each opening.
	float exposure=value_noise(sheet_m*vec2(2.8,3.6));
	float mottling=value_noise(sheet_m*vec2(11.0,13.0));
	float curl=(value_noise(sheet_m*vec2(3.0,1.2))-0.5)*0.065;
	vec2 grain_uv=sheet_m+vec2(curl,0.0);
	float fibres=value_noise(grain_uv*vec2(28.0,3.3));
	float pores=value_noise(sheet_m*vec2(145.0,105.0));
	float fine_weight=resolved(vec2(28.0,3.3));
	float pore_weight=resolved(vec2(145.0,105.0));
	float mottle_weight=resolved(vec2(11.0,13.0));
	float tone=clamp(0.50+(exposure-0.5)*0.20+(mottling-0.5)*0.12*mottle_weight
		+(fibres-0.5)*0.18*fine_weight+(pores-0.5)*0.07*pore_weight,0.0,1.0);
	// Palette enters through source_color so Forward+ receives linear albedo.
	// Keep the broad weathering subordinate to timber tone and directional grain.
	vec3 timber=mix(warm_color.rgb,faded_color.rgb,0.5+(exposure-0.5)*0.35);
	ALBEDO=timber*(0.78+tone*0.40);
	ROUGHNESS=clamp(0.97+(mottling-0.5)*0.045,0.94,0.995);
	SPECULAR=0.15;
	METALLIC=0.0;
}
