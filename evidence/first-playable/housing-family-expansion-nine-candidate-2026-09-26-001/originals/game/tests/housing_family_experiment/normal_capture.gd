extends "res://game/tests/rendered_visual_evidence_capture.gd"
const FAMILY = preload("res://game/scripts/world/facades/housing_site_family.gd")
var output := ""
var rows: Array = []
var mechanics_only := false
var completed := false
var reuse_contact_run := ""
var checks: Array = []
var land_cache: Dictionary = {}
var current_topology: Dictionary = {}

func _initialize() -> void:
	create_timer(480.0,true,false,true).timeout.connect(func(): _fail("Experiment timeout"); _receipt(); quit(1))
	call_deferred("_run")

func _run() -> void:
	var manifest_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg=="--mechanics-only": mechanics_only=true
		if arg.begins_with("--reuse-contact-run="): reuse_contact_run=arg.trim_prefix("--reuse-contact-run=")
		if arg.begins_with("--manifest="): manifest_path = arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="): output = arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output), "Fresh output required"):
		await _finish(null)
		return
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready: Array = []
	var errors: Array = []
	world.world_ready.connect(func(r: Dictionary): ready.append(r))
	world.world_failed.connect(func(c: String,m: String,k: Array): errors.append([c,m,k]))
	root.add_child(main)
	var begin := Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-begin < 45000: await process_frame
	await physics_frame
	await physics_frame
	if not _require(errors.is_empty() and ready.size()==1 and world.is_world_validated(), "Source world load: %s" % [errors]):
		_receipt()
		await _finish(main)
		return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if not mechanics_only:
		for target: Dictionary in manifest.targets:
			var row: Dictionary = target.duplicate(true)
			row.requested_xz=Vector2(target.requested_xz[0],target.requested_xz[1])
			row.aim_target=FAMILY.vec(target.aim_target)
			var settled := await _settle_player(row.requested_xz,row.id,world,player)
			if not _require(settled.get("ok",false),str(settled)): break
			_aim_camera_at(player,row.aim_target)
			if not await _wait_for_render(player): break
			row.id=target.id+"-LIVE"
			var saved := _save_current_view(row,output,player,{"phase":"LIVE","source_key":target.source_key,"scope":"Normal WorldLoader family integration"})
			if not _require(saved.get("ok",false),str(saved)): break
			rows.append(saved.metadata)
			_receipt()
		if rows.size()!=manifest.targets.size():
			_fail("Incomplete normal-play captures")
			_receipt()
			await _finish(main)
			return
	if mechanics_only:
		var last: Dictionary = manifest.targets[-1]
		var settled := await _settle_player(Vector2(last.requested_xz[0],last.requested_xz[1]),"mechanics-street",world,player)
		if not _require(settled.get("ok",false),str(settled)):
			_receipt()
			await _finish(main)
			return
		_aim_camera_at(player,FAMILY.vec(last.aim_target))
	if not _verify_family(world,reuse_contact_run.is_empty()):
		_receipt()
		await _finish(main)
		return
	# Representative stock input motion in the settled final street view.
	player.set_gameplay_enabled(true)
	var motion_recovery := world.get_runtime_evidence().recovery_count
	var motion_start := player.global_position
	Input.action_press("move_forward")
	for frame in 30: await physics_frame
	Input.action_release("move_forward")
	for frame in 30: await physics_frame
	var walked := player.global_position.distance_to(motion_start)
	if not _require(walked>0.3 and walked<4.0 and player.is_on_floor() and world.get_runtime_evidence().recovery_count==motion_recovery,"Representative stock walk displacement "+str(walked)):
		_receipt()
		await _finish(main)
		return
	checks.append({"stock_walk_m":walked,"grounded":player.is_on_floor(),"recovery_delta":world.get_runtime_evidence().recovery_count-motion_recovery})
	print("FAMILY_STOCK_WALK distance=",walked," grounded=",player.is_on_floor()," velocity=",player.velocity)
	if not await _stock_family_spray(world,player):
		_receipt()
		await _finish(main)
		return
	# Lifecycle proof uses the real loader, not a second attachment call.
	_clear_gameplay_input()
	if not _require(player.is_on_floor() and player.velocity.length()<0.05,"Stock rest before reload"):
		_receipt()
		await _finish(main)
		return
	player.set_gameplay_enabled(false)
	var before_reload: Dictionary = current_topology.duplicate(true)
	world.load_world()
	await physics_frame
	await physics_frame
	if _require(world.is_world_validated(),"Reload source validation") and _verify_family(world,reuse_contact_run.is_empty()):
		completed=_require(current_topology==before_reload,"Reload topology/cleanup equality")
	_receipt()
	await _finish(main)

