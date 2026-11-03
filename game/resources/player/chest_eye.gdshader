// The two cartoon eyes on the chest's lid (chest_avatar_parts.gd eyes()):
// white bulbs with black 1930s "pie-cut" pupils (an oval with a wedge cut out)
// and wooden eyelids that close to blink. Drawn procedurally so they stay crisp
// at any distance. UV is the eye-front coordinate (-1..1, x across, y up);
// UV2.x is the side (+1 the chest's left eye), UV2.y > 0 on the front half.
shader_type spatial;
render_mode cull_back, diffuse_toon, specular_toon;

// Where the pupils look, in eye units (x across, y up).
uniform vec2 look = vec2(0.0, -0.08);
// 0 open, 1 shut.
uniform float blink = 0.0;
// How far the upper lids rest down over the eyes (0..1).
uniform float lid_rest = 0.08;
uniform vec4 white : source_color = vec4(0.98, 0.97, 0.93, 1.0);
uniform vec4 ink : source_color = vec4(0.03, 0.025, 0.025, 1.0);
uniform vec4 lid_color : source_color = vec4(0.62, 0.36, 0.17, 1.0);

void fragment() {
	vec2 p = UV;
	float side = UV2.x;
	float front = UV2.y;
	vec3 color = white.rgb;
	float rough = 0.22;
	if (front > 0.0) {
		// The pupil: a tall oval with a wedge cut from its outer upper side.
		vec2 q = (p - look) / vec2(0.40, 0.56);
		float pupil = length(q);
		float wedge = atan(q.y, q.x * side);
		bool cut = pupil > 0.3 && wedge > 0.3 && wedge < 1.0;
		if (pupil < 1.0 && !cut) {
			color = ink.rgb;
			rough = 0.15;
		}
		// Ink rim round the eye's front.
		if (length(p) > 0.9) {
			color = ink.rgb;
		}
		// Wooden lids: the upper comes down and the lower up to meet a little
		// below the middle; a dark line marks each lid's edge.
		float arc = 1.0 - p.x * p.x;
		float shut = clamp(lid_rest + blink * (1.0 - lid_rest), 0.0, 1.0);
		float meet = -0.22 - 0.1 * arc;
		float upper = mix(1.08 - 0.1 * arc, meet, shut);
		float lower = mix(-1.08, meet, clamp(blink, 0.0, 1.0));
		if (p.y > upper || p.y < lower) {
			color = lid_color.rgb;
			rough = 0.7;
		}
		if (upper < 0.98 && abs(p.y - upper) < 0.055) {
			color = ink.rgb;
		}
		if (blink > 0.02 && abs(p.y - lower) < 0.045) {
			color = ink.rgb;
		}
	}
	ALBEDO = color;
	ROUGHNESS = rough;
	SPECULAR = 0.6;
	// A little self-light keeps the eyes readable on the shaded side.
	EMISSION = color * 0.18;
}
