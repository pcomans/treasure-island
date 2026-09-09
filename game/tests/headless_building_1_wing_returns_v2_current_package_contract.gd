extends SceneTree

## Direct-mounted-PCK runtime contract for the isolated Building 1 wing-window
## returns v2 current release. This intentionally checks instantiated ordinary-world
## geometry instead of comparing exported/remapped script bytes with source
## bytes. The PCK itself is bound by an independently supplied SHA-256.
## This component gate does not instantiate the full world under the editor: its
## raw-source validation is intentionally unavailable in private packages. The
## companion Python package verifier binds complete signed-release headless/native smoke.

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
const EXPECTED_PCK_SHA256 := "454b913537742c8b605f41db8730c860de3ab37d08c4a3bfab5e15dc40f69403"
const EXPECTED_REGISTRY_SHA256 := "c6780895e339919f7ebe0900814afaa46fd15f31958946ec81b4391091a1d46f"
const EXPECTED_CONTRACTS_SHA256 := "24efc72b3315540f31dc112949ac108509cdc0e4eb9f5e20ef0d4b45ce41ac49"
const EXPECTED_CONFIG_SHA256 := "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb"
const EXPECTED_REVEAL_SHA256 := "ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de"
const EXPECTED_WALL_COLLISION_SHA256 := "21d69032bdba73c0406545b0b7d2c8efefd423fe8263815c3edc57bdc3756db5"
const EXPECTED_ROOF_COLLISION_SHA256 := "bb2c36915cba6d9d5f5d1a8239888ef1c913b1e4396eb6ce1cd2145c1a38e337"
const EXPECTED_COMPONENTS := {
	WALL_KEY: {"meshes": 6, "surfaces": 6, "triangles": 10246, "bodies": 1, "shapes": 1, "collision_face_vertices": 2046},
	ROOF_KEY: {"meshes": 3, "surfaces": 3, "triangles": 1131, "bodies": 1, "shapes": 1, "collision_face_vertices": 1737},
	TOWER_WALL_KEY: {"meshes": 3, "surfaces": 3, "triangles": 760, "bodies": 1, "shapes": 1, "collision_face_vertices": 120},
	TOWER_ROOF_KEY: {"meshes": 1, "surfaces": 1, "triangles": 14, "bodies": 1, "shapes": 1, "collision_face_vertices": 42},
}

const EXPECTED_COMPONENT_MESH_SHA256 := {
	"building:r16681702:wall": {
		"HeroBronze": "d7cc78de3148592c03b38f022d9744f7cd0c08495b69a6fe80d12498cf581e15",
		"HeroGlass": "7d7606c94e9aea27af5da01dbd047fc6378d2fb9f5d6cb59cd7b03e282340218",
		"HeroIvory": "9b2dcbf15a763c65047c99b9babae305cb566aaf920672075dc0ace085270f0c",
		"HeroProjectingBase": "0db13654d5261e6a2066d12be00447a9c55ea4a483ee8657cdede076ac52948b",
		"HeroPublicFrontReveals": "ca176003fd3f48d2fb3f08d40232398dfbda33949995cd9a47dec52e4a4de7de",
		"HeroTrim": "72f4b3305ec451504c9cafda98ba1439fcee02b50c529c036e54defe0cd179b0",
	},
	"building:r16681702:roof": {
		"HeroEntranceCanopy": "96301224bc182199306c560db5fd399552562e4d606fe87f3e13ec5d75cfa1c9",
		"HeroEntranceCanopyUnderside": "4655f16f18aa16b2f391535035ad0531562efbbce3dd2044ad80f46c1aed3e10",
		"HeroSteppedRoof": "bedbe6a66504ed798d1cd4532edbfc50391c811b43ada10d90fe4957bdf279f8",
	},
	"building:w1222720021:wall": {
		"HeroTowerExactPlanGlass": "7d66067a32063091eb849bd5ee5a86ecc159b96acb236c9a5383d9127d06724d",
		"HeroTowerIvory": "b025257394e663233d1ca41b69cc826af2e0e28d3929fd15c42190498daa6a53",
		"HeroTowerTrim": "87bd6d0b2a4c495b30ba15ad980edffbc4a911eb90e4c716f8312e6bd889e9d2",
	},
	"building:w1222720021:roof": {
		"HeroTowerPlatformAndPyramidalRoof": "d8341e02ce92eeb4bc8b87fc109dbe8134f0ccc9bf988625644082539fc98161",
	},
}


