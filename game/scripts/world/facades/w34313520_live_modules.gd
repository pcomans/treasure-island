class_name W34313520LiveModules
extends RefCounted
## Institutional family: delivered corner plus separately bounded remaining chains.
## Cadence and scale are production inference; hidden-side schedules are not as-built.
## The generated source shell remains the authoritative closed backing.

const RECEIVER_KEY := "building:w34313520:wall"
const SOURCE_KEY := "w34313520"
const REGISTRY_PATH := "res://game/resources/facades/w34313520_quality_family.json"
const CALIBRATION := preload("res://game/tests/support/w34313520_exact_receiver_calibration.gd")
const QUALITY_SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const PALE := preload("res://game/resources/materials/world/w34313520/w34313520_pale_exact_trial.tres")
const FRAME := preload("res://game/resources/materials/world/w34313520/w34313520_bay_frame.tres")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("Receiver identity differs.", record)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not parsed is Dictionary:
		return _failure("Quality family configuration is missing.", record)
	var cfg: Dictionary = parsed
	if cfg.get("source_key") != SOURCE_KEY or cfg.get("receiver_key") != RECEIVER_KEY:
		return _failure("Quality family source identity differs.", record)
	var root := Node3D.new()
	root.name = "W34313520LiveModules"
	var nominal_base := float(record.get("flat_base_elevation_m", 0.0))
	var top := float(record.get("top_elevation_m", 0.0))
	var scale_values: Array = cfg.bay_scale
	var bay_scale := Vector3(scale_values[0], scale_values[1], scale_values[2])
	var center_y := nominal_base + float(cfg.center_height_above_nominal_base_m)
	# The wall-tangent shader is valid only on vertical host faces.
	# Projecting boxes need a material defined for their horizontal caps too.
	var pale_boxes := StandardMaterial3D.new()
	pale_boxes.albedo_color = Color(0.76, 0.755, 0.715)
	pale_boxes.roughness = 0.8
	var mullion_material := StandardMaterial3D.new()
	mullion_material.albedo_color = Color(0.36, 0.39, 0.38)
	mullion_material.metallic = 0.15
	mullion_material.roughness = 0.5
	var module_count := 0
	for chain: Dictionary in cfg.chains:
		var runs: Array[int] = []
		for value: Variant in chain.runs: runs.append(int(value))
		if (str(chain.name) == "WSW" and runs != [0, 1, 2, 3, 4, 5]) \
		or (str(chain.name) == "SSEUpper" and runs != [6, 7, 8, 9, 10]) \
		or str(chain.name) not in ["WSW", "SSEUpper"]:
			root.free()
			return _failure("Unobserved run requested.", record)
		var minimum_y := nominal_base + 0.12 if chain.minimum_y_m == null else float(chain.minimum_y_m)
		if str(chain.name) == "SSEUpper" and minimum_y < 9.2:
			root.free()
			return _failure("Protected SSE lower band requested.", record)
		var first := CALIBRATION.run_frame(record, runs.front())
		var last := CALIBRATION.run_frame(record, runs.back())
		if first.is_empty() or last.is_empty():
			root.free()
			return _failure("Observed host chain is missing.", record)
		var origin: Vector3 = first.start
		var delta: Vector3 = last.end - origin
		delta.y = 0.0
		var length_m := delta.length()
		var tangent := delta.normalized()
		var normal: Vector3 = tangent.cross(Vector3.UP).normalized()
		if normal.dot(first.normal as Vector3) < 0.0:
			normal = -normal
		var basis := Basis(tangent, Vector3.UP, normal)
		# A thin source-owned pale host, separately from complete window motifs.
		# Each run preserves its source bottom/top; only the observed band is clad.
		for run: int in runs:
			var frame := CALIBRATION.run_frame(record, run)
			if not _host_matches(frame, origin, tangent, normal, top):
				root.free()
				return _failure("Host chain is not continuous and planar.", record)
			frame.normal = normal
			_add_host(root, frame, minimum_y, str(chain.name), run)
		var count := int(chain.bay_count)
		var margin := float(chain.end_margin_m)
		if count < 2 or margin < 2.5 or length_m <= margin * 2.0:
			root.free()
			return _failure("Invalid complete-bay domain.", record)
		var cadence := (length_m - margin * 2.0) / float(count - 1)
		var half_width := 2.86 * bay_scale.x
		if cadence <= half_width * 2.0 + 0.8:
			root.free()
			return _failure("Complete motifs overlap.", record)
		for i in count:
			var along := margin + cadence * i
			var bay := CALIBRATION._accepted_standalone_bay()
			if bay == null:
				root.free()
				return _failure("Reusable three-tier BAY is unavailable.", record)
			var placed_origin := origin + tangent * along + normal * float(cfg.wall_offset_m)
			placed_origin.y = center_y
			var placement := Transform3D(Basis(basis.x * bay_scale.x, basis.y * bay_scale.y, basis.z * bay_scale.z), placed_origin)
			for child: Node in bay.get_children():
				var mesh := child as MeshInstance3D
				var tier := int(str(child.name).substr(4, 2))
				if not chain.tiers.has(float(tier)):
					continue
				var transform := placement * mesh.transform
				var bounds := transform * mesh.mesh.get_aabb()
				if bounds.position.y < minimum_y or bounds.end.y > top - 0.35:
					bay.free()
					root.free()
					return _failure("Complete tier escapes its allowed vertical band.", record)
				bay.remove_child(mesh)
				mesh.name = "%s_Bay%02d_%s" % [chain.name, i + 1, mesh.name]
				mesh.transform = transform
				_tag(mesh, "wall", "CompleteBayFrame" if "Frame" in str(mesh.name) else "CompleteBayGlazing")
				mesh.set_meta("host_runs", runs)
				mesh.set_meta("complete_tier", tier)
				root.add_child(mesh)
			bay.free()
			_add_internal_lights(root, "%s_Bay%02d" % [chain.name, i + 1], placement, chain.tiers, runs, mullion_material)
			module_count += 1
		# Reference-supported broad piers and horizontal solid bands organize the
		# complete elevation; bays remain independent complete assemblies.
		for i in range(count - 1):
			var along := margin + cadence * (i + 0.5)
			_add_box(root, "%s_Pier%02d" % [chain.name, i], basis, origin, Vector3(along, (minimum_y + top - 0.28) * 0.5, 0.11), Vector3(0.48, top - 0.28 - minimum_y, 0.15), pale_boxes, "wall", "PalePier")
		for tier_gap: int in [0, 1]:
			var band_y: float = center_y + (-1.525 + 3.05 * tier_gap) * bay_scale.y
			if band_y - 0.40 >= minimum_y:
				_add_box(root, "%s_SolidBand%d" % [chain.name, tier_gap], basis, origin, Vector3(length_m * 0.5, band_y, 0.14), Vector3(length_m - 0.20, 0.8, 0.16), pale_boxes, "wall", "SolidStoreyBand")
		# Finite end piers and a shallow continuous cap; no new roof shape.
		for along in [0.65, length_m - 0.65]:
			_add_box(root, "%s_EndPier_%s" % [chain.name, str(along)], basis, origin, Vector3(along, (minimum_y + top - 0.28) * 0.5, 0.12), Vector3(1.1, top - 0.28 - minimum_y, 0.18), pale_boxes, "wall", "PaleEndPier")
		_add_box(root, str(chain.name) + "RoofEdge", basis, origin, Vector3(length_m * 0.5, top - 0.14, 0.14), Vector3(length_m - 0.20, 0.28, 0.23), pale_boxes, "wall", "ObservedRoofEdge")
		_add_box(root, str(chain.name) + "RoofDrip", basis, origin, Vector3(length_m * 0.5, top - 0.315, 0.18), Vector3(length_m - 0.22, 0.045, 0.20), FRAME, "detail", "RoofDrip")
	var remaining := _build_remaining(root, record, cfg.get("remaining_chains", []), pale_boxes, mullion_material)
	if not bool(remaining.get("ok", false)):
		root.free()
		return _failure(str(remaining.get("message", "Remaining family failed.")), record)
	var support := QUALITY_SUPPORT.attach(root, record, record, {})
	if not bool(support.get("ok", false)):
		return support
	var topology := _render_topology(root)
	var metadata := {"source_key": SOURCE_KEY, "receiver_key": RECEIVER_KEY,
		"placement_role": "production_inference", "module_instances": module_count,
		"observed_runs": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
		"sse_minimum_y_m": 9.2, "complete_motif": true,
		"surveyed_dimensions": false, "surveyed_count": false, "surveyed_cadence": false,
		"completed_sse_elevation": false, "independent_review": "pending",
		"native_producer": "Mesh.get_faces transformed per source-owned mesh",
		"source_shell_retained": true,
		"remaining_runs": remaining.get("runs", []),
		"remaining_placement_status": "production_inference",
		"remaining_observed_motif_runs": [24, 25, 26, 27, 28]}
	for key: String in metadata: root.set_meta(key, metadata[key])
	return {"ok": true, "node": root, "metadata": metadata,
		"mesh_instances": topology.mesh_instances, "surfaces": topology.surfaces, "triangles": topology.triangles}


