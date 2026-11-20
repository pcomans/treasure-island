extends SceneTree
## The paving the housing buildings draw for themselves (parking pads, aprons, drives, walks
## and door paths), written out for the street generators.
##
##   tools/godot --headless --path . --script tools/export_building_paving.gd
##   tools/godot --headless --path . --script tools/export_building_paving.gd -- --check
##
## Builds every "housing" instance of game/resources/housing_family/live_instances.json
## through the family's own build (housing_site_family.gd, parts unmerged) over the frozen
## wall and roof records of generated/world/chunks, and takes the ground it draws: its
## "ground" parts (local_ground and entry paths). An instance that keeps its production
## ground (retain_production_roof) draws that ground instead, from its live factory as the
## world builds it (RETAINED below); its ground_visual parts are taken. A part drawn in a
## green that reads as lawn, and anything that is not flat ground (a shrub), is left out:
## the rest is paving. Writes each building's paving as plan triangles in world x/z to
## data/street_detail/building_paving.json. tools/build_godot_world.mjs reads that file: no
## plant stands on a building's paving (a tree's trunk keeps clear of it, a low plant's foot
## and a hedge's line stay off it).
##
## --check builds them the same way and compares them with the committed file; it names
## every building whose paving the file does not hold as the game draws it (to 1 cm) and
## exits 1. After a change that moves a building's drawn ground, run this script without
## --check, then node tools/build_godot_world.mjs.

const FAMILY := preload("res://game/scripts/world/facades/housing_site_family.gd")
const INSTANCES := "res://game/resources/housing_family/live_instances.json"
const CHUNKS := "res://generated/world/chunks"
const OUTPUT := "res://data/street_detail/building_paving.json"
const SCHEMA := "ti.building-paving/1"
const TOLERANCE_M := 0.01
## The live factories of the instances that keep their production ground, as the world
## chunk builder installs them (world_chunk_builder.gd's NORTHPOINT_1232/1241 replacements).
const RETAINED := {
	"w96215673": preload("res://game/scripts/world/facades/northpoint_1232_live_factory.gd"),
	"w96215674": preload("res://game/scripts/world/facades/northpoint_1241_live_factory.gd"),
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var check := OS.get_cmdline_user_args().has("--check")
	var built := build_paving()
	if not built.errors.is_empty():
		for message: String in built.errors:
			print("FAIL: building paving: " + message)
		quit(1)
		return
	if not check:
		var file := FileAccess.open(OUTPUT, FileAccess.WRITE)
		file.store_string(text_of(built.paving))
		file.close()
		print("PASS: building paving: wrote the paving of %d buildings (%d triangles) to %s" % [built.paving.size(), triangle_count(built.paving), OUTPUT])
		quit(0)
		return
	var problems := compare(built.paving, JSON.parse_string(FileAccess.get_file_as_string(OUTPUT)))
	for problem: String in problems:
		print("FAIL: building paving: " + problem)
	if problems.is_empty():
		print("PASS: building paving: %s holds the paving the game draws for %d buildings (%d triangles, to %.0f cm)" % [OUTPUT, built.paving.size(), triangle_count(built.paving), TOLERANCE_M * 100.0])
	else:
		print("FAIL: building paving: rerun tools/export_building_paving.gd, then node tools/build_godot_world.mjs")
	quit(0 if problems.is_empty() else 1)


## Every housing building's drawn paving: {paving: [{source_key, triangles_xz}], errors}.
static func build_paving() -> Dictionary:
	var records := {}
	for name: String in DirAccess.get_files_at(CHUNKS):
		if not name.ends_with(".json"):
			continue
		var chunk: Variant = JSON.parse_string(FileAccess.get_file_as_string(CHUNKS.path_join(name)))
		if not chunk is Dictionary:
			return {"paving": [], "errors": ["chunk %s does not parse" % name]}
		for record: Dictionary in chunk.records:
			records[str(record.object_key)] = record
	var manifest: Variant = JSON.parse_string(FileAccess.get_file_as_string(INSTANCES))
	var paving: Array = []
	var errors: Array[String] = []
	# The live factories only check that their two builder callables are valid; these paths
	# build no unpaired record, so any valid callable stands in for them.
	var holder := RefCounted.new()
	for item: Dictionary in manifest.instances:
		if str(item.get("family", "housing")) != "housing":
			continue
		var source := str(item.source_key)
		var wall_key := "building:" + source + ":wall"
		var roof_key := "building:" + source + ":roof"
		if not records.has(wall_key) or not records.has(roof_key):
			errors.append("%s has no wall or roof record in the chunks" % source)
			continue
		var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(item.config))
		if not cfg is Dictionary:
			errors.append("%s's config does not parse" % source)
			continue
		var parts: Array[MeshInstance3D] = []
		var model: Node3D = null
		if bool(cfg.get("retain_production_roof", false)):
			if not RETAINED.has(source):
				errors.append("%s keeps its production ground, but no live factory for it is listed in RETAINED" % source)
				continue
			var made: Dictionary = RETAINED[source].build_for_records(records[wall_key], records[roof_key], Callable(holder, "get_class"), Callable(holder, "get_class"))
			if not bool(made.get("ok", false)):
				errors.append("%s's live factory does not build: %s" % [source, made.get("message", "")])
				continue
			model = made.node
			for child: Node in model.get_children():
				if child is MeshInstance3D and str(child.get_meta("physical_role", "")) == "ground_visual":
					parts.append(child)
		else:
			model = FAMILY.build(records[wall_key], records[roof_key], cfg, false)
			if not bool(model.get_meta("build_valid", false)):
				model.free()
				errors.append("%s does not build, so the game would not draw it" % source)
				continue
			for child: Node in model.get_children():
				if child is MeshInstance3D and str(child.get_meta("family_role", "")) == "ground":
					parts.append(child)
		var triangles: Array = []
		for part: MeshInstance3D in parts:
			triangles.append_array(paving_triangles(part))
		model.free()
		if not triangles.is_empty():
			triangles.sort_custom(func(a: Array, b: Array) -> bool: return str(a) < str(b))
			paving.append({"source_key": source, "triangles_xz": triangles})
	paving.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return str(a.source_key) < str(b.source_key))
	return {"paving": paving, "errors": errors}


