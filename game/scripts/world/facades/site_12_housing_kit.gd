class_name Site12HousingKit
extends RefCounted

## Geometry-only Site 12 housing primitives. The kit deliberately contains no
## address, source ID, run schedule, facade cadence, or whole-building layout.
## Callers own those evidence-bound choices.

const KIT_ID := "site-12-housing-kit-v1"


static func new_bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "indices": []}


static func run_frame(record: Dictionary, run_index: int) -> Dictionary:
	var values := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var offset := run_index * 12
	if run_index < 0 or offset + 11 >= values.size() or offset + 2 >= normals.size():
		return {}
	var start := Vector3(float(values[offset]), float(values[offset + 1]), float(values[offset + 2]))
	var end := Vector3(float(values[offset + 3]), float(values[offset + 4]), float(values[offset + 5]))
	var tangent := end - start
	tangent.y = 0.0
	if tangent.length_squared() <= 0.000001:
		return {}
	return {
		"start": start,
		"end": end,
		"midpoint": (start + end) * 0.5,
		"length_m": tangent.length(),
		"tangent": tangent.normalized(),
		"normal": Vector3(float(normals[offset]), 0.0, float(normals[offset + 2])).normalized(),
	}


static func append_source_wall_run(bucket: Dictionary, record: Dictionary, run_index: int) -> void:
	var values := record.vertices as Array
	var normals := record.normals as Array
	var source_indices := record.indices as Array
	var value_offset := run_index * 12
	var vertex_offset := run_index * 4
	var index_offset := run_index * 6
	var frame := run_frame(record, run_index)
	var tangent := frame.tangent as Vector3
	var points := [
		Vector3(float(values[value_offset]), float(values[value_offset + 1]), float(values[value_offset + 2])),
		Vector3(float(values[value_offset + 3]), float(values[value_offset + 4]), float(values[value_offset + 5])),
		Vector3(float(values[value_offset + 6]), float(values[value_offset + 7]), float(values[value_offset + 8])),
		Vector3(float(values[value_offset + 9]), float(values[value_offset + 10]), float(values[value_offset + 11])),
	]
	var base := (bucket.vertices as Array).size()
	for local_index in range(4):
		var point := points[local_index] as Vector3
		var normal_offset := value_offset + local_index * 3
		(bucket.vertices as Array).append(point)
		(bucket.normals as Array).append(Vector3(float(normals[normal_offset]), float(normals[normal_offset + 1]), float(normals[normal_offset + 2])))
		# Absolute local-plane projection keeps one UV unit equal to one meter and
		# keeps texture phase stable across adjacent source runs.
		(bucket.uvs as Array).append(Vector2(point.dot(tangent), point.y))
	for triangle_offset in range(0, 6, 3):
		var first := base + int(source_indices[index_offset + triangle_offset]) - vertex_offset
		var second := base + int(source_indices[index_offset + triangle_offset + 1]) - vertex_offset
		var third := base + int(source_indices[index_offset + triangle_offset + 2]) - vertex_offset
		(bucket.indices as Array).append_array([first, third, second])


static func append_grouped_opening(
		opening_bucket: Dictionary,
		frame_bucket: Dictionary,
		wall_center: Vector3,
		tangent: Vector3,
		outward_normal: Vector3,
		width: float,
		height: float,
		opening_depth: float,
		frame_member: float,
		frame_depth: float,
		mullion_width: float
	) -> void:
	append_box(opening_bucket, wall_center + outward_normal * opening_depth * 0.5, tangent, outward_normal, width, height, opening_depth)
	var frame_center := wall_center + outward_normal * (opening_depth + frame_depth * 0.5)
	append_box(frame_bucket, frame_center + Vector3.UP * (height * 0.5 + frame_member * 0.5), tangent, outward_normal, width + frame_member * 2.0, frame_member, frame_depth)
	append_box(frame_bucket, frame_center - Vector3.UP * (height * 0.5 + frame_member * 0.5), tangent, outward_normal, width + frame_member * 2.0, frame_member, frame_depth)
	append_box(frame_bucket, frame_center - tangent * (width * 0.5 + frame_member * 0.5), tangent, outward_normal, frame_member, height, frame_depth)
	append_box(frame_bucket, frame_center + tangent * (width * 0.5 + frame_member * 0.5), tangent, outward_normal, frame_member, height, frame_depth)
	append_box(frame_bucket, frame_center, tangent, outward_normal, mullion_width, height, frame_depth + 0.015)


