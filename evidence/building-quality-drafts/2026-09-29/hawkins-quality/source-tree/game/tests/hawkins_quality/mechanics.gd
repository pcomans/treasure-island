extends "res://game/tests/hawkins_quality/capture.gd"
var motion_trace: Array=[]
var sampled_frames:=0
var active_source:="w1249412093"
var safe_final:=false
var cases: Array=[]
var preservation: Dictionary={}
var unsafe:=false
var initial_recovery:=0
var candidate_root: Node3D
var native_shapes: Dictionary={}
var candidate_body: StaticBody3D
var candidate_shape: ConcavePolygonShape3D
var visible_faces:=PackedVector3Array()
var source_wall: Dictionary={}
var source_config: Dictionary={}

func _run() -> void:
	var manifest_path:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--manifest="):manifest_path=arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output),"Fresh mechanics output required"):await _finish(null);return
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var target: Dictionary=manifest.targets[0]
	var main: GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world: WorldLoader=main.get_node("WorldRoot")
	var player: PlayerController=main.get_node("Player")
	var ready: Array=[]
	var errors: Array=[]
	world.world_ready.connect(func(r: Dictionary):ready.append(r))
	world.world_failed.connect(func(c: String,m: String,k: Array):errors.append([c,m,k]))
	root.add_child(main)
	initial_recovery=int(world.get_runtime_evidence().recovery_count)
	var begin:=Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-begin<90000:await process_frame
	if not _require(ready.size()==1 and errors.is_empty() and world.is_world_validated(),"Validated current source world"): _receipt();await _finish(main);return
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec()-begin<90000:await physics_frame
	if not _require(player.was_first_reveal_grounded() and player.visible,"Actual initial grounded reveal"):unsafe=true;_receipt();await _finish(main);return
	if not await _rest(world,player,"initial-enabled-released-rest"): _receipt();await _finish(main);return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var owner:=_record_node_for_key(world,"building:w1249412093:wall")
	var chunk: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.chunk))
	var wall: Dictionary={};var roof: Dictionary={}
	for record: Dictionary in chunk.records:
		if record.object_key=="building:w1249412093:wall":wall=record
		if record.object_key=="building:w1249412093:roof":roof=record
	var cfg: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.config))
	source_wall=wall
	source_config=cfg
	var old_facade:=owner.find_child("Hawkins77BrutonFacade",true,false) as Node3D
	if not _require(old_facade!=null,"Exact accepted facade"): _receipt();await _finish(main);return
	var before:=_protected(world,owner)
	var model: Node3D=load(MODEL_PATH).new()
	var built:Dictionary=model.configure(wall,load("res://game/scripts/world/massing/hawkins_77_bruton_massing.gd").massing_contract())
	if not _require(bool(built.get("ok",false)) and bool(model.get_meta("build_valid",false)),"Valid candidate details"):model.free();_receipt();await _finish(main);return
	candidate_root=model
	var changed:Array=[old_facade]
	var states:Array=[]
	old_facade.visible=false
	world.add_child(model)
	await physics_frame
	preservation={"before":before,"after_install":_protected(world,owner)}
	var source_ok:=_require(before==preservation.after_install,"All original roof/wall/terrain/neighbor contacts preserved") and _native(model)
	if source_ok:
		for ray: Dictionary in manifest.rays:
			if not _ray_case(ray,world,player):break
	if _failure.is_empty() and not unsafe:
		var service: Dictionary=manifest.service
		var setup:=await _settle_player(Vector2(service.anchor[0],service.anchor[1]),"service",world,player)
		if _require(setup.get("ok",false),str(setup)):
			var aimed:=await _input_aim(player,Vector3(service.aim[0],service.aim[1],service.aim[2]),false)
			if not _require(aimed.ok,"Stock service aim"):unsafe=true
			if not unsafe and await _rest(world,player,"service-start"):
				var approach:=await _segment(world,player,"service-approach",["move_forward"],100)
				cases.append(approach)
				var signed: float=(player.global_position-Vector3(service.aim[0],service.aim[1],service.aim[2])).dot(Vector3(service.normal[0],0,service.normal[1]))
				_require(approach.safe_rest and approach.recovery_delta==0 and approach.distance>0.5 and signed>0 and signed<1.2,"Stock closed service approach")
				if _failure.is_empty() and not unsafe:
					var retreat:=await _segment(world,player,"service-retreat",["move_back"],40);cases.append(retreat)
					_require(retreat.safe_rest and retreat.recovery_delta==0 and retreat.distance>0.5,"Stock service retreat")
	if _failure.is_empty() and not unsafe:
		for spray: Dictionary in manifest.sprays:
			var result:=await _spray_case(spray,world,player);cases.append(result)
			if not result.ok or unsafe or not _failure.is_empty():break
	if _failure.is_empty() and not unsafe:
		cases.append(await _canopy_case(manifest.canopy,world,player))
	_release_all()
	safe_final=await _rest(world,player,"final-enabled-rest") if not unsafe and world.get_runtime_evidence().recovery_count==initial_recovery and player.is_on_floor() else false
	_sample(world,player,"before-final-disable",{"safe_final":safe_final})
	player.set_gameplay_enabled(false)
	_sample(world,player,"disabled-final")
	_require(not bool(player.get("_gameplay_enabled")) and player.velocity==Vector3.ZERO and _released(),"Disabled final safe inputs")
	preservation["after_cases"]=_protected(world,owner)
	_require(before==preservation.after_cases,"Non-target channels unchanged through mechanics")
	_restore_candidate(model,changed,states)
	await physics_frame
	_require(old_facade.visible,"Accepted facade visibility restored")
	_receipt();await _finish(main)

