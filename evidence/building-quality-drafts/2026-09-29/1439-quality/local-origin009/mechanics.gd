extends SceneTree
# Adapted complete motion/contact/spray consumer closure from the successful same-unit1241 driver.
class NativeMotionReadback extends Node:
	var player:PlayerController
	var phase:String=""
	var timing:String="after_stock_physics"
	var sample:Dictionary={}
	static func vector(value:Vector3) -> Array:
		return [value.x,value.y,value.z]
	func movement_state() -> Dictionary:
		var results:Array=[]
		for index in player.get_slide_collision_count():
			var collision:KinematicCollision3D=player.get_slide_collision(index)
			var contacts:Array=[]
			for contact_index in collision.get_collision_count():
				contacts.append({"index":contact_index,"collider_id":collision.get_collider_id(contact_index),"collider_rid":str(collision.get_collider_rid(contact_index)),"shape_index":collision.get_collider_shape_index(contact_index),"position":vector(collision.get_position(contact_index)),"normal":vector(collision.get_normal(contact_index)),"collider_velocity":vector(collision.get_collider_velocity(contact_index))})
			results.append({"slide_index":index,"travel":vector(collision.get_travel()),"remainder":vector(collision.get_remainder()),"depth":collision.get_depth(),"contacts":contacts})
		return {"velocity":vector(player.velocity),"gameplay_enabled":bool(player.get("_gameplay_enabled")),"physics_processing":player.is_physics_processing(),"on_floor":player.is_on_floor(),"on_wall":player.is_on_wall(),"on_ceiling":player.is_on_ceiling(),"floor_normal":vector(player.get_floor_normal()) if player.is_on_floor() else [],"last_motion":vector(player.get_last_motion()),"position_delta":vector(player.get_position_delta()),"real_velocity":vector(player.get_real_velocity()),"floor_snap_length":player.floor_snap_length,"safe_margin":player.safe_margin,"slide_results":results}
	func _physics_process(_delta:float) -> void:
		if player==null:return
		var rid:RID=player.get_rid()
		var node_transform:Transform3D=player.global_transform
		var getter:Transform3D=PhysicsServer3D.body_get_state(rid,PhysicsServer3D.BODY_STATE_TRANSFORM)
		var direct:PhysicsDirectBodyState3D=PhysicsServer3D.body_get_direct_state(rid)
		sample={"phase":phase,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"player_instance_id":player.get_instance_id(),"rid":str(rid),"rid_object_instance_id":PhysicsServer3D.body_get_object_instance_id(rid),"node_transform":var_to_bytes(node_transform).hex_encode(),"node_position":[node_transform.origin.x,node_transform.origin.y,node_transform.origin.z],"body_get_state_transform":var_to_bytes(getter).hex_encode(),"body_get_state_position":[getter.origin.x,getter.origin.y,getter.origin.z],"direct_state_available":direct!=null,"scope":"Read-only physics callback after stock player; no sync or transform writes."}
		sample["timing"]=timing
		sample["movement_state"]=movement_state()
		sample["scope"]="Read-only priority observer; no movement, snap, sync or transform writes."
		if direct!=null:
			var transform:Transform3D=direct.transform
			sample["direct_state_transform"]=var_to_bytes(transform).hex_encode()
			sample["direct_state_position"]=[transform.origin.x,transform.origin.y,transform.origin.z]

var native_motion_pre_readback:NativeMotionReadback
var native_motion_readback:NativeMotionReadback

const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/1439-from-scratch-2026-09-23/remaining-mechanics/local-origin-motion-009"
const STILL_SIZE := Vector2i(1440,900)
var OUTPUT := ""
var land_body:StaticBody3D
var land_holder:CollisionShape3D
var land_original_shape:ConcavePolygonShape3D
var land_original_transform:Transform3D
var land_original_snapshot:Dictionary={}
var land_owner:Node3D
var land_repair:Dictionary={}
var native_fronts:Array=[]
var native_delta_checks:Dictionary={}
var delta_captures:Array=[]
const SUPPORT = preload("res://game/scripts/world/facades/housing_quality_support.gd")
var WALL_KEY := ""
var ROOF_KEY := ""
var LAND_KEYS: Array = []
var source_key := ""
var geometry_checks: Array = []
var target_snapshots: Dictionary = {}
var contact_failures:Array[String]=[]
var fatal_failures:Array[String]=[]
var failure_events:Array=[]
var case_outcomes:Array=[]
var case_begin:int=0
var case_label:String=""
var case_kind:String=""
var resting_observation:Dictionary={}
var stable_player_identity:Dictionary={}
var drive_integrity_checks:Array=[]
var walk_trace:Array=[]
var walk_attempts:Array=[]
var active_walk_label:=""
var samples:Array=[]
var contact_player:PlayerController
var contact_body:StaticBody3D
var source_main:GameMain
var source_world:WorldLoader
var wall_root:Node3D
var roof_root:Node3D
var study_root:Node3D
var world_info:Dictionary={}
var surface_before:Dictionary={}
var junction_captures:Array=[]
var source_recoveries:Array=[]
var probe_mode:=""
var _finished:=false
var controls_before:Dictionary={}
var route_attempts:Array=[]
var spray_attempts:Array=[]
var motion_data:Dictionary={}
var placements:Array=[]
var frozen_study_state:Dictionary={}
var lighting_observation:Dictionary={}
var native_land_triangles:Array=[]
var native_support_triangles:Array=[]
var threshold_support_shape := -1
var support_binding_by_triangle:Array=[]
var roof_attempts:Array=[]
# A completed record is appended once, after its final marker/timing/retreat.
# Active context preserves started work if timeout interrupts an awaited phase.
var active_attempt:Dictionary={}
var active_completed_phases:Dictionary={}
var active_attempt_start_usec:int=0


func _initialize() -> void:
	create_timer(900.0,true,false,true).timeout.connect(_on_timeout)
	call_deferred("_run")

func _v(a: Array) -> Vector3:
	return Vector3(a[0],a[1],a[2])

func _run() -> void:
	OUTPUT = _argument_value("--artifact-output=")
	probe_mode = "actual-live-housing-mechanics"
	root.size = STILL_SIZE
	_check_contact(not OUTPUT.is_empty() and DisplayServer.get_name().to_lower()=="macos", "Native fresh artifact destination required")
	for path: String in _json(WORK+"/source-pins.json"):
		_check_contact(FileAccess.get_sha256("res://"+path)==str(_json(WORK+"/source-pins.json")[path]),"Frozen source "+path)
	if not fatal_failures.is_empty():await _end_contact(null);return
	source_main=load("res://game/scenes/main.tscn").instantiate() as GameMain
	source_world=source_main.get_node("WorldRoot") as WorldLoader
	contact_player=source_main.get_node("Player") as PlayerController
	var ready:Array=[];var failed:Array=[]
	source_world.world_ready.connect(func(x):ready.append(x))
	source_world.world_failed.connect(func(a,b,c):failed.append([a,b,c]))
	root.add_child(source_main)
	var start:=Time.get_ticks_msec()
	while ready.is_empty() and failed.is_empty() and Time.get_ticks_msec()-start<45000:await process_frame
	_check_contact(ready.size()==1 and failed.is_empty(),"Actual live source world ready: "+JSON.stringify(failed))
	if not fatal_failures.is_empty():await _end_contact(source_main);return
	for i in 120:
		if contact_player.visible:break
		await physics_frame;await process_frame
	_check_contact(contact_player.visible and contact_player.was_first_reveal_grounded(),"Stock grounded first reveal")
	contact_player.recovered.connect(func(cause:String,position:Vector3):source_recoveries.append({"cause":cause,"position":_vector3(position)}))
	native_motion_pre_readback=NativeMotionReadback.new();native_motion_pre_readback.player=contact_player
	native_motion_pre_readback.name="NativeMotionPreReadback"
	native_motion_pre_readback.timing="before_stock_physics_previous_movement_results"
	native_motion_pre_readback.process_physics_priority=contact_player.process_physics_priority-1
	source_main.add_child(native_motion_pre_readback)
	native_motion_readback=NativeMotionReadback.new();native_motion_readback.player=contact_player
	native_motion_readback.name="NativeMotionReadback"
	native_motion_readback.process_physics_priority=contact_player.process_physics_priority+1
	source_main.add_child(native_motion_readback)
	controls_before=_stock_settings()
	stable_player_identity={"object_id":contact_player.get_instance_id(),"rid":str(contact_player.get_rid()),"path":str(contact_player.get_path())}
	world_info={"actual_runtime":source_world.get_runtime_evidence(),"historical_credit":"34/213 unchanged", "revision_acceptance":"pending", "helper_injection":false,"raw_capture_status":"HOLD retained; derived source review separately required"}
	paused=false;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	_clean_hud(source_main.get_node("Interface/HUD") as GameHUD)
	for target: Dictionary in _json(WORK+"/mechanics-plan.json").targets:
		source_key=str(target.source);WALL_KEY="building:"+source_key+":wall";ROOF_KEY="building:"+source_key+":roof";LAND_KEYS=target.land_keys
		var walls:=_record_roots(WALL_KEY);var roofs:=_record_roots(ROOF_KEY)
		_check_contact(walls.size()==1 and roofs.size()==1,"Exactly one actual atomic source pair "+str(target.number))
		if not fatal_failures.is_empty():break
		wall_root=walls[0];roof_root=roofs[0];study_root=wall_root
		contact_body=wall_root.get_node("CurrentGeometry_detail") as StaticBody3D
		_check_contact(str(wall_root.get_meta("revision_acceptance",""))=="pending" and not bool(wall_root.get_meta("old_collision_proxy_retained",true)),"Pending real geometry, not old proxy")
		target_snapshots[WALL_KEY]=_snapshot(wall_root);target_snapshots[ROOF_KEY]=_snapshot(roof_root)
		_check_geometry_congruence(wall_root);_check_geometry_congruence(roof_root)
		_native_front_readback(wall_root);_native_front_readback(roof_root)
		native_delta_checks[str(target.number)]={"reused_actual002":_json(WORK+"/mechanics-plan.json").reuse,"new_geometry_congruence_checked":true}
		await _apply_land_origin()
		if not fatal_failures.is_empty():break
		native_land_triangles=[];_bind_native_land()
		native_support_triangles=native_land_triangles.duplicate(true);threshold_support_shape=-1
		var retained:Dictionary=_json("/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/1439-from-scratch-2026-09-23/remaining-mechanics/mechanics-002/receipt.json").actual_target_snapshots
		var persisted:Dictionary=JSON.parse_string(JSON.stringify(target_snapshots,"  ",false))
		_check_contact(persisted==retained,"Exact unchanged target wall/roof applicability to completed002/006 cases")
		if not fatal_failures.is_empty():break
		for route: Dictionary in target.routes:
			route["route_scope"]=str(target.get("route_scope","full_mechanics"))
			_begin_case(str(route.id),"route")
			var f:=_route_frame(route)
			contact_body=wall_root.get_node("CurrentGeometry_"+str(route.expected_role)) as StaticBody3D if str(route.kind)=="closed" else null
			native_support_triangles=native_land_triangles.duplicate(true);threshold_support_shape=-1
			if str(route.kind)=="closed":_bind_native_obstruction(route)
			_bind_exact_supports(route.get("support_bindings",[]))
			if not fatal_failures.is_empty():break
			await _route_attempt(route,f)
			if _finished:return
			if not _finish_case():break
		if not fatal_failures.is_empty():break
		for spec: Dictionary in target.sprays:
			_begin_case(str(spec.id),"spray")
			var f:=_route_frame(spec)
			contact_body=(roof_root if str(spec.expected_role)=="roof" else wall_root).get_node("CurrentGeometry_"+str(spec.expected_role)) as StaticBody3D
			_bind_native_obstruction(spec)
			_bind_expected_face(spec,_v(spec.target),_v(spec.get("target_normal",spec.frame.normal)),str(spec.expected_role),str(spec.expected_key))
			if not fatal_failures.is_empty():break
			await _spray_case(spec,f)
			if _finished:return
			if not _finish_case():break
		if not fatal_failures.is_empty():break
		for flight:Dictionary in target.roof_routes:
			_begin_case(str(flight.id),"roof")
			await _roof_attempt(flight)
			if _finished:return
			if not _finish_case():break
			if bool(flight.get("spray_roof_after_landing",false)):
				if bool(roof_attempts[-1].ok):
					var spray:Dictionary=flight.roof_spray.duplicate(true)
					_begin_case(str(spray.id),"spray")
					_bind_native_obstruction(spray)
					if not fatal_failures.is_empty():break
					await _spray_case(spray,_route_frame(flight))
					if _finished:return
					if not _finish_case():break
				else:
					spray_attempts.append({"label":flight.roof_spray.id,"record_state":"skipped_dependency","performed":false,"ok":false,"reason":"Required roof case failed; no roof spray attempted."})
		if not fatal_failures.is_empty():break
	await _end_contact(source_main)

func _bind_expected_face(spec: Dictionary, target: Vector3, normal: Vector3, role: String, key: String) -> void:
	# The ray only resolves ordered shape index after a source-derived target/plane check.
	var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(target+normal*.6,target-normal*.08,5,[contact_player.get_rid()]))
	var identity:Dictionary={} if hit.is_empty() else _collider_identity(hit.collider,int(hit.shape))
	var valid:bool=not hit.is_empty() and str(identity.get("derived_object_key",""))==key and str(identity.get("structural_role",""))==role and hit.position.distance_to(target)<.035 and (hit.normal as Vector3).dot(normal)>.9
	spec["geometry_preflight"]={"target":_vector3(target),"normal":_vector3(normal),"identity":identity,"hit":_ray_value(hit),"tolerance_m":.035,"ok":valid}
	_check_contact(valid,str(spec.id)+" source-derived visible target plane and role resolve expected contact")
	if valid:spec.expected_shape=int(hit.shape)

func _bind_native_obstruction(spec:Dictionary) -> void:
	var bindings:Array=spec.native_bindings
	var allowed:Array=[]
	for binding:Dictionary in bindings:
		var index:int=int(binding.shape_index)
		var valid:bool=contact_body!=null and str(contact_body.name)==str(binding.body) and index>=0 and index<contact_body.get_child_count()
		var actual_hash:String=""
		if valid:
			var node:=contact_body.get_child(index) as CollisionShape3D
			valid=node!=null and str(node.name)==str(binding.shape_name) and node.shape is ConcavePolygonShape3D and not node.disabled
			if valid:
				actual_hash=var_to_bytes((node.shape as ConcavePolygonShape3D).get_faces()).hex_encode().sha256_text()
				valid=actual_hash==str(binding.faces_sha256) and str(node.shape.get_meta("physical_role",""))==str(binding.role) and str(node.shape.get_meta("derived_object_key",""))==str(spec.get("expected_key",WALL_KEY))
		_check_contact(valid,str(spec.id)+" exact actual001 native obstruction face binding")
		if valid:allowed.append(index)
	spec["expected_obstruction_shapes"]=allowed
	spec["native_binding_scope"]="Exact retained actual002 body/name/index/native face hash; no arbitrary role contact accepted."

