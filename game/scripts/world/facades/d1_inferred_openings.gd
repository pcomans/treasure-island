extends RefCounted

## Render-only openings for the unphotographed sides of the D1 attachments
## (B201, B225), owner-approved on 2026-10-22. Each config group names
## consecutive host wall runs that form one straight side. The helper places
## that attachment's own clerestory window and service-door style along the
## side from the exact receiver record. The host wall mesh, its material,
## collision and spray ownership are not touched, and nothing here collides.
## Counts and positions are production inference, not as-built.

const RENDER_BUILDING_WALL := 1 << 1
const MAX_SIDE_CHORD_DEVIATION_M := 0.01
const FRAME_DEPTH_M := 0.12
const FRAME_THICKNESS_M := 0.10


## Builds the openings described by `spec` ({"groups": [...]}) on `record`, a
## D1 wall receiver whose 12-float runs are bottom start, bottom end, top end,
## top start. `materials` maps the attachment's material keys to materials.
## `parent_transform` is the attachment root's transform, so the returned node
## can be added under that root while its boxes stay in record coordinates.
## Returns {"ok": true, "node": Node3D, "boxes": int} or {"ok": false, "message": ...}.
static func build(record: Dictionary, spec: Dictionary, materials: Dictionary, parent_transform: Transform3D) -> Dictionary:
	var vertices := record.get("vertices", []) as Array
	var normals := record.get("normals", []) as Array
	var groups := spec.get("groups", []) as Array
	if groups.is_empty():
		return {"ok": false, "message": "inferred openings need at least one side group"}
	var boxes: Dictionary = {}
	for group_value: Variant in groups:
		if not (group_value is Dictionary):
			return {"ok": false, "message": "inferred opening groups must be dictionaries"}
		var group := group_value as Dictionary
		var side := _side(vertices, normals, group.get("runs", []) as Array)
		if not bool(side.get("ok", false)):
			return side
		var problem := _add_group(boxes, group, side, materials)
		if problem != "":
			return {"ok": false, "message": problem}
	var root := Node3D.new()
	root.name = "InferredOpenings"
	root.transform = parent_transform.affine_inverse()
	root.set_meta("render_only", true)
	root.set_meta("collision", "none")
	root.set_meta("navigation", "none")
	root.set_meta("spray_owner", "none")
	root.set_meta("inference", str(spec.get("inference", "")))
	var count := 0
	var keys := boxes.keys()
	keys.sort()
	for key_value: Variant in keys:
		var key := str(key_value)
		var transforms := boxes[key] as Array
		var box := BoxMesh.new()
		box.size = Vector3.ONE
		box.material = materials[key] as Material
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_3D
		multimesh.mesh = box
		multimesh.instance_count = transforms.size()
		for index in transforms.size():
			multimesh.set_instance_transform(index, transforms[index] as Transform3D)
		var instance := MultiMeshInstance3D.new()
		instance.name = "Batch_%s" % key
		instance.multimesh = multimesh
		instance.layers = RENDER_BUILDING_WALL
		instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		instance.set_meta("render_only", true)
		instance.set_meta("material_key", key)
		root.add_child(instance)
		count += transforms.size()
	return {"ok": true, "node": root, "boxes": count}


## One straight side from consecutive runs: start, unit tangent, outward normal,
## length and the per-run bottom profile used to seat doors.
static func _side(vertices: Array, normals: Array, runs: Array) -> Dictionary:
	if runs.is_empty():
		return {"ok": false, "message": "inferred opening group has no runs"}
	var points: Array[Vector3] = []
	var top_y := INF
	var normal := Vector3.ZERO
	for index in runs.size():
		var run := int(runs[index])
		var offset := run * 12
		if run < 0 or offset + 12 > vertices.size() or offset + 3 > normals.size():
			return {"ok": false, "message": "inferred opening run %d is not in the receiver" % run}
		var start := Vector3(float(vertices[offset]), float(vertices[offset + 1]), float(vertices[offset + 2]))
		var end := Vector3(float(vertices[offset + 3]), float(vertices[offset + 4]), float(vertices[offset + 5]))
		if index > 0 and points[points.size() - 1].distance_to(start) > 0.001:
			return {"ok": false, "message": "inferred opening runs %s are not consecutive" % str(runs)}
		if index == 0:
			points.append(start)
		points.append(end)
		normal += Vector3(float(normals[offset]), 0.0, float(normals[offset + 2]))
		top_y = minf(top_y, minf(float(vertices[offset + 7]), float(vertices[offset + 10])))
	var first := points[0]
	var last := points[points.size() - 1]
	var chord := Vector3(last.x - first.x, 0.0, last.z - first.z)
	var length := chord.length()
	if length <= 1.0 or normal.length() <= 0.0:
		return {"ok": false, "message": "inferred opening side %s is degenerate" % str(runs)}
	var tangent := chord / length
	# Place along the exact chord; the record normals (3 decimals) only pick the side.
	var outward := Vector3(-tangent.z, 0.0, tangent.x)
	var record_normal := normal.normalized()
	if absf(record_normal.dot(tangent)) > 0.02 or record_normal.dot(outward) <= 0.0:
		return {"ok": false, "message": "inferred opening side %s normal does not face out of its runs" % str(runs)}
	for point in points:
		var along := Vector3(point.x - first.x, 0.0, point.z - first.z)
		if absf(along.dot(outward)) > MAX_SIDE_CHORD_DEVIATION_M:
			return {"ok": false, "message": "inferred opening side %s is not straight" % str(runs)}
	return {"ok": true, "start": first, "tangent": tangent, "outward": outward, "length": length, "points": points, "top_y": top_y}


