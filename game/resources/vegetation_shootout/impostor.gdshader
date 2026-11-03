shader_type spatial;
// Tree shootout (variant A) far impostor: a quad that turns about the vertical
// axis to face the camera, textured with an image baked from LOD0.
// VERTEX holds the quad's pivot, UV2 the corner offset from it in metres.
render_mode cull_disabled, depth_draw_opaque;

uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float alpha_cutoff : hint_range(0.05, 0.95) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.9;

void vertex() {
	vec3 pivot = VERTEX;
	vec3 camera_local = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	vec3 to_camera = camera_local - pivot;
	to_camera.y = 0.0;
	float distance_xz = length(to_camera);
	vec3 forward = distance_xz > 0.0001 ? to_camera / distance_xz : vec3(0.0, 0.0, 1.0);
	vec3 right = vec3(forward.z, 0.0, -forward.x);
	VERTEX = pivot + right * UV2.x + vec3(0.0, UV2.y, 0.0);
	// Light it like a rounded, mostly sky-facing crown rather than a flat card.
	NORMAL = normalize(forward + vec3(0.0, 0.8, 0.0));
}

void fragment() {
	vec4 tex = texture(albedo_texture, UV);
	ALBEDO = tex.rgb * tint.rgb;
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	ALPHA = tex.a;
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
}