var _failed := false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for pin: String in [EXPECTED_PCK_SHA256, EXPECTED_REGISTRY_SHA256, EXPECTED_CONTRACTS_SHA256, EXPECTED_CONFIG_SHA256]:
		var hex := RegEx.new()
		hex.compile("^[0-9a-f]{64}$")
		_require(hex.search(pin) != null, "Every current package pin must be sealed before any check.")
	var pck_path := _argument_value("--current-pck=")
	var pck_sha256 := _argument_value("--current-pck-sha256=")
	_require(FileAccess.file_exists("res://project.binary") and not FileAccess.file_exists("res://project.godot"), "Contract must execute from a directly mounted export PCK.")
	_require(pck_path.is_absolute_path() and FileAccess.file_exists(pck_path), "Exact absolute current PCK argument is required.")
	_require(pck_sha256 == EXPECTED_PCK_SHA256 and FileAccess.get_sha256(pck_path) == EXPECTED_PCK_SHA256, "Current PCK identity drifted.")
	_require(FileAccess.get_sha256(REGISTRY_PATH) == EXPECTED_REGISTRY_SHA256, "Current v9 registry bytes drifted in the PCK.")
	_require(FileAccess.get_sha256(CONTRACTS_PATH) == EXPECTED_CONTRACTS_SHA256, "Current v9 adapter-contract bytes drifted in the PCK.")
	_require(FileAccess.get_sha256(CONFIG_PATH) == EXPECTED_CONFIG_SHA256, "Candidate Building 1 config bytes drifted in the PCK.")
	_require(GameMain.EXPECTED_TRIANGLES == 70692 and GameMain.EXPECTED_MESHES == 959 and GameMain.EXPECTED_SURFACES == 974, "Mounted current main must use the audited complete release smoke oracle.")
	_require(_authority_exact(), "Mounted authority is not exactly audited current v9 9/213.")
	if _failed:
		quit(1)
		return
	_validate_current_graph()
	_validate_records()
	if not _failed:
		print("PASS: mounted Building 1 wing-return v2 current PCK is exact at v9 9/213; remap-loaded PCK builders produce B1 13/13/12151 with 168 accepted center reveal triangles and 8244 trim triangles while D2 ownership/collision remains intact, complete headless/native release smoke is checked separately by the companion package verifier")
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
		var mesh_hashes := {}
		for child: Node in node.get_children():
			if child is MeshInstance3D:
				mesh_hashes[str(child.name)] = _mesh_sha256((child as MeshInstance3D).mesh as ArrayMesh)
		_require(mesh_hashes == EXPECTED_COMPONENT_MESH_SHA256[key], "%s complete protected/candidate mesh bytes drifted." % key)
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
	_require(combined_meshes == 13 and combined_surfaces == 13 and combined_triangles == 12151, "B1 main+tower combined topology drifted.")
	var wall_built := WorldChunkBuilder.new()._build_record(records.get(WALL_KEY, {}) as Dictionary, false)
	var roof_built := WorldChunkBuilder.new()._build_record(records.get(ROOF_KEY, {}) as Dictionary, false)
	var wall := wall_built.get("node", null) as Node3D
	var roof := roof_built.get("node", null) as Node3D
	if wall != null and roof != null:
		var reveal := wall.get_node_or_null("HeroPublicFrontReveals") as MeshInstance3D
		_require(reveal != null and reveal.mesh is ArrayMesh, "Candidate reveal bucket is absent.")
		if reveal != null and reveal.mesh is ArrayMesh:
			_require(int(reveal.mesh.get_faces().size() / 3) == 168, "Candidate reveal bucket is not exactly 168 triangles.")
			_require(_mesh_sha256(reveal.mesh as ArrayMesh) == EXPECTED_REVEAL_SHA256, "Candidate reveal mesh bytes drifted.")
			var material := reveal.material_override
			if material == null:
				material = reveal.mesh.surface_get_material(0)
			_require(material != null and (material.resource_path.ends_with("building_1_reveal_shadow.tres") or material.resource_name == "Building1RevealShadow"), "Reveal material identity drifted: path=%s name=%s." % ["" if material == null else material.resource_path, "" if material == null else material.resource_name])
		var trim := wall.get_node_or_null("HeroTrim") as MeshInstance3D
		var glass := wall.get_node_or_null("HeroGlass") as MeshInstance3D
		_require(trim != null and glass != null, "Mounted trim/glazing absent.")
		if trim != null and glass != null:
			var light_material := trim.material_override if trim.material_override != null else trim.mesh.surface_get_material(0)
			var dark_material := glass.material_override if glass.material_override != null else glass.mesh.surface_get_material(0)
			_require(_wing_material_semantics(light_material, dark_material), "Mounted returns/glazing lost exact light/dark scalar material semantics.")
		_require(int(wall.get_meta("wing_jamb_return_openings", -1)) == 30 and int(wall.get_meta("wing_jamb_return_strips_per_opening", -1)) == 4 and int(wall.get_meta("wing_dark_backing_boxes", -1)) == 0, "Mounted return schedule or removed backing scope drifted.")
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
	push_error("B1_RETURNS_V2_MOUNTED_PACKAGE_FAIL: %s" % message)
	return false


