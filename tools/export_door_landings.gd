extends SceneTree
## The mid-rise family's door landings and ramps, written out for the street generators.
##
##   tools/godot --headless --path . --script tools/export_door_landings.gd
##   tools/godot --headless --path . --script tools/export_door_landings.gd -- --check
##
## Builds every mid-rise instance of game/resources/housing_family/live_instances.json
## through the family's own build steps (midrise_family.gd _build_all, with the frozen
## wall and land records of generated/world/chunks) and writes each landing and ramp it
## draws, as plan corners in world x/z, to data/street_detail/door_landings.json.
## tools/build_godot_world.mjs reads that file: no plant, hedge or prop stands on a
## landing, the street ground's grass and mulch beside one are paved, and a sidewalk
## a landing stands up out of is cut at its outline.
##
## --check builds them the same way and compares them with the committed file; it names
## every door whose landing the file does not hold as the game builds it (to 1 mm) and
## exits 1. After a change that moves a mid-rise door or landing, run this script without
## --check, then node tools/build_godot_world.mjs.

const MIDRISE := preload("res://game/scripts/world/facades/midrise_family.gd")
const INSTANCES := "res://game/resources/housing_family/live_instances.json"
const CHUNKS := "res://generated/world/chunks"
const OUTPUT := "res://data/street_detail/door_landings.json"
const SCHEMA := "ti.door-landings/1"
const TOLERANCE_M := 0.001


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var check := OS.get_cmdline_user_args().has("--check")
	var built := build_landings()
	if not built.errors.is_empty():
		for message: String in built.errors:
			print("FAIL: door landings: " + message)
		quit(1)
		return
	if not check:
		var file := FileAccess.open(OUTPUT, FileAccess.WRITE)
		file.store_string(text_of(built.landings))
		file.close()
		print("PASS: door landings: wrote %d landings and ramps of %d mid-rise buildings to %s" % [built.landings.size(), built.buildings, OUTPUT])
		quit(0)
		return
	var problems := compare(built.landings, JSON.parse_string(FileAccess.get_file_as_string(OUTPUT)))
	for problem: String in problems:
		print("FAIL: door landings: " + problem)
	if problems.is_empty():
		print("PASS: door landings: %s holds the %d landings and ramps the game builds on %d mid-rise buildings (to %.0f mm)" % [OUTPUT, built.landings.size(), built.buildings, TOLERANCE_M * 1000.0])
	else:
		print("FAIL: door landings: rerun tools/export_door_landings.gd, then node tools/build_godot_world.mjs")
	quit(0 if problems.is_empty() else 1)


## Every mid-rise landing and ramp as the family builds it: {landings, buildings, errors}.
static func build_landings() -> Dictionary:
	var chunks: Array = []
	var records := {}
	for name: String in DirAccess.get_files_at(CHUNKS):
		if not name.ends_with(".json"):
			continue
		var chunk: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNKS.path_join(name)))
		if not chunk is Dictionary:
			return {"landings": [], "buildings": 0, "errors": ["chunk %s does not parse" % name]}
		chunks.append(chunk)
		for record: Dictionary in chunk.records:
			records[str(record.object_key)] = record
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(INSTANCES))
	var landings: Array = []
	var errors: Array[String] = []
	var buildings := 0
	for item: Dictionary in manifest.instances:
		if str(item.get("family", "housing")) != "midrise":
			continue
		var source := str(item.source_key)
		var wall_key := "building:" + source + ":wall"
		var roof_key := "building:" + source + ":roof"
		if not records.has(wall_key) or not records.has(roof_key):
			errors.append("%s has no wall or roof record in the chunks" % source)
			continue
		var ctx := MIDRISE.Ctx.new()
		ctx.cfg = JSON.parse_string(FileAccess.get_file_as_string(item.config))
		ctx.source = source
		MIDRISE._build_all(ctx, records[wall_key], records[roof_key], chunks)
		if not ctx.errors.is_empty():
			errors.append("%s does not build: %s" % [source, ctx.errors])
			continue
		buildings += 1
		for landing: Dictionary in ctx.landings:
			landings.append(rounded(source, landing))
	landings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return key_of(a) < key_of(b))
	# Each landing's name is its identity in the file and in the street generators.
	for i in range(1, landings.size()):
		if key_of(landings[i]) == key_of(landings[i - 1]):
			errors.append("two landings are named %s" % key_of(landings[i]))
	return {"landings": landings, "buildings": buildings, "errors": errors}