func _check_geometry_congruence(owner: Node3D) -> void:
	var indices:Dictionary={"wall":0,"detail":0,"roof":0}
	for node: Node in owner.get_children():
		if not node is MeshInstance3D:continue
		var mesh:=node as MeshInstance3D;var role:=str(mesh.get_meta("physical_role",""))
		if role=="ground_visual":continue
		var expected:=PackedVector3Array();var raw:=mesh.mesh.get_faces()
		for i in range(0,raw.size(),3):
			var a:Vector3=mesh.transform*raw[i];var b:Vector3=mesh.transform*raw[i+1];var c:Vector3=mesh.transform*raw[i+2]
			if (b-a).cross(c-a).length_squared()<0.000000000001:continue
			expected.append_array(PackedVector3Array([a,b,c]))
		if expected.is_empty():continue
		var body:=owner.get_node("CurrentGeometry_"+role) as StaticBody3D
		var shape:=body.get_child(int(indices[role])) as CollisionShape3D
		indices[role]+=1
		var actual:PackedVector3Array=(shape.shape as ConcavePolygonShape3D).get_faces()
		var valid:bool=expected==actual and shape.transform==Transform3D.IDENTITY and body.transform==Transform3D.IDENTITY and not shape.disabled and body.collision_layer==5 and body.is_in_group("spray_receiver_wall")== (role=="wall")
		_check_contact(valid,"Current visible/contact congruence "+str(shape.get_path()))
		geometry_checks.append({"mesh":str(mesh.get_path()),"shape":str(shape.get_path()),"role":role,"faces_sha256":var_to_bytes(actual).hex_encode().sha256_text(),"ok":valid})

func _check_roof_and_canopy(target: Dictionary) -> void:
	for spec: Dictionary in target.surface_queries:
		var p:=_v(spec.point)
		var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(p+Vector3.UP*.5,p-Vector3.UP*.5,5,[contact_player.get_rid()]))
		var identity:Dictionary={} if hit.is_empty() else _collider_identity(hit.collider,int(hit.shape))
		var valid:bool=not hit.is_empty() and str(identity.get("derived_object_key",""))==str(spec.key) and str(identity.get("structural_role",""))==str(spec.role) and absf(hit.position.y-p.y)<.02 and hit.normal.y>.9
		_check_contact(valid,str(target.number)+" current "+str(spec.role)+" visible top is the actual contact")
		geometry_checks.append({"query":spec,"actual":_ray_value(hit),"ok":valid,"scope":"Static native congruence/contact, not a stock landing claim"})

func _end_contact(fixture: Node3D) -> void:
	if _finished:return
	_finished=true;_clear_gameplay_input()
	if not active_attempt.is_empty():
		var partial:=active_attempt.duplicate(true)
		partial["record_state"]="incomplete";partial["ok"]=false
		partial["completed_phase_traces"]=active_completed_phases.duplicate(true)
		partial["active_phase"]=active_walk_label;partial["active_phase_trace"]=walk_trace.duplicate(true)
		if str(partial.get("kind",""))=="route":route_attempts.append(partial)
		elif str(partial.get("kind",""))=="roof":roof_attempts.append(partial)
		else:spray_attempts.append(partial)
	for key: String in target_snapshots:
		var owners:=_record_roots(key)
		_check_contact(owners.size()==1 and _snapshot(owners[0])==target_snapshots[key],"Native target geometry unchanged through actual motion: "+key)
	_check_contact(source_recoveries.is_empty(),"No recovery substituted for movement")
	if not controls_before.is_empty():_check_contact(controls_before==_stock_settings(),"Stock controls/camera/spray unchanged")
	var plan:Dictionary=_json(WORK+"/mechanics-plan.json")
	var expected_routes:int=0;var expected_sprays:int=0;var expected_roofs:int=0
	for target:Dictionary in plan.targets:expected_routes+=target.routes.size();expected_sprays+=target.sprays.size();expected_roofs+=target.roof_routes.size()
	var complete:bool=route_attempts.size()==expected_routes and spray_attempts.size()==expected_sprays and roof_attempts.size()==expected_roofs
	_check_contact(complete,"1439 remaining planned seams complete all planned routes/retreats and spray outcomes")
	for row:Dictionary in route_attempts:
		_check_contact(str(row.get("record_state",""))=="complete" and bool(row.get("ok",false)) and not row.get("input_trace",[]).is_empty() and not row.get("brake_trace",[]).is_empty() and bool(row.get("retreat",{}).get("performed",false)) and bool(row.get("retreat",{}).get("ok",false)),"Remaining wall route record completed actual approach/braking/retreat")
	for row:Dictionary in roof_attempts:
		_check_contact(str(row.get("record_state",""))=="complete" and bool(row.get("ok",false)) and not row.get("rise_trace",[]).is_empty() and not row.get("landing_trace",[]).is_empty(),"Roof record completed actual flight and landing")
	for row:Dictionary in spray_attempts:
		_check_contact(str(row.get("record_state",""))=="complete" and bool(row.get("performed",false)) and bool(row.get("ok",false)),"Each of three sprays actually performed and completed")
	if is_instance_valid(contact_player) and (bool(contact_player.get("_gameplay_enabled")) or contact_player.is_physics_processing()):
		_clear_gameplay_input()
		land_repair["emergency_termination"]={"controller_was_active":true,"physics_processing":contact_player.is_physics_processing(),"supported_rest_claim":false,"reason":"Early/fatal/timeout teardown must stop controller before restoring collision representation."}
		_check_contact(false,"Emergency controller disable before LAND restoration; HOLD, not supported rest")
		contact_player.set_gameplay_enabled(false)
	_restore_land_origin()
	_write_json(_argument_value("--output="),{"land_local_origin":land_repair,"ok":contact_failures.is_empty(),"failures":contact_failures,"fatal_failures":fatal_failures,"failure_events":failure_events,"case_outcomes":case_outcomes,"drive_integrity_checks":drive_integrity_checks,"stable_player_identity":stable_player_identity,"source_pins_sha256":FileAccess.get_sha256(WORK+"/source-pins.json"),"geometry":geometry_checks,"native_front_readback":native_fronts,"native_delta_checks":native_delta_checks,"delta_captures":delta_captures,"actual_target_snapshots":target_snapshots,"routes":route_attempts,"roof_routes":roof_attempts,"sprays":spray_attempts,"captures":junction_captures,"setup_placements":placements,"world":world_info,"recoveries":source_recoveries,"scope":"Candidate-only same-body LAND representation: original wall approach and full retreat only. Completed002/006 cases retained by source applicability; no roof/loggia/spray replay or package acceptance."})
	if fixture!=null:fixture.queue_free()
	await process_frame
	quit(0 if contact_failures.is_empty() else 1)

func _on_timeout() -> void:
	if not _finished:_check_contact(false,"Focused mechanics exceeded900seconds");_end_contact(source_main)

func _support_ray(point:Vector3) -> Dictionary:
	# Retain the complete real-world query, not1308's
	# obsolete3m high bound. Upper scenario support uses a local vertical segment.
	var high:float=point.y+.35 if point.y>4.0 else 20.0
	var low:float=point.y-2.0 if point.y>4.0 else -5.0
	return contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(point.x,high,point.z),Vector3(point.x,low,point.z),1,[contact_player.get_rid()]))


func _record_roots(key:String) -> Array[Node3D]:
	var found:Array[Node3D]=[]
	for node:Node in source_world.find_children("*","Node3D",true,false):
		if not node is MeshInstance3D and not node is CollisionObject3D and node.has_meta("feature_kind") and str(node.get_meta("derived_object_key",""))==key:found.append(node)
	return found



func _final_camera_ground_state() -> Dictionary:
	var camera:Camera3D=contact_player.get_camera()
	var pivot:Node3D=contact_player.get_node("CameraPivot") as Node3D
	var arm:SpringArm3D=pivot.get_node("SpringArm3D") as SpringArm3D
	var space:PhysicsDirectSpaceState3D=contact_player.get_world_3d().direct_space_state
	var hit:Dictionary=space.intersect_ray(PhysicsRayQueryParameters3D.create(pivot.global_position,camera.global_position,1,[contact_player.get_rid()]))
	var length_m:float=pivot.global_position.distance_to(camera.global_position)
	var hit_distance:float=length_m if hit.is_empty() else pivot.global_position.distance_to(hit.position)
	# Same4cm endpoint allowance as the existing stock camera-segment predicate.
	var segment_clear:bool=hit.is_empty() or hit_distance>=length_m-.04
	var query_from:Vector3=camera.global_position;var query_to:Vector3=camera.global_position-Vector3.UP*20.0
	var land:Dictionary=space.intersect_ray(PhysicsRayQueryParameters3D.create(query_from,query_to,1,[contact_player.get_rid()]))
	var land_value:Dictionary=_ray_value(land)
	var expected_land:Dictionary=_expected_camera_land(camera.global_position)
	var land_ok:bool=bool(expected_land.get("ok",false)) and not land.is_empty() and str(land_value.get("derived_object_key",""))==str(expected_land.get("expected_object_key","")) and int(land_value.get("shape_index",-1))==0
	var terrain_confirmation:Dictionary={}
	if not land_ok and bool(expected_land.get("ok",false)) and not land.is_empty():
		var identity:Dictionary=_collider_identity(land.collider,int(land.shape))
		var allowed_body:bool=false
		for owner:Node3D in [wall_root,roof_root]:
			if owner==null:continue
			for body:Node in owner.get_children():
				if body is StaticBody3D and body==land.collider and str(body.name).begins_with("CurrentGeometry_"):allowed_body=true
		var terrain:Dictionary=_setup_land_height(camera.global_position)
		if allowed_body and bool(terrain.ok):
			var terrain_point:=Vector3(camera.global_position.x,float(terrain.y),camera.global_position.z)
			var confirmation:Dictionary=space.intersect_ray(PhysicsRayQueryParameters3D.create(terrain_point+Vector3.UP*.01,terrain_point-Vector3.UP*.01,1,[contact_player.get_rid()]))
			var confirmed:Dictionary=_ray_value(confirmation)
			land_ok=not confirmation.is_empty() and str(confirmed.get("derived_object_key",""))==str(expected_land.expected_object_key) and int(confirmed.get("shape_index",-1))==0 and absf(confirmation.position.y-float(terrain.y))<.002
			terrain_confirmation={"actual_first_target_contact":identity,"bound_land_interpolation":terrain,"short_native_land_ray":confirmed,"ok":land_ok,"scope":"Current shelter/roof may intervene vertically. Preserve first-solid ray and camera segment; separately confirm exact frozen LAND under it, no collision or camera change."}
	var clearance:Variant=null
	var above:bool=false
	if not land.is_empty():
		clearance=camera.global_position.y-float(land.position.y)
		above=float(clearance)>=0.0
		land_value["face_index"]=int(land.get("face_index",-1))
	return {"pivot":_vector3(pivot.global_position),"camera":_vector3(camera.global_position),"camera_near":camera.near,"arm_length":arm.spring_length,"arm_hit_length":arm.get_hit_length(),"arm_margin":arm.margin,"arm_collision_mask":arm.collision_mask,"pivot_to_camera_length_m":length_m,"segment_hit":_ray_value(hit),"segment_hit_distance_m":hit_distance,"segment_endpoint_allowance_m":.04,"segment_clear":segment_clear,"land_ray":land_value,"query_from":_vector3(query_from),"query_to":_vector3(query_to),"expected_camera_land":expected_land,"terrain_confirmation":terrain_confirmation,"land_identity_ok":land_ok,"camera_minus_land_y_m":clearance,"camera_above_land":above,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames()}



func _aim_stock_player_camera(player: PlayerController, target: Vector3) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	delta=rig.get_parent_node_3d().global_basis.inverse()*delta
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "target is vertically singular."}
	var yaw := atan2(-delta.x, -delta.z)
	var pitch := atan2(delta.y, horizontal)
	if pitch < deg_to_rad(rig.minimum_pitch_degrees) or pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "target pitch is outside stock camera limits."}
	rig.rotation = Vector3(0.0, yaw, 0.0)
	arm.rotation = Vector3(pitch, 0.0, 0.0)
	rig.force_update_transform()
	arm.force_update_transform()
	return {"ok": true, "yaw_degrees": rad_to_deg(yaw), "pitch_degrees": rad_to_deg(pitch)}



func _clean_hud(hud: GameHUD) -> void:
	paused = false
	hud.set_paused(false)
	hud.debug_panel.hide()
	hud.feedback_panel.hide()
	hud.load_panel.hide()
	hud.pause_panel.hide()
	hud.reticle.show()



func _clear_gameplay_input() -> void:
	for action: StringName in ["move_forward", "move_back", "move_left", "move_right", "run", "jetpack"]:
		if InputMap.has_action(action):
			Input.action_release(action)



func _json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}



