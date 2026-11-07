class_name StreetFenceBuilder
extends RefCounted
## Builds PlayableWorld/StreetDetail/Fences from the placed street-detail fence
## rows that carry a kit prop (tools/lib/street-fence-generation.mjs chooses them;
## street_fence_kit.gd draws them). A fence row's solid runs become meshes per
## square cell they cross, so they cull by area: the solid parts with shadows, the
## blended wire and windscreens without, and a shadow-only copy of the wire and
## screens. Each row has one static body with a box per bay; bays of one size
## share a box shape. The bodies are on the street-prop layer, like the street
## furniture: the player collides with a fence and the jetpack clears it, the
## spray ray stops on it (a fence is never a spray receiver), and the camera arm
## ignores it. Openings (crossing roads and paths, gates, the gameplay mask) hold
## neither mesh nor box. A fence on a context deck (its fence block's deck: a pier
## drawn as visual-only context beyond the playable boundary) has no body, as the
## deck has none.

const KIT := preload("res://game/scripts/world/street_fence_kit.gd")
## Render cell size (m).
const CELL_M := 48.0
const RENDER_WORLD_VISIBLE := 1
const PHYSICS_SPRAY_SURFACE := 1 << 2
const PHYSICS_STREET_PROP := 1 << 3


func build(document: Dictionary) -> Dictionary:
	var kit := KIT.new()
	var root := Node3D.new()
	root.name = "GeneratedStreetFences"
	var fences := 0
	var length_m := 0.0
	var boxes := 0
	var meshes := 0
	var type_counts: Dictionary = {}
	# size key -> BoxShape3D, shared by every bay of that size in every row
	var box_shapes: Dictionary = {}
	for row_value: Variant in document.get("rows", []):
		var row: Dictionary = row_value
		if str(row.get("status", "")) != "placed" or str(row.get("layer", "")) != "fences" or not row.get("prop", null) is String:
			continue
		var fence: Variant = row.get("fence", null)
		var type := str(row.prop)
		if not fence is Dictionary or str((fence as Dictionary).get("type", "")) != type:
			root.free()
			return _error("%s: a fence prop needs its fence block" % row.get("id", "?"))
		var problem := KIT.params_error(type, row.get("prop_params", null))
		if problem != "":
			root.free()
			return _error("%s: %s" % [row.get("id", "?"), problem])
		var id := str(row.id)
		var cells: Dictionary = {}
		var bay_boxes: Array[Dictionary] = []
		var runs: Array = (fence as Dictionary).get("runs", [])
		for run_index in runs.size():
			var posts := _posts(runs[run_index])
			if posts.size() < 2:
				root.free()
				return _error("%s: run %d has fewer than two posts" % [id, run_index])
			for index in posts.size() - 1:
				length_m += Vector2(posts[index + 1].x - posts[index].x, posts[index + 1].z - posts[index].z).length()
			bay_boxes.append_array(kit.add_run(cells, CELL_M, type, row.prop_params, posts, (id + ":" + str(run_index)).hash()))
		# Gates stand open, their leaves back on the inside; banners hang on the runs.
		for gate_value: Variant in (fence as Dictionary).get("gates", []):
			if gate_value is Dictionary:
				var gate := gate_value as Dictionary
				bay_boxes.append_array(kit.add_gate(cells, CELL_M, type, row.prop_params, _posts(gate), gate.get("leaves", []) as Array))
		for banner_value: Variant in (fence as Dictionary).get("banners", []):
			if banner_value is Dictionary:
				kit.add_banner(cells, CELL_M, type, row.prop_params, _posts(banner_value), float((banner_value as Dictionary).get("height_m", 1.0)), int((banner_value as Dictionary).get("art", -1)))
		var group := Node3D.new()
		group.name = "Fence__" + id.validate_node_name()
		group.set_meta("street_detail_id", id)
		var cell_keys: Array = cells.keys()
		cell_keys.sort()
		for key: String in cell_keys:
			var parts := kit.commit(cells[key])
			for part: Array in [["Mesh", parts.solid, GeometryInstance3D.SHADOW_CASTING_SETTING_ON],
					["Fabric", parts.fabric, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF],
					["Shadow", parts.shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY]]:
				var mesh: ArrayMesh = part[1]
				if mesh == null:
					continue
				var instance := MeshInstance3D.new()
				instance.name = "%s__c%s" % [part[0], key]
				instance.mesh = mesh
				instance.layers = RENDER_WORLD_VISIBLE
				instance.cast_shadow = part[2]
				# Godot measures the range to the bounds centre: reach the whole cell.
				instance.visibility_range_end = KIT.RANGE_M + ceilf(mesh.get_aabb().size.length() * 0.5)
				instance.visibility_range_end_margin = 10.0
				instance.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
				instance.set_meta("street_detail_layer", "fences")
				group.add_child(instance)
				meshes += 1
		if (fence as Dictionary).has("deck"):
			root.add_child(group)
			fences += 1
			type_counts[type] = int(type_counts.get(type, 0)) + 1
			continue
		var body := StaticBody3D.new()
		body.name = "Collision"
		body.collision_layer = PHYSICS_STREET_PROP | PHYSICS_SPRAY_SURFACE
		body.collision_mask = 0
		body.set_meta("feature_kind", "street_fence")
		body.set_meta("receiver_kind", "none")
		body.set_meta("opaque", true)
		body.set_meta("street_detail_id", id)
		body.set_meta("street_detail_kind", "fence")
		body.set_meta("street_detail_ids", PackedStringArray([id]))
		for entry: Dictionary in bay_boxes:
			var collision := CollisionShape3D.new()
			collision.name = "Bay%d" % body.get_child_count()
			collision.shape = _box_shape(box_shapes, entry.size)
			collision.transform = entry.transform
			collision.set_meta("street_detail_id", id)
			body.add_child(collision)
			boxes += 1
		group.add_child(body)
		root.add_child(group)
		fences += 1
		type_counts[type] = int(type_counts.get(type, 0)) + 1
	root.set_meta("fences", fences)
	root.set_meta("fence_types", type_counts)
	return {
		"ok": true,
		"node": root,
		"fences": fences,
		"fence_types": type_counts,
		"length_m": snappedf(length_m, 0.01),
		"meshes": meshes,
		"collision_boxes": boxes,
	}


## A run's posts at the visible ground: land elevation plus the surface bias.
static func _posts(run: Variant) -> PackedVector3Array:
	var posts := PackedVector3Array()
	if not run is Dictionary:
		return posts
	var points: Variant = (run as Dictionary).get("points_m", [])
	var biases: Variant = (run as Dictionary).get("surface_bias_m", [])
	if not points is Array or not biases is Array or (points as Array).size() != (biases as Array).size():
		return posts
	for index in (points as Array).size():
		var point: Array = points[index]
		posts.append(Vector3(float(point[0]), float(point[1]) + float(biases[index]), float(point[2])))
	return posts


## A bay's box shape at its size to the millimetre, shared between bays of the
## same size like the street-furniture kit's prop shapes.
static func _box_shape(cache: Dictionary, size: Vector3) -> BoxShape3D:
	var rounded := size.snapped(Vector3(0.001, 0.001, 0.001))
	var key := "box_%.3f_%.3f_%.3f" % [rounded.x, rounded.y, rounded.z]
	if not cache.has(key):
		var shape := BoxShape3D.new()
		shape.size = rounded
		cache[key] = shape
	return cache[key] as BoxShape3D


static func _error(message: String) -> Dictionary:
	return {"ok": false, "code": "street_fence_build", "message": message, "source_keys": []}
