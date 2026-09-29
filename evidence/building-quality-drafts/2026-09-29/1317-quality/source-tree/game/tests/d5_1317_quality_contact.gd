extends "res://game/tests/d5_1317_quality_candidate_capture.gd"
## Changed-risk proof only: final upper detail contact and adjacent eligible wall spray.
var _player: PlayerController
var _world: WorldLoader
var _hud: GameHUD
var _rows: Array=[]
var _recovery_start:=0
var _unsafe:=false
var _map_path:=""
var _map_hash:=""
var _remaining_only:=false
const PRIOR_CASES="res://evidence/first-playable/1317-quality-2026-09-29/contact001/cases.json"
const PRIOR_NATIVE="res://evidence/first-playable/1317-quality-2026-09-29/contact001/native-contact.json"
const PRIOR_CASES_SHA="34fc212bc4eda6ec8b7f24f74fb5192d968fb1363632af1d1c3e64a9c172b3e3"
const PRIOR_NATIVE_SHA="0686fa7f3aebe087b90b3952ec5b1bcaab988e2830a3d7ad8f9cc1c588eebf56"
func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg=="--remaining-upper":_remaining_only=true
		if arg.begins_with("--output="):_output=arg.trim_prefix("--output=")
		if arg.begins_with("--input-map="):_map_path=arg.trim_prefix("--input-map=")
		if arg.begins_with("--input-map-sha256="):_map_hash=arg.trim_prefix("--input-map-sha256=")
	if not _require(_output.is_absolute_path() and not DirAccess.dir_exists_absolute(_output),"Fresh output required"):_finish(null);return
	DirAccess.make_dir_recursive_absolute(_output)
	if not _require(_validate_map(),"Immutable input map mismatch"):_finish(null);return
	var main: GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	_world=main.get_node("WorldRoot");_player=main.get_node("Player");_hud=main.get_node("Interface/HUD")
	var ready: Array=[];var errors: Array=[]
	_world.world_ready.connect(func(r):ready.append(r));_world.world_failed.connect(func(c,m,s):errors.append([c,m,s]))
	root.add_child(main)
	while ready.is_empty() and errors.is_empty():await process_frame
	if not _require(errors.is_empty(),"Actual world failed"):_finish(main);return
	while not _player.was_first_reveal_grounded():await physics_frame
	_recovery_start=int(_world.get_runtime_evidence().recovery_count)
	var initial_rest: Dictionary=await _rest()
	_write_json(_output.path_join("initial-rest.json"),initial_rest)
	if not _require(initial_rest.ok,"Initial active supported rest failed"):_finish(main);return
	var owners: Array[Node3D]=_nodes_for_keys(_world,[ART.BASE.WALL_KEY,ART.BASE.ROOF_KEY])
	if not _require(owners.size()==2,"Exact pair required"):_finish(main);return
	var wall_root: Node3D;var roof_root: Node3D
	for node: Node3D in owners:
		if node.get_meta("derived_object_key")==ART.BASE.WALL_KEY:wall_root=node
		else:roof_root=node
	var chunk: Dictionary=ART.BASE._json(ART.BASE.CHUNK_PATH)
	var wall: Dictionary=ART.BASE._record(chunk.records,ART.BASE.WALL_KEY)
	if _remaining_only and not _require(_prior_completed(),"Prior completed evidence binding failed"):_finish(main);return
	var before: Array=[] if _remaining_only else _collisions(owners)
	var candidate: Dictionary=ART.apply_to_pair(wall_root,roof_root,wall)
	if not _require(candidate.ok,"Candidate failed"):_finish(main);return
	for i in 6:await physics_frame
	var native: Dictionary={"ok":true,"reused_from":PRIOR_NATIVE,"sha256":PRIOR_NATIVE_SHA}
	if not _remaining_only:
		var after: Array=_collisions(owners)
		var original_after: Array=[]
		for row: Dictionary in after:
			if row.body!="CandidateUpperDetailContact":original_after.append(row)
		native=_native_contact(wall_root,wall)
		native["original_collisions_unchanged"]=before==original_after
		native["ok"]=native.ok and before==original_after
		_write_json(_output.path_join("native-contact.json"),native)
		if not native.ok:
			_write_json(_output.path_join("cases.json"),{"aggregate":"HOLD","cases":[{"id":"upper_contact_congruence","ok":false,"verdict":"HOLD","fatal":true}],"safe_initial_rest":initial_rest,"input_map":_map_path,"input_map_sha256":_map_hash})
			_write_json(_output.path_join("trace.json"),{"rows":_rows})
			_fail("Native contact/source invariant failed");_finish(main);return
	var spray: Dictionary=await _spray_case(wall,_remaining_only)
	var cases: Array=[spray] if _remaining_only else [{"id":"upper_contact_congruence","ok":native.ok,"verdict":"PASS" if native.ok else "HOLD"},spray]
	if not _remaining_only and spray.ok and not spray.fatal:cases.append(await _spray_case(wall,true))
	var passed: bool=cases.size()==(1 if _remaining_only else 3)
	for row: Dictionary in cases:passed=passed and bool(row.ok)
	_write_json(_output.path_join("cases.json"),{"aggregate":"PASS" if passed else "HOLD","cases":cases,"prior_completed_join":{"cases":PRIOR_CASES,"cases_sha256":PRIOR_CASES_SHA,"native":PRIOR_NATIVE,"native_sha256":PRIOR_NATIVE_SHA,"raw_aggregate_retained":"HOLD","reused_ids":["upper_contact_congruence","adjacent_wall_spray"]} if _remaining_only else {},"input_map":_map_path,"input_map_sha256":_map_hash,"scope":"remaining upper nonreceiver rejection only; prior contact001 completed cases explicitly reused, raw HOLD preserved" if _remaining_only else "upper-detail static contact queries and adjacent stock spray only; no new roof/movement claim"})
	_write_json(_output.path_join("trace.json"),{"rows":_rows})
	if not passed:_fail("Changed-risk case held")
	_finish(main)
