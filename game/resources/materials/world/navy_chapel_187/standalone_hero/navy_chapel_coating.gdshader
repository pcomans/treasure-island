shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Chapel-specific coating variant of the existing Building 3 world-space PBR
// treatment. Source texture colour is normalized, not multiplied into paint.
// Optional Chapel-only modes (all off by default): procedural roofing courses
// along the in-plane up-slope axis, a painted plinth band below a world height,
// and anisotropic texture stretch for vertical timber grain. Original
// procedural pattern; no reference pixels.
uniform sampler2D surface_color : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_normal : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D surface_roughness : filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 paint_color : source_color = vec4(0.82, 0.79, 0.69, 1.0);
uniform float tile_span_m = 1.5;
uniform vec2 uv_stretch = vec2(1.0, 1.0);
uniform float relief_strength = 0.08;
uniform float roughness_base = 0.85;
uniform float variation_strength = 0.03;
uniform float wear_strength = 0.01;
uniform float plinth_top_y = -1000.0;
uniform float plinth_shade = 0.88;
uniform float course_exposure_m = 0.0;
uniform float tab_width_m = 0.9;
uniform float course_shadow = 0.0;
uniform float joint_shadow = 0.0;
uniform float tab_variation = 0.0;
uniform float metallic_response = 0.0;
varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

float tab_hash(vec2 cell) {
	return fract(sin(dot(cell, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec3 n = normalize(world_normal);
	vec3 reference_axis = abs(n.y) > 0.8 ? vec3(1.0, 0.0, 0.0) : vec3(0.0, 1.0, 0.0);
	vec3 t = normalize(cross(reference_axis, n));
	vec3 b = normalize(cross(n, t));
	vec2 plane = vec2(dot(world_position, t), dot(world_position, b));
	vec2 uv = plane * uv_stretch / tile_span_m;
	float field = dot(texture(surface_color, uv).rgb, vec3(0.2126, 0.7152, 0.0722));
	float normalized_field = clamp((field - 0.3) * 5.0, -1.0, 1.0);
	// Very faint coating wear below the observed nave eave. No rear modules,
	// architectural seam pattern, coarse grime or new substrate claim.
	float below_eave = 9.8 - world_position.y;
	float wear = smoothstep(0.0, 0.05, below_eave) * (1.0 - smoothstep(0.1, 0.45, below_eave));
	wear *= wear_strength * (0.5 + normalized_field * 0.5) * (1.0 - abs(n.y));
	vec3 albedo = paint_color.rgb * (1.0 + normalized_field * variation_strength - wear);
	float rough_shift = 0.0;
	// Painted base band on vertical faces only; level world height.
	if (world_position.y < plinth_top_y && abs(n.y) < 0.5) {
		albedo *= plinth_shade;
		rough_shift += 0.05;
	}
	if (course_exposure_m > 0.0) {
		// Courses follow world up projected onto the face (in-plane up-slope);
		// tabs follow the orthogonal horizontal ridge tangent. Near-flat faces
		// (projection length <= 0.02) keep the existing stable plane basis.
		vec3 up_slope = vec3(0.0, 1.0, 0.0) - n * n.y;
		vec2 course_plane = plane;
		if (dot(up_slope, up_slope) > 0.0004) {
			up_slope = normalize(up_slope);
			vec3 ridge = normalize(cross(up_slope, n));
			course_plane = vec2(dot(world_position, ridge), dot(world_position, up_slope));
		}
		float s = course_plane.y / course_exposure_m;
		float course = floor(s);
		float f = fract(s);
		float x = course_plane.x / tab_width_m + 0.5 * mod(course, 2.0);
		// Fade line detail when a course spans too few pixels to resolve.
		float course_aa = 1.0 - smoothstep(0.2, 0.6, fwidth(s));
		float joint_aa = 1.0 - smoothstep(0.08, 0.3, fwidth(x));
		float butt = smoothstep(0.78, 1.0, f);
		float joint = 1.0 - smoothstep(0.0, 0.035, min(fract(x), 1.0 - fract(x)));
		float tone = 1.0 + (tab_hash(vec2(course, floor(x))) - 0.5) * tab_variation * course_aa;
		float shade = mix(1.0 - course_shadow * 0.22, 1.0 - course_shadow * butt, course_aa);
		shade *= 1.0 - joint_shadow * joint * joint_aa * course_aa;
		albedo *= tone * shade;
		rough_shift += 0.06 * butt * course_aa;
	}
	ALBEDO = albedo;
	ROUGHNESS = clamp(roughness_base + rough_shift + (texture(surface_roughness, uv).r - 0.5) * 0.10, 0.2, 0.98);
	METALLIC = metallic_response;
	vec3 detail = texture(surface_normal, uv).rgb * 2.0 - 1.0;
	NORMAL = normalize((VIEW_MATRIX * vec4(normalize(n + (t * detail.x + b * detail.y) * relief_strength), 0.0)).xyz);
}