func _verify_family(world: WorldLoader, sample_contacts := true) -> bool:
	var found: Dictionary = {}
	var sampled := 0
	var contact_failures: Array[String] = []
	for node: Node in world.find_children("SharedHousing_*","Node3D",true,false):
		var source := str(node.get_meta("source_key",""))
		if not _require(not found.has(source),"Duplicate live instance "+source): return false
		found[source]=true
		var bodies := 0
		var mesh_samples := 0
		var mesh_inventory := 0
		var tiny_meshes := 0
		var buried_meshes := 0
		var case_failures := 0
		for child: Node in node.get_children():
			if child is StaticBody3D:
				bodies+=1
				var wall := str(child.get_meta("family_role",""))=="wall"
				if not _require(child.collision_layer==(5 if wall else 1) and child.is_in_group("spray_receiver_wall")==wall,"Family collision/spray role "+source): return false
			elif child is MeshInstance3D:
				var mesh := child as MeshInstance3D
				var role := str(mesh.get_meta("family_role","support"))
				if not _require(mesh.layers==(2 if role=="wall" else 1),"Family render role "+source): return false
				mesh_inventory+=1
				if not sample_contacts: continue
				var faces := mesh.mesh.get_faces()
				var candidate_faces: Array[Dictionary] = []
				var largest_area := 0.0
				for i in range(0,faces.size(),3):
					var a := mesh.global_transform*faces[i]
					var b := mesh.global_transform*faces[i+1]
					var c := mesh.global_transform*faces[i+2]
					var cross := (b-a).cross(c-a)
					var area := cross.length()/2
					largest_area=maxf(largest_area,area)
					if area<0.0001: continue
					candidate_faces.append({"a":a,"b":b,"c":c,"normal":cross.normalized(),"area":area,"index":i})
				if largest_area<0.0001:
					tiny_meshes+=1
					print("FAMILY_TINY_CONTACT_UNRESOLVED source=",source," mesh=",mesh.get_index()," max_triangle_area=",largest_area)
					continue
				candidate_faces.sort_custom(func(a: Dictionary,b: Dictionary): return a.area>b.area)
				var chosen: Dictionary = {}
				var maximum_clearance := -INF
				for face: Dictionary in candidate_faces:
					var center: Vector3 = (face.a+face.b+face.c)/3
					for point: Vector3 in [center,face.a*0.7+center*0.3,face.b*0.7+center*0.3,face.c*0.7+center*0.3]:
						var terrain := _source_land_height(source,point)
						if is_inf(terrain):
							_require(false,"Missing source land for "+source+" at "+str(point))
							return false
						var clearance := point.y-terrain
						maximum_clearance=maxf(maximum_clearance,clearance)
						if clearance>0.002:
							chosen=face.duplicate()
							chosen.point=point
							chosen.land_clearance=clearance
							break
					if not chosen.is_empty(): break
				if chosen.is_empty():
					buried_meshes+=1
					print("FAMILY_GRADE_OCCLUDED_CONTACT source=",source," mesh=",mesh.get_index()," sampled_max_clearance=",maximum_clearance," scope=retained_geometry_no_stable_exposed_probe")
					continue
				var center: Vector3 = chosen.point
				var normal: Vector3 = chosen.normal
				var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(center-normal*0.035,center+normal*0.035,1))
				if hit.is_empty(): hit=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(center+normal*0.035,center-normal*0.035,1))
				var matches: bool = not hit.is_empty() and (hit.position as Vector3).distance_to(center)<0.036 and (source in hit.collider.get_meta("source_keys",[]) or _verified_ground_overlap(source,role,center,hit))
				if not matches:
					case_failures+=1
					var actual_owner: Variant = [] if hit.is_empty() else hit.collider.get_meta("source_keys",[])
					var message := "Exposed contact mismatch source=%s role=%s mesh=%s sample=%s land_clearance=%s actual_owner=%s hit=%s" % [source,role,mesh.get_index(),center,chosen.land_clearance,actual_owner,hit]
					contact_failures.append(message)
					print("FAMILY_CONTACT_HOLD ",message)
				else: mesh_samples+=1
		if not _require(bodies>=2 and mesh_inventory>0,"Missing live body/mesh "+source): return false
		sampled+=mesh_samples
		print("FAMILY_LIVE_FIT source=",source," bodies=",bodies," mesh_contact_samples=",mesh_samples," tiny_meshes_not_ray_proved=",tiny_meshes," grade_occluded_meshes=",buried_meshes," failures=",case_failures," mesh_inventory=",mesh_inventory," reused_contact_run=",reuse_contact_run)
		checks.append({"source":source,"samples":mesh_samples,"tiny_unresolved":tiny_meshes,"grade_occluded":buried_meshes,"failures":case_failures})
	var topology := {"visible_meshes":0,"visible_surfaces":0,"visible_triangles":0,"active_bodies":0,"active_shapes":0,"disabled_bodies":0}
	for child: Node in world.find_children("*","Node3D",true,false):
		if child is MeshInstance3D and child.is_visible_in_tree() and child.mesh != null:
			topology.visible_meshes+=1
			topology.visible_surfaces+=child.mesh.get_surface_count()
			topology.visible_triangles+=child.mesh.get_faces().size()/3
		elif child is StaticBody3D:
			if child.collision_layer==0: topology.disabled_bodies+=1
			else:
				topology.active_bodies+=1
				for shape: Node in child.get_children():
					if shape is CollisionShape3D and not shape.disabled: topology.active_shapes+=1
	current_topology=topology.duplicate(true)
	checks.append({"topology":topology})
	print("FAMILY_CURRENT_TOPOLOGY ",JSON.stringify(topology))
	print("FAMILY_LIVE_TOTAL instances=",found.size()," mesh_contact_samples=",sampled)
	if not contact_failures.is_empty():
		_require(false,"Aggregate exposed contact HOLD: "+str(contact_failures.size())+" mismatches; all logged")
		return false
	return _require(found.size()==24,"Expected24 normal-load instances")

