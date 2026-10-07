extends RefCounted
## Shared helpers for the reusable building checks: load the real island,
## find a building by OSM source key, place the stock player and aim its camera.

const WORLD_SOLID_MASK := 1

var tree: SceneTree
var main: GameMain
var world: WorldLoader
var player: PlayerController
var hud: GameHUD


func _init(scene_tree: SceneTree) -> void:
	tree = scene_tree


## Instantiates main.tscn and waits until the world is loaded and the player
## has settled. Returns an error message, or "" on success.
func load_world() -> String:
	# Dummy-renderer MultiMesh readback can return identity transforms, silently
	# moving visible geometry into the origin and invalidating fit/approach checks.
	if DisplayServer.get_name() == "headless":
		return "shared visible-geometry checks require rendering; omit --headless"
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	main = packed.instantiate() as GameMain
	main.capture_mouse_on_ready = false
	world = main.get_node("WorldRoot") as WorldLoader
	player = main.get_node("Player") as PlayerController
	hud = main.get_node("Interface/HUD") as GameHUD
	var ready: Array = []
	var failed: Array = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report))
	world.world_failed.connect(func(code: String, message: String, _keys: Array) -> void: failed.append("%s: %s" % [code, message]))
	tree.root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failed.is_empty() and Time.get_ticks_msec() - started < 120000:
		await tree.process_frame
	if not failed.is_empty():
		return "world failed to load: %s" % failed[0]
	if ready.is_empty():
		return "world did not load within 120 s"
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 120000:
		await tree.physics_frame
	if not player.was_first_reveal_grounded():
		return "player did not settle at spawn"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.set_gameplay_enabled(false)
	clean_hud()
	return ""


## Every node that belongs to the building with this OSM source key
## (e.g. "w291189336"), matched by node metadata or node name.
func building_nodes(source_key: String) -> Array[Node3D]:
	var found: Array[Node3D] = []
	_collect_building_nodes(world, source_key, found)
	return found


func _collect_building_nodes(node: Node, source_key: String, found: Array[Node3D]) -> void:
	if node is Node3D and _belongs_to(node, source_key):
		found.append(node as Node3D)
		return
	for child in node.get_children():
		_collect_building_nodes(child, source_key, found)


func _belongs_to(node: Node, source_key: String) -> bool:
	if node.has_meta("source_keys") and source_key in (node.get_meta("source_keys") as Array).map(func(k: Variant) -> String: return str(k)):
		return true
	if node.has_meta("derived_object_key") and (":%s:" % source_key) in str(node.get_meta("derived_object_key")):
		return true
	return (":%s:" % source_key) in str(node.name) or str(node.name).ends_with(":" + source_key)


## Visible geometry under the given nodes as [mesh, global transform, node name],
## expanding MultiMesh instances.
func visual_meshes(nodes: Array[Node3D]) -> Array:
	var meshes: Array = []
	for node in nodes:
		_collect_meshes(node, meshes)
	return meshes


func _collect_meshes(node: Node, meshes: Array) -> void:
	if node is MeshInstance3D and (node as MeshInstance3D).is_visible_in_tree() and (node as MeshInstance3D).mesh != null:
		meshes.append([(node as MeshInstance3D).mesh, (node as MeshInstance3D).global_transform, str(node.name)])
	elif node is MultiMeshInstance3D and (node as MultiMeshInstance3D).is_visible_in_tree() and (node as MultiMeshInstance3D).multimesh != null:
		var multimesh := (node as MultiMeshInstance3D).multimesh
		if multimesh.mesh != null and multimesh.transform_format == MultiMesh.TRANSFORM_3D:
			for i in multimesh.visible_instance_count if multimesh.visible_instance_count >= 0 else multimesh.instance_count:
				meshes.append([multimesh.mesh, (node as MultiMeshInstance3D).global_transform * multimesh.get_instance_transform(i), str(node.name)])
	for child in node.get_children():
		_collect_meshes(child, meshes)


func bounds(meshes: Array) -> AABB:
	var box := AABB()
	for i in meshes.size():
		var mesh_box: AABB = meshes[i][1] * (meshes[i][0] as Mesh).get_aabb()
		box = mesh_box if i == 0 else box.merge(mesh_box)
	return box


## Collision bodies under the given nodes (the building's own colliders).
func collision_rids(nodes: Array[Node3D]) -> Array[RID]:
	var rids: Array[RID] = []
	for node in nodes:
		_collect_rids(node, rids)
	return rids


func _collect_rids(node: Node, rids: Array[RID]) -> void:
	if node is CollisionObject3D:
		rids.append((node as CollisionObject3D).get_rid())
	for child in node.get_children():
		_collect_rids(child, rids)