## A drawn ground part's paving as plan triangles, world x/z rounded to the centimetre: the
## surfaces of a flat mesh (an ArrayMesh, not a primitive such as a shrub's sphere) whose
## colour does not read as lawn (green at least red and well above blue).
static func paving_triangles(part: MeshInstance3D) -> Array:
	var out: Array = []
	if not part.mesh is ArrayMesh:
		return out
	for s in part.mesh.get_surface_count():
		var material := part.material_override as StandardMaterial3D
		if material == null:
			material = part.mesh.surface_get_material(s) as StandardMaterial3D
		if material != null and is_lawn(material.albedo_color):
			continue
		var arrays := part.mesh.surface_get_arrays(s)
		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var indices: PackedInt32Array = arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX] != null else PackedInt32Array()
		var count := indices.size() if not indices.is_empty() else vertices.size()
		for i in range(0, count, 3):
			var tri: Array = []
			for k in 3:
				var p: Vector3 = part.transform * vertices[indices[i + k] if not indices.is_empty() else i + k]
				tri.append([snappedf(p.x, 0.01), snappedf(p.z, 0.01)])
			var area: float = (tri[1][0] - tri[0][0]) * (tri[2][1] - tri[0][1]) - (tri[2][0] - tri[0][0]) * (tri[1][1] - tri[0][1])
			if absf(area) >= 1e-4:
				out.append(tri)
	return out


## Whether a ground colour reads as lawn: green at least red and well above blue.
static func is_lawn(c: Color) -> bool:
	return c.g >= c.r and c.g > c.b * 1.3


static func triangle_count(paving: Array) -> int:
	var count := 0
	for building: Dictionary in paving:
		count += (building.triangles_xz as Array).size()
	return count


## The document as written: its fields with sorted keys, one building per line.
static func text_of(paving: Array) -> String:
	var lines := PackedStringArray()
	for building: Dictionary in paving:
		lines.append("    " + JSON.stringify(building, "", true))
	return "{\n  \"notes\": %s,\n  \"paving\": [\n%s\n  ],\n  \"producer\": %s,\n  \"schema_version\": %s\n}\n" % [
		JSON.stringify([
			"The paving each housing building draws for itself, as drawn: its parking pads, aprons, drives, walks and door paths (housing_site_family.gd's ground parts, or for a building that keeps its production ground its live factory's ground_visual parts, less lawn-green and non-flat ones), as plan triangles in world x/z (metres, +x east, +z south).",
			"tools/build_godot_world.mjs reads this file: no plant stands on a building's paving (a tree's trunk keeps clear of it, a low plant's foot and a hedge's line stay off it). Regenerate it with tools/export_building_paving.gd after a change that moves a building's drawn ground; its --check (tools/test.sh) fails while the file differs from what the game draws.",
		]),
		",\n".join(lines),
		JSON.stringify("tools/export_building_paving.gd: game/scripts/world/facades/housing_site_family.gd build (and the retained buildings' live factories) over game/resources/housing_family/live_instances.json and the frozen wall and roof records of generated/world/chunks"),
		JSON.stringify(SCHEMA),
	]


## Problems, one per building, where the committed document differs from the drawn paving.
static func compare(built: Array, committed: Variant) -> Array[String]:
	var problems: Array[String] = []
	if not committed is Dictionary or str(committed.get("schema_version", "")) != SCHEMA or not committed.get("paving") is Array:
		problems.append("%s is missing or is not a %s document" % [OUTPUT, SCHEMA])
		return problems
	var held := {}
	for building: Variant in committed.paving:
		if not building is Dictionary or not building.has("source_key") or not building.get("triangles_xz") is Array:
			problems.append("%s holds a malformed building: %s" % [OUTPUT, str(building).left(120)])
			continue
		held[str(building.source_key)] = building.triangles_xz
	var seen := {}
	for building: Dictionary in built:
		var source := str(building.source_key)
		seen[source] = true
		if not held.has(source):
			problems.append("%s: the game draws its paving, the file lacks it" % source)
			continue
		var mine: Array = building.triangles_xz
		var theirs: Array = held[source]
		if mine.size() != theirs.size():
			problems.append("%s: the game draws %d paving triangles, the file holds %d" % [source, mine.size(), theirs.size()])
			continue
		for i in mine.size():
			if not same_triangle(mine[i], theirs[i]):
				problems.append("%s: paving triangle %d is %s as drawn, %s in the file" % [source, i, mine[i], theirs[i]])
				break
	for source: String in held:
		if not seen.has(source):
			problems.append("%s: the file holds paving the game no longer draws" % source)
	return problems


static func same_triangle(a: Variant, b: Variant) -> bool:
	if not a is Array or not b is Array or (a as Array).size() != 3 or (b as Array).size() != 3:
		return false
	for i in 3:
		var p: Variant = a[i]
		var q: Variant = b[i]
		if not p is Array or not q is Array or absf(float(p[0]) - float(q[0])) > TOLERANCE_M or absf(float(p[1]) - float(q[1])) > TOLERANCE_M:
			return false
	return true
