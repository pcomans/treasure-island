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


## Checks a window's own "blind" {"drops": [left, right], "curtains": [left, right]}, each a
## share 0-1 of that pane (see window_blinds); an invalid one fails the build.
static func pinned_blind_valid(root: Node3D, pinned: Variant) -> bool:
	var ok: bool = pinned is Dictionary and not (pinned as Dictionary).is_empty()
	if ok:
		for key: String in pinned:
			var pair: Variant = pinned[key]
			ok = ok and key in ["drops", "curtains"] and pair is Array and (pair as Array).size() == 2
			if ok:
				for share: Variant in pair:
					ok = ok and _number(share) and float(share) >= 0.0 and float(share) <= 1.0
	if not ok:
		_invalid(root, "Invalid window blind (drops and curtains: [left, right] shares 0-1)")
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
static func window_blinds(ctx: Dictionary, spec: Dictionary, point: Vector3, t: Vector3, n: Vector3, w: float, h: float, pinned: Dictionary = {}) -> void:
	var seed := int(spec.get("seed", 0))
	var drops: Array = spec.drops
	var face := -n * (PANE_FRONT_M - BLIND_GAP_M)
	var pane_w := w * 0.5 - 0.045
	var pane_h := h - 0.07
	var top := h * 0.5 - 0.035
	var place := [point.x, point.z, point.y]
	# A window's own "blind" {"drops": [left, right], "curtains": [left, right]} (share of a
	# pane; 0 none) pins what a dated photo shows there; colours still come from the set.
	if not pinned.is_empty():
		_pinned_blinds(ctx, spec, pinned, point, t, n, w, face, pane_w, pane_h, top, place)
		return
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


static func _pinned_blinds(ctx: Dictionary, spec: Dictionary, pinned: Dictionary, point: Vector3, t: Vector3, n: Vector3, w: float, face: Vector3, pane_w: float, pane_h: float, top: float, place: Array) -> void:
	var seed := int(spec.get("seed", 0))
	var rgbs: Array = spec.rgbs
	var blind := _to_color(rgbs[_pick(seed, place + [13.0], rgbs.size())])
	var shade := float(spec.get("hem_shade", 0.78))
	var curtain_rgbs: Array = spec.get("curtain_rgbs", spec.rgbs)
	var cloth := _to_color(curtain_rgbs[_pick(seed, place + [11.0], curtain_rgbs.size())])
	var pleat := cloth * float(spec.get("pleat_shade", 0.86))
	var drops: Array = pinned.get("drops", [0.0, 0.0])
	var curtains: Array = pinned.get("curtains", [0.0, 0.0])
	for i in 2:
		var side := -1.0 if i == 0 else 1.0
		var drop := float(drops[i])
		if drop > 0.0:
			var center := point + t * side * w * 0.25 + face
			var bh := pane_h * minf(drop, 1.0)
			var hem := minf(0.06, bh * 0.25)
			_face(_bucket_for(ctx, blind), center + Vector3.UP * (top - (bh - hem) * 0.5), t, n, pane_w, bh - hem)
			_face(_bucket_for(ctx, blind * shade), center + Vector3.UP * (top - bh + hem * 0.5), t, n, pane_w, hem)
		var share := float(curtains[i])
		if share > 0.0:
			var cw := pane_w * minf(share, 1.0)
			var c := point + t * side * (w * 0.25 + pane_w * 0.5 - cw * 0.5) + face + n * 0.003
			_face(_bucket_for(ctx, cloth), c, t, n, cw, pane_h)
			for k: float in [-1.0 / 6.0, 1.0 / 6.0]:
				_face(_bucket_for(ctx, pleat), c + t * cw * k * 2.0 + n * 0.002, t, n, minf(0.03, cw * 0.2), pane_h)


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


## The lower storey's plan: the footprint ring less each recessed run's strip (recessed maps
## a run index to how far its lower wall stands in), so only those runs move in. Each strip
## starts 5 mm outside its run, so no sliver of the plan is left along the run's line.
static func lower_outline(ring: PackedVector2Array, recessed: Dictionary) -> Array[PackedVector2Array]:
	var parts: Array[PackedVector2Array] = [ring]
	for run: int in recessed:
		if run < 0 or run >= ring.size():
			continue
		var a := ring[run]
		var b := ring[(run + 1) % ring.size()]
		var t := (b - a).normalized()
		var inward := Vector2(-t.y, t.x)
		if not Geometry2D.is_point_in_polygon((a + b) * 0.5 + inward * 0.01, ring):
			inward = -inward
		var depth := float(recessed[run])
		var strip := PackedVector2Array([a - t * 0.001 - inward * 0.005, b + t * 0.001 - inward * 0.005, b + t * 0.001 + inward * depth, a - t * 0.001 + inward * depth])
		var next: Array[PackedVector2Array] = []
		for part: PackedVector2Array in parts:
			next.append_array(Geometry2D.clip_polygons(part, strip))
		parts = next
	return parts


