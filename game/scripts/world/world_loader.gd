class_name WorldLoader
extends Node3D

const STARTUP_MARKS := preload("res://game/scripts/debug/startup_marks.gd")
const PREBUILT_WORLD := preload("res://game/scripts/world/prebuilt_world.gd")

const MERSEA := preload("res://game/scripts/world/facades/mersea_live_attachment.gd")
const HOUSING_FAMILY := preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")

const BULGARIAN_WALL = preload("res://game/scripts/world/facades/bulgarian_wall_live_attachment.gd")
const FERRY_TERMINAL := preload("res://game/scripts/world/ferry_terminal.gd")

## The switchable street-detail layers: subtrees PlayableWorld/StreetDetail/<Layer>,
## kept out of the chunk meshes. Roads, sidewalks and other ground surfaces stay
## in the chunks and are always on. A layer that is off is freed after loading,
## collision included.
const STREET_DETAIL_LAYERS := GeneratedWorldContract.STREET_DETAIL_LAYERS
const STREET_DETAIL_ENABLED_SETTING := "treasure_island/street_detail/enabled"
const STREET_DETAIL_LAYERS_SETTING := "treasure_island/street_detail/layers"

signal load_progress(loaded: int, total: int)
signal world_ready(report: Dictionary)
signal world_failed(code: String, message: String, source_keys: Array)

@export_file("*.json") var default_manifest_path := "res://generated/world/manifest.json"

@onready var ground_and_areas: Node3D = $PlayableWorld/GroundAndAreas
@onready var roads_and_paths: Node3D = $PlayableWorld/RoadsAndPaths
@onready var buildings: Node3D = $PlayableWorld/Buildings
@onready var street_detail: Node3D = $PlayableWorld/StreetDetail
@onready var ybi_context: Node3D = $ContextWorld/YerbaBuenaIsland
@onready var bridge_context: Node3D = $ContextWorld/BayBridge
@onready var boundary_attached_context: Node3D = $ContextWorld/BoundaryAttachedVisuals
## The rock slope and boulders outside the outline (generated/world/shoreline.json).
@onready var shoreline_context: Node3D = $ContextWorld/Shoreline
## The ferry float, gangway, piles and the docked Sammy J (context.json ferry_terminal).
@onready var ferry_context: Node3D = $ContextWorld/FerryTerminal
@onready var world_boundary: WorldBoundary = $WorldBoundary
@onready var runtime_evidence: RuntimeEvidence = $RuntimeEvidence

## Street-detail layers a caller (a test or the static-world bake) wants for the
## next load, as an array of layer names; set it before load_world runs. null
## leaves the choice to the command line and the project setting.
var street_detail_request: Variant = null

var _spawn_transform := Transform3D.IDENTITY
var _validated := false
var _loading := false
var _street_detail_layers: Array[String] = []