static func _build_remaining(root: Node3D, record: Dictionary, chains: Array, pale: Material, mullions: Material) -> Dictionary:
	var allowed := {"ENEEndA": [11, 12, 13], "NNWCourtyard": [14, 15, 16, 17], "ENEReturnA": [18, 19], "ENEEndB": [22, 23], "NNWOuter": [24, 25, 26, 27, 28], "ENEReturnB": [29, 30, 31], "NNWReturn": [32, 33]}
	var seen: Array[String] = []
	var all_runs: Array[int] = []
	var top := float(record.top_elevation_m)
	var center_y := float(record.flat_base_elevation_m) + 5.5
	for item: Variant in chains:
		if not item is Dictionary: return {"ok": false, "message": "Remaining chain is not an object."}
		var chain: Dictionary = item
		var label := str(chain.get("name", ""))
		if not allowed.has(label) or label in seen: return {"ok": false, "message": "Unknown or duplicate remaining chain."}
		var runs: Array[int] = []
		for value: Variant in chain.get("runs", []):
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) != floorf(float(value)):
				return {"ok": false, "message": "Remaining run must be a finite integer."}
			runs.append(int(value))
		if runs != allowed[label]: return {"ok": false, "message": "Remaining chain escaped its exact source partition."}
		seen.append(label)
		all_runs.append_array(runs)
		var first := CALIBRATION.run_frame(record, runs.front())
		var last := CALIBRATION.run_frame(record, runs.back())
		if first.is_empty() or last.is_empty(): return {"ok": false, "message": "Remaining source host missing."}
		var origin: Vector3 = first.start
		var delta: Vector3 = last.end - origin
		delta.y = 0.0
		var length_m := delta.length()
		var tangent := delta.normalized()
		var normal := tangent.cross(Vector3.UP).normalized()
		if normal.dot(first.normal as Vector3) < 0.0: normal = -normal
		var basis := Basis(tangent, Vector3.UP, normal)
		var bottom := -INF
		for run: int in runs:
			var frame := CALIBRATION.run_frame(record, run)
			if not _host_matches(frame, origin, tangent, normal, top): return {"ok": false, "message": "Remaining host is not one source-planar chain."}
			bottom = maxf(bottom, maxf((frame.start as Vector3).y, (frame.end as Vector3).y))
		var count := int(chain.get("bay_count", 0))
		var margin := float(chain.get("end_margin_m", 0.0))
		var width_scale := float(chain.get("width_scale", 0.0))
		if count < 2 or not is_finite(margin) or not is_finite(width_scale) or width_scale <= 0.0 or margin <= 2.86 * width_scale or length_m <= margin * 2.0:
			return {"ok": false, "message": "Remaining complete opening domain invalid."}
		var cadence := (length_m - 2.0 * margin) / float(count - 1)
		if cadence <= 5.72 * width_scale + 0.8: return {"ok": false, "message": "Remaining complete bays overlap."}
		var tiers: Array = chain.get("tiers", [])
		var unique_tiers: Array[int] = []
		for value: Variant in tiers:
			if not (value is float or value is int) or not is_finite(float(value)) or float(value) != floorf(float(value)) or int(value) not in [1, 2, 3] or int(value) in unique_tiers:
				return {"ok": false, "message": "Remaining tier selection invalid."}
			unique_tiers.append(int(value))
		if unique_tiers.is_empty(): return {"ok": false, "message": "Remaining opening family missing."}
		var assembly := Node3D.new()
		for run: int in runs:
			var frame := CALIBRATION.run_frame(record, run)
			frame.normal = normal
			_add_host(assembly, frame, -INF, label, run)
		for i in count:
			var bay := CALIBRATION._accepted_standalone_bay()
			if bay == null:
				assembly.free()
				return {"ok": false, "message": "Existing divided bay base unavailable."}
			var anchor := origin + tangent * (margin + cadence * i) + normal * 0.06
			anchor.y = center_y
			var placement := Transform3D(Basis(basis.x * width_scale, basis.y * 1.12, basis.z), anchor)
			for child: Node in bay.get_children():
				var mesh := child as MeshInstance3D
				var tier := int(str(child.name).substr(4, 2))
				if tier not in unique_tiers: continue
				var transformed := placement * mesh.transform
				var bounds := transformed * mesh.mesh.get_aabb()
				if bounds.position.y < bottom or bounds.end.y > top - 0.35:
					bay.free()
					assembly.free()
					return {"ok": false, "message": "Remaining full tier escaped source host."}
				bay.remove_child(mesh)
				mesh.name = "%s_Bay%02d_%s" % [label, i + 1, mesh.name]
				mesh.transform = transformed
				_tag(mesh, "wall", "CompleteBayFrame" if "Frame" in str(mesh.name) else "CompleteBayGlazing")
				mesh.set_meta("complete_tier", tier)
				assembly.add_child(mesh)
			bay.free()
			_add_internal_lights(assembly, "%s_Bay%02d" % [label, i + 1], placement, tiers, runs, mullions)
		for i in range(count - 1):
			_add_box(assembly, "%s_Pier%02d" % [label, i], basis, origin, Vector3(margin + cadence * (i + 0.5), (bottom + top - 0.28) * 0.5, 0.11), Vector3(0.42, top - 0.28 - bottom, 0.15), pale, "wall", "PalePier")
		for gap: int in [0, 1]:
			var y: float = center_y + (-1.525 + gap * 3.05) * 1.12
			_add_box(assembly, "%s_Band%d" % [label, gap], basis, origin, Vector3(length_m * 0.5, y, 0.14), Vector3(length_m - 0.20, 0.8, 0.16), pale, "wall", "SolidStoreyBand")
		for along: float in [0.65, length_m - 0.65]:
			_add_box(assembly, "%s_End_%s" % [label, str(along)], basis, origin, Vector3(along, (bottom + top - 0.28) * 0.5, 0.12), Vector3(1.1, top - 0.28 - bottom, 0.18), pale, "wall", "PaleEndPier")
		_add_box(assembly, label + "RoofEdge", basis, origin, Vector3(length_m * 0.5, top - 0.14, 0.14), Vector3(length_m - 0.20, 0.28, 0.23), pale, "wall", "ObservedRoofEdge")
		_add_box(assembly, label + "RoofDrip", basis, origin, Vector3(length_m * 0.5, top - 0.315, 0.18), Vector3(length_m - 0.22, 0.045, 0.20), FRAME, "detail", "RoofDrip")
		var labels := {"ObservedPaleHost": "RemainingPaleHost", "CompleteBayFrame": "RemainingBayFrame", "CompleteBayGlazing": "RemainingBayGlazing", "CompleteBayMullion": "RemainingBayMullion", "PalePier": "RemainingPalePier", "SolidStoreyBand": "RemainingSolidBand", "PaleEndPier": "RemainingEndPier", "ObservedRoofEdge": "RemainingRoofEdge", "RoofDrip": "RemainingRoofDrip"}
		for child: Node in assembly.get_children():
			child.set_meta("construction_detail", labels[str(child.get_meta("construction_detail"))])
			child.set_meta("host_runs", runs)
			child.set_meta("evidence_scope", str(chain.provenance))
			assembly.remove_child(child)
			root.add_child(child)
		assembly.free()
	if seen.size() != allowed.size(): return {"ok": false, "message": "Incomplete remaining architectural family."}
	return {"ok": true, "runs": all_runs}


