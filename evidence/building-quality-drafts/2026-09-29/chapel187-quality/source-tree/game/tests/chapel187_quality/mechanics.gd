extends "res://game/tests/chapel187_quality/capture.gd"
class NativeObserver extends Node:
	var callback:Callable
	func _physics_process(_delta:float)->void:callback.call()

var native_pre:Dictionary={}
var native_rows:Array=[]
var native_pre_observer:NativeObserver
var native_post_observer:NativeObserver
var native_world:WorldLoader
var native_label:String="initial"
var native_setup_active:=false
var execution_scope:="full"
var motion_trace: Array=[]
var sampled_frames:=0
var active_source:="w291189336"
var safe_final:=false
var cases: Array=[]
var preservation: Dictionary={}
var unsafe:=false
var initial_recovery:=0
var candidate_body: StaticBody3D
var candidate_shape: ConcavePolygonShape3D
var visible_faces:=PackedVector3Array()
var native_shapes:Dictionary={}
var active_model:Node3D
var owned_player:PlayerController
var saved_changed:Array=[]
var saved_states:Array=[]
var source_wall: Dictionary={}
var source_config: Dictionary={}

func _initialize()->void:
	create_timer(480.0,true,false,true).timeout.connect(_emergency_timeout)
	call_deferred("_run")

func _emergency_timeout()->void:
	unsafe=true;_fail("Mechanics timeout; HOLD")
	_release_all()
	if is_instance_valid(owned_player):owned_player.set_gameplay_enabled(false)
	if is_instance_valid(active_model):_restore_candidate(active_model,saved_changed,saved_states)
	_receipt();quit(1)