func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output): return
	var file := FileAccess.open(output.path_join("capture-receipt.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"ok":completed and _failure.is_empty(),"failure":_failure,"captures":rows,"scope":"Normal-load source integration; representative stock motion and per-instance exposed contact samples","checks":checks,"reused_contact_stage":reuse_contact_run,"reused_visuals":"live-integration-005" if mechanics_only else ""},"\t")+"\n")

func _stock_family_spray(world: WorldLoader, player: PlayerController) -> bool:
	var models := world.find_children("SharedHousing_w96215646","Node3D",true,false)
	if not _require(models.size()==1,"1394 stock probe owner"): return false
	var target := Vector3.ZERO
	var outward := Vector3.ZERO
	for child: Node in models[0].get_children():
		if not child is MeshInstance3D or str(child.get_meta("family_role",""))!="wall": continue
		var faces: PackedVector3Array = child.mesh.get_faces()
		for i in range(0,faces.size(),3):
			var a: Vector3=child.global_transform*faces[i]
			var b: Vector3=child.global_transform*faces[i+1]
			var c: Vector3=child.global_transform*faces[i+2]
			var cross: Vector3=(b-a).cross(c-a)
			var center: Vector3=(a+b+c)/3
			if cross.length()>1.0 and center.y>4.0 and center.y<7.2 and (-cross.normalized()).x< -0.8:
				target=center
				outward=-cross.normalized()
				break
		if outward.length()>0.5: break
	if not _require(outward.length()>0.5,"Substantial west wall for stock spray"): return false
	var anchor := target+outward*2.0
	var ground := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(anchor.x,30,anchor.z),Vector3(anchor.x,-10,anchor.z),1,[player.get_rid()]))
	if not _require(not ground.is_empty(),"Stock approach ground"): return false
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	player.global_position=ground.position+Vector3.UP*0.35
	player.velocity=Vector3.ZERO
	player.set_gameplay_enabled(true)
	var recovery := world.get_runtime_evidence().recovery_count
	for frame in 90: await physics_frame
	if not _require(player.is_on_floor() and world.get_runtime_evidence().recovery_count==recovery,"Stock approach settled without recovery"): return false
	_aim_camera_at(player,target)
	if not await _wait_for_render(player): return false
	var hit := _camera_spray_hit(player)
	if not _require(not hit.is_empty() and str(hit.collider.get_meta("derived_object_key",""))=="building:w96215646:wall","Stock spray source first hit"): return false
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	controller.attempt_spray()
	await process_frame
	if not _require(controller.tag_instances.active_count()==before+1,"Actual stock spray placement"): return false
	var tag := controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
	if not _require(tag!=null and tag.cull_mask==2 and str(tag.get_meta("derived_object_key",""))=="building:w96215646:wall" and tag.get_meta("source_keys",[])==["w96215646"] and tag.global_position.distance_to(hit.position)<0.05,"Placed decal source/layer/position"): return false
	checks.append({"stock_spray":"placed","source":"w96215646","decal_cull_mask":tag.cull_mask,"grounded":player.is_on_floor(),"recovery_delta":world.get_runtime_evidence().recovery_count-recovery})
	var saved := _save_current_view({"id":"1394-stock-spray","region":"w96215646","intent":"Actual stock spray/contact representative"},output,player,{"phase":"mechanics","source_key":"w96215646","scope":"Representative motion only; per-building ray coverage logged separately"})
	if saved.get("ok",false): rows.append(saved.metadata)
	print("FAMILY_STOCK_SPRAY placed=1 source=w96215646 grounded=",player.is_on_floor()," target=",target," hit=",hit.position)
	return _require(saved.get("ok",false),"Stock spray image")

