extends SceneTree

## The mid-rise family's opt-in wall details, on hand-built inputs. The shared wall
## equipment kit (wall_equipment_kit.gd) lays out the same boxes for the same spec and
## other boxes for another seed, refuses bad specs, and gives every box increasing u, y
## and d ranges inside its stations, the cluster's signs on the wall at its foot, and
## the duct rising past the wall's top into a rounded bend whose run is held clear of
## it, with sky under it, before dropping onto the roof. The family (midrise_family.gd)
## refuses equipment off its edge or with a material role the kit does not have, and a
## duct that does not end at its wall's top or whose drop misses the roof inside the
## parapet; an eave whose section stands
## outside the outline closes both ends, one inside it over walls on the outline neither;
## a grid hood's min_w leaves the narrow opening bare and hoods the wide one; grid
## blinds are the same for the same seed, follow another seed, cover whole lights with a
## drop of 1, none with 0, and refuse a drop past 1; and every door kind and a garage
## is paved from its landing to the door at the sill's height, with no ground showing in
## its recess (the Job Corps doors showed grass there: owner, 2026-11-19), the landing
## and the recess floor meeting edge to edge, on flat land and on land rising 0.2 m into
## the building across the recess (the sill clears the land at the recess's back); a
## doorstep stopping 0.3 m short of a side wall runs on to it, one 0.7 m short does not,
## and every landing is listed as drawn (Ctx.landings, which the street generators read).
## The family cases run its own build steps (_build_all) on a 20 x 10 m footprint, so
## expected refusals are read from its error list. Behaviour only.

