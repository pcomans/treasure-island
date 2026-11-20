extends RefCounted
## Building 1's concourse (owner, 2026-11-19: the one interior, "hall, mural and
## bar"), stage 1: a form study entered through the crescent's middle door group.
##
## The hall is laid out in polar terms about the circle fitted to the exact crescent
## front (runs 21-37) and runs between the radial lines of the facade's outer piers.
## West: the colonnade of slim, deep reeded wood columns on the facade's twelve pier
## lines, carrying a wood architrave and the stepped plaster drum out over the hall,
## under the high ceiling over the balcony; the balcony's solid wood parapet with the
## Deco meander rail between the columns; the tall windows in the facade's own places,
## three panes with paired mullions; under the balcony the vestibule, curtained bays
## and plain rooms (the bar's, blank for stage 3). North: the gallery crossing the
## hall's north end to the mural's start, over a low annex. East: thirteen wood-pier
## office bays with light doors, the basement stair bay and the museum's deep open
## bays, the slatted band and a blank panel where the mural goes (stage 2), stepped
## coves to the flat ceiling; amber lanterns over every other east bay. Sizes are
## production inference from the 2023 hall photos and the National Register text
## (game/resources/facades/building_1_interior.json); unphotographed parts are plain.
##
## Building1HeroModel opens the door group, cuts the exterior faces that stood inside
## this volume (cut_polygon) and returns this node beside its wall record. The node
## carries no source key of the building, so the building's fit checks see the
## exterior they always saw; it is lit by the sky's ambient light and its own glowing
## fixtures (lamps and daylight panels, DaySun night roles) over baked vertex
## shading, on RENDER_INTERIOR, which main.tscn's Sun leaves out of its light: the web
## draws no sun shadows, so the sun would otherwise light the hall through its roof. Its collision is a closed shell of
## its own, colliding from both sides; the doorway's car blocker is on the cars' ground
## layer only, so cars stay out and the player and camera pass.

const CONFIG_PATH := "res://game/resources/facades/building_1_interior.json"
const SCHEMA := "ti.building-1-interior/1"
## Render layer 6 ("interior" in project.godot): main.tscn's Sun leaves it out.
const RENDER_INTERIOR := 1 << 5
const PHYSICS_WORLD_SOLID := 1 << 0
## The cars' ground (ShorelineBuilder.PHYSICS_CAR_GROUND): cars and K-rails meet it,
## the player and the on-foot camera do not.
const PHYSICS_CAR_GROUND := 1 << 5
## Longest arc segment (radians) of a curved wall, floor or ceiling.
const ARC_STEP := 0.035
## How far a floor runs on under a curved wall it meets (m): the wall's chords and the
## floor's need not share their stations, and a chord sags up to 8 mm off its arc, so a
## floor that stopped at the wall's arc would leave a crack of the ground under it.
const FLOOR_TUCK := 0.02
## The thickness (m) of the partitions between the bays under the balcony.
const PARTITION_M := 0.15
const NIGHT_ROLE := &"night_role"
const SURFACES := ["terrazzo", "walkway", "plaster", "cream", "ceiling", "wood", "groove", "infill", "stone", "vestibule", "room", "frame", "mural_1", "mural_2", "mural_3", "mural_4", "curtain", "bronze", "brass", "glass", "door", "lamp", "daylight"]
## The floor's shade under its sheen (_shading): headroom for the bright reflections.
const FLOOR_BASE := 0.8
## The columns' and piers' dark reflections in the floor (_floor_sheen): their half
## width as a share of the member's, the share of that at full darkness (the rest
## fades out), and how far into the hall the columns' run (m).
const COLUMN_REFLECTION := 0.7
const REFLECTION_CORE := 0.65
const COLUMN_REFLECTION_M := 2.5
## Veneer strips' width (m) on the wood fronts.
const GRAIN := 0.18
## The mural's tiles, north to south: one surface each (Building1MuralLoader).
const MURALS := ["mural_1", "mural_2", "mural_3", "mural_4"]
const MURAL_LOADER := preload("res://game/scripts/world/facades/building_1_mural_loader.gd")
const HALL_REFLECTIONS := preload("res://game/scripts/world/facades/building_1_hall_reflections.gd")
## The glowing surfaces: lit by their own emission, not shaded.
const GLOWS := ["lamp", "daylight"]

static var _materials: Dictionary = {}


## The plan the hero model needs before it builds: the polar frame, the stations of
## the piers and windows, the door, and the plan polygon (world XZ) inside which no
## exterior face may stand. site: {"front": PackedVector2Array (exact crescent
## vertices), "piers": Array of Vector3 (the twelve pier anchors, north to south),
## "windows": Array of Vector3 (the eleven window centres), "window_glass": float,
## "window_y": [bottom, top], "doors": {bay: door}, door = {"anchor", "tangent",
## "normal": Vector3, "center", "half", "face", "top_y", "transom": [bottom, top]}}.
static func plan(site: Dictionary) -> Dictionary:
	var config := _json(CONFIG_PATH)
	if str(config.get("schema_version", "")) != SCHEMA:
		return {"ok": false, "message": "Building 1 interior configuration is missing or has another schema."}
	var fit := _fit_circle(site.front as PackedVector2Array)
	if fit.is_empty():
		return {"ok": false, "message": "Building 1's crescent front does not fit a circle."}
	var center := fit.center as Vector2
	var radius := float(fit.radius)
	var piers: Array[float] = []
	for anchor: Vector3 in site.piers:
		piers.append(_angle(center, anchor))
	if piers.size() != 12:
		return {"ok": false, "message": "Building 1 interior needs the crescent's twelve piers."}
	for index in range(1, piers.size()):
		if piers[index] <= piers[index - 1]:
			return {"ok": false, "message": "Building 1's crescent piers are not in order along the arc."}
	var rooms := config.rooms as Dictionary
	var door_bay := int((config.door as Dictionary).bay)
	var doors := site.doors as Dictionary
	if not doors.has(door_bay) or int(rooms.vestibule_bay) != door_bay:
		return {"ok": false, "message": "Building 1 interior's door bay has no door group in the facade."}
	var plan_m := config.plan_production_inference_m as Dictionary
	var heights := config.heights_production_inference_m as Dictionary
	var members := config.members_production_inference_m as Dictionary
	var front_in := radius + float(plan_m.front_wall_thickness)
	var column := front_in + float(plan_m.west_zone_depth)
	var east := column + float(plan_m.hall_width)
	var floor_y := float(heights.floor_y)
	var sill_y := float(heights.sill_y)
	if sill_y > floor_y:
		return {"ok": false, "message": "Building 1 interior's door sill stands above the hall's floor."}
	# The east wall's own bays: equal steps over the hall's arc.
	var east_bays := int(plan_m.east_bays)
	var east_piers: Array[float] = []
	for index in east_bays + 1:
		east_piers.append(lerpf(piers[0], piers[piers.size() - 1], float(index) / float(east_bays)))
	var result := {
		"ok": true,
		"config": config,
		"center": center,
		"radius": radius,
		"front_in": front_in,
		"column": column,
		"east": east,
		"floor_y": floor_y,
		# The door's sill and the vestibule's floor inside it, below the hall's floor.
		"sill_y": sill_y,
		"north": piers[0],
		"south": piers[piers.size() - 1],
		# The north annex under the north gallery, north of the old north line.
		"annex_north": piers[0] - deg_to_rad(float((plan_m.north_annex as Dictionary).extent_deg)),
		"piers": piers,
		"east_piers": east_piers,
		"windows": [],
		"window_y": site.window_y,
		"heights": heights,
		"members": members,
		"rooms": rooms,
		"door": (doors[door_bay] as Dictionary).duplicate(),
		"panels": [],
	}
	# Each window's light spans the angle its glass spans in the facade.
	var glass_half := float(site.window_glass) * 0.5
	for anchor: Vector3 in site.windows:
		result.windows.append({"theta": _angle(center, anchor), "half": glass_half / radius})
	# The facade's other door groups show from inside as daylight where a room opens.
	for bay: int in doors:
		if bay != door_bay:
			result.panels.append((doors[bay] as Dictionary).merged({"bay": bay}))
	var door := result.door as Dictionary
	door["inner_left"] = _frame_to_circle(door, float(door.center) - float(door.half), center, front_in)
	door["inner_right"] = _frame_to_circle(door, float(door.center) + float(door.half), center, front_in)
	if not (door.inner_left as Vector3).is_finite() or not (door.inner_right as Vector3).is_finite():
		return {"ok": false, "message": "Building 1 interior's door does not meet the vestibule wall."}
	door["theta"] = _angle(center, _frame_point(door, float(door.center), 0.0, 0.0))
	if door.theta <= result.north or door.theta >= result.south:
		return {"ok": false, "message": "Building 1 interior's door lies outside the hall."}
	var cut := _cut_polygon(result, float(plan_m.cut_margin), float(plan_m.door_corridor_reach_outside))
	if cut.is_empty() or Geometry2D.triangulate_polygon(cut).is_empty():
		return {"ok": false, "message": "Building 1 interior's plan polygon is not a simple polygon."}
	result["cut_polygon"] = cut
	return result


## The interior's node: {"ok", "node", "mesh_instances", "surfaces", "triangles",
## "static_bodies", "shapes"} as a record builder reports it.
static func build(plan: Dictionary) -> Dictionary:
	var buckets := {}
	for surface: String in SURFACES:
		buckets[surface] = _bucket()
	var shell := _bucket()
	_append_floors(plan, buckets, shell)
	_append_ceilings(plan, buckets, shell)
	_append_east_wall(plan, buckets, shell)
	_append_colonnade(plan, buckets, shell)
	_append_balcony(plan, buckets, shell)
	_append_front_wall(plan, buckets, shell)
	_append_rooms(plan, buckets, shell)
	_append_vestibule(plan, buckets, shell)
	_append_end_walls(plan, buckets, shell)
	_append_north_annex(plan, buckets, shell)
	_append_doorway(plan, buckets, shell)
	_append_fixtures(plan, buckets)
	var root := Node3D.new()
	root.name = "Building1Interior"
	# Not the building's source key: the building's fit checks keep to its exterior.
	root.set_meta("feature_kind", "interior")
	root.set_meta("interior_of_source_key", "r16681702")
	root.set_meta("interior_stage", str(plan.config.stage))
	root.set_meta("model_id", str(plan.config.model_id))
	root.set_meta("config_path", CONFIG_PATH)
	var mesh := ArrayMesh.new()
	var triangles := 0
	# The mural's placeholder and materials are this build's own (the loader swaps
	# their textures in play), so no other build ever shares a tile through them.
	var mural_entry := plan.config.palette.mural as Dictionary
	var placeholder := _mural_placeholder(mural_entry)
	for surface: String in SURFACES:
		var bucket := buckets[surface] as Dictionary
		if (bucket.indices as Array).is_empty():
			continue
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = PackedVector3Array(bucket.vertices as Array)
		arrays[Mesh.ARRAY_NORMAL] = PackedVector3Array(bucket.normals as Array)
		arrays[Mesh.ARRAY_TEX_UV] = PackedVector2Array(bucket.uvs as Array)
		if not surface in GLOWS:
			arrays[Mesh.ARRAY_COLOR] = _shading(plan, bucket, surface == "terrazzo")
		arrays[Mesh.ARRAY_INDEX] = PackedInt32Array(bucket.indices as Array)
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var index := mesh.get_surface_count() - 1
		mesh.surface_set_name(index, surface)
		if surface in MURALS:
			mesh.surface_set_material(index, _mural_material(surface, mural_entry, placeholder))
		else:
			# From the shared static _materials cache, terrazzo too: the reflections trial's floor
			# writes would reach every hall if a second one were built (they are off; one hall is built).
			mesh.surface_set_material(index, _material(surface, plan.config.palette[surface] as Dictionary))
		triangles += (bucket.indices as Array).size() / 3
	var instance := MeshInstance3D.new()
	instance.name = "Shell"
	instance.mesh = mesh
	instance.layers = RENDER_INTERIOR
	# The sun never lights it (RENDER_INTERIOR), so its shadows would be unseen work.
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(instance)
	var faces := PackedVector3Array()
	var shell_vertices := shell.vertices as Array
	for index_value: int in shell.indices as Array:
		faces.append(shell_vertices[index_value] as Vector3)
	var shape := ConcavePolygonShape3D.new()
	shape.backface_collision = true
	shape.set_faces(faces)
	var body := StaticBody3D.new()
	body.name = "Collision"
	body.collision_layer = PHYSICS_WORLD_SOLID
	body.collision_mask = 0
	body.set_meta("feature_kind", "interior")
	body.set_meta("receiver_kind", "none")
	var holder := CollisionShape3D.new()
	holder.name = "Shape"
	holder.shape = shape
	body.add_child(holder)
	root.add_child(body)
	root.add_child(_car_blocker(plan))
	# The mural's tiles load near the door after play starts, and go when far away.
	var mural := plan.config.mural as Dictionary
	var loader := MURAL_LOADER.new()
	loader.name = "MuralLoader"
	var door := plan.door as Dictionary
	loader.door = _frame_point(door, float(door.center), 0.0, float(plan.floor_y) + 1.5)
	loader.tiles = PackedStringArray(mural.tiles as Array)
	loader.placeholder = placeholder
	loader.load_radius = float(mural.load_radius)
	loader.unload_radius = float(mural.unload_radius)
	loader.unload_delay = float(mural.unload_delay)
	loader.hall = Vector4((plan.center as Vector2).x, (plan.center as Vector2).y, float(plan.front_in) - 0.5, float(plan.east) + 4.0)
	root.add_child(loader)
	root.add_child(_reflections(plan, loader.hall, buckets.terrazzo as Dictionary))
	root.set_meta("triangles", triangles)
	root.set_meta("collision_triangles", faces.size() / 3)
	return {"ok": true, "node": root, "mesh_instances": 1, "surfaces": mesh.get_surface_count(), "triangles": triangles, "static_bodies": 2, "shapes": 2}


