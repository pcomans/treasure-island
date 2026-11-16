shader_type spatial;
// A bed's wood-chip mulch (game/scripts/world/mulch_ground.gd): the shared chips of
// mulch.gdshaderinc, graded per material. A mesh's vertex colour darkens it (a tree
// pit's rim and trunk); meshes without one are white.
//
// The ground dressing (game/scripts/world/ground_dressing.gd) compiles two capture
// variants, read from straight above: MULCH_CAPTURE_COLOUR draws the bed's colour
// unshaded (its colour capture, which loose chips take on), MULCH_CAPTURE_PLACE its
// height in red, opaque, so the capture's alpha is where the mulch lies (the chips
// capture).
#ifdef MULCH_CAPTURE_COLOUR
render_mode unshaded, depth_draw_opaque, cull_back;
#endif
#ifdef MULCH_CAPTURE_PLACE
render_mode unshaded, depth_draw_opaque, cull_back;
#endif

#include "res://game/resources/materials/world/street/mulch.gdshaderinc"

varying vec3 world_position;
varying vec3 world_normal;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}

void fragment() {
#ifdef MULCH_CAPTURE_PLACE
	ALBEDO = vec3(world_position.y, 0.0, 0.0);
#else
	float foot_m = max(fwidth(world_position.x), fwidth(world_position.z));
	vec3 albedo;
	float height;
	vec2 slope;
	float roughness;
	mulch_sample(world_position.xz, foot_m, albedo, height, slope, roughness);
	ALBEDO = albedo * COLOR.rgb;
#ifndef MULCH_CAPTURE_COLOUR
	ROUGHNESS = roughness;
	SPECULAR = 0.2;
	NORMAL = normalize((VIEW_MATRIX * vec4(mulch_normal(normalize(world_normal), slope), 0.0)).xyz);
#endif
#endif
}
