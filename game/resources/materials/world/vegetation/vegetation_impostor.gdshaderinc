// Street-vegetation far impostor (street_vegetation_kit.gd): a quad that turns
// about the vertical axis to face the camera, textured with images baked from
// the tree's LOD0 (tools/vegetation/bake_impostors.gd). VERTEX holds the quad's
// pivot, UV2 the corner offset from it in metres. With view_grid above 1 x 1 the
// texture holds that many views of the tree, turned evenly round it from +Z
// toward +X, row by row; the quad shows the view nearest the camera's side of the
// tree, crossing to the next over a narrow band (a long blend softens its limbs), so
// the tree keeps its lean and width from every side and each instance's own turn.
// With high_frame_m above 0 the tree also has views from above: the quad grows to
// that square, leans back to face a camera above it, and crossfades to
// high_texture's views, so a far tree keeps its round crown from a jetpack or an
// overview instead of thinning to a line.
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
// The views from above (street_vegetation_kit.gd IMPOSTOR_HIGH_DEG), turned evenly
// round the tree like the side views, and the side in metres of their square frame.
uniform sampler2D high_texture : source_color, filter_linear_mipmap, repeat_disable;
uniform ivec2 high_grid = ivec2(1, 1);
uniform float high_frame_m = 0.0;

// The camera's height angle (radians) where the crossfade to the views from above runs.
const float HIGH_FADE_START = 0.21;
const float HIGH_FADE_END = 0.66;

// How far either side of halfway between two views the crossing runs (0.5 blends all the way).
const float VIEW_BLEND = 0.16;

// First view, second view, the share of the second.
varying flat vec3 views;
// The same for the views from above, and their share of the image.
varying flat vec4 high_views;
// How much of the side views' frame the quad's UV spans.
varying flat vec2 side_scale;

vec2 view_uv(vec2 uv, float view) {
	vec2 grid = vec2(view_grid);
	return (uv + vec2(mod(view, grid.x), floor(view / grid.x))) / grid;
}

vec2 high_uv(vec2 uv, float view) {
	vec2 grid = vec2(high_grid);
	return (uv + vec2(mod(view, grid.x), floor(view / grid.x))) / grid;
}

void vertex() {
	vec3 pivot = VERTEX;
	mat4 to_local = inverse(MODEL_MATRIX);
	vec3 to_camera = (to_local * vec4(CAMERA_POSITION_WORLD, 1.0)).xyz - pivot;
	// An orthographic view looks the same way everywhere.
	if (PROJECTION_MATRIX[3][3] != 0.0) {
		to_camera = (to_local * vec4(INV_VIEW_MATRIX[2].xyz, 0.0)).xyz;
	}
	float rise = to_camera.y;
	to_camera.y = 0.0;
	float distance_xz = length(to_camera);
	vec3 forward = distance_xz > 0.0001 ? to_camera / distance_xz : vec3(0.0, 0.0, 1.0);
	vec3 right = vec3(forward.z, 0.0, -forward.x);
	vec3 up = vec3(0.0, 1.0, 0.0);
	vec2 corner = UV2;
	side_scale = vec2(1.0);
	high_views = vec4(0.0);
	if (high_frame_m > 0.0) {
		float height_angle = max(atan(rise, distance_xz), 0.0);
		up = up * cos(height_angle) - forward * sin(height_angle);
		corner = sign(UV2) * high_frame_m * 0.5;
		side_scale = high_frame_m / (2.0 * abs(UV2));
		float high_count = float(high_grid.x * high_grid.y);
		float high_turn = fract(atan(forward.x, forward.z) / TAU) * high_count;
		float high_first = min(floor(high_turn), high_count - 1.0);
		high_views = vec4(high_first, mod(high_first + 1.0, high_count), high_turn - high_first, smoothstep(HIGH_FADE_START, HIGH_FADE_END, height_angle));
	}
	VERTEX = pivot + forward * toward_camera_m + right * corner.x + up * corner.y;
	// Light it like a rounded, mostly sky-facing crown rather than a flat card.
	NORMAL = normalize(forward + vec3(0.0, sky_lean, 0.0) + (right * sign(UV2.x) + vec3(0.0, sign(UV2.y), 0.0)) * dome);
	float count = float(view_grid.x * view_grid.y);
	float turn = fract(atan(forward.x, forward.z) / TAU) * count;
	float first = min(floor(turn), count - 1.0);
	views = vec3(first, mod(first + 1.0, count), turn - first);
}

void fragment() {
	// The side views fill their own frame inside the quad.
	vec2 side_uv = (UV - 0.5) * side_scale + 0.5;
	vec2 framed_uv = clamp(side_uv, 0.0, 1.0);
	vec4 tex = texture(albedo_texture, view_uv(framed_uv, views.x));
	if (view_grid.x * view_grid.y > 1) {
		tex = mix(tex, texture(albedo_texture, view_uv(framed_uv, views.y)), smoothstep(0.5 - VIEW_BLEND, 0.5 + VIEW_BLEND, views.z));
	}
	tex.a *= step(abs(side_uv.x - 0.5), 0.5) * step(abs(side_uv.y - 0.5), 0.5);
	if (high_views.w > 0.0) {
		vec4 from_above = mix(texture(high_texture, high_uv(UV, high_views.x)), texture(high_texture, high_uv(UV, high_views.y)), high_views.z);
		tex = mix(tex, from_above, high_views.w);
	}
	ALBEDO = tex.rgb * tint.rgb;
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	if (!FRONT_FACING) {
		NORMAL = -NORMAL;
	}
	vec2 texel = side_uv * vec2(textureSize(albedo_texture, 0)) / vec2(view_grid);
	float lod = max(0.0, 0.5 * log2(max(dot(dFdx(texel), dFdx(texel)), dot(dFdy(texel), dFdy(texel)))));
	ALPHA = tex.a * (1.0 + lod * mip_alpha_boost);
	ALPHA_SCISSOR_THRESHOLD = alpha_cutoff;
}