## The hall's reflections trial (plan.config.reflections; Building1HallReflections):
## off unless its mode says, Forward+ only. It carries the floor's vertex colours
## without the baked sheen, for while the real reflections are on.
static func _reflections(plan: Dictionary, hall: Vector4, floor: Dictionary) -> Node:
	var config := plan.config.get("reflections", {}) as Dictionary
	var ssr := config.get("ssr", {}) as Dictionary
	var polish := config.get("floor", {}) as Dictionary
	var probes := config.get("probes", {}) as Dictionary
	var node := HALL_REFLECTIONS.new()
	node.name = "HallReflections"
	node.mode = str(config.get("mode", "off"))
	node.hall = hall
	node.hall_angles = Vector2(float(plan.annex_north), float(plan.south))
	# As high as the door's middle plus 16 m: the balcony and gallery, not the roof.
	node.top_y = float(plan.floor_y) + 17.5
	node.ssr = bool(ssr.get("enabled", true))
	node.ssr_max_steps = int(ssr.get("max_steps", 64))
	node.ssr_fade_in = float(ssr.get("fade_in", 0.15))
	node.ssr_fade_out = float(ssr.get("fade_out", 2.0))
	node.ssr_depth_tolerance = float(ssr.get("depth_tolerance", 0.2))
	node.floor_roughness = float(polish.get("roughness", 0.15))
	node.floor_specular = float(polish.get("specular", 0.5))
	# The floor's tint while on: one number for all channels, or [r, g, b].
	var tint: Variant = polish.get("albedo", 1.0)
	node.floor_albedo = Color(float(tint[0]), float(tint[1]), float(tint[2])) if tint is Array else Color(float(tint), float(tint), float(tint))
	node.baked_sheen = bool(polish.get("baked_sheen", true))
	var plain := PackedByteArray()
	for colour: Color in _shading(plan, floor, true, false):
		for channel: float in [colour.r, colour.g, colour.b, colour.a]:
			plain.append(int(clampf(channel * 255.0, 0.0, 255.0)))
	node.plain_floor = plain
	node.probes = bool(probes.get("enabled", false))
	node.probe_sections = int(probes.get("sections", 4))
	node.probe_intensity = float(probes.get("intensity", 1.0))
	node.probe_blend = float(probes.get("blend", 1.0))
	node.probe_capture_height = float(probes.get("capture_height", 4.0))
	# From the front wall to the deepest east bays' backs, floor to the hall's ceiling.
	var deepest := 0.0
	for bay in (plan.east_piers as Array).size() - 1:
		deepest = maxf(deepest, _east_bay_depth(plan, bay))
	node.probe_box = Vector4(float(plan.front_in), float(plan.east) + deepest, float(plan.floor_y), float(plan.floor_y) + float(plan.heights.ceiling))
	return node


# --- the shell ------------------------------------------------------------------

