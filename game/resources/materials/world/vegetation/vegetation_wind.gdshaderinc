// One subtle breeze for the street vegetation (street_vegetation_kit.gd), shared
// by its bark, foliage and grass shaders. Each vertex carries its own weights in
// UV2: x is how far it sways downwind, in metres (zero at a trunk's foot, rising
// toward its top, the same for a whole crown so it rides on the trunk), y how
// far it flutters along its normal (fronds and leaf tips). Every instance takes
// its own phase from its position, so neighbours never move in step.
// Treasure Island's prevailing wind is westerly: it blows toward the east (+X).

uniform float wind_strength : hint_range(0.0, 2.0) = 1.0;
uniform vec2 wind_direction = vec2(0.95, 0.3);

vec3 vegetation_wind(vec3 vertex, vec3 normal, vec2 weights, mat4 model, float time) {
	if (wind_strength <= 0.0 || (weights.x <= 0.0 && weights.y <= 0.0)) {
		return vec3(0.0);
	}
	vec3 origin = model[3].xyz;
	float phase = dot(origin.xz, vec2(0.137, 0.091));
	// Slow gusts and an irregular rock downwind.
	float gust = 0.55 + 0.45 * sin(time * 0.21 + phase * 0.3);
	float rock = sin(time * 0.93 + phase) * 0.65 + sin(time * 1.61 + phase * 1.7) * 0.35;
	vec2 direction = normalize(wind_direction);
	vec3 world_offset = vec3(direction.x, 0.0, direction.y) * (0.45 + 0.55 * rock) * gust * weights.x;
	// Back into model space: an instance only turns about +Y and scales uniformly.
	mat3 basis = mat3(model[0].xyz, model[1].xyz, model[2].xyz);
	float scale_squared = max(dot(basis[0], basis[0]), 1e-6);
	vec3 offset = (transpose(basis) * world_offset) / scale_squared;
	// Leaves flap along their normal, faster, each part in its own phase.
	float flutter_phase = phase * 3.0 + dot(vertex, vec3(1.9, 1.3, 2.3));
	offset += normal * sin(time * 4.3 + flutter_phase) * (0.6 + 0.4 * gust) * weights.y;
	return offset * wind_strength;
}