func _run() -> void:
	var manifest_path:=""
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--manifest="):manifest_path=arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output),"Fresh mechanics output required"):await _finish(null);return
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	execution_scope=str(manifest.get("execution_scope","full"))
	if not _require(execution_scope in ["full","remaining-roof"],"Declared mechanics scope"):await _finish(null);return
	var target: Dictionary=manifest.targets[0]
	var main: GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world: WorldLoader=main.get_node("WorldRoot")
	var player: PlayerController=main.get_node("Player")
	owned_player=player
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
	var stock_holder:CollisionShape3D=player.get_node("CollisionShape3D")
	var stock_capsule:CapsuleShape3D=stock_holder.shape
	var capsule_ok:bool=stock_capsule!=null and is_equal_approx(stock_capsule.radius,.35) and is_equal_approx(stock_capsule.height,1.8) and stock_holder.transform.is_equal_approx(Transform3D(Basis.IDENTITY,Vector3(0,.9,0))) and not stock_holder.disabled and not player.is_shape_owner_disabled(player.shape_find_owner(0)) and PhysicsServer3D.body_get_shape_count(player.get_rid())==1
	if not _require(capsule_ok,"Actual stock capsule/holder for native reconstruction"):unsafe=true;_receipt();await _finish(main);return
	native_world=world
	native_pre_observer=NativeObserver.new();native_pre_observer.process_physics_priority=player.process_physics_priority-100
	native_pre_observer.callback=func():native_pre=_native_state(player)
	main.add_child(native_pre_observer)
	native_post_observer=NativeObserver.new();native_post_observer.process_physics_priority=player.process_physics_priority+100
	native_post_observer.callback=func():
		var record:Dictionary=_native_state(player)
		record["pre_stock"]=native_pre.duplicate(true)
		record["same_tick"]=native_pre.get("frame",-1)==record.frame
		record["phase"]=native_label
		record["setup_active"]=native_setup_active
		record["support"]=_native_support(world,player)
		record["recovery"]=world.get_runtime_evidence().recovery_count
		native_rows.append(record)
	main.add_child(native_post_observer)
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var owner:=_record_node_for_key(world,"building:w291189336:wall")
	var roof_owner:=_record_node_for_key(world,"building:w291189336:roof")
	var chunk: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.chunk))
	var wall: Dictionary={};var roof: Dictionary={}
	for record: Dictionary in chunk.records:
		if record.object_key=="building:w291189336:wall":wall=record
		if record.object_key=="building:w291189336:roof":roof=record
	var cfg: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.config))
	source_wall=wall
	source_config=cfg
	var legacy: Array[CollisionObject3D]=[]
	for body: CollisionObject3D in owner.find_children("*","CollisionObject3D",true,false)+roof_owner.find_children("*","CollisionObject3D",true,false):
		if str(body.get_meta("derived_object_key",""))in ["building:w291189336:wall","building:w291189336:roof"] and body.get_meta("source_keys",[])==[active_source]:legacy.append(body)
	if not _require(legacy.size()==2 and legacy[0].collision_layer==5,"Single original wall body"): _receipt();await _finish(main);return
	var starting_recovery: int=world.get_runtime_evidence().recovery_count
	var before:=_protected(world,owner)
	var model: Node3D=load(MODEL_PATH).build(wall,roof,cfg)
	if not _require(model!=null and bool(model.get_meta("build_valid",false)),"Valid candidate before superseding wall"): _receipt();await _finish(main);return
	var changed: Array=[];var states: Array=[]
	for mesh: GeometryInstance3D in owner.find_children("*","GeometryInstance3D",true,false):
		if mesh.visible and str(mesh.get_meta("physical_role",""))!="ground_visual":changed.append(mesh);mesh.visible=false
	for body: CollisionObject3D in legacy:
		states.append({"body":body,"layer":body.collision_layer,"mask":body.collision_mask,"spray":body.is_in_group("spray_receiver_wall")})
		body.collision_layer=0;body.collision_mask=0;body.remove_from_group("spray_receiver_wall")
	world.add_child(model)
	active_model=model;saved_changed=changed;saved_states=states
	await physics_frame
	preservation={"before":before,"after_install":_protected(world,owner)}
	var source_ok:=_require(before==preservation.after_install,"Non-target roof/terrain/body channels unchanged") and _native(model)
	for body: CollisionObject3D in legacy:source_ok=_require(body.collision_layer==0 and body.collision_mask==0 and not body.is_in_group("spray_receiver_wall"),"Old flat wall inactive") and source_ok
	if source_ok and execution_scope=="full":
		for ray: Dictionary in manifest.rays:
			if not _ray_case(ray,world,player):break
	if _failure.is_empty() and not unsafe and execution_scope=="full":
		var service: Dictionary=manifest.service
		var setup:=await _mechanics_setup(Vector2(service.anchor[0],service.anchor[1]),"service",world,player)
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
	if _failure.is_empty() and not unsafe and execution_scope=="full":
		var corner: Dictionary=manifest.corner
		var setup:=await _mechanics_setup(Vector2(corner.anchor[0],corner.anchor[1]),"corner",world,player)
		if _require(setup.get("ok",false),str(setup)):
			var destination:=Vector3(corner.destination[0],player.global_position.y,corner.destination[1])
			cases.append(await _cross_leg(destination,player.global_position,(destination-player.global_position).normalized(),"corner-walk",world,player))
	if _failure.is_empty() and not unsafe and execution_scope=="full":
		for spray: Dictionary in manifest.sprays:
			var result:=await _spray_case(spray,world,player);cases.append(result)
			if not result.ok or unsafe or not _failure.is_empty():break
	if _failure.is_empty() and not unsafe:cases.append(await _roof_case(manifest.roof,world,player))
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
	for i:int in legacy.size():_require(legacy[i].collision_layer==states[i].layer and legacy[i].collision_mask==states[i].mask and legacy[i].is_in_group("spray_receiver_wall")==states[i].spray,"Original wall/roof restored")
	_receipt();await _finish(main)

func _protected(world: WorldLoader,owner: Node3D) -> Dictionary:
	var result: Dictionary={}
	for body: CollisionObject3D in world.find_children("*","CollisionObject3D",true,false):
		if body is PlayerController or owner.is_ancestor_of(body) or str(body.get_meta("derived_object_key","")) in ["building:w291189336:wall","building:w291189336:roof"]:continue
		var shapes: Array=[]
		for child: CollisionShape3D in body.find_children("*","CollisionShape3D",true,false):
			shapes.append([child.transform,child.disabled,str(child.shape.get_faces()) if child.shape is ConcavePolygonShape3D else str(child.shape)])
		result[str(body.get_path())]=[body.global_transform,body.collision_layer,body.collision_mask,shapes]
	return result