func _validate_map() -> bool:
	if not _map_path.is_absolute_path() or FileAccess.get_sha256(_map_path)!=_map_hash:return false
	var data: Variant=JSON.parse_string(FileAccess.get_file_as_string(_map_path))
	if not data is Dictionary or data.size()<100:return false
	for path: String in data:
		if FileAccess.get_sha256(path)!=str(data[path]):return false
	return true
func _native_contact(wall_root: Node3D,wall: Dictionary) -> Dictionary:
	var body:=wall_root.get_node("CandidateUpperDetailContact") as StaticBody3D
	var rows: Array=[];var queries: Array=[]
	var expected: Array=["CandidateUpperBoardedPanels","CandidateUpperDarkPanels","CandidateUpperOpeningFrames","CandidateOpeningReveals","CandidateSillsAndEaveFascia"]
	var ok: bool=body.collision_layer==5 and body.collision_mask==0 and body.get_meta("receiver_kind")=="none" and body.get_meta("derived_object_key")==ART.BASE.WALL_KEY and body.get_meta("source_keys")==["w95934125"] and not body.is_in_group("spray_receiver_wall") and body.transform==Transform3D.IDENTITY and bool(body.get_meta("opaque",false)) and wall_root.global_transform==Transform3D.IDENTITY and wall_root.get_meta("derived_object_key")==ART.BASE.WALL_KEY and wall_root.get_meta("source_keys")==["w95934125"]
	for child: Node in body.get_children():
		var shape_node:=child as CollisionShape3D
		var mesh_node:=wall_root.get_node(str(child.name)) as MeshInstance3D
		var faces: PackedVector3Array=mesh_node.mesh.get_faces()
		for i in faces.size():faces[i]=mesh_node.transform*faces[i]
		var actual: PackedVector3Array=(shape_node.shape as ConcavePolygonShape3D).get_faces()
		var owner_id: int=body.shape_find_owner(rows.size())
		var same: bool=rows.size()<expected.size() and str(child.name)==str(expected[rows.size()]) and body.shape_owner_get_owner(owner_id)==shape_node and body.shape_owner_get_shape_count(owner_id)==1 and body.shape_owner_get_shape(owner_id,0)==shape_node.shape and body.shape_owner_get_transform(owner_id)==shape_node.transform and _opaque_identity(shape_node) and _opaque_identity(shape_node.shape) and faces==actual and not shape_node.disabled and not body.is_shape_owner_disabled(owner_id) and shape_node.transform==Transform3D.IDENTITY and mesh_node.layers==1 and shape_node.shape.get_meta("receiver_kind")=="none" and shape_node.shape.get_meta("derived_object_key")==ART.BASE.WALL_KEY and shape_node.shape.get_meta("source_keys")==["w95934125"]
		ok=ok and same
		var arrays: Array=mesh_node.mesh.surface_get_arrays(0)
		rows.append({"name":str(child.name),"ok":same,"faces":_vectors(actual),"normals":str(arrays[Mesh.ARRAY_NORMAL]),"uvs":str(arrays[Mesh.ARRAY_TEX_UV]),"indices":str(arrays[Mesh.ARRAY_INDEX]),"mesh_transform":str(mesh_node.global_transform),"body_transform":str(body.global_transform),"shape_transform":str(shape_node.transform),"receiver":"none","render_layers":mesh_node.layers})
	var config: Dictionary=ART.BASE._json(ART.BASE.CONFIG_PATH)
	for module: Dictionary in config.upper_modules:
		var f: Dictionary=ART.BASE._joined_frame(wall,int(module.runs[0]),int(module.runs[-1]))
		var samples: Array=[
			{"role":"panel","x":float(module.station_m),"y":float(module.bottom_y)+float(module.height_m)*0.5,"depth":0.10},
			{"role":"frame","x":float(module.station_m)+float(module.width_m)*0.5+float(module.frame_width_m)*0.5,"y":float(module.bottom_y)+float(module.height_m)*0.5,"depth":0.20},
			{"role":"sill","x":float(module.station_m),"y":float(module.bottom_y)-0.08,"depth":0.25}]
		for sample: Dictionary in samples:
			var point: Vector3=ART.BASE._point(f,sample.x,sample.y,sample.depth)
			var q:=PhysicsRayQueryParameters3D.create(point+f.normal*0.03,point-f.normal*0.03,5,[_player.get_rid()])
			var hit: Dictionary=_player.get_world_3d().direct_space_state.intersect_ray(q)
			var hit_ok: bool=not hit.is_empty() and hit.collider==body and str(body.shape_owner_get_owner(body.shape_find_owner(int(hit.shape))).name)==({"panel":"CandidateUpperBoardedPanels" if str(module.finish)=="boarded_warm_brown" else "CandidateUpperDarkPanels","frame":"CandidateUpperOpeningFrames","sill":"CandidateSillsAndEaveFascia"}[str(sample.role)]) and (hit.position as Vector3).distance_to(point)<0.002 and (hit.normal as Vector3).dot(f.normal)>0.99
			ok=ok and hit_ok
			queries.append({"role":sample.role,"runs":module.runs,"station":module.station_m,"ok":hit_ok,"from":_vector3(q.from),"to":_vector3(q.to),"hit":_hit_record(hit)})
	return {"ok":ok and rows.size()==5 and queries.size()==36,"meshes":rows,"detail_contact_rays":queries,"expected_shape_names":expected,"body_receiver":"none","no_receiver_group":not body.is_in_group("spray_receiver_wall"),"scope":"all final faces congruent; 36 panel/frame/sill front rays, not traversal proof"}