func _protected(world: WorldLoader,owner: Node3D) -> Dictionary:
	var result: Dictionary={}
	for body: CollisionObject3D in world.find_children("*","CollisionObject3D",true,false):
		if body is PlayerController or (is_instance_valid(candidate_root) and candidate_root.is_ancestor_of(body)):continue
		var shapes: Array=[]
		for child: CollisionShape3D in body.find_children("*","CollisionShape3D",true,false):
			shapes.append([child.transform,child.disabled,str(child.shape.get_faces()) if child.shape is ConcavePolygonShape3D else str(child.shape)])
		result[str(body.get_path())]=[body.global_transform,body.collision_layer,body.collision_mask,shapes]
	return result

func _native(model:Node3D)->bool:
	var detail_faces:=PackedVector3Array()
	var canopy_faces:=PackedVector3Array()
	var render_operands:Array=[]
	var render_ok:bool=model.global_transform==Transform3D.IDENTITY and not model.is_in_group("hawkins_render_only_facade") and not model.get_meta("render_only",true)
	for instance:MultiMeshInstance3D in model.get_node("RenderBatches").get_children():
		render_ok=render_ok and instance.layers==2 and instance.get_meta("receiver_kind","")=="building_wall" and instance.get_meta("source_keys",[])==[active_source]
		var poses:Array=[]
		for n in instance.multimesh.instance_count:poses.append(_transform_record(instance.multimesh.get_instance_transform(n)))
		render_operands.append({"path":str(instance.get_path()),"transform":_transform_record(instance.transform),"layer":instance.layers,"metadata":_metadata_record(instance),"instance_transforms":poses})
		var arrays:Array=instance.multimesh.mesh.surface_get_arrays(0)
		var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
		for n in instance.multimesh.instance_count:
			var pose:Transform3D=instance.transform*instance.multimesh.get_instance_transform(n)
			for index:int in arrays[Mesh.ARRAY_INDEX]:detail_faces.append(pose*vertices[index])
	var canopy:MeshInstance3D=model.get_node("EntranceCanopy")
	render_ok=render_ok and canopy.layers==1 and canopy.get_meta("receiver_kind","")=="none" and canopy.get_meta("source_keys",[])==[active_source]
	render_operands.append({"path":str(canopy.get_path()),"transform":_transform_record(canopy.transform),"layer":canopy.layers,"metadata":_metadata_record(canopy)})
	var arrays:Array=canopy.mesh.surface_get_arrays(0)
	var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	for index:int in arrays[Mesh.ARRAY_INDEX]:canopy_faces.append(canopy.transform*vertices[index])
	var groups:Dictionary={"FacadeDetailContact":detail_faces,"CanopyContact":canopy_faces}
	var exports:Dictionary={}
	var all_ok:bool=render_ok
	for name:String in groups:
		var body:StaticBody3D=model.get_node(name)
		var holder:CollisionShape3D=body.get_child(0)
		var shape:ConcavePolygonShape3D=holder.shape
		var eligible:bool=name=="FacadeDetailContact"
		var member:bool=false
		var owners:Array=[]
		for id in body.get_shape_owners():
			for i in body.shape_owner_get_shape_count(id):
				var correct:bool=body.shape_owner_get_owner(id)==holder and not body.is_shape_owner_disabled(id) and body.shape_owner_get_transform(id)==holder.transform and body.shape_owner_get_shape(id,i)==shape
				member=member or correct
				owners.append({"owner":id,"shape_index":body.shape_owner_get_shape_index(id,i),"correct":correct,"same_holder":body.shape_owner_get_owner(id)==holder,"disabled":body.is_shape_owner_disabled(id),"transform":_transform_record(body.shape_owner_get_transform(id)),"same_shape":body.shape_owner_get_shape(id,i)==shape})
		var faces:PackedVector3Array=groups[name]
		var actual:PackedVector3Array=shape.get_faces()
		var predicates:Dictionary={"render_roles":render_ok,"member":member,"holder_enabled":not holder.disabled,"holder_identity":holder.transform==Transform3D.IDENTITY,"body_identity":body.transform==Transform3D.IDENTITY,"indexed_faces_equal":faces==actual,"layer":body.collision_layer==5,"mask":body.collision_mask==0,"group":body.is_in_group("spray_receiver_wall")==eligible,"server_transform":body.global_transform==PhysicsServer3D.body_get_state(body.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)}
		for object:Object in [body,holder,shape]:
			predicates["metadata_"+str(object.get_instance_id())]=object.get_meta("source_keys",[])==[active_source] and object.get_meta("derived_object_key","")=="building:w1249412093:wall" and object.get_meta("receiver_kind","")==("building_wall" if eligible else "none") and bool(object.get_meta("opaque",false))
		var valid:bool=true
		for key:String in predicates:valid=valid and bool(predicates[key])
		native_shapes[body]=shape
		if eligible:candidate_body=body;candidate_shape=shape;visible_faces=faces
		exports[name]={"ok":valid,"predicates":predicates,"owners":owners,"body":str(body.get_path()),"rid":str(body.get_rid()),"indexed_render_faces":_face_values(faces),"collision_faces":_face_values(actual),"operands":{"model_transform":_transform_record(model.global_transform),"body_transform":_transform_record(body.transform),"body_global_transform":_transform_record(body.global_transform),"server_transform":_transform_record(PhysicsServer3D.body_get_state(body.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)),"holder_transform":_transform_record(holder.transform),"holder_disabled":holder.disabled,"layer":body.collision_layer,"mask":body.collision_mask,"receiver_group":body.is_in_group("spray_receiver_wall"),"body_metadata":_metadata_record(body),"holder_metadata":_metadata_record(holder),"shape_metadata":_metadata_record(shape),"renders":render_operands}}
		all_ok=all_ok and valid
	FileAccess.open(output.path_join("native-faces.json"),FileAccess.WRITE).store_string(JSON.stringify(exports))
	cases.append({"case":"indexed-native-faces-and-roles","ok":all_ok})
	return _require(all_ok,"Exact indexed visible/detail/canopy contact ownership")

