extends SceneTree

const MANIFEST_PATH := "res://generated/world/manifest.json"
const FURNITURE_KIT := preload("res://game/scripts/world/street_furniture_kit.gd")
## A kit vertex this close to y = 0 (m) is on the ground; a foot this close to
## its listed rectangle (m) is inside it.
const FOOT_TOLERANCE_M := 0.001


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
	var feet_problem := _standing_feet_problem(result.street_detail)
	if feet_problem != "":
		push_error("FAIL [street_furniture_feet]: %s" % feet_problem)
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


## "" when every kit prop on legs that the generated street detail lists in
## prop_feet stands on those feet, which the generator settles it on: its mesh
## (no leg drops) reaches down to y = 0 and no lower, every vertex at that level
## lies inside a listed foot, and every listed foot holds some.
static func _standing_feet_problem(street_detail: Dictionary) -> String:
	var table: Variant = street_detail.get("prop_feet", null)
	if not table is Dictionary or (table as Dictionary).is_empty():
		return "the street detail lists no prop feet"
	var kit := FURNITURE_KIT.new()
	for prop: Variant in table:
		var feet: Array = table[prop]
		var vertices := kit.standing_vertices(str(prop))
		if vertices.is_empty() or feet.is_empty():
			return "%s has no kit legs or no listed feet" % prop
		var lowest := INF
		for vertex in vertices:
			lowest = minf(lowest, vertex.y)
		if absf(lowest) > FOOT_TOLERANCE_M:
			return "%s reaches down to y = %.4f m, not to its feet at 0" % [prop, lowest]
		var touching := []
		touching.resize(feet.size())
		touching.fill(0)
		for vertex in vertices:
			if vertex.y > FOOT_TOLERANCE_M:
				continue
			var owner := -1
			for index in feet.size():
				var foot: Dictionary = feet[index]
				if absf(vertex.x - float(foot.x)) <= float(foot.half_x) + FOOT_TOLERANCE_M and absf(vertex.z - float(foot.z)) <= float(foot.half_z) + FOOT_TOLERANCE_M:
					owner = index
			if owner < 0:
				return "%s touches the ground outside its listed feet at %s" % [prop, vertex]
			touching[owner] += 1
		var bare := touching.find(0)
		if bare >= 0:
			return "%s has no leg on its listed foot %s" % [prop, feet[bare]]
	return ""