func load_world(manifest_path: String = default_manifest_path) -> void:
	if _loading:
		return
	_loading = true
	_validated = false
	_clear_generated_children()
	runtime_evidence.begin_load(0)
	var street_choice := resolve_street_detail()
	if not street_choice.ok:
		_fail("street_detail_toggle", str(street_choice.message), [])
		return
	if OS.has_feature("web") or OS.has_feature("prebuilt_native_world") or OS.get_cmdline_user_args().has("--use-prebuilt-world"):
		_load_prebuilt(street_choice)
		return
	var validation := GeneratedWorldContract.load_and_validate(manifest_path)
	if not validation.ok:
		_fail(str(validation.get("code", "world_validation")), str(validation.get("message", "World validation failed.")), validation.get("source_keys", []))
		return

	var chunks: Array = validation.chunks
	runtime_evidence.set_expected_chunks(chunks.size())
	var builder := WorldChunkBuilder.new()
	var category_parents := {
		"ground": ground_and_areas,
		"roads": roads_and_paths,
		"buildings": buildings,
	}
	var staged_reports: Array[Dictionary] = []
	var loaded := 0
	for chunk_value: Variant in chunks:
		var build_result := builder.build_chunk(chunk_value, category_parents)
		if not build_result.ok:
			_free_staged(staged_reports)
			_fail(str(build_result.get("code", "chunk_build")), str(build_result.get("message", "Could not build a validated chunk.")), build_result.get("source_keys", []))
			return
		staged_reports.append(build_result)
		loaded += 1
		load_progress.emit(loaded, chunks.size() + 1)

	var context_parents := {
		"ybi": ybi_context,
		"bay_bridge": bridge_context,
		"boundary_attached_visual": boundary_attached_context,
	}
	var context_result := builder.build_context(validation.context, context_parents)
	if not context_result.ok:
		_free_staged(staged_reports)
		_fail(str(context_result.get("code", "context_build")), str(context_result.get("message", "Could not build validated context.")), context_result.get("source_keys", []))
		return
	staged_reports.append(context_result)
	load_progress.emit(chunks.size() + 1, chunks.size() + 1)
	var shoreline_result := ShorelineBuilder.new().build(validation.shoreline)
	if not shoreline_result.ok:
		_free_staged(staged_reports)
		_fail(str(shoreline_result.get("code", "shoreline_build")), str(shoreline_result.get("message", "Could not build the validated shoreline.")), [])
		return
	var furniture_result := StreetFurnitureBuilder.new().build(validation.street_detail)
	if not furniture_result.ok:
		shoreline_result.node.free()
		_free_staged(staged_reports)
		_fail(str(furniture_result.get("code", "street_furniture_build")), str(furniture_result.get("message", "Could not build the street furniture.")), [])
		return
	var fence_result := StreetFenceBuilder.new().build(validation.street_detail)
	if not fence_result.ok:
		furniture_result.node.free()
		shoreline_result.node.free()
		_free_staged(staged_reports)
		_fail(str(fence_result.get("code", "street_fence_build")), str(fence_result.get("message", "Could not build the street fences.")), [])
		return
	var clutter_result := StreetClutterBuilder.new().build(validation.street_detail)
	if not clutter_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		shoreline_result.node.free()
		_free_staged(staged_reports)
		_fail(str(clutter_result.get("code", "street_clutter_build")), str(clutter_result.get("message", "Could not build the street clutter.")), [])
		return
	# The planted trees and grass of the street-detail vegetation rows.
	var planting_result := StreetVegetationBuilder.new().build(validation.street_detail)
	if not planting_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		clutter_result.node.free()
		shoreline_result.node.free()
		_free_staged(staged_reports)
		_fail(str(planting_result.get("code", "street_vegetation_build")), str(planting_result.get("message", "Could not build the street vegetation.")), [])
		return

	# Attach only after every chunk and context mesh was validated and built.
	for report: Dictionary in staged_reports:
		builder.attach_built_chunk(report, category_parents)
		runtime_evidence.add_builder_report(report)
	shoreline_context.add_child(shoreline_result.node)
	runtime_evidence.add_builder_report(shoreline_result)
	var family_result := HOUSING_FAMILY.install(buildings, validation.chunks)
	if not family_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		clutter_result.node.free()
		planting_result.node.free()
		_fail("housing_family",str(family_result.message),family_result.get("source_keys",[]))
		return
	var bulgarian_result := BULGARIAN_WALL.install(buildings,ground_and_areas,validation.chunks)
	if not bulgarian_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		clutter_result.node.free()
		planting_result.node.free()
		_fail("bulgarian_wall",str(bulgarian_result.message),bulgarian_result.get("source_keys",[]))
		return
	var mersea_result := MERSEA.install(buildings, validation.chunks)
	if not mersea_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		clutter_result.node.free()
		planting_result.node.free()
		_fail("mersea", str(mersea_result.message), [])
		return
	# The gangway hangs from the canopy family's pier, installed with the housing family.
	var ferry_result := FERRY_TERMINAL.build(validation.context.ferry_terminal, buildings)
	if not ferry_result.ok:
		furniture_result.node.free()
		fence_result.node.free()
		clutter_result.node.free()
		planting_result.node.free()
		_fail("ferry_terminal", str(ferry_result.message), [])
		return
	ferry_context.add_child(ferry_result.node)
	runtime_evidence.add_builder_report(ferry_result)
	street_detail_layer("vegetation").add_child(planting_result.node)
	street_detail_layer("furniture").add_child(furniture_result.node)
	street_detail_layer("fences").add_child(fence_result.node)
	street_detail_layer("clutter").add_child(clutter_result.node)
	runtime_evidence.set_street_detail_report(validation.street_detail)
	_apply_street_detail_choice(street_choice)
	world_boundary.configure(validation.boundary)
	_spawn_transform = validation.spawn_transform
	_validated = true
	_loading = false
	var ready_report: Dictionary = validation.report.duplicate(true)
	ready_report["housing_family"] = family_result
	ready_report["bulgarian_wall"] = bulgarian_result
	ready_report["street_vegetation"] = {"trees": int(planting_result.trees), "shrubs": int(planting_result.shrubs), "grass_clumps": int(planting_result.grass_clumps), "multimesh_batches": int(planting_result.multimesh_batches), "collision_shapes": int(planting_result.collision_shapes)}
	ready_report["shoreline_boulders"] = int(shoreline_result.boulders)
	ready_report["shoreline_multimesh_batches"] = int(shoreline_result.multimesh_batches)
	ready_report["street_detail"] = street_detail_report()
	runtime_evidence.finish_load(ready_report)
	world_ready.emit(ready_report)