func _face_values(faces:PackedVector3Array)->Array:
	var rows:Array=[]
	for v:Vector3 in faces:rows.append(_v(v))
	return rows

func _ray_case(row: Dictionary,world: WorldLoader,player: PlayerController) -> bool:
	var point:=Vector3(row.point[0],row.point[1],row.point[2])
	var n:=Vector3(row.normal[0],0,row.normal[1])
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(point+n*0.6,point-n*0.6,5,[player.get_rid()]))
	var distance: float=999 if hit.is_empty() else hit.position.distance_to(point)
	var valid: bool=_exact_hit(hit) and bool(_spray_region(row,hit).ok)
	cases.append({"case":row.id,"ok":valid,"expected":_v(point),"hit":_hit_record(hit),"region":_spray_region(row,hit),"expected_normal":_v(n),"distance":distance})
	return _require(valid,"Targeted actual native face "+str(row.id))

func _spray_case(row: Dictionary,world: WorldLoader,player: PlayerController) -> Dictionary:
	var record:Dictionary={"case":row.id,"ok":false}
	var setup:=await _settle_player(Vector2(row.anchor[0],row.anchor[1]),row.id,world,player)
	record["setup"]=setup
	if not _require(setup.get("ok",false),str(setup)):return record
	var aimed:=await _input_aim(player,Vector3(row.aim[0],row.aim[1],row.aim[2]),false)
	record["aim"]=aimed
	if not _require(aimed.ok,"Stock spray pitch/yaw"):unsafe=true;return record
	if not await _rest(world,player,row.id+"-start"):return record
	if not await _wait_for_active_render(player):unsafe=true;return record
	if not _safe(world):return record
	var hit:=_camera_spray_hit(player)
	var intended:=_spray_region(row,hit)
	record.merge({"hit":_hit_record(hit),"intended_region":intended,"player_range":null if hit.is_empty() else player.global_position.distance_to(hit.position),"maximum_range":player.get_spray_controller().maximum_range_m})
	if not _require(_exact_hit(hit) and bool(intended.ok) and player.global_position.distance_to(hit.position)<=player.get_spray_controller().maximum_range_m,"Actual stock first intended visible region "+str(row.id)):return record
	var controller:=player.get_spray_controller()
	var before:int=controller.tag_instances.active_count()
	var results:Array[String]=[]
	var callback:Callable=func(code:String):results.append(code)
	controller.spray_result.connect(callback)
	controller.attempt_spray()
	await process_frame
	controller.spray_result.disconnect(callback)
	var tag: Decal=null
	if controller.tag_instances.get_child_count()>before:tag=controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
	var valid: bool=results==["placed"] and controller.tag_instances.active_count()==before+1 and tag!=null and tag.cull_mask==2 and tag.get_meta("derived_object_key","")=="building:w1249412093:wall" and tag.get_meta("source_keys",[])==[active_source] and tag.global_position.distance_to(hit.position)<0.05 and is_equal_approx(tag.size.y,controller.projection_depth_m) and tag.global_basis.y.is_equal_approx(hit.normal.normalized()) and player.global_position.distance_to(hit.position)<=controller.maximum_range_m
	record.merge({"results":results,"tag_count_before":before,"tag_count_after":controller.tag_instances.active_count(),"tag":{} if tag==null else {"transform":_transform_record(tag.global_transform),"size":_v(tag.size),"cull":tag.cull_mask,"metadata":_metadata_record(tag)},"projection_depth":controller.projection_depth_m})
	_require(valid,"Actual stock decal source/cull/projector position "+str(row.id))
	var footprint: Array=[]
	if valid:
		for u in [-.5,0.0,.5]:
			for v in [-.5,0.0,.5]:
				var point: Vector3=tag.global_position+tag.global_basis.x*tag.size.x*u+tag.global_basis.z*tag.size.z*v
				var origin: Vector3=point+tag.global_basis.y*.03
				var end: Vector3=point-tag.global_basis.y*.08
				var h:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,end,5,[player.get_rid()]))
				var nearest: Variant=null
				var direction: Vector3=(end-origin).normalized()
				for i in range(0,visible_faces.size(),3):
					var point_hit: Variant=Geometry3D.ray_intersects_triangle(origin,direction,visible_faces[i],visible_faces[i+1],visible_faces[i+2])
					if point_hit!=null and (nearest==null or origin.distance_to(point_hit)<origin.distance_to(nearest)):nearest=point_hit
				var fits: bool=_exact_hit(h) and bool(_spray_region(row,h).ok) and nearest!=null and origin.distance_to(nearest)<=origin.distance_to(end) and nearest.distance_to(h.position)<0.002
				valid=valid and fits
				footprint.append({"u":u,"v":v,"fits_visible_wall_and_native":fits,"hit":_hit_record(h),"intended_region":_spray_region(row,h),"visible_point":null if nearest==null else _v(nearest),"origin":_v(origin),"end":_v(end)})
	record["footprint"]=footprint
	_require(valid,"Projector footprint fits intended visible layer2 native wall")
	if valid:await _motion_image(player,row.id)
	if unsafe or not _failure.is_empty():return record
	var rest:=await _rest(world,player,row.id+"-rest")
	record["rest"]=rest
	record["ok"]=valid and rest and not unsafe and _failure.is_empty()
	return record