## A simple polygon's area, from its first corner (world coordinates are hundreds of
## metres out, too far for single-precision cross products).
static func _area(polygon: PackedVector2Array) -> float:
	var twice := 0.0
	for i in range(1, polygon.size() - 1):
		twice += (polygon[i] - polygon[0]).cross(polygon[i + 1] - polygon[0])
	return absf(twice) * 0.5


## Commits the utilities (visual only, one mesh per colour, plus their collision boxes),
## failing the build where one overlaps the lower storey's plan (lower_outline) by more
## than 1 cm2 or stands on a door landing.
static func commit_utilities(root: Node3D, ctx: Dictionary, outline: Array[PackedVector2Array]) -> void:
	for entry: Array in ctx.footprints:
		var quad: PackedVector2Array = entry[2]
		var inside := 0.0
		for part: PackedVector2Array in outline:
			for piece: PackedVector2Array in Geometry2D.intersect_polygons(quad, part):
				inside += _area(piece)
		if inside > 0.0001:
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

## Checks roof_plane: the instance's roof as one gable per footprint segment, in the
## production roof's own frame: "axis" [x, z] along the ridges, "normal" [x, z] across
## them, "ridge_d" (the frame's origin across), "slope" (rise a metre), "segments"
## [{"ridge_offset", "ridge_y"}] (each ridge's offset across from ridge_d and height),
## "cuts" [{"west_t", "east_t", "jog_d"}] between neighbours (a point lies before cut k
## where t <= west_t if d >= jog_d, east_t otherwise) and "extent_t" [t0, t1].
static func plane_valid(root: Node3D, plane: Variant) -> bool:
	var ok: bool = plane is Dictionary
	if ok:
		for key: String in ["axis", "normal", "extent_t"]:
			var pair: Variant = plane.get(key, [])
			ok = ok and pair is Array and (pair as Array).size() == 2 and _number(pair[0]) and _number(pair[1])
		ok = ok and _number(plane.get("ridge_d")) and _number(plane.get("slope")) and float(plane.get("slope", 0.0)) >= 0.0 and float(plane.get("slope", 0.0)) < 1.5
		var segments: Variant = plane.get("segments", [])
		var cuts: Variant = plane.get("cuts", [])
		ok = ok and segments is Array and not (segments as Array).is_empty() and cuts is Array and (cuts as Array).size() == (segments as Array).size() - 1
		if ok:
			for segment: Variant in segments:
				ok = ok and segment is Dictionary and _number(segment.get("ridge_offset")) and _number(segment.get("ridge_y"))
			for cut: Variant in cuts:
				ok = ok and cut is Dictionary and _number(cut.get("west_t")) and _number(cut.get("east_t")) and _number(cut.get("jog_d"))
	if not ok:
		_invalid(root, "Invalid roof_plane (axis, normal, ridge_d, slope 0-1.5, segments [{ridge_offset, ridge_y}], cuts [{west_t, east_t, jog_d}] one fewer, extent_t)")
	return ok


## (t, d): along the ridges and across them, from ridge_d.
static func _plane_td(plane: Dictionary, xz: Vector2) -> Vector2:
	var axis := Vector2(float(plane.axis[0]), float(plane.axis[1]))
	var normal := Vector2(float(plane.normal[0]), float(plane.normal[1]))
	return Vector2(xz.dot(axis), xz.dot(normal) - float(plane.ridge_d))


static func _plane_segment(plane: Dictionary, td: Vector2) -> int:
	var cuts: Array = plane.cuts
	for k in cuts.size():
		if td.x <= float(cuts[k].west_t if td.y >= float(cuts[k].jog_d) else cuts[k].east_t):
			return k
	return cuts.size()


## The cut's t at a given d (its west or east line).
static func _cut_t(cut: Dictionary, d: float) -> float:
	return float(cut.west_t if d >= float(cut.jog_d) else cut.east_t)


## The point at (t, d) in the plane's frame.
static func _plane_xz(plane: Dictionary, t: float, d: float) -> Vector2:
	var axis := Vector2(float(plane.axis[0]), float(plane.axis[1]))
	var normal := Vector2(float(plane.normal[0]), float(plane.normal[1]))
	return axis * t + normal * (float(plane.ridge_d) + d)


