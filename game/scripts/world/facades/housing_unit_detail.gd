extends RefCounted
## Opt-in unit details for the shared housing kit (housing_site_family): blinds and
## curtains behind the window glass, a glazed door sidelight, utility kits beside the
## doors (air-conditioner condensers, utility cabinets, slatted bin enclosures and
## wheelie bins), downspouts with their bends, straps and kick-outs, roof vent stacks
## and gable rakes carried out over the gable walls. The kit calls these only for
## config keys that are present, so configs without them build exactly as before.
## Sizes, counts and stations are instance-config production inference from dated
## photos of the photographed sides, not survey.
##
## Roles (housing_family_live_attachment): blinds and the utilities' drawn parts are
## visual only ("solid" role, visual_only), so the player collides with one plain box
## per utility (a hidden "solid" collision_only part) and nothing in a window. The
## downspouts, roof vents and gable rakes take the support role and collide as drawn;
## being support, they are also what a retained-ground family's support proof compares.

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


static func _rgb_list(value: Variant) -> bool:
	if not value is Array or (value as Array).is_empty():
		return false
	for rgb: Variant in value:
		if not _rgb(rgb):
			return false
	return true


static func _color(cfg: Dictionary, key: String, fallback: Color) -> Color:
	var a: Variant = cfg.get(key, [])
	return Color(float(a[0]), float(a[1]), float(a[2])) if _rgb(a) else fallback


static func _to_color(a: Array) -> Color:
	return Color(float(a[0]), float(a[1]), float(a[2]))


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


## A bucket for one colour in a context of colour buckets, made on first use.
static func _bucket_for(ctx: Dictionary, color: Color) -> Dictionary:
	var key := color.to_html(false)
	if not ctx.buckets.has(key):
		ctx.buckets[key] = KIT._bucket()
		ctx.colors[key] = color
	return ctx.buckets[key]


# ------------------------------------------------------------------ blinds

## Checks window_blinds once; an invalid spec fails the build.
static func blinds_valid(root: Node3D, spec: Dictionary) -> bool:
	var drops: Variant = spec.get("drops", [])
	var ok: bool = _rgb_list(spec.get("rgbs")) and drops is Array and not (drops as Array).is_empty() and _number(spec.get("seed", 0))
	if ok:
		for drop: Variant in drops:
			ok = ok and _number(drop) and float(drop) >= 0.0 and float(drop) <= 1.0
		ok = ok and (not spec.has("curtain_rgbs") or _rgb_list(spec.curtain_rgbs))
		var widths: Variant = spec.get("curtain_widths", [0.35])
		ok = ok and widths is Array and not (widths as Array).is_empty()
		for width: Variant in widths:
			ok = ok and _number(width) and float(width) > 0.0 and float(width) <= 1.0
		for key: String in ["curtain_share", "roughness", "metallic", "hem_shade", "pleat_shade"]:
			ok = ok and _number(spec.get(key, 0.5)) and float(spec.get(key, 0.5)) >= 0.0 and float(spec.get(key, 0.5)) <= 1.0
	if not ok:
		_invalid(root, "Invalid window_blinds (rgbs, drops 0-1, seed, curtain_rgbs, curtain_widths 0-1, curtain_share, roughness, metallic, hem_shade and pleat_shade 0-1)")
	return ok


## Colour buckets for one building's blinds and curtains.
static func blind_buckets() -> Dictionary:
	return {"buckets": {}, "colors": {}}


