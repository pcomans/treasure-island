extends RefCounted
## Opt-in unit details for the shared housing kit (housing_site_family): blinds and
## curtains behind the window glass, utility kits beside the doors (air-conditioner
## condensers, utility cabinets, slatted bin enclosures and wheelie bins), downspouts
## with their elbows, straps and kick-outs, and roof vent stacks. The kit calls these
## only for config keys that are present, so configs without them build exactly as
## before. Sizes, counts and stations are instance-config production inference from
## dated photos of the photographed sides, not survey.
##
## Roles (housing_family_live_attachment): blinds and the utilities' drawn parts are
## visual only ("solid" role, visual_only), so the player collides with one plain box
## per utility (a hidden "solid" collision_only part) and nothing in a window. The
## downspouts and roof vents take the support role and collide as drawn; being
## support, they are also what a retained-ground family's support proof compares.

const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const KIT = preload("res://game/scripts/world/facades/housing_garage_court.gd")

## The panes of PARTS._recessed_window: their front face stands this far behind the
## window's wall plane, and a blind hangs this far in front of that face.
const PANE_FRONT_M := 0.185
const BLIND_GAP_M := 0.005
## A door's outer trim edge from its centre (PARTS._entry: trim at 0.53, 0.085 wide).
const DOOR_TRIM_HALF_M := 0.5725
## A door's landing kept clear of utilities: this far beyond its trim each side, and
## this deep from the wall.
const LANDING_SIDE_M := 0.25
const LANDING_DEPTH_M := 1.3
const FORMS := ["condenser", "cabinet", "enclosure", "bin"]


static func _number(value: Variant) -> bool:
	return (value is float or value is int) and is_finite(float(value))


static func _rgb(value: Variant) -> bool:
	if not value is Array or (value as Array).size() != 3:
		return false
	for channel: Variant in value:
		if not _number(channel) or float(channel) < 0.0 or float(channel) > 1.0:
			return false
	return true


static func _color(cfg: Dictionary, key: String, fallback: Color) -> Color:
	var a: Variant = cfg.get(key, [])
	return Color(float(a[0]), float(a[1]), float(a[2])) if _rgb(a) else fallback


static func _invalid(root: Node3D, message: String) -> void:
	root.set_meta("build_valid", false)
	push_error("%s: %s" % [message, root.get_meta("source_key", "")])


## A stable pick in [0, size) from a seed and a few numbers (centimetre-rounded).
static func _pick(seed: int, values: Array, size: int) -> int:
	var h := seed * 73856093
	for value: Variant in values:
		h = h ^ (roundi(float(value) * 100.0) * 19349663)
		h = (h * 83492791) & 0x7fffffff
	return posmod(h, maxi(size, 1))


# ------------------------------------------------------------------ blinds

## Checks window_blinds once; an invalid spec fails the build.
static func blinds_valid(root: Node3D, spec: Dictionary) -> bool:
	var drops: Variant = spec.get("drops", [])
	var ok: bool = _rgb(spec.get("rgb")) and drops is Array and not (drops as Array).is_empty() and _number(spec.get("seed", 0))
	if ok:
		for drop: Variant in drops:
			ok = ok and _number(drop) and float(drop) >= 0.0 and float(drop) <= 1.0
		for key: String in ["rail_rgb", "curtain_rgb"]:
			ok = ok and (not spec.has(key) or _rgb(spec[key]))
		var widths: Variant = spec.get("curtain_widths", [0.35])
		ok = ok and widths is Array and not (widths as Array).is_empty()
		for width: Variant in widths:
			ok = ok and _number(width) and float(width) > 0.0 and float(width) <= 0.5
		ok = ok and _number(spec.get("curtain_share", 0.0)) and float(spec.get("curtain_share", 0.0)) >= 0.0 and float(spec.get("curtain_share", 0.0)) <= 1.0
		for key: String in ["roughness", "metallic"]:
			ok = ok and _number(spec.get(key, 0.5)) and float(spec.get(key, 0.5)) >= 0.0 and float(spec.get(key, 0.5)) <= 1.0
	if not ok:
		_invalid(root, "Invalid window_blinds (rgb, drops 0-1, seed, rail_rgb, curtain_rgb, curtain_widths 0-0.5, curtain_share, roughness and metallic 0-1)")
	return ok