## The roof's surface height over xz (segment k when given, else the one over xz).
static func _roof_y(plane: Dictionary, xz: Vector2, k: int = -1) -> float:
	var td := _plane_td(plane, xz)
	if k < 0:
		k = _plane_segment(plane, td)
	var segment: Dictionary = plane.segments[k]
	return float(segment.ridge_y) - absf(td.y - float(segment.ridge_offset)) * float(plane.slope)


## Segment k's ridge line: its two ends in xz, between its cuts (or the plane's extent).
static func _ridge_ends(plane: Dictionary, k: int) -> Array[Vector2]:
	var dc := float(plane.segments[k].ridge_offset)
	var t0 := float(plane.extent_t[0]) if k == 0 else _cut_t(plane.cuts[k - 1], dc)
	var t1 := float(plane.extent_t[1]) if k == (plane.segments as Array).size() - 1 else _cut_t(plane.cuts[k], dc)
	return [_plane_xz(plane, t0, dc), _plane_xz(plane, t1, dc)]


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
	ok = ok and _range_pair(spec, "stack_radius_m", 0.01, 0.3) and _range_pair(spec, "stack_height_m", 0.05, 2.0)
	ok = ok and _range_pair(spec, "cluster_size", 1.0, 4.0) and _range_pair(spec, "cap_m", 0.0, 0.2)
	ok = ok and (not spec.has("cluster_step_m") or (_number(spec.cluster_step_m) and float(spec.cluster_step_m) >= 0.25 and float(spec.cluster_step_m) <= 1.5))
	if not ok:
		_invalid(root, "Invalid roof_vents (spacing_m >= 0.8, jitter_m, offset_m [min, max], seed, avoid, rgb, stack_radius_m, stack_height_m, cluster_size 1-4, cluster_step_m 0.25-1.5, cap_m)")
	return ok


## Whether an optional spec[key] is absent or [a, b] with lo <= a <= b <= hi.
static func _range_pair(spec: Dictionary, key: String, lo: float, hi: float) -> bool:
	if not spec.has(key):
		return true
	var pair: Variant = spec[key]
	return pair is Array and (pair as Array).size() == 2 and _number(pair[0]) and _number(pair[1]) \
		and float(pair[0]) >= lo and float(pair[0]) <= float(pair[1]) and float(pair[1]) <= hi


## Vent stacks and box vents along the roof plane's ridge: one every spacing_m (moved
## up to jitter_m along it), offset_m from the ridge, on the front (toward front_xz)
## slope or, for a back_share of them, the back; each inside the footprint ring by
## margin_m and clear of the `avoid` points (existing vents) by 0.6 m. Stacks are
## 8-sided pipes with a cap; box vents a low hood on a curb; all in grey metal (rgb).
static func roof_vents(root: Node3D, spec: Dictionary, plane: Dictionary, ring: PackedVector2Array, front_xz: Vector2) -> void:
	var vents := KIT._bucket()
	for k in (plane.segments as Array).size():
		var ends := _ridge_ends(plane, k)
		_segment_vents(vents, spec, plane, k, ends[0], ends[1], ring, front_xz)
	var metal := PARTS._material(_color(spec, "rgb", Color(0.56, 0.57, 0.58)), float(spec.get("roughness", 0.5)))
	metal.metallic = float(spec.get("metallic", 0.3))
	var node := KIT._commit(root, vents, metal, "RoofVents")
	if node != null:
		node.set_meta("family_role", "support")