func _settle_player(requested_xz: Vector2, capture_id: String, world: WorldLoader, player: PlayerController, expected_terrain_y_m := INF) -> Dictionary:
	var boundary := world.get_boundary()
	var requested_position := Vector3(requested_xz.x, 0.0, requested_xz.y)
	if not boundary.contains_position(requested_position):
		return {"ok": false, "message": "%s anchor is outside the playable boundary." % capture_id}
	var hit := _ground_hit(requested_xz, player)
	if hit.is_empty():
		return {"ok": false, "message": "%s anchor did not ray-hit generated collision." % capture_id}
	var collider := hit.get("collider") as Node
	var record := collider.get_parent() if collider != null else null
	var feature_kind := "" if record == null else str(record.get_meta("feature_kind", ""))
	var family_ground := collider != null and str(collider.get_meta("family_role",""))=="ground" and str(collider.get_meta("derived_object_key","")).begins_with("building:w")
	if family_ground:
		feature_kind="installed_family_ground"
		record=collider
	if feature_kind != "land_ground" and not family_ground:
		return {"ok": false, "message": "%s anchor hit %s rather than land_ground." % [capture_id, feature_kind]}
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	var ground_y := float(hit.position.y)
	if not is_inf(expected_terrain_y_m) and absf(ground_y - expected_terrain_y_m) > 0.35:
		return {"ok": false, "message": "%s terrain elevation %.3f differs from its USGS anchor %.3f." % [capture_id, ground_y, expected_terrain_y_m]}
	var spawn_position := Vector3(requested_xz.x, ground_y + SETTLE_START_HEIGHT_M, requested_xz.y)
	player.global_transform = Transform3D(Basis.IDENTITY, spawn_position)
	player.velocity = Vector3.ZERO
	player.force_update_transform()
	var recovery_count_before := world.get_runtime_evidence().recovery_count
	paused = false
	player.set_gameplay_enabled(true)
	var settled := false
	var settle_frames := 0
	for frame in SETTLE_MAX_PHYSICS_FRAMES:
		paused = false
		await physics_frame
		settle_frames = frame + 1
		if player.is_on_floor() \
		and absf(player.global_position.y - ground_y) <= SETTLE_CLEARANCE_TOLERANCE_M \
		and absf(player.velocity.y) <= 0.05:
			settled = true
			break
	var settled_position := player.global_position
	var recovery_delta := world.get_runtime_evidence().recovery_count - recovery_count_before
	_clear_gameplay_input()
	player.set_gameplay_enabled(false)
	if not settled:
		return {"ok": false, "message": "%s player did not settle within %d physics frames." % [capture_id, SETTLE_MAX_PHYSICS_FRAMES]}
	var horizontal_drift := Vector2(settled_position.x - requested_xz.x, settled_position.z - requested_xz.y).length()
	var clearance := settled_position.y - ground_y
	if horizontal_drift > 0.05 or absf(clearance) > SETTLE_CLEARANCE_TOLERANCE_M or recovery_delta != 0:
		return {"ok": false, "message": "%s invalid settlement: drift=%.3f clearance=%.3f recovery_delta=%d." % [capture_id, horizontal_drift, clearance, recovery_delta]}
	print("VISUAL_SETTLED: id=%s spawn_y=%.3f settled_y=%.3f ground_y=%.3f clearance=%.3f frames=%d recovery_delta=%d" % [
		capture_id, spawn_position.y, settled_position.y, ground_y, clearance, settle_frames, recovery_delta,
	])
	return {
		"ok": true,
		"metadata": {
			"scenario_reset": "fixed_player_transform_then_physics_settle",
			"movement_proof": false,
			"input_driven_after_reset": false,
			"physics_grounded": true,
			"settle_spawn_y": spawn_position.y,
			"settled_y": settled_position.y,
			"ground_y": ground_y,
			"ground_clearance_m": clearance,
			"settle_physics_frames": settle_frames,
			"settle_horizontal_drift_m": horizontal_drift,
			"settle_recovery_delta": recovery_delta,
			"ground_feature": feature_kind,
			"ground_object": "" if record == null else str(record.get_meta("derived_object_key", record.name)),
			"ground_sources": [] if record == null else record.get_meta("source_keys", []),
			"in_boundary": boundary.contains_position(settled_position),
		},
	}


