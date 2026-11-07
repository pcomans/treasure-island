shader_type spatial;
// The docked Sammy J (game/scripts/world/ferry_terminal.gd): her paint, glass and
// lettering in one draw, gently rocking at her berth. The rocking is visual only:
// the mesh's origin is her waterline amidships, and the vertex stage rolls her
// about her length (local X), pitches her about her beam (local Z) and lifts her a
// little, so her shadow rocks with her; her collision stays still. Every period
// divides Godot's one-hour TIME rollover, so the motion never jumps.
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

// Vertex colour: sRGB paint; its alpha marks the finish (1 paint, 0.5 glass,
// 0 matte rubber and foam). UV: the livery atlas cell (lettering), or its white cell.
uniform sampler2D livery : source_color, filter_linear_mipmap_anisotropic, repeat_disable;
uniform float roll_deg = 0.55;
uniform float pitch_deg = 0.2;
uniform float heave_m = 0.025;

varying float finish;

mat3 roll_about_length(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat3(vec3(1.0, 0.0, 0.0), vec3(0.0, c, s), vec3(0.0, -s, c));
}

mat3 pitch_about_beam(float angle) {
	float c = cos(angle);
	float s = sin(angle);
	return mat3(vec3(c, s, 0.0), vec3(-s, c, 0.0), vec3(0.0, 0.0, 1.0));
}

void vertex() {
	float roll = radians(roll_deg) * (0.75 * sin(TAU * TIME / 5.0) + 0.25 * sin(TAU * TIME / 3.6 + 1.7));
	float pitch = radians(pitch_deg) * sin(TAU * TIME / 4.5 + 0.6);
	float heave = heave_m * (0.7 * sin(TAU * TIME / 4.0 + 2.1) + 0.3 * sin(TAU * TIME / 2.4));
	mat3 sway = pitch_about_beam(pitch) * roll_about_length(roll);
	VERTEX = sway * VERTEX + vec3(0.0, heave, 0.0);
	NORMAL = normalize(sway * NORMAL);
	finish = COLOR.a;
	// sRGB vertex colour to linear, as StandardMaterial3D's vertex_color_is_srgb.
	COLOR.rgb = mix(pow((COLOR.rgb + vec3(0.055)) * (1.0 / 1.055), vec3(2.4)), COLOR.rgb * (1.0 / 12.92), lessThan(COLOR.rgb, vec3(0.04045)));
}

void fragment() {
	vec3 lettering = texture(livery, UV).rgb;
	float glass = 1.0 - abs(finish * 2.0 - 1.0);
	float matte = 1.0 - smoothstep(0.0, 0.5, finish);
	ALBEDO = COLOR.rgb * lettering;
	ROUGHNESS = mix(mix(0.42, 0.08, glass), 0.85, matte);
	SPECULAR = mix(0.5, 0.6, glass);
	METALLIC = 0.0;
}