## One segment's vents, along its ridge from a to b (see roof_vents).
static func _segment_vents(vents: Dictionary, spec: Dictionary, plane: Dictionary, k: int, a: Vector2, b: Vector2, ring: PackedVector2Array, front_xz: Vector2) -> void:
	var along := (b - a).normalized()
	var across := Vector2(-along.y, along.x)
	if across.dot(front_xz - a) < 0.0:
		across = -across
	var length := a.distance_to(b)
	var seed := int(spec.get("seed", 0)) + 7919 * k
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
	# Opt-in cluster_size [min, max]: that many vents at each place, cluster_step_m apart
	# along the ridge, each a little off its neighbour's line; cap_m [wider by, tall] gives a
	# stack a broad cap with a hood on it (default one vent, a thin cap).
	var cluster: Array = spec.get("cluster_size", [1, 1])
	var step := float(spec.get("cluster_step_m", 0.45))
	var cap: Array = spec.get("cap_m", [0.012, 0.025])
	var places: Array[Array] = []
	var next := spacing * 0.5
	while next < length:
		var s0 := next
		next += spacing
		var count := int(cluster[0]) + _pick(seed, [s0, 9.0], int(cluster[1]) - int(cluster[0]) + 1)
		for m in count:
			# The first vent where a single one would stand; the others step along the ridge
			# with their own picks (station s) and a small offset across.
			var s := s0 + float(m) * 0.37
			var dy := 0.0 if m == 0 else (float(_pick(seed, [s, 11.0], 1000)) / 1000.0 - 0.5) * step * 0.4
			places.append([s0, s, float(m) * step, dy])
	for place: Array in places:
		var s: float = place[1]
		var s_base: float = place[0]
		var at := s_base + float(place[2]) + (float(_pick(seed, [s_base, 1.0], 1000)) / 1000.0 - 0.5) * 2.0 * jitter
		var off := lerpf(lo, hi, float(_pick(seed, [s_base, 2.0], 1000)) / 1000.0) + float(place[3])
		var sign := -1.0 if float(_pick(seed, [s_base, 3.0], 1000)) / 1000.0 < back_share else 1.0
		var xz := a + along * at + across * off * sign
		var clear := Geometry2D.is_point_in_polygon(xz, ring)
		for i in ring.size():
			clear = clear and Geometry2D.get_closest_point_to_segment(xz, ring[i], ring[(i + 1) % ring.size()]).distance_to(xz) >= margin
		for point: Vector2 in avoid:
			clear = clear and point.distance_to(xz) >= 0.6
		# On this segment's roof, clear of a neighbour's (a step's gable end).
		var td := _plane_td(plane, xz)
		for dt in [-0.5, 0.5]:
			clear = clear and _plane_segment(plane, td + Vector2(dt, 0.0)) == k
		if not clear:
			continue
		var roof_y := _roof_y(plane, xz, k)
		var base := Vector3(xz.x, roof_y, xz.y)
		var t3 := Vector3(along.x, 0.0, along.y)
		var n3 := Vector3(across.x, 0.0, across.y)
		if float(_pick(seed, [s, 4.0], 1000)) / 1000.0 < stack_share:
			# Opt-in stack_radius_m / stack_height_m [min, max] (default 0.04-0.06, 0.28-0.46).
			var radii: Array = spec.get("stack_radius_m", [0.04, 0.06])
			var heights: Array = spec.get("stack_height_m", [0.28, 0.46])
			var r := lerpf(float(radii[0]), float(radii[1]), float(_pick(seed, [s, 5.0], 3)) * 0.5)
			var hgt := lerpf(float(heights[0]), float(heights[1]), float(_pick(seed, [s, 6.0], 4)) / 3.0)
			# From under the roof surface (its fall across the pipe) to the stack's top.
			var foot := roof_y - r * slope - 0.03
			_prism(vents, Vector3(xz.x, foot, xz.y), r, roof_y + hgt - foot)
			_prism(vents, Vector3(xz.x, roof_y + hgt, xz.y), r + float(cap[0]), float(cap[1]), spec.has("cap_m"))
			if spec.has("cap_m"):
				_prism(vents, Vector3(xz.x, roof_y + hgt + float(cap[1]), xz.y), r * 0.55, float(cap[1]) * 1.2)
		else:
			var curb := 0.3
			KIT._box(vents, base + Vector3.UP * 0.02, t3, n3, Vector3(curb, 0.16 + curb * slope, curb))
			KIT._box(vents, base + Vector3.UP * 0.13, t3, n3, Vector3(curb + 0.08, 0.05, curb + 0.08))


## An 8-sided upright prism (radius r, height h) standing on foot, capped on top; a foot
## under the roof surface needs no bottom, a cap seen from below takes one (underside).
static func _prism(bucket: Dictionary, foot: Vector3, r: float, h: float, underside: bool = false) -> void:
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
		if underside:
			KIT._tri(bucket, foot, p, q, Vector3.DOWN)


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
	ok = ok and _number(spec.get("edge_m", 0.03)) and float(spec.get("edge_m", 0.03)) >= 0.0 and float(spec.get("edge_m", 0.03)) <= 0.1
	ok = ok and _number(spec.get("shade_m", 0.0)) and float(spec.get("shade_m", 0.0)) >= 0.0 and float(spec.get("shade_m", 0.0)) <= 1.5
	for key: String in ["top_rgb", "board_rgb", "soffit_rgb"]:
		ok = ok and (not spec.has(key) or _rgb(spec[key]))
	if not ok:
		_invalid(root, "Invalid gable_rakes (runs of the wall ring, overhang_m, board_m, soffit_drop_m 0-1 m, edge_m 0-0.1, rgbs)")
	return ok