## Active native wall receivers define architectural approach geometry. Attached
## ground/support meshes remain in visual_meshes and all surface fit checks.
func architectural_walls(nodes: Array[Node3D]) -> Dictionary:
	var bodies: Array[CollisionObject3D] = []
	for node in nodes:
		_collect_wall_bodies(node, bodies)
	var points := PackedVector3Array()
	var rids: Array[RID] = []
	var shapes := {}
	var faces: Array[Dictionary] = []
	for body in bodies:
		var allowed: Array[int] = []
		for owner_id in body.get_shape_owners():
			if body.is_shape_owner_disabled(owner_id):
				continue
			var shape_node := body.shape_owner_get_owner(owner_id) as CollisionShape3D
			if shape_node == null:
				return {"ok": false, "reason": "unsupported native wall shape owner"}
			var shape := shape_node.shape
			if shape == null:
				return {"ok": false, "reason": "missing native wall shape"}
			# Explicit per-shape identity wins over body identity on mixed bodies.
			# SharedHousing alone supplies a homogeneous semantic family role.
			var role := str(shape.get_meta("receiver_kind", shape_node.get_meta("receiver_kind", "")))
			if role == "" and str(body.get_meta("family_role", "")) == "wall":
				role = "building_wall"
			if role == "none":
				continue
			if role != "building_wall":
				return {"ok": false, "reason": "unknown native shape role: " + str(shape_node.get_path())}
			var local_points := PackedVector3Array()
			if shape is ConcavePolygonShape3D:
				local_points = (shape as ConcavePolygonShape3D).get_faces()
			elif shape is BoxShape3D:
				var box_mesh := BoxMesh.new()
				box_mesh.size = (shape as BoxShape3D).size
				local_points = box_mesh.get_faces()
			else:
				return {"ok": false, "reason": "unsupported native wall shape: " + str(shape_node.get_path())}
			if local_points.is_empty() or local_points.size() % 3 != 0 or body.shape_owner_get_shape_count(owner_id) != 1:
				return {"ok": false, "reason": "empty or ambiguous native wall shape owner"}
			var world_faces := PackedVector3Array()
			for vertex in local_points:
				var point := shape_node.global_transform * vertex
				if not point.is_finite():
					return {"ok": false, "reason": "nonfinite native wall geometry"}
				points.append(point)
				world_faces.append(point)
			var shape_index := body.shape_owner_get_shape_index(owner_id, 0)
			allowed.append(shape_index)
			faces.append({"rid": body.get_rid(), "shape": shape_index, "vertices": world_faces})
		if not allowed.is_empty():
			rids.append(body.get_rid())
			shapes[body.get_rid()] = allowed
	if points.is_empty():
		return {"ok": false, "reason": "no active source wall receiver geometry"}
	var box := AABB(points[0], Vector3.ZERO)
	for point in points:
		box = box.expand(point)
	return {"ok": true, "bounds": box, "rids": rids, "shapes": shapes, "faces": faces}


func _collect_wall_bodies(node: Node, found: Array[CollisionObject3D]) -> void:
	if node is CollisionObject3D and ((node as CollisionObject3D).collision_layer & player.collision_mask) != 0 and node.is_in_group("spray_receiver_wall") and str(node.get_meta("receiver_kind", "")) == "building_wall":
		found.append(node as CollisionObject3D)
	for child in node.get_children():
		_collect_wall_bodies(child, found)


## Ray query that never hits the player. Like the player, it doesn't see
## one-sided collision from behind (the housing roofs were invisible from above).
func ray(from: Vector3, to: Vector3, mask: int = WORLD_SOLID_MASK, exclude: Array[RID] = []) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask, exclude + [player.get_rid()])
	query.collide_with_areas = false
	query.hit_back_faces = false
	return player.get_world_3d().direct_space_state.intersect_ray(query)


## Open ground or the live housing producer's homogeneous traversable surfaces.
## Roofs/support remain ineligible even when they share the same source building.
func is_walkable_ground(hit: Dictionary) -> bool:
	if hit.is_empty():
		return false
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := str(record.get_meta("feature_kind", "")) if record != null else ""
	if not (hit.normal as Vector3).is_finite() or (hit.normal as Vector3).dot(Vector3.UP) < 0.7:
		return false
	if feature != "" and not feature.begins_with("building"):
		return true
	# housing_family_live_attachment groups native faces by the producer's role;
	# its ground group contains parking, footway and entry-path tops only.
	var body := collider as StaticBody3D
	if body == null or record == null or str(record.get_meta("scope", "")) != "approved_shared_family_normal_play" or not bool(record.get_meta("build_valid", false)):
		return false
	var source := str(record.get_meta("source_key", ""))
	if source.is_empty() or body.get_meta("source_keys", []) != [source] or str(body.get_meta("derived_object_key", "")) != "building:" + source + ":wall":
		return false
	if str(body.get_meta("family_role", "")) != "ground" or str(body.get_meta("receiver_kind", "")) != "none" or body.collision_layer != WORLD_SOLID_MASK or body.is_in_group("spray_receiver_wall"):
		return false
	var owners := body.get_shape_owners()
	if owners.size() != 1 or body.is_shape_owner_disabled(owners[0]) or body.shape_owner_get_shape_count(owners[0]) != 1:
		return false
	var shape_node := body.shape_owner_get_owner(owners[0]) as CollisionShape3D
	if shape_node == null or not shape_node.shape is ConcavePolygonShape3D:
		return false
	return not (shape_node.shape as ConcavePolygonShape3D).get_faces().is_empty()


