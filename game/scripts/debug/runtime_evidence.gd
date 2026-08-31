class_name RuntimeEvidence
extends Node

var manifest_hash := "not-loaded"
var load_started_msec := 0
var load_duration_msec := 0
var load_failure_code := "none"
var load_failure_message := "none"
var chunks_loaded := 0
var chunks_expected := 0
var playable_rows := 0
var context_rows := 0
var mesh_instances := 0
var surfaces := 0
var triangles := 0
var static_bodies := 0
var shapes := 0
var vegetation_seed := 0
var vegetation_instances := 0
var vegetation_assets := 0
var vegetation_multimesh_batches := 0
var vegetation_rendered_triangles := 0
var vegetation_species_counts: Dictionary = {}
var vegetation_zone_counts: Dictionary = {}
var active_decals := 0
var tags_evicted := 0
var recovery_count := 0
var last_recovery_cause := "none"
var last_recovery_from := Vector3.ZERO
var last_spray_object := "none"
var last_spray_sources: Array = []
var spray_counts := {
	"placed": 0,
	"no_hit": 0,
	"range_rejection": 0,
	"receiver_rejection": 0,
	"identity_error": 0,
}
var player: CharacterBody3D
var boundary: WorldBoundary


func begin_load(expected_chunks: int) -> void:
	load_started_msec = Time.get_ticks_msec()
	chunks_expected = expected_chunks
	manifest_hash = "not-loaded"
	load_duration_msec = 0
	load_failure_code = "none"
	load_failure_message = "none"
	chunks_loaded = 0
	playable_rows = 0
	context_rows = 0
	mesh_instances = 0
	surfaces = 0
	triangles = 0
	static_bodies = 0
	shapes = 0
	vegetation_seed = 0
	vegetation_instances = 0
	vegetation_assets = 0
	vegetation_multimesh_batches = 0
	vegetation_rendered_triangles = 0
	vegetation_species_counts = {}
	vegetation_zone_counts = {}


func set_expected_chunks(expected_chunks: int) -> void:
	chunks_expected = expected_chunks


func finish_load(report: Dictionary) -> void:
	load_duration_msec = Time.get_ticks_msec() - load_started_msec
	manifest_hash = str(report.get("content_sha256", "unknown"))
	chunks_loaded = int(report.get("chunks", 0))
	playable_rows = int(report.get("playable_rows", 0))
	context_rows = int(report.get("context_rows", 0))


func fail_load(code: String, message: String) -> void:
	load_duration_msec = Time.get_ticks_msec() - load_started_msec
	load_failure_code = code
	load_failure_message = message


func add_builder_report(report: Dictionary) -> void:
	mesh_instances += int(report.get("mesh_instances", 0))
	surfaces += int(report.get("surfaces", 0))
	triangles += int(report.get("triangles", 0))
	static_bodies += int(report.get("static_bodies", 0))
	shapes += int(report.get("shapes", 0))


func set_vegetation_report(report: Dictionary) -> void:
	vegetation_seed = int(report.get("seed", 0))
	vegetation_instances = int(report.get("instances", 0))
	vegetation_assets = int(report.get("assets", 0))
	vegetation_multimesh_batches = int(report.get("multimesh_batches", 0))
	vegetation_rendered_triangles = int(report.get("rendered_triangles", 0))
	vegetation_species_counts = report.get("species_counts", {}).duplicate(true)
	vegetation_zone_counts = report.get("zone_counts", {}).duplicate(true)


func bind_runtime(player_body: CharacterBody3D, world_boundary: WorldBoundary) -> void:
	player = player_body
	boundary = world_boundary


func record_spray(result_code: String) -> void:
	if spray_counts.has(result_code):
		spray_counts[result_code] += 1


func set_active_decals(count: int) -> void:
	active_decals = count


func record_tag_eviction() -> void:
	tags_evicted += 1


func record_spray_identity(derived_object_key: String, source_keys: Array) -> void:
	last_spray_object = derived_object_key
	last_spray_sources = source_keys.duplicate()


func record_recovery(cause: String, from_position: Vector3) -> void:
	recovery_count += 1
	last_recovery_cause = cause
	last_recovery_from = from_position


func debug_text() -> String:
	var fps := Engine.get_frames_per_second()
	var frame_ms := 0.0 if fps <= 0.0 else 1000.0 / fps
	var node_count := get_tree().get_node_count()
	var player_position := Vector3.ZERO if player == null else player.global_position
	var grounded := false if player == null else player.is_on_floor()
	var in_boundary := false if player == null or boundary == null else boundary.contains_position(player_position)
	var has_safe_transform: bool = false if player == null else player.get_recovery_controller().has_safe_transform()
	var static_memory_mib := float(Performance.get_monitor(Performance.MEMORY_STATIC)) / (1024.0 * 1024.0)
	return "\n".join([
		"Manifest: %s" % manifest_hash,
		"Load: %d ms | chunks %d/%d | coverage %d+%d | failure %s" % [load_duration_msec, chunks_loaded, chunks_expected, playable_rows, context_rows, load_failure_code],
		"Meshes: %d | surfaces %d | triangles %d" % [mesh_instances, surfaces, triangles],
		"Vegetation: seed %d | %d instances | %d assets | %d batches | %d rendered triangles" % [vegetation_seed, vegetation_instances, vegetation_assets, vegetation_multimesh_batches, vegetation_rendered_triangles],
		"Physics: %d bodies | %d shapes | nodes %d" % [static_bodies, shapes, node_count],
		"Frame: %.1f FPS | %.2f ms" % [fps, frame_ms],
		"Memory: %.1f MiB static" % static_memory_mib,
		"Player: (%.1f, %.1f, %.1f) | grounded %s | in boundary %s | safe transform %s" % [player_position.x, player_position.y, player_position.z, grounded, in_boundary, has_safe_transform],
		"Tags: %d | evicted %d | placed %d | no hit %d | range %d | receiver %d | identity %d" % [active_decals, tags_evicted, spray_counts.placed, spray_counts.no_hit, spray_counts.range_rejection, spray_counts.receiver_rejection, spray_counts.identity_error],
		"Last tag: %s | %s" % [last_spray_object, ",".join(last_spray_sources)],
		"Recoveries: %d | last %s from (%.1f, %.1f, %.1f)" % [recovery_count, last_recovery_cause, last_recovery_from.x, last_recovery_from.y, last_recovery_from.z],
	])