func _face_values(faces:PackedVector3Array)->Array:
	var values:Array=[]
	for point:Vector3 in faces:values.append(_v(point))
	return values

func _native(model:Node3D)->bool:
	var all_ok:bool=model.global_transform==Transform3D.IDENTITY
	var exports:Dictionary={}
	for mesh:MeshInstance3D in model.find_children("*","MeshInstance3D",true,false):
		var body:StaticBody3D=model.get_node(str(mesh.name)+"Contact")
		var holder:CollisionShape3D=body.get_child(0)
		var shape:ConcavePolygonShape3D=holder.shape
		# This producer submits the same indexed Float32 vertices to render and collision.
		# Mesh.get_faces() is separately retained: its triangle-mesh snapping is not the render array.
		var faces:PackedVector3Array=mesh.mesh.get_faces()
		var collision_faces:PackedVector3Array=shape.get_faces()
		var indexed_faces:=PackedVector3Array()
		for surface:int in mesh.mesh.get_surface_count():
			var arrays:Array=mesh.mesh.surface_get_arrays(surface)
			var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			for index:int in arrays[Mesh.ARRAY_INDEX]:indexed_faces.append(vertices[index])
		var eligible:bool=not str(mesh.name) in ["Roof","Cross"]
		var key:String="building:w291189336:"+("wall" if eligible else "roof")
		var member:bool=false
		var owners:Array=[]
		for id in body.get_shape_owners():
			var owner_shapes:Array=[]
			for i in body.shape_owner_get_shape_count(id):
				var same_shape:bool=body.shape_owner_get_shape(id,i)==shape
				owner_shapes.append({"index":body.shape_owner_get_shape_index(id,i),"same_shape":same_shape})
				if body.shape_owner_get_owner(id)==holder and not body.is_shape_owner_disabled(id) and body.shape_owner_get_transform(id)==holder.transform and same_shape:member=true
			owners.append({"id":id,"same_holder":body.shape_owner_get_owner(id)==holder,"disabled":body.is_shape_owner_disabled(id),"transform":_transform_record(body.shape_owner_get_transform(id)),"shapes":owner_shapes})
		var server_transform:Transform3D=PhysicsServer3D.body_get_state(body.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)
		var predicates:Dictionary={"model_identity":model.global_transform==Transform3D.IDENTITY,"owner_member":member,"holder_enabled":not holder.disabled,"mesh_identity":mesh.transform==Transform3D.IDENTITY,"body_identity":body.transform==Transform3D.IDENTITY,"holder_identity":holder.transform==Transform3D.IDENTITY,"faces_equal":indexed_faces==collision_faces,"body_layer":body.collision_layer==5,"body_mask":body.collision_mask==0,"render_layer":mesh.layers==(2 if eligible else 1),"receiver_group":body.is_in_group("spray_receiver_wall")==eligible,"node_server_transform":body.global_transform==server_transform}
		var metadata:Dictionary={}
		var objects:Dictionary={"mesh":mesh,"body":body,"holder":holder,"shape":shape}
		for role:String in objects:
			var object:Object=objects[role]
			metadata[role]={"derived_object_key":object.get_meta("derived_object_key",""),"source_keys":object.get_meta("source_keys",[]),"receiver_kind":object.get_meta("receiver_kind",""),"opaque":object.get_meta("opaque",false)}
			predicates[role+"_key"]=metadata[role].derived_object_key==key
			predicates[role+"_sources"]=metadata[role].source_keys==[active_source]
			predicates[role+"_receiver"]=metadata[role].receiver_kind==("building_wall" if eligible else "none")
			predicates[role+"_opaque"]=bool(metadata[role].opaque)
		var server_shapes:Array=[]
		for i:int in PhysicsServer3D.body_get_shape_count(body.get_rid()):
			server_shapes.append({"index":i,"same_shape_rid":PhysicsServer3D.body_get_shape(body.get_rid(),i)==shape.get_rid(),"transform":_transform_record(PhysicsServer3D.body_get_shape_transform(body.get_rid(),i))})
		var valid:bool=true
		for predicate:String in predicates:valid=valid and bool(predicates[predicate])
		native_shapes[body]=shape
		if eligible:visible_faces.append_array(indexed_faces)
		exports[str(mesh.name)]={"faces":_face_values(faces),"collision_faces":_face_values(collision_faces),"indexed_render_faces":_face_values(indexed_faces),"body":str(body.get_path()),"rid":str(body.get_rid()),"eligible":eligible,"ok":valid,"predicates":predicates,"get_faces_equal_collision":faces==collision_faces,"metadata":metadata,"expected":{"key":key,"sources":[active_source],"receiver_kind":"building_wall" if eligible else "none","body_layer":5,"body_mask":0,"render_layer":2 if eligible else 1},"readback":{"model_transform":_transform_record(model.global_transform),"mesh_transform":_transform_record(mesh.transform),"body_transform":_transform_record(body.transform),"body_global_transform":_transform_record(body.global_transform),"holder_transform":_transform_record(holder.transform),"server_transform":_transform_record(server_transform),"holder_disabled":holder.disabled,"owners":owners,"server_shapes":server_shapes,"body_layer":body.collision_layer,"body_mask":body.collision_mask,"render_layer":mesh.layers,"receiver_group":body.is_in_group("spray_receiver_wall")}}
		all_ok=all_ok and valid
	cases.append({"case":"all-native-face-owner-equality","ok":all_ok,"buckets":exports.keys()})
	FileAccess.open(output.path_join("native-faces.json"),FileAccess.WRITE).store_string(JSON.stringify(exports))
	return _require(all_ok,"All actual candidate native faces/layers/owners")

