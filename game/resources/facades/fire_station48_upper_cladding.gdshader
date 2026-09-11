shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 wall_color : source_color = vec4(0.73, 0.75, 0.67, 1.0);
uniform vec4 head_color : source_color = vec4(0.66, 0.685, 0.60, 1.0);
uniform float rib_period_m = 0.22;
uniform float rib_normal_slope = 0.09;
uniform float rib_albedo_amplitude = 0.018;
uniform float upper_start_y = 6.9;
uniform float upper_full_y = 7.2;
uniform vec2 head_limits = vec2(8.66, 8.72);
varying vec3 source_world_position;
varying vec3 source_world_normal;

void vertex() {
	source_world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	source_world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
	// This material is attached only to the exact public draw subset. The two
	// fixed source directions keep phase continuous across collinear run splits.
	vec2 tangent = dot(source_world_normal.xz, vec2(-0.8854596, 0.4647164)) > 0.5
		? vec2(0.4647164, 0.8854596) : vec2(-0.8854596, 0.4647164);
	float station = dot(source_world_position.xz - vec2(125.223, -364.588), tangent);
	float cycles = station / rib_period_m;
	float visible_ribs = 1.0 - smoothstep(0.25, 0.65, fwidth(cycles));
	float upper = smoothstep(upper_start_y, upper_full_y, source_world_position.y);
	float wave = cos(cycles * 6.28318530718);
	ALBEDO = wall_color.rgb * (1.0 - rib_albedo_amplitude * upper * visible_ribs * (0.5 + 0.5 * wave));
	// A filtered tonal joint replaces the former thin detached shadow caster.
	float footprint = max(fwidth(source_world_position.y), 0.0001);
	float head = smoothstep(head_limits.x - footprint, head_limits.x + footprint, source_world_position.y)
		* (1.0 - smoothstep(head_limits.y - footprint, head_limits.y + footprint, source_world_position.y));
	ALBEDO = mix(ALBEDO, head_color.rgb, head);
	vec3 view_tangent = (VIEW_MATRIX * vec4(tangent.x, 0.0, tangent.y, 0.0)).xyz;
	NORMAL = normalize(NORMAL + view_tangent * rib_normal_slope * sin(cycles * 6.28318530718) * upper * visible_ribs * (1.0 - head));
	ROUGHNESS = 0.92;
	METALLIC = 0.0;
	SPECULAR = 0.5;
}