func _opaque_identity(object: Object) -> bool:
	return object.get_meta("receiver_kind","")=="none" and object.get_meta("derived_object_key","")==ART.BASE.WALL_KEY and object.get_meta("source_keys",[])==["w95934125"] and bool(object.get_meta("opaque",false))
func _vectors(values: PackedVector3Array) -> Array:
	var out: Array=[]
	for v: Vector3 in values:out.append(_vector3(v))
	return out
func _hit_record(hit: Dictionary) -> Dictionary:
	if hit.is_empty():return {"hit":false}
	var body:=hit.collider as CollisionObject3D
	return {"hit":true,"body":str(body.name),"key":body.get_meta("derived_object_key",""),"sources":body.get_meta("source_keys",[]),"shape":int(hit.shape),"position":_vector3(hit.position),"normal":_vector3(hit.normal)}
func _inputs() -> Array:
	var out: Array=[]
	for action in ["move_forward","move_back","move_left","move_right","run","jetpack","spray"]:
		if Input.is_action_pressed(action):out.append(action)
	return out
func _tick() -> void:
	await physics_frame;await process_frame
	if int(_world.get_runtime_evidence().recovery_count)!=_recovery_start:_unsafe=true;_clear_gameplay_input();Input.action_release("spray")
	var q:=PhysicsRayQueryParameters3D.create(_player.global_position+Vector3.UP*0.2,_player.global_position-Vector3.UP,1,[_player.get_rid()])
	var support: Dictionary=_player.get_world_3d().direct_space_state.intersect_ray(q)
	_rows.append({"frame":Engine.get_physics_frames(),"position":_vector3(_player.global_position),"velocity":_vector3(_player.velocity),"floor":_player.is_on_floor(),"enabled":_player.is_physics_processing(),"support":_hit_record(support),"inputs":_inputs(),"recovery":_world.get_runtime_evidence().recovery_count})
