extends RefCounted
## The generated world around its enterable interiors, built as the world builds it, for
## the headless contracts that check an interior in its place
## (headless_interior_ground_contract.gd, headless_interior_far_stand_in_contract.gd).
## The catalog units that list walk-through "passages" (game/tests/shared/building_fit.gd
## walks them) are entered into an interior that their producer builds beside the unit's
## records: a node carrying INTERIOR_META (Building 1's concourse,
## building_1_interior.gd). The chunks that hold a unit's records (the coverage ledger's
## chunk_ids) and those under a plan rectangle are built with the world's own
## WorldChunkBuilder, each once, under the world's category parents (PARTS).

const Catalog := preload("res://game/tests/shared/catalog.gd")
const WORLD := "res://generated/world/"
const MANIFEST := WORLD + "manifest.json"
const LEDGER := WORLD + "coverage-ledger.csv"
## The meta an interior's root carries: the OSM key of the building it is inside.
const INTERIOR_META := "interior_of_source_key"
## The world's category parents (WorldChunkBuilder, WorldLoader): "ground" and "roads"
## hold the outdoor ground, "buildings" the buildings and the interiors beside them.
const PARTS := ["ground", "roads", "buildings"]

## What went wrong: an unreadable manifest or ledger, a chunk missing or not building.
var errors: Array[String] = []
## The category parents by name, under the root given.
var parents := {}
var chunk_size := 0.0
var _root: Node
var _paths := {}
var _ledger := {}
var _built := {}
var _builder := WorldChunkBuilder.new()


func _init(root: Node) -> void:
	_root = root
	for part: String in PARTS:
		var parent := Node3D.new()
		parent.name = part
		root.add_child(parent)
		parents[part] = parent
	var manifest := json(MANIFEST)
	chunk_size = float(manifest.get("chunk_size_m", 0.0))
	for entry: Dictionary in manifest.get("chunks", []):
		_paths[str(entry.chunk_id)] = WORLD + str(entry.path)
	if chunk_size <= 0.0 or _paths.is_empty():
		errors.append("the generated world's manifest names no chunks")
		return
	_read_ledger()


## The catalog units that list walk-through passages.
static func units_with_passages() -> Array[Dictionary]:
	var units: Array[Dictionary] = []
	for unit: Dictionary in Catalog.units():
		if not (unit.get("passages", []) as Array).is_empty():
			units.append(unit)
	return units


## Builds the chunks that hold the source's records: false when no chunk does.
func build_holding(source: String) -> bool:
	var holding: Array = _ledger.get(source, [])
	for chunk_id: String in holding:
		build(chunk_id)
	return not holding.is_empty()


## Builds every chunk of the world under the plan rectangle low..high (world XZ).
func build_under(low: Vector2, high: Vector2) -> void:
	for i in range(floori(low.x / chunk_size), floori(high.x / chunk_size) + 1):
		for j in range(floori(low.y / chunk_size), floori(high.y / chunk_size) + 1):
			var chunk_id := "x_%d__z_%d" % [i, j]
			if _paths.has(chunk_id):
				build(chunk_id)


## Builds one generated chunk with the world's builder, once, under the parents.
func build(chunk_id: String) -> void:
	if _built.has(chunk_id):
		return
	_built[chunk_id] = true
	if not _paths.has(chunk_id):
		errors.append("chunk %s is not in the generated world" % chunk_id)
		return
	var report := _builder.build_chunk(json(str(_paths[chunk_id])), parents)
	if not bool(report.get("ok", false)):
		errors.append("chunk %s does not build: %s" % [chunk_id, str(report.get("message", report))])
		return
	_builder.attach_built_chunk(report, parents)


## Every node marked as the source's interior, searched from the root, so one built
## outside the buildings' parent is found too.
func interiors(source: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	for node: Node in _root.find_children("*", "Node3D", true, false):
		if str(node.get_meta(INTERIOR_META, "")) == source:
			found.append(node as Node3D)
	return found


## Frees what was built.
func free_parents() -> void:
	for part: String in parents:
		if is_instance_valid(parents[part]):
			(parents[part] as Node).free()
	parents.clear()


static func json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


## Each source key's chunks, from the coverage ledger's chunk_ids column.
func _read_ledger() -> void:
	var file := FileAccess.open(LEDGER, FileAccess.READ)
	if file == null:
		errors.append("the coverage ledger %s can't be read" % LEDGER)
		return
	var header := file.get_csv_line()
	var key_at := header.find("source_key")
	var chunks_at := header.find("chunk_ids")
	if key_at < 0 or chunks_at < 0:
		errors.append("the coverage ledger has no source_key or chunk_ids column")
		return
	while not file.eof_reached():
		var line := file.get_csv_line()
		if line.size() <= maxi(key_at, chunks_at):
			continue
		var ids: Array[String] = []
		for id in line[chunks_at].split(";", false):
			ids.append(id.strip_edges())
		_ledger[line[key_at]] = ids