func _write_json(path: String, value: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ", false) + "\n")
	file.close()
	return true



func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""



func _vector3(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]



func _place(position: Vector3,frame: Dictionary,settle: bool=true) -> void:
	placements.append({"position":_vector3(position),"physics_counter":Engine.get_physics_frames(),"setup_only":true})
	_clear_gameplay_input();contact_player.set_gameplay_enabled(false)
	contact_player.global_position=position;contact_player.velocity=Vector3.ZERO;contact_player.force_update_transform()
	_aim_stock_player_camera(contact_player,position-(frame.normal as Vector3)*8+Vector3.UP*2)
	await physics_frame;await process_frame;contact_player.set_gameplay_enabled(true)
	if settle:await _drive([],30,"place_settle")



func _drive(actions: Array,frames: int,label: String,stop_on_contact: Dictionary={}) -> void:
	if not fatal_failures.is_empty():
		_clear_gameplay_input();return
	native_motion_readback.phase=label
	native_motion_pre_readback.phase=label
	if not _drive_integrity(label,false):
		_clear_gameplay_input();return
	_clear_gameplay_input()
	for action: String in actions:Input.action_press(action)
	if not stop_on_contact.is_empty():
		active_attempt["forward_termination"]={"mode":"first_verified_expected_contact","maximum_input_frames":frames,"sampled_input_frames":0,"termination_reason":"in_progress","trigger":{},"input_released":false}
	for i in frames:
		var previous_position:Vector3=contact_player.global_position
		var previous_physics:int=Engine.get_physics_frames()
		await physics_frame;await process_frame
		if _finished:return
		var integrity_ok:bool=_drive_integrity(label,true)
		_check_contact(source_recoveries.is_empty() and controls_before==_stock_settings(),"No recovery or controller mutation during "+label)
		if not integrity_ok:
			_clear_gameplay_input();return
		if not fatal_failures.is_empty():
			_clear_gameplay_input();return
		var camera:=contact_player.get_camera();var pivot:=contact_player.get_node("CameraPivot") as Node3D
		var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pivot.global_position,camera.global_position,1,[contact_player.get_rid()]))
		_check_contact(hit.is_empty() or pivot.global_position.distance_to(hit.position)>=pivot.global_position.distance_to(camera.global_position)-.04,"Stock camera segment stays clear during "+label)
		if not active_walk_label.is_empty():
			walk_trace.append({"input_frame":i+1,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"phase":active_walk_label,"actions":actions.duplicate(),"camera_state":_final_camera_ground_state(),"camera_pivot_rotation":_vector3(contact_player.camera_rig.rotation),"camera_arm_rotation":_vector3(contact_player.camera_rig.spring_arm.rotation),"input_strengths":_input_strengths(),"drawn_counter":Engine.get_frames_drawn(),"planar_forward":_vector3(contact_player.camera_rig.planar_forward()),"position":_vector3(contact_player.global_position),"physics_server_position":_vector3((PhysicsServer3D.body_get_state(contact_player.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM) as Transform3D).origin),"velocity":_vector3(contact_player.velocity),"on_floor":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"slide_contacts":_walk_contacts()})
			walk_trace[-1]["drive_integrity"]=drive_integrity_checks[-1].duplicate(true)
			walk_trace[-1]["player_instance_id"]=contact_player.get_instance_id()
			walk_trace[-1]["player_rid"]=str(contact_player.get_rid())
			walk_trace[-1]["rid_object_instance_id"]=PhysicsServer3D.body_get_object_instance_id(contact_player.get_rid())
			walk_trace[-1]["physics_callback_readback"]=native_motion_readback.sample.duplicate(true)
			walk_trace[-1]["physics_callback_same_row"]=int(native_motion_readback.sample.get("physics_counter",-1))==int(walk_trace[-1].physics_counter) and str(native_motion_readback.sample.get("phase",""))==label
			walk_trace[-1]["pre_stock_physics_readback"]=native_motion_pre_readback.sample.duplicate(true)
			walk_trace[-1]["pre_post_same_physics_tick"]=int(native_motion_pre_readback.sample.get("physics_counter",-1))==int(native_motion_readback.sample.get("physics_counter",-2)) and str(native_motion_pre_readback.sample.get("phase",""))==label
			walk_trace[-1]["post_process_movement_state"]=native_motion_readback.movement_state()
			var pre:Dictionary=native_motion_pre_readback.sample
			var pre_identity:bool=int(pre.get("player_instance_id",-1))==contact_player.get_instance_id() and int(pre.get("rid_object_instance_id",-1))==contact_player.get_instance_id() and str(pre.get("rid",""))==str(contact_player.get_rid())
			walk_trace[-1]["diagnostic_interpretation_valid"]=bool(walk_trace[-1].pre_post_same_physics_tick) and bool(walk_trace[-1].physics_callback_same_row) and pre_identity and bool(drive_integrity_checks[-1].ok)
			_qualify_threshold_edge(walk_trace[-1],previous_position,previous_physics)
		if i%10==0 or i==frames-1:samples.append({"phase":label,"frame":i,"position":_vector3(contact_player.global_position),"camera":_vector3(camera.global_position),"on_floor":contact_player.is_on_floor(),"actions":actions.duplicate()})
		if not stop_on_contact.is_empty():
			var observed:Dictionary=walk_trace[-1]
			active_attempt.forward_termination["sampled_input_frames"]=walk_trace.size()
			var intended:Dictionary=_verified_obstruction_contact(observed,stop_on_contact)
			if not intended.is_empty():
				# Release at the observed contact boundary, before another awaited frame.
				_clear_gameplay_input()
				active_attempt.forward_termination["termination_reason"]="verified_expected_contact"
				active_attempt.forward_termination["trigger"]={"input_frame":observed.input_frame,"physics_counter":observed.physics_counter,"process_counter":observed.process_counter,"drawn_counter":observed.drawn_counter,"contact":intended.duplicate(true)}
				active_attempt.forward_termination["release_physics_counter"]=Engine.get_physics_frames()
				active_attempt.forward_termination["input_strengths_after_release"]=_input_strengths()
				active_attempt.forward_termination["input_released"]=Input.get_action_strength("move_forward")==0.0
				break
	if not stop_on_contact.is_empty() and str(active_attempt.forward_termination.termination_reason)=="in_progress":
		active_attempt.forward_termination["termination_reason"]="maximum_forward_budget_exhausted"
	_clear_gameplay_input()
	if not stop_on_contact.is_empty():
		active_attempt.forward_termination["input_released"]=Input.get_action_strength("move_forward")==0.0



func _verified_obstruction_contact(row:Dictionary,condition:Dictionary) -> Dictionary:
	for hit:Dictionary in row.slide_contacts:
		if bool(hit.exact_structure_body) and str(hit.derived_object_key)==WALL_KEY and int(hit.shape_index) in condition.get("expected_obstruction_shapes",[int(condition.expected_shape)]) and str(hit.structural_role)==str(condition.expected_role) and _v(hit.normal).dot(_v(condition.source_normal))>.7 and _contact_role_metadata_ok(hit,str(condition.expected_role)):
			return hit
	return {}



func _check_contact(ok:bool,message:String,fatal:bool=true)->void:
	if ok:return
	if message not in contact_failures:contact_failures.append(message)
	failure_events.append({"case":case_label,"kind":case_kind,"message":message,"fatal":fatal,"physics_counter":Engine.get_physics_frames()})
	if fatal and message not in fatal_failures:fatal_failures.append(message)

func _begin_case(label:String,kind:String)->void:
	case_begin=failure_events.size();case_label=label;case_kind=kind;resting_observation={}

func _case_ok()->bool:
	return failure_events.size()==case_begin and fatal_failures.is_empty()

func _stable_player_binding()->bool:
	return not stable_player_identity.is_empty() and source_main.get_node("Player")==contact_player and contact_player.get_instance_id()==int(stable_player_identity.object_id) and str(contact_player.get_rid())==str(stable_player_identity.rid) and str(contact_player.get_path())==str(stable_player_identity.path) and PhysicsServer3D.body_get_object_instance_id(contact_player.get_rid())==contact_player.get_instance_id()

func _drive_integrity(label:String,sampled:bool)->bool:
	var rid:RID=contact_player.get_rid()
	var server:Transform3D=PhysicsServer3D.body_get_state(rid,PhysicsServer3D.BODY_STATE_TRANSFORM)
	var active:bool=bool(contact_player.get("_gameplay_enabled")) and contact_player.is_physics_processing()
	var phase_ok:bool=native_motion_readback.phase==label and (active_walk_label.is_empty() or active_walk_label==label)
	var callback:Dictionary=native_motion_readback.sample.duplicate(true)
	var sample_ok:bool=true
	if sampled:
		sample_ok=str(callback.get("phase",""))==label and int(callback.get("physics_counter",-1))==Engine.get_physics_frames() and str(callback.get("rid",""))==str(rid) and int(callback.get("player_instance_id",-1))==contact_player.get_instance_id() and int(callback.get("rid_object_instance_id",-1))==contact_player.get_instance_id() and callback.get("node_position",[])==_vector3(contact_player.global_position)
	var server_ok:bool=server.origin.is_finite() and contact_player.global_position.is_finite() and server.origin.distance_to(contact_player.global_position)<=.000001
	var valid:bool=active and phase_ok and sample_ok and _stable_player_binding() and server_ok
	drive_integrity_checks.append({"ok":valid,"phase":label,"sampled_tick":sampled,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"gameplay_active":contact_player.get("_gameplay_enabled"),"physics_active":contact_player.is_physics_processing(),"stable_binding":_stable_player_binding(),"phase_ok":phase_ok,"callback_same_row_identity":sample_ok,"callback":callback if sampled else {},"node_position":_vector3(contact_player.global_position),"postprocess_server_position":_vector3(server.origin),"node_server_error_m":server.origin.distance_to(contact_player.global_position),"existing_server_tolerance_m":.000001})
	_check_contact(valid,"Fatal active stock controller/phase/native player identity during "+label)
	return valid

func _observe_resting_boundary(expected_active:bool)->Dictionary:
	_clear_gameplay_input()
	var land:Dictionary=_player_land_state()
	var camera:Dictionary=_final_camera_ground_state()
	var rid:RID=contact_player.get_rid()
	var server:Transform3D=PhysicsServer3D.body_get_state(rid,PhysicsServer3D.BODY_STATE_TRANSFORM)
	var released:bool=true
	for strength:Variant in _input_strengths().values():released=released and float(strength)==0.0
	var identity:bool=_stable_player_binding()
	var phase_state_ok:bool=bool(contact_player.get("_gameplay_enabled"))==expected_active and contact_player.is_physics_processing()==expected_active
	var ok:bool=contact_player.velocity.is_finite() and contact_player.velocity.length()<.01 and contact_player.is_on_floor() and bool(land.ok) and bool(camera.segment_clear) and bool(camera.land_identity_ok) and bool(camera.camera_above_land) and released and identity and phase_state_ok and server.origin.is_finite() and contact_player.global_position.is_finite() and server.origin.distance_to(contact_player.global_position)<=.000001 and source_recoveries.is_empty() and controls_before==_stock_settings()
	return {"ok":ok,"position":_vector3(contact_player.global_position),"velocity_before_disable":_vector3(contact_player.velocity),"controller_enabled_before_disable":contact_player.get("_gameplay_enabled"),"expected_active":expected_active,"physics_processing":contact_player.is_physics_processing(),"phase_state_ok":phase_state_ok,"on_floor":contact_player.is_on_floor(),"land":land,"camera":camera,"input_strengths":_input_strengths(),"rid":str(rid),"object_id":contact_player.get_instance_id(),"rid_object_id":PhysicsServer3D.body_get_object_instance_id(rid),"server_position":_vector3(server.origin),"physics_counter":Engine.get_physics_frames(),"scope":"Read before stock disable clears velocity; no transform, velocity, sync, or recovery write."}

func _hold_at_resting_boundary()->void:
	resting_observation=_observe_resting_boundary(true)
	_check_contact(bool(resting_observation.ok),case_label+" qualified actual resting boundary before controller disable")
	contact_player.set_gameplay_enabled(false)

func _finish_case()->bool:
	var final_state:Dictionary=_observe_resting_boundary(false)
	var safe:bool=bool(resting_observation.get("ok",false)) and bool(final_state.ok) and resting_observation.position==final_state.position and not bool(contact_player.get("_gameplay_enabled")) and not contact_player.is_physics_processing()
	_check_contact(safe,case_label+" safe released disabled final state before independent next setup")
	var events:Array=failure_events.slice(case_begin)
	case_outcomes.append({"id":case_label,"kind":case_kind,"ok":events.is_empty() and safe,"failures":events,"pre_disable_rest":resting_observation.duplicate(true),"final_state":final_state,"safe_to_continue":safe and fatal_failures.is_empty(),"aggregate_hold_retained":not contact_failures.is_empty()})
	return safe and fatal_failures.is_empty()

func _trace_phase(actions: Array, frames: int, label: String,stop_on_contact: Dictionary={}) -> Array:
	walk_trace = []
	active_walk_label = label
	await _drive(actions, frames, label,stop_on_contact)
	if _finished:return walk_trace.duplicate(true)
	if not active_attempt.is_empty():active_completed_phases[label]=walk_trace.duplicate(true)
	active_walk_label = ""
	return walk_trace.duplicate(true)



func _endpoint(frame: Dictionary) -> Dictionary:
	var contacts := _walk_contacts()
	var upward: Array = []
	for hit: Dictionary in contacts:
		if float(hit.normal[1]) > 0.7: upward.append(hit)
	return {"position":_vector3(contact_player.global_position),"depth_m":(contact_player.global_position - (frame.start as Vector3)).dot(frame.normal),"station_m":(contact_player.global_position - (frame.start as Vector3)).dot(frame.tangent),"on_floor":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"slide_contacts":contacts,"upward_slide_contacts":upward,"unfiltered_world_solid_ray":_ray_value(_support_ray(contact_player.global_position))}



func _walk_contacts() -> Array:
	var contacts: Array = []
	for i in contact_player.get_slide_collision_count():
		var hit := contact_player.get_slide_collision(i)
		var row := _collider_identity(hit.get_collider() as Node, hit.get_collider_shape_index())
		row.merge({"position":_vector3(hit.get_position()),"normal":_vector3(hit.get_normal())})
		contacts.append(row)
	return contacts



func _collider_identity(collider: Node, shape_index: int) -> Dictionary:
	var row := {"collider_path":"" if collider == null else str(collider.get_path()),"exact_structure_body":collider == contact_body,"shape_index":shape_index,"derived_object_key":"","feature_kind":"","shape_node_path":"","structural_role":""}
	var ancestor := collider
	while ancestor != null:
		if str(row.derived_object_key).is_empty() and ancestor.has_meta("derived_object_key"): row.derived_object_key = str(ancestor.get_meta("derived_object_key"))
		if str(row.feature_kind).is_empty() and ancestor.has_meta("feature_kind"): row.feature_kind = str(ancestor.get_meta("feature_kind"))
		ancestor = ancestor.get_parent()
	if collider is CollisionObject3D and shape_index >= 0:
		var shape_node := collider.shape_owner_get_owner(collider.shape_find_owner(shape_index)) as CollisionShape3D
		if shape_node != null:
			row.shape_node_path = str(shape_node.get_path())
			row.structural_role = str(shape_node.shape.get_meta("physical_role", ""))
	if collider is CollisionObject3D:
		row["collision_layer"]=collider.collision_layer
		row["spray_receiver_group"]=collider.is_in_group("spray_receiver_wall")
		row["resolved_receiver_metadata"]=contact_player.get_spray_controller()._resolve_hit_metadata(collider,shape_index)
	return row



func _ray_value(hit: Dictionary) -> Dictionary:
	if hit.is_empty(): return {"hit":false,"excludes_only_player":true}
	var row := _collider_identity(hit.collider as Node, int(hit.shape))
	row.merge({"hit":true,"position":_vector3(hit.position),"normal":_vector3(hit.normal),"excludes_only_player":true,"not_a_stock_contact_claim":true})
	return row



func _expected_camera_land(point:Vector3) -> Dictionary:
	var manifest_path:String="res://generated/world/manifest.json"
	var manifest:Dictionary=_json(manifest_path)
	var size_m:float=float(manifest.get("chunk_size_m",0.0))
	if size_m<=0.0:return {"ok":false,"reason":"No positive frozen chunk size."}
	var tile_x:int=int(floor(point.x/size_m));var tile_z:int=int(floor(point.z/size_m))
	var tile:String="x_%d__z_%d"%[tile_x,tile_z]
	var relative_path:String="chunks/"+tile+".json"
	var path:String="res://generated/world/"+relative_path
	var expected_sha:String=""
	for item:Dictionary in manifest.get("files",[]):
		if str(item.get("path",""))==relative_path:expected_sha=str(item.get("sha256",""))
	if expected_sha.is_empty() or FileAccess.get_sha256(path)!=expected_sha:return {"ok":false,"reason":"Camera tile lacks exact frozen source file.","tile":tile}
	var key:String="land:"+str(manifest.get("boundary_source_key",""))+":"+tile
	var found:Array=[]
	for record:Dictionary in _json(path).get("records",[]):
		if str(record.get("object_key",""))==key:found.append(record)
	var valid:bool=found.size()==1
	if valid:valid=str(found[0].get("feature_kind",""))=="land_ground" and str(found[0].get("collision_kind",""))=="world_solid"
	return {"ok":valid,"actual_camera_xz":[point.x,point.z],"tile":tile,"chunk_size_m":size_m,"expected_object_key":key,"expected_shape_index":0,"source_file":path,"source_sha256":expected_sha,"manifest_sha256":FileAccess.get_sha256(manifest_path)}