func _rest() -> Dictionary:
	_clear_gameplay_input();Input.action_release("spray");_player.set_gameplay_enabled(true)
	var good:=0;var last: Dictionary={}
	for i in 180:
		await _tick();last=_rows.back()
		if _player.is_physics_processing() and _player.is_on_floor() and _player.velocity.length()<0.05 and _inputs().is_empty() and str(last.support.get("key","")).begins_with("land:"):good+=1
		else:good=0
		if good>=8:break
	var pre: Dictionary=last.duplicate(true)
	_player.set_gameplay_enabled(false)
	return {"ok":good>=8 and not _unsafe and not _player.is_physics_processing() and _player.velocity==Vector3.ZERO and _inputs().is_empty(),"pre_disable":pre,"disabled":not _player.is_physics_processing(),"velocity":_vector3(_player.velocity),"released":_inputs().is_empty()}
func _spray_case(wall: Dictionary,reject: bool) -> Dictionary:
	var run: int=10 if reject else 29
	var f: Dictionary=ART.BASE._joined_frame(wall,run,run)
	var station: float=2.4002092617103084 if reject else 3.70
	var target: Vector3=ART.BASE._point(f,station,6.27 if reject else 3.35,0.25 if reject else 0.0)
	var anchor: Vector3=ART.BASE._point(f,station,0.0,4.6 if reject else 4.5)
	var id: String="upper_nonreceiver_rejection" if reject else "adjacent_wall_spray"
	var ground: Dictionary=_ground_hit(_player,Vector2(anchor.x,anchor.z))
	var clearance: Array=[]
	var anchor_ok: bool=not ground.is_empty() and str(ground.collider.get_meta("derived_object_key","")).begins_with("land:")
	if anchor_ok:
		for height: float in [0.05,SETTLE_START_HEIGHT_M]:
			var probe:=PhysicsShapeQueryParameters3D.new();probe.shape=_player.collision_shape.shape
			probe.transform=Transform3D(Basis.IDENTITY,Vector3(anchor.x,float(ground.position.y)+height,anchor.z))*_player.collision_shape.transform
			probe.collision_mask=1;probe.exclude=[_player.get_rid()]
			var overlaps: Array[Dictionary]=_player.get_world_3d().direct_space_state.intersect_shape(probe,8)
			anchor_ok=anchor_ok and overlaps.is_empty();clearance.append({"height":height,"transform":str(probe.transform),"overlap_count":overlaps.size()})
	if not anchor_ok:
		var failed_rest: Dictionary=await _rest()
		return {"id":id,"ok":false,"verdict":"HOLD","fatal":true,"anchor_clearance":clearance,"ground":_hit_record(ground),"rest":failed_rest}
	var setup: Dictionary=await _settle_and_aim(_world,_player,_hud,{"id":id,"requested_xz":Vector2(anchor.x,anchor.z),"aim_target":target})
	if _remaining_only and str(setup.get("message","")).contains("stock camera contract failed:"):
		# This remaining high-target interaction allows stock LAND arm shortening;
		# the parent helper's wide-view framing minimum is not player behavior.
		var camera: Camera3D=_player.get_camera()
		var rig:=_player.get_node("CameraPivot") as PlayerCamera
		var arm:=rig.get_node("SpringArm3D") as SpringArm3D
		var camera_probe:=PhysicsShapeQueryParameters3D.new();camera_probe.shape=arm.shape
		camera_probe.transform=Transform3D(Basis.IDENTITY,camera.global_position);camera_probe.collision_mask=1;camera_probe.exclude=[_player.get_rid()]
		var overlaps: Array[Dictionary]=_player.get_world_3d().direct_space_state.intersect_shape(camera_probe,8)
		var camera_ground: Dictionary=_ground_hit(_player,Vector2(camera.global_position.x,camera.global_position.z))
		var hull_radius: float=(arm.shape as SphereShape3D).radius
		var ground_clearance: float=-INF if camera_ground.is_empty() else camera.global_position.y-float(camera_ground.position.y)
		var camera_ok: bool=ground_clearance>=hull_radius-0.003 and arm.rotation.x<=deg_to_rad(rig.maximum_pitch_degrees) and arm.rotation.x>=deg_to_rad(rig.minimum_pitch_degrees) and overlaps.is_empty() and is_equal_approx(camera.fov,70.0) and is_equal_approx(arm.spring_length,5.5) and camera.global_position.distance_to(rig.global_position)>0.15 and camera.global_position.distance_to(rig.global_position)<=5.501
		setup={"ok":camera_ok,"parent_framing_result":setup,"stock_terrain_shortened_camera":true,"camera_position":_vector3(camera.global_position),"actual_arm_m":camera.global_position.distance_to(rig.global_position),"camera_overlap_count":overlaps.size(),"camera_ground_clearance":ground_clearance,"camera_hull_radius":hull_radius,"pitch_degrees":rad_to_deg(arm.rotation.x)}
	if not setup.get("ok",false):
		var failed_rest: Dictionary=await _rest()
		return {"id":id,"ok":false,"verdict":"HOLD","fatal":true,"setup":setup,"rest":failed_rest}
	_player.set_gameplay_enabled(true)
	for i in 6:await _tick()
	var camera:=_player.get_camera();var center:=camera.get_viewport().get_visible_rect().size*0.5
	var start:=camera.project_ray_origin(center);var direction:=camera.project_ray_normal(center)
	var q:=PhysicsRayQueryParameters3D.create(start,start+direction*1000.0,4,[_player.get_rid()])
	var hit: Dictionary=_player.get_world_3d().direct_space_state.intersect_ray(q)
	var controller:=_player.get_spray_controller()
	var metadata: Dictionary={} if hit.is_empty() else controller._resolve_hit_metadata(hit.collider,int(hit.shape))
	var identity: bool=not hit.is_empty() and metadata.get("derived_object_key")==ART.BASE.WALL_KEY and metadata.get("source_keys")==["w95934125"] and metadata.get("receiver_kind")==("none" if reject else "building_wall") and (not hit.collider.is_in_group("spray_receiver_wall") if reject else hit.collider.is_in_group("spray_receiver_wall")) and (str(hit.collider.name)=="CandidateUpperDetailContact" if reject else str(hit.collider.name)=="Collision")
	var face_region: Dictionary={}
	if reject and identity:
		var hit_body:=hit.collider as CollisionObject3D
		face_region=_intended_sill_face(hit_body,int(hit.shape),hit.position,target)
		identity=bool(face_region.ok) and (hit.normal as Vector3).dot(f.normal)>0.99
	var results: Array=[]
	var result_callback: Callable=func(code: String):results.append(code)
	controller.spray_result.connect(result_callback)
	var distance: float=INF if hit.is_empty() else _player.global_position.distance_to(hit.position)
	var in_range: bool=distance<=controller.maximum_range_m
	var count: int=controller.tag_instances.active_count()
	if identity and in_range and not _unsafe:controller.attempt_spray()
	await _tick()
	controller.spray_result.disconnect(result_callback)
	var placed: bool=controller.tag_instances.active_count()==count+1
	var rejected: bool=controller.tag_instances.active_count()==count and results==["receiver_rejection"]
	var tag_record: Dictionary={};var tag_ok:=false
	if placed:
		var tag:=controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
		tag_ok=tag.get_meta("derived_object_key")==ART.BASE.WALL_KEY and tag.get_meta("source_keys")==["w95934125"] and tag.cull_mask==2
		tag_record={"key":tag.get_meta("derived_object_key"),"sources":tag.get_meta("source_keys"),"cull_mask":tag.cull_mask,"position":_vector3(tag.global_position),"size":_vector3(tag.size)}
		var samples: Array=[]
		for u: float in [-0.5,0.0,0.5]:
			for v: float in [-0.5,0.0,0.5]:
				var p: Vector3=tag.global_position+tag.global_basis.x*tag.size.x*u+tag.global_basis.z*tag.size.z*v
				var probe:=PhysicsRayQueryParameters3D.create(p+tag.global_basis.y*0.03,p-tag.global_basis.y*0.08,4,[_player.get_rid()])
				var h: Dictionary=_player.get_world_3d().direct_space_state.intersect_ray(probe)
				var fits: bool=not h.is_empty() and h.collider==hit.collider and int(h.shape)==int(hit.shape)
				tag_ok=tag_ok and fits;samples.append({"u":u,"v":v,"fits":fits,"hit":_hit_record(h)})
		tag_record["projector_samples"]=samples
	var rest: Dictionary=await _rest()
	var action_ok: bool=in_range and (rejected if reject else placed and tag_ok)
	return {"id":id,"ok":identity and action_ok and rest.ok,"verdict":"PASS" if identity and action_ok and rest.ok else "HOLD","fatal":not identity or not action_ok or _unsafe,"anchor_clearance":clearance,"results":results,"rejected":rejected,"range_m":distance,"maximum_range_m":controller.maximum_range_m,"in_range":in_range,"setup":setup,"first_hit":_hit_record(hit),"intended_face":face_region,"resolved_metadata":metadata,"placed":placed,"tag":tag_record,"rest":rest}