func _load_prebuilt(street_choice: Dictionary) -> void:
	STARTUP_MARKS.mark("resource_load_begin")
	var packed := load(PREBUILT_WORLD.resource_path()) as PackedScene
	STARTUP_MARKS.mark("resource_load_end")
	if packed == null:
		_fail("prebuilt_missing", "Static world is missing; rebuild through the platform build script.", [])
		return
	STARTUP_MARKS.mark("instantiate_begin")
	var baked := packed.instantiate()
	STARTUP_MARKS.mark("instantiate_end")
	if baked.get_meta("schema", "") != PREBUILT_WORLD.SCHEMA or baked.get_meta("profile", "") != PREBUILT_WORLD.profile() or not baked.has_node("PlayableWorld") or not baked.has_node("ContextWorld"):
		baked.free()
		_fail("prebuilt_invalid", "Invalid prebuilt world or material profile.", [])
		return
	var spawn: Variant = baked.get_meta("spawn", null)
	var boundary: Variant = baked.get_meta("boundary", null)
	var report: Variant = baked.get_meta("report", null)
	var evidence: Variant = baked.get_meta("evidence", null)
	if not spawn is Transform3D or not boundary is Dictionary or not report is Dictionary or not evidence is Dictionary:
		baked.free()
		_fail("prebuilt_state", "Prebuilt world is missing validated startup state.", [])
		return
	var valid_categories := true
	var required_paths: Array[String] = ["PlayableWorld/GroundAndAreas", "PlayableWorld/RoadsAndPaths", "PlayableWorld/Buildings", "PlayableWorld/StreetDetail", "ContextWorld/YerbaBuenaIsland", "ContextWorld/BayBridge", "ContextWorld/BoundaryAttachedVisuals", "ContextWorld/Shoreline", "ContextWorld/FerryTerminal"]
	for layer: String in STREET_DETAIL_LAYERS:
		required_paths.append("PlayableWorld/StreetDetail/" + layer.capitalize())
	for path: String in required_paths:
		valid_categories = valid_categories and baked.get_node_or_null(path) is Node3D
	for field: String in PREBUILT_WORLD.EVIDENCE_FIELDS:
		valid_categories = valid_categories and evidence.has(field) and typeof(evidence.get(field)) == typeof(runtime_evidence.get(field))
	if not valid_categories or not spawn.is_finite() or not GeneratedWorldContract.validate_boundary(boundary).ok or not GeneratedWorldContract.contains_xz(boundary, Vector2(spawn.origin.x, spawn.origin.z)):
		baked.free()
		_fail("prebuilt_content", "Prebuilt world has incomplete categories, evidence or spawn/boundary state.", [])
		return
	STARTUP_MARKS.mark("attach_configure_begin")
	for name: String in ["PlayableWorld", "ContextWorld"]:
		var old := get_node(name)
		remove_child(old)
		old.free()
		var child := baked.get_node(name)
		PREBUILT_WORLD.clear_owners(child)
		child.reparent(self, false)
	ground_and_areas = $PlayableWorld/GroundAndAreas
	roads_and_paths = $PlayableWorld/RoadsAndPaths
	buildings = $PlayableWorld/Buildings
	street_detail = $PlayableWorld/StreetDetail
	ybi_context = $ContextWorld/YerbaBuenaIsland
	bridge_context = $ContextWorld/BayBridge
	boundary_attached_context = $ContextWorld/BoundaryAttachedVisuals
	shoreline_context = $ContextWorld/Shoreline
	ferry_context = $ContextWorld/FerryTerminal
	world_boundary.configure(boundary)
	_spawn_transform = spawn
	for field: String in PREBUILT_WORLD.EVIDENCE_FIELDS:
		runtime_evidence.set(field, evidence[field])
	baked.free()
	_apply_street_detail_choice(street_choice)
	_validated = true
	_loading = false
	var ready_report: Dictionary = (report as Dictionary).duplicate(true)
	ready_report["street_detail"] = street_detail_report()
	runtime_evidence.finish_load(ready_report)
	STARTUP_MARKS.mark("attach_configure_end")
	STARTUP_MARKS.mark("reflection_setup_begin")
	preload("res://game/scripts/world/facades/mersea_model.gd").resume_prebuilt_reflections(buildings)
	STARTUP_MARKS.mark("reflection_setup_end")
	world_ready.emit(ready_report)


