extends SceneTree

const PREBUILT_WORLD := preload("res://game/scripts/world/prebuilt_world.gd")
## Build the web static scene from the same validated source generator as native play.
## The generated scene is a disposable build product, never a source-of-truth cache.
var failed := false
var compared_resources := {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Static world baking requires a renderer: Dummy MultiMesh readback is not reliable.")
		quit(1)
		return
	print("BAKE_RENDERER ", DisplayServer.get_name(), " / ", RenderingServer.get_video_adapter_name())
	if not OS.get_cmdline_user_args().has("--web-world-bake"):
		push_error("Pass --web-world-bake to select the existing web material profile.")
		quit(1)
		return
	var world := load("res://game/scenes/world/world_root.tscn").instantiate() as WorldLoader
	root.add_child(world)
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void:
		push_error(code + ": " + message)
		failed = true)
	world.load_world()
	if failed or not world.is_world_validated():
		quit(1)
		return
	print("SOURCE_WORLD_MS ", world.runtime_evidence.load_duration_msec)
	var packed := PREBUILT_WORLD.pack_world(world)
	if packed == null:
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://generated/web")
	var error := ResourceSaver.save(packed, PREBUILT_WORLD.PATH, ResourceSaver.FLAG_COMPRESS)
	if error != OK:
		push_error("Static world save failed: " + error_string(error))
		quit(1)
		return
	# Load from disk, not the in-memory PackedScene, and compare actual properties.
	var reloaded := ResourceLoader.load(PREBUILT_WORLD.PATH, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if reloaded == null:
		quit(1)
		return
	var restored := reloaded.instantiate()
	for name: String in ["PlayableWorld", "ContextWorld"]:
		_compare_nodes(world.get_node(name), restored.get_node(name), name)
	_compare_value(world.get_spawn_transform(), restored.get_meta("spawn"), "spawn")
	_compare_value(world.get_boundary().get_boundary_data(), restored.get_meta("boundary"), "boundary")
	restored.free()
	world.free()
	await process_frame
	if failed:
		push_error("Static world serialization changed source semantics.")
		quit(1)
		return
	print("PASS: disk-reloaded static geometry, materials, transforms, metadata, groups and collision properties match the generated source")
	print("BAKED_BYTES ", FileAccess.get_file_as_bytes(PREBUILT_WORLD.PATH).size())
	print("MEMORY_STATIC_BYTES ", Performance.get_monitor(Performance.MEMORY_STATIC))
	quit(0)

func _compare_nodes(source: Node, restored: Node, path: String) -> void:
	_compare_value(source.get_class(), restored.get_class(), path + ":class")
	var source_meta: Array[String] = []
	var restored_meta: Array[String] = []
	for key in source.get_meta_list(): source_meta.append(str(key))
	for key in restored.get_meta_list(): restored_meta.append(str(key))
	source_meta.sort()
	restored_meta.sort()
	_compare_value(source_meta, restored_meta, path + ":metadata_names")
	for key: StringName in source.get_meta_list():
		_compare_value(source.get_meta(key), restored.get_meta(key), path + ":metadata:" + str(key))
	var source_groups := Array(source.get_groups())
	var restored_groups := Array(restored.get_groups())
	source_groups.sort()
	restored_groups.sort()
	_compare_value(source_groups, restored_groups, path + ":groups")
	for property: Dictionary in source.get_property_list():
		var key: String = property.name
		if int(property.usage) & PROPERTY_USAGE_STORAGE == 0 or key in ["owner", "unique_name_in_owner", "scene_file_path"] or key.begins_with("metadata/"):
			continue
		_compare_value(source.get(key), restored.get(key), path + ":" + key)
	_compare_value(source.get_child_count(), restored.get_child_count(), path + ":children")
	for child: Node in source.get_children():
		if not restored.has_node(NodePath(child.name)):
			_mismatch(path + "/" + child.name)
		else:
			_compare_nodes(child, restored.get_node(NodePath(child.name)), path + "/" + child.name)

func _compare_value(a: Variant, b: Variant, label: String) -> void:
	if a is Resource and b is Resource:
		var pair := str(a.get_instance_id()) + ":" + str(b.get_instance_id())
		if compared_resources.has(pair):
			return
		compared_resources[pair] = true
		if a.get_class() != b.get_class():
			_mismatch(label)
			return
		for property: Dictionary in a.get_property_list():
			var key: String = property.name
			if int(property.usage) & PROPERTY_USAGE_STORAGE != 0 and key not in ["resource_path"]:
				_compare_value(a.get(key), b.get(key), label + ":" + key)
	elif a is Array and b is Array:
		if a.size() != b.size():
			_mismatch(label)
			return
		for index in a.size():
			_compare_value(a[index], b[index], label + ":" + str(index))
	elif a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			_mismatch(label)
			return
		for key: Variant in a:
			if not b.has(key):
				_mismatch(label + ":missing:" + str(key))
			else:
				_compare_value(a[key], b[key], label + ":" + str(key))
	elif a != b:
		_mismatch(label)

func _mismatch(label: String) -> void:
	failed = true
	push_error("Serialization mismatch: " + label)