func _ray_case(row: Dictionary,world: WorldLoader,player: PlayerController) -> bool:
	var point:=Vector3(row.point[0],row.point[1],row.point[2])
	var n:=Vector3(row.normal[0],0,row.normal[1])
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(point+n*0.6,point-n*0.6,5,[player.get_rid()]))
	var distance: float=999 if hit.is_empty() else hit.position.distance_to(point)
	var valid: bool=_exact_hit(hit) and distance<0.002 and hit.normal.dot(n)>0.999
	cases.append({"case":row.id,"ok":valid,"expected":_v(point),"hit":[] if hit.is_empty() else _v(hit.position),"distance":distance})
	return _require(valid,"Targeted actual native face "+str(row.id))

func _spray_case(row: Dictionary,world: WorldLoader,player: PlayerController) -> Dictionary:
	var setup:=await _mechanics_setup(Vector2(row.anchor[0],row.anchor[1]),row.id,world,player)
	if not _require(setup.get("ok",false),str(setup)):return {"ok":false,"case":row.id}
	var aimed:=await _input_aim(player,Vector3(row.aim[0],row.aim[1],row.aim[2]),false)
	if not _require(aimed.ok,"Stock spray pitch/yaw"):unsafe=true;return {"ok":false,"case":row.id}
	if not await _rest(world,player,row.id+"-start"):return {"ok":false,"case":row.id}
	if not await _wait_for_active_render(player):unsafe=true;return {"ok":false,"case":row.id}
	if not _safe(world):return {"ok":false,"case":row.id}
	var hit:=_camera_spray_hit(player)
	var intended:=_spray_region(row,hit)
	if not _require(_exact_hit(hit) and bool(intended.ok) and player.global_position.distance_to(hit.position)<=player.get_spray_controller().maximum_range_m,"Actual stock first intended visible region "+str(row.id)):return {"ok":false,"case":row.id,"intended_region":intended}
	var controller:=player.get_spray_controller()
	var before:int=controller.tag_instances.active_count()
	controller.attempt_spray()
	await process_frame
	var tag: Decal=null
	if controller.tag_instances.get_child_count()>before:tag=controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
	var valid: bool=controller.tag_instances.active_count()==before+1 and tag!=null and tag.cull_mask==2 and tag.get_meta("derived_object_key","")=="building:w291189336:wall" and tag.get_meta("source_keys",[])==[active_source] and tag.global_position.distance_to(hit.position)<0.05 and is_equal_approx(tag.size.y,controller.projection_depth_m) and tag.global_basis.y.is_equal_approx(hit.normal.normalized()) and player.global_position.distance_to(hit.position)<=controller.maximum_range_m
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
				var fits: bool=_exact_hit(h) and nearest!=null and origin.distance_to(nearest)<=origin.distance_to(end) and nearest.distance_to(h.position)<0.002
				valid=valid and fits
				footprint.append({"u":u,"v":v,"fits_visible_wall_and_native":fits})
	_require(valid,"Projector footprint fits intended visible layer2 native wall")
	if valid:await _motion_image(player,row.id)
	if unsafe or not _failure.is_empty():return {"ok":false,"case":row.id,"footprint":footprint}
	var rest:=await _rest(world,player,row.id+"-rest")
	return {"case":row.id,"ok":valid and rest and not unsafe and _failure.is_empty(),"intended_region":intended,"footprint":footprint,"hit":_v(hit.position),"cull":0 if tag==null else tag.cull_mask,"projector_size":[] if tag==null else _v(tag.size),"player_range":player.global_position.distance_to(hit.position),"camera_range":player.get_camera().global_position.distance_to(hit.position)}