func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output):return
	FileAccess.open(output.path_join("motion-trace.json"),FileAccess.WRITE).store_string(JSON.stringify({"sampled_frames":sampled_frames,"stored_records":motion_trace.size(),"records":motion_trace}))
	FileAccess.open(output.path_join("capture-receipt.json"),FileAccess.WRITE).store_string(JSON.stringify({"ok":_failure.is_empty() and safe_final,"failure":_failure,"safe_final":safe_final,"unsafe":unsafe,"initial_recovery":initial_recovery,"cases":cases,"captures":rows,"preservation":preservation},"\t")+"\n")
func _sample(world: WorldLoader,player: PlayerController,label: String,extra: Dictionary={}) -> Dictionary:
	var position := player.global_position
	var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position+Vector3.UP*0.3,position-Vector3.UP*0.6,1,[player.get_rid()]))
	var support := "" if hit.is_empty() else _derived_object_key_for_collider(hit.collider)
	var collisions: Array=[]
	for i in player.get_slide_collision_count():
		var col := player.get_slide_collision(i)
		collisions.append({"owner":_derived_object_key_for_collider(col.get_collider()),"normal":_v(col.get_normal()),"position":_v(col.get_position()),"rid":str(col.get_collider_rid()),"shape_index":col.get_collider_shape_index(),"depth":col.get_depth(),"travel":_v(col.get_travel()),"remainder":_v(col.get_remainder())})
	var row := {"source":active_source,"stage":label,"physics_frame":Engine.get_physics_frames(),"position":_v(position),"velocity":_v(player.velocity),"on_floor":player.is_on_floor(),"support":support,"support_y":null if hit.is_empty() else hit.position.y,"recovery":world.get_runtime_evidence().recovery_count,"slides":collisions,"controller_enabled":bool(player.get("_gameplay_enabled")),"released_inputs":_released()}
	row["actions"]=_input_state()
	row["physics_server_position"]=_v(PhysicsServer3D.body_get_state(player.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM).origin)
	if not hit.is_empty():
		row["support_body_path"]=str(hit.collider.get_path())
		row["support_shape_index"]=int(hit.shape)
		row["support_role"]=str(hit.collider.get_meta("family_role",""))
	row.merge(extra,true)
	sampled_frames+=1
	motion_trace.append(row)
	return row