static func _append_floors(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var floor := buckets.terrazzo as Dictionary
	# In rings, so its baked shading can darken toward the walls and carry the polished
	# terrazzo's sheen (_floor_sheen), and every ring, the vestibule's floor and the
	# east bays' floors cut at the same angles (floor_cuts): wherever two of them meet,
	# they share their edge's vertices, so no crack opens between them. The first ring
	# runs on under the front wall (FLOOR_TUCK).
	var front_in := float(plan.front_in)
	var column := float(plan.column)
	var east := float(plan.east)
	var rings := [front_in - FLOOR_TUCK, column - float((plan.members.west_column as Array)[1]), column, column + 1.0, column + 2.2, column + 3.5, east - 3.0, east - 1.6, east - 0.6, east]
	var cuts := floor_cuts(plan)
	var vestibule := vestibule_span(plan)
	for ring in rings.size() - 1:
		# The vestibule has a floor of its own (_append_vestibule_floor).
		var spans := [Vector2(float(plan.north), vestibule.x), Vector2(vestibule.y, float(plan.south))] if ring == 0 else [Vector2(float(plan.north), float(plan.south))]
		for span: Vector2 in spans:
			_annulus_cut(plan, [floor], float(rings[ring]), float(rings[ring + 1]), span.x, span.y, y, cuts)
			_annulus(plan, [shell], float(rings[ring]), float(rings[ring + 1]), span.x, span.y, y, true)
	_append_vestibule_floor(plan, floor, shell, cuts)
	# The east bays' floors run on under their walls, the recessed bays' under their backs.
	var east_piers := plan.east_piers as Array
	for bay in east_piers.size() - 1:
		var depth := _east_bay_depth(plan, bay)
		var span := _east_bay_span(plan, bay, depth)
		_annulus_cut(plan, [floor, shell], east, east + depth + FLOOR_TUCK, span.x, span.y, y, cuts)
	# The balcony floor over the west zone, from under the front wall to the parapet's
	# back: a plain walkway (unphotographed).
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var parapet_back := column - float(members.parapet_setback) - float(members.parapet_thickness)
	_annulus(plan, [buckets.walkway, shell], front_in - FLOOR_TUCK, parapet_back, plan.north, plan.south, y + float(heights.balcony_floor), true)


## The vestibule's floor: level with the door's sill (sill_y) from under its front wall
## to sill_landing inside it, under the door's open leaves, then rising too gently to
## see to the hall's floor at the colonnade's back, through the inner doorway. In the
## doorway it starts at the sill's inner edge, on the sill's stations (_append_doorway).
static func _append_vestibule_floor(plan: Dictionary, floor: Dictionary, shell: Dictionary, cuts: Array[float]) -> void:
	var front_in := float(plan.front_in)
	var column_back := float(plan.column) - float((plan.members.west_column as Array)[1])
	var sill := float(plan.sill_y)
	var landing := front_in + float((plan.heights as Dictionary).sill_landing)
	var span := vestibule_span(plan)
	var door := door_span(plan)
	_annulus_cut(plan, [floor, shell], front_in - FLOOR_TUCK, landing, span.x, door.x, sill, cuts)
	_annulus_cut(plan, [floor, shell], front_in, landing, door.x, door.y, sill, cuts)
	_annulus_cut(plan, [floor, shell], front_in - FLOOR_TUCK, landing, door.y, span.y, sill, cuts)
	_ramp_cut(plan, [floor, shell], landing, column_back, span.x, span.y, sill, float(plan.floor_y), cuts)


## The angles every floor of the hall is cut at (_append_floors): the east piers' sides
## and middles and the windows' sides and middles, for the floor's baked shading and
## sheen; the columns' dark reflections' edges; and the sides of the east bays, the
## vestibule and its door, where other floors meet the hall's.
static func floor_cuts(plan: Dictionary) -> Array[float]:
	var cuts: Array[float] = []
	var pier_half := float((plan.members.east_pier as Array)[0]) * 0.5 / float(plan.east)
	for theta: Variant in plan.east_piers:
		cuts.append_array([float(theta) - pier_half, float(theta) - pier_half * 0.5, float(theta), float(theta) + pier_half * 0.5, float(theta) + pier_half])
	var window_half := float((plan.members.window as Dictionary).inner_width) * 0.5 / float(plan.front_in)
	for window: Dictionary in plan.windows:
		cuts.append_array([float(window.theta) - window_half, float(window.theta), float(window.theta) + window_half])
	var column_half := float((plan.members.west_column as Array)[0]) * COLUMN_REFLECTION / float(plan.column)
	for theta: Variant in plan.piers:
		for k: float in [-1.0, -REFLECTION_CORE, 0.0, REFLECTION_CORE, 1.0]:
			cuts.append(float(theta) + column_half * k)
	var east_piers := plan.east_piers as Array
	for bay in east_piers.size() - 1:
		var span := _east_bay_span(plan, bay, _east_bay_depth(plan, bay))
		cuts.append_array([span.x, span.y])
	var vestibule := vestibule_span(plan)
	var door := door_span(plan)
	cuts.append_array([vestibule.x, door.x, door.y, vestibule.y])
	return cuts


## The vestibule's sides (angles): the door bay's piers, less its walls.
static func vestibule_span(plan: Dictionary) -> Vector2:
	var piers := plan.piers as Array
	var bay := int((plan.rooms as Dictionary).vestibule_bay)
	var wall := PARTITION_M / float(plan.front_in)
	return Vector2(float(piers[bay]) + wall, float(piers[bay + 1]) - wall)


## The open door's sides where they meet the vestibule's front wall (angles).
static func door_span(plan: Dictionary) -> Vector2:
	var door := plan.door as Dictionary
	return Vector2(_angle(plan.center, door.inner_left as Vector3), _angle(plan.center, door.inner_right as Vector3))


static func _append_ceilings(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var ceiling := buckets.ceiling as Dictionary
	var column := float(plan.column)
	var column_back := column - float((members.west_column as Array)[1])
	var drum := column - float(members.drum_setback)
	var east := float(plan.east)
	var top := y + float(heights.ceiling)
	var cove := heights.cove as Array
	var run := float(heights.cove_step_run)
	# Over the balcony: the high ceiling clear of the windows' heads.
	_annulus(plan, [ceiling, shell], float(plan.front_in), column_back, plan.north, plan.south, y + float(heights.balcony_ceiling), false)
	# The colonnade's wood architrave, then the drum: plaster steps rising from it
	# out over the hall to the flat ceiling (photo 5); its back rises to the balcony's
	# ceiling.
	var architrave := heights.architrave as Array
	_arc_wall(plan, [buckets.wood], column, plan.north, plan.south, y + float(architrave[0]), y + float(architrave[1]), 1.0, {}, GRAIN)
	_arc_wall(plan, [shell], column, plan.north, plan.south, y + float(architrave[0]), y + float(architrave[1]), 1.0)
	_annulus(plan, [buckets.wood, shell], column_back, column, plan.north, plan.south, y + float(architrave[0]), false)
	_annulus(plan, [buckets.wood, shell], drum, column, plan.north, plan.south, y + float(architrave[1]), true)
	_arc_wall(plan, [buckets.wood, shell], column_back, plan.north, plan.south, y + float(architrave[0]), y + float(architrave[1]), -1.0)
	_arc_wall(plan, [ceiling, shell], column_back, plan.north, plan.south, y + float(architrave[1]), y + float(heights.balcony_ceiling), -1.0)
	var inner := drum
	var level := y + float(architrave[1])
	# The drum and the coves are the warm plaster; the flat ceiling between them is paler.
	var cream := buckets.plaster as Dictionary
	for step: Variant in members.drum_steps:
		var outer := column + float((step as Array)[0])
		var step_y := y + float((step as Array)[1])
		_arc_wall(plan, [cream, shell], inner, plan.north, plan.south, level, step_y, 1.0)
		_annulus(plan, [cream, shell], inner, outer, plan.north, plan.south, step_y, false)
		inner = outer
		level = step_y
	_arc_wall(plan, [cream, shell], inner, plan.north, plan.south, level, top, 1.0)
	# The hall's flat ceiling and the stepped coves down to the east wall.
	var edges := [east, east - run, east - 2.0 * run, east - 3.0 * run]
	for step in 3:
		_annulus(plan, [cream, shell], float(edges[step + 1]), float(edges[step]), plan.north, plan.south, y + float(cove[step]), false)
		_arc_wall(plan, [cream, shell], float(edges[step + 1]), plan.north, plan.south, y + float(cove[step]), y + float(cove[step + 1]), -1.0)
	_annulus(plan, [ceiling, shell], inner, float(edges[3]), plan.north, plan.south, top, false)


static func _append_east_wall(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var rooms := plan.rooms as Dictionary
	var east := float(plan.east)
	var head := y + float(heights.east_bay_head)
	var band := heights.east_band as Array
	var mural := heights.mural as Array
	var cove := heights.cove as Array
	var reed := float(heights.reed_height)
	var proud := float(members.reed_proud)
	var east_piers := plan.east_piers as Array
	# The slatted band over the bays, the mural panel (UVs over the whole panel, read
	# from its north end) over its run in bays, plaster beyond it, and the frieze
	# under the coves.
	_arc_wall(plan, [buckets.wood], east, plan.north, plan.south, y + float(band[0]), y + float(band[1]), -1.0, {}, GRAIN)
	_arc_wall(plan, [shell], east, plan.north, plan.south, y + float(band[0]), y + float(band[1]), -1.0)
	for level: Variant in heights.band_reeds:
		_arc_slab(plan, [buckets.groove], east - proud, east, plan.north, plan.south, y + float(level), y + float(level) + reed, false)
	var mural_span := mural_theta(plan)
	_arc_wall(plan, [buckets.cream, shell], east, plan.north, mural_span.x, y + float(mural[0]), y + float(mural[1]), -1.0)
	_append_mural(plan, buckets, shell)
	_arc_wall(plan, [buckets.cream, shell], east, mural_span.y, plan.south, y + float(mural[0]), y + float(mural[1]), -1.0)
	_arc_wall(plan, [buckets.cream, shell], east, plan.north, plan.south, y + float(mural[1]), y + float(cove[0]), -1.0)
	# Flat wood piers on stone plinths, the bays behind them: closed offices with their
	# photographed doors and small windows, the stair bay, the museum's open bays.
	var pier := members.east_pier as Array
	var plinth := float(heights.plinth)
	var plinth_proud := float(members.plinth_proud)
	for index in east_piers.size():
		var theta := float(east_piers[index])
		var south_end := index == east_piers.size() - 1
		_radial_box(plan, [buckets.wood], theta, east, east + float(pier[1]), float(pier[0]), y + plinth, head, false, south_end, false, GRAIN)
		_radial_box(plan, [shell], theta, east, east + float(pier[1]), float(pier[0]), y + plinth, head, false, south_end, false)
		var base_r := east + (float(pier[1]) - plinth_proud) * 0.5
		_box([buckets.stone, shell], _at(plan, base_r, theta, y + plinth * 0.5), _tangential(theta), _radial(theta), float(pier[0]) + 2.0 * plinth_proud, plinth, float(pier[1]) + plinth_proud)
	var doors := rooms.east_doors as Dictionary
	for bay in east_piers.size() - 1:
		var depth := _east_bay_depth(plan, bay)
		var span := _east_bay_span(plan, bay, depth)
		var back := east + depth
		_annulus(plan, [buckets.infill, shell], east, back, span.x, span.y, head, false)
		_arc_wall(plan, [buckets.infill, shell], back, span.x, span.y, y, head, -1.0)
		if depth > float(pier[1]) + 0.01:
			# A recess past the piers' backs: its own side walls.
			_radial_wall(plan, [buckets.infill, shell], span.x, east + float(pier[1]) - 0.05, back, y, head, 1.0)
			_radial_wall(plan, [buckets.infill, shell], span.y, east + float(pier[1]) - 0.05, back, y, head, -1.0)
		if bay in _ints(rooms.east_stair_bays):
			_append_stair_massing(plan, buckets, shell, span, east + float(pier[1]), back)
		elif bay in _ints(rooms.east_museum_bays):
			# Daylight through the museum room's windows, across the bay's back.
			var window := heights.museum_window as Array
			var middle := (span.x + span.y) * 0.5
			var half := (span.y - span.x) * 0.35
			var bottom := y + float(window[0])
			var top := y + float(window[1])
			_arc_wall(plan, [buckets.daylight], back - 0.02, middle - half, middle + half, bottom, top, -1.0)
			var grid := heights.museum_grid as Array
			var bar := 0.06
			for index in int(grid[0]) + 1:
				var at := lerpf(middle - half, middle + half, float(index) / float(grid[0]))
				_arc_slab(plan, [buckets.bronze], back - 0.06, back - 0.02, at - bar * 0.5 / back, at + bar * 0.5 / back, bottom, top, true)
			for index in int(grid[1]) + 1:
				var level := lerpf(bottom, top, float(index) / float(grid[1]))
				_arc_slab(plan, [buckets.bronze], back - 0.06, back - 0.02, middle - half, middle + half, level - bar * 0.5, level + bar * 0.5, false)
		elif doors.has(str(bay)):
			_append_office_front(plan, buckets, span, back, doors[str(bay)] as Dictionary)


## The mural (stage 2): one picture on the east wall from the north gallery's end to
## the south corner, on four tiles meeting at its quarter points (MURALS). Its scenes
## keep the scale they were painted at (mural.design_length less the calm ends); the
## calm sea and sky at each end (mural.calm of the picture) stretch to fill the rest
## of the wall, so no scene is squeezed or cut. UVs: u along the tile from its north
## edge, v from the mural's top to its bottom.
static func _append_mural(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var band := (plan.heights as Dictionary).mural as Array
	var bottom := y + float(band[0])
	var top := y + float(band[1])
	var east := float(plan.east)
	var span := mural_theta(plan)
	var length := east * (span.y - span.x)
	var cuts: Array[float] = [0.0, length]
	for u: float in [float(plan.config.mural.calm), 0.25, 0.5, 0.75, 1.0 - float(plan.config.mural.calm)]:
		cuts.append(_mural_s(plan, length, u))
	cuts.sort()
	for index in cuts.size() - 1:
		var s0 := cuts[index]
		var s1 := cuts[index + 1]
		if s1 - s0 < 0.001:
			continue
		var u_mid := _mural_u(plan, length, (s0 + s1) * 0.5)
		var tile := clampi(int(floor(u_mid * 4.0)), 0, 3)
		var bucket := buckets[MURALS[tile]] as Dictionary
		var stations := _stations(span.x + s0 / east, span.x + s1 / east)
		for step in stations.size() - 1:
			var a := stations[step]
			var b := stations[step + 1]
			var ua := clampf(_mural_u(plan, length, (a - span.x) * east) * 4.0 - float(tile), 0.0, 1.0)
			var ub := clampf(_mural_u(plan, length, (b - span.x) * east) * 4.0 - float(tile), 0.0, 1.0)
			_quad([bucket, shell], _at(plan, east, a, bottom), _at(plan, east, b, bottom), _at(plan, east, b, top), _at(plan, east, a, top), -_radial((a + b) * 0.5), [Vector2(ua, 1.0), Vector2(ub, 1.0), Vector2(ub, 0.0), Vector2(ua, 0.0)])


## Where along the mural (m from its north end) the picture's u falls, on a wall of
## this length: the calm ends take what the scenes, at their painted scale, leave.
static func _mural_s(plan: Dictionary, length: float, u: float) -> float:
	var calm := float(plan.config.mural.calm)
	var scenes := minf(length, float(plan.config.mural.design_length) * (1.0 - 2.0 * calm))
	var calm_m := (length - scenes) * 0.5
	if u <= calm:
		return calm_m * u / calm
	if u >= 1.0 - calm:
		return length - calm_m * (1.0 - u) / calm
	return calm_m + scenes * (u - calm) / (1.0 - 2.0 * calm)


## The picture's u at s m along the mural from its north end (the inverse of _mural_s).
static func _mural_u(plan: Dictionary, length: float, s: float) -> float:
	var calm := float(plan.config.mural.calm)
	var scenes := minf(length, float(plan.config.mural.design_length) * (1.0 - 2.0 * calm))
	var calm_m := (length - scenes) * 0.5
	if s <= calm_m:
		return calm * s / calm_m if calm_m > 0.0 else calm
	if s >= length - calm_m:
		return 1.0 - calm * (length - s) / calm_m if calm_m > 0.0 else 1.0 - calm
	return calm + (1.0 - 2.0 * calm) * (s - calm_m) / scenes


static func _append_colonnade(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# Slim, deep wood columns on stone plinths, on the facade's pier lines, floor to
	# the architrave (0.5 m by 0.8 m, photos 3 and 5). Their fine reeding is stripes of
	# baked shade on the hall and side faces, no extra geometry or texture. The north
	# one stands free at the north gallery's corner; the south one half in its end wall.
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var column := float(plan.column)
	var size := members.west_column as Array
	var width := float(size[0])
	var depth := float(size[1])
	var top := y + float(heights.column_top)
	var plinth := y + float(heights.plinth)
	var plinth_proud := float(members.plinth_proud)
	var reeds := members.column_reeds as Dictionary
	var shade := float(reeds.shade)
	var piers := plan.piers as Array
	for index in piers.size():
		var theta := float(piers[index])
		var south_end := index == piers.size() - 1
		var tangent := _tangential(theta)
		var radial := _radial(theta)
		var corner := func(lateral: float, r: float, height: float) -> Vector3:
			return _at(plan, r, theta, height) + tangent * lateral
		var left := -width * 0.5
		var right := 0.0 if south_end else width * 0.5
		var back := column - depth
		# Hall face, in reeds.
		var count := int(reeds.hall)
		for reed in count:
			var a := lerpf(-width * 0.5, width * 0.5, float(reed) / float(count))
			var b := minf(right, lerpf(-width * 0.5, width * 0.5, float(reed + 1) / float(count)))
			if b - a < 0.001:
				break
			_quad([buckets.wood, shell], corner.call(a, column, plinth), corner.call(b, column, plinth), corner.call(b, column, top), corner.call(a, column, top), radial, [], 1.0 if reed % 2 == 0 else shade)
		# Side faces, in reeds; the back face plain.
		var side_count := int(reeds.side)
		for side: float in [-1.0, 1.0]:
			if side > 0.0 and south_end:
				continue
			var lateral := side * width * 0.5
			for reed in side_count:
				var r0 := lerpf(back, column, float(reed) / float(side_count))
				var r1 := lerpf(back, column, float(reed + 1) / float(side_count))
				_quad([buckets.wood, shell], corner.call(lateral, r0, plinth), corner.call(lateral, r1, plinth), corner.call(lateral, r1, top), corner.call(lateral, r0, top), tangent * side, [], 1.0 if reed % 2 == 0 else shade)
		_quad([buckets.wood, shell], corner.call(right, back, plinth), corner.call(left, back, plinth), corner.call(left, back, top), corner.call(right, back, top), -radial)
		_box([buckets.stone, shell], _at(plan, column - depth * 0.5, theta, (y + plinth) * 0.5), tangent, radial, width + 2.0 * plinth_proud, plinth - y, depth + 2.0 * plinth_proud)


static func _append_balcony(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# Between the columns: the lintel over the ground-floor openings, the reeded wood
	# fascia, the solid wood parapet and on it the bronze Deco meander rail. These run
	# the whole arc; the columns stand in front of them.
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var column := float(plan.column)
	var column_back := column - float((members.west_column as Array)[1])
	var fascia_r := column - float(members.fascia_setback)
	var parapet_front := column - float(members.parapet_setback)
	var parapet_back := parapet_front - float(members.parapet_thickness)
	var opening := y + float(heights.west_opening_head)
	var fascia := heights.fascia as Array
	var parapet := heights.parapet as Array
	var railing := heights.railing as Array
	var reed := float(heights.reed_height)
	var proud := float(members.reed_proud)
	_annulus(plan, [buckets.wood, shell], column_back, fascia_r, plan.north, plan.south, opening, false)
	_arc_wall(plan, [buckets.wood], fascia_r, plan.north, plan.south, opening, y + float(fascia[1]), 1.0, {}, GRAIN)
	_arc_wall(plan, [shell], fascia_r, plan.north, plan.south, opening, y + float(fascia[1]), 1.0)
	for level: Variant in heights.fascia_reeds:
		_arc_slab(plan, [buckets.groove], fascia_r, fascia_r + proud, plan.north, plan.south, y + float(level), y + float(level) + reed, false)
	_annulus(plan, [buckets.wood, shell], parapet_front, fascia_r, plan.north, plan.south, y + float(parapet[0]), true)
	_arc_wall(plan, [buckets.wood], parapet_front, plan.north, plan.south, y + float(parapet[0]), y + float(parapet[1]), 1.0, {}, GRAIN)
	_arc_wall(plan, [shell], parapet_front, plan.north, plan.south, y + float(parapet[0]), y + float(parapet[1]), 1.0)
	_arc_wall(plan, [buckets.wood, shell], parapet_back, plan.north, plan.south, y + float(parapet[0]), y + float(parapet[1]), -1.0)
	_annulus(plan, [buckets.wood, shell], parapet_back, parapet_front, plan.north, plan.south, y + float(parapet[1]), true)
	_annulus(plan, [buckets.wood, shell], parapet_back, parapet_front, plan.north, plan.south, y + float(parapet[0]), false)
	# The rail: bronze rails and the meander for the eye, and in their plane a solid
	# guard to the rail's top: the walk cannot step over it (no step-up in the stock
	# controller), and a player who lands on it stands on the rail, not on air.
	var line := (parapet_front + parapet_back) * 0.5
	_arc_wall(plan, [shell], line, plan.north, plan.south, y + float(railing[0]), y + float(railing[1]), 1.0)
	var bar := members.rail_bar as Array
	var meander := members.meander as Dictionary
	var piers := plan.piers as Array
	var width := float((members.west_column as Array)[0])
	for bay in piers.size() - 1:
		var from := float(piers[bay]) + width * 0.5 / line
		var to := float(piers[bay + 1]) - width * 0.5 / line
		_arc_bar(plan, buckets.bronze as Dictionary, line, from, to, y + float(railing[0]) + float(bar[1]) * 0.5, float(bar[0]), float(bar[1]))
		_arc_bar(plan, buckets.bronze as Dictionary, line, from, to, y + float(railing[1]) - float(bar[1]) * 0.5, float(bar[0]), float(bar[1]))
		_append_meander(plan, buckets.bronze as Dictionary, line, from, to, y + float(railing[0]) + float(bar[1]), y + float(railing[1]) - float(bar[1]), meander)


## A square-wave key between two rails: up, across high, down, across low, with
## short posts tying its low runs to the bottom rail and its high runs to the top.
static func _append_meander(plan: Dictionary, bucket: Dictionary, r: float, from: float, to: float, bottom: float, top: float, meander: Dictionary) -> void:
	var units := maxi(1, roundi((to - from) * r / float(meander.unit)))
	var step := (to - from) / float(units)
	var bar := float(meander.bar)
	var high := lerpf(bottom, top, float(meander.high))
	var low := lerpf(bottom, top, float(meander.low))
	for unit in units:
		var a := from + step * float(unit)
		var b := a + step * 0.5
		var c := a + step
		_meander_post(plan, bucket, r, a, low, high, bar)
		_meander_run(plan, bucket, r, a, b, high, bar)
		_meander_post(plan, bucket, r, b, low, high, bar)
		_meander_run(plan, bucket, r, b, c, low, bar)
		_meander_post(plan, bucket, r, (a + b) * 0.5, high, top, bar)
		_meander_post(plan, bucket, r, (b + c) * 0.5, bottom, low, bar)
	_meander_post(plan, bucket, r, to, low, high, bar)


static func _meander_post(plan: Dictionary, bucket: Dictionary, r: float, theta: float, bottom: float, top: float, bar: float) -> void:
	_box([bucket], _at(plan, r, theta, (bottom + top) * 0.5), _tangential(theta), _radial(theta), bar, top - bottom + bar, bar)


static func _meander_run(plan: Dictionary, bucket: Dictionary, r: float, from: float, to: float, y: float, bar: float) -> void:
	var a := _at(plan, r, from, y)
	var b := _at(plan, r, to, y)
	_box([bucket], (a + b) * 0.5, b - a, _radial((from + to) * 0.5), a.distance_to(b), bar, bar)


static func _append_front_wall(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# Above the balcony: the inside of the crescent in cream plaster, its tall windows
	# deep in white reveals at the facade's window centres, and a dentil cornice under
	# the balcony's ceiling.
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var front_in := float(plan.front_in)
	var cornice := heights.cornice as Array
	var wall_bottom := y + float(heights.balcony_floor)
	var wall_top := y + float(cornice[0])
	var window_y := plan.window_y as Array
	var style := members.window as Dictionary
	var half := float(style.inner_width) * 0.5 / front_in
	var bottom := float(window_y[0])
	var top := minf(float(window_y[1]), wall_top - float(style.surround))
	var cream := buckets.cream as Dictionary
	# The wall in pieces round the window openings.
	var edge := float(plan.north)
	for window: Dictionary in plan.windows:
		var theta := float(window.theta)
		if theta - half < float(plan.north) or theta + half > float(plan.south):
			continue
		_arc_wall(plan, [cream, shell], front_in, edge, theta - half, wall_bottom, wall_top, 1.0)
		_arc_wall(plan, [cream, shell], front_in, theta - half, theta + half, wall_bottom, bottom, 1.0)
		_arc_wall(plan, [cream, shell], front_in, theta - half, theta + half, top, wall_top, 1.0)
		_append_window(plan, buckets, shell, theta, half, bottom, top, style)
		edge = theta + half
	_arc_wall(plan, [cream, shell], front_in, edge, plan.south, wall_bottom, wall_top, 1.0)
	_arc_slab(plan, [cream, shell], front_in, front_in + 0.25, plan.north, plan.south, wall_top, y + float(cornice[1]), false)
	# Dentils under the cornice.
	var dentils := members.dentils as Dictionary
	var pitch := float(dentils.pitch) / front_in
	var count := int(floor((float(plan.south) - float(plan.north)) / pitch))
	var depth := float(dentils.depth)
	for index in count:
		var theta := float(plan.north) + (float(index) + 0.5) * pitch
		var at := _at(plan, front_in + depth * 0.5, theta, wall_top - float(dentils.height) * 0.5)
		_box([cream], at, _tangential(theta), _radial(theta), float(dentils.width), float(dentils.height), depth)


## A tall window seen from inside (photo 3): an opening narrower than the facade's
## glass, at its centre, in a deep white reveal with a white surround in the cream
## wall; three tall panes split by paired thin mullions, five thin glazing bars with
## small squares where they cross the mullions, on daylight. The glass closes the
## shell.
static func _append_window(plan: Dictionary, buckets: Dictionary, shell: Dictionary, theta: float, half: float, bottom: float, top: float, style: Dictionary) -> void:
	var front_in := float(plan.front_in)
	var glass := front_in - float(style.reveal_depth)
	var bars := glass + float(style.bar_front)
	var surround := float(style.surround)
	var proud := float(style.surround_proud)
	var from := theta - half
	var to := theta + half
	var white := buckets.frame as Dictionary
	_arc_wall(plan, [buckets.daylight, shell], glass, from, to, bottom, top, 1.0)
	# The reveal: jambs, sill and head from the wall's face back to the glass.
	_radial_wall(plan, [white, shell], from, glass, front_in, bottom, top, 1.0)
	_radial_wall(plan, [white, shell], to, glass, front_in, bottom, top, -1.0)
	_annulus(plan, [white, shell], glass, front_in, from, to, bottom, true)
	_annulus(plan, [white, shell], glass, front_in, from, to, top, false)
	# The surround on the wall's face.
	var s_theta := surround / front_in
	_arc_slab(plan, [white], front_in, front_in + proud, from - s_theta, from, bottom - surround, top + surround, true)
	_arc_slab(plan, [white], front_in, front_in + proud, to, to + s_theta, bottom - surround, top + surround, true)
	_arc_slab(plan, [white], front_in, front_in + proud, from, to, bottom - surround, bottom, false)
	_arc_slab(plan, [white], front_in, front_in + proud, from, to, top, top + surround, false)
	# The frame round the glass.
	var frame := float(style.frame)
	var f_theta := frame / glass
	_arc_slab(plan, [white], glass, bars, from, from + f_theta, bottom, top, true)
	_arc_slab(plan, [white], glass, bars, to - f_theta, to, bottom, top, true)
	_arc_slab(plan, [white], glass, bars, from, to, bottom, bottom + frame, false)
	_arc_slab(plan, [white], glass, bars, from, to, top - frame, top, false)
	# Paired thin mullions between the panes; bars across with a small square at each
	# pair of mullions.
	var panes := int(style.panes)
	var mullion := float(style.mullion) / glass
	var gap := float(style.mullion_gap) / glass
	var bar := float(style.bar)
	var square := float(style.inset_square)
	var pairs: Array[float] = []
	for index in range(1, panes):
		var at := lerpf(from, to, float(index) / float(panes))
		pairs.append(at)
		for side: float in [-1.0, 1.0]:
			var centre := at + side * (gap + mullion) * 0.5
			_arc_slab(plan, [white], glass, bars, centre - mullion * 0.5, centre + mullion * 0.5, bottom + frame, top - frame, true)
	var count := int(style.bars)
	for index in range(1, count + 1):
		var level := lerpf(bottom, top, float(index) / float(count + 1))
		_arc_slab(plan, [white], glass, bars, from + f_theta, to - f_theta, level - bar * 0.5, level + bar * 0.5, false)
		for at: float in pairs:
			var w := square * 0.5 / glass
			for side: float in [-1.0, 1.0]:
				_arc_slab(plan, [white], glass, bars, at + side * w - mullion * 0.5, at + side * w + mullion * 0.5, level - square * 0.5, level + square * 0.5, true)
			_arc_slab(plan, [white], glass, bars, at - w, at + w, level + square * 0.5 - bar, level + square * 0.5, false)
			_arc_slab(plan, [white], glass, bars, at - w, at + w, level - square * 0.5, level - square * 0.5 + bar, false)


static func _append_rooms(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# Under the balcony, between the columns: plain rooms open to the hall (the north
	# room; the bar's blank room for stage 3) with wood ceilings and dim walls, and
	# closed bays behind red velvet curtains.
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var rooms := plan.rooms as Dictionary
	var column := float(plan.column)
	var front_in := float(plan.front_in)
	var column_back := column - float((members.west_column as Array)[1])
	var ceiling := y + float(heights.balcony_floor) - float(heights.balcony_slab)
	var opening := y + float(heights.west_opening_head)
	var piers := plan.piers as Array
	var wall := PARTITION_M
	# The lintel's back over each room, the rooms' fronts, ceilings and partitions.
	for group: Array in [_ints(rooms.room_bays), _ints(rooms.bar_bays)]:
		if group.is_empty():
			continue
		var from := float(piers[int(group.min())])
		var to := float(piers[int(group.max()) + 1])
		var inner_from := from + (0.0 if is_equal_approx(from, float(plan.north)) else wall / front_in)
		var inner_to := to - (0.0 if is_equal_approx(to, float(plan.south)) else wall / front_in)
		_annulus(plan, [buckets.wood, shell], front_in, column_back, inner_from, inner_to, ceiling, false)
		_arc_wall(plan, [buckets.room, shell], front_in, inner_from, inner_to, y, ceiling, 1.0)
		_arc_wall(plan, [buckets.room, shell], column_back, inner_from, inner_to, opening, ceiling, -1.0)
		if not is_equal_approx(from, float(plan.north)):
			_radial_wall(plan, [buckets.room, shell], inner_from, front_in, column_back, y, ceiling, 1.0)
		if not is_equal_approx(to, float(plan.south)):
			_radial_wall(plan, [buckets.room, shell], inner_to, front_in, column_back, y, ceiling, -1.0)
		# The facade's other door groups show from inside as glazed daylight.
		for panel: Dictionary in plan.panels:
			var middle := _angle(plan.center, _frame_point(panel, float(panel.center), 0.0, 0.0))
			if middle <= inner_from or middle >= inner_to:
				continue
			_append_door_glass(plan, buckets, middle, float(panel.half), y + 0.02, float(panel.top_y), minf(float((panel.transom as Array)[1]), ceiling - 0.05))
	# Curtained bays: velvet hung between the columns, before the bar's room or a dim
	# wall; closed bays: the dim wall alone.
	var curtain := members.curtain as Dictionary
	var width := float((members.west_column as Array)[0])
	var line := column - float(curtain.setback)
	var in_rooms := _ints(rooms.room_bays) + _ints(rooms.bar_bays)
	for bay: int in _ints(rooms.curtained_bays) + _ints(rooms.closed_bays):
		var from := float(piers[bay]) + width * 0.5 / line
		var to := float(piers[bay + 1]) - width * 0.5 / line
		if not bay in in_rooms:
			_arc_wall(plan, [buckets.plaster if bay in _ints(rooms.closed_bays) else buckets.room, shell], line - 0.15, from, to, y, opening, 1.0)
		if bay in _ints(rooms.curtained_bays):
			_arc_wall(plan, [shell], line + float(curtain.depth), from, to, y, opening, 1.0)
			_append_curtain(plan, buckets.curtain as Dictionary, line, from, to, y, opening - 0.05, curtain)


static func _append_curtain(plan: Dictionary, bucket: Dictionary, r: float, from: float, to: float, bottom: float, top: float, curtain: Dictionary) -> void:
	var pleats := maxi(2, roundi((to - from) * r / float(curtain.pleat)))
	var depth := float(curtain.depth)
	for index in pleats * 2:
		var a := lerpf(from, to, float(index) / float(pleats * 2))
		var b := lerpf(from, to, float(index + 1) / float(pleats * 2))
		var ra := r + (depth if index % 2 == 1 else 0.0)
		var rb := r + (depth if index % 2 == 0 else 0.0)
		var pa := _at(plan, ra, a, 0.0)
		var pb := _at(plan, rb, b, 0.0)
		var along := pb - pa
		var normal := Vector3(along.z, 0.0, -along.x).normalized()
		if normal.dot(_radial((a + b) * 0.5)) < 0.0:
			normal = -normal
		# Both faces: the bar's room sees its curtains from behind.
		_quad([bucket], _lifted(pa, bottom), _lifted(pb, bottom), _lifted(pb, top), _lifted(pa, top), normal)
		_quad([bucket], _lifted(pa, bottom), _lifted(pb, bottom), _lifted(pb, top), _lifted(pa, top), -normal)


static func _append_vestibule(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# The vestibule (plain stone, its finish unphotographed): its ceiling under the
	# balcony, the open front door and the inner doorway to the hall on the same axis.
	# Its floor rises from the door's sill to the hall's (_append_vestibule_floor), so
	# its walls stand from the sill's height; the inner doorway's hall face from the hall's.
	var y := float(plan.floor_y)
	var sill := float(plan.sill_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var column := float(plan.column)
	var front_in := float(plan.front_in)
	var column_back := column - float((members.west_column as Array)[1])
	var ceiling := y + float(heights.balcony_floor) - float(heights.balcony_slab)
	var opening := y + float(heights.west_opening_head)
	var stone := buckets.vestibule as Dictionary
	var door := plan.door as Dictionary
	var span := vestibule_span(plan)
	var from := span.x
	var to := span.y
	# Its back wall stands just behind the columns' backs, so they don't show in it.
	var inner := column_back - 0.05
	var door_top := float(door.top_y)
	_annulus(plan, [stone, shell], front_in, inner, from, to, ceiling, false)
	_radial_wall(plan, [stone, shell], from, front_in, inner, sill, ceiling, 1.0)
	_radial_wall(plan, [stone, shell], to, front_in, inner, sill, ceiling, -1.0)
	var opened := door_span(plan)
	var left := opened.x
	var right := opened.y
	_arc_wall(plan, [stone, shell], front_in, from, left, sill, ceiling, 1.0)
	_arc_wall(plan, [stone, shell], front_in, right, to, sill, ceiling, 1.0)
	_arc_wall(plan, [stone, shell], front_in, left, right, door_top, ceiling, 1.0)
	var transom := door.transom as Array
	_append_door_glass(plan, buckets, (left + right) * 0.5, (right - left) * 0.5 * front_in - 0.02, float(transom[0]), float(transom[0]), minf(float(transom[1]), ceiling - 0.05))
	# The inner doorway: radial sides at one angle each, so both faces of the wall
	# and its reveal meet on the same lines.
	var axis := float(door.theta)
	var half := float(door.half) / inner
	_arc_wall(plan, [stone, shell], inner, from, axis - half, sill, ceiling, -1.0)
	_arc_wall(plan, [stone, shell], inner, axis + half, to, sill, ceiling, -1.0)
	_arc_wall(plan, [stone, shell], inner, axis - half, axis + half, door_top, ceiling, -1.0)
	var hall_side := column_back
	_arc_wall(plan, [stone, shell], hall_side, from, axis - half, y, opening, 1.0)
	_arc_wall(plan, [stone, shell], hall_side, axis + half, to, y, opening, 1.0)
	_arc_wall(plan, [stone, shell], hall_side, axis - half, axis + half, door_top, opening, 1.0)
	_radial_wall(plan, [stone, shell], axis - half, inner, hall_side, sill, door_top, 1.0)
	_radial_wall(plan, [stone, shell], axis + half, inner, hall_side, sill, door_top, -1.0)
	_annulus(plan, [stone, shell], inner, hall_side, axis - half, axis + half, door_top, false)


static func _append_end_walls(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var drum := float(plan.column) - float(members.drum_setback)
	var column_back := float(plan.column) - float((members.west_column as Array)[1])
	var back := float(plan.east) + float((members.east_pier as Array)[1])
	var annex := plan.config.plan_production_inference_m.north_annex as Dictionary
	var cream := buckets.cream as Dictionary
	# Plain cream cross-sections (no photograph shows either end wall): at the south
	# end the balcony zone to its high ceiling and the hall to its own; at the north
	# end the balcony zone's, and over the north gallery the cream return from the
	# gallery's ceiling up to the hall's ceiling and the drum.
	var south := float(plan.south)
	_radial_wall(plan, [cream, shell], south, float(plan.front_in), drum, y, y + float(heights.balcony_ceiling), -1.0)
	_radial_wall(plan, [cream, shell], south, drum, back, y, y + float(heights.ceiling), -1.0)
	var north := float(plan.north)
	var return_bottom := y + float(annex.height)
	_radial_wall(plan, [cream, shell], north, float(plan.front_in), column_back, y, y + float(heights.balcony_ceiling), 1.0)
	_radial_wall(plan, [cream, shell], north, column_back, drum, return_bottom, y + float(heights.balcony_ceiling), 1.0)
	_radial_wall(plan, [cream, shell], north, drum, back, return_bottom, y + float(heights.ceiling), 1.0)


## North of the old north line: the floor the north view is taken from (photo 5's
## camera), under a plain gallery, inferred (no dated photo shows it: owner's shot
## list): it crosses the hall's north end from the colonnade's north column and, as
## photo 4 shows the balcony do, curves into the east wall below the mural's start.
## Its floor and soffit, a plain wood front and top rail, the annex's low ceiling under
## the two-storey roof, and plain dim walls.
static func _append_north_annex(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var annex := plan.config.plan_production_inference_m.north_annex as Dictionary
	var north := float(plan.north)
	var far := float(plan.annex_north)
	var column := float(plan.column)
	var west := column - float((members.west_column as Array)[1])
	var east := float(plan.east)
	var top := y + float(annex.height)
	var soffit := y + float(heights.west_opening_head)
	var gallery := y + float(heights.balcony_floor)
	var pier_half := float((members.east_pier as Array)[0]) * 0.5 / east
	# Warm like the hall (cream walls, a wood soffit), not dark holes.
	var cream := buckets.cream as Dictionary
	# The floor runs on under the east wall, whose chords are not the floor's.
	_annulus(plan, [buckets.terrazzo, shell], west, east + FLOOR_TUCK, far, north, y, true)
	_annulus(plan, [buckets.wood, shell], west, east, far, north, soffit, false)
	_annulus(plan, [buckets.walkway, shell], west, east, far, north, gallery, true)
	_annulus(plan, [cream, shell], west, east, far, north, top, false)
	_radial_wall(plan, [cream, shell], far, west, east, y, top, 1.0)
	_arc_wall(plan, [cream, shell], west, far, north, y, top, 1.0)
	_arc_wall(plan, [cream, shell], east, far, north - pier_half, y, top, -1.0)
	# Over the north east pier, whose side closes the corner below its head.
	_arc_wall(plan, [cream, shell], east, north - pier_half, north, y + float(heights.east_bay_head), top, -1.0)
	# The gallery's front: along the north line, then a quarter circle into the wall.
	var fillet := float(annex.gallery_fillet)
	var corner := _at(plan, east, north, 0.0)
	var e_r := _radial(north)
	var e_t := _tangential(north)
	var centre := corner - e_r * fillet + e_t * fillet
	var path: Array[Vector3] = [_at(plan, column, north, 0.0)]
	var normals: Array[Vector3] = [e_t]
	var steps := 8
	for index in steps + 1:
		var phi := PI * 0.5 * float(index) / float(steps)
		path.append(centre + (-e_t * cos(phi) + e_r * sin(phi)) * fillet)
		normals.append((centre - path[path.size() - 1]).normalized())
	# The floor and soffit over the corner the curve leaves.
	for index in range(1, path.size() - 1):
		_triangle([buckets.walkway, shell], _lifted(corner, gallery), _lifted(path[index], gallery), _lifted(path[index + 1], gallery), Vector3.UP)
		_triangle([buckets.wood, shell], _lifted(corner, soffit), _lifted(path[index], soffit), _lifted(path[index + 1], soffit), Vector3.DOWN)
	var railing := heights.railing as Array
	var bar := members.rail_bar as Array
	# Its collision guard rises from the gallery's floor to the annex's ceiling: the
	# inferred gallery is seen over its rail, never entered, and leaves no ledge to
	# perch on under that ceiling (a guard to rail height would leave an opening lower
	# than a player, whose top edge held a player wedged against the ceiling's edge).
	var guard := top
	var rail := y + float(railing[1]) - float(bar[1]) * 0.5
	var since_post := 0.0
	for index in path.size() - 1:
		var a := path[index]
		var b := path[index + 1]
		var n := ((normals[index] + normals[index + 1]) * 0.5).normalized() if index > 0 else e_t
		_quad([shell], _lifted(a, soffit), _lifted(b, soffit), _lifted(b, gallery), _lifted(a, gallery), n)
		_quad([shell], _lifted(a, gallery), _lifted(b, gallery), _lifted(b, guard), _lifted(a, guard), n)
		var length := a.distance_to(b)
		var edges := _veneer(length, GRAIN, float(index) * 31.0)
		for strip in edges.size() - 1:
			var p := a.lerp(b, edges[strip])
			var q := a.lerp(b, edges[strip + 1])
			_quad([buckets.wood], _lifted(p, soffit), _lifted(q, soffit), _lifted(q, gallery), _lifted(p, gallery), n, [], _grain_tint(float(index * 31 + strip)))
		_box([buckets.bronze], _lifted((a + b) * 0.5, rail) - n * 0.05, b - a, n, length, float(bar[1]), float(bar[0]))
		since_post += length
		if since_post >= 1.5 or index == 0:
			since_post = 0.0
			_box([buckets.bronze], _lifted(a, (gallery + rail) * 0.5) - n * 0.05, b - a, n, float(bar[0]), rail - gallery, float(bar[0]))


static func _append_doorway(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	# The opened door group's reveal, from the facade's dark border to the vestibule
	# wall: sides, head and a level stone sill, its front a riser down to the
	# forecourt's paving; under it, for the feet, a hidden slope over the same step.
	# The sides and head start at the dark border's back, which frames the opening
	# outside; the sill runs to the border's front and on to its riser. The sill is the
	# door's own height (sill_y), below the hall's floor, and meets the vestibule's floor
	# on its stations (_append_vestibule_floor).
	var door := plan.door as Dictionary
	var y := float(plan.sill_y)
	var heights := plan.heights as Dictionary
	var top := float(door.top_y)
	var left := float(door.center) - float(door.half)
	var right := float(door.center) + float(door.half)
	var back := float(door.back)
	var front := float(door.face) + 0.06
	var inner_left := door.inner_left as Vector3
	var inner_right := door.inner_right as Vector3
	var stone := buckets.stone as Dictionary
	var tangent := door.tangent as Vector3
	var normal := door.normal as Vector3
	var side_left := _frame_point(door, left, back, 0.0)
	var side_right := _frame_point(door, right, back, 0.0)
	_quad([buckets.vestibule, shell], _lifted(side_left, y), _lifted(inner_left, y), _lifted(inner_left, top), _lifted(side_left, top), tangent)
	_quad([buckets.vestibule, shell], _lifted(inner_right, y), _lifted(side_right, y), _lifted(side_right, top), _lifted(inner_right, top), -tangent)
	_doorway_strip(plan, [buckets.vestibule, shell], side_left, side_right, inner_left, inner_right, top, Vector3.DOWN)
	var outer_left := _frame_point(door, left, front, 0.0)
	var outer_right := _frame_point(door, right, front, 0.0)
	var opened := door_span(plan)
	_doorway_strip(plan, [stone, shell], outer_left, outer_right, inner_left, inner_right, y, Vector3.UP, _cut_stations(opened.x, opened.y, floor_cuts(plan)))
	# The sill's front: a 45-degree bevel down to the forecourt's paving, the same
	# surface seen and walked (a slope the stock player takes as floor).
	var bevel := float(heights.threshold_bevel)
	var foot_left := _frame_point(door, left, front + bevel, 0.0)
	var foot_right := _frame_point(door, right, front + bevel, 0.0)
	var slope := (normal + Vector3.UP).normalized()
	_quad([stone, shell], _lifted(foot_left, y - bevel), _lifted(foot_right, y - bevel), _lifted(outer_right, y), _lifted(outer_left, y), slope)
	_triangle([stone], _lifted(foot_left, y - bevel - 0.03), _lifted(outer_left, y), _lifted(outer_left, y - bevel - 0.03), -tangent)
	_triangle([stone], _lifted(outer_right, y - bevel - 0.03), _lifted(outer_right, y), _lifted(foot_right, y - bevel - 0.03), tangent)
	_append_door_leaves(plan, buckets, shell)


## The group's three bronze leaves stood open, swung in against the reveal sides:
## two folded together on the left, one on the right. Glazed bronze in the facade;
## here the frames (the glass is clear), solid for the player.
static func _append_door_leaves(plan: Dictionary, buckets: Dictionary, shell: Dictionary) -> void:
	var door := plan.door as Dictionary
	var leaf := plan.members.door_leaf as Dictionary
	# On the sill's level, which runs on inside under them (sill_landing).
	var y := float(plan.sill_y)
	var top := float(door.top_y)
	var half := float(door.half)
	var hinge := float(door.face) + 0.06
	var width := half * 2.0 / 3.0
	var thickness := float(leaf.thickness)
	var inset := float(leaf.inset)
	var tangent := door.tangent as Vector3
	var normal := door.normal as Vector3
	var stile := float(leaf.stile)
	var rail := float(leaf.rail)
	var lefts := [float(door.center) - half + inset, float(door.center) - half + inset + thickness + 0.01]
	var places: Array = []
	for lateral: float in lefts:
		places.append(lateral + thickness * 0.5)
	places.append(float(door.center) + half - inset - thickness * 0.5)
	for lateral: float in places:
		# The leaf lies in the plane of the normal and up, from the hinge inward.
		var hinge_point := _frame_point(door, lateral, hinge, 0.0)
		var middle := hinge_point - normal * width * 0.5
		var bronze := buckets.bronze as Dictionary
		_box([shell], Vector3(middle.x, (y + top) * 0.5, middle.z), normal, tangent, width, top - y, thickness)
		for edge: float in [stile * 0.5, width - stile * 0.5]:
			var at := hinge_point - normal * edge
			_box([bronze], Vector3(at.x, (y + top) * 0.5, at.z), normal, tangent, stile, top - y, thickness)
		var rails := [y + float((leaf.rails as Array)[0]) * 0.5, y + float((leaf.rails as Array)[1]), top - rail * 0.5]
		var heights := [float((leaf.rails as Array)[0]), rail, rail]
		for index in rails.size():
			_box([bronze], Vector3(middle.x, float(rails[index]), middle.z), normal, tangent, width - stile * 2.0, float(heights[index]), thickness * 0.8)
		# Dark glass between the rails, as the facade's door glass.
		var glass_bottom := y + float((leaf.rails as Array)[0])
		var glass_top := top - rail
		_box([buckets.glass], Vector3(middle.x, (glass_bottom + glass_top) * 0.5, middle.z), normal, tangent, width - stile * 2.0, glass_top - glass_bottom, thickness * 0.4)


## A door group's glazing seen from inside, on the front wall's inner face: daylight
## behind the group's bronze bars (its leaves' stiles, the door head and the transom's
## middle rail), as the facade draws them.
static func _append_door_glass(plan: Dictionary, buckets: Dictionary, middle: float, half_m: float, bottom: float, door_top: float, top: float) -> void:
	var front_in := float(plan.front_in)
	var panel := front_in + float(plan.members.window_panel_front)
	var half := half_m / front_in
	_arc_wall(plan, [buckets.daylight], panel, middle - half, middle + half, bottom, top, 1.0)
	var bar := 0.1 / front_in
	var bronze := buckets.bronze as Dictionary
	for leaf in 4:
		var at := lerpf(middle - half, middle + half, float(leaf) / 3.0)
		_arc_slab(plan, [bronze], panel, panel + 0.04, maxf(middle - half, at - bar * 0.5), minf(middle + half, at + bar * 0.5), bottom, top, true)
	for level: float in [bottom, door_top, (door_top + top) * 0.5, top]:
		if level < bottom or level > top:
			continue
		_arc_slab(plan, [bronze], panel, panel + 0.04, middle - half, middle + half, maxf(bottom, level - 0.05), minf(top, level + 0.05), false)


## A horizontal strip at y from a straight outer edge to the vestibule wall's arc,
## so the head and threshold meet the curved wall without a sliver: on stations (the
## angles from inner_a's to inner_b's) where a floor meets the strip's arc on them,
## else in even steps.
static func _doorway_strip(plan: Dictionary, targets: Array, outer_a: Vector3, outer_b: Vector3, inner_a: Vector3, inner_b: Vector3, y: float, normal: Vector3, stations := PackedFloat64Array()) -> void:
	var center := plan.center as Vector2
	var radius := float(plan.front_in)
	if stations.is_empty():
		stations = _stations(_angle(center, inner_a), _angle(center, inner_b))
	var count := stations.size() - 1
	var span := stations[count] - stations[0]
	for index in count:
		var o0 := outer_a.lerp(outer_b, (stations[index] - stations[0]) / span)
		var o1 := outer_a.lerp(outer_b, (stations[index + 1] - stations[0]) / span)
		var i0 := inner_a if index == 0 else _at(plan, radius, stations[index], 0.0)
		var i1 := inner_b if index == count - 1 else _at(plan, radius, stations[index + 1], 0.0)
		_quad(targets, _lifted(o0, y), _lifted(o1, y), _lifted(i1, y), _lifted(i0, y), normal)


static func _append_fixtures(plan: Dictionary, buckets: Dictionary) -> void:
	# Lanterns (visual only): the hall's big amber ones over every other east bay on
	# the centre line and smaller ones over the balcony before the windows.
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var members := plan.members as Dictionary
	var rooms := plan.rooms as Dictionary
	var column := float(plan.column)
	var column_back := column - float((members.west_column as Array)[1])
	var rod := float(members.lamp_rod)
	var east_piers := plan.east_piers as Array
	var hall_r := (column + float(plan.east)) * 0.5
	var hall_lamp := heights.hall_lamp as Array
	for bay: int in _ints(rooms.hall_lantern_bays):
		var theta := (float(east_piers[bay]) + float(east_piers[bay + 1])) * 0.5
		_lantern(plan, buckets, hall_r, theta, members.hall_lantern as Dictionary, y + float(hall_lamp[0]), y + float(hall_lamp[1]), y + float(heights.ceiling), rod)
	var balcony_r := (float(plan.front_in) + column_back) * 0.5
	var balcony_lamp := heights.balcony_lamp as Array
	for window: Dictionary in plan.windows:
		_lantern(plan, buckets, balcony_r, float(window.theta), members.balcony_lantern as Dictionary, y + float(balcony_lamp[0]), y + float(balcony_lamp[1]), y + float(heights.balcony_ceiling), rod)


static func _append_stair_massing(plan: Dictionary, buckets: Dictionary, shell: Dictionary, span: Vector2, from_r: float, back: float) -> void:
	# The photographed basement stair: a bay open to its flight, stood in for by a
	# solid stone block at handrail height with a bronze rail along its front.
	var y := float(plan.floor_y)
	var height := float(plan.heights.stair_parapet)
	var inset := 0.25 / from_r
	_annulus(plan, [buckets.stone, shell], from_r, back, span.x + inset, span.y - inset, y + height, true)
	_arc_wall(plan, [buckets.stone, shell], from_r, span.x + inset, span.y - inset, y, y + height, -1.0)
	_radial_wall(plan, [buckets.stone, shell], span.x + inset, from_r, back, y, y + height, -1.0)
	_radial_wall(plan, [buckets.stone, shell], span.y - inset, from_r, back, y, y + height, 1.0)
	var bar := plan.members.rail_bar as Array
	_arc_bar(plan, buckets.bronze as Dictionary, from_r - 0.04, span.x + inset, span.y - inset, y + height + 0.05, float(bar[0]), float(bar[1]))


## An office bay's front as photographed: light doors in light frames and small
## framed windows high in the wall, at their shares of the bay from its north side.
static func _append_office_front(plan: Dictionary, buckets: Dictionary, span: Vector2, radius: float, front: Dictionary) -> void:
	var y := float(plan.floor_y)
	var heights := plan.heights as Dictionary
	var size := heights.office_door as Array
	var frame := 0.08
	var door := buckets.door as Dictionary
	for entry: Variant in front.get("doors", []):
		var share := float((entry as Array)[0])
		var width := float((entry as Array)[1]) / radius
		var theta := lerpf(span.x, span.y, share)
		var top := y + float(size[1])
		_arc_wall(plan, [door], radius - 0.02, theta - width * 0.5, theta + width * 0.5, y, top, -1.0)
		_arc_slab(plan, [door], radius - 0.045, radius, theta - width * 0.5 - frame / radius, theta - width * 0.5, y, top + frame, true)
		_arc_slab(plan, [door], radius - 0.045, radius, theta + width * 0.5, theta + width * 0.5 + frame / radius, y, top + frame, true)
		_arc_slab(plan, [door], radius - 0.045, radius, theta - width * 0.5, theta + width * 0.5, top, top + frame, false)
	var window := heights.small_window as Array
	for share: Variant in front.get("windows", []):
		var theta := lerpf(span.x, span.y, float(share))
		var half := float(window[0]) * 0.5 / radius
		var bottom := y + float(window[2])
		var top := bottom + float(window[1])
		_arc_wall(plan, [buckets.bronze], radius - 0.01, theta - half, theta + half, bottom, top, -1.0)
		_arc_slab(plan, [door], radius - 0.04, radius, theta - half - 0.06 / radius, theta - half, bottom - 0.06, top + 0.06, true)
		_arc_slab(plan, [door], radius - 0.04, radius, theta + half, theta + half + 0.06 / radius, bottom - 0.06, top + 0.06, true)
		_arc_slab(plan, [door], radius - 0.04, radius, theta - half, theta + half, bottom - 0.06, bottom, false)
		_arc_slab(plan, [door], radius - 0.04, radius, theta - half, theta + half, top, top + 0.06, false)


## A lantern hung on a rod: a glowing glass cylinder between brass caps (a short drum
## and a cone up to the rod, a rim and a dish below), and a canopy on the ceiling.
static func _lantern(plan: Dictionary, buckets: Dictionary, r: float, theta: float, style: Dictionary, bottom: float, top: float, ceiling: float, rod: float) -> void:
	var at := _at(plan, r, theta, 0.0)
	var radius := float(style.radius)
	var sides := int(style.sides)
	var cap := float(style.cap)
	var base := float(style.base)
	var brass := buckets.brass as Dictionary
	_cylinder([buckets.lamp], at, radius, bottom + base, top - cap * 0.4, sides, false, false)
	_cylinder([brass], at, radius * 1.05, top - cap * 0.4, top, sides, true, false)
	_frustum([brass], at, radius * 1.05, rod * 2.0, top, top + cap * 0.6, sides)
	_cylinder([brass], at, radius * 1.05, bottom + base * 0.4, bottom + base, sides, false, true)
	_frustum([brass], at, radius * 0.6, radius * 1.05, bottom, bottom + base * 0.4, sides)
	_triangle_fan([brass], at, radius * 0.6, bottom, sides, false)
	_box([brass], Vector3(at.x, (top + cap * 0.6 + ceiling) * 0.5, at.z), Vector3.RIGHT, Vector3.BACK, rod, ceiling - top - cap * 0.6, rod)
	_cylinder([brass], at, radius * 0.45, ceiling - 0.06, ceiling, sides, false, true)


static func _car_blocker(plan: Dictionary) -> StaticBody3D:
	var door := plan.door as Dictionary
	var y := float(plan.sill_y)
	var height := float(door.top_y) - y
	var box := BoxShape3D.new()
	box.size = Vector3(float(door.half) * 2.0, height, 0.3)
	var holder := CollisionShape3D.new()
	holder.name = "Shape"
	holder.shape = box
	var body := StaticBody3D.new()
	body.name = "CarBlocker"
	body.collision_layer = PHYSICS_CAR_GROUND
	body.collision_mask = 0
	body.set_meta("feature_kind", "interior")
	body.set_meta("receiver_kind", "none")
	var tangent := door.tangent as Vector3
	var normal := door.normal as Vector3
	var center := _frame_point(door, float(door.center), float(door.face) - 0.2, 0.0)
	body.transform = Transform3D(Basis(tangent, Vector3.UP, normal), Vector3(center.x, y + height * 0.5, center.z))
	body.add_child(holder)
	return body


# --- plan helpers ---------------------------------------------------------------

## The plan polygon (world XZ) that exterior faces must stay out of: the hall, the
## west zone and the east bays with a margin (deeper behind the museum's bays), and a
## corridor out through the door, so it crosses the footprint's outline and no cut
## leaves a hole in a roof slab. The north annex stays outside it: it stands under
## the two-storey roof, which it must keep.
static func _cut_polygon(plan: Dictionary, margin: float, reach: float) -> PackedVector2Array:
	var center := plan.center as Vector2
	# Inside the front wall's thickness, short of its exact face.
	var inner := float(plan.front_in) - minf(margin, (float(plan.front_in) - float(plan.radius)) * 0.5)
	var plan_m := plan.config.plan_production_inference_m as Dictionary
	var east := float(plan.east)
	var outer := east + float(plan_m.east_recess_depth) + margin
	var deep := east + float(plan_m.east_museum_depth) + margin
	var museum := _ints((plan.rooms as Dictionary).east_museum_bays)
	var east_piers := plan.east_piers as Array
	var pad := float((plan.members.east_pier as Array)[0]) / east
	var deep_from := float(east_piers[int(museum.min())]) - pad
	var deep_to := float(east_piers[int(museum.max()) + 1]) + pad
	var door := plan.door as Dictionary
	var left := float(door.center) - float(door.half)
	var right := float(door.center) + float(door.half)
	var wall_left := _frame_to_circle(door, left, center, inner)
	var wall_right := _frame_to_circle(door, right, center, inner)
	if not wall_left.is_finite() or not wall_right.is_finite():
		return PackedVector2Array()
	var theta_left := _angle(center, wall_left)
	var theta_right := _angle(center, wall_right)
	var polygon := PackedVector2Array()
	for part: Array in [[float(plan.north), deep_from, outer], [deep_from, deep_to, deep], [deep_to, float(plan.south), outer]]:
		for theta in _stations(float(part[0]), float(part[1])):
			var p := _at(plan, float(part[2]), theta, 0.0)
			polygon.append(Vector2(p.x, p.z))
	# Back along the inner arc, south to north, out through the doorway on the way.
	var stations := _stations(float(plan.north), float(plan.south))
	stations.reverse()
	var corridor_done := false
	for theta in stations:
		if theta < theta_right and theta > theta_left:
			continue
		if theta <= theta_left and not corridor_done:
			for point: Vector3 in [wall_right, _frame_point(door, right, float(door.face) + reach, 0.0), _frame_point(door, left, float(door.face) + reach, 0.0), wall_left]:
				polygon.append(Vector2(point.x, point.z))
			corridor_done = true
		var p := _at(plan, inner, theta, 0.0)
		polygon.append(Vector2(p.x, p.z))
	return polygon if corridor_done else PackedVector2Array()


## An east bay between its piers' flat sides, out to depth behind the wall: the
## angle is taken at the bay's back, so at the wall the bay's faces run a few
## millimetres into the piers and no seam opens at either end.
static func _east_bay_span(plan: Dictionary, bay: int, depth: float) -> Vector2:
	var east_piers := plan.east_piers as Array
	var half := (float((plan.members.east_pier as Array)[0]) * 0.5 - 0.005) / (float(plan.east) + depth)
	return Vector2(float(east_piers[bay]) + half, float(east_piers[bay + 1]) - half)


static func _east_bay_depth(plan: Dictionary, bay: int) -> float:
	var rooms := plan.rooms as Dictionary
	var plan_m := plan.config.plan_production_inference_m as Dictionary
	if bay in _ints(rooms.east_museum_bays):
		return float(plan_m.east_museum_depth)
	if bay in _ints(rooms.east_stair_bays):
		return float(plan_m.east_recess_depth)
	return float((plan.members.east_pier as Array)[1])


## The mural's angular span on the east wall: from the north gallery's end, where its
## front curves into the wall, past a narrow plaster return, to the south corner less
## another (config mural).
static func mural_theta(plan: Dictionary) -> Vector2:
	var east := float(plan.east)
	var mural := plan.config.mural as Dictionary
	var fillet := float((plan.config.plan_production_inference_m.north_annex as Dictionary).gallery_fillet)
	return Vector2(float(plan.north) + (fillet + float(mural.north_return)) / east, float(plan.south) - float(mural.south_return) / east)


static func _ints(values: Variant) -> Array:
	return (values as Array).map(func(value: Variant) -> int: return int(value))


## Least-squares circle (Kasa) through the exact front vertices: {center, radius}.
static func _fit_circle(points: PackedVector2Array) -> Dictionary:
	if points.size() < 3:
		return {}
	var mean := Vector2.ZERO
	for point in points:
		mean += point
	mean /= float(points.size())
	var suu := 0.0
	var svv := 0.0
	var suv := 0.0
	var suuu := 0.0
	var svvv := 0.0
	var suvv := 0.0
	var svuu := 0.0
	for point in points:
		var u := point.x - mean.x
		var v := point.y - mean.y
		suu += u * u
		svv += v * v
		suv += u * v
		suuu += u * u * u
		svvv += v * v * v
		suvv += u * v * v
		svuu += v * u * u
	var det := suu * svv - suv * suv
	if absf(det) < 1e-9:
		return {}
	var b1 := 0.5 * (suuu + suvv)
	var b2 := 0.5 * (svvv + svuu)
	var uc := (b1 * svv - suv * b2) / det
	var vc := (suu * b2 - suv * b1) / det
	var radius := sqrt(uc * uc + vc * vc + (suu + svv) / float(points.size()))
	return {"center": mean + Vector2(uc, vc), "radius": radius}


## Angles from one to the other in equal steps no longer than ARC_STEP, both ends
## exact, so pieces that share an end angle share their edge vertices.
static func _stations(from: float, to: float) -> PackedFloat64Array:
	var count := maxi(1, ceili(absf(to - from) / ARC_STEP))
	var result := PackedFloat64Array()
	for index in count + 1:
		result.append(lerpf(from, to, float(index) / float(count)))
	result[count] = to
	return result


static func _angle(center: Vector2, point: Vector3) -> float:
	return atan2(point.z - center.y, point.x - center.x)


static func _at(plan: Dictionary, r: float, theta: float, y: float) -> Vector3:
	var center := plan.center as Vector2
	return Vector3(center.x + r * cos(theta), y, center.y + r * sin(theta))


static func _radial(theta: float) -> Vector3:
	return Vector3(cos(theta), 0.0, sin(theta))


## Toward increasing theta (north to south along the crescent).
static func _tangential(theta: float) -> Vector3:
	return Vector3(-sin(theta), 0.0, cos(theta))


## A point in a door frame: lateral metres along its tangent, depth along its
## outward normal, at height y.
static func _frame_point(door: Dictionary, lateral: float, depth: float, y: float) -> Vector3:
	var point := (door.anchor as Vector3) + (door.tangent as Vector3) * lateral + (door.normal as Vector3) * depth
	return Vector3(point.x, y, point.z)


## Where the door frame's lateral line, run back into the building (against its
## outward normal), first meets the circle of this radius beyond the facade; NAN
## when it does not.
static func _frame_to_circle(door: Dictionary, lateral: float, center: Vector2, radius: float) -> Vector3:
	var base := _frame_point(door, lateral, 0.0, 0.0)
	var normal := door.normal as Vector3
	var offset := Vector2(base.x - center.x, base.z - center.y)
	var direction := Vector2(normal.x, normal.z).normalized()
	# |offset + direction * d| = radius; the facade lies inside the circle, so the
	# roots straddle 0 and the negative one is into the building.
	var b := 2.0 * offset.dot(direction)
	var c := offset.length_squared() - radius * radius
	var disc := b * b - 4.0 * c
	if c >= 0.0 or disc < 0.0:
		return Vector3(NAN, NAN, NAN)
	return _frame_point(door, lateral, (-b - sqrt(disc)) * 0.5, 0.0)


# --- mesh helpers ---------------------------------------------------------------

## Plain arrays, appended in place (a packed array taken out of a Dictionary is a
## copy); build() packs them.
static func _bucket() -> Dictionary:
	return {"vertices": [], "normals": [], "uvs": [], "indices": [], "tints": []}


## A horizontal annular sector at y, facing up or down, split along its arc.
static func _annulus(plan: Dictionary, targets: Array, r0: float, r1: float, from: float, to: float, y: float, up: bool) -> void:
	if r1 - r0 < 0.001 or to - from < 0.0001:
		return
	var stations := _stations(from, to)
	for index in stations.size() - 1:
		var a := stations[index]
		var b := stations[index + 1]
		_quad(targets, _at(plan, r0, a, y), _at(plan, r1, a, y), _at(plan, r1, b, y), _at(plan, r0, b, y), Vector3.UP if up else Vector3.DOWN)


## An upward annular sector split at the given angles as well as along its arc.
static func _annulus_cut(plan: Dictionary, targets: Array, r0: float, r1: float, from: float, to: float, y: float, cuts: Array[float]) -> void:
	_ramp_cut(plan, targets, r0, r1, from, to, y, y, cuts)


## An upward annular sector rising evenly from y0 at r0 to y1 at r1, split at the given
## angles as well as along its arc (_cut_stations).
static func _ramp_cut(plan: Dictionary, targets: Array, r0: float, r1: float, from: float, to: float, y0: float, y1: float, cuts: Array[float]) -> void:
	if r1 - r0 < 0.001 or to - from < 0.0001:
		return
	var rise := (y1 - y0) / (r1 - r0)
	var stations := _cut_stations(from, to, cuts)
	for index in stations.size() - 1:
		var a := stations[index]
		var b := stations[index + 1]
		var normal := (Vector3.UP - _radial((a + b) * 0.5) * rise).normalized()
		_quad(targets, _at(plan, r0, a, y0), _at(plan, r1, a, y1), _at(plan, r1, b, y1), _at(plan, r0, b, y0), normal)


## Angles from one to the other through every cut between them, each piece in steps
## no longer than ARC_STEP (_stations): surfaces cut at the same angles share their
## edges' vertices wherever they meet.
static func _cut_stations(from: float, to: float, cuts: Array[float]) -> PackedFloat64Array:
	var edges: Array[float] = [from, to]
	for cut in cuts:
		if cut > from + 0.0005 and cut < to - 0.0005:
			edges.append(cut)
	edges.sort()
	var result := PackedFloat64Array([from])
	for index in edges.size() - 1:
		if edges[index + 1] - edges[index] < 1e-7:
			continue
		var piece := _stations(edges[index], edges[index + 1])
		for step in range(1, piece.size()):
			result.append(piece[step])
	return result


## A vertical wall on the arc of radius r between two angles, facing away from the
## centre (facing 1) or toward it (-1). uv: {"theta": Vector2, "y": Vector2(top,
## bottom)} maps the wall's own span to 0..1 for a painted panel.
static func _arc_wall(plan: Dictionary, targets: Array, r: float, from: float, to: float, bottom: float, top: float, facing: float, uv: Dictionary = {}, grain := 0.0) -> void:
	if top - bottom < 0.001 or to - from < 0.0001:
		return
	if grain > 0.0:
		# Veneer: vertical strips about grain m wide (_veneer), each its own shade.
		var edges := _veneer((to - from) * r, grain, r * from)
		for index in edges.size() - 1:
			var a := lerpf(from, to, edges[index])
			var b := lerpf(from, to, edges[index + 1])
			var middle := (a + b) * 0.5
			_quad(targets, _at(plan, r, a, bottom), _at(plan, r, b, bottom), _at(plan, r, b, top), _at(plan, r, a, top), _radial(middle) * facing, [], _grain_tint(r * middle / grain))
		return
	var stations := _stations(from, to)
	for index in stations.size() - 1:
		var a := stations[index]
		var b := stations[index + 1]
		var normal := _radial((a + b) * 0.5) * facing
		var corners := [_at(plan, r, a, bottom), _at(plan, r, b, bottom), _at(plan, r, b, top), _at(plan, r, a, top)]
		if uv.is_empty():
			_quad(targets, corners[0], corners[1], corners[2], corners[3], normal)
		else:
			var span := uv.theta as Vector2
			var heights := uv.y as Vector2
			var ua := inverse_lerp(span.x, span.y, a)
			var ub := inverse_lerp(span.x, span.y, b)
			var vb := inverse_lerp(heights.x, heights.y, bottom)
			var vt := inverse_lerp(heights.x, heights.y, top)
			_quad(targets, corners[0], corners[1], corners[2], corners[3], normal, [Vector2(ua, vb), Vector2(ub, vb), Vector2(ub, vt), Vector2(ua, vt)])


## A strip's shade of veneer: a steady pseudo-random 0.84-1.0 from its place.
static func _grain_tint(place: float) -> float:
	return 0.84 + 0.16 * _noise(floorf(place))


## Veneer strips across a span (m), as fractions 0..1 of it: as many as strips grain
## m wide would need, each 0.55 to 1.45 of that width at random (steady from seed), so
## the strips read as boards of veneer, not as the even ribs of fluting.
static func _veneer(span: float, grain: float, seed: float) -> Array[float]:
	var count := maxi(1, ceili(span / grain))
	var edges: Array[float] = [0.0]
	var total := 0.0
	for index in count:
		total += 0.55 + 0.9 * _noise(seed * 0.37 + float(index) * 1.618)
		edges.append(total)
	for index in edges.size():
		edges[index] /= total
	return edges


## A steady pseudo-random 0..1 from a number.
static func _noise(place: float) -> float:
	return fposmod(sin(place * 12.9898) * 43758.5453, 1.0)


## A curved slab between two radii, two angles and two heights: both curved faces,
## top and bottom, and (ends) its radial ends.
static func _arc_slab(plan: Dictionary, targets: Array, r0: float, r1: float, from: float, to: float, bottom: float, top: float, ends: bool) -> void:
	_arc_wall(plan, targets, r1, from, to, bottom, top, 1.0)
	_arc_wall(plan, targets, r0, from, to, bottom, top, -1.0)
	_annulus(plan, targets, r0, r1, from, to, top, true)
	_annulus(plan, targets, r0, r1, from, to, bottom, false)
	if ends:
		_radial_wall(plan, targets, from, r0, r1, bottom, top, -1.0)
		_radial_wall(plan, targets, to, r0, r1, bottom, top, 1.0)


## A vertical wall on the radial line at theta, facing toward increasing theta (1)
## or decreasing (-1).
static func _radial_wall(plan: Dictionary, targets: Array, theta: float, r0: float, r1: float, bottom: float, top: float, facing: float) -> void:
	if r1 - r0 < 0.001 or top - bottom < 0.001:
		return
	var normal := _tangential(theta) * facing
	_quad(targets, _at(plan, r0, theta, bottom), _at(plan, r1, theta, bottom), _at(plan, r1, theta, top), _at(plan, r0, theta, top), normal)


## A box column on the radial line at theta, its faces flat: hall face, back face
## and sides. An end column sits half in its end wall: that side is not drawn.
static func _radial_box(plan: Dictionary, targets: Array, theta: float, r0: float, r1: float, width: float, bottom: float, top: float, north_end: bool, south_end: bool, faces_out: bool, grain := 0.0) -> void:
	var tangent := _tangential(theta)
	var radial := _radial(theta)
	var middle := _at(plan, (r0 + r1) * 0.5, theta, 0.0)
	var half_depth := (r1 - r0) * 0.5
	var left := -width * 0.5 if not north_end else 0.0
	var right := width * 0.5 if not south_end else 0.0
	var corner := func(lateral: float, depth: float, y: float) -> Vector3:
		var p: Vector3 = middle + tangent * lateral + radial * depth
		return Vector3(p.x, y, p.z)
	var front_depth := half_depth if faces_out else -half_depth
	var back_depth := -front_depth
	var front_normal := radial * (1.0 if faces_out else -1.0)
	var edges: Array[float] = [0.0, 1.0]
	if grain > 0.0:
		edges = _veneer(right - left, grain, theta * 1000.0)
	for index in edges.size() - 1:
		var a := lerpf(left, right, edges[index])
		var b := lerpf(left, right, edges[index + 1])
		var tint := _grain_tint(theta * 1000.0 + float(index) * 7.0) if grain > 0.0 else 1.0
		_quad(targets, corner.call(a, front_depth, bottom), corner.call(b, front_depth, bottom), corner.call(b, front_depth, top), corner.call(a, front_depth, top), front_normal, [], tint)
	_quad(targets, corner.call(right, back_depth, bottom), corner.call(left, back_depth, bottom), corner.call(left, back_depth, top), corner.call(right, back_depth, top), -front_normal)
	if not north_end:
		_quad(targets, corner.call(left, back_depth, bottom), corner.call(left, front_depth, bottom), corner.call(left, front_depth, top), corner.call(left, back_depth, top), -tangent)
	if not south_end:
		_quad(targets, corner.call(right, front_depth, bottom), corner.call(right, back_depth, bottom), corner.call(right, back_depth, top), corner.call(right, front_depth, top), tangent)


## A rail along an arc: a bar of this width (radially) and height, its top and both faces.
static func _arc_bar(plan: Dictionary, bucket: Dictionary, r: float, from: float, to: float, center_y: float, width: float, height: float) -> void:
	var inner := r - width * 0.5
	var outer := r + width * 0.5
	_arc_wall(plan, [bucket], outer, from, to, center_y - height * 0.5, center_y + height * 0.5, 1.0)
	_arc_wall(plan, [bucket], inner, from, to, center_y - height * 0.5, center_y + height * 0.5, -1.0)
	_annulus(plan, [bucket], inner, outer, from, to, center_y + height * 0.5, true)
	_annulus(plan, [bucket], inner, outer, from, to, center_y - height * 0.5, false)


## A vertical cylinder's side (its axis through at), with its top or bottom closed.
static func _cylinder(targets: Array, at: Vector3, radius: float, bottom: float, top: float, sides: int, close_top: bool, close_bottom: bool) -> void:
	for side in sides:
		var a := TAU * float(side) / float(sides)
		var b := TAU * float(side + 1) / float(sides)
		var pa := Vector3(at.x + cos(a) * radius, 0.0, at.z + sin(a) * radius)
		var pb := Vector3(at.x + cos(b) * radius, 0.0, at.z + sin(b) * radius)
		_quad(targets, _lifted(pa, bottom), _lifted(pb, bottom), _lifted(pb, top), _lifted(pa, top), Vector3(cos((a + b) * 0.5), 0.0, sin((a + b) * 0.5)))
	if close_top:
		_triangle_fan(targets, at, radius, top, sides, true)
	if close_bottom:
		_triangle_fan(targets, at, radius, bottom, sides, false)


## A vertical cone's side from radius r0 at bottom to r1 at top.
static func _frustum(targets: Array, at: Vector3, r0: float, r1: float, bottom: float, top: float, sides: int) -> void:
	var rise := top - bottom
	for side in sides:
		var a := TAU * float(side) / float(sides)
		var b := TAU * float(side + 1) / float(sides)
		var middle := (a + b) * 0.5
		var normal := Vector3(cos(middle) * rise, r0 - r1, sin(middle) * rise).normalized()
		_quad(targets, Vector3(at.x + cos(a) * r0, bottom, at.z + sin(a) * r0), Vector3(at.x + cos(b) * r0, bottom, at.z + sin(b) * r0), Vector3(at.x + cos(b) * r1, top, at.z + sin(b) * r1), Vector3(at.x + cos(a) * r1, top, at.z + sin(a) * r1), normal)


static func _triangle_fan(targets: Array, at: Vector3, radius: float, y: float, sides: int, up: bool) -> void:
	for side in sides:
		var a := TAU * float(side) / float(sides)
		var b := TAU * float(side + 1) / float(sides)
		_triangle(targets, Vector3(at.x, y, at.z), Vector3(at.x + cos(a) * radius, y, at.z + sin(a) * radius), Vector3(at.x + cos(b) * radius, y, at.z + sin(b) * radius), Vector3.UP if up else Vector3.DOWN)


static func _box(targets: Array, center: Vector3, tangent_value: Vector3, normal_value: Vector3, width: float, height: float, depth: float) -> void:
	var tangent := tangent_value.normalized() * width * 0.5
	var normal := normal_value.normalized() * depth * 0.5
	var up := Vector3.UP * height * 0.5
	var t := tangent_value.normalized()
	var n := normal_value.normalized()
	_quad(targets, center - tangent - up + normal, center + tangent - up + normal, center + tangent + up + normal, center - tangent + up + normal, n)
	_quad(targets, center + tangent - up - normal, center - tangent - up - normal, center - tangent + up - normal, center + tangent + up - normal, -n)
	_quad(targets, center - tangent - up - normal, center - tangent - up + normal, center - tangent + up + normal, center - tangent + up - normal, -t)
	_quad(targets, center + tangent - up + normal, center + tangent - up - normal, center + tangent + up - normal, center + tangent + up + normal, t)
	_quad(targets, center - tangent + up + normal, center + tangent + up + normal, center + tangent + up - normal, center - tangent + up - normal, Vector3.UP)
	_quad(targets, center - tangent - up - normal, center + tangent - up - normal, center + tangent - up + normal, center - tangent - up + normal, Vector3.DOWN)


## A quad a-b-c-d (in order round its edge) facing normal, into each target bucket.
## UVs default to metres (x + z, y); a painted panel passes its own. tint scales the
## quad's baked shading (a reed's stripe).
static func _quad(targets: Array, a: Vector3, b: Vector3, c: Vector3, d: Vector3, normal_value: Vector3, uvs: Array = [], tint: float = 1.0) -> void:
	var normal := normal_value.normalized()
	var flip := (b - a).cross(c - a).dot(normal) > 0.0
	var corners: Array[Vector3] = [a, b, c, d]
	for target: Dictionary in targets:
		var vertices := target.vertices as Array
		var base := vertices.size()
		for index in 4:
			vertices.append(corners[index])
			(target.normals as Array).append(normal)
			(target.tints as Array).append(tint)
			(target.uvs as Array).append(uvs[index] if uvs.size() == 4 else Vector2(corners[index].x + corners[index].z, corners[index].y))
		# Godot draws clockwise front faces: wind so the normal faces the viewer.
		if flip:
			(target.indices as Array).append_array([base, base + 2, base + 1, base, base + 3, base + 2])
		else:
			(target.indices as Array).append_array([base, base + 1, base + 2, base, base + 2, base + 3])


static func _triangle(targets: Array, a: Vector3, b: Vector3, c: Vector3, normal_value: Vector3) -> void:
	var normal := normal_value.normalized()
	var flip := (b - a).cross(c - a).dot(normal) > 0.0
	for target: Dictionary in targets:
		var vertices := target.vertices as Array
		var base := vertices.size()
		for corner: Vector3 in [a, b, c]:
			vertices.append(corner)
			(target.normals as Array).append(normal)
			(target.tints as Array).append(1.0)
			(target.uvs as Array).append(Vector2(corner.x + corner.z, corner.y))
		(target.indices as Array).append_array([base, base + 2, base + 1] if flip else [base, base + 1, base + 2])


static func _lifted(point: Vector3, y: float) -> Vector3:
	return Vector3(point.x, y, point.z)


## One material a palette entry, shared by every interior built this run. Plain
## StandardMaterial3D in the flag sets the world already draws: a shaded surface is
## albedo times its baked vertex shading (as the Bay Bridge's solid parts), with
## roughness, metallic and specular; a glow is albedo with emission and its DaySun
## night role: a lamp's own, or a daylight panel's (out at night).
static func _material(key: String, entry: Dictionary) -> StandardMaterial3D:
	if _materials.has(key):
		return _materials[key]
	var rgb := entry.rgb as Array
	var material := StandardMaterial3D.new()
	material.resource_name = "Building1Interior_" + key
	material.albedo_color = Color(float(rgb[0]), float(rgb[1]), float(rgb[2]))
	material.roughness = float(entry.get("roughness", 0.9))
	material.metallic = float(entry.get("metallic", 0.0))
	material.metallic_specular = float(entry.get("specular", 0.5))
	if entry.has("emission"):
		var glow := entry.emission as Array
		material.emission_enabled = true
		material.emission = Color(float(glow[0]), float(glow[1]), float(glow[2]))
		material.emission_energy_multiplier = float(entry.get("emission_energy", 1.0))
		material.set_meta(NIGHT_ROLE, str(entry.night_role))
	else:
		material.vertex_color_use_as_albedo = true
		material.vertex_color_is_srgb = true
	_materials[key] = material
	return material


## A mural tile's material, new for each build (not shared like _material's: the
## loader swaps its texture): matte paint, the tile's albedo times the room's baked
## shading. Until Building1MuralLoader loads the tile it shows the placeholder texture
## of the band's plain colour, so the shader (texture, vertex colour, clamped and
## mipmapped) is the same before and after: loading compiles nothing.
static func _mural_material(key: String, entry: Dictionary, placeholder: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = "Building1Interior_" + key
	material.albedo_color = Color.WHITE
	material.albedo_texture = placeholder
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	material.texture_repeat = false
	material.vertex_color_use_as_albedo = true
	material.vertex_color_is_srgb = true
	material.roughness = float(entry.get("roughness", 0.85))
	material.metallic_specular = float(entry.get("specular", 0.15))
	# A faint glow of the picture itself, as if the pendants lit it: unseen by day, it
	# keeps the mural from vanishing at night (a lamp: DaySun leaves it as it is).
	material.emission_enabled = true
	# BaseMaterial3D adds the emission colour to the texture's: black, so only the
	# picture glows.
	material.emission = Color.BLACK
	material.emission_texture = material.albedo_texture
	material.emission_energy_multiplier = float(entry.get("night_glow", 0.06))
	material.set_meta(NIGHT_ROLE, "lamp")
	return material


## The mural's plain placeholder (4 x 4 of the band's colour), new for each build.
static func _mural_placeholder(entry: Dictionary) -> Texture2D:
	var rgb := entry.rgb as Array
	var image := Image.create(4, 4, false, Image.FORMAT_RGB8)
	image.fill(Color(float(rgb[0]), float(rgb[1]), float(rgb[2])))
	var texture := ImageTexture.create_from_image(image)
	texture.resource_name = "Building1InteriorMuralPlaceholder"
	return texture


## Baked shading for one surface's vertices: the hall is lit by its tall west windows
## and their bounce, which the sky's ambient light alone (all the sun-less hall gets)
## spreads evenly. Faces toward the windows stay full, faces away and soffits fall
## off, members darken toward the floor, the floor toward the walls, and the bays
## and rooms under the balcony go dim, darker the deeper they run. The floor carries
## its baked sheen unless sheen_on is false (the reflections trial's plain floor).
static func _shading(plan: Dictionary, bucket: Dictionary, floor := false, sheen_on := true) -> PackedColorArray:
	var colors := PackedColorArray()
	var vertices := bucket.vertices as Array
	var normals := bucket.normals as Array
	var tints := bucket.tints as Array
	for index in vertices.size():
		var shade := _shade(plan, vertices[index] as Vector3, normals[index] as Vector3) * float(tints[index])
		var colour := Color(shade, shade, shade)
		if floor:
			# Vertex colours stop at 1: the floor's own shade sits lower (its albedo is
			# that much brighter), leaving the sheen room to brighten.
			var sheen := _floor_sheen(plan, vertices[index] as Vector3) if sheen_on else Color.WHITE
			shade *= FLOOR_BASE
			colour = Color(minf(1.0, shade * sheen.r), minf(1.0, shade * sheen.g), minf(1.0, shade * sheen.b))
		colors.append(colour.linear_to_srgb())
	return colors


## The polished terrazzo's sheen, baked (no reflection probe, no new shader): the tall
## windows' light in streaks fading into the hall from the colonnade, the mural's warm
## glow along the east wall, and the wood piers' dark reflections in front of them.
static func _floor_sheen(plan: Dictionary, point: Vector3) -> Color:
	var center := plan.center as Vector2
	var offset := Vector2(point.x - center.x, point.z - center.y)
	var r := offset.length()
	var theta := atan2(offset.y, offset.x)
	var column := float(plan.column)
	var east := float(plan.east)
	var sheen := Color(1.0, 1.0, 1.0)
	# The tall windows' light in streaks out from between the columns.
	if r > column - 0.01 and r < column + 4.5:
		var half := float((plan.members.window as Dictionary).inner_width) * 0.5 / float(plan.front_in)
		var fade := 1.0 - clampf((r - column) / 4.5, 0.0, 1.0)
		for window: Dictionary in plan.windows:
			var across := absf(theta - float(window.theta)) / half
			if across < 1.3:
				var k := (1.0 - smoothstep(0.5, 1.3, across)) * fade
				sheen = sheen * Color(1.0 + 0.4 * k, 1.0 + 0.38 * k, 1.0 + 0.33 * k)
		# The columns' dark reflections in front of them: dark at the column's foot,
		# with sharp sides (the floor is cut at their edges, _append_floors).
		var col_half := float((plan.members.west_column as Array)[0]) * COLUMN_REFLECTION / column
		for pier: Variant in plan.piers:
			var across := absf(theta - float(pier)) / col_half
			if across < 1.0 and r < column + COLUMN_REFLECTION_M:
				var k := (1.0 - smoothstep(REFLECTION_CORE, 1.0, across)) * (1.0 - clampf((r - column) / COLUMN_REFLECTION_M, 0.0, 1.0))
				sheen = sheen * Color(1.0 - 0.52 * k, 1.0 - 0.55 * k, 1.0 - 0.58 * k)
	if r > east - 3.5:
		# The mural's warm colour along the east wall, and the wood piers' dark
		# reflections in front of them.
		var k := smoothstep(east - 3.5, east, r)
		sheen = sheen * Color(1.0 + 0.14 * k, 1.0 + 0.06 * k, 1.0 - 0.04 * k)
		var pier_half := float((plan.members.east_pier as Array)[0]) * 0.55 / east
		for pier: Variant in plan.east_piers:
			var across := absf(theta - float(pier)) / pier_half
			if across < 1.0 and r > east - 2.6:
				var d := (1.0 - smoothstep(REFLECTION_CORE, 1.0, across)) * smoothstep(east - 2.6, east - 0.4, r)
				sheen = sheen * Color(1.0 - 0.52 * d, 1.0 - 0.56 * d, 1.0 - 0.6 * d)
	return sheen


static func _shade(plan: Dictionary, point: Vector3, normal: Vector3) -> float:
	var center := plan.center as Vector2
	var offset := Vector2(point.x - center.x, point.z - center.y)
	var r := offset.length()
	var theta := atan2(offset.y, offset.x)
	var radial := Vector3(offset.x, 0.0, offset.y) / maxf(r, 0.001)
	var heights := plan.heights as Dictionary
	var h := point.y - float(plan.floor_y)
	var column := float(plan.column)
	var east := float(plan.east)
	var front_in := float(plan.front_in)
	# The tall west windows' daylight: fullest by them, softer toward the east wall.
	var daylight := lerpf(1.0, 0.86, clampf((r - column) / (east - column), 0.0, 1.0))
	var shade := 1.0
	if normal.y > 0.7:
		shade = 1.0
	elif normal.y < -0.7:
		# Ceilings take the windows' bounce; soffits low down stay in shade.
		shade = 0.96 if h > float((heights.mural as Array)[1]) - 0.01 else 0.62
	else:
		var facing := normal.dot(radial)
		shade = lerpf(0.93, 1.0, -facing) if facing < 0.0 else lerpf(0.93, 0.84, facing)
		shade *= lerpf(0.84, 1.0, smoothstep(0.0, 1.0, h))
	if normal.y > 0.7 and h < 0.05:
		# The floor: against the east wall and its bays, and in from the colonnade.
		shade *= lerpf(0.8, 1.0, smoothstep(0.0, 1.5, east - r)) if r < east else 0.8
		shade *= lerpf(0.88, 1.0, smoothstep(0.0, 1.5, r - column)) if r > column else 0.86
	if h < float(heights.balcony_floor) - 0.05 and r < column - 0.02:
		# Under the balcony: the bays, rooms, vestibule and doorway.
		shade *= lerpf(0.74, 0.46, clampf((column - r) / (column - front_in), 0.0, 1.0))
	elif r > east + 0.05 and h < float(heights.east_bay_head):
		# Into the east bays.
		shade *= 0.93 if r < east + float((plan.members.east_pier as Array)[1]) + 0.05 else 0.84
	if theta < float(plan.north) - 0.0005:
		# The north annex under the gallery and the gallery itself (unphotographed).
		shade *= 0.82
	return shade * daylight


static func _json(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}