func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output):return
	FileAccess.open(output.path_join("native-motion-trace.json"),FileAccess.WRITE).store_string(JSON.stringify({"rows":native_rows,"stored_frames":native_rows.size(),"scope":"Pre/post stock physics readbacks for independent native capsule/triangle reconstruction; no new inline gap threshold."}))
	FileAccess.open(output.path_join("motion-trace.json"),FileAccess.WRITE).store_string(JSON.stringify({"sampled_frames":sampled_frames,"stored_records":motion_trace.size(),"records":motion_trace}))
	FileAccess.open(output.path_join("capture-receipt.json"),FileAccess.WRITE).store_string(JSON.stringify({"ok":_failure.is_empty() and safe_final,"execution_scope":execution_scope,"failure":_failure,"safe_final":safe_final,"unsafe":unsafe,"initial_recovery":initial_recovery,"cases":cases,"captures":rows,"preservation":preservation},"\t")+"\n")
func _sample(world: WorldLoader,player: PlayerController,label: String,extra: Dictionary={}) -> Dictionary:
	native_label=label
	var position := player.global_position
	var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position+Vector3.UP*0.3,position-Vector3.UP*0.6,1,[player.get_rid()]))
	var support := "" if hit.is_empty() else _derived_object_key_for_collider(hit.collider)
	var collisions: Array=[]
	for i in player.get_slide_collision_count():
		var col := player.get_slide_collision(i)
		collisions.append({"owner":_derived_object_key_for_collider(col.get_collider()),"normal":_v(col.get_normal()),"position":_v(col.get_position()),"shape":col.get_collider_shape_index(),"rid":str(col.get_collider_rid()),"depth":col.get_depth()})
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

func _mechanics_setup(anchor:Vector2,label:String,world:WorldLoader,player:PlayerController)->Dictionary:
	native_label="setup:"+label;native_setup_active=true
	var result:Dictionary=await _settle_player(anchor,label,world,player)
	native_setup_active=false;native_label="setup-complete:"+label
	return result

func _rest(world: WorldLoader,player: PlayerController,label: String,max_frames:int=180) -> bool:
	_release_all()
	player.set_gameplay_enabled(true)
	var consecutive:=0
	for frame in max_frames:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label,{"rest_max_frames":max_frames})
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

func _exact_hit(hit:Dictionary)->bool:
	if hit.is_empty() or not native_shapes.has(hit.collider):return false
	var body:StaticBody3D=hit.collider
	var id:int=body.shape_find_owner(int(hit.shape))
	if body.is_shape_owner_disabled(id):return false
	for i in body.shape_owner_get_shape_count(id):
		if body.shape_owner_get_shape(id,i)==native_shapes[body]:return true
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
	var c:=Vector3(source_config.front_center[0],0,source_config.front_center[2])
	var t:=Vector3(source_config.tangent[0],0,source_config.tangent[2]).normalized()
	var n:=Vector3(source_config.normal[0],0,source_config.normal[2]).normalized()
	var station:float=(hit.position-c).dot(t)
	var plane_error:float=absf((hit.position-c).dot(n)-float(row.region.depth))
	var within:bool=station>=row.region.station[0] and station<=row.region.station[1] and hit.position.y>=row.region.height[0] and hit.position.y<=row.region.height[1]
	return {"ok":within and plane_error<.002 and hit.normal.dot(n)>.999 and str(hit.collider.name)==row.region.body,"station":station,"plane_error":plane_error,"region":row.region,"aim_center_error_diagnostic_only":hit.position.distance_to(Vector3(row.aim[0],row.aim[1],row.aim[2]))}