func _setup_land_height(point:Vector3) -> Dictionary:
	# Interpolate the already-bound native LAND faces at the unchanged setup XZ.
	var rows:Array=[];var land_y:float=-INF
	for i in native_land_triangles.size():
		var tri:Array=native_land_triangles[i];var a:Vector3=tri[0];var b:Vector3=tri[1];var c:Vector3=tri[2]
		var den:float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
		if absf(den)<1e-12:continue
		var u:float=((b.z-c.z)*(point.x-c.x)+(c.x-b.x)*(point.z-c.z))/den
		var v:float=((c.z-a.z)*(point.x-c.x)+(a.x-c.x)*(point.z-c.z))/den
		if minf(u,minf(v,1.0-u-v))>=-1e-7:
			var y:float=u*a.y+v*b.y+(1.0-u-v)*c.y
			rows.append({"triangle":i,"y":y,"barycentric":[u,v,1.0-u-v]});land_y=maxf(land_y,y)
	return {"ok":not rows.is_empty(),"y":land_y if not rows.is_empty() else null,"xz":[point.x,point.z],"triangles":rows,"binding":world_info.get("player_land_binding",{}).duplicate(true)}


func _setup_grounded_pose(spec:Dictionary,f:Dictionary) -> bool:
	var xz:Array=spec.setup_position_xz
	var pose:=Vector3(float(xz[0]),0.0,float(xz[1]))
	var terrain:Dictionary=_setup_land_height(pose)
	active_attempt["setup_support_query"]={"terrain_basis":terrain,"query_performed":false,"from":[],"to":[],"collision_mask":1,"excludes_only_player":true,"actual_hit":{}}
	_check_contact(bool(terrain.ok),str(spec.id)+" setup XZ has bound native LAND height.")
	if not bool(terrain.ok):return false
	pose.y=float(terrain.y)
	var query_from:=pose+Vector3.UP*.5;var query_to:=pose-Vector3.UP*.5
	var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(query_from,query_to,1,[contact_player.get_rid()]))
	active_attempt["setup_support_query"]["query_performed"]=true
	active_attempt["setup_support_query"]["from"]=_vector3(query_from)
	active_attempt["setup_support_query"]["to"]=_vector3(query_to)
	active_attempt["setup_support_query"]["actual_hit"]=_ray_value(hit)
	var identity:Dictionary={} if hit.is_empty() else _collider_identity(hit.collider,int(hit.shape))
	var valid:bool=not hit.is_empty() and str(identity.get("derived_object_key","")) in LAND_KEYS and int(identity.get("shape_index",-1))==0
	_check_contact(valid,str(spec.id)+" setup actually reaches source LAND shape0.")
	if not valid:return false
	pose.y=hit.position.y+.1;await _place(pose,f)
	if _finished:return false
	_hold_at_resting_boundary()
	# Final route aim is horizontal and along actual outward normal; stock FOV/arm unchanged.
	var aim:=_aim_stock_player_camera(contact_player,contact_player.global_position+Vector3.UP*2.0-(f.normal as Vector3)*8.0)
	for i in 6:await physics_frame;await process_frame
	if _finished:return false
	var final_camera:=_final_camera_ground_state()
	var land_state:Dictionary=_player_land_state()
	active_attempt["setup_land_state"]=land_state
	var grounded:bool=contact_player.is_on_floor() and bool(land_state.ok)
	var valid_camera:bool=bool(final_camera.segment_clear) and bool(final_camera.land_identity_ok) and bool(final_camera.camera_above_land)
	_check_contact(bool(aim.ok) and grounded and valid_camera,str(spec.id)+" grounded setup and final stock camera ready.")
	return bool(aim.ok) and grounded and valid_camera


func _visual_trajectory_join(_spec:Dictionary,_trace:Array,_brake:Array,_retreat:bool=false) -> Dictionary:
	return {"requested":false,"ok":false,"scope":"1439 remaining planned seams require complete new mechanics; no inherited visual-only exception."}