## Buckets for one building's blinds: blind, rail and curtain faces.
static func blind_buckets() -> Dictionary:
	return {"blind": KIT._bucket(), "rail": KIT._bucket(), "curtain": KIT._bucket()}


## The blinds or curtains of one window built by PARTS._recessed_window at point
## (the window centre on its wall plane), w x h. Each of its two panes takes a
## drop from `drops` (the share of the pane covered from its head down; 0: none),
## or, for a `curtain_share` of windows, both panes take a curtain at their outer
## jambs, `curtain_widths` of the pane wide. Picks follow `seed` and the window's
## place, so a config always draws the same blinds.
static func window_blinds(buckets: Dictionary, spec: Dictionary, point: Vector3, t: Vector3, n: Vector3, w: float, h: float) -> void:
	var seed := int(spec.get("seed", 0))
	var drops: Array = spec.drops
	var face := -n * (PANE_FRONT_M - BLIND_GAP_M)
	var pane_w := w * 0.5 - 0.045
	var pane_h := h - 0.07
	var top := h * 0.5 - 0.035
	var curtains := float(_pick(seed, [point.x, point.z, point.y, 7.0], 1000)) / 1000.0 < float(spec.get("curtain_share", 0.0))
	var shared := _pick(seed, [point.x, point.z, point.y, 3.0], 2) == 0
	var first_drop := float(drops[_pick(seed, [point.x, point.z, point.y, -1.0], drops.size())])
	var widths: Array = spec.get("curtain_widths", [0.35])
	for side: float in [-1.0, 1.0]:
		var center := point + t * side * w * 0.25 + face
		if curtains:
			var share := float(widths[_pick(seed, [point.x, point.z, point.y, side * 5.0], widths.size())])
			var cw := pane_w * share
			# Hung at the pane's outer jamb, full height.
			var c := center + t * side * (pane_w * 0.5 - cw * 0.5)
			_face(buckets.curtain, c, t, n, cw, pane_h)
			continue
		var drop := first_drop if shared else float(drops[_pick(seed, [point.x, point.z, point.y, side], drops.size())])
		if drop <= 0.0:
			continue
		var bh := pane_h * drop
		_face(buckets.blind, center + Vector3.UP * (top - bh * 0.5), t, n, pane_w, bh)
		# The bottom rail, a hair in front of the blind.
		_face(buckets.rail, center + Vector3.UP * (top - bh + 0.012) + n * 0.002, t, n, pane_w, 0.024)


## Commits a building's blinds as visual-only meshes in their own materials.
static func commit_blinds(root: Node3D, buckets: Dictionary, spec: Dictionary) -> void:
	var receive := bool(spec.get("receive_shadows", true))
	var colors := {
		"blind": _color(spec, "rgb", Color(0.86, 0.85, 0.82)),
		"rail": _color(spec, "rail_rgb", Color(0.7, 0.69, 0.66)),
		"curtain": _color(spec, "curtain_rgb", Color(0.82, 0.79, 0.73)),
	}
	for key: String in ["blind", "rail", "curtain"]:
		# As glossy as the panes (PARTS._recessed_window), so the glass's sheen lies over it.
		var material := PARTS._material(colors[key], float(spec.get("roughness", 0.7)))
		material.metallic = float(spec.get("metallic", 0.0))
		# Opt-out: behind the glass, out of the reveal's hard shadow (as Dorm 369's blinds).
		material.disable_receive_shadows = not receive
		var node := KIT._commit(root, buckets[key], material, "WindowBlinds_" + key)
		if node != null:
			_visual(node)
			node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## A quad facing +n, w along t and h up, centred at c.