const KIT := preload("res://game/scripts/world/facades/wall_equipment_kit.gd")
const MIDRISE := preload("res://game/scripts/world/facades/midrise_family.gd")
const SOURCE := "w0"
const GRID_SOURCE := {"kind": "rectified_photo", "ref": "test-photo", "date": "2025-09", "side": "s"}
const CLUSTER := {"s": [0.2, 6.0], "y": [9.0, 12.0], "mounts": 8, "cabinets": 3, "standoff": 0.45, "seed": 369}
const DUCT := {"s": [2.75, 3.3], "y": [12.0, 16.5], "depth": 0.3, "lift": 0.35, "over": 1.2, "land": 14.5, "conduits": 2, "strap_every": 1.5}
## The grid face (edge 0, stations along x): a 1 m opening and a 4 m one, on storey 1.
const NARROW := [2.0, 3.0]
const WIDE := [8.0, 12.0]
## Door kinds on edge 0 (stations along x, outside towards -z), each in its own bay: a
## unit door, a lobby, a porch, a unit door wider than its landing and a garage. On
## flat land at y 0 every landing stands at 0.1 m and the garage's sill at 0.04 m; on
## land rising RISE_M into the building across the recess (z 0 to RECESS_RISE_Z_M),
## both stand RISE_M higher.
const RISE_M := 0.2
const RECESS_RISE_Z_M := 0.3
const DOORS := [
	{"type": "entry", "from": 0.5, "to": 3.5, "door": {"kind": "unit", "w": 1.0, "h": 2.2}, "landing": {"w": 1.8, "depth": 1.2}},
	{"type": "entry", "from": 4.0, "to": 8.0, "door": {"kind": "lobby", "w": 2.4, "h": 2.6}, "landing": {"w": 3.4, "depth": 2.0}},
	{"type": "entry", "from": 8.5, "to": 12.5, "door": {"kind": "porch", "w": 2.4, "h": 2.6, "recess": 1.5, "door_w": 1.6}, "landing": {"w": 3.0, "depth": 1.2}},
	{"type": "entry", "from": 13.0, "to": 15.5, "door": {"kind": "unit", "w": 1.6, "h": 2.2}, "landing": {"w": 1.2, "depth": 1.0}},
	{"type": "garage", "from": 16.0, "to": 19.5, "w": 2.6, "h": 2.4},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var failures := run_checks()
	for failure: String in failures:
		print("FAIL: mid-rise wall detail: ", failure)
	if failures.is_empty():
		print("PASS: mid-rise wall detail: the equipment kit lays out the same boxes for a spec and others for another seed, refuses bad specs and keeps its boxes ordered, inside their stations, the signs at the foot and the duct's rounded bend held clear of its wall's top; the family refuses equipment off its edge or with an unknown role, and a duct off its wall's top or off the roof; an outward eave closes both ends; a hood's min_w skips the narrow opening; grid blinds follow their seed and drops; every door kind and a garage is paved from its landing to the door on flat and rising land, its landing and recess floor meeting edge to edge; a doorstep runs on to a side wall 0.3 m off and not to one 0.7 m off; every landing is listed as drawn")
	quit(0 if failures.is_empty() else 1)


static func run_checks() -> Array:
	var failures := []
	_check_kit(failures)
	_check_kit_refusals(failures)
	_check_equipment_parts(failures)
	_check_outward_eave(failures)
	_check_hood_min_w(failures)
	_check_blinds(failures)
	_check_door_floors(failures, 0.0)
	_check_door_floors(failures, RISE_M)
	_check_side_wall(failures)
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
	var bend := {}
	var top := float(DUCT.y[1])
	for box: Dictionary in duct.boxes:
		if str(box.role) == "duct" and shaft.is_empty():
			shaft = box
		elif str(box.role) == "hood":
			bend = box
	_expect(failures, not shaft.is_empty() and not bend.is_empty() and bend.has("profile"), "the duct has a shaft and a bend profile")
	if shaft.is_empty() or not bend.has("profile"):
		return
	_expect(failures, float(shaft.y1) > top, "the duct's shaft rises past the wall's top")
	_expect(failures, float(bend.u0) == float(shaft.u0) and float(bend.u1) == float(shaft.u1) and float(bend.d1) == float(shaft.d1) and float(bend.d0) == -float(DUCT.over) and float(bend.y0) == float(DUCT.land), "the bend continues the shaft and drops over its distance behind the wall to land")
	for box: Dictionary in duct.boxes:
		_expect(failures, float(box.y1) <= float(bend.y1), "nothing of the duct rises above its bend (%s)" % box.role)
	var outline := PackedVector2Array()
	for p: Array in bend.profile:
		outline.append(Vector2(float(p[0]), float(p[1])))
	var run_d := -float(DUCT.over) * 0.5
	var lift := float(DUCT.lift)
	var section := float(DUCT.depth) - 0.02
	_expect(failures, Geometry2D.is_point_in_polygon(Vector2(run_d, top + lift + section * 0.5), outline) and not Geometry2D.is_point_in_polygon(Vector2(run_d, top + lift * 0.5), outline), "the bend's run is held lift clear of the wall's top, with a gap under it")
	_expect(failures, Geometry2D.is_point_in_polygon(Vector2(float(DUCT.depth) - 0.01, float(shaft.y1) + 0.01), outline) and not Geometry2D.is_point_in_polygon(Vector2(float(DUCT.depth) - 0.01, float(bend.y1) - 0.01), outline), "the bend's outer corner is rounded")
	_expect(failures, Geometry2D.is_point_in_polygon(Vector2(-float(DUCT.over) + section * 0.5, float(DUCT.land) + 0.01), outline), "the bend drops down to land")
	_expect(failures, not Geometry2D.triangulate_polygon(outline).is_empty(), "the bend's profile is a simple polygon")


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
		[{"lift": 0.05}, "a low lift"], [{"lift": 1.5}, "a high lift"], [{"over": 0.4}, "a drop inside its own bend"],
		[{"over": 6.0}, "a long run over"], [{"land": 17.0}, "a landing above its top"],
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
	# The block's wall top is 6 m above its floor (two 3 m storeys, no parapet).
	var duct := _with(DUCT, {"kind": "duct", "edge": 1, "s": [4.0, 4.5], "y": [1.0, 6.0]})
	_expect(failures, _errors(_config({"parts": [cluster, duct]})).is_empty(), "equipment on its 10 m edge builds")
	var below_top := _errors(_config({"parts": [_with(duct, {"y": [1.0, 5.5]})]}))
	_expect(failures, below_top.size() == 1 and str(below_top[0]).contains("wall's top"), "a duct that ends below its wall's top fails the build: %s" % [below_top])
	# A block 2 m deep along edge 0 and one behind it: a drop 3 m back lands on the other.
	var split := {"blocks": [
		{"id": "front", "storeys": 2, "ground_h": 3.0, "clip": [{"edge": 0, "max": 2.0}], "parapet": {"h": 0.0}, "faces": {"default": "wall"}},
		{"id": "back", "storeys": 2, "ground_h": 3.0, "clip": [{"edge": 0, "min": 2.0}], "parapet": {"h": 0.0}, "faces": {"default": "wall"}},
	]}
	var on_edge0 := _with(duct, {"edge": 0, "s": [8.0, 8.5]})
	_expect(failures, _errors(_config(split.merged({"parts": [on_edge0]}))).is_empty(), "a duct whose drop lands on its own block's roof builds")
	var past := _errors(_config(split.merged({"parts": [_with(on_edge0, {"over": 3.0})]})))
	_expect(failures, past.size() == 1 and str(past[0]).contains("must land on block front"), "a duct whose drop passes its block's roof fails the build: %s" % [past])
	var in_parapet := _errors(_config({"parts": [_with(duct, {"over": 0.55})]}))
	_expect(failures, in_parapet.size() == 1 and str(in_parapet[0]).contains("inside its parapet"), "a duct whose drop falls inside the parapet fails the build: %s" % [in_parapet])
	var off := _errors(_config({"parts": [_with(cluster, {"s": [0.5, 10.5]})]}))
	_expect(failures, off.size() == 1 and str(off[0]).contains("off the edge"), "a cluster past its edge's end fails the build: %s" % [off])
	var run_off := _errors(_config({"parts": [_with(duct, {"s": [9.4, 9.95]})]}))
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


## Straight down from just over the sill, anywhere in each door's recess and on its
## landing in front of the door, the first surface met is the paving at the sill's
## height, never the land under the building, on flat land and on land rising `rise`
## into the building across the recess. Where the landing meets the recess floor
## along the wall's line, both have their vertices at the same stations, so no
## T-junction can crack open between them; and the family lists each landing as drawn,
## naming its block.
static func _check_door_floors(failures: Array, rise: float) -> void:
	var cfg := _config({})
	cfg.schemes["doors"] = {"material": "render", "module": 60.0, "ground": {"kind": "blank"}, "upper": "blank", "features": DOORS.duplicate(true)}
	cfg.blocks[0].faces["e0"] = "doors"
	var ctx := _build(cfg, rise)
	var land := "flat land" if rise == 0.0 else "land rising %.1f m" % rise
	if not ctx.errors.is_empty():
		failures.append("the door kinds build on %s: %s" % [land, ctx.errors])
		return
	var tris := _surfaces(ctx, rise)
	for feature: Dictionary in DOORS:
		var garage := str(feature.type) == "garage"
		var door: Dictionary = feature.get("door", {})
		var kind := "garage" if garage else str(door.kind)
		var w := float(feature.w) if garage else float(door.w)
		var c := (float(feature.from) + float(feature.to)) * 0.5
		var s0 := c - w * 0.5
		var s1 := c + w * 0.5
		var depth := float(door.get("recess", 0.3))
		var sill := rise + (0.04 if garage else 0.1)
		var landing: Dictionary = feature.get("landing", {})
		var l0 := maxf(s0, c - float(landing.get("w", 0.0)) * 0.5)
		var l1 := minf(s1, c + float(landing.get("w", 0.0)) * 0.5)
		# [s0, s1, z0, z1]: the recess, and the landing in front of the door.
		var zones := [[s0, s1, 0.0, depth]]
		if not garage:
			zones.append([l0, l1, -float(landing.depth), 0.0])
		var misses := _misses(tris, zones, sill)
		_expect(failures, misses.is_empty(), "a %s on %s is paved from its landing to the door at %.2f m (%d of %d points are not: %s)" % [kind, land, sill, misses.size(), zones.size() * 35, misses.slice(0, 3)])
		if garage:
			continue
		var outside := _seam_stations(tris, l0, l1, sill, -1.0)
		var inside := _seam_stations(tris, l0, l1, sill, 1.0)
		_expect(failures, not outside.is_empty() and outside == inside, "a %s's landing and recess floor on %s meet edge to edge along the wall (landing %s, recess floor %s)" % [kind, land, outside, inside])
		var drawn := [c - float(landing.w) * 0.5, c + float(landing.w) * 0.5, -float(landing.depth), 0.0]
		var listed := _listed(ctx, c, 0.0)
		_expect(failures, not listed.is_empty() and absf(float(listed.top_y_m) - sill) < 0.001 and _extent_is(listed, drawn), "a %s's landing on %s is listed as drawn at %.2f m over %s: %s" % [kind, land, sill, drawn, listed])
		# A face key repeats on every block of a row, so a listed landing names its block.
		_expect(failures, str(listed.get("block", "")) == "main", "a %s's listed landing on %s names its block: %s" % [kind, land, listed])


## A doorstep 0.3 m short of a side wall (the wing at x 4, an inside corner) runs on to
## it: its paving reaches the wall at the sill's height and its listed top does too. One
## 0.7 m short of a wall (the east block at x 16) keeps its own width.
static func _check_side_wall(failures: Array) -> void:
	var cfg := _config({"blocks": [
		{"id": "wing", "storeys": 2, "ground_h": 3.0, "clip": [{"edge": 0, "s_max": 4.0}], "parapet": {"h": 0.0}, "faces": {"e0": "steps", "default": "wall"}},
		{"id": "main", "storeys": 2, "ground_h": 3.0, "clip": [{"edge": 0, "s_min": 4.0, "s_max": 16.0, "min": 2.0}], "parapet": {"h": 0.0}, "faces": {"e0": "steps", "default": "wall"}},
		{"id": "east", "storeys": 2, "ground_h": 3.0, "clip": [{"edge": 0, "s_min": 16.0}], "parapet": {"h": 0.0}, "faces": {"e0": "steps", "default": "wall"}},
	]})
	cfg.schemes["steps"] = {"material": "render", "module": 60.0, "ground": {"kind": "blank"}, "upper": "blank", "features": [
		{"type": "entry", "from": 4.0, "to": 6.4, "door": {"kind": "unit", "w": 1.0, "h": 2.2}, "landing": {"w": 1.8, "depth": 1.2}},
		{"type": "entry", "from": 13.4, "to": 15.4, "door": {"kind": "unit", "w": 1.0, "h": 2.2}, "landing": {"w": 1.8, "depth": 1.2}},
	]}
	var ctx := _build(cfg)
	if not ctx.errors.is_empty():
		failures.append("the side-wall doorsteps build: %s" % [ctx.errors])
		return
	var tris := _surfaces(ctx, 0.0)
	# The main block's face stands 2 m back (z 2); its landings run out to z 0.8.
	var gap := _misses(tris, [[4.02, 4.28, 0.85, 1.95]], 0.1)
	var near := _listed(ctx, 5.2, 2.0)
	_expect(failures, gap.is_empty() and not near.is_empty() and _extent_is(near, [4.0, 6.1, 0.8, 2.0]), "a doorstep 0.3 m short of a side wall runs on to it (%d points of its gap unpaved: %s; listed %s)" % [gap.size(), gap.slice(0, 3), near])
	var open := _misses(tris, [[15.35, 15.95, 0.85, 1.95]], 0.1)
	var far := _listed(ctx, 14.4, 2.0)
	_expect(failures, open.size() == 35 and not far.is_empty() and _extent_is(far, [13.5, 15.3, 0.8, 2.0]), "a doorstep 0.7 m short of a side wall keeps its width (%d of 35 points of its gap paved at the sill; listed %s)" % [35 - open.size(), far])


## Every surface the build drew, with its bucket key, and the land under it (_records).
static func _surfaces(ctx: MIDRISE.Ctx, rise: float) -> Array:
	var tris: Array = []
	for key: String in ctx.buckets:
		var bucket: MIDRISE.Bucket = ctx.buckets[key]
		for i in range(0, bucket.vertices.size(), 3):
			tris.append([bucket.vertices[i], bucket.vertices[i + 1], bucket.vertices[i + 2], key])
	var land: Dictionary = _records(rise).chunks[0].records[0]
	for i in range(0, (land.indices as Array).size(), 3):
		var corners: Array = []
		for k in 3:
			var at := int(land.indices[i + k]) * 3
			corners.append(Vector3(float(land.vertices[at]), float(land.vertices[at + 1]), float(land.vertices[at + 2])))
		tris.append([corners[0], corners[1], corners[2], "land"])
	return tris


## The points of each [x0, x1, z0, z1] zone (7 by 5, inset a little) whose first surface
## straight down from 0.25 m over the sill is not paving at the sill's height.
static func _misses(tris: Array, zones: Array, sill: float) -> Array:
	var misses := []
	for zone: Array in zones:
		for i in 7:
			for j in 5:
				var x := lerpf(float(zone[0]) + 0.02, float(zone[1]) - 0.02, float(i) / 6.0)
				var z := lerpf(float(zone[2]) + 0.005, float(zone[3]) - 0.005, float(j) / 4.0)
				var hit := _first_hit(tris, Vector3(x, sill + 0.25, z))
				if hit.is_empty() or not str(hit.key).begins_with("ground|paving") or absf(float(hit.y) - sill) > 0.001:
					misses.append("(%.2f, %.3f) meets %s" % [x, z, "nothing" if hit.is_empty() else "%s at %.3f" % [hit.key, float(hit.y)]])
	return misses


## The family's listed landing (not a ramp) whose top spans x 0.5 m in front of the
## wall line z, or {}: the door at x on edge 0's side.
static func _listed(ctx: MIDRISE.Ctx, x: float, wall_z: float) -> Dictionary:
	var probe := Vector2(x, wall_z - 0.5)
	for landing: Dictionary in ctx.landings:
		var ring := PackedVector2Array()
		for corner: Array in landing.top_xz:
			ring.append(Vector2(float(corner[0]), float(corner[1])))
		if str(landing.kind) != "ramp" and Geometry2D.is_point_in_polygon(probe, ring):
			return landing
	return {}


## Whether a listed landing's top spans [x0, x1, z0, z1] (to 1 mm).
static func _extent_is(landing: Dictionary, extent: Array) -> bool:
	var lo := Vector2(INF, INF)
	var hi := Vector2(-INF, -INF)
	for corner: Array in landing.top_xz:
		lo = lo.min(Vector2(float(corner[0]), float(corner[1])))
		hi = hi.max(Vector2(float(corner[0]), float(corner[1])))
	return absf(lo.x - float(extent[0])) < 0.001 and absf(hi.x - float(extent[1])) < 0.001 and absf(lo.y - float(extent[2])) < 0.001 and absf(hi.y - float(extent[3])) < 0.001


## The highest surface straight under `from`: {key, y}, or {} when there is none.
static func _first_hit(tris: Array, from: Vector3) -> Dictionary:
	var best := {}
	for tri: Array in tris:
		var at: Variant = Geometry3D.ray_intersects_triangle(from, Vector3.DOWN, tri[0], tri[1], tri[2])
		if at is Vector3 and (best.is_empty() or (at as Vector3).y > float(best.y)):
			best = {"key": tri[3], "y": (at as Vector3).y}
	return best


## Stations (x, to 0.1 mm) of the paving's vertices at the sill's height on the wall's
## line (z 0) from s0 to s1, from its triangles on one side of that line (-1 outside).
static func _seam_stations(tris: Array, s0: float, s1: float, sill: float, side: float) -> Array:
	var stations := {}
	for tri: Array in tris:
		var a: Vector3 = tri[0]
		var b: Vector3 = tri[1]
		var c: Vector3 = tri[2]
		if not str(tri[3]).begins_with("ground|paving") or (a.z + b.z + c.z) * side <= 0.0:
			continue
		for p: Vector3 in [a, b, c]:
			if absf(p.z) < 0.0001 and absf(p.y - sill) < 0.0001 and p.x > s0 - 0.0001 and p.x < s1 + 0.0001:
				stations[snappedf(p.x, 0.0001)] = true
	var out := stations.keys()
	out.sort()
	return out


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


## The producer's build steps for a config on the hand-built footprint and land
## (rising `rise` into the building across the recess, _records).
static func _build(cfg: Dictionary, rise := 0.0) -> MIDRISE.Ctx:
	var records := _records(rise)
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
## record and one chunk of land under it: flat at y 0, or with `rise` it rises from 0
## at edge 0 (z 0) to `rise` at z RECESS_RISE_Z_M and stays there.
static func _records(rise := 0.0) -> Dictionary:
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
	var land_vertices: Array = []
	for row: Array in [[-50.0, 0.0], [0.0, 0.0], [RECESS_RISE_Z_M, rise], [60.0, rise]]:
		land_vertices.append_array([-50.0, float(row[1]), float(row[0]), 70.0, float(row[1]), float(row[0])])
	var land_indices: Array = []
	for strip in 3:
		var k := strip * 2
		land_indices.append_array([k, k + 1, k + 3, k, k + 3, k + 2])
	var land := {"feature_kind": "land_ground", "vertices": land_vertices, "indices": land_indices}
	return {
		"wall": {"source_keys": [SOURCE], "vertices": vertices, "normals": normals},
		"roof": {"source_keys": [SOURCE]},
		"chunks": [{"records": [land]}],
	}