## The street-detail layers to keep for this load and where the choice came from:
## the caller's street_detail_request, else the command line
## (--street-detail on|off, --street-detail-layers vegetation,fences), else the
## project setting. {"ok": true, "layers": [...], "source": "..."} or
## {"ok": false, "message": "..."}.
func resolve_street_detail() -> Dictionary:
	if street_detail_request != null:
		if not street_detail_request is Array:
			return _street_detail_error("street_detail_request must be an array of layer names")
		return _street_detail_choice(street_detail_request, "caller")
	return parse_street_detail(
		OS.get_cmdline_user_args(),
		ProjectSettings.get_setting(STREET_DETAIL_ENABLED_SETTING, true),
		ProjectSettings.get_setting(STREET_DETAIL_LAYERS_SETTING, ",".join(PackedStringArray(STREET_DETAIL_LAYERS))),
	)


## The command-line and project-setting part of resolve_street_detail. Flags and
## their values are separate arguments; --street-detail off cannot be combined
## with a layer list, and any bad value is an error rather than a silent default.
static func parse_street_detail(args: PackedStringArray, setting_enabled: Variant, setting_layers: Variant) -> Dictionary:
	var values := {}
	var index := 0
	while index < args.size():
		var arg := args[index]
		if arg.begins_with("--street-detail=") or arg.begins_with("--street-detail-layers="):
			return _street_detail_error("pass %s and its value as separate arguments" % arg.get_slice("=", 0))
		if arg in ["--street-detail", "--street-detail-layers"]:
			if values.has(arg):
				return _street_detail_error("%s is given twice" % arg)
			if index + 1 >= args.size() or args[index + 1].is_empty() or args[index + 1].begins_with("--"):
				return _street_detail_error("%s needs a value" % arg)
			values[arg] = args[index + 1]
			index += 2
			continue
		index += 1
	if not values.is_empty():
		var mode := str(values.get("--street-detail", "on"))
		if mode not in ["on", "off"]:
			return _street_detail_error("--street-detail takes on or off, not %s" % mode)
		if mode == "off":
			if values.has("--street-detail-layers"):
				return _street_detail_error("--street-detail off conflicts with --street-detail-layers")
			return _street_detail_choice([], "command_line")
		if values.has("--street-detail-layers"):
			return _street_detail_choice(str(values["--street-detail-layers"]).split(","), "command_line")
		return _street_detail_choice(STREET_DETAIL_LAYERS, "command_line")
	if not setting_enabled is bool:
		return _street_detail_error("%s must be true or false" % STREET_DETAIL_ENABLED_SETTING)
	if not setting_enabled:
		return _street_detail_choice([], "project_setting")
	if setting_layers is String:
		return _street_detail_choice((setting_layers as String).split(","), "project_setting")
	if setting_layers is PackedStringArray or setting_layers is Array:
		return _street_detail_choice(setting_layers, "project_setting")
	return _street_detail_error("%s must list layer names" % STREET_DETAIL_LAYERS_SETTING)