static func _face(bucket: Dictionary, c: Vector3, t: Vector3, n: Vector3, w: float, h: float) -> void:
	var x := t * w * 0.5
	var y := Vector3.UP * h * 0.5
	KIT._quad(bucket, c - x - y, c + x - y, c + x + y, c - x + y, n)


static func _visual(node: MeshInstance3D) -> void:
	node.set_meta("family_role", "solid")
	node.set_meta("visual_only", true)


# ------------------------------------------------------------------ utilities

## Checks utility_kit once: every item names a known form, a positive size and a colour.
static func kit_valid(root: Node3D, kit: Dictionary) -> bool:
	var items: Variant = kit.get("items", {})
	var ok: bool = items is Dictionary and not (items as Dictionary).is_empty()
	for key: String in ["door_clear_m", "gap_m", "wall_gap_m", "roughness"]:
		ok = ok and (not kit.has(key) or (_number(kit[key]) and float(kit[key]) >= 0.0 and float(kit[key]) <= 1.0))
	if ok:
		for item: Variant in (items as Dictionary).values():
			ok = ok and item is Dictionary and str(item.get("form", "")) in FORMS and _rgb(item.get("rgb"))
			var size: Variant = item.get("size_m", []) if item is Dictionary else []
			ok = ok and size is Array and (size as Array).size() == 3
			if ok:
				for value: Variant in size:
					ok = ok and _number(value) and float(value) > 0.05 and float(value) <= 2.5
	if not ok:
		_invalid(root, "Invalid utility_kit (items with form %s, size_m [w, h, d] and rgb; door_clear_m, gap_m, wall_gap_m 0-1 m, roughness 0-1)" % [FORMS])
	return ok


## Context collecting one building's utilities: buckets by material key, the
## collision boxes, and every footprint and door landing for the final check.
static func utility_context(kit: Dictionary) -> Dictionary:
	return {"buckets": {}, "colors": {}, "roughness": float(kit.get("roughness", 0.7)), "collision": KIT._bucket(), "footprints": [], "landings": []}


## A door landing (world XZ quad) that no utility may stand on.
static func add_landing(ctx: Dictionary, point: Vector3, t: Vector3, n: Vector3) -> void:
	var half := DOOR_TRIM_HALF_M + LANDING_SIDE_M
	var p := Vector2(point.x, point.z)
	var tt := Vector2(t.x, t.z)
	var nn := Vector2(n.x, n.z)
	(ctx.landings as Array).append(PackedVector2Array([p - tt * half, p + tt * half, p + tt * half + nn * LANDING_DEPTH_M, p - tt * half + nn * LANDING_DEPTH_M]))


