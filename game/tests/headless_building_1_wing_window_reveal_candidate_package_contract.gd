extends SceneTree

## Direct-mounted-PCK runtime contract for the isolated Building 1 wing-window
## reveal candidate. This intentionally checks instantiated ordinary-world
## geometry instead of comparing exported/remapped script bytes with source
## bytes. The PCK itself is bound by an independently supplied SHA-256.

const WALL_KEY := "building:r16681702:wall"
const ROOF_KEY := "building:r16681702:roof"
const TOWER_WALL_KEY := "building:w1222720021:wall"
const TOWER_ROOF_KEY := "building:w1222720021:roof"
const D2_WALL_KEY := "building:w95934105:wall"
const D2_ROOF_KEY := "building:w95934105:roof"
const D2_ADAPTER_PATH := "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd"
const REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const CONFIG_PATH := "res://game/resources/facades/building_1_public_front_believability.json"
const EXPECTED_PCK_SHA256 := "835cfc74b5e4662abdab27d023f0dd0a00feaf06dcc19a73657bc6631d47474b"
const EXPECTED_REGISTRY_SHA256 := "26dcf64a34cf92aa7766c60940933190cdb5f9bc595dc23dc2f16fa01752e16c"
const EXPECTED_CONTRACTS_SHA256 := "8c61ea5601ab94852ac593b8658963b52cb5253aae22a2ff109f2e46771caa93"
const EXPECTED_CONFIG_SHA256 := "fca8feba243c4b1b1747050852ab2db7102aae668838ad8265524caa20cc6fc1"
const EXPECTED_REVEAL_SHA256 := "b3fa18f566ac516bdb94e3e70ddf4da155768277ef2d3c700d256719ce53960c"
const EXPECTED_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const EXPECTED_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const EXPECTED_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69612, "bodies": 466, "shapes": 466}
const EXPECTED_COMPONENTS := {
	WALL_KEY: {"meshes": 6, "surfaces": 6, "triangles": 9166, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	ROOF_KEY: {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
	TOWER_WALL_KEY: {"meshes": 3, "surfaces": 3, "triangles": 760, "bodies": 1, "shapes": 1, "collision_face_vertices": 120},
	TOWER_ROOF_KEY: {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1, "collision_face_vertices": 42},
}

var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var pck_path := _argument_value("--candidate-pck=")
	var pck_sha256 := _argument_value("--candidate-pck-sha256=")
	_require(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"), "Contract must execute from a directly mounted export PCK.")
	_require(pck_path.is_absolute_path() and FileAccess.file_exists(pck_path), "Exact absolute candidate PCK argument is required.")
	_require(pck_sha256 == EXPECTED_PCK_SHA256 and FileAccess.get_sha256(pck_path) == EXPECTED_PCK_SHA256, "Candidate PCK identity drifted.")
	_require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Frozen v9 registry bytes drifted in the PCK.")
	_require(FileAccess.get_sha256(CONTRACTS_PATH) == EXPECTED_CONTRACTS_SHA256, "Frozen v9 adapter-contract bytes drifted in the PCK.")
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Candidate Building 1 config bytes drifted in the PCK.")
	_require(_authority_exact(), "Mounted authority is not exactly unchanged v9 9/213.")
	if _failed:
		quit(1)
		return
	_validate_records()
	if not _failed:
		print("PASS: mounted Building 1 wing-window reveal candidate PCK is exact at v9 9/213; remap-loaded PCK builders produce B1 13/13/11071 with 528 reveal triangles while D2 ownership/collision remains intact, and authority records the candidate world target 735/959/974/69612/466/466")
	quit(1 if _failed else 0)


func _validate_records() -> void:
	var records := _records()
	_require(records.size() == EXPECTED_COMPONENTS.size() + 2, "Mounted target record closure did not resolve six exact B1/D2 records.")
	var combined_meshes := 0
	var combined_surfaces := 0
	var combined_triangles := 0
	for key: String in EXPECTED_COMPONENTS:
		var built := WorldChunkBuilder.new()._build_record(records.get(key, {}) as Dictionary, false)
		if not _require(bool(built.get("ok", false)), "%s did not build from the mounted PCK." % key):
			continue
		var node := built.node as Node3D
		var measured := {
			"meshes": int(built.mesh_instances),
			"surfaces": int(built.surfaces),
			"triangles": int(built.triangles),
			"bodies": int(built.static_bodies),
			"shapes": int(built.shapes),
		}
		measured["collision_face_vertices"] = int(node.get_meta("collision_face_vertices", -1))
		_require(measured == EXPECTED_COMPONENTS[key], "%s topology drifted: %s" % [key, JSON.stringify(measured)])
		_require(node.get_meta("source_keys", []) == (["r16681702"] if key.begins_with("building:r16681702") else ["w1222720021"]), "%s source ownership drifted." % key)
		combined_meshes += int(measured.meshes)
		combined_surfaces += int(measured.surfaces)
		combined_triangles += int(measured.triangles)
		node.free()
	_require(combined_meshes == 13 and combined_surfaces == 13 and combined_triangles == 11071, "B1 main+tower combined topology drifted.")
	var wall_built := WorldChunkBuilder.new()._build_record(records.get(WALL_KEY, {}) as Dictionary, false)
	var roof_built := WorldChunkBuilder.new()._build_record(records.get(ROOF_KEY, {}) as Dictionary, false)
	var wall := wall_built.get("node", null) as Node3D
	var roof := roof_built.get("node", null) as Node3D
	if wall != null and roof != null:
		var reveal := wall.get_node_or_null("HeroPublicFrontReveals") as MeshInstance3D
		_require(reveal != null and reveal.mesh is ArrayMesh, "Candidate reveal bucket is absent.")
		if reveal != null and reveal.mesh is ArrayMesh:
			_require(int(reveal.mesh.get_faces().size() / 3) == 528, "Candidate reveal bucket is not exactly 528 triangles.")
			_require(_mesh_sha256(reveal.mesh as ArrayMesh) == EXPECTED_REVEAL_SHA256, "Candidate reveal mesh bytes drifted.")
			var material := reveal.material_override
			if material == null:
				material = reveal.mesh.surface_get_material(0)
			_require(material != null and (material.resource_path.ends_with("building_1_reveal_shadow.tres") or material.resource_name == "Building1RevealShadow"), "Reveal material identity drifted: path=%s name=%s." % ["" if material == null else material.resource_path, "" if material == null else material.resource_name])
		_require(_collision_sha256(wall) == EXPECTED_WALL_COLLISION_SHA256, "B1 wall collision bytes drifted.")
		_require(_collision_sha256(roof) == EXPECTED_ROOF_COLLISION_SHA256, "B1 roof collision bytes drifted.")
		_require(_sole_collision_owner(wall, true, 2046), "B1 wall collision/spray ownership drifted.")
		_require(_sole_collision_owner(roof, false, 1737), "B1 roof collision/spray ownership drifted.")
		_require(bool(wall.get_meta("public_front_believability_pass", false)) and int(wall.get_meta("upper_windows_per_wing", -1)) == 8 and int(wall.get_meta("lower_windows_per_wing", -1)) == 7, "B1 wing schedule metadata drifted.")
		wall.free()
		roof.free()
	_validate_d2(records)


func _validate_d2(records: Dictionary) -> void:
	var adapter := load(D2_ADAPTER_PATH)
	var chunk := _json("res://generated/world/chunks/x_-1__z_-1.json")
	if not _require(adapter != null and not chunk.is_empty(), "D2 adapter/chunk is not remap-loadable from the PCK."):
		return
	var prepared: Dictionary = adapter.prepare_chunk_records(chunk)
	var plan: Dictionary = adapter.build_chunk_plan(prepared)
	if not _require(bool(plan.get("ok", false)), "Accepted D2 pair plan did not prepare from the mounted PCK: %s." % plan):
		return
	var wall_built: Dictionary = adapter.consume_record(records.get(D2_WALL_KEY, {}) as Dictionary, plan)
	var roof_built: Dictionary = adapter.consume_record(records.get(D2_ROOF_KEY, {}) as Dictionary, plan)
	if not _require(bool(wall_built.get("ok", false)) and bool(roof_built.get("ok", false)) and adapter.plan_was_fully_consumed(plan), "Accepted D2 pair did not consume atomically from the mounted PCK: wall=%s roof=%s." % [wall_built, roof_built]):
		return
	var wall := wall_built.node as Node3D
	var roof := roof_built.node as Node3D
	_require(_measure(wall) == {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1}, "D2 wall topology drifted under B1 candidate.")
	_require(_measure(roof) == {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1}, "D2 roof topology drifted under B1 candidate.")
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	_require(wall_body != null and roof_body != null and wall_shape != null and roof_shape != null, "D2 collision owners are absent.")
	if wall_body != null and roof_body != null and wall_shape != null and roof_shape != null:
		_require((wall_shape.shape as ConcavePolygonShape3D).get_faces().size() == 96 and (roof_shape.shape as ConcavePolygonShape3D).get_faces().size() == 30, "D2 collision faces drifted.")
		_require(wall_body.is_in_group("spray_receiver_wall") and not roof_body.is_in_group("spray_receiver_wall"), "D2 spray ownership drifted.")
		_require(bool(roof_body.get_meta("roof_landing_world_solid", false)), "D2 roof landing semantics drifted.")
	wall.free()
	roof.free()


func _authority_exact() -> bool:
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(CONTRACTS_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/9" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/8" \
		and int(metric.get("numerator", -1)) == 9 and int(metric.get("denominator", -1)) == 213 \
		and str(metric.get("display", "")) == "9/213" \
		and (metric.get("accepted_physical_unit_ids", []) as Array).size() == 9 \
		and (registry.get("active_runtime_adapters", []) as Array).size() == 8 \
		and (contracts.get("plans", []) as Array).size() == 17


func _records() -> Dictionary:
	var result := {}
	for path: String in ["res://generated/world/chunks/x_-1__z_2.json", "res://generated/world/chunks/x_0__z_2.json", "res://generated/world/chunks/x_-1__z_-1.json"]:
		var chunk := _json(path)
		for value: Variant in chunk.get("records", []) as Array:
			var record := value as Dictionary
			var key := str(record.get("object_key", ""))
			if key in [WALL_KEY, ROOF_KEY, TOWER_WALL_KEY, TOWER_ROOF_KEY, D2_WALL_KEY, D2_ROOF_KEY]:
				result[key] = record
	return result


func _measure(node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for candidate: Node in node.find_children("*", "", true, false):
		if candidate is MeshInstance3D:
			result.meshes += 1
			result.surfaces += (candidate as MeshInstance3D).mesh.get_surface_count()
			result.triangles += int((candidate as MeshInstance3D).mesh.get_faces().size() / 3)
		elif candidate is StaticBody3D:
			result.bodies += 1
		elif candidate is CollisionShape3D:
			result.shapes += 1
	return result


func _sole_collision_owner(node: Node3D, sprayable: bool, face_count: int) -> bool:
	var bodies := node.find_children("*", "StaticBody3D", true, false)
	var shapes := node.find_children("*", "CollisionShape3D", true, false)
	if bodies.size() != 1 or shapes.size() != 1:
		return false
	var body := bodies[0] as StaticBody3D
	var shape := (shapes[0] as CollisionShape3D).shape as ConcavePolygonShape3D
	return shape != null and shape.get_faces().size() == face_count \
		and body.is_in_group("spray_receiver_wall") == sprayable \
		and str(body.get_meta("derived_object_key", "")) == str(node.get_meta("derived_object_key", "")) \
		and body.get_meta("source_keys", []) == node.get_meta("source_keys", [])


func _collision_sha256(node: Node3D) -> String:
	var shape_node := node.get_node_or_null("Collision/Shape") as CollisionShape3D
	if shape_node == null or not shape_node.shape is ConcavePolygonShape3D:
		return ""
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	context.update((shape_node.shape as ConcavePolygonShape3D).get_faces().to_byte_array())
	return context.finish().hex_encode()


func _mesh_sha256(mesh: ArrayMesh) -> String:
	if mesh == null or mesh.get_surface_count() != 1:
		return ""
	var arrays := mesh.surface_get_arrays(0)
	var context := HashingContext.new()
	context.start(HashingContext.HASH_SHA256)
	for slot in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_INDEX]:
		var value: Variant = arrays[slot]
		if value is PackedVector3Array:
			context.update((value as PackedVector3Array).to_byte_array())
		elif value is PackedVector2Array:
			context.update((value as PackedVector2Array).to_byte_array())
		elif value is PackedInt32Array:
			context.update((value as PackedInt32Array).to_byte_array())
	return context.finish().hex_encode()


func _json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _require(condition: bool, message: String) -> bool:
	if condition:
		return true
	_failed = true
	push_error("B1_WING_REVEAL_MOUNTED_PACKAGE_FAIL: %s" % message)
	return false
