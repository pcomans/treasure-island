shader_type spatial;
render_mode cull_back;

uniform sampler2D source_albedo : source_color, filter_linear_mipmap, repeat_enable;
uniform vec4 low_color : source_color = vec4(0.24, 0.15, 0.085, 1.0);
uniform vec4 high_color : source_color = vec4(0.48, 0.35, 0.22, 1.0);
uniform bool boarded_grain = false;

void fragment() {
	float tone;
	if (boarded_grain) {
		float bend = sin(UV.y * 1.7 + sin(UV.x * 2.9)) * 0.08;
		float fine = sin((UV.x + bend) * 96.0 + sin(UV.y * 11.0));
		float broad = sin(UV.x * 7.1 + UV.y * 1.3);
		float attenuation = 1.0 - smoothstep(0.15, 0.7, fwidth(UV.x) * 96.0);
		tone = clamp(0.52 + fine * attenuation * 0.11 + broad * 0.15, 0.0, 1.0);
	} else {
		vec3 source = texture(source_albedo, UV * 0.2).rgb;
		tone = clamp(dot(source, vec3(0.2126, 0.7152, 0.0722)) * 2.0, 0.0, 1.0);
	}
	ALBEDO = mix(low_color.rgb, high_color.rgb, tone);
	ROUGHNESS = 0.93;
	METALLIC = 0.0;
}
