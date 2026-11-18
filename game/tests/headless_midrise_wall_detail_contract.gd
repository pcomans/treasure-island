extends SceneTree

## The mid-rise family's opt-in wall details, on hand-built inputs. The shared wall
## equipment kit (wall_equipment_kit.gd) lays out the same boxes for the same spec and
## other boxes for another seed, refuses bad specs, and gives every box increasing u, y
## and d ranges inside its stations, the cluster's signs on the wall at its foot and the
## duct's elbow on its top, curving back over the wall. The family (midrise_family.gd) refuses equipment off its
## edge or with a material role the kit does not have; an eave whose section stands
## outside the outline closes both ends, one inside it over walls on the outline neither;
## a grid hood's min_w leaves the narrow opening bare and hoods the wide one; and grid
## blinds are the same for the same seed, follow another seed, cover whole lights with a
## drop of 1, none with 0, and refuse a drop past 1. The family cases run its own build
## steps (_build_all) on a 20 x 10 m footprint, so expected refusals are read from its
## error list. Behaviour only.

const KIT := preload("res://game/scripts/world/facades/wall_equipment_kit.gd")
const MIDRISE := preload("res://game/scripts/world/facades/midrise_family.gd")
const SOURCE := "w0"
const GRID_SOURCE := {"kind": "rectified_photo", "ref": "test-photo", "date": "2025-09", "side": "s"}
const CLUSTER := {"s": [0.2, 6.0], "y": [9.0, 12.0], "mounts": 8, "cabinets": 3, "standoff": 0.45, "seed": 369}
const DUCT := {"s": [2.75, 3.3], "y": [12.0, 16.5], "depth": 0.3, "neck": 0.26, "over": 1.0, "conduits": 2, "strap_every": 1.5}
## The grid face (edge 0, stations along x): a 1 m opening and a 4 m one, on storey 1.
const NARROW := [2.0, 3.0]
const WIDE := [8.0, 12.0]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := run_checks()
	for failure: String in failures:
		print("FAIL: mid-rise wall detail: ", failure)
	if failures.is_empty():
		print("PASS: mid-rise wall detail: the equipment kit lays out the same boxes for a spec and others for another seed, refuses bad specs and keeps its boxes ordered, inside their stations, the signs at the foot and the duct's elbow curving back over its top; the family refuses equipment off its edge or with an unknown role; an outward eave closes both ends; a hood's min_w skips the narrow opening; grid blinds follow their seed and drops")
	quit(0 if failures.is_empty() else 1)


static func run_checks() -> Array:
	var failures := []
	_check_kit(failures)
	_check_kit_refusals(failures)
	_check_equipment_parts(failures)
	_check_outward_eave(failures)
	_check_hood_min_w(failures)
	_check_blinds(failures)
	return failures


