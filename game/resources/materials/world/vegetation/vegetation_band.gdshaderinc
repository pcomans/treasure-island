// The street vegetation's detail levels in large batches (street_vegetation_builder.gd
// with game/scripts/world/street_detail_batches.gd). A batch holds every instance of
// one variant's detail level in a large cell, so the batch's own visibility range
// can no longer say which instance shows: each instance shows only within its own
// level's range, measured exactly as the small cell it was once drawn in measured it,
// from that cell's box centre to the main camera (the same camera in the shadow and
// reflection-probe passes, as the renderer's own visibility ranges use).
// INSTANCE_CUSTOM.xyz is that centre less the instance's origin, in the world's frame;
// INSTANCE_CUSTOM.w is 1 plus the metres that cell's last level ran on past the
// level's end (an instance drawn any other way has w 0, which turns the test off).
// street_band is the level's range [begin, end] in metres, set on the level mesh's own
// materials (y 0: no level, the test is off). Outside it the instance collapses to its
// origin: a point, which draws nothing.
uniform vec2 street_band = vec2(0.0);
// A hedge's large batch is one merged mesh (no instances): each vertex carries the
// centre of the small cell it was once drawn in, in CUSTOM0.xyz (the mesh's frame),
// and its level's range has no extension past its end.
uniform bool street_band_by_vertex = false;

bool street_band_hides(vec3 origin, vec4 custom, vec3 camera) {
	if (custom.w < 0.5 || street_band.y <= 0.0) {
		return false;
	}
	float away = distance(camera, origin + custom.xyz);
	return away < street_band.x || away > street_band.y + (custom.w - 1.0);
}