func _verified_ground_overlap(source: String, role: String, point: Vector3, hit: Dictionary) -> bool:
	if role!="ground" or str(hit.collider.get_meta("family_role",""))!="ground": return false
	var actual: Array = hit.collider.get_meta("source_keys",[])
	if actual.size()!=1: return false
	var live: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/housing_family/live_instances.json"))
	var known := false
	for item: Dictionary in live.instances:
		if str(item.source_key)==str(actual[0]): known=true
	if not known: return false
	var expected_y := _ground_config_height(source,point)
	var actual_y := _ground_config_height(str(actual[0]),hit.position)
	if is_inf(expected_y) or is_inf(actual_y) or absf(expected_y-point.y)>0.001 or absf(actual_y-expected_y)>0.036 or absf(float(hit.position.y)-actual_y)>0.001: return false
	print("FAMILY_VERIFIED_GROUND_OVERLAP expected=",source," actual=",actual[0]," position=",point," expected_y=",expected_y," actual_y=",actual_y)
	return true

func _ground_config_height(source: String, point: Vector3) -> float:
	var cfg: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/housing_family/"+source+".json"))
	var surfaces: Array = cfg.get("local_ground",{}).values()
	for frame: Dictionary in cfg.target.frames:
		for entry: Dictionary in frame.get("entries",[]): surfaces.append(entry.get("path_mesh",{}))
	for surface: Dictionary in surfaces:
		for triangle: Array in surface.get("top_triangles",[]):
			var a := FAMILY.vec(triangle[0])
			var b := FAMILY.vec(triangle[1])
			var c := FAMILY.vec(triangle[2])
			var determinant := (b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
			if absf(determinant)<0.000001: continue
			var u := ((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.z-c.z))/determinant
			var v := ((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.z-c.z))/determinant
			if minf(u,minf(v,1-u-v))>=-0.00001: return u*a.y+v*b.y+(1-u-v)*c.y
	return INF

func _source_land_height(source: String, point: Vector3) -> float:
	if not land_cache.has("manifest"):
		land_cache["manifest"]=JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/manifest.json"))
	var manifest: Dictionary = land_cache.manifest
	var size := float(manifest.chunk_size_m)
	var tile := "x_%d__z_%d" % [floori(point.x/size),floori(point.z/size)]
	if not land_cache.has(tile):
		var triangles: Array = []
		for item: Dictionary in manifest.chunks:
			if str(item.chunk_id)!=tile: continue
			var chunk: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/"+str(item.path)))
			for record: Dictionary in chunk.records:
				if str(record.feature_kind)!="land_ground": continue
				for i in range(0,record.indices.size(),3):
					var tri: Array[Vector3] = []
					for j in 3:
						var index := int(record.indices[i+j])*3
						tri.append(Vector3(record.vertices[index],record.vertices[index+1],record.vertices[index+2]))
					triangles.append(tri)
		land_cache[tile]=triangles
	for tri: Array in land_cache[tile]:
		var a: Vector3=tri[0]
		var b: Vector3=tri[1]
		var c: Vector3=tri[2]
		var determinant := (b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
		if absf(determinant)<0.000001: continue
		var u := ((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.z-c.z))/determinant
		var v := ((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.z-c.z))/determinant
		if minf(u,minf(v,1-u-v))>=-0.00001: return u*a.y+v*b.y+(1-u-v)*c.y
	return INF
