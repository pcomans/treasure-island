// The jetpack's two cartoon flames (chest_avatar_parts.gd flames()): opaque,
// unshaded teardrops below the nozzles, white-yellow where they face the camera
// and orange to red at their rims and tips. `intensity` (0..1) scales their
// length; at 0 they collapse to nothing. UV.y runs 0 at the nozzle to 1 at the
// tip, UV2.x is the flame's index.
shader_type spatial;
render_mode unshaded, cull_back, shadows_disabled;

uniform float intensity = 0.0;
uniform float length_m = 0.5;

void vertex() {
	float k = UV2.x;
	float t = UV.y;
	float flicker = 0.82 + 0.12 * sin(TIME * 47.0 + k * 2.1) + 0.08 * sin(TIME * 29.0 + k * 4.7);
	float len = length_m * intensity * flicker;
	// The mesh hangs one unit below each nozzle (y = 0 in the body frame).
	VERTEX.y *= len;
	vec2 wobble = vec2(sin(TIME * 31.0 + k * 3.0 + t * 6.0), cos(TIME * 23.0 + k * 1.3 + t * 5.0)) * 0.025 * t * intensity;
	VERTEX.x += wobble.x;
	VERTEX.z += wobble.y;
}

void fragment() {
	float t = UV.y;
	float facing = clamp(abs(dot(NORMAL, VIEW)), 0.0, 1.0);
	vec3 core = vec3(1.0, 0.86, 0.32);
	vec3 mid = vec3(1.0, 0.48, 0.06);
	vec3 rim = vec3(0.86, 0.14, 0.03);
	vec3 color = mix(rim, mid, smoothstep(0.15, 0.55, facing));
	color = mix(color, core, smoothstep(0.6, 0.9, facing) * (1.0 - smoothstep(0.35, 0.8, t)));
	color = mix(color, rim, smoothstep(0.65, 1.0, t));
	ALBEDO = color;
}