func _route_attempt(spec:Dictionary,f:Dictionary) -> void:
	var route_start_usec:=Time.get_ticks_usec()
	active_attempt_start_usec=route_start_usec
	active_attempt={"kind":"route","label":spec.id,"performed":false,"step":"setup"};active_completed_phases={}
	var route_timing:Dictionary={"clock":"Time.get_ticks_usec monotonic wall"}
	if not await _setup_grounded_pose(spec,f):
		if _finished:return
		route_attempts.append({"record_state":"incomplete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"label":spec.id,"performed":false,"reason":"Source-grounded setup failed.","setup_land_state":active_attempt.get("setup_land_state",{}),"ok":false,"timing_usec":{"setup_failed_wall_usec":Time.get_ticks_usec()-route_start_usec}});active_attempt={};active_completed_phases={};return
	route_timing["setup_and_settle_usec"]=Time.get_ticks_usec()-route_start_usec
	var basis_start:=Engine.get_physics_frames()
	_clear_gameplay_input();Input.action_press("move_forward")
	var input:=Input.get_vector("move_left","move_right","move_forward","move_back")
	_clear_gameplay_input()
	var forward:Vector3=contact_player.camera_rig.planar_forward()
	var basis:Dictionary={"input_vector":[input.x,input.y],"forward":_vector3(forward),"source_normal":_vector3(f.normal),"dot":forward.dot(f.normal),"physics_frames":Engine.get_physics_frames()-basis_start}
	var basis_ok:bool=input==Vector2.UP and float(basis.dot)<-.999 and int(basis.physics_frames)==0
	_check_contact(basis_ok,str(spec.id)+" actual signed stock forward input points toward facade.")
	if not basis_ok:
		route_attempts.append({"record_state":"incomplete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"label":spec.id,"performed":false,"reason":"Signed input/camera basis failed.","basis":basis,"ok":false,"timing_usec":{"failed_before_input_wall_usec":Time.get_ticks_usec()-route_start_usec}});active_attempt={};active_completed_phases={};return
	var initial:=_endpoint(f);var placement_count:=placements.size()
	var fixed_pivot:=_vector3(contact_player.camera_rig.rotation);var fixed_arm:=_vector3(contact_player.camera_rig.spring_arm.rotation)
	var process_begin:=Engine.get_process_frames();var physics_begin:=Engine.get_physics_frames();var draw_begin:=Engine.get_frames_drawn()
	contact_player.set_gameplay_enabled(true)
	active_attempt["performed"]=true;active_attempt["step"]="forward"
	var input_wall_start_usec:=Time.get_ticks_usec()
	var stop_condition:Dictionary={}
	if bool(spec.get("stop_on_expected_contact",false)):
		stop_condition={"expected_obstruction_shapes":spec.get("expected_obstruction_shapes",[int(spec.expected_shape)]),"expected_shape":spec.expected_shape,"expected_role":spec.expected_role,"source_normal":_vector3(f.normal)}
	var trace:=await _trace_phase(["move_forward"],int(spec.input_frames),str(spec.id)+"_forward",stop_condition)
	if _finished:return
	route_timing["input_wall_usec"]=Time.get_ticks_usec()-input_wall_start_usec
	var input_endpoint:=_endpoint(f)
	active_attempt["step"]="natural_braking"
	var brake_wall_start_usec:=Time.get_ticks_usec()
	var brake:=await _trace_phase([],int(spec.brake_frames),str(spec.id)+"_natural_braking")
	if _finished:return
	route_timing["brake_wall_usec"]=Time.get_ticks_usec()-brake_wall_start_usec
	var endpoint:=_endpoint(f);var land_frames:=0;var obstruction_events:=0;var obstruction_rows:=0;var ground_ok:=true;var camera_ok:=true;var station_ok:=true;var maximum_station_drift:=0.0
	for row:Dictionary in trace+brake:
		var observed_land:=false;var observed_obstruction:=false
		for hit:Dictionary in row.slide_contacts:
			if float(hit.normal[1])>.7:
				ground_ok=ground_ok and _supported_contact(hit)
				if str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0:observed_land=true
			if bool(hit.exact_structure_body) and int(hit.shape_index) in spec.get("expected_obstruction_shapes",[int(spec.expected_shape)]) and str(hit.structural_role)==str(spec.expected_role) and _v(hit.normal).dot(f.normal)>.7:
				obstruction_events+=1;observed_obstruction=true
				ground_ok=ground_ok and _contact_role_metadata_ok(hit,str(spec.expected_role))
		if observed_land:land_frames+=1
		if observed_obstruction:obstruction_rows+=1
		ground_ok=ground_ok and bool(row.on_floor) and bool(row.player_land_state.ok)
		var camera:Dictionary=row.camera_state
		camera_ok=camera_ok and bool(camera.segment_clear) and bool(camera.land_identity_ok) and bool(camera.camera_above_land) and _fixed_camera_check(row,fixed_pivot,fixed_arm)
		var station:float=(_v(row.position)-(f.start as Vector3)).dot(f.tangent)
		maximum_station_drift=maxf(maximum_station_drift,absf(station-float(spec.station_m)))
		station_ok=station_ok and absf(station-float(spec.station_m))<=float(spec.maximum_station_drift_m)
	var corridor:Dictionary=_corridor_rows(trace+brake,spec)
	var progress:float=float(initial.depth_m)-float(endpoint.depth_m)
	var depth_ok:bool=float(endpoint.depth_m)>=float(spec.expected_depth_interval_m[0]) and float(endpoint.depth_m)<=float(spec.expected_depth_interval_m[1])
	var forward_termination:Dictionary=active_attempt.get("forward_termination",{"mode":"fixed_budget","maximum_input_frames":spec.input_frames,"sampled_input_frames":trace.size(),"termination_reason":"fixed_budget_completed","trigger":{}}).duplicate(true)
	var forward_complete:bool=trace.size()==int(spec.input_frames)
	if not stop_condition.is_empty():
		forward_complete=not trace.is_empty() and trace.size()<=int(spec.input_frames) and str(forward_termination.termination_reason)=="verified_expected_contact" and bool(forward_termination.input_released) and int(forward_termination.sampled_input_frames)==trace.size() and int(forward_termination.get("release_physics_counter",-1))==int(trace[-1].physics_counter) and int(forward_termination.trigger.get("input_frame",-1))==trace.size() and int(forward_termination.trigger.get("physics_counter",-1))==int(trace[-1].physics_counter) and not _verified_obstruction_contact(trace[-1],stop_condition).is_empty()
	var complete:bool=forward_complete and brake.size()==int(spec.brake_frames)
	var stopped:bool=contact_player.velocity.length()<.01
	var no_placement:bool=placements.size()==placement_count
	# The unchanged 150 mm centering diagnostic is recorded, not a gameplay gate.
	var contact_ok:bool=obstruction_events>0 if str(spec.kind)=="closed" else _open_route_clear(trace+brake)
	var ok:bool=bool(corridor.ok) and complete and ground_ok and camera_ok and contact_ok and progress>=float(spec.minimum_progress_m) and depth_ok and stopped and no_placement
	var visual_join:Dictionary=_visual_trajectory_join(spec,trace,brake)
	var visual_ok:bool=bool(visual_join.ok) and bool(corridor.ok) and complete and camera_ok and obstruction_events>0 and progress>=float(spec.minimum_progress_m) and depth_ok and stopped and no_placement
	_check_contact(visual_ok if bool(visual_join.requested) else ok,str(spec.id)+" scoped complete stock approach: full mechanical gate or exact prior physical/trajectory visual reuse.",false)
	# Construct exactly one completed attempt from actual finished data; never merge into seeded evidence.
	var completed:Dictionary={"record_state":"complete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"forward_termination":forward_termination,"maximum_input_frames":spec.input_frames,"actual_approach_phase_rows":trace.size()+brake.size(),"corridor":corridor,"timing_usec":route_timing,"label":spec.id,"performed":true,"ok":ok,"signed_basis":basis,"initial":initial,"input_endpoint":input_endpoint,"endpoint":endpoint,"input_trace":trace,"brake_trace":brake,"sampled_input_frames":trace.size(),"sampled_brake_frames":brake.size(),"direct_land_contact_frames":land_frames,"direct_expected_obstruction_contact_events":obstruction_events,"direct_expected_obstruction_contact_rows":obstruction_rows,"expected_shape":spec.expected_shape,"expected_obstruction_shapes":spec.get("expected_obstruction_shapes",[int(spec.expected_shape)]),"door_assembly_binding":spec.get("door_assembly_binding",{}),"expected_role":spec.expected_role,"all_grounded_on_intended_support":ground_ok,"all_camera_checks":camera_ok,"station_held":station_ok,"station_diagnostic_limit_m":spec.maximum_station_drift_m,"station_diagnostic_only":true,"actual_maximum_station_drift_m":maximum_station_drift,"normal_progress_m":progress,"expected_stop_depth_interval_m":spec.expected_depth_interval_m,"actual_stop_depth_m":endpoint.depth_m,"stopped":stopped,"transform_writes_during_trace":placements.size()-placement_count,"process_range":[process_begin,Engine.get_process_frames()],"physics_range":[physics_begin,Engine.get_physics_frames()],"drawn_range":[draw_begin,Engine.get_frames_drawn()],"no_stair_or_traversal_between_setups_claim":true}
	completed["route_scope"]=spec.get("route_scope","full_mechanics")
	completed["mechanical_diagnostic_ok"]=ok
	completed["visual_reuse_join"]=visual_join
	completed["visual_recording_ok"]=visual_ok if bool(visual_join.requested) else false
	active_attempt["finished_observation"]=completed.duplicate(true)
	_hold_at_resting_boundary()
	active_attempt["step"]="held_marker"
	var route_marker_start_usec:=Time.get_ticks_usec()
	var marker_target:Vector3=_v(spec.inspection_target) if str(spec.kind)=="closed" else contact_player.global_position+contact_player.camera_rig.planar_forward()*2.0+Vector3.UP
	await _save_marker(str(spec.marker),marker_target,WALL_KEY,int(spec.expected_shape))
	if _finished:return
	route_timing["marker_call_usec"]=Time.get_ticks_usec()-route_marker_start_usec
	var retreat:Dictionary={"performed":false,"ok":false,"reason":"Approach or held marker failed; no retreat input performed."}
	if _case_ok():
		active_attempt["finished_observation"]=completed.duplicate(true)
		active_attempt["step"]="retreat"
		retreat=await _retreat_attempt(spec,f,fixed_pivot,fixed_arm,placement_count)
		if _finished:return
	completed["retreat"]=retreat
	completed["motion_frame_locators"]={"approach":_phase_frame_locator(trace),"stop_brake":_phase_frame_locator(brake),"retreat":_phase_frame_locator(retreat.get("input_trace",[])),"retreat_brake":_phase_frame_locator(retreat.get("brake_trace",[])),"scope":"Exact recorded per-phase engine counters; use retained marker to align movie, never substitute next setup or claim inter-setup traversal."}
	if bool(visual_join.requested):completed["visual_recording_ok"]=visual_ok and bool(retreat.get("visual_recording_ok",false)) and _case_ok()
	completed["ok"]=bool(completed.ok) and bool(retreat.ok) and _case_ok()
	completed["process_range"][1]=Engine.get_process_frames();completed["physics_range"][1]=Engine.get_physics_frames();completed["drawn_range"][1]=Engine.get_frames_drawn()
	route_timing["attempt_total_wall_usec"]=Time.get_ticks_usec()-route_start_usec
	completed["timing_usec"]=route_timing.duplicate(true)
	route_attempts.append(completed)
	active_attempt={};active_completed_phases={}


func _corridor_rows(rows:Array,spec:Dictionary) -> Dictionary:
	var corridor:Dictionary=spec.source_corridor
	var minimum:=INF;var outside:Array=[]
	var start:Vector3=_v(corridor.construction_frame_start)
	var tangent:Vector3=_v(corridor.construction_tangent)
	for i in rows.size():
		var station:float=(_v(rows[i].position)-start).dot(tangent)
		var clearance:float=float(corridor.half_width_m)-absf(station-float(corridor.centre_station_m))-float(corridor.capsule_radius_m)
		minimum=minf(minimum,clearance)
		if clearance<0.0:outside.append({"row":i+1,"physics_counter":rows[i].physics_counter,"clearance_m":clearance})
	return {"ok":not rows.is_empty() and outside.is_empty(),"minimum_capsule_side_clearance_m":minimum,"outside_rows":outside,"frame":corridor}


func _retreat_attempt(spec:Dictionary,f:Dictionary,fixed_pivot:Array,fixed_arm:Array,placement_count:int) -> Dictionary:
	var started:=Time.get_ticks_usec();var initial:=_endpoint(f)
	var basis_start:=Engine.get_physics_frames()
	_clear_gameplay_input();Input.action_press("move_back")
	var input:=Input.get_vector("move_left","move_right","move_forward","move_back")
	_clear_gameplay_input()
	var outward:Vector3=-contact_player.camera_rig.planar_forward()
	var basis_ok:bool=input==Vector2.DOWN and outward.dot(f.normal)>.999 and Engine.get_physics_frames()==basis_start
	_check_contact(basis_ok,str(spec.id)+" stock reverse input withdraws from obstruction without camera change.")
	if not basis_ok:return {"performed":false,"ok":false,"reason":"Reverse stock input basis failed."}
	contact_player.set_gameplay_enabled(true)
	var input_start:=Time.get_ticks_usec()
	var trace:=await _trace_phase(["move_back"],int(spec.retreat.input_frames),str(spec.id)+"_retreat")
	if _finished:return {}
	var input_usec:=Time.get_ticks_usec()-input_start;var input_endpoint:=_endpoint(f)
	active_attempt["step"]="retreat_natural_braking"
	var brake_start:=Time.get_ticks_usec()
	var brake:=await _trace_phase([],int(spec.retreat.brake_frames),str(spec.id)+"_retreat_natural_braking")
	if _finished:return {}
	var brake_usec:=Time.get_ticks_usec()-brake_start;var endpoint:=_endpoint(f)
	var ground_ok:=true;var camera_ok:=true;var land_rows:=0;var land_events:=0
	for row:Dictionary in trace+brake:
		var has_land:=false
		for hit:Dictionary in row.slide_contacts:
			if float(hit.normal[1])>.7:
				ground_ok=ground_ok and _supported_contact(hit)
				if str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0:has_land=true;land_events+=1
		if has_land:land_rows+=1
		ground_ok=ground_ok and bool(row.on_floor) and bool(row.player_land_state.ok)
		var camera:Dictionary=row.camera_state
		camera_ok=camera_ok and bool(camera.segment_clear) and bool(camera.land_identity_ok) and bool(camera.camera_above_land) and _fixed_camera_check(row,fixed_pivot,fixed_arm)
	var corridor:Dictionary=_corridor_rows(trace+brake,spec)
	var progress:float=float(endpoint.depth_m)-float(initial.depth_m)
	var interval:Array=spec.retreat.depth_interval_m
	var destination:bool=progress>=float(spec.retreat.minimum_progress_m) and progress<=float(spec.retreat.maximum_progress_m) and float(endpoint.depth_m)>=float(interval[0]) and float(endpoint.depth_m)<=float(interval[1])
	var stopped:bool=contact_player.velocity.length()<.01
	var ok:bool=trace.size()==int(spec.retreat.input_frames) and brake.size()==int(spec.retreat.brake_frames) and ground_ok and camera_ok and bool(corridor.ok) and destination and stopped and placements.size()==placement_count
	var visual_join:Dictionary=_visual_trajectory_join(spec,trace,brake,true)
	var visual_ok:bool=bool(visual_join.ok) and trace.size()==int(spec.retreat.input_frames) and brake.size()==int(spec.retreat.brake_frames) and camera_ok and bool(corridor.ok) and destination and stopped and placements.size()==placement_count
	_check_contact(visual_ok if bool(visual_join.requested) else ok,str(spec.id)+" scoped complete stock retreat and braking without transform writes.",false)
	_hold_at_resting_boundary()
	return {"performed":true,"ok":ok,"mechanical_diagnostic_ok":ok,"visual_reuse_join":visual_join,"visual_recording_ok":visual_ok if bool(visual_join.requested) else false,"initial":initial,"input_endpoint":input_endpoint,"endpoint":endpoint,"input_trace":trace,"brake_trace":brake,"sampled_input_frames":trace.size(),"sampled_brake_frames":brake.size(),"direct_land_contact_rows":land_rows,"direct_land_contact_events":land_events,"all_grounded_on_intended_support":ground_ok,"all_camera_checks":camera_ok,"corridor":corridor,"outward_progress_m":progress,"expected_progress_interval_m":[spec.retreat.minimum_progress_m,spec.retreat.maximum_progress_m],"destination_depth_interval_m":interval,"destination_ok":destination,"stopped":stopped,"transform_writes_during_route":placements.size()-placement_count,"timing_usec":{"input_wall_usec":input_usec,"brake_wall_usec":brake_usec,"total_wall_usec":Time.get_ticks_usec()-started}}


func _spray_case(spec:Dictionary,f:Dictionary) -> void:
	var attempt_start_usec:=Time.get_ticks_usec()
	active_attempt_start_usec=attempt_start_usec
	active_attempt={"kind":"spray","label":spec.id,"performed":false,"step":"setup"};active_completed_phases={}
	var timing:Dictionary={"clock":"Time.get_ticks_usec monotonic wall", "stock_call_usec":null,"post_call_observation_usec":null,"marker_call_usec":0}
	var setup_ok:bool=false
	if bool(spec.get("use_current_landing",false)):
		setup_ok=bool(_player_land_state().ok) and contact_player.is_on_floor()
		resting_observation=_observe_resting_boundary(false)
	else:setup_ok=await _setup_grounded_pose(spec,f)
	if not setup_ok:
		if _finished:return
		spray_attempts.append({"record_state":"incomplete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"label":spec.id,"performed":false,"reason":"Source-grounded setup failed.","setup_land_state":active_attempt.get("setup_land_state",{}),"ok":false,"timing_usec":{"setup_failed_wall_usec":Time.get_ticks_usec()-attempt_start_usec,"stock_call_usec":null}});active_attempt={};active_completed_phases={};return
	timing["setup_and_settle_usec"]=Time.get_ticks_usec()-attempt_start_usec
	active_attempt["step"]="final_aim"
	var final_aim_start_usec:=Time.get_ticks_usec()
	var target:Vector3=_v(spec.target)
	var aim:=_aim_stock_player_camera(contact_player,target)
	_check_contact(bool(aim.ok),str(spec.id)+" stock spray aim is within limits.")
	if not bool(aim.ok):
		spray_attempts.append({"record_state":"incomplete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"label":spec.id,"performed":false,"reason":"Stock aim outside limits.","aim":aim,"ok":false,"timing_usec":{"setup_and_settle_usec":timing.setup_and_settle_usec,"aim_failed_wall_usec":Time.get_ticks_usec()-final_aim_start_usec,"stock_call_usec":null}});active_attempt={};active_completed_phases={};return
	var aim_start:=Engine.get_physics_frames()
	for i in 20:await physics_frame;await process_frame
	if _finished:return
	timing["final_aim_and_wait_usec"]=Time.get_ticks_usec()-final_aim_start_usec
	var observation_start_usec:=Time.get_ticks_usec()
	var camera:=contact_player.get_camera();var final_camera:=_final_camera_ground_state()
	var center:=camera.get_viewport().get_visible_rect().size*.5
	var origin:=camera.project_ray_origin(center);var direction:=camera.project_ray_normal(center)
	var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,origin+direction*1000,4,[contact_player.get_rid()]))
	var identity:Dictionary={} if hit.is_empty() else _collider_identity(hit.collider,int(hit.shape))
	var spray:=contact_player.get_spray_controller()
	var distance:float=-1.0 if hit.is_empty() else contact_player.global_position.distance_to(hit.position)
	var exact:bool=not hit.is_empty() and str(identity.derived_object_key)==str(spec.expected_key) and int(identity.shape_index)==int(spec.expected_shape)
	if str(spec.expected_result)=="placed":exact=exact and str(identity.collider_path)==str(study_root.get_node("CurrentGeometry_wall").get_path())
	var in_range:bool=distance>=0 and distance<float(spec.maximum_attempt_distance_m) and distance<spray.maximum_range_m
	var camera_ok:bool=bool(final_camera.segment_clear) and bool(final_camera.land_identity_ok) and bool(final_camera.camera_above_land)
	var eligible:bool=exact and bool(identity.get("spray_receiver_group",false)) and str(identity.resolved_receiver_metadata.get("receiver_kind",""))=="building_wall" and bool(identity.resolved_receiver_metadata.get("opaque",false))
	var nonreceiver:bool=exact and not bool(identity.get("spray_receiver_group",false)) and str(identity.resolved_receiver_metadata.get("receiver_kind",""))=="none" and str(identity.structural_role)==str(spec.expected_role)
	var metadata_ok:bool=eligible if str(spec.expected_result)=="placed" else nonreceiver
	var performed:bool=exact and in_range and camera_ok and metadata_ok and contact_player.is_on_floor() and bool(_player_land_state().ok)
	_check_contact(performed,str(spec.id)+" actual exact shape, metadata, stock camera and conservative player-hit range before spray.")
	var results:Array=[];var identities:Array=[];var before:=spray.tag_instances.active_count()
	var receive:=func(code:String):results.append(code)
	var identity_receive:=func(key:String,keys:Array):identities.append({"derived_object_key":key,"source_keys":keys.duplicate()})
	timing["pre_call_observation_usec"]=Time.get_ticks_usec()-observation_start_usec
	var post_call_start_usec:=Time.get_ticks_usec()
	if performed:
		active_attempt["performed"]=true;active_attempt["step"]="stock_spray_call"
		spray.spray_result.connect(receive);spray.spray_identity.connect(identity_receive)
		var stock_call_start_usec:=Time.get_ticks_usec()
		spray.attempt_spray()
		post_call_start_usec=Time.get_ticks_usec()
		timing["stock_call_usec"]=post_call_start_usec-stock_call_start_usec
		spray.spray_result.disconnect(receive);spray.spray_identity.disconnect(identity_receive)
	var after:=spray.tag_instances.active_count();var decal_state:Dictionary={}
	var ok:bool=performed and results==[str(spec.expected_result)] and after==before+(1 if str(spec.expected_result)=="placed" else 0)
	if str(spec.expected_result)=="placed" and after>before:
		var decal:=spray.tag_instances.get_child(spray.tag_instances.get_child_count()-1) as Decal
		decal_state={"derived_object_key":str(decal.get_meta("derived_object_key","")),"source_keys":decal.get_meta("source_keys",[]),"cull_mask":decal.cull_mask,"transform":str(decal.global_transform),"size":_vector3(decal.size),"tag_texture":decal.texture_albedo.resource_path}
		ok=ok and identities==[{"derived_object_key":WALL_KEY,"source_keys":[source_key]}] and decal_state.derived_object_key==WALL_KEY and decal_state.source_keys==[source_key] and decal.cull_mask==2
	else:ok=ok and identities.is_empty()
	if str(spec.expected_result)=="placed" and after>before:
		var placed_decal:Decal=spray.tag_instances.get_child(spray.tag_instances.get_child_count()-1) as Decal
		decal_state["full_footprint"]=_decal_full_footprint(placed_decal,hit.position)
		ok=ok and bool(decal_state.full_footprint.ok)
	_check_contact(ok,str(spec.id)+" performed stock spray emits exact result/identity/count and full clear projected footprint.",false)
	timing["post_call_observation_usec"]=Time.get_ticks_usec()-post_call_start_usec if performed else null
	var completed:Dictionary={"record_state":"complete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"timing_usec":timing,"label":spec.id,"performed":performed,"skipped_reason":"" if performed else "Exact target/range/camera/metadata/ground prerequisite failed; no spray action was performed.","ok":ok,"aim":aim,"aim_physics_start":aim_start,"explicit_final_aim_physics_waits":20,"final_camera":final_camera,"target":spec.target,"player":_vector3(contact_player.global_position),"stock_player_grounded":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"actual_ray":identity,"actual_ray_origin":_vector3(origin),"actual_ray_direction":_vector3(direction),"actual_hit_position":[] if hit.is_empty() else _vector3(hit.position),"actual_hit_normal":[] if hit.is_empty() else _vector3(hit.normal),"actual_ray_distance_m":-1.0 if hit.is_empty() else origin.distance_to(hit.position),"actual_player_hit_distance_m":distance,"maximum_stock_range_m":spray.maximum_range_m,"conservative_attempt_limit_m":spec.maximum_attempt_distance_m,"expected_result":spec.expected_result,"result":results,"identity_signals":identities,"tags_before":before,"tags_after":after,"decal":decal_state,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"drawn_counter":Engine.get_frames_drawn()}
	active_attempt["finished_observation"]=completed.duplicate(true)
	# Retain every reached attempt; only the eligible-wall case requests a separate marker still.
	active_attempt["step"]="marker"
	var marker_start_usec:=Time.get_ticks_usec()
	if not str(spec.marker).is_empty():await _save_marker(str(spec.marker),target,str(spec.expected_key),int(spec.expected_shape))
	if _finished:return
	timing["marker_call_usec"]=Time.get_ticks_usec()-marker_start_usec if not str(spec.marker).is_empty() else 0
	timing["attempt_total_wall_usec"]=Time.get_ticks_usec()-attempt_start_usec
	completed["timing_usec"]=timing.duplicate(true)
	completed["ok"]=bool(completed.ok) and _case_ok()
	spray_attempts.append(completed)
	active_attempt={};active_completed_phases={}


func _save_marker(label:String,target:Vector3,expected_key:String,expected_shape:int) -> void:
	var marker_start_usec:=Time.get_ticks_usec()
	for i in 3:
		_clean_hud(source_main.get_node("Interface/HUD") as GameHUD)
		await process_frame;await RenderingServer.frame_post_draw
	if _finished:return
	var marker_wait_end_usec:=Time.get_ticks_usec()
	var camera:=contact_player.get_camera();var final_camera:=_final_camera_ground_state()
	_check_contact(bool(final_camera.segment_clear) and bool(final_camera.land_identity_ok) and bool(final_camera.camera_above_land),label+" saved marker has final clear source-grounded camera.")
	var projected:=camera.unproject_position(target)
	var in_frame:bool=not camera.is_position_behind(target) and Rect2(Vector2.ZERO,Vector2(STILL_SIZE)).has_point(projected)
	var direction:Vector3=(target-camera.global_position).normalized()
	var los:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.global_position,target+direction*.02,1,[contact_player.get_rid()]))
	var los_value:=_ray_value(los)
	var exact:bool=los.is_empty() if expected_shape<0 else not los.is_empty() and str(los_value.derived_object_key)==expected_key and int(los_value.shape_index)==expected_shape
	_check_contact(in_frame and exact,label+" saved marker has exact intended solid or explicitly empty open-route observation segment.",false)
	var marker_footprint:Dictionary={}
	if expected_key==WALL_KEY and "spray" in label:
		var tag_pool:Node=contact_player.get_spray_controller().tag_instances
		if tag_pool.get_child_count()>0 and not los.is_empty():marker_footprint=_decal_full_footprint(tag_pool.get_child(tag_pool.get_child_count()-1) as Decal,los.position)
		_check_contact(bool(marker_footprint.get("ok",false)),label+" whole projected tag remains clear and framed at the saved camera.",false)
	var readback_start_usec:=Time.get_ticks_usec()
	var image:Image=root.get_texture().get_image();var path:=OUTPUT+"/images/"+label+".png"
	var readback_end_usec:=Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var png_start_usec:=Time.get_ticks_usec()
	var saved:bool=image!=null and not image.is_empty() and image.get_size()==STILL_SIZE and image.save_png(path)==OK
	var png_end_usec:=Time.get_ticks_usec()
	_check_contact(saved,label+" actual original post-draw framebuffer saved.",false)
	junction_captures.append({"timing_usec":{"post_draw_wait_usec":marker_wait_end_usec-marker_start_usec,"camera_target_checks_usec":readback_start_usec-marker_wait_end_usec,"framebuffer_readback_usec":readback_end_usec-readback_start_usec,"png_validate_and_write_usec":png_end_usec-png_start_usec,"marker_wall_before_record_usec":Time.get_ticks_usec()-marker_start_usec},"id":label,"path":path,"sha256":FileAccess.get_sha256(path) if saved else "","saved_success":saved,"image_dimensions":[] if not saved else [image.get_width(),image.get_height()],"player":_vector3(contact_player.global_position),"velocity":_vector3(contact_player.velocity),"on_floor":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"slide_contacts":_walk_contacts(),"camera":_vector3(camera.global_position),"camera_forward":_vector3(-camera.global_basis.z),"camera_fov":camera.fov,"final_camera":final_camera,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"drawn_counter":Engine.get_frames_drawn(),"full_tag_footprint":marker_footprint,"inspection_target":_vector3(target),"projected_target_px":[projected.x,projected.y],"inspection_target_in_frame":in_frame,"first_world_solid_los":los_value,"expected_target_key":expected_key,"expected_target_shape":expected_shape,"pixel_scope":"Actual completed post-draw framebuffer; not asserted equal to a physics trace sample."})
	print("Northpoint1241_MECHANICS_IMAGE "+path)


func _input_strengths() -> Dictionary:
	var values:Dictionary={}
	for action:String in ["move_forward","move_back","move_left","move_right","run","jetpack"]:values[action]=Input.get_action_strength(action)
	return values



func _stock_settings() -> Dictionary:
	var p:=contact_player;var c:=p.camera_rig;var s:=p.get_spray_controller();var capsule:=p.collision_shape.shape as CapsuleShape3D
	return {"walk":p.walk_speed_mps,"run":p.run_speed_mps,"acceleration":p.acceleration_mps2,"braking":p.braking_mps2,"jetpack_ascent":p.jetpack_ascent_speed_mps,"jetpack_descent":p.jetpack_descent_speed_mps,"vertical_response":p.jetpack_vertical_response_mps2,"floor_snap":p.floor_snap_length,"safe_margin":p.safe_margin,"capsule_local_transform":str(p.collision_shape.transform),"floor_max_angle":p.floor_max_angle,"capsule_radius":capsule.radius,"capsule_height":capsule.height,"collision_layer":p.collision_layer,"collision_mask":p.collision_mask,"camera_fov":p.get_camera().fov,"min_pitch":c.minimum_pitch_degrees,"max_pitch":c.maximum_pitch_degrees,"spring_length":c.spring_arm.spring_length,"spring_margin":c.spring_arm.margin,"spring_mask":c.spring_arm.collision_mask,"spray_range":s.maximum_range_m,"max_wall_up_dot":s.maximum_wall_up_dot,"tag_size":str(s.tag_size),"projection_depth":s.projection_depth_m}


func _clip_junction(points: Array[Vector3], origin: Vector3, axis: Vector3, limit: float, greater: bool) -> Array[Vector3]:
	var result: Array[Vector3] = []
	if points.is_empty(): return result
	var previous := points[-1]
	var previous_distance := ((previous - origin).dot(axis) - limit) * (1.0 if greater else -1.0)
	for point: Vector3 in points:
		var distance := ((point - origin).dot(axis) - limit) * (1.0 if greater else -1.0)
		if (distance >= 0.0) != (previous_distance >= 0.0):
			result.append(previous.lerp(point, previous_distance / (previous_distance - distance)))
		if distance >= 0.0: result.append(point)
		previous = point; previous_distance = distance
	return result


func _material_state(material:Material) -> Dictionary:
	var state:Dictionary={"class":material.get_class()}
	for property:Dictionary in material.get_property_list():
		if (int(property.usage)&PROPERTY_USAGE_STORAGE)==0 or str(property.name) in ["script","resource_path"]:continue
		var value:Variant=material.get(str(property.name))
		if value is Resource:
			state[str(property.name)]={"class":value.get_class(),"path":value.resource_path,"name":value.resource_name}
			if value is Shader:state[str(property.name)]["code_sha256"]=value.code.sha256_text()
			if not value.resource_path.is_empty() and FileAccess.file_exists(value.resource_path):state[str(property.name)]["source_sha256"]=FileAccess.get_sha256(value.resource_path)
		else:state[str(property.name)]=var_to_bytes(value).hex_encode()
	return state



func _snapshot(node:Node) -> Dictionary:
	var out:Dictionary={"class":node.get_class(),"name":str(node.name),"children":[]}
	if node is Node3D:out["transform"]=var_to_bytes(node.transform).hex_encode()
	var metadata:Dictionary={}
	for key:StringName in node.get_meta_list():metadata[str(key)]=var_to_bytes(node.get_meta(key)).hex_encode()
	out["metadata"]=metadata
	if node is MeshInstance3D:
		out["layers"]=node.layers;out["shadow"]=node.cast_shadow;out["surfaces"]=[]
		out["mesh_class"]=node.mesh.get_class()
		out["named_surface_api"]=node.mesh is ArrayMesh
		for surface in node.mesh.get_surface_count():
			var surface_name:Variant=node.mesh.surface_get_name(surface) if node.mesh is ArrayMesh else null
			out.surfaces.append({"arrays":var_to_bytes(node.mesh.surface_get_arrays(surface)).hex_encode(),"name":surface_name,"material":_material_state(node.get_active_material(surface))})
	if node is CollisionObject3D:out["collision_layer"]=node.collision_layer;out["collision_mask"]=node.collision_mask;out["wall_group"]=node.is_in_group("spray_receiver_wall")
	if node is CollisionShape3D and node.shape is ConcavePolygonShape3D:
		out["faces"]=var_to_bytes(node.shape.get_faces()).hex_encode()
		var shape_meta:Dictionary={}
		for key:StringName in node.shape.get_meta_list():shape_meta[str(key)]=var_to_bytes(node.shape.get_meta(key)).hex_encode()
		out["shape_metadata"]=shape_meta
	for child:Node in node.get_children():out.children.append(_snapshot(child))
	return out




func _bind_native_land() -> void:
	var bindings:Array=[]
	for land_key:String in LAND_KEYS:
		var nodes:Array[Node3D]=_record_roots(land_key)
		_check_contact(nodes.size()==1,"Exactly one actual route LAND root for capsule evidence.")
		if nodes.size()!=1:return
		var body:StaticBody3D=nodes[0].get_node("Collision") as StaticBody3D
		_check_contact(body!=null and body.get_child_count()==1 and body.collision_layer==5,"Unchanged LAND collision body and single shape.")
		if body==null or body.get_child_count()!=1:return
		var shape_node:CollisionShape3D=body.get_child(0) as CollisionShape3D
		var shape:ConcavePolygonShape3D=shape_node.shape as ConcavePolygonShape3D
		_check_contact(shape!=null and not shape_node.disabled,"Actual LAND concave faces available.")
		if shape==null:return
		var faces:PackedVector3Array=shape.get_faces()
		var triangle_begin:int=native_land_triangles.size()
		for i in range(0,faces.size(),3):
			native_land_triangles.append([shape_node.global_transform*faces[i],shape_node.global_transform*faces[i+1],shape_node.global_transform*faces[i+2]])
		bindings.append({"key":land_key,"body_path":str(body.get_path()),"shape_index":0,"shape_path":str(shape_node.get_path()),"shape_transform":str(shape_node.global_transform),"faces_sha256":var_to_bytes(faces).hex_encode().sha256_text(),"triangle_begin":triangle_begin,"triangle_end_exclusive":native_land_triangles.size(),"triangles":int(faces.size()/3),"scope":"Actual unchanged native LAND faces; full before/after surface snapshot also bound."})
	world_info["player_land_binding"]=bindings


func _closest_triangle(p:Vector3,a:Vector3,b:Vector3,c:Vector3) -> Vector3:
	var ab:Vector3=b-a;var ac:Vector3=c-a;var ap:Vector3=p-a
	var d1:float=ab.dot(ap);var d2:float=ac.dot(ap)
	if d1<=0.0 and d2<=0.0:return a
	var bp:Vector3=p-b;var d3:float=ab.dot(bp);var d4:float=ac.dot(bp)
	if d3>=0.0 and d4<=d3:return b
	var vc:float=d1*d4-d3*d2
	if vc<=0.0 and d1>=0.0 and d3<=0.0:return a+ab*(d1/(d1-d3))
	var cp:Vector3=p-c;var d5:float=ab.dot(cp);var d6:float=ac.dot(cp)
	if d6>=0.0 and d5<=d6:return c
	var vb:float=d5*d2-d1*d6
	if vb<=0.0 and d2>=0.0 and d6<=0.0:return a+ac*(d2/(d2-d6))
	var va:float=d3*d6-d5*d4
	if va<=0.0 and d4-d3>=0.0 and d5-d6>=0.0:return b+(c-b)*((d4-d3)/((d4-d3)+(d5-d6)))
	var inverse:float=1.0/(va+vb+vc)
	return a+ab*(vb*inverse)+ac*(vc*inverse)


func _segment_distance(p1:Vector3,q1:Vector3,p2:Vector3,q2:Vector3) -> float:
	var d1:Vector3=q1-p1;var d2:Vector3=q2-p2;var r:Vector3=p1-p2
	var a:float=d1.dot(d1);var e:float=d2.dot(d2);var f:float=d2.dot(r)
	var ss:float=0.0;var tt:float=0.0
	if a<=1e-15 and e<=1e-15:return p1.distance_to(p2)
	if a<=1e-15:tt=clampf(f/e,0.0,1.0)
	else:
		var cc:float=d1.dot(r)
		if e<=1e-15:ss=clampf(-cc/a,0.0,1.0)
		else:
			var bb:float=d1.dot(d2);var denominator:float=a*e-bb*bb
			ss=clampf((bb*f-cc*e)/denominator,0.0,1.0) if absf(denominator)>1e-15 else 0.0
			tt=(bb*ss+f)/e
			if tt<0.0:tt=0.0;ss=clampf(-cc/a,0.0,1.0)
			elif tt>1.0:tt=1.0;ss=clampf((bb-cc)/a,0.0,1.0)
	return (p1+d1*ss).distance_to(p2+d2*tt)


func _segment_triangle(p:Vector3,q:Vector3,a:Vector3,b:Vector3,c:Vector3) -> float:
	var direction:Vector3=q-p;var e1:Vector3=b-a;var e2:Vector3=c-a;var h:Vector3=direction.cross(e2);var det:float=e1.dot(h)
	if absf(det)>1e-12:
		var inv:float=1.0/det;var ss:Vector3=p-a;var u:float=inv*ss.dot(h);var qq:Vector3=ss.cross(e1);var v:float=inv*direction.dot(qq);var t:float=inv*e2.dot(qq)
		if u>=0.0 and u<=1.0 and v>=0.0 and u+v<=1.0 and t>=0.0 and t<=1.0:return 0.0
	return minf(minf(p.distance_to(_closest_triangle(p,a,b,c)),q.distance_to(_closest_triangle(q,a,b,c))),minf(_segment_distance(p,q,a,b),minf(_segment_distance(p,q,b,c),_segment_distance(p,q,c,a))))


func _fixed_camera_check(row:Dictionary,pivot:Array,arm:Array) -> bool:
	var errors:Array=[]
	for pair:Array in [[row.camera_pivot_rotation,pivot],[row.camera_arm_rotation,arm]]:
		var delta:Vector3=_v(pair[0])-_v(pair[1])
		delta=Vector3(wrapf(delta.x,-PI,PI),wrapf(delta.y,-PI,PI),wrapf(delta.z,-PI,PI))
		var actual:=Basis.from_euler(_v(pair[0]));var expected:=Basis.from_euler(_v(pair[1]))
		var basis_error:float=0.0
		for axis:int in 3:
			var a:Vector3=actual[axis].normalized();var b:Vector3=expected[axis].normalized()
			basis_error=maxf(basis_error,atan2(a.cross(b).length(),a.dot(b)))
		errors.append({"euler_delta_length_rad":delta.length(),"maximum_basis_axis_angle_rad":basis_error})
	var ok:bool=true
	for error:Dictionary in errors:ok=ok and float(error.euler_delta_length_rad)<=1e-6 and float(error.maximum_basis_axis_angle_rad)<=1e-6
	row["fixed_camera_numeric_check"]={"ok":ok,"tolerance_rad":1e-6,"pivot_and_arm":errors}
	return ok

func _qualify_threshold_edge(row:Dictionary,previous_position:Vector3,previous_physics:int) -> void:
	var state:Dictionary=row.player_land_state
	state["static_distance_ok"]=bool(state.ok)
	var observation:Dictionary={"qualified":false,"scope":"Exact native threshold-edge transition only; does not change static-distance result.","contacts":[]}
	state["threshold_edge_transition"]=observation
	if not state.has("capsule_support_clearance_m"):return
	var tolerance:float=float(state.solver_qualification_m)
	var clearance:float=float(state.capsule_support_clearance_m)
	var displacement:float=_v(row.position).distance_to(previous_position)
	var server_error:float=_v(row.position).distance_to(_v(row.physics_server_position))
	var effective_server_error:float=server_error
	var chosen_readback:String="body_get_state_trace"
	var callback:Dictionary=row.get("physics_callback_readback",{})
	var bound_direct:bool=bool(row.get("physics_callback_same_row",false)) and int(callback.get("physics_counter",-1))==int(row.physics_counter) and str(callback.get("phase",""))==str(row.phase) and str(callback.get("rid",""))==str(row.get("player_rid","")) and int(callback.get("player_instance_id",-1))==int(row.get("player_instance_id",-2)) and int(callback.get("rid_object_instance_id",-1))==int(row.get("player_instance_id",-2)) and int(row.get("rid_object_instance_id",-1))==int(row.get("player_instance_id",-2)) and bool(callback.get("direct_state_available",false))
	if bound_direct:
		bound_direct=_v(callback.node_position)==_v(row.position) and _v(callback.direct_state_position).is_finite()
	observation["direct_state_identity_bound"]=bound_direct
	if bound_direct:
		var direct_error:float=_v(callback.direct_state_position).distance_to(_v(row.position))
		observation["direct_state_node_error_m"]=direct_error
		if (not is_finite(server_error) or server_error>.000001) and direct_error<=.000001:
			effective_server_error=direct_error;chosen_readback="identity_bound_same_physics_callback_direct_state"
	observation["chosen_readback_source"]=chosen_readback
	observation["qualified_server_error_m"]=effective_server_error
	observation["server_agreement_tolerance_m"]=.000001
	observation.merge({"previous_position":_vector3(previous_position),"frame_displacement_m":displacement,"physics_frame_delta":int(row.physics_counter)-previous_physics,"node_server_error_m":server_error,"normal_plane_tolerance_m":tolerance,"native_edge_point_tolerance_m":.0001})
	# No qualification for static hover, penetration, unrelated geometry or skipped physics rows.
	if bool(state.ok) or clearance<=tolerance or not bool(state.actual_stock_transform) or not bool(row.on_floor) or threshold_support_shape<0 or int(state.shape_index)!=threshold_support_shape or str(state.support_kind)!="exact_bound_visible_top" or _v(state.foot).distance_to(_v(row.position))>=.0001 or displacement<=.000001 or not is_finite(effective_server_error) or effective_server_error>.000001 or int(row.physics_counter)-previous_physics!=1:return
	var edges:Array=[]
	for i in range(native_land_triangles.size(),native_support_triangles.size()):
		var bound:Dictionary=support_binding_by_triangle[i-native_land_triangles.size()]
		if int(bound.shape_index)!=int(state.shape_index) or str(bound.key)!=str(state.support_key) or str(bound.role)!=str(state.support_role):continue
		var tri:Array=native_support_triangles[i]
		for j in 3:
			var a:Vector3=tri[j];var b:Vector3=tri[(j+1)%3];var shared:=false
			for edge:Dictionary in edges:
				if (a==edge.a and b==edge.b) or (a==edge.b and b==edge.a):edge.count=int(edge.count)+1;shared=true;break
			if not shared:edges.append({"a":a,"b":b,"count":1})
	var low:Vector3=_v(state.capsule_axis[0]);var radius:float=float(state.capsule_radius_m)
	for hit:Dictionary in row.slide_contacts:
		if not _supported_contact(hit) or int(hit.shape_index)!=threshold_support_shape or str(hit.derived_object_key)!=str(state.support_key) or str(hit.structural_role)!=str(state.support_role):continue
		var normal:Vector3=_v(hit.normal).normalized();var point:Vector3=_v(hit.position)
		if normal.y<=.7:continue
		var edge_distance:float=INF
		for edge:Dictionary in edges:
			if int(edge.count)!=1:continue
			var a:Vector3=edge.a;var b:Vector3=edge.b
			var closest:Vector3=a+(b-a)*clampf((point-a).dot(b-a)/(b-a).length_squared(),0.0,1.0)
			edge_distance=minf(edge_distance,point.distance_to(closest))
		var offset:Vector3=low-point;var projection:float=offset.dot(normal)
		var gap:float=projection-radius;var tangent:float=(offset-normal*projection).length()
		var qualifies:bool=edge_distance<=.0001 and gap>=-tolerance and gap<=tolerance and tangent<=displacement
		observation.contacts.append({"contact":hit.duplicate(true),"native_boundary_edge_distance_m":edge_distance,"signed_normal_plane_gap_m":gap,"tangential_offset_m":tangent,"qualified":qualifies})
		if qualifies:observation.qualified=true
	state["ok"]=bool(state.static_distance_ok) or bool(observation.qualified)


func _player_land_state() -> Dictionary:
	var shape_node:CollisionShape3D=contact_player.collision_shape
	var capsule:CapsuleShape3D=shape_node.shape as CapsuleShape3D
	if capsule==null or native_support_triangles.is_empty():return {"ok":false,"reason":"Actual capsule or bound LAND faces unavailable."}
	var transform:Transform3D=shape_node.global_transform
	var scale:Vector3=transform.basis.get_scale();var axis:Vector3=transform.basis.y.normalized()
	var actual_stock_shape:bool=scale.is_equal_approx(Vector3.ONE) and axis.is_equal_approx(Vector3.UP) and is_equal_approx(capsule.radius,.35) and is_equal_approx(capsule.height,1.8)
	var low:Vector3=transform*Vector3(0.0,-capsule.height/2.0+capsule.radius,0.0)
	var high:Vector3=transform*Vector3(0.0,capsule.height/2.0-capsule.radius,0.0)
	var foot:Vector3=transform*Vector3(0.0,-capsule.height/2.0,0.0)
	var minimum:float=INF;var nearest:int=-1;var foot_heights:Array=[];var maximum_slope:float=0.0
	for i in native_support_triangles.size():
		var tri:Array=native_support_triangles[i];var a:Vector3=tri[0];var b:Vector3=tri[1];var c:Vector3=tri[2]
		var normal:Vector3=(b-a).cross(c-a).normalized()
		if foot.x>=minf(a.x,minf(b.x,c.x))-capsule.radius and foot.x<=maxf(a.x,maxf(b.x,c.x))+capsule.radius and foot.z>=minf(a.z,minf(b.z,c.z))-capsule.radius and foot.z<=maxf(a.z,maxf(b.z,c.z))+capsule.radius:
			var clearance:float=_segment_triangle(low,high,a,b,c)-capsule.radius
			if clearance<minimum:minimum=clearance;nearest=i
			if absf(normal.y)>1e-8:maximum_slope=maxf(maximum_slope,Vector2(normal.x,normal.z).length()/absf(normal.y))
		var den:float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
		if absf(den)<1e-12:continue
		var u:float=((b.z-c.z)*(foot.x-c.x)+(c.x-b.x)*(foot.z-c.z))/den
		var v:float=((c.z-a.z)*(foot.x-c.x)+(a.x-c.x)*(foot.z-c.z))/den
		if minf(u,minf(v,1.0-u-v))>=-1e-7:foot_heights.append({"triangle":i,"y":u*a.y+v*b.y+(1.0-u-v)*c.y})
	if nearest<0 or foot_heights.is_empty():return {"ok":false,"reason":"Actual capsule footprint lacks LAND geometry.","foot":_vector3(foot),"nearest_triangle":nearest,"foot_heights":foot_heights}
	var land_y:float=-INF
	for row:Dictionary in foot_heights:land_y=maxf(land_y,float(row.y))
	var delta:float=foot.y-land_y
	var tolerance:float=maxf(.002,contact_player.safe_margin*4.0)
	var max_foot_gap:float=capsule.radius*maximum_slope+tolerance
	var threshold_support:bool=nearest>=native_land_triangles.size()
	var support:Dictionary=support_binding_by_triangle[nearest-native_land_triangles.size()] if threshold_support else {}
	threshold_support_shape=int(support.shape_index) if threshold_support else -1
	var ok:bool=actual_stock_shape and absf(minimum)<=tolerance and (threshold_support or (delta>=-tolerance and delta<=max_foot_gap)) and foot.distance_to(contact_player.global_position)<.0001
	return {"ok":ok,"source_keys":[source_key] if threshold_support else LAND_KEYS,"shape_index":threshold_support_shape if threshold_support else 0,"support_key":support.get("key",""),"support_role":support.get("role",""),"support_kind":"exact_bound_visible_top" if threshold_support else "source_land","foot":_vector3(foot),"player_origin":_vector3(contact_player.global_position),"capsule_axis":[_vector3(low),_vector3(high)],"capsule_radius_m":capsule.radius,"capsule_height_m":capsule.height,"actual_stock_transform":actual_stock_shape,"nearest_support_triangle":nearest,"capsule_support_clearance_m":minimum,"foot_support_y":land_y,"foot_minus_support_m":delta,"foot_source_triangles":foot_heights,"safe_margin_m":contact_player.safe_margin,"solver_qualification_m":tolerance,"slope_derived_maximum_foot_gap_m":max_foot_gap,"scope":"Actual sampled native capsule-to-LAND or exact source-bound threshold-top triangle distance. Negative means geometric overlap;2mm or4x safe-margin bounds solver-scale qualification. Independent of on_floor, empty contacts are retained; no continuous swept-volume proof."}


func _footprint_polygon_area(points:Array[Vector3]) -> float:
	var area:=0.0
	for i in range(1,points.size()-1):area+=(points[i]-points[0]).cross(points[i+1]-points[0]).length()*.5
	return area


func _decal_full_footprint(decal:Decal,hit_position:Vector3) -> Dictionary:
	var camera:=contact_player.get_camera()
	var right:=decal.global_basis.x.normalized();var normal:=decal.global_basis.y.normalized();var up:=decal.global_basis.z.normalized()
	var centre:Vector3=decal.global_position-normal*.015
	var half_width:float=decal.size.x*.5;var half_height:float=decal.size.z*.5
	var depth_low:float=.015-decal.size.y*.5;var depth_high:float=.015+decal.size.y*.5
	var skin:Vector3=centre
	var corners:Array[Vector3]=[];var pixels:Array=[];var framed:=true
	for uv:Vector2 in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
		var corner:Vector3=skin+right*(uv.x*half_width)+up*(uv.y*half_height)
		corners.append(corner);var pixel:=camera.unproject_position(corner);pixels.append([pixel.x,pixel.y])
		framed=framed and not camera.is_position_behind(corner) and Rect2(Vector2.ZERO,Vector2(STILL_SIZE)).has_point(pixel)
	var planes:Array=[]
	for i in 4:
		var axis:Vector3=(corners[i]-camera.global_position).cross(corners[(i+1)%4]-camera.global_position).normalized()
		if (skin-camera.global_position).dot(axis)<0.0:axis=-axis
		planes.append({"origin":camera.global_position,"axis":axis,"limit":0.0})
	planes.append({"origin":centre,"axis":normal,"limit":.001})
	planes.append({"origin":camera.global_position,"axis":-normal,"limit":.001})
	var cone_bounds:=AABB(camera.global_position,Vector3.ZERO)
	for corner:Vector3 in corners:cone_bounds=cone_bounds.expand(corner)
	cone_bounds=cone_bounds.grow(.001)
	var box_bounds:=AABB(centre,Vector3.ZERO)
	for x:float in [-half_width,half_width]:
		for y:float in [-half_height,half_height]:
			for z:float in [depth_low,depth_high]:box_bounds=box_bounds.expand(centre+right*x+up*y+normal*z)
	box_bounds=box_bounds.grow(.001)
	var meshes:Array=source_world.find_children("*","MeshInstance3D",true,false)
	meshes.append_array(contact_player.find_children("*","MeshInstance3D",true,false))
	var inspected:Array=[];var box_obstacles:Array=[];var cone_obstacles:Array=[];var unsupported:Array=[]
	var box_receiver_hits:Array=[];var skin_area:=0.0;var triangle_count:=0
	for node:Node in meshes:
		var mesh:=node as MeshInstance3D
		if mesh.mesh==null or not mesh.is_visible_in_tree() or (mesh.layers&camera.cull_mask)==0:continue
		var world_bounds:AABB=mesh.global_transform*mesh.get_aabb()
		if not world_bounds.intersects(cone_bounds) and not world_bounds.intersects(box_bounds):continue
		inspected.append({"path":str(mesh.get_path()),"layers":mesh.layers,"transform":str(mesh.global_transform)})
		for surface in mesh.mesh.get_surface_count():
			var arrays:=mesh.mesh.surface_get_arrays(surface)
			var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
			var indices:PackedInt32Array=PackedInt32Array() if arrays[Mesh.ARRAY_INDEX]==null else arrays[Mesh.ARRAY_INDEX]
			if indices.is_empty():
				for j in vertices.size():indices.append(j)
			if indices.size()%3!=0:
				unsupported.append({"path":str(mesh.get_path()),"surface":surface,"reason":"Non-triangular index count"});continue
			for j in range(0,indices.size(),3):
				triangle_count+=1
				var triangle:Array[Vector3]=[mesh.global_transform*vertices[indices[j]],mesh.global_transform*vertices[indices[j+1]],mesh.global_transform*vertices[indices[j+2]]]
				var polygon:Array[Vector3]=triangle.duplicate()
				for bound:Array in [[right,-half_width,half_width],[up,-half_height,half_height],[normal,depth_low,depth_high]]:
					polygon=_clip_junction(polygon,centre,bound[0],bound[1],true)
					polygon=_clip_junction(polygon,centre,bound[0],bound[2],false)
				var box_area:float=_footprint_polygon_area(polygon)
				if box_area>0.000000001:
					var row:Dictionary={"path":str(mesh.get_path()),"surface":surface,"triangle":j/3,"clipped_area_m2":box_area,"layers":mesh.layers}
					if (mesh.layers&decal.cull_mask)==0:box_obstacles.append(row)
					else:box_receiver_hits.append(row)
					var midpoint:Vector3=(triangle[0]+triangle[1]+triangle[2])/3.0
					if str(mesh.get_meta("physical_role",""))=="wall" and absf((midpoint-centre).dot(normal))<.001:skin_area+=box_area
				polygon=triangle.duplicate()
				for plane:Dictionary in planes:polygon=_clip_junction(polygon,plane.origin,plane.axis,plane.limit,true)
				var cone_area:float=_footprint_polygon_area(polygon)
				if cone_area>0.000000001:cone_obstacles.append({"path":str(mesh.get_path()),"surface":surface,"triangle":j/3,"clipped_area_m2":cone_area})
	var size_ok:bool=decal.size.is_equal_approx(Vector3(1.2,.08,.65)) and up.dot(Vector3.UP)>.99999 and absf(normal.y)<.00001 and centre.distance_to(hit_position)<.001
	var skin_ok:bool=absf(skin_area-decal.size.x*decal.size.z)<.0001
	return {"ok":size_ok and skin_ok and framed and box_obstacles.is_empty() and cone_obstacles.is_empty() and unsupported.is_empty(),"size_ok":size_ok,"mapped_front_skin_coverage_ok":skin_ok,"mapped_front_skin_area_m2":skin_area,"whole_rectangle_framed":framed,"centre":_vector3(centre),"actual_hit":_vector3(hit_position),"origin":_vector3(decal.global_position),"basis_x":_vector3(right),"basis_y":_vector3(normal),"basis_z":_vector3(up),"size":_vector3(decal.size),"normal_depth_from_hit_m":[depth_low,depth_high],"corners":corners.map(func(p:Vector3):return _vector3(p)),"pixel_corners":pixels,"camera":_vector3(camera.global_position),"box_nonreceiver_intersections":box_obstacles,"box_receiver_intersections":box_receiver_hits,"camera_cone_intersections":cone_obstacles,"unsupported_surfaces":unsupported,"inspected_meshes":inspected,"triangles_tested":triangle_count,"scope":"Actual complete triangle/box and camera-cone clipping at this camera, including visible source-world geometry and stock avatar. Cone stops 1 mm before the coincident projected front plane; <=1e-9m2 is numerical zero. Full projected front area tolerance.0001m2, hit-origin1mm. This finite geometry result does not replace independent inspection of the whole unchanged SVG in the original PNG."}

func _route_frame(spec: Dictionary) -> Dictionary:
	var f:Dictionary=spec.frame
	return {"start":_v(f.start),"tangent":_v(f.tangent),"normal":_v(f.normal)}

func _contact_role_metadata_ok(hit:Dictionary,role:String) -> bool:
	var wall:bool=role=="wall"
	return bool(hit.spray_receiver_group)==wall and str(hit.resolved_receiver_metadata.get("receiver_kind",""))==("building_wall" if wall else "none")

func _open_route_clear(rows:Array) -> bool:
	for row:Dictionary in rows:
		for hit:Dictionary in row.slide_contacts:
			if float(hit.normal[1])<=.7:return false
	return true

func _require(ok:bool,message:String)->bool:
	_check_contact(ok,message)
	return ok

func _native_front_readback(owner:Node3D) -> void:
	for node:Node in owner.find_children("*","MeshInstance3D",true,false):
		var mesh:=node as MeshInstance3D
		var intended:Vector3=mesh.get_meta("intended_exterior",Vector3.ZERO)
		var kind:String=str(mesh.get_meta("exterior_kind",""))
		for surface in mesh.mesh.get_surface_count():
			var arrays:Array=mesh.mesh.surface_get_arrays(surface)
			var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX];var normals:PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
			var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX] if arrays[Mesh.ARRAY_INDEX]!=null else PackedInt32Array()
			if indices.is_empty():
				for i in vertices.size():indices.append(i)
			var row:Dictionary={"mesh":str(mesh.get_path()),"surface":surface,"exterior_kind":kind,"intended_exterior":[intended.x,intended.y,intended.z],"triangles":0,"collapsed":0,"minimum_front_normal_dot":1.0,"minimum_intended_front_dot":null,"intended_outward_observed":intended!=Vector3.ZERO,"offending":[]}
			for i in range(0,indices.size(),3):
				var a:Vector3=mesh.global_transform*vertices[indices[i]];var b:Vector3=mesh.global_transform*vertices[indices[i+1]];var c:Vector3=mesh.global_transform*vertices[indices[i+2]]
				var cross:Vector3=(b-a).cross(c-a)
				if cross.length_squared()<0.000000000001:row.collapsed+=1;continue
				row.triangles+=1
				var front:Vector3=-cross.normalized();var minimum:float=1.0
				for j in 3:
					var normal:Vector3=(mesh.global_basis.inverse().transposed()*normals[indices[i+j]]).normalized()
					minimum=minf(minimum,front.dot(normal))
				row.minimum_front_normal_dot=minf(float(row.minimum_front_normal_dot),minimum)
				var exterior:Variant=null if intended==Vector3.ZERO else front.dot(intended.normalized())
				if exterior!=null:row.minimum_intended_front_dot=exterior if row.minimum_intended_front_dot==null else minf(float(row.minimum_intended_front_dot),float(exterior))
				if minimum<=0.0 or (exterior!=null and float(exterior)<=0.0):row.offending.append({"triangle":i/3,"vertices":[[a.x,a.y,a.z],[b.x,b.y,b.z],[c.x,c.y,c.z]],"front":[front.x,front.y,front.z],"front_normal_dot":minimum,"intended_front_dot":exterior})
			native_fronts.append(row)
			_require(row.offending.is_empty(),"Actual consumed front/normal orientation "+str(mesh.get_path()))

func _visibility_v3(v:Vector3)->Array:
	return [v.x,v.y,v.z]

func _visibility_transform(value:Transform3D)->Array:
	return [_visibility_v3(value.basis.x),_visibility_v3(value.basis.y),_visibility_v3(value.basis.z),_visibility_v3(value.origin)]

func _visibility_packed(value:Variant)->Dictionary:
	if value==null:return {"type":TYPE_NIL,"bytes":""}
	var kind:int=typeof(value)
	assert(kind in [TYPE_PACKED_VECTOR3_ARRAY,TYPE_PACKED_VECTOR2_ARRAY,TYPE_PACKED_FLOAT32_ARRAY,TYPE_PACKED_INT32_ARRAY,TYPE_PACKED_BYTE_ARRAY,TYPE_PACKED_COLOR_ARRAY])
	return {"type":kind,"bytes":value.to_byte_array().hex_encode()}

func _visibility_material(material:Material)->Dictionary:
	if material is ShaderMaterial:
		var row:Dictionary={"class":"ShaderMaterial","shader_code":material.shader.code}
		if material.shader.code.contains("shelter_visibility"):
			var values:Dictionary={}
			for key in ["shelter_face_normal","shelter_u_axis","shelter_v_axis"]:values[key]=_visibility_v3(material.get_shader_parameter(key))
			for key in ["shelter_span","shelter_grid"]:
				var v:Vector2=material.get_shader_parameter(key);values[key]=[v.x,v.y]
			if material.shader.code.contains("original_color"):
				var color:Color=material.get_shader_parameter("original_color")
				values["original_color"]=[color.r,color.g,color.b,color.a]
				values["original_roughness"]=material.get_shader_parameter("original_roughness")
			var texture:Texture2D=material.get_shader_parameter("shelter_visibility")
			var image:Image=texture.get_image()
			values["visibility_image"]={"format":image.get_format(),"width":image.get_width(),"height":image.get_height(),"mipmaps":image.has_mipmaps(),"bytes":image.get_data().hex_encode()}
			row["parameters"]=values
		return row
	assert(material is StandardMaterial3D)
	var c:Color=material.albedo_color
	return {"class":"StandardMaterial3D","albedo_color":[c.r,c.g,c.b,c.a],"roughness":material.roughness,"metallic":material.metallic,"metallic_specular":material.metallic_specular,"cull_mode":material.cull_mode,"shading_mode":material.shading_mode,"transparency":material.transparency,"ao_enabled":material.ao_enabled,"disable_ambient_light":material.disable_ambient_light,"disable_receive_shadows":material.disable_receive_shadows}


func _json_file(path:String)->Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary

func _v3(value:Array)->Vector3:
	return Vector3(value[0],value[1],value[2])

func _render_rows(owners:Array)->Array:
	var rows:Array=[]
	for owner:Node3D in owners:
		for node:Node in owner.get_children():
			if not node is MeshInstance3D:continue
			var mesh:=node as MeshInstance3D
			var geometry:Dictionary={"class":"MeshInstance3D","local_transform":_visibility_transform(mesh.transform),"visible":mesh.visible,"cast_shadow":mesh.cast_shadow,"gi_mode":mesh.gi_mode,"surfaces":[]}
			var materials:Array=[]
			for surface in mesh.mesh.get_surface_count():
				var channels:Array=[]
				for channel in mesh.mesh.surface_get_arrays(surface):channels.append(_visibility_packed(channel))
				geometry.surfaces.append(channels);materials.append(_visibility_material(mesh.get_active_material(surface)))
			rows.append({"geometry":geometry,"materials":materials})
	return JSON.parse_string(JSON.stringify(rows)) as Array

func _bind_exact_supports(bindings:Array)->void:
	native_support_triangles=native_land_triangles.duplicate(true);support_binding_by_triangle=[];threshold_support_shape=-1
	for binding:Dictionary in bindings:
		var owner:Node3D=roof_root if str(binding.role)=="roof" else wall_root
		var body:=owner.get_node(str(binding.body)) as StaticBody3D
		var index:int=int(binding.shape_index)
		if not _require(index>=0 and index<body.get_child_count(),"Exact support index in native body"):continue
		var shape_node:=body.get_child(index) as CollisionShape3D
		var faces:PackedVector3Array=(shape_node.shape as ConcavePolygonShape3D).get_faces()
		var valid:bool=str(shape_node.name)==str(binding.shape_name) and var_to_bytes(faces).hex_encode().sha256_text()==str(binding.faces_sha256) and not shape_node.disabled
		_require(valid,"Exact actual002 support faces preserved")
		if not valid:continue
		for i in range(0,faces.size(),3):
			var a:Vector3=shape_node.global_transform*faces[i];var b:Vector3=shape_node.global_transform*faces[i+1];var c:Vector3=shape_node.global_transform*faces[i+2]
			var front:Vector3=-(b-a).cross(c-a).normalized()
			if front.y<=.7:continue
			native_support_triangles.append([a,b,c]);support_binding_by_triangle.append({"key":str(owner.get_meta("derived_object_key")),"role":binding.role,"body_path":str(body.get_path()),"shape_index":index,"faces_sha256":binding.faces_sha256})
	if not world_info.has("exact_support_bindings"):world_info["exact_support_bindings"]=[]
	world_info.exact_support_bindings.append({"bindings":bindings.duplicate(true),"bound_top_triangles":support_binding_by_triangle.duplicate(true),"land_triangles":native_land_triangles.size()})

func _supported_contact(hit:Dictionary)->bool:
	if str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0:return true
	for binding:Dictionary in support_binding_by_triangle:
		if str(hit.collider_path)==str(binding.body_path) and str(hit.derived_object_key)==str(binding.key) and int(hit.shape_index)==int(binding.shape_index) and str(hit.structural_role)==str(binding.role):return true
	return false

func _roof_attempt(spec:Dictionary)->void:
	var f:Dictionary=_route_frame(spec)
	active_attempt={"kind":"roof","label":spec.id,"step":"ground_setup","performed":false};active_completed_phases={}
	_bind_exact_supports([])
	if not await _setup_grounded_pose(spec,f):return
	var placement_count:int=placements.size();var initial:Vector3=contact_player.global_position
	contact_body=roof_root.get_node("CurrentGeometry_roof") as StaticBody3D
	_bind_exact_supports(spec.roof_bindings)
	active_attempt["performed"]=true;active_attempt["step"]="stock_jetpack_rise"
	contact_player.set_gameplay_enabled(true)
	var rise:Array=await _trace_phase(["jetpack"],int(spec.rise_frames),str(spec.id)+"_rise")
	if _finished:return
	active_attempt["step"]="stock_forward_slow_descent"
	var across:Array=await _trace_phase(["move_forward"],int(spec.forward_frames),str(spec.id)+"_cross")
	if _finished:return
	active_attempt["step"]="released_slow_descent_to_roof"
	var descent:Array=await _trace_phase([],int(spec.settle_frames),str(spec.id)+"_landing")
	if _finished:return
	var endpoint:Vector3=contact_player.global_position;var wanted:Vector3=_v(spec.landing_target)
	var support:Dictionary=_player_land_state();var exact_contact:bool=false
	for hit:Dictionary in _walk_contacts():
		if str(hit.derived_object_key)==ROOF_KEY and int(hit.shape_index) in spec.allowed_landing_shapes and str(hit.structural_role)=="roof" and _v(hit.normal).y>.7:exact_contact=true
	var ok:bool=rise.size()==int(spec.rise_frames) and across.size()==int(spec.forward_frames) and descent.size()==int(spec.settle_frames) and contact_player.is_on_floor() and bool(support.ok) and exact_contact and Vector2(endpoint.x-wanted.x,endpoint.z-wanted.z).length()<=float(spec.landing_radius_m) and placements.size()==placement_count and contact_player.velocity.length()<.01
	_check_contact(ok,str(spec.id)+" actual stock jetpack flight crosses edge and settles on exact current roof without teleport",false)
	var completed:Dictionary={"record_state":"complete","id":spec.id,"ok":ok,"rise_trace":rise,"cross_trace":across,"landing_trace":descent,"initial":_vector3(initial),"endpoint":_vector3(endpoint),"expected_landing":spec.landing_target,"exact_final_contact":exact_contact,"support":support,"transform_writes":placements.size()-placement_count}
	_hold_at_resting_boundary()
	await _save_marker(str(spec.marker),wanted,ROOF_KEY,int(spec.expected_shape))
	if _finished:return
	completed["ok"]=bool(completed.ok) and _case_ok();roof_attempts.append(completed);active_attempt={};active_completed_phases={}


func _phase_frame_locator(rows:Array)->Dictionary:
	if rows.is_empty():return {"present":false}
	return {"present":true,"first_process":rows[0].process_counter,"last_process":rows[-1].process_counter,"first_drawn":rows[0].drawn_counter,"last_drawn":rows[-1].drawn_counter,"first_physics":rows[0].physics_counter,"last_physics":rows[-1].physics_counter,"samples":rows.size()}

func _apply_land_origin()->void:
	var roots:Array[Node3D]=_record_roots("land:w26767313:x_-2__z_0")
	_check_contact(roots.size()==1,"One exact experimental LAND owner")
	if roots.size()!=1:return
	land_owner=roots[0];land_body=land_owner.get_node("Collision") as StaticBody3D
	_check_contact(land_body!=null and land_body.get_child_count()==1,"Single same LAND body and holder")
	if land_body==null or land_body.get_child_count()!=1:return
	land_holder=land_body.get_child(0) as CollisionShape3D
	land_original_shape=land_holder.shape as ConcavePolygonShape3D
	land_original_transform=land_body.transform
	land_original_snapshot=_snapshot(land_owner)
	var valid:bool=land_original_shape!=null and land_body.global_transform==Transform3D.IDENTITY and land_holder.transform==Transform3D.IDENTITY and not land_holder.disabled and land_body.collision_layer==5 and land_body.collision_mask==0
	_check_contact(valid,"Exact008 identity transform/layer/mask/enabled LAND prerequisites")
	if not valid:return
	var before_identity:Dictionary=_collider_identity(land_body,0)
	var before_rid:RID=land_body.get_rid()
	var faces:PackedVector3Array=land_original_shape.get_faces()
	var expected_hash:String="137f306660ee44d3430bbb6e898f3e358de563d8cb757d146a42cab33a17b49f"
	_check_contact(var_to_bytes(faces).hex_encode().sha256_text()==expected_hash,"Exact008 ordered366 LAND vertices")
	if not fatal_failures.is_empty():return
	var candidate:ConcavePolygonShape3D=land_original_shape.duplicate()
	var offset:Vector3=Vector3(-296,0,17)
	var local_faces:PackedVector3Array=faces.duplicate()
	for i:int in local_faces.size():local_faces[i]-=offset
	candidate.set_faces(local_faces)
	land_holder.shape=candidate
	land_body.global_position=offset
	var reconstructed:PackedVector3Array=[]
	for face:Vector3 in candidate.get_faces():reconstructed.append(land_holder.global_transform*face)
	var equivalent:bool=var_to_bytes(reconstructed)==var_to_bytes(faces)
	var identity_equal:bool=before_identity==_collider_identity(land_body,0) and before_rid==land_body.get_rid()
	land_repair={"applied":true,"fixed_offset":_vector3(offset),"same_body_rid":str(before_rid),"original_identity":before_identity,"identity_unchanged":identity_equal,"ordered_world_bytes_equal":equivalent,"world_faces_sha256":var_to_bytes(reconstructed).hex_encode().sha256_text(),"vertices":faces.size(),"layer":land_body.collision_layer,"mask":land_body.collision_mask,"backface_collision":candidate.backface_collision,"original_body_transform":var_to_bytes(land_original_transform).hex_encode(),"candidate_body_transform":var_to_bytes(land_body.transform).hex_encode(),"holder_transform":var_to_bytes(land_holder.transform).hex_encode(),"restored":false,"scope":"Only same-body collision coordinate representation; no clones, query exclusions, render/terrain/topology/controller changes."}
	_check_contact(equivalent and identity_equal,"Byte-identical world surface and same native body/source ownership")
	await physics_frame;await process_frame

func _restore_land_origin()->void:
	if not bool(land_repair.get("applied",false)):return
	land_holder.shape=land_original_shape
	land_body.transform=land_original_transform
	var restored:bool=_snapshot(land_owner)==land_original_snapshot and land_holder.shape==land_original_shape
	land_repair["restored"]=restored
	_check_contact(restored,"Original LAND resource/transform and complete snapshot restored at teardown")