## Only the existing producer's explicitly related rooftop component gets an
## elevated approach surface. This does not make arbitrary roofs open ground.
func approach_support(source: String, nodes: Array[Node3D], architecture: Dictionary) -> Dictionary:
	var towers: Array[Node3D] = []
	for node in nodes:
		_collect_component(node, "tower_wall", towers)
	if towers.is_empty():
		return {"ok": true, "context": {}}
	if towers.size() != 1 or not architecture.ok:
		return {"ok": false, "reason": "ambiguous rooftop target architecture"}
	var tower := towers[0]
	var config_path := str(tower.get_meta("config_path", ""))
	var config: Variant = JSON.parse_string(FileAccess.get_file_as_string(config_path))
	if not config is Dictionary or not config.get("target") is Dictionary or not config.get("vertical_production_inference_m") is Dictionary:
		return {"ok": false, "reason": "missing rooftop producer binding"}
	var target: Dictionary = config.target
	var parent_source := str(target.get("building_source_key", ""))
	if str(target.get("tower_source_key", "")) != source or parent_source.is_empty() or parent_source == source or tower.get_meta("source_keys", []) != [source] or str(tower.get_meta("model_id", "")) != str(config.get("model_id", "")):
		return {"ok": false, "reason": "rooftop producer source mismatch"}
	var wall_bodies: Array[CollisionObject3D] = []
	for node in nodes:
		_collect_wall_bodies(node, wall_bodies)
	for body in wall_bodies:
		if body.get_meta("source_keys", []) != [source] or str(body.get_meta("derived_object_key", "")) != str(target.get("tower_wall_key", "")):
			return {"ok": false, "reason": "rooftop architecture includes another source receiver"}
	var base := float((architecture.bounds as AABB).position.y)
	var configured_base := float(config.vertical_production_inference_m.get("four_story_roof_y", NAN))
	if not is_finite(base) or not is_finite(configured_base) or not is_finite(player.safe_margin) or player.safe_margin <= 0.0 or absf(base - configured_base) > player.safe_margin:
		return {"ok": false, "reason": "rooftop base does not match producer support elevation"}
	var roofs: Array[Node3D] = []
	for node in building_nodes(parent_source):
		_collect_component(node, "building_roof", roofs)
	var shapes := {}
	var key := str(target.get("building_roof_key", ""))
	for roof in roofs:
		if roof.get_meta("source_keys", []) != [parent_source] or str(roof.get_meta("config_path", "")) != config_path or str(roof.get_meta("model_id", "")) != str(config.model_id):
			continue
		for child in roof.get_children():
			var body := child as StaticBody3D
			if body == null or (body.collision_layer & player.collision_mask) == 0 or body.is_in_group("spray_receiver_wall") or body.get_meta("source_keys", []) != [parent_source] or str(body.get_meta("derived_object_key", "")) != key or str(body.get_meta("receiver_kind", "")) != "none":
				continue
			var allowed: Array[int] = []
			for owner_id in body.get_shape_owners():
				if body.is_shape_owner_disabled(owner_id) or body.shape_owner_get_shape_count(owner_id) != 1:
					continue
				var shape_node := body.shape_owner_get_owner(owner_id) as CollisionShape3D
				if shape_node == null or not shape_node.shape is ConcavePolygonShape3D:
					continue
				var shape := shape_node.shape as ConcavePolygonShape3D
				if shape.get_meta("source_keys", []) != [parent_source] or str(shape.get_meta("derived_object_key", "")) != key or str(shape.get_meta("receiver_kind", "")) != "none":
					continue
				var faces := shape.get_faces()
				var has_base_face := false
				for index in range(0, faces.size(), 3):
					var a := shape_node.global_transform * faces[index]
					var b := shape_node.global_transform * faces[index + 1]
					var c := shape_node.global_transform * faces[index + 2]
					if a.is_finite() and b.is_finite() and c.is_finite() and absf(a.y - base) <= player.safe_margin and absf(b.y - base) <= player.safe_margin and absf(c.y - base) <= player.safe_margin and not (b-a).cross(c-a).is_zero_approx():
						has_base_face = true
				if has_base_face:
					allowed.append(body.shape_owner_get_shape_index(owner_id, 0))
			if not allowed.is_empty():
				shapes[body.get_rid()] = allowed
	if shapes.is_empty():
		return {"ok": false, "reason": "no active native parent roof at tower base"}
	print("LOCAL_ROOFTOP_APPROACH source=%s parent=%s base_y=%s target_bounds=%s; no ground-to-roof walking proof" % [source, parent_source, base, architecture.bounds])
	return {"ok": true, "context": {"source": parent_source, "key": key, "shapes": shapes, "elevation": base}}


