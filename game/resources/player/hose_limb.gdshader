// One rubber-hose limb of the player's treasure chest (chest_avatar.gd): a
// straight tube mesh (UV.x along it, UV.y around it) bent on the GPU along the
// cubic Bezier p0..p3 that the avatar script sets each physics tick, in the
// MeshInstance3D's own frame. Constant radius, no elbows or knees: the 1930s
// rubber-hose look. The script gives the instance a custom AABB.
shader_type spatial;
render_mode cull_back, diffuse_toon, specular_toon;

uniform vec3 p0 = vec3(0.0, 0.0, 0.0);
uniform vec3 p1 = vec3(0.0, -0.15, 0.0);
uniform vec3 p2 = vec3(0.0, -0.35, 0.0);
uniform vec3 p3 = vec3(0.0, -0.5, 0.0);
// Any direction not along the hose; it only sets where the tube's seam runs.
uniform vec3 bend_normal = vec3(1.0, 0.0, 0.0);
uniform float radius = 0.04;
uniform vec4 albedo : source_color = vec4(0.035, 0.032, 0.036, 1.0);
uniform float roughness_value = 0.3;

void vertex() {
	float t = UV.x;
	float s = 1.0 - t;
	vec3 centre = s * s * s * p0 + 3.0 * s * s * t * p1 + 3.0 * s * t * t * p2 + t * t * t * p3;
	vec3 d = 3.0 * s * s * (p1 - p0) + 6.0 * s * t * (p2 - p1) + 3.0 * t * t * (p3 - p2);
	float d_len = length(d);
	vec3 tangent = d_len > 1e-5 ? d / d_len : normalize(p3 - p0 + vec3(0.0, -1e-4, 0.0));
	vec3 side = cross(tangent, bend_normal);
	if (dot(side, side) < 1e-6) {
		side = cross(tangent, vec3(0.0, 0.0, 1.0));
	}
	side = normalize(side);
	// Keep (side, up, tangent) right-handed like the mesh, so its winding holds.
	vec3 up = cross(tangent, side);
	float angle = UV.y * TAU;
	vec3 radial = side * cos(angle) + up * sin(angle);
	VERTEX = centre + radial * radius;
	NORMAL = radial;
}

void fragment() {
	ALBEDO = albedo.rgb;
	ROUGHNESS = roughness_value;
	SPECULAR = 0.65;
}