## The blinds or curtains of one window built by PARTS._recessed_window at point
## (the window centre on its wall plane), w x h. A window takes one colour from
## `rgbs`; each of its two panes takes a drop from `drops` (the share of the pane
## covered from its head down; 0: none), its hem shading off in two bands (hem_shade).
## For a `curtain_share` of windows both panes instead take a curtain from their
## outer jambs, `curtain_widths` of the pane wide, in a colour from `curtain_rgbs`,
## with two pleats (pleat_shade). Picks follow `seed` and the window's place, so a
## config always draws the same blinds.
static func window_blinds(ctx: Dictionary, spec: Dictionary, point: Vector3, t: Vector3, n: Vector3, w: float, h: float) -> void:
	var seed := int(spec.get("seed", 0))
	var drops: Array = spec.drops
	var face := -n * (PANE_FRONT_M - BLIND_GAP_M)
	var pane_w := w * 0.5 - 0.045
	var pane_h := h - 0.07
	var top := h * 0.5 - 0.035
	var place := [point.x, point.z, point.y]
	var curtains := float(_pick(seed, place + [7.0], 1000)) / 1000.0 < float(spec.get("curtain_share", 0.0))
	if curtains:
		var curtain_rgbs: Array = spec.get("curtain_rgbs", spec.rgbs)
		var cloth := _to_color(curtain_rgbs[_pick(seed, place + [11.0], curtain_rgbs.size())])
		var pleat := cloth * float(spec.get("pleat_shade", 0.86))
		var widths: Array = spec.get("curtain_widths", [0.35])
		for side: float in [-1.0, 1.0]:
			var cw := pane_w * float(widths[_pick(seed, place + [side * 5.0], widths.size())])
			# Hung from the pane's outer jamb, full height, two pleats down it.
			var c := point + t * side * (w * 0.25 + pane_w * 0.5 - cw * 0.5) + face
			_face(_bucket_for(ctx, cloth), c, t, n, cw, pane_h)
			for k: float in [-1.0 / 6.0, 1.0 / 6.0]:
				_face(_bucket_for(ctx, pleat), c + t * cw * k * 2.0 + n * 0.002, t, n, minf(0.03, cw * 0.2), pane_h)
		return
	var rgbs: Array = spec.rgbs
	var blind := _to_color(rgbs[_pick(seed, place + [13.0], rgbs.size())])
	var shade := float(spec.get("hem_shade", 0.78))
	var hems := [blind.lerp(blind * shade, 0.5), blind * shade]
	var shared := _pick(seed, place + [3.0], 2) == 0
	var first_drop := float(drops[_pick(seed, place + [-1.0], drops.size())])
	for side: float in [-1.0, 1.0]:
		var center := point + t * side * w * 0.25 + face
		var drop := first_drop if shared else float(drops[_pick(seed, place + [side], drops.size())])
		if drop <= 0.0:
			continue
		var bh := pane_h * drop
		var hem := minf(0.06, bh * 0.25)
		_face(_bucket_for(ctx, blind), center + Vector3.UP * (top - (bh - hem) * 0.5), t, n, pane_w, bh - hem)
		# A soft foot: two bands, each a shade darker, toward the glass below.
		for k in 2:
			_face(_bucket_for(ctx, hems[k]), center + Vector3.UP * (top - bh + hem * (0.75 - 0.5 * float(k))), t, n, pane_w, hem * 0.5)


## Commits a building's blinds and curtains as visual-only meshes, one per colour.
static func commit_blinds(root: Node3D, ctx: Dictionary, spec: Dictionary) -> void:
	var receive := bool(spec.get("receive_shadows", true))
	for key: String in ctx.buckets:
		# As glossy as the panes (PARTS._recessed_window), so the glass's sheen lies over it.
		var material := PARTS._material(ctx.colors[key], float(spec.get("roughness", 0.7)))
		material.metallic = float(spec.get("metallic", 0.0))
		# Opt-out: behind the glass, out of the reveal's hard shadow (as Dorm 369's blinds).
		material.disable_receive_shadows = not receive
		var node := KIT._commit(root, ctx.buckets[key], material, "WindowBlinds")
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


# ------------------------------------------------------------------ sidelight