## The utility kit of one entry: `utilities` {"side": 1 or -1, "items": [kit keys],
## "ground_y": y} stands its items in a row along the wall from the door's trim
## (beyond any screen of the frame on the same basis within reach on that side),
## `wall_gap_m` off the wall, on the visible ground at ground_y (default: the entry's
## threshold ground, bottom_y); a unit's pad and every collision box sink below it.
static func entry_utilities(root: Node3D, ctx: Dictionary, kit: Dictionary, motif: Dictionary, frame: Dictionary, door: Vector3, t: Vector3, n: Vector3, station: float, bottom: float) -> void:
	var spec: Variant = motif.get("utilities")
	var items: Dictionary = kit.get("items", {})
	if not spec is Dictionary or not _number(spec.get("side")) or absf(float(spec.side)) != 1.0 or not spec.get("items") is Array or (spec.items as Array).is_empty() or not _number(spec.get("ground_y", bottom)):
		_invalid(root, "Invalid entry utilities (side 1 or -1, items, ground_y) in frame %s" % [frame.get("id", "")])
		return
	var side := float(spec.side)
	var seat := float(spec.get("ground_y", bottom))
	var cursor := DOOR_TRIM_HALF_M + float(kit.get("door_clear_m", 0.35))
	# Start beyond a screen of the frame that stands on this side within reach.
	for screen: Dictionary in frame.get("screens", []):
		if screen.get("basis", frame) != motif.get("basis", frame):
			continue
		var along := (float(screen.get("local_station_m", screen.get("station_m", 0.0))) - station) * side
		if along > 0.0 and along < cursor + 0.6:
			cursor = maxf(cursor, along + 0.12)
	var gap := float(kit.get("gap_m", 0.12))
	var wall_gap := float(kit.get("wall_gap_m", 0.06))
	var base := Vector3(door.x, seat, door.z)
	for key: Variant in spec.items:
		if not items.has(str(key)):
			_invalid(root, "Unknown utility %s in frame %s" % [key, frame.get("id", "")])
			return
		var item: Dictionary = items[str(key)]
		var size: Array = item.size_m
		var w := float(size[0])
		var h := float(size[1])
		var d := float(size[2])
		var center := base + t * side * (cursor + w * 0.5) + n * (wall_gap + d * 0.5)
		_utility(ctx, str(key), item, center, t, n, w, h, d)
		# One plain collision box per item, from 0.1 m under its base to the top of a
		# padded unit (its 0.06 m pad and lid).
		KIT._box(ctx.collision, center + Vector3.UP * ((h - 0.04) * 0.5), t, n, Vector3(w, h + 0.16, d))
		var c := Vector2(center.x, center.z)
		var tt := Vector2(t.x, t.z) * w * 0.5
		var nn := Vector2(n.x, n.z) * d * 0.5
		(ctx.footprints as Array).append([str(key), frame.get("id", ""), PackedVector2Array([c - tt - nn, c + tt - nn, c + tt + nn, c - tt + nn])])
		cursor += w + gap


## Commits the utilities (visual only, one mesh per colour, plus their collision
## boxes) after checking that none stands in the building or on a door landing.
static func commit_utilities(root: Node3D, ctx: Dictionary, ring: PackedVector2Array) -> void:
	for entry: Array in ctx.footprints:
		var quad: PackedVector2Array = entry[2]
		for corner: Vector2 in quad:
			if Geometry2D.is_point_in_polygon(corner, ring):
				_invalid(root, "Utility %s in frame %s stands inside the building" % [entry[0], entry[1]])
				return
		for landing: PackedVector2Array in ctx.landings:
			if not Geometry2D.intersect_polygons(quad, landing).is_empty():
				_invalid(root, "Utility %s in frame %s stands on a door landing" % [entry[0], entry[1]])
				return
	for key: String in ctx.buckets:
		var spec: Array = ctx.colors[key]
		var node := KIT._commit(root, ctx.buckets[key], PARTS._material(spec[0], spec[1]), "Utility_" + key)
		if node != null:
			_visual(node)
	var walls := KIT._commit(root, ctx.collision, null, "UtilityCollision")
	if walls != null:
		walls.visible = false
		walls.set_meta("family_role", "solid")
		walls.set_meta("collision_only", true)


## The bucket for one colour, made on first use. Every utility part shares the kit's
## one roughness, so the bake's merge by colour folds them into one surface.
static func _bucket_for(ctx: Dictionary, color: Color) -> Dictionary:
	var key := color.to_html(false)
	if not ctx.buckets.has(key):
		ctx.buckets[key] = KIT._bucket()
		ctx.colors[key] = [color, float(ctx.roughness)]
	return ctx.buckets[key]