## The roof (roof_plane) carried out over the listed gable runs: a strip of roof
## overhang_m deep along each run, its top a little above the roof's own edge so it
## covers it, running edge_m past the rake board so the roofing's edge shows over it, a
## soffit soffit_drop_m under it back to the wall, the board down its outer edge and end
## caps at the eaves. Heights follow the run's segment of the roof, split at its ridge.
## Roof top in top_rgb (else the roofing), board and caps in board_rgb, soffit in
## soffit_rgb (else the trim).
static func gable_rakes(root: Node3D, spec: Dictionary, plane: Dictionary, vertices: Array, roofing: Material, trim: Material, shades: Array = []) -> void:
	var over := float(spec.get("overhang_m", 0.4))
	# Opt-in shade_m: the wall under the soffit, that far down, in the building's two shade
	# materials (darker at the soffit), as the deep rake keeps the sky off it.
	var shade_m := float(spec.get("shade_m", 0.0)) if shades.size() == 2 else 0.0
	var shade_buckets := [KIT._bucket(), KIT._bucket()]
	var board := float(spec.get("board_m", 0.2))
	var drop := float(spec.get("soffit_drop_m", 0.14))
	var edge := float(spec.get("edge_m", 0.03))
	var lift := 0.06
	var top := KIT._bucket()
	var white := KIT._bucket()
	var under := KIT._bucket()
	var count := vertices.size() / 12
	var listed := {}
	for run: Variant in spec.runs: listed[int(run)] = true
	for run: Variant in spec.runs:
		var i := int(run) * 12
		var a := Vector2(float(vertices[i]), float(vertices[i + 2]))
		var b := Vector2(float(vertices[i + 3]), float(vertices[i + 5]))
		var t := (b - a).normalized()
		var n := Vector2(-t.y, t.x)
		# The run's segment, and where the run crosses that segment's ridge.
		var k := _plane_segment(plane, _plane_td(plane, (a + b) * 0.5))
		var dc := float(plane.segments[k].ridge_offset)
		var stations: Array[Vector2] = [a]
		var da := _plane_td(plane, a).y - dc
		var db := _plane_td(plane, b).y - dc
		if da * db < 0.0:
			stations.append(a.lerp(b, da / (da - db)))
		stations.append(b)
		var face := Vector3(n.x, 0.0, n.y)
		for j in stations.size() - 1:
			var p0 := stations[j]
			var p1 := stations[j + 1]
			var q0 := p0 + n * (over + edge)
			var q1 := p1 + n * (over + edge)
			var w0 := Vector3(p0.x, _roof_y(plane, p0, k) + lift, p0.y)
			var w1 := Vector3(p1.x, _roof_y(plane, p1, k) + lift, p1.y)
			var o0 := Vector3(q0.x, _roof_y(plane, q0, k) + lift, q0.y)
			var o1 := Vector3(q1.x, _roof_y(plane, q1, k) + lift, q1.y)
			# The roof's own slope normal, up and away from the ridge.
			var up := (w1 - w0).cross(o0 - w0).normalized()
			if up.y < 0.0:
				up = -up
			KIT._quad(top, w0, w1, o1, o0, up)
			# The roofing's edge: a thin dark face over the board.
			KIT._quad(top, o0, o1, o1 + Vector3.DOWN * 0.03, o0 + Vector3.DOWN * 0.03, face)
			# The board, edge_m inside the roofing's edge, from under the soffit to the top.
			var b0 := o0 - face * edge
			var b1 := o1 - face * edge
			var low := Vector3.DOWN * (board - 0.02)
			KIT._quad(white, b0 + Vector3.DOWN * 0.03, b1 + Vector3.DOWN * 0.03, b1 + low, b0 + low, face)
			KIT._quad(white, b0 + low, b1 + low, b1 + low - face * 0.025, b0 + low - face * 0.025, Vector3.DOWN)
			# The soffit, from the board's back to the wall.
			var down := Vector3.DOWN * drop
			var s0 := Vector3(p0.x, w0.y, p0.y) + down
			var s1 := Vector3(p1.x, w1.y, p1.y) + down
			var e0 := b0 - face * 0.025 + Vector3.UP * (o0.y - b0.y) + down
			var e1 := b1 - face * 0.025 + Vector3.UP * (o1.y - b1.y) + down
			KIT._quad(under, s0, s1, e1, e0, Vector3.DOWN)
			KIT._quad(white, b0 + low - face * 0.025, b1 + low - face * 0.025, e1, e0, -face)
			if shade_m > 0.0:
				# Two bands a hair off the wall, from the soffit down: the darker one first.
				var off := face * 0.004
				for band in 2:
					var hi := Vector3.DOWN * (0.0 if band == 0 else shade_m * 0.4)
					var lo := Vector3.DOWN * (shade_m * 0.4 if band == 0 else shade_m)
					KIT._quad(shade_buckets[band], s0 + hi + off, s1 + hi + off, s1 + lo + off, s0 + lo + off, face)
		# End caps where the strip meets the eaves: the run's ends that no listed run continues.
		for end: Array in [[a, -t, posmod(int(run) - 1, count)], [b, t, posmod(int(run) + 1, count)]]:
			if listed.has(int(end[2])):
				continue
			var p: Vector2 = end[0]
			var out: Vector2 = end[1]
			var q := p + n * over
			var yp := _roof_y(plane, p, k) + lift
			var yq := _roof_y(plane, q, k) + lift
			var o3 := Vector3(out.x, 0.0, out.y)
			KIT._quad(white, Vector3(p.x, yp, p.y), Vector3(q.x, yq, q.y), Vector3(q.x, yq - board + 0.02, q.y), Vector3(p.x, yp - drop, p.y), o3)
	var roof_top: Material = roofing
	if spec.has("top_rgb"):
		roof_top = PARTS._material(_color(spec, "top_rgb", Color.GRAY), 0.95)
	var board_material: Material = trim
	if spec.has("board_rgb"):
		board_material = PARTS._material(_color(spec, "board_rgb", Color.WHITE), 0.7)
	var soffit_material: Material = trim
	if spec.has("soffit_rgb"):
		soffit_material = PARTS._material(_color(spec, "soffit_rgb", Color.WHITE), 0.85)
	for pair: Array in [[top, roof_top, "GableRakeTop"], [white, board_material, "GableRake"], [under, soffit_material, "GableRakeSoffit"]]:
		var node := KIT._commit(root, pair[0], pair[1], pair[2])
		if node != null:
			node.set_meta("family_role", "support")
	if shade_m > 0.0:
		for band in 2:
			var node := KIT._commit(root, shade_buckets[band], shades[band], "GableRakeShade")
			if node != null:
				node.set_meta("family_role", "support")