static func _add_internal_lights(root: Node3D, prefix: String, placement: Transform3D, tiers: Array, runs: Array[int], material: Material) -> void:
	# Preserve the prototype's 5.6 x 1.55 opening and 0.12 outer frame.
	# Two full mullions and three joined rail sections form six complete lights.
	# Internal spacing is production inference, not a surveyed pane schedule.
	var inner_half_width := 2.74
	var inner_height := 1.43
	var division := 5.6 / 6.0
	var bar_width := 0.055
	for value: Variant in tiers:
		var tier := int(value)
		var center_y: float = -3.05 + (tier - 1) * 3.05
		for side: int in [-1, 1]:
			_add_partition(root, "%s_Tier%02d_Mullion%d" % [prefix, tier, side], placement, Vector3(side * division, center_y, 0.215), Vector3(bar_width, inner_height, 0.065), material, runs, tier)
		var intervals: Array[Vector2] = [Vector2(-inner_half_width, -division - bar_width * 0.5), Vector2(-division + bar_width * 0.5, division - bar_width * 0.5), Vector2(division + bar_width * 0.5, inner_half_width)]
		for index in intervals.size():
			var interval: Vector2 = intervals[index]
			_add_partition(root, "%s_Tier%02d_Rail%d" % [prefix, tier, index], placement, Vector3((interval.x + interval.y) * 0.5, center_y, 0.215), Vector3(interval.y - interval.x, bar_width, 0.065), material, runs, tier)