static func _check_kit(failures: Array) -> void:
	var cluster: Dictionary = KIT.antenna_cluster(CLUSTER)
	_expect(failures, bool(cluster.ok) and not (cluster.boxes as Array).is_empty(), "a valid antenna cluster builds")
	_expect(failures, cluster.boxes == (KIT.antenna_cluster(CLUSTER.duplicate(true)) as Dictionary).boxes, "the same seed lays out the same cluster")
	_expect(failures, cluster.boxes != (KIT.antenna_cluster(_with(CLUSTER, {"seed": 370})) as Dictionary).boxes, "another seed lays out another cluster")
	for seed: int in [0, 1, 7, 369, 1000]:
		var made: Dictionary = KIT.antenna_cluster(_with(CLUSTER, {"seed": seed}))
		var label := "cluster seed %d" % seed
		_check_boxes(failures, label, made, float(CLUSTER.s[0]), float(CLUSTER.s[1]))
		var roles := {}
		for box: Dictionary in made.boxes:
			roles[box.role] = true
			var foot := float(CLUSTER.y[0]) + KIT.SIGN_BAND_M
			if str(box.role) == "sign":
				_expect(failures, float(box.d0) == 0.0 and float(box.y0) >= float(CLUSTER.y[0]) and float(box.y1) <= foot, "%s: a sign stands on the wall at the foot of the range" % label)
			elif str(box.role) != "pipe" and str(box.role) != "bracket":
				_expect(failures, float(box.y0) >= foot - 0.0001, "%s: its %s keeps above the signs' band" % [label, box.role])
		for role: String in ["pipe", "bracket", "panel", "cabinet", "radio", "cable", "sign"]:
			_expect(failures, roles.has(role), "%s has a %s" % [label, role])
	var duct: Dictionary = KIT.duct(DUCT)
	_expect(failures, bool(duct.ok) and duct.boxes == (KIT.duct(DUCT.duplicate(true)) as Dictionary).boxes, "the same duct spec gives the same duct")
	_check_boxes(failures, "duct", duct, -INF, INF)
	var shaft := {}
	var top := float(DUCT.y[1])
	for box: Dictionary in duct.boxes:
		_expect(failures, float(box.y1) <= top + float(DUCT.neck), "nothing of the duct rises above its elbow (%s)" % box.role)
		if str(box.role) == "duct" and shaft.is_empty():
			shaft = box
	_expect(failures, float(shaft.y1) == top, "the duct's shaft reaches the wall's top")
	var elbow := false
	for box: Dictionary in duct.boxes:
		if str(box.role) == "hood":
			elbow = true
			_expect(failures, float(box.y0) == top and float(box.y1) == top + float(DUCT.neck) and float(box.u0) == float(shaft.u0) and float(box.u1) == float(shaft.u1) and float(box.d1) == float(shaft.d1) and float(box.d0) == -float(DUCT.over), "the duct's elbow sits on the wall's top and curves back over it from the shaft's front")
		elif str(box.role) != "duct":
			_expect(failures, float(box.y1) <= top, "the duct's %s stays on the wall" % box.role)
	_expect(failures, elbow, "the duct has its elbow")


static func _check_kit_refusals(failures: Array) -> void:
	for case: Array in [
		[{"s": [1.0, 1.2]}, "narrow stations"], [{"y": [9.0, 10.0]}, "short range"], [{"mounts": 1}, "one mount"],
		[{"mounts": 13}, "13 mounts"], [{"standoff": 0.1}, "standoff"], [{"cabinets": -1}, "cabinets"],
		[{"s": ["a", 2.0]}, "text station"], [{"y": [9.0, NAN]}, "NaN height"],
	]:
		var made: Dictionary = KIT.antenna_cluster(_with(CLUSTER, case[0]))
		_expect(failures, not bool(made.ok) and not (made.errors as Array).is_empty() and (made.boxes as Array).is_empty(), "the kit refuses a cluster with %s" % case[1])
	for case: Array in [
		[{"s": [2.0, 2.1]}, "a 0.1 m shaft"], [{"y": [12.0, 12.5]}, "a short range"], [{"depth": 0.05}, "depth"],
		[{"neck": 0.05}, "neck"], [{"over": 0.1}, "a short run over"], [{"over": 6.0}, "a long run over"],
		[{"conduit_side": 0}, "conduit_side 0"], [{"conduits": 5}, "conduits"], [{"strap_every": 0.2}, "strap_every"],
	]:
		var made: Dictionary = KIT.duct(_with(DUCT, case[0]))
		_expect(failures, not bool(made.ok) and not (made.errors as Array).is_empty() and (made.boxes as Array).is_empty(), "the kit refuses a duct with %s" % case[1])


## Every box: a kit role, increasing ranges, and inside [u_min, u_max].
static func _check_boxes(failures: Array, label: String, made: Dictionary, u_min: float, u_max: float) -> void:
	_expect(failures, bool(made.ok), label + " builds")
	for box: Dictionary in made.boxes:
		_expect(failures, KIT.ROLES.has(str(box.role)), "%s: %s is a kit role" % [label, box.role])
		_expect(failures, float(box.u0) < float(box.u1) and float(box.y0) < float(box.y1) and float(box.d0) < float(box.d1), "%s: its %s has increasing u, y and d" % [label, box.role])
		_expect(failures, float(box.u0) >= u_min - 0.0001 and float(box.u1) <= u_max + 0.0001, "%s: its %s stays within its stations" % [label, box.role])