## A full-height glazed sidelight (lower_windows "glazing": "sidelight") in its w x h
## opening centred at point: white stiles, rails and a kick plate round one light of
## glass over a dark back, in shallow reveals, with a casing on the wall face.
static func sidelight(root: Node3D, point: Vector3, t: Vector3, n: Vector3, w: float, h: float, trim: Material, dark: Material, glass: Material) -> void:
	var white := KIT._bucket()
	var pane := KIT._bucket()
	var back := KIT._bucket()
	for side: float in [-1.0, 1.0]:
		KIT._box(white, point + t * side * (w * 0.5 - 0.02) - n * 0.07, t, n, Vector3(0.04, h, 0.14))
		KIT._box(white, point + t * side * (w * 0.5 - 0.035) - n * 0.11, t, n, Vector3(0.05, h, 0.05))
		KIT._box(white, point + t * side * (w * 0.5 + 0.035) + n * 0.015, t, n, Vector3(0.07, h + 0.07, 0.03))
	KIT._box(white, point + Vector3.UP * (h * 0.5 - 0.025) - n * 0.11, t, n, Vector3(w, 0.05, 0.05))
	KIT._box(white, point + Vector3.UP * (-h * 0.5 + 0.09) - n * 0.11, t, n, Vector3(w, 0.18, 0.05))
	KIT._box(white, point + Vector3.UP * (-h * 0.5 + 0.92) - n * 0.11, t, n, Vector3(w, 0.04, 0.05))
	KIT._box(white, point + Vector3.UP * (h * 0.5 + 0.035) + n * 0.015, t, n, Vector3(w + 0.14, 0.07, 0.03))
	KIT._box(pane, point + Vector3.UP * 0.06 - n * 0.125, t, n, Vector3(w - 0.08, h - 0.22, 0.01))
	KIT._box(back, point - n * 0.16, t, n, Vector3(w, h, 0.02))
	KIT._commit(root, white, trim, "SidelightFrame")
	KIT._commit(root, pane, glass, "SidelightGlass")
	KIT._commit(root, back, dark, "SidelightBack")


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


## Context collecting one building's utilities: colour buckets (every part shares the
## kit's one roughness, so the bake's merge by colour folds them into one surface), the
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
## "ground_y": y, "start_m": m} stands its items in a row along the wall from the
## door's trim (from start_m from the door's centre when given, and beyond any screen
## of the frame on the same basis within reach on that side), `wall_gap_m` off the
## wall, on the visible ground at ground_y (default: the entry's threshold ground,
## bottom_y); a unit's pad and every collision box sink below it.
static func entry_utilities(root: Node3D, ctx: Dictionary, kit: Dictionary, motif: Dictionary, frame: Dictionary, door: Vector3, t: Vector3, n: Vector3, station: float, bottom: float) -> void:
	var spec: Variant = motif.get("utilities")
	var items: Dictionary = kit.get("items", {})
	if not spec is Dictionary or not _number(spec.get("side")) or absf(float(spec.side)) != 1.0 or not spec.get("items") is Array or (spec.items as Array).is_empty() or not _number(spec.get("ground_y", bottom)) or not _number(spec.get("start_m", 0.0)):
		_invalid(root, "Invalid entry utilities (side 1 or -1, items, ground_y, start_m) in frame %s" % [frame.get("id", "")])
		return
	var side := float(spec.side)
	var seat := float(spec.get("ground_y", bottom))
	var cursor := maxf(DOOR_TRIM_HALF_M + float(kit.get("door_clear_m", 0.35)), float(spec.get("start_m", 0.0)))
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
		_utility(ctx, item, center, t, n, w, h, d)
		# One plain collision box per item, from 0.1 m under its base to the top of a
		# padded unit (its 0.06 m pad and lid).
		KIT._box(ctx.collision, center + Vector3.UP * ((h - 0.04) * 0.5), t, n, Vector3(w, h + 0.16, d))
		var c := Vector2(center.x, center.z)
		var tt := Vector2(t.x, t.z) * w * 0.5
		var nn := Vector2(n.x, n.z) * d * 0.5
		(ctx.footprints as Array).append([str(key), frame.get("id", ""), PackedVector2Array([c - tt - nn, c + tt - nn, c + tt + nn, c - tt + nn])])
		cursor += w + gap


## Commits the utilities (visual only, one mesh per colour, plus their collision
## boxes) after checking that none stands inside `ring` (the building's lower walls)
## or on a door landing.
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
		var node := KIT._commit(root, ctx.buckets[key], PARTS._material(ctx.colors[key], float(ctx.roughness)), "Utility")
		if node != null:
			_visual(node)
	var walls := KIT._commit(root, ctx.collision, null, "UtilityCollision")
	if walls != null:
		walls.visible = false
		walls.set_meta("family_role", "solid")
		walls.set_meta("collision_only", true)