# ------------------------------------------------------------------ end annexes

## Sources whose annex may stand outside the frozen OSM footprint: each one a recorded
## owner exception (the entry's osm_exception), so a new one needs a code change here.
const ANNEX_EXCEPTION_SOURCES := ["w96215673"]


## Checks an end_annexes entry: {"run", "from_m", "to_m" (along the run), "depth_m" (out
## from it), "base_y" (under the ground), "top_y", "door": {"out_m" (from the wall to its
## near jamb), "width_m", "height_m", "bottom_y", "rgb"}, "flues": [{"at_m", "out_m",
## "diameter_m", "height_m"}], "roof_rgb", "evidence",
## "osm_exception": {"reason", "approved", "photo", "outline_xz"} (exactly these, as the
## street detail's zones record theirs)}.
static func annex_valid(root: Node3D, spec: Dictionary, source_key: String, vertices: Array) -> bool:
	var ok: bool = ANNEX_EXCEPTION_SOURCES.has(source_key)
	ok = ok and _number(spec.get("run")) and int(spec.get("run", -1)) >= 0 and int(spec.get("run", -1)) < vertices.size() / 12
	for key: String in ["from_m", "to_m", "depth_m", "base_y", "top_y"]:
		ok = ok and _number(spec.get(key))
	if ok:
		ok = float(spec.to_m) > float(spec.from_m) + 0.5 and float(spec.depth_m) >= 0.5 and float(spec.depth_m) <= 6.0 and float(spec.top_y) > float(spec.base_y) + 2.0
	var door: Variant = spec.get("door", {})
	ok = ok and door is Dictionary
	if ok:
		for key: String in ["out_m", "width_m", "height_m", "bottom_y"]:
			ok = ok and _number(door.get(key))
		ok = ok and (not door.has("rgb") or _rgb(door.rgb))
		ok = ok and float(door.get("out_m", 0.0)) >= 0.0 and float(door.get("out_m", 0.0)) + float(door.get("width_m", 0.0)) <= float(spec.get("depth_m", 0.0)) - 0.05
	for key: String in ["roof_rgb", "flue_rgb", "flue_cap_rgb"]:
		ok = ok and (not spec.has(key) or _rgb(spec[key]))
	var exception: Variant = spec.get("osm_exception", null)
	ok = ok and exception is Dictionary and (exception as Dictionary).size() == 4
	if ok:
		for key: String in ["reason", "approved", "photo"]:
			ok = ok and exception.get(key) is String and not str(exception.get(key)).strip_edges().is_empty()
		# The recorded outline is the block itself: its four corners within 1 cm of the
		# run's from_m and to_m, at the wall and depth_m out, in that order.
		var outline: Variant = exception.get("outline_xz", [])
		ok = ok and outline is Array and (outline as Array).size() == 4
		if ok:
			var corners := annex_corners(spec, vertices)
			ok = float(spec.to_m) <= corners[4].x + 0.01
			for c in 4:
				var given: Variant = outline[c]
				ok = ok and given is Array and (given as Array).size() == 2 and _number(given[0]) and _number(given[1]) \
					and Vector2(float(given[0]), float(given[1])).distance_to(corners[c]) <= 0.01
	for flue: Variant in spec.get("flues", []):
		ok = ok and flue is Dictionary and _number(flue.get("at_m")) and _number(flue.get("out_m")) and _number(flue.get("diameter_m")) and _number(flue.get("height_m"))
	if not ok:
		_invalid(root, "Invalid end_annexes entry (a recorded exception for this source only: run, from_m < to_m within the run, depth_m 0.5-6, base_y, top_y, door {out_m, width_m, height_m, bottom_y} inside the end face, flues, osm_exception {reason, approved, photo, outline_xz: the block's corners within 1 cm})")
	return ok