static func _check_equipment_parts(failures: Array) -> void:
	var cluster := _with(CLUSTER, {"kind": "antenna_cluster", "edge": 1, "s": [0.5, 9.5], "y": [1.0, 4.0]})
	var duct := _with(DUCT, {"kind": "duct", "edge": 1, "s": [4.0, 4.5], "y": [1.0, 5.5]})
	_expect(failures, _errors(_config({"parts": [cluster, duct]})).is_empty(), "equipment on its 10 m edge builds")
	var off := _errors(_config({"parts": [_with(cluster, {"s": [0.5, 10.5]})]}))
	_expect(failures, off.size() == 1 and str(off[0]).contains("off the edge"), "a cluster past its edge's end fails the build: %s" % [off])
	var run_off := _errors(_config({"parts": [_with(duct, {"s": [9.6, 9.95]})]}))
	_expect(failures, run_off.size() == 1 and str(run_off[0]).contains("runs past the edge"), "a duct whose conduits pass its edge's end fails the build: %s" % [run_off])
	var role := _errors(_config({"parts": [_with(duct, {"materials": {"chimney": "slab"}})]}))
	_expect(failures, role.size() == 1 and str(role[0]).contains("not a kit role"), "an unknown material role fails the build: %s" % [role])


static func _check_outward_eave(failures: Array) -> void:
	var out_profile := [[-0.45, 3.2, "slab"], [-0.45, 3.5, "slab"]]
	var in_profile := [[0.0, 3.2, "slab"], [0.0, 3.5, "slab"]]
	for case: Array in [[out_profile, true], [in_profile, false]]:
		var eave := {"edges": [0], "soffit": 3.2, "top": 3.5, "profile": case[0], "roof_material": "roof", "soffit_material": "soffit", "end_material": "eave_end"}
		var ctx := _build(_config({"eaves": [eave]}))
		var ends := _vertices(ctx, "support|eave_end")
		var at_start := false
		var at_end := false
		for p: Vector3 in ends:
			at_start = at_start or p.x < 1.0
			at_end = at_end or p.x > 19.0
		if bool(case[1]):
			_expect(failures, ctx.errors.is_empty() and at_start and at_end, "an eave outside the outline closes both ends (start %s, end %s, errors %s)" % [at_start, at_end, ctx.errors])
		else:
			_expect(failures, ctx.errors.is_empty() and ends.is_empty(), "an eave inside the outline over walls on it has no ends")


static func _check_hood_min_w(failures: Array) -> void:
	var ctx := _build(_config({}, {"window": {"hood": {"depth": 0.45, "h": 0.1, "over": 0.2, "gap": 0.03, "material": "hood_test", "min_w": 2.0}}}))
	var narrow := false
	var wide := false
	for p: Vector3 in _vertices(ctx, "support|hood_test"):
		narrow = narrow or (p.x > float(NARROW[0]) - 0.3 and p.x < float(NARROW[1]) + 0.3)
		wide = wide or (p.x > float(WIDE[0]) - 0.3 and p.x < float(WIDE[1]) + 0.3)
	_expect(failures, ctx.errors.is_empty() and wide and not narrow, "a hood's min_w hoods the wide opening and leaves the narrow one bare (wide %s, narrow %s, errors %s)" % [wide, narrow, ctx.errors])


