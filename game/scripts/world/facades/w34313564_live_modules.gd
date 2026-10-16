class_name W34313564LiveModules
extends RefCounted

const RECEIVER_KEY := "building:w34313564:wall"
const SOURCE_KEY := "w34313564"
const REGISTRY_PATH := "res://game/resources/facades/w34313564_module_calibration.json"
const REVIEWED_HELPER_PATH := "res://game/tests/support/w34313564_module_calibration.gd"
const PLACEMENT_ROLE := "stylized/reference-derived production inference"
const POSITION_UNCERTAINTY_M := 4.0
const RENDER_BUILDING_WALL := 1 << 1
const EXPECTED_PLACEMENTS := {
	"CAL-SSE-PDOOR-01": {"motif_id": "W34313564-PDOOR", "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "anchor_run": 7, "center_chain_m": 47.5, "host_material_id": "W34313564-MAT-TAN"},
	"CAL-SSE-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "SSE", "mapping_id": "B06-34313564-SSE-CENTRAL", "anchor_run": 8, "center_chain_m": 68.0, "host_material_id": "W34313564-MAT-TAN"},
	"CAL-ENE-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "ENE", "mapping_id": "B06-34313564-ENE-END", "anchor_run": 12, "center_chain_m": 18.0, "host_material_id": "W34313564-MAT-PALE"},
	"CAL-NNW-PDOOR-01": {"motif_id": "W34313564-PDOOR", "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "anchor_run": 16, "center_chain_m": 32.0, "host_material_id": "W34313564-MAT-PALE"},
	"CAL-NNW-HWIN-01": {"motif_id": "W34313564-HWIN", "face": "NNW", "mapping_id": "B06-34313564-NNW-OUTER", "anchor_run": 17, "center_chain_m": 54.0, "host_material_id": "W34313564-MAT-PALE"},
}

const REVIEWED_CALIBRATION := preload("res://game/tests/support/w34313564_module_calibration.gd")


static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY \
		and record.get("source_keys", []) == [SOURCE_KEY] \
		and str(record.get("feature_kind", "")) == "building_wall" \
		and str(record.get("receiver_kind", "")) == "building_wall" \
		and str(record.get("collision_kind", "")) == "world_solid" \
		and bool(record.get("opaque", false))


static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record):
		return _failure("w34313564_live_module_receiver", "Live module target receiver identity does not match.", record)
	var registry_value: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not (registry_value is Dictionary):
		return _failure("w34313564_live_module_registry", "Reviewed module registry did not parse.", record)
	var registry := registry_value as Dictionary
	if not _registry_matches_exact_live_scope(registry):
		return _failure("w34313564_live_module_scope", "Reviewed module registry no longer matches the exact five authorized placements.", record)
	var result := REVIEWED_CALIBRATION.build(record, registry)
	if not bool(result.get("ok", false)):
		return result
	var live_root := result.get("node") as Node3D
	if live_root == null or not _promote_to_live_attachment(live_root, registry):
		if live_root != null:
			live_root.free()
		return _failure("w34313564_live_module_geometry", "Reviewed module output failed the render-only live attachment contract.", record)
	live_root.name = "W34313564LiveModules"
	if not _build_sse_family(live_root, record):
		live_root.free()
		return _failure("w34313564_family", "SSE family escaped source scope.", record)
	var support := QUALITY_SUPPORT.attach(live_root, record, record, {})
	if not bool(support.get("ok", false)): return support
	var topology := _render_topology(live_root)
	if int(topology.mesh_instances) == 0 or int(topology.triangles) == 0:
		live_root.free()
		return _failure("w34313564_live_module_topology", "Reviewed live modules produced no render geometry.", record)
	var metadata := {
		"source_key": SOURCE_KEY,
		"receiver_key": RECEIVER_KEY,
		"placement_role": PLACEMENT_ROLE,
		"position_uncertainty_m": POSITION_UNCERTAINTY_M,
		"retained_module_instances": 3,
		"observed_family_runs": [5,6,7,8,9],
		"reference_recognizable": false,
		"sse_family_config": FAMILY_PATH,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"field_meshes": 0,
		"collision_geometry": "shared_quality_support_current_visible_faces",
		"navigation_nodes": 0,
		"spray_nodes": 0,
		"cadence_inferred": true,
		"total_opening_count_inferred": true,
		"reviewed_registry_path": REGISTRY_PATH,
		"reviewed_geometry_helper_path": REVIEWED_HELPER_PATH,
	}
	for key: String in metadata:
		live_root.set_meta(key, metadata[key])
	return {
		"ok": true,
		"node": live_root,
		"mesh_instances": int(topology.mesh_instances),
		"surfaces": int(topology.surfaces),
		"triangles": int(topology.triangles),
		"metadata": metadata,
		"resolved_placements": result.get("resolved_placements", []).duplicate(true),
	}


static func _registry_matches_exact_live_scope(registry: Dictionary) -> bool:
	var policy := registry.get("placement_policy", {}) as Dictionary
	if int(policy.get("placement_count", -1)) != EXPECTED_PLACEMENTS.size() \
	or float(policy.get("maximum_outward_depth_m", 1.0)) > 0.18 \
	or int(policy.get("collision_nodes", -1)) != 0 \
	or int(policy.get("navigation_nodes", -1)) != 0 \
	or int(policy.get("spray_nodes", -1)) != 0:
		return false
	var seen := {}
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		var placement_id := str(placement.get("placement_id", ""))
		if not EXPECTED_PLACEMENTS.has(placement_id) or seen.has(placement_id):
			return false
		seen[placement_id] = true
		var expected := EXPECTED_PLACEMENTS[placement_id] as Dictionary
		if str(placement.get("motif_id", "")) != str(expected.motif_id) \
		or str(placement.get("face", "")) != str(expected.face) \
		or str(placement.get("mapping_id", "")) != str(expected.mapping_id) \
		or int(placement.get("anchor_run", -1)) != int(expected.anchor_run) \
		or _int_array(placement.get("run_ownership", []) as Array) != [int(expected.anchor_run)] \
		or not is_equal_approx(float(placement.get("center_chain_m", -1.0)), float(expected.center_chain_m)) \
		or not is_equal_approx(float(placement.get("center_chain_uncertainty_m", -1.0)), POSITION_UNCERTAINTY_M) \
		or str(placement.get("host_material_id", "")) != str(expected.host_material_id):
			return false
	return seen.size() == EXPECTED_PLACEMENTS.size()


static func _promote_to_live_attachment(live_root: Node3D, registry: Dictionary) -> bool:
	if live_root.get_child_count() != EXPECTED_PLACEMENTS.size() \
	or _count_type(live_root, CollisionObject3D) != 0 \
	or _count_type(live_root, CollisionShape3D) != 0 \
	or _count_type(live_root, NavigationRegion3D) != 0:
		return false
	live_root.set_meta("controlled_calibration", false)
	for child: Node in live_root.get_children():
		if not (child is Node3D):
			return false
		var module := child as Node3D
		var placement_id := str(module.get_meta("placement_id", ""))
		var expected := EXPECTED_PLACEMENTS.get(placement_id, {}) as Dictionary
		var placement := _placement_for(registry, placement_id)
		if expected.is_empty() or placement.is_empty():
			return false
		module.set_meta("placement_role", PLACEMENT_ROLE)
		module.set_meta("center_chain_m", float(expected.center_chain_m))
		module.set_meta("center_chain_uncertainty_m", POSITION_UNCERTAINTY_M)
		module.set_meta("anchor_run", int(expected.anchor_run))
		module.set_meta("run_ownership", [int(expected.anchor_run)])
		module.set_meta("face", str(expected.face))
		module.set_meta("mapping_id", str(expected.mapping_id))
		module.set_meta("host_material_id", str(expected.host_material_id))
		module.set_meta("cadence_inferred", false)
		module.set_meta("total_opening_count_inferred", false)
		for mesh_value: Node in module.get_children():
			if not (mesh_value is MeshInstance3D):
				return false
			var mesh_instance := mesh_value as MeshInstance3D
			if not (mesh_instance.mesh is BoxMesh) \
			or mesh_instance.material_override == null \
			or bool(mesh_instance.get_meta("collision", false)):
				return false
			mesh_instance.layers = RENDER_BUILDING_WALL
			var size := (mesh_instance.mesh as BoxMesh).size
			var clearance := REVIEWED_CALIBRATION.WALL_OFFSET_M + mesh_instance.position.z - size.z * 0.5
			if clearance < 0.001:
				return false
	return true


static func _render_topology(root_node: Node) -> Dictionary:
	var result := {"mesh_instances": 0, "surfaces": 0, "triangles": 0}
	if root_node is MeshInstance3D:
		var mesh := (root_node as MeshInstance3D).mesh
		if mesh == null:
			return result
		result.mesh_instances = 1
		result.surfaces = mesh.get_surface_count()
		for surface_index in mesh.get_surface_count():
			var arrays := mesh.surface_get_arrays(surface_index)
			var indices := arrays[Mesh.ARRAY_INDEX] as PackedInt32Array
			result.triangles += int(indices.size() / 3)
	for child: Node in root_node.get_children():
		var child_result := _render_topology(child)
		result.mesh_instances += int(child_result.mesh_instances)
		result.surfaces += int(child_result.surfaces)
		result.triangles += int(child_result.triangles)
	return result


static func _placement_for(registry: Dictionary, placement_id: String) -> Dictionary:
	for value: Variant in registry.get("placements", []):
		var placement := value as Dictionary
		if str(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


static func _count_type(node: Node, node_type: Variant) -> int:
	var count := 1 if is_instance_of(node, node_type) else 0
	for child: Node in node.get_children():
		count += _count_type(child, node_type)
	return count


static func _int_array(values: Array) -> Array[int]:
	var result: Array[int] = []
	for value: Variant in values:
		result.append(int(value))
	return result


static func _failure(code: String, message: String, record: Dictionary) -> Dictionary:
	return {"ok": false, "code": code, "message": message, "source_keys": record.get("source_keys", [])}


const FAMILY_PATH := "res://game/resources/facades/w34313564_quality_family.json"
const QUALITY_SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const FAMILY_PALE := preload("res://game/resources/materials/world/w34313564/w34313564_pale_exact_trial.tres")
const FAMILY_PLINTH := preload("res://game/resources/materials/world/w34313564/w34313564_plinth_field.tres")
const FAMILY_TAN := preload("res://game/resources/materials/world/w34313564/w34313564_tan_exact_trial.tres")


static func _build_sse_family(root: Node3D, record: Dictionary) -> bool:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FAMILY_PATH))
	if cfg.get("source_key") != SOURCE_KEY or _int_array(cfg.get("runs", [])) != [5,6,7,8,9]: return false
	# This unique target material is also used by its five accepted SSE host runs.
	# Updating that resource changes their color without adding a second wall skin.
	FAMILY_TAN.set_shader_parameter("base_color", Color(0.88,0.68,0.39))
	FAMILY_TAN.set_shader_parameter("secondary_color", Color(0.80,0.61,0.35))
	var pale := FAMILY_PALE.duplicate() as ShaderMaterial
	pale.set_shader_parameter("base_color", Color(0.94,0.93,0.87))
	pale.set_shader_parameter("secondary_color", Color(0.87,0.86,0.81))
	var plinth := FAMILY_PLINTH.duplicate() as ShaderMaterial
	plinth.set_shader_parameter("base_color", Color(0.93,0.92,0.86))
	plinth.set_shader_parameter("secondary_color", Color(0.86,0.85,0.80))
	var door_leaf := REVIEWED_CALIBRATION.DOOR.duplicate() as StandardMaterial3D
	door_leaf.albedo_color = Color(0.94,0.93,0.87)
	# Deliberately migrate the two SSE exemplars; retain all other native faces.
	for child: Node in root.get_children():
		var module := child as Node3D
		var placement := str(module.get_meta("placement_id", ""))
		if placement.begins_with("CAL-SSE-"):
			root.remove_child(module)
			module.free()
			continue
		var detail := "RetainedENEWindow" if placement == "CAL-ENE-HWIN-01" else ("RetainedNNWDoor" if placement == "CAL-NNW-PDOOR-01" else "RetainedNNWWindow")
		var run := int(EXPECTED_PLACEMENTS[placement].anchor_run)
		for part: Node in module.get_children():
			var mesh := part as MeshInstance3D
			if mesh == null: return false
			var composed := module.transform * mesh.transform
			module.remove_child(mesh)
			mesh.transform = composed
			mesh.name = placement.replace("-", "_") + "_" + str(mesh.name)
			_family_tag(mesh, "wall", detail, run)
			mesh.set_meta("placement_id", placement)
			if "Glass" in str(mesh.name): mesh.set_meta("opening_kind", "window")
			if "Leaf" in str(mesh.name): mesh.set_meta("opening_kind", "door")
			root.add_child(mesh)
		root.remove_child(module)
		module.free()
	var plinth_top := float(cfg.plinth_top_y_m)
	for run: int in range(5,10):
		var f := REVIEWED_CALIBRATION._run_frame(record, run)
		var tangent: Vector3 = f.tangent
		var normal: Vector3 = tangent.cross(Vector3.UP).normalized()
		if normal.dot(f.normal as Vector3) < 0.0: normal = -normal
		var basis := Basis(tangent, Vector3.UP, normal)
		var start: Vector3 = f.start
		var length_m := float(f.length_m)
		var top := float((f.top_start as Vector3).y)
		# Short vertical strips follow the sloping source bottom, buried into LAND.
		var count := int(ceil(length_m / 1.0))
		for index: int in count:
			var lo := 0.001 + (length_m - 0.002) * float(index) / count
			var hi := 0.001 + (length_m - 0.002) * float(index + 1) / count
			var base := lerpf(start.y, (f.end as Vector3).y, (lo+hi)*0.5/length_m) - 0.20
			_family_box(root, "Plinth%d_%d" % [run,index], basis, start, Vector3((lo+hi)*0.5,(base+plinth_top)*0.5,0.025), Vector3(hi-lo,plinth_top-base,0.10), plinth, "wall", "SSEPlinth", run)
		# Closed roof-edge extension, rear edge buried in retained roof backing.
		_family_box(root,"Eave%d" % run,basis,start,Vector3(length_m*0.5,top-0.10,0.46),Vector3(length_m-0.002,0.20,1.22),FAMILY_TAN,"detail","SSEEave",run)
		_family_box(root,"Fascia%d" % run,basis,start,Vector3(length_m*0.5,top-0.12,1.12),Vector3(length_m-0.002,0.24,0.10),pale,"detail","SSEFascia",run)
	for spec: Dictionary in cfg.openings:
		var run := int(spec.run)
		if run < 5 or run > 9: return false
		var f := REVIEWED_CALIBRATION._run_frame(record, run)
		var center := float(spec.center_m)
		var width := float(spec.width_m)
		var height := float(spec.height_m)
		if center-width*0.5-0.12 < 0.12 or center+width*0.5+0.12 > float(f.length_m)-0.12: return false
		var tangent: Vector3 = f.tangent
		var normal: Vector3 = tangent.cross(Vector3.UP).normalized()
		if normal.dot(f.normal as Vector3) < 0.0: normal = -normal
		var basis := Basis(tangent, Vector3.UP, normal)
		var origin: Vector3 = f.start + tangent*center + normal*0.075
		var door := str(spec.kind) == "door"
		var contract := {"opening_m":[width,height],"frame_thickness_m":0.08,"pane_count":int(spec.get("panes",2)),"base_clearance_assumption_m":0.0}
		var module := REVIEWED_CALIBRATION._build_door(contract) if door else REVIEWED_CALIBRATION._build_window(contract)
		origin.y = plinth_top+0.02 if door else float(spec.center_y_m)
		var placement := Transform3D(basis,origin)
		var surround_y := origin.y+height*0.5 if door else origin.y
		_family_box(root,"Surround%d" % root.get_child_count(),basis,f.start,Vector3(center,surround_y,0.055),Vector3(width+0.24,height+0.24,0.06),pale,"wall","SSESurround",run)
		for part: Node in module.get_children():
			var mesh := part as MeshInstance3D
			module.remove_child(mesh)
			mesh.transform = placement * mesh.transform
			mesh.name = "SSE%d_%d_%s" % [run,root.get_child_count(),mesh.name]
			_family_tag(mesh,"wall","SSEClosedDoor" if door else "SSEWindow",run)
			if "Glass" in str(mesh.name): mesh.set_meta("opening_kind","window")
			if "Leaf" in str(mesh.name):
				mesh.set_meta("opening_kind","door")
				mesh.material_override = door_leaf
			root.add_child(mesh)
		module.free()
	return true


static func _family_tag(mesh: MeshInstance3D, role: String, detail: String, run: int) -> void:
	mesh.layers = 3 if role == "wall" else 1
	mesh.set_meta("physical_role",role)
	mesh.set_meta("construction_detail",detail)
	mesh.set_meta("source_keys",[SOURCE_KEY])
	mesh.set_meta("derived_object_key",RECEIVER_KEY)
	mesh.set_meta("placement_status","production_inference")
	mesh.set_meta("host_runs",[run])
	mesh.set_meta("complete_motif",true)


static func _family_box(root: Node3D, label: String, basis: Basis, origin: Vector3, center: Vector3, size: Vector3, material: Material, role: String, detail: String, run: int) -> void:
	var mesh := REVIEWED_CALIBRATION._box(label,Vector3.ZERO,size,material)
	var position := origin + basis.x*center.x + basis.z*center.z
	position.y = center.y
	mesh.transform = Transform3D(basis,position)
	_family_tag(mesh,role,detail,run)
	root.add_child(mesh)
