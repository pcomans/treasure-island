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
	var packed := load("res://game/scenes/main.tscn") as PackedScene
	main = packed.instantiate() as GameMain
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


## Ray query that never hits the player. Like the player, it doesn't see
## one-sided collision from behind (the housing roofs were invisible from above).
func ray(from: Vector3, to: Vector3, mask: int = WORLD_SOLID_MASK, exclude: Array[RID] = []) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask, exclude + [player.get_rid()])
	query.collide_with_areas = false
	query.hit_back_faces = false
	return player.get_world_3d().direct_space_state.intersect_ray(query)


## True when a downward ray hit open ground (land, road, plaza, park), not a building.
func is_walkable_ground(hit: Dictionary) -> bool:
	if hit.is_empty():
		return false
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature := str(record.get_meta("feature_kind", "")) if record != null else ""
	return feature != "" and not feature.begins_with("building") \
		and (hit.normal as Vector3).dot(Vector3.UP) >= 0.7


## Why settle_player can't place the player somewhere.
const OFF_ISLAND := "off the island (water or outside the playable boundary)"
const ON_BUILDING := "on top of a building"
const STEEP := "too steep to stand"
const NOT_SETTLED := "did not settle on the ground"


## Drops the stock player at xz and lets physics settle it. Returns "" on
## success, or one of the reasons above.
func settle_player(xz: Vector2) -> String:
	if not world.get_boundary().contains_position(Vector3(xz.x, 0.0, xz.y)):
		return OFF_ISLAND
	var hit := ray(Vector3(xz.x, 300.0, xz.y), Vector3(xz.x, -50.0, xz.y), player.collision_mask)
	if hit.is_empty():
		return OFF_ISLAND
	if not is_walkable_ground(hit):
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