static func _check_blinds(failures: Array) -> void:
	var drops := [1.0, 0.6, 0.0]
	var a := _vertices(_build(_blind_config(drops, 5)), "wall|blinds_test")
	var b := _vertices(_build(_blind_config(drops, 5)), "wall|blinds_test")
	var c := _vertices(_build(_blind_config(drops, 6)), "wall|blinds_test")
	_expect(failures, not a.is_empty() and a == b, "the same seed draws the same blinds")
	_expect(failures, a != c, "another seed draws other blinds")
	_expect(failures, _vertices(_build(_blind_config([0.0], 5)), "wall|blinds_test").is_empty(), "drops of 0 draw no blinds")
	# A drop of 1 covers each light, so the blinds span both openings from sill to head.
	var full := _vertices(_build(_blind_config([1.0], 5)), "wall|blinds_test")
	var lo := Vector3(INF, INF, INF)
	var hi := Vector3(-INF, -INF, -INF)
	for p: Vector3 in full:
		lo = lo.min(p)
		hi = hi.max(p)
	_expect(failures, absf(lo.x - float(NARROW[0])) < 0.001 and absf(hi.x - float(WIDE[1])) < 0.001, "drops of 1 cover the lights edge to edge (x %.3f-%.3f)" % [lo.x, hi.x])
	var ctx := _build(_config({}, {"grid_unit": {"unit": {"pane_w": 1.1}, "blinds": {"material": "blinds_test", "drops": [1.5], "seed": 1}}}))
	_expect(failures, ctx.errors.size() >= 1 and str(ctx.errors[0]).contains("blinds"), "a drop past 1 fails the build: %s" % [ctx.errors])


static func _blind_config(drops: Array, seed: int) -> Dictionary:
	return _config({}, {"grid_unit": {"unit": {"pane_w": 1.1, "split_min_w": 0.9}, "blinds": {"material": "blinds_test", "drops": drops, "seed": seed}}})


static func _with(base: Dictionary, extra: Dictionary) -> Dictionary:
	var out := base.duplicate(true)
	out.merge(extra, true)
	return out


static func _expect(failures: Array, condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


static func _vertices(ctx: MIDRISE.Ctx, key: String) -> PackedVector3Array:
	return (ctx.buckets[key] as MIDRISE.Bucket).vertices if ctx.buckets.has(key) else PackedVector3Array()


static func _errors(cfg: Dictionary) -> Array:
	return Array(_build(cfg).errors)


## The producer's build steps for a config on the hand-built footprint and land.
static func _build(cfg: Dictionary) -> MIDRISE.Ctx:
	var records := _records()
	var ctx := MIDRISE.Ctx.new()
	ctx.cfg = cfg
	ctx.source = SOURCE
	MIDRISE._build_all(ctx, records.wall, records.roof, records.chunks)
	return ctx


## One two-storey block over a 20 x 10 m footprint: edge 0 has the grid face (a narrow
## and a wide opening on storey 1, the ground storey blank), the others are blank.
## `extra` adds top-level fields; `grid_face` overrides the grid scheme's fields.
static func _config(extra: Dictionary, grid_face: Dictionary = {}) -> Dictionary:
	var palette := {}
	for key: String in ["render", "roof", "metal", "slab", "soffit", "coping", "rail", "mech", "frame", "frame_light", "glass", "roof_brown", "eave_end", "hood_test", "blinds_test"]:
		palette[key] = {"rgb": [0.5, 0.5, 0.5]}
	var grid_scheme := {
		"material": "render", "module": 60.0, "ground": {"kind": "blank"},
		"grid": {"columns": [NARROW.duplicate(), WIDE.duplicate()], "rows": {"*": {"sill": 0.9, "head": 2.4}}, "source": GRID_SOURCE.duplicate()},
	}
	grid_scheme.merge(grid_face, true)
	var cfg := {
		"schema_version": "ti.midrise-family/1",
		"target": {"source_key": SOURCE, "edge_normals": [[0.0, -1.0], [1.0, 0.0], [0.0, 1.0], [-1.0, 0.0]]},
		"floor": {"anchor_edge": 0, "above_terrain": 0.05},
		"levels": {"ground_h": 3.0, "storey_h": 3.0, "parapet_h": 0.0},
		"palette": palette,
		"schemes": {
			"wall": {"material": "render", "module": 60.0, "ground": {"kind": "blank"}, "upper": "blank"},
			"grid_face": grid_scheme,
		},
		"blocks": [{"id": "main", "storeys": 2, "ground_h": 3.0, "parapet": {"h": 0.0}, "faces": {"e0": "grid_face", "default": "wall"}}],
	}
	cfg.merge(extra, true)
	return cfg


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