func _v(p: Vector3) -> Array: return [p.x,p.y,p.z]

func _released() -> bool:
	for action in ["move_forward","move_back","move_left","move_right","run","jetpack","spray"]:
		if Input.is_action_pressed(action): return false
	return true

func _input_state() -> Dictionary:
	var state: Dictionary={}
	for action in ["move_forward","move_back","move_left","move_right","run","jetpack","spray"]:
		state[action]=Input.is_action_pressed(action)
	return state

func _rest(world: WorldLoader,player: PlayerController,label: String) -> bool:
	_release_all()
	player.set_gameplay_enabled(true)
	var consecutive:=0
	for frame in 180:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label)
		if not _safe(world):return false
		var current: Dictionary=motion_trace[-1]
		if player.is_on_floor() and player.velocity.length()<0.05 and not str(current.support).is_empty() and current.controller_enabled and current.released_inputs:consecutive+=1
		else:consecutive=0
		if consecutive>=8:break
	var last: Dictionary=motion_trace[-1]
	var good: bool = consecutive>=8 and player.is_on_floor() and player.velocity.length()<0.05 and not str(last.support).is_empty() and last.controller_enabled and last.released_inputs
	if not good:unsafe=true
	return _require(good and not unsafe,"Supported input-released stock rest: "+label)