func _roof_tick(world:WorldLoader,player:PlayerController,label:String)->bool:
	_force_unpaused(player);await physics_frame
	_sample(world,player,label)
	return _safe(world)

func _fly_to(target:Vector3,altitude:float,world:WorldLoader,player:PlayerController)->bool:
	var aim:=await _input_aim(player,target,true)
	if not _require(aim.ok,"Stock roof flight aim"):unsafe=true;return false
	player.set_gameplay_enabled(true);Input.action_press("jetpack")
	for i in 600:
		if not await _roof_tick(world,player,"roof-rise"):break
		if player.global_position.y>=altitude:break
	if unsafe or player.global_position.y<altitude:_release_all();return false
	Input.action_press("move_forward")
	var reached:=false
	for i in 600:
		if player.global_position.y>altitude+1.0:Input.action_release("jetpack")
		elif player.global_position.y<altitude:Input.action_press("jetpack")
		if not await _roof_tick(world,player,"roof-cross"):break
		if Vector2(player.global_position.x-target.x,player.global_position.z-target.z).length()<.18:reached=true;break
	_release_all()
	return reached and not unsafe

func _pitched_support(world:WorldLoader,player:PlayerController,region:Dictionary)->Dictionary:
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP*.3,player.global_position-Vector3.UP*.6,5,[player.get_rid()]))
	var ok:bool=_exact_hit(hit) and str(hit.collider.name)=="RoofContact" and hit.normal.y>.7 and hit.normal.y<.999 and hit.position.y>8.0 and hit.collider.get_meta("receiver_kind","")=="none"
	var c:=Vector3(source_config.front_center[0],0,source_config.front_center[2])
	var t:=Vector3(source_config.tangent[0],0,source_config.tangent[2]).normalized()
	var n:=Vector3(source_config.normal[0],0,source_config.normal[2]).normalized()
	var station:float=(player.global_position-c).dot(t);var depth:float=(player.global_position-c).dot(-n)
	ok=ok and station>=region.station[0] and station<=region.station[1] and depth>=region.depth[0] and depth<=region.depth[1]
	return {"ok":ok,"planned_region":region,"station":station,"depth":depth,"point":[] if hit.is_empty() else _v(hit.position),"normal":[] if hit.is_empty() else _v(hit.normal),"face_index":hit.get("face_index",-1),"scope":"Ray identity and planned region prerequisite only, not absence-of-dip proof. Native capsule/triangle reconstruction is independent from continuous pre/post trace."}

func _roof_case(row:Dictionary,world:WorldLoader,player:PlayerController)->Dictionary:
	var setup:=await _mechanics_setup(Vector2(row.anchor[0],row.anchor[1]),"roof-setup",world,player)
	if not _require(setup.get("ok",false),str(setup)):return {"ok":false,"case":"roof"}
	if not await _rest(world,player,"roof-start"):return {"ok":false,"case":"roof"}
	var records:Array=[]
	for target:Array in row.destinations:
		var flight:=await _fly_to(Vector3(target[0],target[1],target[2]),float(row.altitude),world,player)
		if not _require(flight,"Bounded stock flight reached roof destination"):unsafe=true;break
		var rest:=await _rest(world,player,"pitched-landing-rest",900)
		var support:=_pitched_support(world,player,row.regions[records.size()])
		records.append({"flight":flight,"rest":rest,"landing_wait_max_frames":900,"support":support})
		if not _require(rest and support.ok,"Enabled released pitched roof landing"):break
		await _motion_image(player,"roof-landing-"+str(records.size()))
		if unsafe or not _failure.is_empty():break
	if _failure.is_empty() and not unsafe:
		var target:=Vector3(row.reject_aim[0],row.reject_aim[1],row.reject_aim[2])
		var aim:=await _input_aim(player,target,false)
		var hit:=_camera_spray_hit(player)
		var valid:bool=aim.ok and _exact_hit(hit) and str(hit.collider.name)=="RoofContact" and hit.collider.get_meta("receiver_kind","")=="none" and hit.collider.get_meta("source_keys",[])==[active_source] and player.global_position.distance_to(hit.position)<=player.get_spray_controller().maximum_range_m
		if _require(valid,"Actual reachable roof nonreceiver first hit"):
			var controller:=player.get_spray_controller();var before:int=controller.tag_instances.active_count()
			var results:Array[String]=[]
			var callback:Callable=func(code:String):results.append(code)
			controller.spray_result.connect(callback)
			controller.attempt_spray();await process_frame
			controller.spray_result.disconnect(callback)
			var rejected:bool=results==["receiver_rejection"] and controller.tag_instances.active_count()==before
			records.append({"case":"actual-roof-rejection","ok":rejected,"results":results,"body":str(hit.collider.get_path()),"rid":str(hit.collider.get_rid()),"shape":int(hit.shape),"source_keys":hit.collider.get_meta("source_keys",[]),"derived_key":hit.collider.get_meta("derived_object_key",""),"receiver_kind":hit.collider.get_meta("receiver_kind",""),"range":player.global_position.distance_to(hit.position),"maximum_range":controller.maximum_range_m,"point":_v(hit.position),"normal":_v(hit.normal)})
			_require(rejected,"Actual stock receiver_rejection result, unchanged tag count")
	return {"case":"roof-flight-junction-hop-rejection","ok":_failure.is_empty() and not unsafe,"landings":records,"cross_semantics":"Native nonreceiver only; no unsafe high-angle ground spray forced."}