static func _add_group(boxes: Dictionary, group: Dictionary, side: Dictionary, materials: Dictionary) -> String:
	var length := float(side.length)
	var glass := str(group.get("glass_material", ""))
	var frame := str(group.get("frame_material", ""))
	if not materials.has(glass) or not materials.has(frame):
		return "inferred opening group %s names an unknown material" % str(group.get("runs", []))
	var windows := group.get("windows", {}) as Dictionary
	if not windows.is_empty():
		var widths := windows.get("widths_m", []) as Array
		var panes := windows.get("panes", []) as Array
		var gap := float(windows.get("gap_m", 0.4))
		var center_y := float(windows.get("center_y_m", 0.0))
		var height := float(windows.get("height_m", 0.0))
		if widths.is_empty() or panes.size() != widths.size() or height <= 0.0:
			return "inferred window row on %s needs widths, matching panes and a height" % str(group.get("runs", []))
		var total := gap * float(widths.size() - 1)
		for width in widths:
			total += float(width)
		var margin := float(windows.get("end_margin_m", 1.0))
		if total > length - margin * 2.0:
			return "inferred window row on %s is longer than its side" % str(group.get("runs", []))
		if center_y + height * 0.5 + FRAME_THICKNESS_M > float(side.top_y) - 0.05:
			return "inferred window row on %s rises above its wall top" % str(group.get("runs", []))
		var cursor := (length - total) * 0.5
		for index in widths.size():
			var width := float(widths[index])
			var u := cursor + width * 0.5
			cursor += width + gap
			_add_opening(boxes, side, glass, frame, u, center_y, Vector2(width, height), int(panes[index]) - 1)
	for door_value: Variant in group.get("doors", []) as Array:
		var door := door_value as Dictionary
		var u := float(door.get("u_m", -1.0))
		var width := float(door.get("width_m", 0.0))
		var top_y := float(door.get("top_y_m", 0.0))
		var leaf := str(door.get("leaf_material", glass))
		if not materials.has(leaf) or width <= 0.0 or u - width * 0.5 < 0.5 or u + width * 0.5 > length - 0.5:
			return "inferred door at %.2f on %s does not fit its side" % [u, str(group.get("runs", []))]
		var bottom_y := _bottom_y(side, u) - 0.04
		if top_y - bottom_y < 1.9:
			return "inferred door at %.2f on %s is lower than 1.9 m" % [u, str(group.get("runs", []))]
		_add_box(boxes, leaf, side, u, (bottom_y + top_y) * 0.5, 0.06, Vector3(width, top_y - bottom_y, 0.09))
		_add_frame(boxes, frame, side, u, (bottom_y + top_y) * 0.5, Vector2(width, top_y - bottom_y), 0)
	return ""


static func _bottom_y(side: Dictionary, u: float) -> float:
	var points := side.points as Array
	var start := side.start as Vector3
	var tangent := side.tangent as Vector3
	for index in points.size() - 1:
		var a := points[index] as Vector3
		var b := points[index + 1] as Vector3
		var ua := Vector3(a.x - start.x, 0.0, a.z - start.z).dot(tangent)
		var ub := Vector3(b.x - start.x, 0.0, b.z - start.z).dot(tangent)
		if u <= ub + 0.000001 or index == points.size() - 2:
			return lerpf(a.y, b.y, clampf((u - ua) / maxf(ub - ua, 0.000001), 0.0, 1.0))
	return (points[0] as Vector3).y


static func _add_opening(boxes: Dictionary, side: Dictionary, glass: String, frame: String, u: float, center_y: float, opening: Vector2, mullions: int) -> void:
	_add_box(boxes, glass, side, u, center_y, 0.05, Vector3(opening.x, opening.y, 0.08))
	_add_frame(boxes, frame, side, u, center_y, opening, mullions)


static func _add_frame(boxes: Dictionary, frame: String, side: Dictionary, u: float, center_y: float, opening: Vector2, mullions: int) -> void:
	var t := FRAME_THICKNESS_M
	var out := 0.11
	_add_box(boxes, frame, side, u, center_y + opening.y * 0.5 + t * 0.5, out, Vector3(opening.x + t * 2.0, t, FRAME_DEPTH_M))
	_add_box(boxes, frame, side, u, center_y - opening.y * 0.5 - t * 0.5, out, Vector3(opening.x + t * 2.0, t, FRAME_DEPTH_M))
	_add_box(boxes, frame, side, u - opening.x * 0.5 - t * 0.5, center_y, out, Vector3(t, opening.y, FRAME_DEPTH_M))
	_add_box(boxes, frame, side, u + opening.x * 0.5 + t * 0.5, center_y, out, Vector3(t, opening.y, FRAME_DEPTH_M))
	for index in mullions:
		var x := u - opening.x * 0.5 + opening.x * float(index + 1) / float(mullions + 1)
		_add_box(boxes, frame, side, x, center_y, out, Vector3(t, opening.y, FRAME_DEPTH_M))


static func _add_box(boxes: Dictionary, material_key: String, side: Dictionary, u: float, y: float, outward_m: float, size: Vector3) -> void:
	var tangent := side.tangent as Vector3
	var outward := side.outward as Vector3
	var start := side.start as Vector3
	var origin := Vector3(start.x, y, start.z) + tangent * u + outward * outward_m
	var transform := Transform3D(Basis(tangent * size.x, Vector3.UP * size.y, outward * size.z), origin)
	if not boxes.has(material_key):
		boxes[material_key] = []
	(boxes[material_key] as Array).append(transform)