func _segment(world: WorldLoader,player: PlayerController,label: String,actions: Array,frames: int) -> Dictionary:
	var start := player.global_position
	var recovery := world.get_runtime_evidence().recovery_count
	player.set_gameplay_enabled(true)
	for action: String in actions: Input.action_press(action)
	for frame in frames:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label)
		if not _safe(world):break
	_release_all()
	if unsafe or world.get_runtime_evidence().recovery_count!=recovery:
		_require(false,"Unsafe recovery; stop "+label)
		player.set_gameplay_enabled(false)
		return {"stage":label,"safe_rest":false,"recovery_delta":world.get_runtime_evidence().recovery_count-recovery,"distance":start.distance_to(player.global_position)}
	var rest := await _rest(world,player,label+"-rest")
	return {"stage":label,"start":_v(start),"end":_v(player.global_position),"distance":start.distance_to(player.global_position),"safe_rest":rest,"recovery_delta":world.get_runtime_evidence().recovery_count-recovery}

func _motion_image(player: PlayerController,stage: String) -> void:
	if not await _wait_for_active_render(player):unsafe=true;return
	if not _failure.is_empty():unsafe=true;return
	var shot: Dictionary=_save_current_view({"id":active_source+"-"+stage,"region":active_source,"intent":"Sampled actual stock motion: "+stage},output,player,{"source_key":active_source,"phase":stage,"physics_frame":Engine.get_physics_frames(),"movement_proof":true,"physics_grounded":player.is_on_floor(),"controller_enabled":bool(player.get("_gameplay_enabled")),"actions":_input_state(),"scope":"Single sampled frame; physics trace has gaps while awaiting renderer"})
	if _require(shot.get("ok",false),"Mandatory motion sample "+active_source+" "+stage): rows.append(shot.metadata)
	else:unsafe=true