static func rounded(source: String, landing: Dictionary) -> Dictionary:
	var corners: Array = []
	for corner: Array in landing.top_xz:
		corners.append([snappedf(float(corner[0]), 0.001), snappedf(float(corner[1]), 0.001)])
	var heights: Variant = landing.top_y_m
	return {
		"source_key": source,
		"block": str(landing.block),
		"face": str(landing.face),
		"kind": str(landing.kind),
		"station_m": [snappedf(float(landing.station_m[0]), 0.001), snappedf(float(landing.station_m[1]), 0.001)],
		"top_y_m": [snappedf(float(heights[0]), 0.001), snappedf(float(heights[1]), 0.001)] if heights is Array else snappedf(float(heights), 0.001),
		"top_xz": corners,
	}


## A landing's name: source, block, face, kind and stations (a door's, or its ramp's).
static func key_of(landing: Dictionary) -> String:
	return "%s %s %s %s %.3f-%.3f" % [landing.source_key, landing.get("block", ""), landing.face, landing.kind, float(landing.station_m[0]), float(landing.station_m[1])]


## The document as written: its fields with sorted keys, one landing per line.
static func text_of(landings: Array) -> String:
	var lines := PackedStringArray()
	for landing: Dictionary in landings:
		lines.append("    " + JSON.stringify(landing, "", true))
	return "{\n  \"landings\": [\n%s\n  ],\n  \"notes\": %s,\n  \"producer\": %s,\n  \"schema_version\": %s\n}\n" % [
		",\n".join(lines),
		JSON.stringify([
			"Every mid-rise entry landing (door kind unit, lobby or porch) and ramp the game builds, as drawn: block and face name the building block and its footprint edge, station_m the door's (or ramp's) span along that block's face, top_xz its top's plan corners in world x/z (metres, +x east, +z south), top_y_m its top height (a ramp's at each end).",
			"tools/build_godot_world.mjs reads this file: no plant, hedge or prop stands on a landing, the street ground's grass and mulch beside one are paved, and a sidewalk a landing stands up out of is cut at its outline. Regenerate it with tools/export_door_landings.gd after a change that moves a mid-rise door; its --check (tools/test.sh) fails while the file differs from what the game builds.",
		]),
		JSON.stringify("tools/export_door_landings.gd: game/scripts/world/facades/midrise_family.gd _build_all over game/resources/housing_family/live_instances.json and the frozen wall and land records of generated/world/chunks"),
		JSON.stringify(SCHEMA),
	]


## Problems, one per door, where the committed document differs from the built landings.
static func compare(built: Array, committed: Variant) -> Array[String]:
	var problems: Array[String] = []
	if not committed is Dictionary or str(committed.get("schema_version", "")) != SCHEMA or not committed.get("landings") is Array:
		problems.append("%s is missing or is not a %s document" % [OUTPUT, SCHEMA])
		return problems
	var held := {}
	for landing: Variant in committed.landings:
		if not landing is Dictionary or not landing.has("source_key") or not landing.has("station_m"):
			problems.append("%s holds a malformed landing: %s" % [OUTPUT, landing])
			continue
		if held.has(key_of(landing)):
			problems.append("%s holds %s twice" % [OUTPUT, key_of(landing)])
		held[key_of(landing)] = landing
	var seen := {}
	for landing: Dictionary in built:
		var key := key_of(landing)
		seen[key] = true
		if not held.has(key):
			problems.append("%s: the game builds it, the file lacks it" % key)
			continue
		var other: Dictionary = held[key]
		var moved := not other.get("top_xz") is Array or (other.top_xz as Array).size() != (landing.top_xz as Array).size()
		if not moved:
			for i in (landing.top_xz as Array).size():
				var a: Array = landing.top_xz[i]
				var b: Variant = other.top_xz[i]
				moved = moved or not b is Array or absf(float(a[0]) - float(b[0])) > TOLERANCE_M or absf(float(a[1]) - float(b[1])) > TOLERANCE_M
		var ya: Array = landing.top_y_m if landing.top_y_m is Array else [landing.top_y_m]
		var yb: Array = other.top_y_m if other.get("top_y_m") is Array else [other.get("top_y_m", INF)]
		moved = moved or ya.size() != yb.size()
		if not moved:
			for i in ya.size():
				moved = moved or absf(float(ya[i]) - float(yb[i])) > TOLERANCE_M
		if moved:
			problems.append("%s: the game builds it at %s, top %s; the file has %s, top %s" % [key, landing.top_xz, landing.top_y_m, other.get("top_xz"), other.get("top_y_m")])
	for key: String in held:
		if not seen.has(key):
			problems.append("%s: the file holds it, the game no longer builds it" % key)
	return problems