static func append_recessed_balcony_or_breezeway(
		void_bucket: Dictionary,
		slab_bucket: Dictionary,
		rail_bucket: Dictionary,
		wall_center: Vector3,
		tangent: Vector3,
		outward_normal: Vector3,
		width: float,
		height: float,
		void_depth: float,
		slab_height: float,
		slab_depth: float,
		rail_center_y: float,
		rail_height: float,
		rail_member: float,
		picket_width: float,
		picket_spacing: float,
		rail_depth: float
	) -> int:
	append_box(void_bucket, wall_center + outward_normal * void_depth * 0.5, tangent, outward_normal, width, height, void_depth)
	var slab_y := wall_center.y - height * 0.5 + slab_height * 0.5
	append_box(slab_bucket, Vector3(wall_center.x, slab_y, wall_center.z) + outward_normal * (slab_depth * 0.5 + void_depth), tangent, outward_normal, width + 0.12, slab_height, slab_depth)
	var rail_center := Vector3(wall_center.x, rail_center_y, wall_center.z) + outward_normal * (slab_depth + void_depth + rail_depth * 0.5)
	return append_simple_rail(rail_bucket, rail_center, tangent, outward_normal, width - 0.14, rail_height, rail_member, picket_width, picket_spacing, rail_depth)


static func append_simple_rail(
		bucket: Dictionary,
		center: Vector3,
		tangent: Vector3,
		outward_normal: Vector3,
		width: float,
		height: float,
		member: float,
		picket_width: float,
		picket_spacing: float,
		depth: float
	) -> int:
	append_box(bucket, center + Vector3.UP * (height * 0.5 - member * 0.5), tangent, outward_normal, width, member, depth)
	append_box(bucket, center - Vector3.UP * (height * 0.5 - member * 0.5), tangent, outward_normal, width, member, depth)
	var picket_count := maxi(2, int(floor(width / picket_spacing)) - 1)
	for picket_index in range(picket_count):
		var fraction := float(picket_index + 1) / float(picket_count + 1)
		var along := lerpf(-width * 0.5, width * 0.5, fraction)
		append_box(bucket, center + tangent * along, tangent, outward_normal, picket_width, height - member * 2.0, depth)
	return picket_count


static func append_eave_band(
		bucket: Dictionary,
		wall_center: Vector3,
		tangent: Vector3,
		outward_normal: Vector3,
		width: float,
		height: float,
		depth: float
	) -> void:
	append_box(bucket, wall_center + outward_normal * depth * 0.5, tangent, outward_normal, width, height, depth)


static func append_box(
		bucket: Dictionary,
		center: Vector3,
		tangent_value: Vector3,
		outward_normal_value: Vector3,
		width: float,
		height: float,
		depth: float
	) -> void:
	var tangent := tangent_value.normalized()
	var outward := outward_normal_value.normalized()
	var half_tangent := tangent * width * 0.5
	var half_depth := outward * depth * 0.5
	var half_up := Vector3.UP * height * 0.5
	var fbl := center - half_tangent - half_up + half_depth
	var fbr := center + half_tangent - half_up + half_depth
	var ftr := center + half_tangent + half_up + half_depth
	var ftl := center - half_tangent + half_up + half_depth
	var bbl := center - half_tangent - half_up - half_depth
	var bbr := center + half_tangent - half_up - half_depth
	var btr := center + half_tangent + half_up - half_depth
	var btl := center - half_tangent + half_up - half_depth
	append_quad(bucket, fbl, fbr, ftr, ftl, outward, Vector2.ZERO, Vector2(width, height))
	append_quad(bucket, bbr, bbl, btl, btr, -outward, Vector2.ZERO, Vector2(width, height))
	append_quad(bucket, ftl, ftr, btr, btl, Vector3.UP, Vector2.ZERO, Vector2(width, depth))
	append_quad(bucket, bbl, bbr, fbr, fbl, Vector3.DOWN, Vector2.ZERO, Vector2(width, depth))
	append_quad(bucket, bbl, fbl, ftl, btl, -tangent, Vector2.ZERO, Vector2(depth, height))
	append_quad(bucket, fbr, bbr, btr, ftr, tangent, Vector2.ZERO, Vector2(depth, height))


static func append_quad(
		bucket: Dictionary,
		a: Vector3,
		b: Vector3,
		c: Vector3,
		d: Vector3,
		normal_value: Vector3,
		uv_min: Vector2,
		uv_extent: Vector2
	) -> void:
	var normal := normal_value.normalized()
	var base := (bucket.vertices as Array).size()
	(bucket.vertices as Array).append_array([a, b, c, d])
	(bucket.normals as Array).append_array([normal, normal, normal, normal])
	(bucket.uvs as Array).append_array([
		uv_min,
		uv_min + Vector2(uv_extent.x, 0.0),
		uv_min + uv_extent,
		uv_min + Vector2(0.0, uv_extent.y),
	])
	if (b - a).cross(c - a).dot(normal) > 0.0:
		(bucket.indices as Array).append_array([base, base + 2, base + 1, base, base + 3, base + 2])
	else:
		(bucket.indices as Array).append_array([base, base + 1, base + 2, base, base + 2, base + 3])