func _cross_leg(destination: Vector3,anchor: Vector3,normal: Vector3,label: String,world: WorldLoader,player: PlayerController) -> Dictionary:
	var aim := destination
	aim.y=player.global_position.y+2.0
	var aimed:=await _input_aim(player,aim,true)
	if not _require(aimed.ok,"Stock corner aim"):unsafe=true;return {"ok":false,"safe_rest":false,"fatal":true}
	var before: int=int(world.get_runtime_evidence().recovery_count)
	var start_index: int=motion_trace.size()
	var arrived := false
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for i in 240:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label,{"path_depth_m":(player.global_position-anchor).dot(normal)})
		if not _safe(world):break
		if Vector2(player.global_position.x-destination.x,player.global_position.z-destination.z).length()<0.16:
			arrived=true
			break
	_release_all()
	if unsafe or int(world.get_runtime_evidence().recovery_count)!=before:
		_require(false,"Unsafe corner recovery; stop")
		player.set_gameplay_enabled(false)
		return {"ok":false,"safe_rest":false,"fatal":true}
	var rest := await _rest(world,player,label+"-rest")
	var recovery: bool=int(world.get_runtime_evidence().recovery_count)!=before
	var end_depth: float=(player.global_position-anchor).dot(normal)
	var ok: bool=arrived and rest and not recovery and absf(end_depth-(destination-anchor).dot(normal))<0.25
	_require(ok,"Stock pedestrian connection crossing "+label)
	return {"ok":ok,"safe_rest":rest,"fatal":recovery or not rest,"arrived":arrived,"final_depth_m":end_depth,"destination_depth_m":(destination-anchor).dot(normal),"trace_start":start_index,"trace_end":motion_trace.size(),"recovery_delta":int(world.get_runtime_evidence().recovery_count)-before}

func _release_all() -> void:
	_clear_gameplay_input()
	Input.action_release("spray")

func _safe(world: WorldLoader) -> bool:
	if int(world.get_runtime_evidence().recovery_count)!=initial_recovery:
		unsafe=true
		_require(false,"Recovery since initial reveal; stop later actions")
	return not unsafe

func _exact_hit(hit: Dictionary) -> bool:
	if hit.is_empty() or hit.collider!=candidate_body:return false
	var owner_id:=candidate_body.shape_find_owner(int(hit.shape))
	if candidate_body.is_shape_owner_disabled(owner_id):return false
	for i in candidate_body.shape_owner_get_shape_count(owner_id):
		if candidate_body.shape_owner_get_shape(owner_id,i)==candidate_shape:return true
	return false

func _input_aim(player: PlayerController, target: Vector3, horizontal_only: bool) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	if horizontal_only:
		delta.y = 0.0
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "Input aim target is singular."}
	var local_delta := ((rig.get_parent() as Node3D).global_basis.inverse() * delta)
	var desired_yaw := atan2(-local_delta.x, -local_delta.z)
	var desired_pitch := 0.0 if horizontal_only else atan2(delta.y, horizontal)
	if desired_pitch < deg_to_rad(rig.minimum_pitch_degrees) or desired_pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "Input aim pitch escaped stock limits."}
	player.set_gameplay_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for _attempt in 4:
		var yaw_delta := angle_difference(rig.rotation.y, desired_yaw)
		var pitch_delta := desired_pitch - arm.rotation.x
		if absf(yaw_delta) <= 0.0001 and absf(pitch_delta) <= 0.0001:
			break
		var event := InputEventMouseMotion.new()
		event.relative = Vector2(-yaw_delta / rig.look_sensitivity, -pitch_delta / rig.look_sensitivity)
		Input.parse_input_event(event)
		await process_frame
	var yaw_error := absf(angle_difference(rig.rotation.y, desired_yaw))
	var pitch_error := absf(arm.rotation.x - desired_pitch)
	return {"ok": yaw_error <= 0.001 and pitch_error <= 0.001, "input_route": "Input.parse_input_event_to_stock_PlayerCamera", "yaw_degrees": rad_to_deg(rig.rotation.y), "pitch_degrees": rad_to_deg(arm.rotation.x), "yaw_error_degrees": rad_to_deg(yaw_error), "pitch_error_degrees": rad_to_deg(pitch_error)}

func _spray_region(row:Dictionary,hit:Dictionary)->Dictionary:
	if hit.is_empty():return {"ok":false}
	var region:Dictionary=row.region_geometry
	var origin:=Vector3(region.origin[0],0,region.origin[1])
	var tangent:=Vector3(region.tangent[0],0,region.tangent[1])
	var normal:=Vector3(-tangent.z,0,tangent.x)
	var point:Vector3=hit.position
	var station:float=(point-origin).dot(tangent)
	var plane_error:float=absf((point-origin).dot(normal)-float(region.depth))
	var within:bool=station>=region.u[0] and station<=region.u[1] and point.y>=region.y[0] and point.y<=region.y[1]
	return {"ok":within and plane_error<0.002 and hit.normal.dot(normal)>0.999,"station":station,"plane_error":plane_error,"bounds":region,"aim_center_error_diagnostic_only":point.distance_to(Vector3(row.aim[0],row.aim[1],row.aim[2]))}