static func _utility(ctx: Dictionary, key: String, item: Dictionary, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	var body := _color(item, "rgb", Color.GRAY)
	match str(item.form):
		"condenser":
			_condenser(ctx, item, body, center, t, n, w, h, d)
		"cabinet":
			_cabinet(ctx, item, body, center, t, n, w, h, d)
		"enclosure":
			_enclosure(ctx, item, body, center, t, n, w, h, d)
		"bin":
			_bin(ctx, item, body, center, t, n, w, h, d)


## A concrete pad under a box unit, sunk 0.25 m so a dip in the ground never shows under it.
static func _pad(ctx: Dictionary, center: Vector3, t: Vector3, n: Vector3, w: float, d: float) -> void:
	var pad := _bucket_for(ctx, Color(0.6, 0.6, 0.57))
	KIT._box(pad, center + Vector3.UP * -0.095, t, n, Vector3(w + 0.1, 0.31, d + 0.1))


## An air-conditioner condenser on its pad: cabinet, louvred coil on the front and
## both ends, dark fan grille on top.
static func _condenser(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	_pad(ctx, center, t, n, w, d)
	var lift := 0.06
	var shell := _bucket_for(ctx, body)
	KIT._box(shell, center + Vector3.UP * (lift + h * 0.5), t, n, Vector3(w, h, d))
	var louvre := _bucket_for(ctx, _color(item, "louvre_rgb", body.darkened(0.35)))
	var y := lift + 0.12
	while y < lift + h - 0.1:
		KIT._box(louvre, center + Vector3.UP * y + n * (d * 0.5 + 0.004), t, n, Vector3(w - 0.12, 0.022, 0.01))
		for side: float in [-1.0, 1.0]:
			KIT._box(louvre, center + Vector3.UP * y + t * side * (w * 0.5 + 0.004), n, t, Vector3(d - 0.12, 0.022, 0.01))
		y += 0.075
	var grille := _bucket_for(ctx, _color(item, "grille_rgb", Color(0.16, 0.17, 0.18)))
	var g := minf(w, d) * 0.78
	KIT._box(grille, center + Vector3.UP * (lift + h + 0.006), t, n, Vector3(g, 0.012, g))


## A plain utility cabinet: box with a lid lip and a door seam.
static func _cabinet(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	_pad(ctx, center, t, n, w, d)
	var lift := 0.06
	KIT._box(_bucket_for(ctx, body), center + Vector3.UP * (lift + h * 0.5 - 0.02), t, n, Vector3(w, h - 0.04, d))
	var lid := _bucket_for(ctx, _color(item, "lid_rgb", body.lightened(0.1)))
	KIT._box(lid, center + Vector3.UP * (lift + h - 0.02), t, n, Vector3(w + 0.04, 0.04, d + 0.04))
	var seam := _bucket_for(ctx, body.darkened(0.45))
	KIT._box(seam, center + Vector3.UP * (lift + h * 0.48) + n * (d * 0.5 + 0.004), t, n, Vector3(0.018, h - 0.16, 0.01))
	KIT._box(seam, center + Vector3.UP * (lift + h * 0.55) + n * (d * 0.5 + 0.012) + t * 0.06, t, n, Vector3(0.025, 0.12, 0.02))


## A slatted bin enclosure open to the wall: a front fence of vertical slats on two
## rails between corner posts, and a slatted end on each side back to the wall.
static func _enclosure(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	var wood := _bucket_for(ctx, body)
	var frame := _bucket_for(ctx, _color(item, "frame_rgb", body.darkened(0.2)))
	var front := center + n * (d * 0.5 - 0.045)
	_slats(wood, frame, front, t, n, w, h, float(item.get("slat_m", 0.09)), float(item.get("slat_gap_m", 0.035)))
	for side: float in [-1.0, 1.0]:
		var end := center + t * side * (w * 0.5 - 0.045) - n * 0.045
		_slats(wood, frame, end, n, t * side, d - 0.09, h, float(item.get("slat_m", 0.09)), float(item.get("slat_gap_m", 0.035)))


## One slatted panel w wide along a (its face toward f), standing on base.
static func _slats(wood: Dictionary, frame: Dictionary, base: Vector3, a: Vector3, f: Vector3, w: float, h: float, slat: float, gap: float) -> void:
	for side: float in [-1.0, 1.0]:
		KIT._box(frame, base + a * side * (w * 0.5) + Vector3.UP * (h * 0.5 - 0.02), a, f, Vector3(0.09, h + 0.04, 0.09))
	for rail_y: float in [0.22, h - 0.18]:
		KIT._box(frame, base + Vector3.UP * rail_y - f * 0.03, a, f, Vector3(w, 0.07, 0.04))
	var count := maxi(2, int(floor((w - 0.09) / (slat + gap))))
	for i in count:
		var along := lerpf(-w * 0.5 + 0.045 + slat * 0.5 + gap, w * 0.5 - 0.045 - slat * 0.5 - gap, float(i) / float(maxi(count - 1, 1)))
		KIT._box(wood, base + a * along + Vector3.UP * (h * 0.5 + 0.01), a, f, Vector3(slat, h - 0.02, 0.022))


## A two-wheeled wheelie bin, its handle and wheels toward the wall: a body that
## narrows to its foot, an overhanging lid and two wheels on an axle.
static func _bin(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	var shell := _bucket_for(ctx, body)
	var foot := 0.86
	var hb := h - 0.06
	# The body as two stacked boxes, narrower below, reads as the bin's taper.
	KIT._box(shell, center + Vector3.UP * (hb * 0.3), t, n, Vector3(w * foot, hb * 0.6, d * foot))
	KIT._box(shell, center + Vector3.UP * (hb * 0.78), t, n, Vector3(w, hb * 0.44, d))
	var lid := _bucket_for(ctx, _color(item, "lid_rgb", body.darkened(0.12)))
	KIT._box(lid, center + Vector3.UP * (h - 0.035) + n * 0.015, t, n, Vector3(w + 0.03, 0.05, d + 0.04))
	var dark := _bucket_for(ctx, Color(0.12, 0.12, 0.12))
	KIT._box(dark, center + Vector3.UP * (h - 0.09) - n * (d * 0.5 + 0.025), t, n, Vector3(w * 0.8, 0.035, 0.045))
	for side: float in [-1.0, 1.0]:
		KIT._box(dark, center + Vector3.UP * 0.1 + t * side * (w * 0.5 - 0.02) - n * (d * 0.5 - 0.08), n, t, Vector3(0.2, 0.2, 0.06))


# ------------------------------------------------------------------ downspouts

## A downspout (a `pipes` entry with "style": "downspout") on a front wall: a 75 x
## 100 mm leader from the eave trim at top_y down to bottom_y. From the trim it bends
## back to the wall, steps out round the storey band (band_y) and runs on in front of
## it, and kicks out over a splash block at its foot. Straps hold it every 1.4 m.
## Support role, colliding as drawn, in the trim's material.
static func downspout(root: Node3D, at: Vector3, t: Vector3, n: Vector3, bottom: float, top: float, band_y: float, trim: Material, concrete: Material) -> void:
	# Heights below are absolute; the station point's own height plays no part.
	var p := Vector3(at.x, 0.0, at.z)
	var pipe := KIT._bucket()
	var straps := KIT._bucket()
	var splash := KIT._bucket()
	var inner := 0.03 + 0.05
	var outer := 0.21 + 0.06
	var head := top - 0.04
	var y_top := head - 0.32
	# The outlet under the eave trim's front, then the gooseneck back to the wall.
	_leg(pipe, p, t, n, 0.215, head, 0.215, head - 0.1)
	_leg(pipe, p, t, n, 0.215, head - 0.1, inner, y_top)
	var y := y_top
	var stepped := band_y > bottom + 0.6 and band_y < y_top - 0.3
	if stepped:
		_leg(pipe, p, t, n, inner, y, inner, band_y + 0.28)
		_leg(pipe, p, t, n, inner, band_y + 0.28, outer, band_y + 0.09)
		_straps(straps, p, t, n, inner, y_top - 0.4, band_y + 0.5)
		y = band_y + 0.09
	var depth := outer if stepped else inner
	_leg(pipe, p, t, n, depth, y, depth, bottom + 0.3)
	_leg(pipe, p, t, n, depth, bottom + 0.3, depth + 0.22, bottom + 0.1)
	_straps(straps, p, t, n, depth, y - 0.4, bottom + 0.6)
	KIT._box(splash, p + n * (depth + 0.38) + Vector3.UP * (bottom - 0.02), t, n, Vector3(0.3, 0.08, 0.55))
	for bucket: Dictionary in [pipe, straps]:
		var node := KIT._commit(root, bucket, trim, "Downspout")
		if node != null:
			node.set_meta("family_role", "support")
	var block := KIT._commit(root, splash, concrete, "DownspoutSplash")
	if block != null:
		block.set_meta("family_role", "support")


## Straps from the wall to a leader `depth` out, from y_high down to y_low every 1.4 m.
static func _straps(bucket: Dictionary, p: Vector3, t: Vector3, n: Vector3, depth: float, y_high: float, y_low: float) -> void:
	var y := y_high
	while y > y_low:
		KIT._box(bucket, p + n * (depth * 0.5 + 0.005) + Vector3.UP * y, t, n, Vector3(0.095, 0.03, depth + 0.06))
		y -= 1.4


## One straight run of leader between two points in the wall's (n, y) plane at p.
static func _leg(bucket: Dictionary, p: Vector3, t: Vector3, n: Vector3, d0: float, y0: float, d1: float, y1: float) -> void:
	var a := p + n * d0 + Vector3.UP * y0
	var b := p + n * d1 + Vector3.UP * y1
	var along := b - a
	var length := along.length()
	if length < 0.001:
		return
	var axis := along / length
	var side := t
	var face := axis.cross(side).normalized()
	# Each leg runs 0.05 into its neighbours so the bends close.
	KIT._obox(bucket, (a + b) * 0.5, axis, side, face, Vector3(length + 0.05, 0.075, 0.1))


# ------------------------------------------------------------------ roof vents

## Checks roof_vents once.
static func vents_valid(root: Node3D, spec: Dictionary) -> bool:
	var ridge: Variant = spec.get("ridge", [])
	var ok: bool = ridge is Array and (ridge as Array).size() == 2 and _number(spec.get("ridge_y")) and _number(spec.get("slope")) and float(spec.get("slope", 0.0)) >= 0.0 and float(spec.get("slope", 0.0)) < 1.5
	if ok:
		for end: Variant in ridge:
			ok = ok and end is Array and (end as Array).size() == 2 and _number(end[0]) and _number(end[1])
		for key: String in ["spacing_m", "jitter_m"]:
			ok = ok and _number(spec.get(key)) and float(spec[key]) >= 0.0 and float(spec[key]) < 20.0
		ok = ok and float(spec.get("spacing_m", 0.0)) >= 0.8 and _number(spec.get("seed", 0))
		var offset: Variant = spec.get("offset_m", [])
		ok = ok and offset is Array and (offset as Array).size() == 2 and _number(offset[0]) and _number(offset[1]) and float(offset[0]) >= 0.0 and float(offset[1]) >= float(offset[0])
		for item: Variant in spec.get("avoid", []):
			ok = ok and item is Array and (item as Array).size() == 2 and _number(item[0]) and _number(item[1])
	if not ok:
		_invalid(root, "Invalid roof_vents (ridge [[x,z],[x,z]], ridge_y, slope, spacing_m >= 0.8, jitter_m, offset_m [min,max], seed)")
	return ok


## Vent stacks and box vents along the ridge of a two-slope roof whose surface falls
## `slope` metres a metre from the ridge line at ridge_y: one every spacing_m (moved
## up to jitter_m along it), offset_m from the ridge, on the front (-ridge normal
## toward front_xz) slope or, for a back_share of them, the back; each inside the
## footprint ring by margin_m and clear of the `avoid` points (existing vents) by
## 0.6 m. Stacks are 8-sided pipes with a cap; box vents a low hood on a curb; all in
## the instance's trim, as the production roof's own vents are.
static func roof_vents(root: Node3D, spec: Dictionary, ring: PackedVector2Array, front_xz: Vector2, trim: Material) -> void:
	var a := Vector2(float(spec.ridge[0][0]), float(spec.ridge[0][1]))
	var b := Vector2(float(spec.ridge[1][0]), float(spec.ridge[1][1]))
	var along := (b - a).normalized()
	var across := Vector2(-along.y, along.x)
	if across.dot(front_xz - a) < 0.0:
		across = -across
	var length := a.distance_to(b)
	var seed := int(spec.get("seed", 0))
	var spacing := float(spec.spacing_m)
	var jitter := float(spec.jitter_m)
	var lo := float(spec.offset_m[0])
	var hi := float(spec.offset_m[1])
	var margin := float(spec.get("margin_m", 0.6))
	var back_share := float(spec.get("back_share", 0.0))
	var stack_share := float(spec.get("stack_share", 0.7))
	var ridge_y := float(spec.ridge_y)
	var slope := float(spec.slope)
	var avoid: Array[Vector2] = []
	for item: Array in spec.get("avoid", []):
		avoid.append(Vector2(float(item[0]), float(item[1])))
	var vents := KIT._bucket()
	var next := spacing * 0.5
	while next < length:
		var s := next
		next += spacing
		var at := s + (float(_pick(seed, [s, 1.0], 1000)) / 1000.0 - 0.5) * 2.0 * jitter
		var off := lerpf(lo, hi, float(_pick(seed, [s, 2.0], 1000)) / 1000.0)
		var sign := -1.0 if float(_pick(seed, [s, 3.0], 1000)) / 1000.0 < back_share else 1.0
		var xz := a + along * at + across * off * sign
		var clear := Geometry2D.is_point_in_polygon(xz, ring)
		for i in ring.size():
			clear = clear and Geometry2D.get_closest_point_to_segment(xz, ring[i], ring[(i + 1) % ring.size()]).distance_to(xz) >= margin
		for point: Vector2 in avoid:
			clear = clear and point.distance_to(xz) >= 0.6
		if not clear:
			continue
		var roof_y := ridge_y - off * slope
		var base := Vector3(xz.x, roof_y, xz.y)
		var t3 := Vector3(along.x, 0.0, along.y)
		var n3 := Vector3(across.x, 0.0, across.y)
		if float(_pick(seed, [s, 4.0], 1000)) / 1000.0 < stack_share:
			var r := 0.04 + 0.02 * float(_pick(seed, [s, 5.0], 3)) * 0.5
			var hgt := 0.28 + 0.06 * float(_pick(seed, [s, 6.0], 4))
			# From under the roof surface (its fall across the pipe) to the stack's top.
			var foot := roof_y - r * slope - 0.03
			_prism(vents, Vector3(xz.x, foot, xz.y), r, roof_y + hgt - foot)
			_prism(vents, Vector3(xz.x, roof_y + hgt, xz.y), r + 0.012, 0.025)
		else:
			var curb := 0.3
			KIT._box(vents, base + Vector3.UP * 0.02, t3, n3, Vector3(curb, 0.16 + curb * slope, curb))
			KIT._box(vents, base + Vector3.UP * 0.13, t3, n3, Vector3(curb + 0.08, 0.05, curb + 0.08))
	var node := KIT._commit(root, vents, trim, "RoofVents")
	if node != null:
		node.set_meta("family_role", "support")


## An 8-sided upright prism (radius r, height h) standing on foot, capped on top; its
## foot stands under the roof surface, so it needs no bottom.
static func _prism(bucket: Dictionary, foot: Vector3, r: float, h: float) -> void:
	var ring: Array[Vector3] = []
	for i in 8:
		var angle := TAU * (float(i) + 0.5) / 8.0
		ring.append(Vector3(cos(angle) * r, 0.0, sin(angle) * r))
	var up := Vector3.UP * h
	for i in 8:
		var p := foot + ring[i]
		var q := foot + ring[(i + 1) % 8]
		var out := (ring[i] + ring[(i + 1) % 8]).normalized()
		KIT._quad(bucket, p, q, q + up, p + up, out)
		KIT._tri(bucket, foot + up, p + up, q + up, Vector3.UP)
