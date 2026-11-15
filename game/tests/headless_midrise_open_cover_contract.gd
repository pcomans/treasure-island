extends SceneTree

## The mid-rise family's open-cover rule (midrise_family.gd _check_open_covers) on a
## hand-built 20 x 10 m footprint split into a hall and a porch: a porch with open
## (posts) sides that is not open_sided, a pergola or a flat deck hides the hall's wall
## with only posts in its place, which left 899 13th St see-through (2026-11-15), so
## its build fails, flat or pitched, with one walled side too, and with an empty deck,
## which is no deck. Each exemption, a walled porch, two open blocks side by side and
## an open hall whose only wall is on its far side still build: what counts is the
## scheme of the hidden edge itself. The cases run the
## producer's own build steps (_build_all), so an expected failure is read from its
## error list instead of printed as an engine error, which the suite counts as a
## failure; the cases that should build also go through build() and must be valid.

const MIDRISE := preload("res://game/scripts/world/facades/midrise_family.gd")
const SOURCE := "w0"
const OPEN_COVER := "has open sides but hides the wall of block hall"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := run_checks()
	for failure: String in failures:
		print("FAIL: mid-rise open cover: ", failure)
	if failures.is_empty():
		print("PASS: mid-rise open cover: an open porch that hides a walled edge fails the build, an empty deck included; open_sided, pergola, flat deck, walled and open neighbours and an open hidden edge build")
	quit(0 if failures.is_empty() else 1)


static func run_checks() -> Array:
	var failures := []
	var flat_hall := {}
	var gable_hall := {"roof": {"form": "gable", "ridge_edge": 0, "pitch_deg": 15.0, "overhang": 0.3, "t": 0.12}}
	var mono_porch := {"roof": {"form": "mono", "low_edge": 2, "pitch_deg": 8.0, "overhang": 0.25, "t": 0.1}}
	# The fault: an open porch against the walled hall, flat and as at 899 13th St.
	_expect_fails(failures, "flat open porch", _config(flat_hall, {}, "posts"))
	_expect_fails(failures, "pitched open porch", _config(gable_hall, mono_porch, "posts"))
	# One walled side does not close the hall's wall behind the posts.
	_expect_fails(failures, "porch with one walled side", _config(flat_hall, {"faces": {"e2": "wall", "default": "posts"}}, "posts"))
	# An empty deck is no deck (_cover_floor): the porch still hides the hall's wall from the ground.
	_expect_fails(failures, "flat porch with an empty deck", _config(flat_hall, {"deck": {}}, "posts"))
	# Exemptions: open_sided and pergola leave the hall's wall standing; a flat deck hides
	# only its slab band, which its fascia closes.
	_expect_builds(failures, "open_sided porch", _config(flat_hall, {"open_sided": true}, "posts"))
	_expect_builds(failures, "open_sided pitched porch", _config(gable_hall, mono_porch.merged({"open_sided": true}), "posts"))
	_expect_builds(failures, "pergola porch", _config(flat_hall, {"pergola": {"rafter_edge": 0}}, "posts"))
	_expect_builds(failures, "flat deck porch", _config(flat_hall, {"deck": {"t": 0.3}}, "posts"))
	# A walled porch, and two open blocks with no wall between them to lose.
	_expect_builds(failures, "walled porch", _config(flat_hall, {}, "wall"))
	_expect_builds(failures, "open hall and porch", _config({"faces": {"default": "posts"}}, {}, "posts"))
	# The hidden edge's own scheme counts: a hall walled only on its far side (e0) loses no wall.
	_expect_builds(failures, "open porch beside an open hall edge", _config({"faces": {"e0": "wall", "default": "posts"}}, {}, "posts"))
	return failures


static func _expect_fails(failures: Array, label: String, cfg: Dictionary) -> void:
	var errors := _errors(cfg)
	if errors.size() != 1 or not str(errors[0]).contains(OPEN_COVER):
		failures.append("%s: expected only the open-cover error, got %s" % [label, errors])