## An annex's plan corners (XZ): at from_m and to_m along its run on the wall, then
## depth_m out at to_m and from_m; a fifth entry carries the run's length in x.
static func annex_corners(spec: Dictionary, vertices: Array) -> Array[Vector2]:
	var i := int(spec.run) * 12
	var a := Vector2(float(vertices[i]), float(vertices[i + 2]))
	var b := Vector2(float(vertices[i + 3]), float(vertices[i + 5]))
	var t := (b - a).normalized()
	var n := Vector2(-t.y, t.x)
	var from := float(spec.from_m)
	var to := float(spec.to_m)
	var depth := float(spec.depth_m)
	return [a + t * from, a + t * to, a + t * to + n * depth, a + t * from + n * depth, Vector2(a.distance_to(b), 0.0)]


## A one-storey block on an end wall, as the dated photo shows it: siding on its three
## open sides from base_y (under the ground) up to a flat roof slab with a coping round
## its edge, a two-leaf door in the end face toward the run's end (door.out_m from the
## wall) with its casing and a threshold slab from the door down into the ground, and
## the flues on the roof. Sides the photo doesn't show stay plain siding. Walls are the
## wall role; roof, coping, door, flues and threshold collide as support.
static func end_annex(root: Node3D, spec: Dictionary, vertices: Array, siding: Material, trim: Material, concrete: Material) -> void:
	var i := int(spec.run) * 12
	var a := Vector3(float(vertices[i]), 0.0, float(vertices[i + 2]))
	var b := Vector3(float(vertices[i + 3]), 0.0, float(vertices[i + 5]))
	var t := (b - a).normalized()
	var n := Vector3(-t.z, 0.0, t.x)
	var depth := float(spec.depth_m)
	var base := float(spec.base_y)
	var top := float(spec.top_y)
	var slab := 0.2
	var a0 := a + t * float(spec.from_m)
	var a1 := a + t * float(spec.to_m)
	var b0 := a0 + n * depth
	var b1 := a1 + n * depth
	var wall_top := top - slab
	var door: Dictionary = spec.door
	var door_w := float(door.width_m)
	var door_h := float(door.height_m)
	var door_bottom := float(door.bottom_y)
	# The end face runs from b1 back to a1 (outward t); x along it from b1.
	var door_x := depth - float(door.out_m) - door_w
	var begin := root.get_child_count()
	PARTS._wall_with_openings(root, Vector3(b0.x, base, b0.z), Vector3(b1.x, base, b1.z), wall_top, [], siding)
	var holes: Array[Rect2] = [Rect2(door_x, door_bottom, door_w, door_h)]
	PARTS._wall_with_openings(root, Vector3(b1.x, base, b1.z), Vector3(a1.x, base, a1.z), wall_top, holes, siding)
	PARTS._wall_with_openings(root, Vector3(a0.x, base, a0.z), Vector3(b0.x, base, b0.z), wall_top, [], siding)
	for k in range(begin, root.get_child_count()):
		root.get_child(k).set_meta("family_role", "wall")
	var white := KIT._bucket()
	var leaf := KIT._bucket()
	var dark := KIT._bucket()
	var roof := KIT._bucket()
	var pad := KIT._bucket()
	var metal := KIT._bucket()
	var mid_y := (base + wall_top) * 0.5
	# Corner boards on the two outer corners.
	for corner: Vector3 in [b0, b1]:
		KIT._box(white, Vector3(corner.x, mid_y, corner.z), t, n, Vector3(0.1, wall_top - base, 0.1))
	# Flat roof: the slab over the block, a coping band round its three open edges.
	var centre := (a0 + b1) * 0.5
	KIT._box(roof, Vector3(centre.x, top - slab * 0.5 - 0.01, centre.z), t, n, Vector3(float(spec.to_m) - float(spec.from_m) + 0.06, slab, depth + 0.06))
	var c_top := top + 0.02
	for side: Array in [[b0, b1, n], [b1, a1, t], [a0, b0, -t]]:
		var p: Vector3 = side[0]
		var q: Vector3 = side[1]
		var out: Vector3 = side[2]
		var along := (q - p).normalized()
		var mid := (p + q) * 0.5 + out * 0.05
		KIT._box(white, Vector3(mid.x, c_top - 0.11, mid.z), along, out, Vector3(p.distance_to(q) + 0.16, 0.22, 0.06))
	# The door: two leaves set 6 cm back in the opening, dark reveals at its jambs and
	# head, the casing proud of the siding, the leaves' joint, handles and the plate on
	# the first leaf.
	var face := -n
	var door_mid := b1 + face * (door_x + door_w * 0.5)
	var dc := Vector3(door_mid.x, door_bottom + door_h * 0.5, door_mid.z)
	KIT._box(leaf, dc - t * 0.075, face, t, Vector3(door_w, door_h, 0.03))
	for side in [-1.0, 1.0]:
		KIT._box(dark, dc + face * side * (door_w * 0.5 - 0.01) - t * 0.03, face, t, Vector3(0.02, door_h, 0.06))
	KIT._box(dark, dc + Vector3.UP * (door_h * 0.5 - 0.01) - t * 0.03, face, t, Vector3(door_w, 0.02, 0.06))
	KIT._box(dark, dc - t * 0.055, face, t, Vector3(0.012, door_h - 0.04, 0.012))
	for side in [-1.0, 1.0]:
		KIT._box(white, dc + face * side * (door_w * 0.5 + 0.045) + t * 0.015 + Vector3.UP * 0.04, face, t, Vector3(0.09, door_h + 0.08, 0.05))
		KIT._box(dark, dc + face * side * 0.07 - t * 0.045 + Vector3.DOWN * 0.08, face, t, Vector3(0.03, 0.16, 0.03))
	KIT._box(white, dc + Vector3.UP * (door_h * 0.5 + 0.045) + t * 0.015, face, t, Vector3(door_w + 0.18, 0.09, 0.05))
	KIT._box(white, dc - face * (door_w * 0.25) + Vector3.UP * 0.15 - t * 0.055, face, t, Vector3(0.34, 0.12, 0.012))
	# Threshold: from the door out, its top at the door's foot, its bottom in the ground.
	var low := minf(base + 0.1, door_bottom - 0.25)
	var step := dc + t * 0.45
	KIT._box(pad, Vector3(step.x, (door_bottom + low) * 0.5, step.z), face, t, Vector3(door_w + 0.3, door_bottom - low, 0.9))
	# Flues on the roof, at_m along the run and out_m from the wall: a dark collar where they
	# leave the roof, the metal body, a wide rain cap on a short neck and its cone.
	var caps := KIT._bucket()
	for flue: Dictionary in spec.get("flues", []):
		var foot := a + t * float(flue.at_m) + n * float(flue.out_m)
		var r := float(flue.diameter_m) * 0.5
		var h := float(flue.height_m)
		_prism(dark, Vector3(foot.x, top - 0.05, foot.z), r * 1.25, 0.2)
		_prism(metal, Vector3(foot.x, top + 0.15, foot.z), r, h - 0.15)
		_prism(caps, Vector3(foot.x, top + h, foot.z), r * 0.5, 0.1)
		_prism(caps, Vector3(foot.x, top + h + 0.1, foot.z), r * 1.6, 0.06, true)
		_prism(caps, Vector3(foot.x, top + h + 0.16, foot.z), r * 0.9, 0.1)
	var door_rgb := _color(door, "rgb", Color(0.62, 0.64, 0.64))
	var parts: Array = [[white, trim, "AnnexTrim"], [leaf, PARTS._material(door_rgb, 0.6), "AnnexDoor"], [dark, PARTS._material(Color(0.16, 0.17, 0.18), 0.6), "AnnexReveal"],
		[roof, PARTS._material(_color(spec, "roof_rgb", Color(0.2, 0.21, 0.22)), 0.9), "AnnexRoof"], [pad, concrete, "AnnexThreshold"]]
	# Galvanised: a sharp sky reflection for the photo's bright stripe, a light body.
	var steel := PARTS._material(_color(spec, "flue_rgb", Color(0.62, 0.63, 0.64)), 0.18)
	steel.metallic = 0.4
	parts.append([metal, steel, "AnnexFlues"])
	var cap_steel := PARTS._material(_color(spec, "flue_cap_rgb", Color(0.8, 0.81, 0.82)), 0.35)
	cap_steel.metallic = 0.6
	parts.append([caps, cap_steel, "AnnexFlueCaps"])
	for part: Array in parts:
		var node := KIT._commit(root, part[0], part[1], part[2])
		if node != null:
			node.set_meta("family_role", "support")