func _collect_component(node: Node, component: String, found: Array[Node3D]) -> void:
	if node is Node3D and str(node.get_meta("building_1_hero_component", "")) == component:
		found.append(node as Node3D)
		return
	for child in node.get_children():
		_collect_component(child, component, found)


func is_approach_support(hit: Dictionary, context: Dictionary = {}) -> bool:
	if context.is_empty():
		return is_walkable_ground(hit)
	var body := hit.get("collider") as CollisionObject3D
	if body == null or not context.shapes.has(body.get_rid()) or int(hit.get("shape", -1)) not in context.shapes[body.get_rid()]:
		return false
	if (body.collision_layer & player.collision_mask) == 0 or body.get_meta("source_keys", []) != [context.source] or str(body.get_meta("derived_object_key", "")) != str(context.key):
		return false
	var point: Vector3 = hit.get("position", Vector3(INF, INF, INF))
	var normal: Vector3 = hit.get("normal", Vector3.ZERO)
	return point.is_finite() and normal.is_finite() and normal.dot(player.up_direction.normalized()) >= cos(player.floor_max_angle) and absf(point.y - float(context.elevation)) <= player.safe_margin


## Why settle_player can't place the player somewhere.
const OFF_ISLAND := "off the island (water or outside the playable boundary)"
const ON_BUILDING := "on top of a building"
const STEEP := "too steep to stand"
const NOT_SETTLED := "did not settle on the ground"


## Drops the stock player at xz and lets physics settle it. Returns "" on
## success, or one of the reasons above.
func settle_player(xz: Vector2, support_context: Dictionary = {}) -> String:
	if not world.get_boundary().contains_position(Vector3(xz.x, 0.0, xz.y)):
		return OFF_ISLAND
	var hit := ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), player.collision_mask)
	if hit.is_empty():
		return OFF_ISLAND
	if not is_approach_support(hit, support_context):
		return STEEP if (hit.normal as Vector3).dot(Vector3.UP) < 0.7 else ON_BUILDING
	var y := float((hit.position as Vector3).y)
	release_input()
	player.set_gameplay_enabled(false)
	player.global_transform = Transform3D(Basis.IDENTITY, Vector3(xz.x, y + 2.0, xz.y))
	player.velocity = Vector3.DOWN * 0.1
	player.set_gameplay_enabled(true)
	for _frame in 240:
		await tree.physics_frame
		if player.is_on_floor() and absf(player.velocity.y) <= 0.05:
			player.set_gameplay_enabled(false)
			return ""
	player.set_gameplay_enabled(false)
	return NOT_SETTLED


## Points the stock gameplay camera at target, within its normal pitch limits.
func aim_camera(target: Vector3) -> void:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	var pitch := clampf(atan2(delta.y, Vector2(delta.x, delta.z).length()), deg_to_rad(rig.minimum_pitch_degrees), deg_to_rad(rig.maximum_pitch_degrees))
	rig.rotation = Vector3(0.0, atan2(-delta.x, -delta.z), 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)


func release_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		Input.action_release(action)


func clean_hud() -> void:
	tree.paused = false
	hud.set_paused(false)
	for panel: Control in [hud.debug_panel, hud.feedback_panel, hud.load_panel, hud.pause_panel]:
		panel.hide()
	hud.reticle.show()


## Waits for a few rendered frames and saves the viewport to path.
func save_screenshot(path: String) -> String:
	for _i in 4:
		clean_hud()
		await tree.process_frame
		await RenderingServer.frame_post_draw
	var error := tree.root.get_texture().get_image().save_png(path)
	return "" if error == OK else "could not save %s (error %d)" % [path, error]


## Values after "--" on the command line, as a dictionary of --key value pairs.
static func user_args() -> Dictionary:
	var args := {}
	var list := OS.get_cmdline_user_args()
	var i := 0
	while i < list.size():
		var key := list[i].trim_prefix("--")
		if i + 1 < list.size() and not list[i + 1].begins_with("--"):
			args[key] = list[i + 1]
			i += 2
		else:
			args[key] = true
			i += 1
	return args