func _transform_record(value:Transform3D)->Dictionary:
	return {"origin":_v(value.origin),"basis":[_v(value.basis.x),_v(value.basis.y),_v(value.basis.z)]}

func _native_state(player:PlayerController)->Dictionary:
	var holder:CollisionShape3D=player.get_node("CollisionShape3D")
	var capsule:CapsuleShape3D=holder.shape
	var server:Transform3D=PhysicsServer3D.body_get_state(player.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)
	var contacts:Array=[]
	for i in player.get_slide_collision_count():
		var collision:KinematicCollision3D=player.get_slide_collision(i)
		for j in collision.get_collision_count():
			var body:CollisionObject3D=collision.get_collider(j)
			contacts.append({"body":"" if body==null else str(body.get_path()),"rid":str(collision.get_collider_rid(j)),"key":"" if body==null else body.get_meta("derived_object_key",""),"sources":[] if body==null else body.get_meta("source_keys",[]),"shape":collision.get_collider_shape_index(j),"normal":_v(collision.get_normal(j)),"position":_v(collision.get_position(j)),"depth":collision.get_depth(),"travel":_v(collision.get_travel()),"remainder":_v(collision.get_remainder())})
	return {"frame":Engine.get_physics_frames(),"player_id":player.get_instance_id(),"rid":str(player.get_rid()),"rid_object_id":PhysicsServer3D.body_get_object_instance_id(player.get_rid()),"position":_v(player.global_position),"node_transform":_transform_record(player.global_transform),"server_transform":_transform_record(server),"shape_local_transform":_transform_record(holder.transform),"shape_server_transform":_transform_record(PhysicsServer3D.body_get_shape_transform(player.get_rid(),0)),"capsule_radius":capsule.radius,"capsule_height":capsule.height,"shape_disabled":holder.disabled,"shape_owner_disabled":player.is_shape_owner_disabled(player.shape_find_owner(0)),"velocity":_v(player.velocity),"floor":player.is_on_floor(),"enabled":player.is_physics_processing(),"gameplay_enabled":bool(player.get("_gameplay_enabled")),"contacts":contacts,"inputs":_input_state(),"last_motion":_v(player.get_last_motion()),"safe_margin":player.safe_margin,"floor_snap_length":player.floor_snap_length}

func _native_support(world:WorldLoader,player:PlayerController)->Dictionary:
	var hit:=world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP*.3,player.global_position-Vector3.UP*.6,5,[player.get_rid()]))
	if hit.is_empty():return {"hit":false}
	return {"hit":true,"body":str(hit.collider.get_path()),"rid":str(hit.collider.get_rid()),"shape":int(hit.shape),"face_index":hit.get("face_index",-1),"key":hit.collider.get_meta("derived_object_key",""),"sources":hit.collider.get_meta("source_keys",[]),"position":_v(hit.position),"normal":_v(hit.normal)}
