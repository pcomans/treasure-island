extends SceneTree
## Headless B600 fresh-study preflight: identity, footprint containment, winding,
## shared indexed-geometry comparison, roles and ground-contact seating.
## Not a render, movement, visual or acceptance check.

const Geometry = preload("res://game/tests/support/building_study_geometry.gd")
const MODEL_PATH := "res://game/scripts/world/facades/b600_fresh_study_model.gd"
const CHUNK := "res://generated/world/chunks/x_1__z_-2.json"
const LAND_KEY := "land:w26767313:x_1__z_-2"

var failures: Array[String] = []


func _initialize() -> void:
	var output := ""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):
			output = arg.trim_prefix("--output=")
	if output.is_empty() or DirAccess.dir_exists_absolute(output):
		push_error("B600_STATIC: fresh --output required")
		quit(2)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var chunk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CHUNK))
	var roof: Dictionary = {}
	var wall: Dictionary = {}
	var land: Dictionary = {}
	for record: Dictionary in chunk.records:
		match str(record.object_key):
			"building:w34313548:roof": roof = record
			"building:w34313548:wall": wall = record
			LAND_KEY: land = record
	check(not roof.is_empty() and not wall.is_empty() and not land.is_empty(), "Exact roof/wall/land records")
	var receipt := {"chunk_sha256": FileAccess.get_sha256(CHUNK), "model_sha256": FileAccess.get_sha256(MODEL_PATH)}
	var model = load(MODEL_PATH).new()
	var built: Dictionary = model.build(roof, land)
	receipt["build"] = built
	check(bool(built.get("ok", false)), "Model build")
	var L: float = model.L
	var W: float = model.W
	var role_stats := {}
	var winding_bad := 0
	var outside: Array = []
	var nonfinite := 0
	for name: String in ["WallMesh", "RoofMesh", "DetailMesh", "VisualMesh"]:
		var inst := model.get_node(name) as MeshInstance3D
		var mesh := inst.mesh as ArrayMesh
		var tris := 0
		for si in mesh.get_surface_count():
			var arr: Array = mesh.surface_get_arrays(si)
			var v: PackedVector3Array = arr[Mesh.ARRAY_VERTEX]
			var nrm: PackedVector3Array = arr[Mesh.ARRAY_NORMAL]
			var ids: PackedInt32Array = arr[Mesh.ARRAY_INDEX]
			tris += ids.size() / 3
			for p: Vector3 in v:
				if not p.is_finite():
					nonfinite += 1
				elif p.x < -0.001 or p.x > L + 0.001 or p.z < -0.001 or p.z > W + 0.001:
					if outside.size() < 20:
						outside.append([name, mesh.surface_get_name(si), p.x, p.y, p.z])
					else:
						outside.append(null)
			for i in range(0, ids.size(), 3):
				var a := v[ids[i]]
				var b := v[ids[i + 1]]
				var c := v[ids[i + 2]]
				if (b - a).cross(c - a).dot(nrm[ids[i]]) >= 0.0:
					winding_bad += 1
		role_stats[name] = {"surfaces": mesh.get_surface_count(), "triangles": tris, "layers": inst.layers}
	for letter: MeshInstance3D in model.letters:
		var box: AABB = letter.mesh.get_aabb()
		for k in 8:
			var p: Vector3 = letter.transform * box.get_endpoint(k)
			if p.x < -0.001 or p.x > L + 0.001 or p.z < -0.001 or p.z > W + 0.001:
				outside.append(["letter", letter.name, p.x, p.y, p.z])
	receipt["roles"] = role_stats
	receipt["letters"] = model.letters.size()
	receipt["winding_violations"] = winding_bad
	receipt["outside_footprint"] = outside
	receipt["nonfinite_vertices"] = nonfinite
	check(winding_bad == 0, "All triangles front-face outward in Godot clockwise convention")
	check(outside.is_empty(), "Every emitted vertex and letter bound inside the frozen footprint")
	check(nonfinite == 0, "Finite vertices")
	# Shared indexed-array geometry comparison per collision owner.
	var geometry := {}
	var pairs := {"WallContact": "WallMesh", "RoofContact": "RoofMesh", "DetailContact": "DetailMesh"}
	for body_name: String in pairs:
		var body := model.get_node(body_name) as StaticBody3D
		var holder := body.get_node("Shape") as CollisionShape3D
		var shape := holder.shape as ConcavePolygonShape3D
		var mesh := (model.get_node(pairs[body_name]) as MeshInstance3D).mesh
		var expected := 0
		for si in mesh.get_surface_count():
			expected += (mesh.surface_get_arrays(si)[Mesh.ARRAY_INDEX] as PackedInt32Array).size()
		var transforms: Array[Transform3D] = [Transform3D.IDENTITY]
		var collected := Geometry.collect(mesh, transforms, Geometry.INDEXED_ARRAYS)
		var compared := Geometry.compare(collected, shape.get_faces(), expected)
		var wall_role := body_name == "WallContact"
		var predicates := {
			"compare": bool(compared.ok),
			"body_identity": body.transform == Transform3D.IDENTITY,
			"holder_identity": holder.transform == Transform3D.IDENTITY,
			"mesh_identity": (model.get_node(pairs[body_name]) as Node3D).transform == Transform3D.IDENTITY,
			"layer": body.collision_layer == 5,
			"mask": body.collision_mask == 0,
			"spray_group": body.is_in_group("spray_receiver_wall") == wall_role,
			"receiver": str(body.get_meta("receiver_kind", "")) == ("building_wall" if wall_role else "none") and str(shape.get_meta("receiver_kind", "")) == str(body.get_meta("receiver_kind", "")),
			"source": body.get_meta("source_keys", []) == ["w34313548"] and shape.get_meta("source_keys", []) == ["w34313548"],
			"render_layer": (model.get_node(pairs[body_name]) as MeshInstance3D).layers == (2 if wall_role else 1),
		}
		var ok := true
		for key: String in predicates:
			ok = ok and bool(predicates[key])
		check(ok, "Geometry/role predicates " + body_name)
		geometry[body_name] = {"ok": ok, "predicates": predicates, "expected_vertex_count": expected, "compare_predicates": compared.predicates}
		var detail_file := FileAccess.open(output.path_join("geometry-%s.json" % body_name), FileAccess.WRITE)
		detail_file.store_string(JSON.stringify({"predicates": predicates, "compare": compared}))
		detail_file.close()
	receipt["geometry"] = geometry
	# Ground-contact preflight against actual land (and the +0.05 m visible area overlay).
	var contacts: Array = []
	for c: Dictionary in model.ground_contacts:
		var g := float(c.land_y)
		var bottom := float(c.bottom_y)
		var row := c.duplicate()
		row["area_overlay_y"] = g + 0.05
		row["bottom_minus_land"] = bottom - g
		var seated := is_finite(g) and bottom <= g + 0.031 and bottom >= g - 0.30
		if str(c.id) == "porch-pier":
			seated = is_finite(g) and bottom < g
		row["seated"] = seated
		check(seated, "Ground contact seated " + str(c.id))
		contacts.append(row)
	receipt["ground_contacts"] = contacts
	# Perimeter: wall bottoms must stay below actual land everywhere.
	var lowest_margin := INF
	for i in 209:
		var a := L * float(i) / 208.0
		for b in [0.05, W - 0.05]:
			lowest_margin = minf(lowest_margin, model.land_y(a, b) - 3.40)
	for i in 37:
		var b2 := W * float(i) / 36.0
		for a2 in [0.05, L - 0.05]:
			lowest_margin = minf(lowest_margin, model.land_y(a2, b2) - 3.40)
	var source_bottom := INF
	var wv: Array = wall.vertices
	for i in range(1, wv.size(), 3):
		source_bottom = minf(source_bottom, float(wv[i]))
	receipt["wall_bottom_y"] = 3.40
	receipt["min_land_minus_wall_bottom"] = lowest_margin
	receipt["source_min_wall_bottom_y"] = source_bottom
	check(lowest_margin > 0.1 and source_bottom > 3.40, "Wall bottoms below land and below source wall-bottom elevations")
	receipt["ok"] = failures.is_empty()
	receipt["failures"] = failures
	var file := FileAccess.open(output.path_join("static-receipt.json"), FileAccess.WRITE)
	file.store_string(JSON.stringify(receipt, "\t") + "\n")
	file.close()
	print("B600_STATIC: ", JSON.stringify({"ok": failures.is_empty(), "failures": failures, "roles": role_stats}))
	model.free()
	quit(0 if failures.is_empty() else 1)


func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
