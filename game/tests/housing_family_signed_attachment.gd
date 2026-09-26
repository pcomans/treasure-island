extends RefCounted
# Read-only evidence for the already constructed signed normal world. No fixture
# construction, player movement, settings changes, or recognition decisions.
const ADOPTION = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")

static func inspect(world: Node3D) -> Dictionary:
	var adoption: Dictionary = ADOPTION.validate_live(world)
	if not bool(adoption.get("ok", false)):
		return {"ok": false, "message": "Existing adoption validator failed", "adoption": adoption}
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ADOPTION.CONFIG))
	var binding: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(ADOPTION.ADOPTION))
	var executable := OS.get_executable_path()
	var pck_path := executable.get_base_dir().get_base_dir().path_join("Resources").path_join(executable.get_file() + ".pck")
	var pck_expected := ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--family-evidence-pck-sha256="): pck_expected = argument.trim_prefix("--family-evidence-pck-sha256=")
	if pck_path.is_empty() or pck_expected.length() != 64 or FileAccess.get_sha256(pck_path) != pck_expected or not FileAccess.file_exists("res://project.binary") or FileAccess.file_exists("res://project.godot"):
		return {"ok": false, "message": "Signed exact PCK boundary missing"}
	var dependency_representations: Dictionary = {}
	for path: String in binding.dependencies:
		var representation: Dictionary = ADOPTION.dependency_representation(path, str(binding.dependencies[path]))
		if not bool(representation.get("ok", false)): return {"ok": false, "message": "Actual dependency representation drift", "path": path}
		dependency_representations[path] = representation
	var units: Array = []
	var found: Array[String] = []
	for model: Node3D in world.find_children("SharedHousing_*", "Node3D", true, false):
		var source := str(model.get_meta("source_key", ""))
		var parent := model.get_parent()
		var parent_key := str(parent.get_meta("derived_object_key", ""))
		var buildings: Node = world.get("buildings")
		var normal_owned: bool = buildings != null and buildings.is_ancestor_of(parent) and parent_key == "building:" + source + ":wall"
		if source in found or not normal_owned or not bool(model.get_meta("build_valid", false)):
			return {"ok": false, "message": "Actual family ownership/build drift", "source": source}
		found.append(source)
		var roles: Dictionary = {}
		for child: Node in model.get_children():
			if not (child is MeshInstance3D or child is StaticBody3D): continue
			var role := str(child.get_meta("family_role", "support"))
			if not roles.has(role): roles[role] = {"meshes": [], "bodies": []}
			if child is MeshInstance3D:
				roles[role].meshes.append({"path": str(world.get_path_to(child)), "visible": child.is_visible_in_tree(), "visual_layer": child.layers, "surfaces": child.mesh.get_surface_count() if child.mesh != null else 0})
			elif child is StaticBody3D:
				var shapes: Array = []
				for shape: Node in child.get_children():
					if shape is CollisionShape3D: shapes.append({"disabled": shape.disabled, "shape_present": shape.shape != null})
				roles[role].bodies.append({"path": str(world.get_path_to(child)), "object_key": str(child.get_meta("derived_object_key", "")), "source_keys": child.get_meta("source_keys", []), "collision_layer": child.collision_layer, "spray_receiver": child.is_in_group("spray_receiver_wall"), "shapes": shapes})
		var config_path := "res://game/resources/housing_family/" + source + ".json"
		var declared: Array = manifest.instances.filter(func(item: Dictionary) -> bool: return str(item.source_key) == source)
		if declared.size() != 1: return {"ok": false, "message": "Actual target not in exact manifest", "source": source}
		units.append({"source_key": source, "unit_id": "physical-building:" + source, "receiver_key": parent_key, "parent_path": str(world.get_path_to(parent)), "normal_loader_owned": normal_owned, "build_valid": model.get_meta("build_valid", false), "config": {"path": config_path, "sha256": FileAccess.get_sha256(config_path)}, "chunk": {"path": declared[0].chunk, "sha256": FileAccess.get_sha256(str(declared[0].chunk))}, "roles": roles})
	found.sort()
	var declared_sources: Array[String] = []
	for item: Dictionary in manifest.instances: declared_sources.append(str(item.source_key))
	declared_sources.sort()
	if found != declared_sources: return {"ok": false, "message": "Actual membership differs from manifest"}
	# Raw source digests for remapped executables are verified by the export binding,
	# not falsely reported as FileAccess hashes of nonexistent packaged .gd bytes.
	return {"ok": true, "pck_sha256": pck_expected, "manifest_sha256": FileAccess.get_sha256(ADOPTION.CONFIG), "adoption_sha256": FileAccess.get_sha256(ADOPTION.ADOPTION), "declared_dependencies": binding.dependencies, "dependency_representations": dependency_representations, "instances": manifest.instances, "actual_sources": found, "topology": ADOPTION.measure_world(world), "units": units}
