extends SceneTree

const MANIFEST_PATH := "res://generated/world/manifest.json"


func _initialize() -> void:
	if not FileAccess.file_exists(MANIFEST_PATH):
		push_error("FAIL [generated_scan_boundary]: Raw manifest is unavailable behind generated/.gdignore")
		quit(1)
		return
	var manifest_file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if manifest_file == null or manifest_file.get_length() <= 0:
		push_error("FAIL [generated_scan_boundary]: Raw manifest cannot be read behind generated/.gdignore")
		quit(1)
		return
	manifest_file.close()
	var result := GeneratedWorldContract.load_and_validate(MANIFEST_PATH)
	if not result.ok:
		push_error("FAIL [%s]: %s | sources=%s" % [result.get("code", "unknown"), result.get("message", "validation failed"), result.get("source_keys", [])])
		quit(1)
		return
	var report: Dictionary = result.report
	print("PASS: %d playable + %d context rows across %d chunks; manifest %s" % [
		report.playable_rows,
		report.context_rows,
		report.chunks,
		report.content_sha256,
	])
	quit(0)
