shader_type spatial;
render_mode depth_draw_opaque, cull_back;

// Private LocalLawn palette; source textures and source-ground materials remain untouched.
uniform sampler2D lawn_albedo : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D lawn_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 dark_color : source_color = vec4(0.302, 0.400, 0.239, 1.0);
uniform vec4 light_color : source_color = vec4(0.506, 0.604, 0.341, 1.0);
uniform float luminance_gain = 5.0;

void fragment() {
	// Same2m world-UV repeat as the former StandardMaterial uv1_scale=0.5.
	vec2 sample_uv = UV * 0.5;
	vec3 source = texture(lawn_albedo, sample_uv).rgb;
	float tone = clamp(dot(source, vec3(0.2126, 0.7152, 0.0722)) * luminance_gain, 0.0, 1.0);
	ALBEDO = mix(dark_color.rgb, light_color.rgb, tone);
	ROUGHNESS = texture(lawn_roughness, sample_uv).r;
	METALLIC = 0.0;
}