static func _expect_builds(failures: Array, label: String, cfg: Dictionary) -> void:
	var errors := _errors(cfg)
	if not errors.is_empty():
		failures.append("%s: expected a valid build, got %s" % [label, errors])
		return
	var records := _records()
	var model := MIDRISE.build(records.wall, records.roof, cfg, records.chunks)
	if not bool(model.get_meta("build_valid", false)) or model.get_child_count() == 0:
		failures.append("%s: build() is not valid" % label)
	model.free()


## The producer's errors for a config on the hand-built footprint and land.
static func _errors(cfg: Dictionary) -> Array:
	var records := _records()
	var ctx := MIDRISE.Ctx.new()
	ctx.cfg = cfg
	ctx.source = SOURCE
	MIDRISE._build_all(ctx, records.wall, records.roof, records.chunks)
	return Array(ctx.errors)


## A hall (6 m deep from edge 0, 4 m high) and a porch (the other 4 m, 3 m high) over
## a 20 x 10 m footprint; hall and porch entries override the blocks' fields.
static func _config(hall: Dictionary, porch: Dictionary, porch_scheme: String) -> Dictionary:
	var hall_block := {"id": "hall", "storeys": 1, "ground_h": 4.0, "clip": [{"edge": 0, "max": 6.0}], "parapet": {"h": 0.0}, "faces": {"default": "wall"}}
	var porch_block := {"id": "porch", "storeys": 1, "ground_h": 3.0, "clip": [{"edge": 0, "min": 6.0}], "parapet": {"h": 0.0}, "faces": {"default": porch_scheme}}
	hall_block.merge(hall, true)
	porch_block.merge(porch, true)
	var palette := {}
	for key: String in ["render", "roof", "metal", "timber", "slab", "soffit", "coping"]:
		palette[key] = {"rgb": [0.5, 0.5, 0.5]}
	return {
		"schema_version": "ti.midrise-family/1",
		"target": {"source_key": SOURCE, "edge_normals": [[0.0, -1.0], [1.0, 0.0], [0.0, 1.0], [-1.0, 0.0]]},
		"floor": {"anchor_edge": 0, "above_terrain": 0.05},
		"levels": {"ground_h": 4.0, "storey_h": 3.0, "parapet_h": 0.0},
		"palette": palette,
		"schemes": {
			"wall": {"material": "render", "module": 60.0, "ground": {"kind": "blank"}},
			"posts": {"material": "render", "module": 60.0, "ground": {"kind": "blank"}, "open": {"post_w": 0.2, "module": 3.0}},
		},
		"blocks": [hall_block, porch_block],
	}


## The footprint's wall record (one quad run per edge, outward normals), its roof
## record and one chunk of flat land under it.
static func _records() -> Dictionary:
	var corners := [Vector2(0.0, 0.0), Vector2(20.0, 0.0), Vector2(20.0, 10.0), Vector2(0.0, 10.0)]
	var outward := [Vector2(0.0, -1.0), Vector2(1.0, 0.0), Vector2(0.0, 1.0), Vector2(-1.0, 0.0)]
	var vertices: Array = []
	var normals: Array = []
	for i in corners.size():
		var a: Vector2 = corners[i]
		var b: Vector2 = corners[(i + 1) % corners.size()]
		var n: Vector2 = outward[i]
		for p: Vector3 in [Vector3(a.x, 0.0, a.y), Vector3(b.x, 0.0, b.y), Vector3(b.x, 6.0, b.y), Vector3(a.x, 6.0, a.y)]:
			vertices.append_array([p.x, p.y, p.z])
			normals.append_array([n.x, 0.0, n.y])
	var land := {"feature_kind": "land_ground", "vertices": [-50.0, 0.0, -50.0, 70.0, 0.0, -50.0, 70.0, 0.0, 60.0, -50.0, 0.0, 60.0], "indices": [0, 1, 2, 0, 2, 3]}
	return {
		"wall": {"source_keys": [SOURCE], "vertices": vertices, "normals": normals},
		"roof": {"source_keys": [SOURCE]},
		"chunks": [{"records": [land]}],
	}