func _canopy_case(row:Dictionary,world:WorldLoader,player:PlayerController)->Dictionary:
	var record:Dictionary={"case":"canopy-rejection","ok":false}
	var setup:=await _settle_player(Vector2(row.anchor[0],row.anchor[1]),"canopy",world,player)
	record["setup"]=setup
	if not _require(setup.get("ok",false),str(setup)):unsafe=true;return record
	var aimed:=await _input_aim(player,Vector3(row.aim[0],row.aim[1],row.aim[2]),false)
	record["aim"]=aimed
	if not _require(aimed.ok,"Reachable stock canopy aim"):unsafe=true;return record
	if not await _rest(world,player,"canopy-start"):return record
	var hit:=_camera_spray_hit(player)
	var body:StaticBody3D=candidate_root.get_node("CanopyContact")
	var valid:bool=not hit.is_empty() and hit.collider==body and _owned_hit(hit) and body.get_meta("receiver_kind","")=="none" and player.global_position.distance_to(hit.position)<=player.get_spray_controller().maximum_range_m
	record.merge({"hit":_hit_record(hit),"player_range":null if hit.is_empty() else player.global_position.distance_to(hit.position),"maximum_range":player.get_spray_controller().maximum_range_m,"expected_body":str(body.get_path())})
	if not _require(valid,"Actual reachable canopy native first hit"):return record
	var controller:=player.get_spray_controller()
	var before:int=controller.tag_instances.active_count()
	var results:Array[String]=[]
	var callback:Callable=func(code:String):results.append(code)
	controller.spray_result.connect(callback)
	controller.attempt_spray();await process_frame
	controller.spray_result.disconnect(callback)
	valid=results==["receiver_rejection"] and controller.tag_instances.active_count()==before
	record.merge({"results":results,"tag_count_before":before,"tag_count_after":controller.tag_instances.active_count()})
	_require(valid,"Actual canopy receiver_rejection")
	var rest:=await _rest(world,player,"canopy-final-rest")
	record["rest"]=rest
	record["ok"]=valid and rest
	return record

func _owned_hit(hit:Dictionary)->bool:
	if hit.is_empty() or not native_shapes.has(hit.collider):return false
	var body:StaticBody3D=hit.collider
	var owner_id:=body.shape_find_owner(int(hit.shape))
	if body.is_shape_owner_disabled(owner_id):return false
	for i in body.shape_owner_get_shape_count(owner_id):
		if body.shape_owner_get_shape(owner_id,i)==native_shapes[body]:return true
	return false

func _transform_record(value:Transform3D)->Dictionary:
	return {"origin":_v(value.origin),"basis":[_v(value.basis.x),_v(value.basis.y),_v(value.basis.z)]}

func _metadata_record(object:Object)->Dictionary:
	return {"derived_object_key":object.get_meta("derived_object_key",""),"source_keys":object.get_meta("source_keys",[]),"receiver_kind":object.get_meta("receiver_kind",""),"opaque":object.get_meta("opaque",false)}

func _hit_record(hit:Dictionary)->Dictionary:
	if hit.is_empty():return {"hit":false}
	var body:CollisionObject3D=hit.collider
	return {"hit":true,"body":str(body.get_path()),"rid":str(body.get_rid()),"shape_index":int(hit.shape),"point":_v(hit.position),"normal":_v(hit.normal),"metadata":_metadata_record(body),"layer":body.collision_layer,"mask":body.collision_mask}