## The node that holds one street-detail layer ("vegetation" -> StreetDetail/Vegetation).
func street_detail_layer(layer: String) -> Node3D:
	return street_detail.get_node(layer.capitalize()) as Node3D


## The street-detail layers that are on, in canonical order.
func get_street_detail_layers() -> Array[String]:
	return _street_detail_layers.duplicate()


## Switches street-detail layers off after loading: frees every layer that is not
## in layers, collision included. A freed layer stays empty until the next load,
## so this cannot switch a layer back on. Returns {"ok", "layers"} or {"ok", "message"}.
func apply_street_detail(layers: Array) -> Dictionary:
	var choice := _street_detail_choice(layers, "caller")
	if not choice.ok:
		return choice
	for layer: String in choice.layers:
		if layer not in _street_detail_layers:
			return _street_detail_error("street-detail layer %s is already off; reload the world to restore it" % layer)
	_apply_street_detail_choice(choice)
	return {"ok": true, "layers": get_street_detail_layers()}


func street_detail_report() -> Dictionary:
	var children := {}
	for layer: String in STREET_DETAIL_LAYERS:
		children[layer] = street_detail_layer(layer).get_child_count()
	return {
		"layers_on": get_street_detail_layers(),
		"source": runtime_evidence.street_detail_source,
		"layer_nodes": children,
		"rows": runtime_evidence.street_detail_rows,
	}


func _apply_street_detail_choice(choice: Dictionary) -> void:
	var keep: Array[String] = []
	keep.assign(choice.layers)
	for layer: String in STREET_DETAIL_LAYERS:
		if layer in keep:
			continue
		for child: Node in street_detail_layer(layer).get_children():
			child.free()
	_street_detail_layers = keep
	runtime_evidence.set_street_detail_layers(keep, str(choice.source))


static func _street_detail_choice(names: Variant, source: String) -> Dictionary:
	var chosen: Array[String] = []
	for name_value: Variant in names:
		var layer_name := str(name_value).strip_edges()
		if layer_name not in STREET_DETAIL_LAYERS:
			return _street_detail_error("unknown street-detail layer '%s' (layers: %s)" % [layer_name, ",".join(PackedStringArray(STREET_DETAIL_LAYERS))])
		if layer_name in chosen:
			return _street_detail_error("street-detail layer %s is listed twice" % layer_name)
		chosen.append(layer_name)
	var layers: Array[String] = []
	for layer: String in STREET_DETAIL_LAYERS:
		if layer in chosen:
			layers.append(layer)
	return {"ok": true, "layers": layers, "source": source}


static func _street_detail_error(message: String) -> Dictionary:
	return {"ok": false, "message": message}


func get_spawn_transform() -> Transform3D:
	return _spawn_transform if _validated else Transform3D.IDENTITY


func get_boundary() -> WorldBoundary:
	return world_boundary if _validated else null


func get_runtime_evidence() -> RuntimeEvidence:
	return runtime_evidence


func is_world_validated() -> bool:
	return _validated


func _fail(code: String, message: String, source_keys: Array) -> void:
	_clear_generated_children()
	_loading = false
	_validated = false
	runtime_evidence.fail_load(code, message)
	world_failed.emit(code, message, source_keys)


func _free_staged(reports: Array[Dictionary]) -> void:
	for report: Dictionary in reports:
		var node: Node = report.get("node", null)
		if node != null:
			node.free()


func _clear_generated_children() -> void:
	var parents: Array[Node3D] = [ground_and_areas, roads_and_paths, buildings, ybi_context, bridge_context, boundary_attached_context, shoreline_context, ferry_context]
	if street_detail != null:
		for layer: String in STREET_DETAIL_LAYERS:
			parents.append(street_detail_layer(layer))
	for parent: Node3D in parents:
		if parent == null:
			continue
		for child: Node in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