static func _add_partition(root: Node3D, node_name: String, placement: Transform3D, center: Vector3, size: Vector3, material: Material, runs: Array[int], tier: int) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.transform = placement * Transform3D(Basis.IDENTITY, center)
	instance.material_override = material
	_tag(instance, "wall", "CompleteBayMullion")
	instance.set_meta("host_runs", runs)
	instance.set_meta("complete_tier", tier)
	root.add_child(instance)


static func _host_matches(frame: Dictionary, origin: Vector3, tangent: Vector3, normal: Vector3, top: float) -> bool:
	if frame.is_empty(): return false
	for point: Vector3 in [frame.start, frame.end]:
		if absf((point - origin).dot(normal)) > 0.025: return false
	return (frame.tangent as Vector3).dot(tangent) > 0.9999 \
		and is_equal_approx(float((frame.top_start as Vector3).y), top) \
		and is_equal_approx(float((frame.top_end as Vector3).y), top)


static func _add_host(root: Node3D, frame: Dictionary, minimum_y: float, chain: String, run: int) -> void:
	var points := PackedVector3Array()
	for source: Vector3 in [frame.start, frame.end, frame.top_end, frame.top_start]:
		var point := source + (frame.normal as Vector3) * 0.025
		point.y = maxf(point.y, minimum_y)
		points.append(point)
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = points
	arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array([frame.normal, frame.normal, frame.normal, frame.normal])
	arrays[Mesh.ARRAY_INDEX] = PackedInt32Array([0, 2, 1, 0, 3, 2])
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = "%s_PaleHostRun%02d" % [chain, run]
	instance.mesh = mesh
	instance.material_override = PALE
	_tag(instance, "wall", "ObservedPaleHost")
	instance.set_meta("host_runs", [run])
	root.add_child(instance)


static func _add_box(root: Node3D, node_name: String, basis: Basis, origin: Vector3, center: Vector3, size: Vector3, material: Material, role: String, detail: String) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	var placed := origin + basis.x * center.x + basis.z * center.z
	placed.y = center.y
	instance.transform = Transform3D(basis, placed)
	instance.material_override = material
	_tag(instance, role, detail)
	root.add_child(instance)


static func _tag(mesh: MeshInstance3D, role: String, detail: String) -> void:
	mesh.layers = 3 if role == "wall" else 1
	mesh.set_meta("physical_role", role)
	mesh.set_meta("construction_detail", detail)
	mesh.set_meta("source_keys", [SOURCE_KEY])
	mesh.set_meta("derived_object_key", RECEIVER_KEY)
	mesh.set_meta("placement_status", "production_inference")


static func _render_topology(node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		if mesh != null:
			result.mesh_instances = 1
			result.surfaces = mesh.get_surface_count()
			result.triangles = mesh.get_faces().size() / 3
	for child: Node in node.get_children():
		var counts := _render_topology(child)
		for key: String in result: result[key] += int(counts[key])
	return result


static func _failure(message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": "w34313520_quality_family", "message": message, "source_keys": record.get("source_keys", [])}
