// Street-vegetation far impostor (street_vegetation_kit.gd): a quad that turns
// about the vertical axis to face the camera, textured with images baked from
// the tree's LOD0 (tools/vegetation/bake_impostors.gd). VERTEX holds the quad's
// pivot, UV2 the corner offset from it in metres. With view_grid above 1 x 1 the
// texture holds that many views of the tree, turned evenly round it from +Z
// toward +X, row by row; the quad shows the two views nearest the camera's side
// of the tree, blended, so the tree keeps its lean and width from every side and
// each instance's own turn.
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 tint : source_color = vec4(1.0);
uniform float alpha_cutoff : hint_range(0.05, 0.95) = 0.5;
uniform float roughness : hint_range(0.0, 1.0) = 0.9;
uniform ivec2 view_grid = ivec2(1, 1);
// Alpha gained per sampled mip level, so a sparse crown's outline holds at a
// distance as its near levels' does (see vegetation_foliage.gdshader).
uniform float mip_alpha_boost : hint_range(0.0, 0.5) = 0.0;
// How far the quad stands toward the camera from its pivot: a palm's crown
// image in front of the trunk and knob, which stay geometry.
uniform float toward_camera_m : hint_range(0.0, 4.0) = 0.0;
// How far the quad's corner normals lean out from its middle, so the sun shades it
// across like a rounded crown, not all at once like a flat card; and how far its
// normal leans up from facing the camera. A real crown's cards face every way and
// let light through, so it looks only a little darker from its shaded side.
uniform float dome : hint_range(0.0, 3.0) = 0.0;
uniform float sky_lean : hint_range(0.0, 5.0) = 0.8;

// First view, second view, the share of the second.
varying flat vec3 views;

vec2 view_uv(vec2 uv, float view) {
	vec2 grid = vec2(view_grid);
	return (uv + vec2(mod(view, grid.x), floor(view / grid.x))) / grid;
}

void vertex() {
	vec3 pivot = VERTEX;
	vec3 camera_local = (inverse(MODEL_MATRIX) * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz;
	vec3 to_camera = camera_local - pivot;
	to_camera.y = 0.0;
	float distance_xz = length(to_camera);
	vec3 forward = distance_xz > 0.0001 ? to_camera / distance_xz : vec3(0.0, 0.0, 1.0);
	vec3 right = vec3(forward.z, 0.0, -forward.x);
	VERTEX = pivot + forward * toward_camera_m + right * UV2.x + vec3(0.0, UV2.y, 0.0);
	// Light it like a rounded, mostly sky-facing crown rather than a flat card.
	NORMAL = normalize(forward + vec3(0.0, sky_lean, 0.0) + (right * sign(UV2.x) + vec3(0.0, sign(UV2.y), 0.0)) * dome);
	float count = float(view_grid.x * view_grid.y);
	float turn = fract(atan(forward.x, forward.z) / TAU) * count;
	float first = min(floor(turn), count - 1.0);
	views = vec3(first, mod(first + 1.0, count), turn - first);
}

void fragment() {
	vec4 tex = texture(albedo_texture, view_uv(UV, views.x));
	if (view_grid.x * view_grid.y > 1) {
		tex = mix(tex, texture(albedo_texture, view_uv(UV, views.y)), views.z);
	}
	ALBEDO = tex.rgb * tint.rgb;
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	vec2 texel = UV * vec2(textureSize(albedo_texture, 0)) / vec2(view_grid);
	float lod = max(0.0, 0.5 * log2(max(dot(dFdx(texel), dFdx(texel)), dot(dFdy(texel), dFdy(texel)))));
	ALPHA = tex.a * (1.0 + lod * mip_alpha_boost);
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
}