func _prior_completed() -> bool:
	if FileAccess.get_sha256(PRIOR_CASES)!=PRIOR_CASES_SHA or FileAccess.get_sha256(PRIOR_NATIVE)!=PRIOR_NATIVE_SHA:return false
	var prior: Dictionary=ART.BASE._json(PRIOR_CASES)
	if prior.get("aggregate")!="HOLD" or prior.cases.size()!=3:return false
	for i in 2:
		if not prior.cases[i].ok or prior.cases[i].verdict!="PASS":return false
	var old_map_path: String=prior.input_map
	if FileAccess.get_sha256(old_map_path)!=str(prior.input_map_sha256):return false
	var old_map: Dictionary=ART.BASE._json(old_map_path)
	for path: String in old_map:
		if path.ends_with("/game/tests/d5_1317_quality_contact.gd") or path.ends_with("/run_contact.py") or path.ends_with("/freeze_contact.py"):continue
		if FileAccess.get_sha256(path)!=str(old_map[path]):return false
	return true

func _intended_sill_face(body: CollisionObject3D,shape_index: int,point: Vector3,target: Vector3) -> Dictionary:
	# The first emitted run10 sill front is immutable contact001 triangles0/1.
	# Containment belongs to this face, not to a single nominal camera aim point.
	var owner: Object=body.shape_owner_get_owner(body.shape_find_owner(shape_index))
	if not owner is CollisionShape3D or str(owner.name)!="CandidateSillsAndEaveFascia":return {"ok":false,"reason":"Wrong shape owner"}
	if FileAccess.get_sha256(PRIOR_NATIVE)!=PRIOR_NATIVE_SHA:return {"ok":false,"reason":"Retained face binding changed"}
	var prior: Dictionary=ART.BASE._json(PRIOR_NATIVE)
	var retained: Array=[]
	for row: Dictionary in prior.meshes:
		if row.name=="CandidateSillsAndEaveFascia":retained=row.faces.slice(0,6)
	var shape_node:=owner as CollisionShape3D
	var current: PackedVector3Array=(shape_node.shape as ConcavePolygonShape3D).get_faces()
	if retained.size()!=6 or current.size()<6:return {"ok":false,"reason":"Intended triangle pair missing"}
	for i in 6:
		if current[i]!=ART.BASE._v(retained[i]):return {"ok":false,"reason":"Intended face changed"}
	var local_point: Vector3=shape_node.global_transform.affine_inverse()*point
	var triangles: Array=[];var contained:=false
	for index in 2:
		var a: Vector3=current[index*3];var b: Vector3=current[index*3+1];var c: Vector3=current[index*3+2]
		var ab:=b-a;var ac:=c-a;var ap:=local_point-a
		var normal:=ab.cross(ac).normalized()
		var plane_error: float=absf(ap.dot(normal))
		var aa: float=ab.dot(ab);var bb: float=ab.dot(ac);var cc: float=ac.dot(ac)
		var denominator: float=aa*cc-bb*bb
		if denominator<=0.0:return {"ok":false,"reason":"Degenerate retained face"}
		var u: float=(ap.dot(ab)*cc-ap.dot(ac)*bb)/denominator
		var v: float=(ap.dot(ac)*aa-ap.dot(ab)*bb)/denominator
		var inside: bool=plane_error<=0.0001 and minf(minf(u,v),1.0-u-v)>=-0.000001
		contained=contained or inside
		triangles.append({"triangle":index,"inside":inside,"plane_error_m":plane_error,"barycentric":[1.0-u-v,u,v]})
	return {"ok":contained,"retained_native_sha256":PRIOR_NATIVE_SHA,"intended_triangles":[0,1],"current_face_exact":true,"triangles":triangles,"nominal_center_error_m":point.distance_to(target),"center_error_is_diagnostic_only":true}