static func _utility(ctx: Dictionary, item: Dictionary, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
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
	KIT._box(_bucket_for(ctx, Color(0.6, 0.6, 0.57)), center + Vector3.UP * -0.095, t, n, Vector3(w + 0.1, 0.31, d + 0.1))


## An air-conditioner condenser on its pad: cabinet, louvred coil on the front and
## both ends, dark fan grille on top.
static func _condenser(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	_pad(ctx, center, t, n, w, d)
	var lift := 0.06
	KIT._box(_bucket_for(ctx, body), center + Vector3.UP * (lift + h * 0.5), t, n, Vector3(w, h, d))
	var louvre := _bucket_for(ctx, _color(item, "louvre_rgb", body.darkened(0.35)))
	var y := lift + 0.12
	while y < lift + h - 0.1:
		KIT._box(louvre, center + Vector3.UP * y + n * (d * 0.5 + 0.004), t, n, Vector3(w - 0.12, 0.022, 0.01))
		for side: float in [-1.0, 1.0]:
			KIT._box(louvre, center + Vector3.UP * y + t * side * (w * 0.5 + 0.004), n, t, Vector3(d - 0.12, 0.022, 0.01))
		y += 0.075
	var g := minf(w, d) * 0.78
	KIT._box(_bucket_for(ctx, _color(item, "grille_rgb", Color(0.16, 0.17, 0.18))), center + Vector3.UP * (lift + h + 0.006), t, n, Vector3(g, 0.012, g))


## A plain utility cabinet: box with a lid lip and a door seam.
static func _cabinet(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	_pad(ctx, center, t, n, w, d)
	var lift := 0.06
	KIT._box(_bucket_for(ctx, body), center + Vector3.UP * (lift + h * 0.5 - 0.02), t, n, Vector3(w, h - 0.04, d))
	KIT._box(_bucket_for(ctx, _color(item, "lid_rgb", body.lightened(0.1))), center + Vector3.UP * (lift + h - 0.02), t, n, Vector3(w + 0.04, 0.04, d + 0.04))
	var seam := _bucket_for(ctx, body.darkened(0.45))
	KIT._box(seam, center + Vector3.UP * (lift + h * 0.48) + n * (d * 0.5 + 0.004), t, n, Vector3(0.018, h - 0.16, 0.01))
	KIT._box(seam, center + Vector3.UP * (lift + h * 0.55) + n * (d * 0.5 + 0.012) + t * 0.06, t, n, Vector3(0.025, 0.12, 0.02))


## A slatted bin enclosure open to the wall: a front fence of vertical slats on two
## rails between corner posts, and a slatted end on each side back to the wall.
static func _enclosure(ctx: Dictionary, item: Dictionary, body: Color, center: Vector3, t: Vector3, n: Vector3, w: float, h: float, d: float) -> void:
	var wood := _bucket_for(ctx, body)
	var frame := _bucket_for(ctx, _color(item, "frame_rgb", body.darkened(0.2)))
	var slat := float(item.get("slat_m", 0.09))
	var gap := float(item.get("slat_gap_m", 0.035))
	_slats(wood, frame, center + n * (d * 0.5 - 0.045), t, n, w, h, slat, gap)
	for side: float in [-1.0, 1.0]:
		_slats(wood, frame, center + t * side * (w * 0.5 - 0.045) - n * 0.045, n, t * side, d - 0.09, h, slat, gap)


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
	var hb := h - 0.06
	# The body as two stacked boxes, narrower below, reads as the bin's taper.
	KIT._box(shell, center + Vector3.UP * (hb * 0.3), t, n, Vector3(w * 0.86, hb * 0.6, d * 0.86))
	KIT._box(shell, center + Vector3.UP * (hb * 0.78), t, n, Vector3(w, hb * 0.44, d))
	KIT._box(_bucket_for(ctx, _color(item, "lid_rgb", body.darkened(0.12))), center + Vector3.UP * (h - 0.035) + n * 0.015, t, n, Vector3(w + 0.03, 0.05, d + 0.04))
	var dark := _bucket_for(ctx, Color(0.12, 0.12, 0.12))
	KIT._box(dark, center + Vector3.UP * (h - 0.09) - n * (d * 0.5 + 0.025), t, n, Vector3(w * 0.8, 0.035, 0.045))
	for side: float in [-1.0, 1.0]:
		KIT._box(dark, center + Vector3.UP * 0.1 + t * side * (w * 0.5 - 0.02) - n * (d * 0.5 - 0.08), n, t, Vector3(0.2, 0.2, 0.06))


# ------------------------------------------------------------------ downspouts

## A downspout (a `pipes` entry with "style": "downspout") on a front wall: a 75 x
## 100 mm leader from the eave trim at top_y down to bottom_y, bending back from the
## trim's outlet to the wall. Where the lower storey stands `jetty_depth` back under
## the upper one (lower_frontage_recess), the leader runs down the upper wall in front
## of the band board to jetty_low, then bends back under the overhang to the lower
## wall; without one it steps out round the storey band at band_y (none below -100).
## It kicks out over a splash block at its foot, and straps wrap it every 1.4 m.
## Support role, colliding as drawn, in the trim's material.
static func downspout(root: Node3D, at: Vector3, t: Vector3, n: Vector3, bottom: float, top: float, band_y: float, jetty_depth: float, jetty_low: float, trim: Material, concrete: Material) -> void:
	# Heights below are absolute; the station point's own height plays no part.
	var p := Vector3(at.x, 0.0, at.z)
	var pipe := KIT._bucket()
	var straps := KIT._bucket()
	var splash := KIT._bucket()
	var head := top - 0.04
	var y_top := head - 0.32
	var upper := 0.10 if jetty_depth > 0.0 else 0.08
	# The outlet under the eave trim's front, then the gooseneck back to the wall.
	_leg(pipe, p, t, n, 0.215, head, 0.215, head - 0.1)
	_leg(pipe, p, t, n, 0.215, head - 0.1, upper, y_top)
	var y := y_top
	var depth := upper
	var wall := 0.0
	if jetty_depth > 0.0 and jetty_low > bottom + 0.9 and jetty_low < y_top - 0.3:
		_leg(pipe, p, t, n, upper, y, upper, jetty_low)
		_straps(straps, p, t, n, 0.0, upper, y_top - 0.4, jetty_low + 0.3)
		depth = -jetty_depth + 0.08
		wall = -jetty_depth
		_leg(pipe, p, t, n, upper, jetty_low, depth, jetty_low - 0.3)
		y = jetty_low - 0.3
	elif band_y > bottom + 0.6 and band_y < y_top - 0.3:
		_leg(pipe, p, t, n, upper, y, upper, band_y + 0.28)
		_leg(pipe, p, t, n, upper, band_y + 0.28, 0.27, band_y + 0.09)
		_straps(straps, p, t, n, 0.0, upper, y_top - 0.4, band_y + 0.5)
		depth = 0.27
		y = band_y + 0.09
	_leg(pipe, p, t, n, depth, y, depth, bottom + 0.3)
	_leg(pipe, p, t, n, depth, bottom + 0.3, depth + 0.22, bottom + 0.1)
	_straps(straps, p, t, n, wall, depth, y - 0.4, bottom + 0.6)
	KIT._box(splash, p + n * (depth + 0.38) + Vector3.UP * (bottom - 0.02), t, n, Vector3(0.3, 0.08, 0.55))
	for bucket: Dictionary in [pipe, straps]:
		var node := KIT._commit(root, bucket, trim, "Downspout")
		if node != null:
			node.set_meta("family_role", "support")
	var block := KIT._commit(root, splash, concrete, "DownspoutSplash")
	if block != null:
		block.set_meta("family_role", "support")


## Straps round a leader `depth` out (its wall at `wall`), from y_high down to y_low
## every 1.4 m: a band round the pipe and a short tab back to the wall.
static func _straps(bucket: Dictionary, p: Vector3, t: Vector3, n: Vector3, wall: float, depth: float, y_high: float, y_low: float) -> void:
	var y := y_high
	while y > y_low:
		KIT._box(bucket, p + n * depth + Vector3.UP * y, t, n, Vector3(0.091, 0.022, 0.116))
		var tab := depth - 0.05 - wall
		if tab > 0.005:
			KIT._box(bucket, p + n * (wall + tab * 0.5) + Vector3.UP * y, t, n, Vector3(0.03, 0.022, tab))
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


# ------------------------------------------------------------------ roof plane

## Checks roof_plane {"ridge": [[x, z], [x, z]], "ridge_y": y, "slope": rise a metre}:
## a two-slope roof whose surface falls `slope` metres a metre from its ridge line.
static func plane_valid(root: Node3D, plane: Variant) -> bool:
	var ok: bool = plane is Dictionary
	if ok:
		var ridge: Variant = plane.get("ridge", [])
		ok = ridge is Array and (ridge as Array).size() == 2 and _number(plane.get("ridge_y")) and _number(plane.get("slope")) and float(plane.get("slope", 0.0)) >= 0.0 and float(plane.get("slope", 0.0)) < 1.5
		if ok:
			for end: Variant in ridge:
				ok = ok and end is Array and (end as Array).size() == 2 and _number(end[0]) and _number(end[1])
	if not ok:
		_invalid(root, "Invalid roof_plane (ridge [[x, z], [x, z]], ridge_y, slope 0-1.5)")
	return ok


## The roof plane's surface height over xz.
static func _roof_y(plane: Dictionary, xz: Vector2) -> float:
	var a := Vector2(float(plane.ridge[0][0]), float(plane.ridge[0][1]))
	var b := Vector2(float(plane.ridge[1][0]), float(plane.ridge[1][1]))
	var across := Vector2(-(b - a).normalized().y, (b - a).normalized().x)
	return float(plane.ridge_y) - absf((xz - a).dot(across)) * float(plane.slope)


# ------------------------------------------------------------------ roof vents

## Checks roof_vents once.
static func vents_valid(root: Node3D, spec: Dictionary) -> bool:
	var ok := true
	for key: String in ["spacing_m", "jitter_m"]:
		ok = ok and _number(spec.get(key)) and float(spec[key]) >= 0.0 and float(spec[key]) < 20.0
	ok = ok and float(spec.get("spacing_m", 0.0)) >= 0.8 and _number(spec.get("seed", 0))
	var offset: Variant = spec.get("offset_m", [])
	ok = ok and offset is Array and (offset as Array).size() == 2 and _number(offset[0]) and _number(offset[1]) and float(offset[0]) >= 0.0 and float(offset[1]) >= float(offset[0])
	for item: Variant in spec.get("avoid", []):
		ok = ok and item is Array and (item as Array).size() == 2 and _number(item[0]) and _number(item[1])
	ok = ok and (not spec.has("rgb") or _rgb(spec.rgb))
	if not ok:
		_invalid(root, "Invalid roof_vents (spacing_m >= 0.8, jitter_m, offset_m [min, max], seed, avoid, rgb)")
	return ok


## Vent stacks and box vents along the roof plane's ridge: one every spacing_m (moved
## up to jitter_m along it), offset_m from the ridge, on the front (toward front_xz)
## slope or, for a back_share of them, the back; each inside the footprint ring by
## margin_m and clear of the `avoid` points (existing vents) by 0.6 m. Stacks are
## 8-sided pipes with a cap; box vents a low hood on a curb; all in grey metal (rgb).
static func roof_vents(root: Node3D, spec: Dictionary, plane: Dictionary, ring: PackedVector2Array, front_xz: Vector2) -> void:
	var a := Vector2(float(plane.ridge[0][0]), float(plane.ridge[0][1]))
	var b := Vector2(float(plane.ridge[1][0]), float(plane.ridge[1][1]))
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
	var slope := float(plane.slope)
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
		var roof_y := _roof_y(plane, xz)
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
	var metal := PARTS._material(_color(spec, "rgb", Color(0.56, 0.57, 0.58)), float(spec.get("roughness", 0.5)))
	metal.metallic = float(spec.get("metallic", 0.3))
	var node := KIT._commit(root, vents, metal, "RoofVents")
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


# ------------------------------------------------------------------ gable rakes

## Checks gable_rakes once.
static func rakes_valid(root: Node3D, spec: Dictionary, run_count: int) -> bool:
	var runs: Variant = spec.get("runs", [])
	var ok: bool = runs is Array and not (runs as Array).is_empty()
	if ok:
		for run: Variant in runs:
			ok = ok and _number(run) and int(run) >= 0 and int(run) < run_count
	for key: String in ["overhang_m", "board_m", "soffit_drop_m"]:
		ok = ok and _number(spec.get(key, 0.2)) and float(spec.get(key, 0.2)) > 0.0 and float(spec.get(key, 0.2)) <= 1.0
	if not ok:
		_invalid(root, "Invalid gable_rakes (runs of the wall ring, overhang_m, board_m, soffit_drop_m 0-1 m)")
	return ok


## The roof (roof_plane) carried out over the listed gable runs: a strip of roof
## overhang_m deep along each run, its top a little above the roof's own edge so it
## covers it, a soffit soffit_drop_m under it back to the wall, a rake board down its
## outer edge and end caps at the eaves. Heights follow the two-slope plane, split at
## the ridge. Roof top in the roofing, the rest in the trim.
static func gable_rakes(root: Node3D, spec: Dictionary, plane: Dictionary, vertices: Array, roofing: Material, trim: Material) -> void:
	var over := float(spec.get("overhang_m", 0.4))
	var board := float(spec.get("board_m", 0.2))
	var drop := float(spec.get("soffit_drop_m", 0.14))
	var lift := 0.06
	var top := KIT._bucket()
	var white := KIT._bucket()
	var ra := Vector2(float(plane.ridge[0][0]), float(plane.ridge[0][1]))
	var rb := Vector2(float(plane.ridge[1][0]), float(plane.ridge[1][1]))
	var across := Vector2(-(rb - ra).normalized().y, (rb - ra).normalized().x)
	var count := vertices.size() / 12
	var listed := {}
	for run: Variant in spec.runs: listed[int(run)] = true
	for run: Variant in spec.runs:
		var i := int(run) * 12
		var a := Vector2(float(vertices[i]), float(vertices[i + 2]))
		var b := Vector2(float(vertices[i + 3]), float(vertices[i + 5]))
		var t := (b - a).normalized()
		var n := Vector2(-t.y, t.x)
		# Split where the run crosses the ridge line.
		var stations: Array[Vector2] = [a]
		var da := (a - ra).dot(across)
		var db := (b - ra).dot(across)
		if da * db < 0.0:
			stations.append(a.lerp(b, da / (da - db)))
		stations.append(b)
		for k in stations.size() - 1:
			var p0 := stations[k]
			var p1 := stations[k + 1]
			var q0 := p0 + n * over
			var q1 := p1 + n * over
			var y0 := _roof_y(plane, p0) + lift
			var y1 := _roof_y(plane, p1) + lift
			var w0 := Vector3(p0.x, y0, p0.y)
			var w1 := Vector3(p1.x, y1, p1.y)
			var o0 := Vector3(q0.x, _roof_y(plane, q0) + lift, q0.y)
			var o1 := Vector3(q1.x, _roof_y(plane, q1) + lift, q1.y)
			var down := Vector3.DOWN * drop
			KIT._quad(top, w0, w1, o1, o0, Vector3.UP)
			KIT._quad(white, w0 + down, w1 + down, o1 + down, o0 + down, Vector3.DOWN)
			# The rake board: the outer edge's face, from under the soffit to the strip's top.
			var face := Vector3(n.x, 0.0, n.y)
			var low := Vector3.DOWN * (board - 0.02)
			KIT._quad(white, o0 + Vector3.UP * 0.02 + face * 0.005, o1 + Vector3.UP * 0.02 + face * 0.005, o1 + low + face * 0.005, o0 + low + face * 0.005, face)
			# Close the board's underside back to the soffit.
			KIT._quad(white, o0 + low + face * 0.005, o1 + low + face * 0.005, o1 + down, o0 + down, Vector3.DOWN)
		# End caps where the strip meets the eaves: the run's ends that no listed run continues.
		for end: Array in [[a, -t, posmod(int(run) - 1, count)], [b, t, posmod(int(run) + 1, count)]]:
			if listed.has(int(end[2])):
				continue
			var p: Vector2 = end[0]
			var out: Vector2 = end[1]
			var q := p + n * over
			var yp := _roof_y(plane, p) + lift
			var yq := _roof_y(plane, q) + lift
			var o3 := Vector3(out.x, 0.0, out.y)
			KIT._quad(white, Vector3(p.x, yp, p.y), Vector3(q.x, yq, q.y), Vector3(q.x, yq - board + 0.02, q.y), Vector3(p.x, yp - drop, p.y), o3)
	for pair: Array in [[top, roofing, "GableRakeTop"], [white, trim, "GableRake"]]:
		var node := KIT._commit(root, pair[0], pair[1], pair[2])
		if node != null:
			node.set_meta("family_role", "support")