func _wing_material_semantics(trim_material: Material, glass_material: Material) -> bool:
	if not (trim_material is StandardMaterial3D) or not (glass_material is StandardMaterial3D):
		return false
	var light := trim_material as StandardMaterial3D
	var dark := glass_material as StandardMaterial3D
	for material: StandardMaterial3D in [light, dark]:
		if material.albedo_texture != null or material.normal_texture != null or material.roughness_texture != null or material.metallic_texture != null \
		or material.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED or material.emission_enabled:
			return false
	return light.albedo_color.is_equal_approx(Color(0.865, 0.84, 0.76, 1)) \
		and is_equal_approx(light.roughness, 0.78) and is_zero_approx(light.metallic) \
		and dark.albedo_color.is_equal_approx(Color(0.145, 0.205, 0.235, 1)) \
		and is_equal_approx(dark.roughness, 0.32) and is_equal_approx(dark.metallic, 0.14)


func _validate_current_graph() -> void:
	var registry := _json(REGISTRY_PATH)
	var contracts := _json(CONTRACTS_PATH)
	_require(str((registry.get("build_contract", {}) as Dictionary).get("compiler_version", "")) == "1.8.1", "Mounted compiler provenance drifted.")
	var b1_adapters := 0
	var d2_current_owners := 0
	for entry: Dictionary in registry.get("active_runtime_adapters", []):
		var contract := entry.get("active_runtime_contract", {}) as Dictionary
		var assets := entry.get("runtime_assets", []) as Array
		for asset: Dictionary in assets:
			var path := str(asset.get("path", ""))
			# Exported scripts/materials resolve through Godot remaps; source hash fields are provenance.
			if path.ends_with(".json"):
				_require(FileAccess.file_exists(path) and FileAccess.get_sha256(path) == str(asset.get("sha256", "")), "Mounted JSON dependency bytes drifted: %s" % path)
			else:
				_require(ResourceLoader.exists(path), "Mounted active dependency cannot resolve through its export remap: %s" % path)
		if str(entry.get("adapter_id", "")).begins_with("active-adapter:building-1-hero:"):
			b1_adapters += 1
			_require(assets.size() == 11 and contract.get("behavior_contract") == null, "Mounted B1 closure/null behavior drifted.")
			_require(str(contract.get("adapter_sha256", "")) == "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a" and str(contract.get("public_front_config_sha256", "")) == EXPECTED_CONFIG_SHA256, "Mounted B1 source provenance is not the accepted source.")
		var behavior := contract.get("behavior_contract") as Dictionary if contract.get("behavior_contract") is Dictionary else {}
		var geometry := behavior.get("geometry_contract", {}) as Dictionary
		if str(geometry.get("world_topology_scope", "")) == "current_integration_topology":
			d2_current_owners += 1
			_require(str(entry.get("adapter_id", "")) == "active-adapter:d2-1441-live:building:w95934105:wall", "Current world topology owner changed.")
			_require(int(geometry.get("world_triangles", -1)) == 70692 and int(geometry.get("visual_triangles", -1)) == 1578, "Mounted current world/D2 component topology drifted.")
			_require(str((behavior.get("acceptance_contract", {}) as Dictionary).get("capture_time_recognition_metric", "")) == "8/213", "D2 capture-time acceptance changed.")
	_require(b1_adapters == 2 and d2_current_owners == 1, "Mounted current B1/D2 graph count drifted.")
	var b1_plans := 0
	for plan: Dictionary in contracts.get("plans", []):
		if str(plan.get("receiver_key", "")) in [WALL_KEY, TOWER_WALL_KEY]:
			b1_plans += 1
			_require(plan.get("behavior_contract") == null and (plan.get("runtime_assets", []) as Array).size() == 11 and str(plan.get("integration_state", "")) == "package_safe_ready_for_integration", "Mounted B1 executable plan changed.")
	_require(b1_plans == 2, "Mounted B1 plan pair missing.")
