class_name WorldLoader
extends Node3D

signal load_progress(loaded: int, total: int)
signal world_ready(report: Dictionary)
signal world_failed(code: String, message: String, source_keys: Array)

@export_file("*.json") var default_manifest_path := "res://generated/world/manifest.json"

@onready var ground_and_areas: Node3D = $PlayableWorld/GroundAndAreas
@onready var roads_and_paths: Node3D = $PlayableWorld/RoadsAndPaths
@onready var buildings: Node3D = $PlayableWorld/Buildings
@onready var vegetation: Node3D = $PlayableWorld/Vegetation
@onready var ybi_context: Node3D = $ContextWorld/YerbaBuenaIsland
@onready var bridge_context: Node3D = $ContextWorld/BayBridge
@onready var boundary_attached_context: Node3D = $ContextWorld/BoundaryAttachedVisuals
@onready var world_boundary: WorldBoundary = $WorldBoundary
@onready var runtime_evidence: RuntimeEvidence = $RuntimeEvidence

var _spawn_transform := Transform3D.IDENTITY
var _validated := false
var _loading := false


func load_world(manifest_path: String = default_manifest_path) -> void:
	if _loading:
		return
	_loading = true
	_validated = false
	_clear_generated_children()
	runtime_evidence.begin_load(0)
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
	var vegetation_builder := VegetationBuilder.new()
	var vegetation_result := vegetation_builder.build(validation.vegetation)
	if not vegetation_result.ok:
		_free_staged(staged_reports)
		_fail(str(vegetation_result.get("code", "vegetation_build")), str(vegetation_result.get("message", "Could not build validated vegetation.")), [])
		return

	# Attach only after every chunk and context mesh was validated and built.
	for report: Dictionary in staged_reports:
		builder.attach_built_chunk(report, category_parents)
		runtime_evidence.add_builder_report(report)
	vegetation.add_child(vegetation_result.node)
	runtime_evidence.set_vegetation_report(vegetation_result)
	world_boundary.configure(validation.boundary)
	_spawn_transform = validation.spawn_transform
	_validated = true
	_loading = false
	var ready_report: Dictionary = validation.report.duplicate(true)
	ready_report["vegetation_multimesh_batches"] = int(vegetation_result.multimesh_batches)
	ready_report["vegetation_rendered_triangles"] = int(vegetation_result.rendered_triangles)
	runtime_evidence.finish_load(ready_report)
	world_ready.emit(ready_report)


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
	for parent: Node3D in [ground_and_areas, roads_and_paths, buildings, vegetation, ybi_context, bridge_context, boundary_attached_context]:
		if parent == null:
			continue
		for child: Node in parent.get_children():
			parent.remove_child(child)
			child.queue_free()
