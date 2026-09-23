extends SceneTree
# Source/main startup, actual terrain, stock camera/input, original PNG saves,
# contacts and native teardown reuse the complete1308 live-driver dependencies.
const PROTOTYPE := preload("res://game/scripts/world/facades/northpoint_1229_study.gd")
const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-mechanics-001/1229"
const OUTPUT := "/private/tmp/1237-1229-mechanics-001/1229"
const CONFIG_PATH := "res://game/resources/facades/northpoint_1229_study.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-2__z_-4.json"
const WALL_KEY := "building:w96665911:wall"
const ROOF_KEY := "building:w96665911:roof"
const LAND_KEY := "land:w26767313:x_-2__z_-4"
const LAND_KEYS := ["land:w26767313:x_-2__z_-4", "land:w26767313:x_-1__z_-4"]
const AREA_KEY := "area:r17241151:x_-2__z_-4"
const ROAD_KEY := "roads:x_-2__z_-4"
const GROUND_MESH_NAMES := ["DrapedEntryPaths", "FootwaySurface"]
const STILL_SIZE := Vector2i(1440,900)
const DEFAULT_SUN := Vector3(-52,-28,0)
const CHANGED_SUN := Vector3(-26,126,0)
const VIEWS := [
	{"id":"01-whole-front-baseline","xz":Vector2(-304.88330168932686,-817.610522090058),"target":Vector3(-327.56490765911826,6.444000000000001,-825.4546173137728),"run":5,"public_front":true,"baseline":true,"sun":Vector3(-52,-28,0)},
	{"id":"02-whole-front-candidate","xz":Vector2(-304.88330168932686,-817.610522090058),"target":Vector3(-327.56490765911826,6.444000000000001,-825.4546173137728),"run":5,"public_front":true,"baseline":false,"sun":Vector3(-52,-28,0)},
	{"id":"03-roof-entry-candidate","xz":Vector2(-314.3340932512488,-820.8789374328662),"target":Vector3(-327.56490765911826,6.444000000000001,-825.4546173137728),"run":5,"public_front":false,"baseline":false,"sun":Vector3(-26,126,0)},
	{"id":"04-door-path-footway-junction","xz":Vector2(-320.71934532555184,-823.8327583408103),"target":Vector3(-328.2171521349846,3.4779692708054872,-823.5688594736839),"run":4,"public_front":false,"baseline":false,"sun":Vector3(-52,-28,0),"junction":true,"junction_station_min":2.1,"junction_station_max":4.300000000000001,"junction_depth_min":-0.05,"junction_depth_max":4.4}
]

var contact_failures:Array[String]=[]
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
# A completed record is appended once, after its final marker/timing/retreat.
# Active context preserves started work if timeout interrupts an awaited phase.
var activation_observations:Array=[]
var active_attempt:Dictionary={}
var active_completed_phases:Dictionary={}
var active_attempt_start_usec:int=0

func _initialize() -> void:
	create_timer(300.0,true,false,true).timeout.connect(_on_timeout)
	call_deferred("_run")
func _run() -> void:
	probe_mode=_argument_value("--probe-mode=")
	_check_contact(probe_mode=="mechanics" and DisplayServer.get_name().to_lower()=="macos","One native macOS bounded route/spray/support run.")
	var pins:=_json(WORK+"/../source-pins.json")
	for path:String in pins:_check_contact(FileAccess.get_sha256(path)==str(pins[path]),"Frozen source "+path)
	root.size=STILL_SIZE
	if not contact_failures.is_empty():await _end_contact(null);return
	if not await _load_current_world():await _end_contact(source_main);return
	controls_before=_stock_settings()
	frozen_study_state=_snapshot(study_root)
	_check_physical_reference()
	_bind_native_land()
	if not contact_failures.is_empty():await _end_contact(source_main);return
	lighting_observation={"scope":"Existing default world lighting retained; no repeated static study capture."}
	var plan:=_json(WORK+"/route-plan.json")
	var first_draw:=Engine.get_frames_drawn()
	motion_data={"routes":[],"sprays":[],"drawn_range":[first_draw,first_draw],"movie_path":OUTPUT+"/1229-mechanics.avi","movie_hash_status":"bind_after_writer_terminal","physics_process_draw_and_encoded_indices_distinct":true,"continuous_traversal_between_setup_poses":false,"continuous_video_review_claim":false}
	for route:Dictionary in plan.routes:
		await _route_attempt(route,_route_frame(route))
		if _finished:return
		if not contact_failures.is_empty():break
	var spray_phase_wall_usec:Variant=null
	if contact_failures.is_empty():
		var spray_phase_start_usec:=Time.get_ticks_usec()
		for spec:Dictionary in plan.sprays:
			await _spray_case(spec,_route_frame(spec))
			if _finished:return
			if not contact_failures.is_empty():break
		spray_phase_wall_usec=Time.get_ticks_usec()-spray_phase_start_usec
	motion_data={"spray_phase_wall_usec":spray_phase_wall_usec,"timing_scope":"Monotonic wall microseconds; includes setup/aim/observations/tag marker within this phase. Distinct from fixed-FPS simulation and encoded duration; no avoided-run-time claim.","routes":route_attempts,"sprays":spray_attempts,"drawn_range":[first_draw,Engine.get_frames_drawn()],"movie_path":OUTPUT+"/1229-mechanics.avi","movie_hash_status":"bind_after_writer_terminal","physics_process_draw_and_encoded_indices_distinct":true,"continuous_traversal_between_setup_poses":false,"continuous_video_review_claim":false}
	await _end_contact(source_main)

func _load_current_world() -> bool:
	source_main=load("res://game/scenes/main.tscn").instantiate() as GameMain
	source_world=source_main.get_node("WorldRoot") as WorldLoader
	contact_player=source_main.get_node("Player") as PlayerController
	var ready:Array=[];var failed:Array=[]
	source_world.world_ready.connect(func(x):ready.append(x));source_world.world_failed.connect(func(a,b,c):failed.append([a,b,c]))
	root.add_child(source_main)
	var start:=Time.get_ticks_msec()
	while ready.is_empty() and failed.is_empty() and Time.get_ticks_msec()-start<45000:await process_frame
	_check_contact(ready.size()==1 and failed.is_empty(),"Actual current main ready: "+JSON.stringify(failed))
	if not contact_failures.is_empty():return false
	for i in 120:
		if contact_player.visible:break
		await physics_frame;await process_frame
	_check_contact(contact_player.visible and contact_player.was_first_reveal_grounded(),"Main first reveals stock player grounded.")
	contact_player.recovered.connect(func(cause:String,position:Vector3):source_recoveries.append({"cause":cause,"position":_vector3(position)}))
	var e:=source_world.get_runtime_evidence()
	_check_contact(e.playable_rows==735 and e.mesh_instances==1260 and e.surfaces==1275 and e.triangles==176165 and e.static_bodies==496 and e.shapes==646,"Actual base32 whole-world counts before temporary study swap.")
	_check_contact(str(_json("res://game/resources/facades/facade-runtime-registry.json").recognition_metric.display)=="32/213","Current32 authority retained.")
	if not contact_failures.is_empty():return false
	world_info={"authority":"32/213","baseline_before_capture_swap":{"rows":e.playable_rows,"meshes":e.mesh_instances,"surfaces":e.surfaces,"triangles":e.triangles,"bodies":e.static_bodies,"shapes":e.shapes},"capture_only_target_swap":true,"production_adapter":false,"recognition_credit":0}
	for key:String in [WALL_KEY,ROOF_KEY]:
		var found:=_record_roots(key);_check_contact(found.size()==1,"One exact original source root: "+key)
		if found.size()==1:
			if key==WALL_KEY:wall_root=found[0]
			else:roof_root=found[0]
	if not contact_failures.is_empty():return false
	surface_before=_surface_state();_check_contact(surface_before.size()==6,"Actual land and separate visual area present.")
	var records:Array=_json(CHUNK_PATH).records
	# The frozen factory signature is exactly(wall,roof); failure is fatal.
	var built:=PROTOTYPE.build_for_records(PROTOTYPE._record(records,WALL_KEY),PROTOTYPE._record(records,ROOF_KEY))
	_check_contact(bool(built.get("ok",false)),"1229 Northpoint source study construction: "+str(built.get("message","")))
	if not bool(built.get("ok",false)):return false
	study_root=built.node as Node3D;study_root.name="CaptureOnlyNorthpoint1229Study"
	var channel_report:Dictionary=_source_channels(wall_root.get_node("Mesh") as MeshInstance3D,roof_root.get_node("Mesh") as MeshInstance3D,study_root)
	world_info["source_channel_comparison"]=channel_report
	_check_contact(bool(channel_report.ok),"Actual original live-world channels including tangent values and protected material/state are preserved.")
	if not bool(channel_report.ok):study_root.free();return false
	var source_collision: Dictionary = {}
	for pair: Array in [["OriginalWallRecord", wall_root], ["OriginalRoofRecord", roof_root]]:
		var actual := study_root.get_node(str(pair[0]) + "/Collision") as StaticBody3D
		var expected := (pair[1] as Node).get_node("Collision") as StaticBody3D
		var equal := actual.collision_layer == expected.collision_layer and actual.collision_mask == expected.collision_mask and actual.transform == expected.transform and actual.get_child_count() == expected.get_child_count()
		for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys"]: equal = equal and actual.get_meta(key) == expected.get_meta(key)
		equal = equal and actual.is_in_group("spray_receiver_wall") == expected.is_in_group("spray_receiver_wall")
		for index in expected.get_child_count():
			var a := actual.get_child(index) as CollisionShape3D; var b := expected.get_child(index) as CollisionShape3D
			equal = equal and a.transform == b.transform and a.disabled == b.disabled and (a.shape as ConcavePolygonShape3D).get_faces() == (b.shape as ConcavePolygonShape3D).get_faces()
		_check_contact(equal, "Exact original collision and receiver ownership: " + str(pair[0]))
		source_collision[str(pair[0])] = {"equal": equal, "layer": actual.collision_layer, "receiver": actual.get_meta("receiver_kind"), "spray_group": actual.is_in_group("spray_receiver_wall")}
	world_info["source_collision_comparison"]=source_collision
	source_world.add_child(study_root)
	for original:Node3D in [wall_root,roof_root]:
		original.hide()
		for body:CollisionObject3D in original.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
	contact_body=study_root.get_node("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	world_info["study_build"]=built.metadata
	world_info["original_source_roots_preserved"]= [str(wall_root.get_path()),str(roof_root.get_path())]
	_check_contact(surface_before==_surface_state(),"Land/area bytes and nodes survived target-only swap.")
	paused=false;Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	_clean_hud(source_main.get_node("Interface/HUD") as GameHUD)
	for i in 3:await physics_frame;await process_frame
	return contact_failures.is_empty()

func _support_ray(point:Vector3) -> Dictionary:
	# Retain the complete real-world query, not1308's
	# obsolete3m high bound. Upper scenario support uses a local vertical segment.
	var high:float=point.y+.35 if point.y>4.0 else 20.0
	var low:float=point.y-2.0 if point.y>4.0 else -5.0
	return contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(point.x,high,point.z),Vector3(point.x,low,point.z),1,[contact_player.get_rid()]))

func _end_contact(fixture:Node3D) -> void:
	if _finished:return
	_finished=true;_clear_gameplay_input()
	if not active_attempt.is_empty():
		var partial:Dictionary=active_attempt.duplicate(true)
		partial["record_state"]="incomplete";partial["ok"]=false
		if partial.has("forward_termination") and str(partial.forward_termination.termination_reason)=="in_progress":
			partial.forward_termination["termination_reason"]="interrupted"
			partial.forward_termination["input_released"]=Input.get_action_strength("move_forward")==0.0
		partial["completed_phase_traces"]=active_completed_phases.duplicate(true)
		partial["active_phase"]=active_walk_label
		partial["active_phase_trace"]=walk_trace.duplicate(true) if not active_walk_label.is_empty() else []
		partial["elapsed_wall_usec"]=Time.get_ticks_usec()-active_attempt_start_usec
		partial["reason"]="Termination interrupted this actually started attempt; no completed outcome inferred."
		if str(partial.kind)=="route":route_attempts.append(partial)
		else:spray_attempts.append(partial)
		active_attempt={};active_completed_phases={}
	if not motion_data.is_empty():
		motion_data["routes"]=route_attempts.duplicate(true);motion_data["sprays"]=spray_attempts.duplicate(true)
		motion_data["drawn_range"][1]=Engine.get_frames_drawn()
	if source_world!=null and not surface_before.is_empty():_check_contact(surface_before==_surface_state(),"Exact actual land and area survive all phases.")
	_check_contact(source_recoveries.is_empty(),"No recovery substituted for movement.")
	if not controls_before.is_empty():_check_contact(controls_before==_stock_settings(),"Stock controller/camera/spray settings preserved.")
	var final_study_state:Dictionary={} if study_root==null or not is_instance_valid(study_root) else _snapshot(study_root)
	if not frozen_study_state.is_empty():_check_contact(frozen_study_state==final_study_state,"All source/addition native arrays, materials, ordered shapes and metadata remain exact after changed light and mechanics.")
	var result:Dictionary={"activation_observations":activation_observations,"study_state_before":frozen_study_state,"study_state_after":final_study_state,"lighting":lighting_observation,"ok":contact_failures.is_empty(),"mode":probe_mode,"scope":"1229 finite affected door/path/footway routes and configured screen contact, component-wise walk/run return to source road over unchanged LAND; eligible wall/window/trim stock callbacks. Exact observed roof nonreceiver geometry and prior native routing retained; no roof callback/landing claim.","failures":contact_failures,"reached_scope":_reached_scope(),"carried_forward":_json(WORK+"/route-plan.json").get("carried_forward",{}),"world":world_info,"surface_before":surface_before,"surface_after":{} if source_world==null else _surface_state(),"captures":junction_captures,"route_attempts":route_attempts,"spray_attempts":spray_attempts,"motion":motion_data,"setup_placements":placements,"stock_settings_before":controls_before,"stock_settings_after":{} if contact_player==null else _stock_settings(),"samples":samples,"recoveries":source_recoveries,"controller_or_camera_source_changed":false,"source_terrain_changed":false,"recognition_credit":0}
	_write_json(_argument_value("--output="),result)
	print("Northpoint1229_STUDY_"+("PASS" if contact_failures.is_empty() else "HOLD")+" "+JSON.stringify(contact_failures))
	if fixture!=null:fixture.queue_free()
	await process_frame;quit(0 if contact_failures.is_empty() else 1)
func _on_timeout() -> void:
	if not _finished:_check_contact(false,"Source study exceeded300seconds.");_end_contact(source_main)

func _record_roots(key:String) -> Array[Node3D]:
	var found:Array[Node3D]=[]
	for node:Node in source_world.find_children("*","Node3D",true,false):
		if not node is MeshInstance3D and not node is CollisionObject3D and node.has_meta("feature_kind") and str(node.get_meta("derived_object_key",""))==key:found.append(node)
	return found


func _native_view(view:Dictionary,wall:Dictionary,save:bool) -> void:
	var baseline:bool=bool(view.get("baseline",false))
	study_root.visible=not baseline
	for body:CollisionObject3D in study_root.find_children("*","CollisionObject3D",true,false):body.collision_layer=0 if baseline else 5
	for original:Node3D in [wall_root,roof_root]:
		original.visible=baseline
		for body:CollisionObject3D in original.find_children("*","CollisionObject3D",true,false):body.collision_layer=5 if baseline else 0
	await physics_frame;await process_frame
	var sun:=source_main.get_node("Sun") as DirectionalLight3D;sun.rotation_degrees=view.sun
	var f:=PROTOTYPE._joined_frame(wall,int(view.run),int(view.run))
	var pose:=Vector3(view.xz.x,0.0,view.xz.y);var ground:=_support_ray(pose)
	_check_contact(not ground.is_empty(),str(view.id)+" actual-world support ray exists.")
	if ground.is_empty():return
	var support_identity:Dictionary=_collider_identity(ground.collider,int(ground.shape))
	var expected_player_land:String="land:w26767313:x_%d__z_%d" % [floori(pose.x/256.0),floori(pose.z/256.0)]
	var valid_support:bool=str(support_identity.derived_object_key)==expected_player_land and int(support_identity.shape_index)==0
	_check_contact(valid_support,"Broader anchor actually starts on unchanged land collision.")
	if not valid_support:return
	pose.y=ground.position.y+.1
	await _place(pose,f)
	var aim:=_aim_stock_player_camera(contact_player,view.target)
	_check_contact(bool(aim.get("ok",false)),str(view.id)+" stock camera aim.")
	contact_player.set_gameplay_enabled(false)
	var final_aim_physics_start:int=Engine.get_physics_frames()
	var final_aim_player_position:Vector3=contact_player.global_position
	# Let the unchanged PlayerCamera and SpringArm execute after the FINAL aim.
	for i in 6:
		await physics_frame;await process_frame
	for i in 3:
		_clean_hud(source_main.get_node("Interface/HUD") as GameHUD)
		await process_frame;await RenderingServer.frame_post_draw
	var camera:=contact_player.get_camera();var target:Vector3=view.target;var projected:=camera.unproject_position(target)
	var final_camera:Dictionary=_final_camera_ground_state()
	final_camera["physics_start"]=final_aim_physics_start
	final_camera["physics_end"]=Engine.get_physics_frames()
	final_camera["explicit_physics_waits"]=6
	final_camera["player_position_before"]= _vector3(final_aim_player_position)
	final_camera["player_position_unchanged"]=contact_player.global_position==final_aim_player_position
	_check_contact(bool(final_camera.player_position_unchanged),str(view.id)+" player unchanged during final camera settle.")
	_check_contact(bool(final_camera.segment_clear),str(view.id)+" final stock pivot-to-camera segment clear.")
	_check_contact(bool(final_camera.land_identity_ok),str(view.id)+" final camera vertical ray identifies unchanged LAND shape0.")
	_check_contact(bool(final_camera.camera_above_land),str(view.id)+" final camera is above unchanged colliding LAND.")
	_check_contact(absf(camera.fov-70.0)<.001,"Unchanged stock70degree camera.")
	var settled:Dictionary=_endpoint(f)
	var landed_on_source:bool=false
	for hit:Dictionary in settled.upward_slide_contacts:
		if str(hit.derived_object_key)==expected_player_land and int(hit.shape_index)==0:landed_on_source=true
	_check_contact(landed_on_source,"Actual settled upward slide support belongs to unchanged land.")
	_check_contact(contact_player.is_on_floor() and not camera.is_position_behind(target) and Rect2(Vector2.ZERO,Vector2(STILL_SIZE)).has_point(projected),str(view.id)+" grounded ordinary view contains target.")
	var framing:=_framing_metadata(camera,[wall_root,roof_root] if baseline else [study_root])
	var ground_framing:=_framing_metadata(camera,[] if baseline else [study_root],true)
	var public_framing:Dictionary={}
	if bool(view.public_front):
		public_framing=_public_front_framing(camera,wall)
		_check_contact(_framing_is_valid(public_framing),str(view.id)+" approved exact target002 observed/protected partition and actual facade framing.")
	var junction_framing:Dictionary={}
	if bool(view.get("junction",false)):
		junction_framing=_junction_framing(camera,view)
		_check_contact(_framing_is_valid(junction_framing),str(view.id)+" actual emitted entry-to-footway-to-parking-to-source-road region fully framed.")
	var visibility_endpoint:Vector3=target+(target-camera.global_position).normalized()*.02
	var los:Dictionary=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.global_position,visibility_endpoint,1,[contact_player.get_rid()]))
	var los_value:Dictionary=_ray_value(los)
	var target_visible:bool=not los.is_empty() and str(los_value.get("derived_object_key","")) in [WALL_KEY,ROOF_KEY,"prototype:"+WALL_KEY,"prototype:"+ROOF_KEY]
	_check_contact(target_visible,str(view.id)+" actual first solid toward unchanged surface target belongs to this building.")
	var row:Dictionary={"id":view.id,"baseline_exact_source":baseline,"requested_xz":[view.xz.x,view.xz.y],"aim_target":_vector3(target),"sun":_vector3(sun.rotation_degrees),"player":_endpoint(f),"camera":_vector3(camera.global_position),"camera_forward":_vector3(-camera.global_basis.z),"camera_fov":camera.fov,"final_camera":final_camera,"framing":framing,"public_front_framing":public_framing,"ground_framing":ground_framing,"junction_framing":junction_framing,"visibility_ray_endpoint":_vector3(visibility_endpoint),"visibility_extension_m":.02,"target_first_solid_visible":target_visible,"first_world_solid_los":_ray_value(los),"source_world_land_and_area_intact":surface_before==_surface_state()}
	if save:
		var image:=root.get_texture().get_image();var path:=OUTPUT.path_join("images/"+str(view.id)+".png")
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		_check_contact(image!=null and not image.is_empty() and image.get_size()==STILL_SIZE,str(view.id)+" original native dimensions.")
		if image!=null and not image.is_empty():
			var sample:=_sample_image(image);_check_contact(int(sample.unique_colors)>=8 and float(sample.luminance_range)>=.1,"Nonblank native image.")
			var saved:bool=image.save_png(path)==OK
			_check_contact(saved,"Save original native image.");row["saved_success"]=saved;row["path"]=path;row["sha256"]=FileAccess.get_sha256(path) if saved else "";row["sample"]=sample
		print("Northpoint1229_STUDY_IMAGE "+path)
	junction_captures.append(row)


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
	var clearance:Variant=null
	var above:bool=false
	if not land.is_empty():
		clearance=camera.global_position.y-float(land.position.y)
		above=float(clearance)>=0.0
		land_value["face_index"]=int(land.get("face_index",-1))
	return {"pivot":_vector3(pivot.global_position),"camera":_vector3(camera.global_position),"camera_near":camera.near,"arm_length":arm.spring_length,"arm_hit_length":arm.get_hit_length(),"arm_margin":arm.margin,"arm_collision_mask":arm.collision_mask,"pivot_to_camera_length_m":length_m,"segment_hit":_ray_value(hit),"segment_hit_distance_m":hit_distance,"segment_endpoint_allowance_m":.04,"segment_clear":segment_clear,"land_ray":land_value,"query_from":_vector3(query_from),"query_to":_vector3(query_to),"expected_camera_land":expected_land,"land_identity_ok":land_ok,"camera_minus_land_y_m":clearance,"camera_above_land":above,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames()}


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


func _framing_metadata(camera: Camera3D, nodes: Array, ground_only:bool=false) -> Dictionary:
	var points: Array[Vector3] = [];var mesh_labels:Array[String]=[]
	for node_value: Variant in nodes:
		var node := node_value as Node3D
		for child_value: Variant in node.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance := child_value as MeshInstance3D
			if mesh_instance == null or mesh_instance.mesh == null or not mesh_instance.is_visible_in_tree():
				continue
			var is_ground:bool=str(mesh_instance.name) in GROUND_MESH_NAMES
			if is_ground!=ground_only:continue
			mesh_labels.append(str(mesh_instance.name))
			var bounds := mesh_instance.get_aabb()
			for x_index in 2:
				for y_index in 2:
					for z_index in 2:
						points.append(mesh_instance.global_transform * (bounds.position + Vector3(bounds.size.x * x_index, bounds.size.y * y_index, bounds.size.z * z_index)))
	if points.is_empty():
		return {"ok": false,"scope":"ground_only" if ground_only else "facade_with_render_only_window_register","mesh_labels":mesh_labels}
	var minimum := Vector2(INF, INF)
	var maximum := Vector2(-INF, -INF)
	var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point):
			behind += 1
			continue
		var screen := camera.unproject_position(point)
		minimum = minimum.min(screen)
		maximum = maximum.max(screen)
	var size := maximum - minimum
	return {"ok": behind < points.size(), "scope":"ground_only" if ground_only else "facade_with_render_only_window_register","mesh_labels":mesh_labels, "metadata": {"target_bounds_point_count": points.size(), "target_bounds_points_behind_camera": behind, "target_projected_min_px": [minimum.x, minimum.y], "target_projected_max_px": [maximum.x, maximum.y], "target_projected_width_ratio": size.x / STILL_SIZE.x, "target_projected_height_ratio": size.y / STILL_SIZE.y, "target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= STILL_SIZE.x and maximum.y <= STILL_SIZE.y}}


func _framing_is_valid(result: Dictionary) -> bool:
	if not bool(result.get("ok", false)):
		return false
	var data := result.metadata as Dictionary
	return int(data.target_bounds_points_behind_camera) == 0 and bool(data.target_bounds_fully_in_frame) and float(data.target_projected_width_ratio) >= 0.12 and float(data.target_projected_height_ratio) >= 0.035 and float(data.target_projected_width_ratio) <= 0.96 and float(data.target_projected_height_ratio) <= 0.96


func _clean_hud(hud: GameHUD) -> void:
	paused = false
	hud.set_paused(false)
	hud.debug_panel.hide()
	hud.feedback_panel.hide()
	hud.load_panel.hide()
	hud.pause_panel.hide()
	hud.reticle.show()


func _hud_state(hud: GameHUD) -> Dictionary:
	return {"debug_panel_visible": hud.debug_panel.visible, "feedback_panel_visible": hud.feedback_panel.visible, "load_panel_visible": hud.load_panel.visible, "pause_panel_visible": hud.pause_panel.visible, "reticle_visible": hud.reticle.visible}


func _sample_image(image: Image) -> Dictionary:
	var colors := {}
	var minimum := 1.0
	var maximum := 0.0
	for sample_y in 20:
		var y := mini(image.get_height() - 1, int((float(sample_y) + 0.5) * image.get_height() / 20.0))
		for sample_x in 32:
			var x := mini(image.get_width() - 1, int((float(sample_x) + 0.5) * image.get_width() / 32.0))
			var color := image.get_pixel(x, y)
			colors[color.to_rgba32()] = true
			minimum = minf(minimum, color.get_luminance())
			maximum = maxf(maximum, color.get_luminance())
	return {"unique_colors": colors.size(), "luminance_range": maximum - minimum}


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
	_clear_gameplay_input()
	for action: String in actions:Input.action_press(action)
	if not stop_on_contact.is_empty():
		active_attempt["forward_termination"]={"mode":"first_verified_expected_contact","maximum_input_frames":frames,"sampled_input_frames":0,"termination_reason":"in_progress","trigger":{},"input_released":false}
	for i in frames:
		await physics_frame;await process_frame
		if _finished:return
		var camera:=contact_player.get_camera();var pivot:=contact_player.get_node("CameraPivot") as Node3D
		var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pivot.global_position,camera.global_position,1,[contact_player.get_rid()]))
		_check_contact(hit.is_empty() or pivot.global_position.distance_to(hit.position)>=pivot.global_position.distance_to(camera.global_position)-.04,"Stock camera segment stays clear during "+label)
		if not active_walk_label.is_empty():
			walk_trace.append({"input_frame":i+1,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"phase":active_walk_label,"actions":actions.duplicate(),"camera_state":_final_camera_ground_state(),"camera_pivot_rotation":_vector3(contact_player.camera_rig.rotation),"camera_arm_rotation":_vector3(contact_player.camera_rig.spring_arm.rotation),"input_strengths":_input_strengths(),"drawn_counter":Engine.get_frames_drawn(),"planar_forward":_vector3(contact_player.camera_rig.planar_forward()),"position":_vector3(contact_player.global_position),"velocity":_vector3(contact_player.velocity),"on_floor":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"slide_contacts":_walk_contacts()})
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
		var owner_ok:bool=str(hit.derived_object_key)==str(condition.expected_key) and int(hit.shape_index)==int(condition.expected_shape)
		var routing_ok:bool=false
		if str(condition.receiver_mode)=="original_wall":
			routing_ok=str(hit.collider_path)==str(study_root.get_node("OriginalWallRecord/Collision").get_path()) and bool(hit.spray_receiver_group) and str(hit.resolved_receiver_metadata.get("receiver_kind",""))=="building_wall"
		else:
			routing_ok=bool(hit.exact_structure_body) and str(hit.structural_role)==str(condition.expected_role) and str(hit.resolved_receiver_metadata.get("receiver_kind",""))=="none" and not bool(hit.spray_receiver_group)
		if owner_ok and routing_ok and PROTOTYPE._v(hit.normal).dot(PROTOTYPE._v(condition.source_normal))>.7:return hit
	return {}


func _check_contact(ok: bool,message: String) -> void:
	if not ok and message not in contact_failures:contact_failures.append(message)


func _trace_phase(actions: Array, frames: int, label: String,stop_on_contact: Dictionary={}) -> Array:
	_capture_activation(label+"_start")
	walk_trace = []
	active_walk_label = label
	await _drive(actions, frames, label,stop_on_contact)
	if _finished:return walk_trace.duplicate(true)
	if not active_attempt.is_empty():active_completed_phases[label]=walk_trace.duplicate(true)
	active_walk_label = ""
	_capture_activation(label+"_end")
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
			row.structural_role = str(shape_node.shape.get_meta("structural_role", ""))
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


func _surface_state() -> Dictionary:
	var state: Dictionary = {}
	for key: String in [LAND_KEY, AREA_KEY, ROAD_KEY, "land:w26767313:x_-1__z_-4", "area:r17241151:x_-1__z_-4", "roads:x_-1__z_-4"]:
		var nodes := _record_roots(key)
		if nodes.size() != 1: continue
		var node: Node3D = nodes[0]
		var mesh := node.get_node("Mesh") as MeshInstance3D
		var body := node.get_node_or_null("Collision") as StaticBody3D
		state[key] = {"path":str(node.get_path()),"instance_id":node.get_instance_id(),"transform":str(node.global_transform),"visible":node.is_visible_in_tree(),"mesh_instance_id":mesh.get_instance_id(),"mesh_rid":str(mesh.mesh.get_rid()),"mesh_transform":str(mesh.global_transform),"mesh_arrays_sha256":var_to_bytes(mesh.mesh.surface_get_arrays(0)).hex_encode().sha256_text(),"material_path":mesh.mesh.surface_get_material(0).resource_path,"body_path":"" if body == null else str(body.get_path()),"body_rid":"" if body == null else str(body.get_rid()),"collision_layer":0 if body == null else body.collision_layer,"shape_count":0 if body == null else body.get_child_count()}
		var shapes: Array = []
		if body != null:
			for shape_node: CollisionShape3D in body.get_children():
				var shape := shape_node.shape as ConcavePolygonShape3D
				shapes.append({"path":str(shape_node.get_path()),"transform":str(shape_node.global_transform),"disabled":shape_node.disabled,"faces_sha256":var_to_bytes(shape.get_faces()).hex_encode().sha256_text()})
		state[key]["collision_shapes"] = shapes
	return state

func _material_channels(material:Material) -> Dictionary:
	var state:Dictionary={"class":material.get_class()}
	for property:Dictionary in material.get_property_list():
		if (int(property.usage)&PROPERTY_USAGE_STORAGE)==0:continue
		var value:Variant=material.get(str(property.name))
		if value is Resource:state[str(property.name)]={"class":value.get_class(),"path":value.resource_path}
		else:state[str(property.name)]=value
	return state
func _source_channels(original_wall:MeshInstance3D,original_roof:MeshInstance3D,study:Node3D) -> Dictionary:
	var result:Dictionary={"ok":true,"meshes":{}}
	for label:String in ["ExactOriginalWallSurfaces","ExactSourceNeutralRoof"]:
		var original:MeshInstance3D=original_roof if label=="ExactSourceNeutralRoof" else original_wall
		var current:MeshInstance3D=study.get_node(NodePath(label)) as MeshInstance3D
		var surfaces:Array=[]
		var state_equal:bool=current.transform==original.transform and current.layers==original.layers and current.cast_shadow==original.cast_shadow and current.mesh.get_surface_count()==original.mesh.get_surface_count()
		result.ok=bool(result.ok) and state_equal
		for surface in original.mesh.get_surface_count():
			var expected:Array=original.mesh.surface_get_arrays(surface);var actual:Array=current.mesh.surface_get_arrays(surface);var channels:Dictionary={}
			for ch in Mesh.ARRAY_MAX:
				var equal:bool=var_to_bytes(actual[ch])==var_to_bytes(expected[ch])
				channels[str(ch)]={"equal":equal,"actual_count":0 if actual[ch]==null else actual[ch].size(),"original_count":0 if expected[ch]==null else expected[ch].size()}
				if not equal:channels[str(ch)]["difference"]=_channel_difference(actual[ch],expected[ch])
				result.ok=bool(result.ok) and equal
			var material_equal:bool=_material_channels(current.get_active_material(surface))==_material_channels(original.get_active_material(surface))
			result.ok=bool(result.ok) and material_equal and current.mesh.surface_get_name(surface)==original.mesh.surface_get_name(surface)
			surfaces.append({"surface":surface,"name":original.mesh.surface_get_name(surface),"channels":channels,"material_equal":material_equal})
		result.meshes[label]={"source_state_equal":state_equal,"surfaces":surfaces,"complete_original_material_partitions_preserved":true}
	return result

func _channel_components(values:Variant) -> Array[float]:
	var out:Array[float]=[]
	if values==null:return out
	for value:Variant in values:
		if value is Vector3:out.append_array([value.x,value.y,value.z])
		elif value is Vector2:out.append_array([value.x,value.y])
		elif value is Color:out.append_array([value.r,value.g,value.b,value.a])
		else:out.append(float(value))
	return out
func _channel_difference(actual:Variant,expected:Variant) -> Dictionary:
	var a:Array[float]=_channel_components(actual);var b:Array[float]=_channel_components(expected)
	var count:=0;var maximum:=0.0;var examples:Array=[]
	for i in mini(a.size(),b.size()):
		if a[i]==b[i]:continue
		count+=1;var delta:float=a[i]-b[i];maximum=maxf(maximum,absf(delta))
		if examples.size()<6:examples.append({"component":i,"actual":a[i],"expected":b[i],"delta":delta})
	return {"actual_components":a.size(),"expected_components":b.size(),"unequal_shared_components":count,"max_absolute_difference":maximum,"first_examples":examples}

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

func _public_front_framing(camera: Camera3D, wall: Dictionary) -> Dictionary:
	var points: Array[Vector3] = []
	for run: int in PROTOTYPE.TARGET_RUNS:
		for local in 4:
			var index := run * 4 + local
			points.append(PROTOTYPE._v(wall.vertices.slice(index * 3, index * 3 + 3)))
	var labels: Array[String] = []
	# Matched baseline/candidate envelope uses the same actual emitted geometry.
	for child: Node in study_root.get_children():
		if not child is MeshInstance3D or str(child.name) in ["ExactOriginalWallSurfaces", "ExactSourceNeutralRoof", "ParkingSurface"]: continue
		var mesh := child as MeshInstance3D
		for surface in mesh.mesh.get_surface_count():
			for vertex: Vector3 in mesh.mesh.surface_get_arrays(surface)[Mesh.ARRAY_VERTEX]:
				points.append(mesh.global_transform * vertex)
		labels.append(str(mesh.name))
	var minimum := Vector2(INF, INF); var maximum := Vector2(-INF, -INF); var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point): behind += 1; continue
		var screen := camera.unproject_position(point)
		minimum = minimum.min(screen); maximum = maximum.max(screen)
	var size := maximum - minimum
	return {"ok": behind < points.size(), "scope": "Bounded accepted public-front regions, shallow roof strips, target canopy segmentation, three inferred entries and local ground; hidden/cropped geometry unclaimed.", "source_runs": PROTOTYPE.TARGET_RUNS, "mesh_labels": labels, "metadata": {"target_bounds_point_count": points.size(), "target_bounds_points_behind_camera": behind, "target_projected_min_px": [minimum.x, minimum.y], "target_projected_max_px": [maximum.x, maximum.y], "target_projected_width_ratio": size.x / STILL_SIZE.x, "target_projected_height_ratio": size.y / STILL_SIZE.y, "target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= STILL_SIZE.x and maximum.y <= STILL_SIZE.y}}


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
	_capture_activation(str(spec.id)+"_before_setup")
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
	contact_player.set_gameplay_enabled(false)
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
	_capture_activation(str(spec.id)+"_after_setup")
	return bool(aim.ok) and grounded and valid_camera

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
		stop_condition={"expected_shape":spec.expected_shape,"expected_role":spec.expected_role,"expected_key":spec.expected_key,"receiver_mode":spec.receiver_mode,"source_normal":_vector3(f.normal)}
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
				ground_ok=ground_ok and str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0
				if str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0:observed_land=true
			if not _verified_obstruction_contact({"slide_contacts":[hit]},stop_condition).is_empty():
				obstruction_events+=1;observed_obstruction=true
		if observed_land:land_frames+=1
		if observed_obstruction:obstruction_rows+=1
		ground_ok=ground_ok and bool(row.on_floor) and bool(row.player_land_state.ok)
		var camera:Dictionary=row.camera_state
		camera_ok=camera_ok and bool(camera.segment_clear) and bool(camera.land_identity_ok) and bool(camera.camera_above_land) and row.camera_pivot_rotation==fixed_pivot and row.camera_arm_rotation==fixed_arm
		var station:float=(PROTOTYPE._v(row.position)-(f.start as Vector3)).dot(f.tangent)
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
	var ok:bool=bool(corridor.ok) and complete and ground_ok and camera_ok and land_frames>0 and obstruction_events>0 and progress>=float(spec.minimum_progress_m) and depth_ok and stopped and no_placement
	_check_contact(ok,str(spec.id)+" actual complete grounded stock input contacts the expected authored obstruction and naturally stops without source/camera penetration.")
	# Construct exactly one completed attempt from actual finished data; never merge into seeded evidence.
	var completed:Dictionary={"record_state":"complete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"forward_termination":forward_termination,"maximum_input_frames":spec.input_frames,"actual_approach_phase_rows":trace.size()+brake.size(),"corridor":corridor,"timing_usec":route_timing,"label":spec.id,"performed":true,"ok":ok,"signed_basis":basis,"initial":initial,"input_endpoint":input_endpoint,"endpoint":endpoint,"input_trace":trace,"brake_trace":brake,"sampled_input_frames":trace.size(),"sampled_brake_frames":brake.size(),"direct_land_contact_frames":land_frames,"direct_expected_obstruction_contact_events":obstruction_events,"direct_expected_obstruction_contact_rows":obstruction_rows,"expected_shape":spec.expected_shape,"expected_role":spec.expected_role,"all_grounded_on_original_land":ground_ok,"all_camera_checks":camera_ok,"station_held":station_ok,"station_diagnostic_limit_m":spec.maximum_station_drift_m,"station_diagnostic_only":true,"actual_maximum_station_drift_m":maximum_station_drift,"normal_progress_m":progress,"expected_stop_depth_interval_m":spec.expected_depth_interval_m,"actual_stop_depth_m":endpoint.depth_m,"stopped":stopped,"transform_writes_during_trace":placements.size()-placement_count,"process_range":[process_begin,Engine.get_process_frames()],"physics_range":[physics_begin,Engine.get_physics_frames()],"drawn_range":[draw_begin,Engine.get_frames_drawn()],"no_stair_or_traversal_between_setups_claim":true}
	active_attempt["finished_observation"]=completed.duplicate(true)
	contact_player.set_gameplay_enabled(false)
	active_attempt["step"]="held_marker"
	var route_marker_start_usec:=Time.get_ticks_usec()
	if not str(spec.marker).is_empty():await _save_marker(str(spec.marker),PROTOTYPE._v(spec.inspection_target),str(spec.expected_key),int(spec.expected_shape))
	if _finished:return
	route_timing["marker_call_usec"]=Time.get_ticks_usec()-route_marker_start_usec
	var retreat:Dictionary={"performed":false,"ok":false,"reason":"Approach or held marker failed; no retreat input performed."}
	if contact_failures.is_empty():
		active_attempt["finished_observation"]=completed.duplicate(true)
		active_attempt["step"]="retreat"
		retreat=await _retreat_attempt(spec,f,fixed_pivot,fixed_arm,placement_count)
		if _finished:return
	completed["retreat"]=retreat
	completed["ok"]=bool(completed.ok) and bool(retreat.ok) and contact_failures.is_empty()
	completed["process_range"][1]=Engine.get_process_frames();completed["physics_range"][1]=Engine.get_physics_frames();completed["drawn_range"][1]=Engine.get_frames_drawn()
	route_timing["attempt_total_wall_usec"]=Time.get_ticks_usec()-route_start_usec
	completed["timing_usec"]=route_timing.duplicate(true)
	route_attempts.append(completed)
	active_attempt={};active_completed_phases={}

func _corridor_rows(rows:Array,spec:Dictionary) -> Dictionary:
	var corridor:Dictionary=spec.source_corridor
	var minimum:=INF;var outside:Array=[]
	var start:Vector3=PROTOTYPE._v(corridor.construction_frame_start)
	var tangent:Vector3=PROTOTYPE._v(corridor.construction_tangent)
	for i in rows.size():
		var station:float=(PROTOTYPE._v(rows[i].position)-start).dot(tangent)
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
	var trace:Array=[]
	var segment_records:Array=[]
	for segment:Dictionary in spec.retreat.segments:
		var segment_trace:Array=await _trace_phase(segment.actions,int(segment.input_frames),str(spec.id)+"_retreat_segment_"+str(segment_records.size()+1))
		trace.append_array(segment_trace)
		segment_records.append({"actions":segment.actions,"expected_frames":segment.input_frames,"actual_frames":segment_trace.size()})
		if _finished:return {}
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
				ground_ok=ground_ok and str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0
				if str(hit.derived_object_key) in LAND_KEYS and int(hit.shape_index)==0:has_land=true;land_events+=1
		if has_land:land_rows+=1
		ground_ok=ground_ok and bool(row.on_floor) and bool(row.player_land_state.ok)
		var camera:Dictionary=row.camera_state
		camera_ok=camera_ok and bool(camera.segment_clear) and bool(camera.land_identity_ok) and bool(camera.camera_above_land) and row.camera_pivot_rotation==fixed_pivot and row.camera_arm_rotation==fixed_arm
	var corridor:Dictionary=_return_path_rows(trace+brake,spec)
	var progress:float=float(endpoint.depth_m)-float(initial.depth_m)
	var interval:Array=spec.retreat.depth_interval_m
	var destination:bool=progress>=float(spec.retreat.minimum_progress_m) and progress<=float(spec.retreat.maximum_progress_m) and float(endpoint.depth_m)>=float(interval[0]) and float(endpoint.depth_m)<=float(interval[1])
	var stopped:bool=contact_player.velocity.length()<.01
	var road_membership:Dictionary=_actual_road_membership(contact_player.global_position) if bool(spec.retreat.expected_road_membership) else {"required":false,"ok":true}
	var ok:bool=bool(road_membership.ok) and trace.size()==int(spec.retreat.input_frames) and brake.size()==int(spec.retreat.brake_frames) and ground_ok and camera_ok and bool(corridor.ok) and destination and stopped and placements.size()==placement_count
	_check_contact(ok,str(spec.id)+" complete stock retreat reaches the source-grounded corridor destination and naturally brakes with no transform writes.")
	contact_player.set_gameplay_enabled(false)
	return {"performed":true,"ok":ok,"actual_road_membership":road_membership,"initial":initial,"input_endpoint":input_endpoint,"endpoint":endpoint,"input_segments":segment_records,"input_trace":trace,"brake_trace":brake,"sampled_input_frames":trace.size(),"sampled_brake_frames":brake.size(),"direct_land_contact_rows":land_rows,"direct_land_contact_events":land_events,"all_grounded_on_original_land":ground_ok,"all_camera_checks":camera_ok,"corridor":corridor,"outward_progress_m":progress,"expected_progress_interval_m":[spec.retreat.minimum_progress_m,spec.retreat.maximum_progress_m],"destination_depth_interval_m":interval,"destination_ok":destination,"stopped":stopped,"transform_writes_during_route":placements.size()-placement_count,"timing_usec":{"input_wall_usec":input_usec,"brake_wall_usec":brake_usec,"total_wall_usec":Time.get_ticks_usec()-started}}

func _spray_case(spec:Dictionary,f:Dictionary) -> void:
	var attempt_start_usec:=Time.get_ticks_usec()
	active_attempt_start_usec=attempt_start_usec
	active_attempt={"kind":"spray","label":spec.id,"performed":false,"step":"setup"};active_completed_phases={}
	var timing:Dictionary={"clock":"Time.get_ticks_usec monotonic wall", "stock_call_usec":null,"post_call_observation_usec":null,"marker_call_usec":0}
	if not await _setup_grounded_pose(spec,f):
		if _finished:return
		spray_attempts.append({"record_state":"incomplete","setup_support_query":active_attempt.get("setup_support_query",{}).duplicate(true),"label":spec.id,"performed":false,"reason":"Source-grounded setup failed.","setup_land_state":active_attempt.get("setup_land_state",{}),"ok":false,"timing_usec":{"setup_failed_wall_usec":Time.get_ticks_usec()-attempt_start_usec,"stock_call_usec":null}});active_attempt={};active_completed_phases={};return
	timing["setup_and_settle_usec"]=Time.get_ticks_usec()-attempt_start_usec
	active_attempt["step"]="final_aim"
	var final_aim_start_usec:=Time.get_ticks_usec()
	var target:Vector3=PROTOTYPE._v(spec.target)
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
	if str(spec.expected_result)=="placed":exact=exact and str(identity.collider_path)==str(study_root.get_node("ProjectedUpperWallReceiver").get_path())
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
		ok=ok and identities==[{"derived_object_key":WALL_KEY,"source_keys":["w96665911"]}] and decal_state.derived_object_key==WALL_KEY and decal_state.source_keys==["w96665911"] and decal.cull_mask==2
	else:ok=ok and identities.is_empty()
	if str(spec.expected_result)=="placed" and after>before:
		var placed_decal:Decal=spray.tag_instances.get_child(spray.tag_instances.get_child_count()-1) as Decal
		decal_state["full_footprint"]=_decal_full_footprint(placed_decal,hit.position)
		ok=ok and bool(decal_state.full_footprint.ok)
	_check_contact(ok,str(spec.id)+" performed stock spray emits exact result/identity/count and full clear projected footprint.")
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
	completed["ok"]=bool(completed.ok) and contact_failures.is_empty()
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
	var exact:bool=not los.is_empty() and str(los_value.derived_object_key)==expected_key and int(los_value.shape_index)==expected_shape
	_check_contact(in_frame and exact,label+" saved marker contains the exact first-solid intended target.")
	var marker_footprint:Dictionary={}
	if expected_key==WALL_KEY:
		var tag_pool:Node=contact_player.get_spray_controller().tag_instances
		if tag_pool.get_child_count()>0 and not los.is_empty():marker_footprint=_decal_full_footprint(tag_pool.get_child(tag_pool.get_child_count()-1) as Decal,los.position)
		_check_contact(bool(marker_footprint.get("ok",false)),label+" whole projected tag remains clear and framed at the saved camera.")
	var readback_start_usec:=Time.get_ticks_usec()
	var image:Image=root.get_texture().get_image();var path:=OUTPUT+"/images/"+label+".png"
	var readback_end_usec:=Time.get_ticks_usec()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var png_start_usec:=Time.get_ticks_usec()
	var saved:bool=image!=null and not image.is_empty() and image.get_size()==STILL_SIZE and image.save_png(path)==OK
	var png_end_usec:=Time.get_ticks_usec()
	_check_contact(saved,label+" actual original post-draw framebuffer saved.")
	junction_captures.append({"timing_usec":{"post_draw_wait_usec":marker_wait_end_usec-marker_start_usec,"camera_target_checks_usec":readback_start_usec-marker_wait_end_usec,"framebuffer_readback_usec":readback_end_usec-readback_start_usec,"png_validate_and_write_usec":png_end_usec-png_start_usec,"marker_wall_before_record_usec":Time.get_ticks_usec()-marker_start_usec},"id":label,"path":path,"sha256":FileAccess.get_sha256(path) if saved else "","saved_success":saved,"image_dimensions":[] if not saved else [image.get_width(),image.get_height()],"player":_vector3(contact_player.global_position),"velocity":_vector3(contact_player.velocity),"on_floor":contact_player.is_on_floor(),"player_land_state":_player_land_state(),"slide_contacts":_walk_contacts(),"camera":_vector3(camera.global_position),"camera_forward":_vector3(-camera.global_basis.z),"camera_fov":camera.fov,"final_camera":final_camera,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"drawn_counter":Engine.get_frames_drawn(),"full_tag_footprint":marker_footprint,"inspection_target":_vector3(target),"projected_target_px":[projected.x,projected.y],"inspection_target_in_frame":in_frame,"first_world_solid_los":los_value,"expected_target_key":expected_key,"expected_target_shape":expected_shape,"pixel_scope":"Actual completed post-draw framebuffer; not asserted equal to a physics trace sample."})
	print("Northpoint1229_MECHANICS_IMAGE "+path)

func _input_strengths() -> Dictionary:
	var values:Dictionary={}
	for action:String in ["move_forward","move_back","move_left","move_right","run","jetpack"]:values[action]=Input.get_action_strength(action)
	return values


func _reached_scope() -> Dictionary:
	var plan := _json(WORK+"/route-plan.json")
	var summary: Dictionary = {"saved_capture_ids":[], "route_attempts":[], "spray_attempts":[], "unreached_route_ids":[], "unreached_spray_ids":[]}
	for capture: Dictionary in junction_captures:
		if bool(capture.get("saved_success",false)) and not str(capture.get("sha256","")).is_empty(): summary.saved_capture_ids.append(str(capture.id))
	for group: Array in [[route_attempts,"route_attempts","routes","unreached_route_ids"],[spray_attempts,"spray_attempts","sprays","unreached_spray_ids"]]:
		var reached: Array[String] = []
		for attempt: Dictionary in group[0]:
			reached.append(str(attempt.label))
			summary[group[1]].append({"id":str(attempt.label),"record_state":str(attempt.get("record_state","incomplete")),"performed":bool(attempt.get("performed",false)),"ok":bool(attempt.get("ok",false))})
		for planned: Dictionary in plan.get(group[2],[]):
			if not str(planned.id) in reached: summary[group[3]].append(str(planned.id))
	return summary

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

func _junction_framing(camera: Camera3D, view: Dictionary) -> Dictionary:
	var config := _json(CONFIG_PATH); var frame: Dictionary = config.target.frames[1]
	var origin := PROTOTYPE._v(frame.start); var tangent := PROTOTYPE._v(frame.tangent); var normal := PROTOTYPE._v(frame.normal)
	var top: float = float(frame.entries[0].bottom_y) + float(frame.entries[0].height_m) + .15
	var points: Array[Vector3] = []; var labels: Array[String] = []
	for label: String in ["MaroonClosedDoors", "PaleCompleteTrim", "DrapedEntryPaths", "FootwaySurface", "ParkingSurface", "ExactSourceRoad"]:
		var vertices: Array[Vector3] = []; var indices: Array[int] = []
		if label == "ExactSourceRoad":
			for tile:String in ["x_-2__z_-3"]:
				var record:Dictionary=PROTOTYPE._record(_json("res://generated/world/chunks/"+tile+".json").records,"roads:"+tile)
				var offset:int=vertices.size()
				for i in int(record.vertices.size()/3): vertices.append(PROTOTYPE._v(record.vertices.slice(i*3,i*3+3)))
				for value:Variant in record.indices: indices.append(offset+int(value))
		else:
			var mesh := study_root.get_node(NodePath(label)) as MeshInstance3D
			var arrays := mesh.mesh.surface_get_arrays(0)
			for vertex: Vector3 in arrays[Mesh.ARRAY_VERTEX]: vertices.append(mesh.global_transform * vertex)
			for value: int in arrays[Mesh.ARRAY_INDEX]: indices.append(value)
		var initial := points.size()
		for i in range(0, indices.size(), 3):
			var polygon: Array[Vector3] = [vertices[indices[i]], vertices[indices[i+1]], vertices[indices[i+2]]]
			polygon = _clip_junction(polygon, origin, tangent, float(view.junction_station_min), true)
			polygon = _clip_junction(polygon, origin, tangent, float(view.junction_station_max), false)
			polygon = _clip_junction(polygon, origin, normal, float(view.junction_depth_min), true)
			polygon = _clip_junction(polygon, origin, normal, float(view.junction_depth_max), false)
			polygon = _clip_junction(polygon, Vector3.ZERO, Vector3.UP, top, false)
			if polygon.size() >= 3: points.append_array(polygon)
		if points.size() > initial: labels.append(label)
	var minimum := Vector2(INF, INF); var maximum := Vector2(-INF, -INF); var behind := 0
	for point: Vector3 in points:
		if camera.is_position_behind(point): behind += 1; continue
		var screen := camera.unproject_position(point); minimum = minimum.min(screen); maximum = maximum.max(screen)
	var size := maximum - minimum
	return {"ok":labels.size()==6 and not points.is_empty(), "scope":"Actual near-2 first complete door/trim and its approach, continuous footway, parking and original-road junction in the explicit 2.2m station strip. Outer contextual parking ends remain cropped.", "station_interval_m":[view.junction_station_min,view.junction_station_max], "depth_interval_m":[view.junction_depth_min,view.junction_depth_max], "height_max_m":top, "mesh_labels":labels, "metadata":{"target_bounds_point_count":points.size(),"target_bounds_points_behind_camera":behind,"target_projected_min_px":[minimum.x,minimum.y],"target_projected_max_px":[maximum.x,maximum.y],"target_projected_width_ratio":size.x/STILL_SIZE.x,"target_projected_height_ratio":size.y/STILL_SIZE.y,"target_bounds_fully_in_frame":minimum.x>=0.0 and minimum.y>=0.0 and maximum.x<=STILL_SIZE.x and maximum.y<=STILL_SIZE.y}}

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



func _check_physical_reference() -> void:
	var reference:Dictionary=_json("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/focused-1229-001-result.json")
	var checked:int=0
	var body:StaticBody3D=study_root.get_node("PhysicalDetails_NoSprayReceiver") as StaticBody3D
	_check_contact(body.collision_layer==5 and body.collision_mask==0 and not body.is_in_group("spray_receiver_wall") and str(body.get_meta("receiver_kind",""))=="none","Target detail shapes remain nonreceivers.")
	for shape_node:CollisionShape3D in body.get_children():
		var label:String=str(shape_node.shape.get_meta("structural_role",""))
		var faces:PackedVector3Array=(shape_node.shape as ConcavePolygonShape3D).get_faces()
		_check_contact(reference.detail_collision.has(label) and var_to_bytes(faces).hex_encode().sha256_text()==str(reference.detail_collision.get(label,{}).get("faces_sha256","")),"Actual target002 ordered physical faces: "+label)
		checked+=1
	var receiver:StaticBody3D=study_root.get_node("ProjectedUpperWallReceiver") as StaticBody3D
	var projected:CollisionShape3D=receiver.get_node("ProjectedUpperSiding") as CollisionShape3D
	var projected_faces:PackedVector3Array=(projected.shape as ConcavePolygonShape3D).get_faces()
	_check_contact(receiver.collision_layer==5 and receiver.collision_mask==0 and receiver.is_in_group("spray_receiver_wall") and str(receiver.get_meta("receiver_kind",""))=="building_wall" and bool(receiver.get_meta("opaque",false)),"Projected front retains exact eligible receiver routing.")
	_check_contact(var_to_bytes(projected_faces).hex_encode().sha256_text()==str(reference.detail_collision.ProjectedUpperWallReceiver.faces_sha256),"Projected front collision is exact accepted visible plane.")
	_check_contact(checked==9,"All 9 nonreceiver details plus separate projected receiver compared; original wall/roof remain separate source comparisons.")

# Actual native collision, sampled at each completed physics row. This records
# geometric support separately from on_floor and explicit slide-contact events.

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

func _player_land_state() -> Dictionary:
	var shape_node:CollisionShape3D=contact_player.collision_shape
	var capsule:CapsuleShape3D=shape_node.shape as CapsuleShape3D
	if capsule==null or native_land_triangles.is_empty():return {"ok":false,"reason":"Actual capsule or bound LAND faces unavailable."}
	var transform:Transform3D=shape_node.global_transform
	var scale:Vector3=transform.basis.get_scale();var axis:Vector3=transform.basis.y.normalized()
	var actual_stock_shape:bool=scale.is_equal_approx(Vector3.ONE) and axis.is_equal_approx(Vector3.UP) and is_equal_approx(capsule.radius,.35) and is_equal_approx(capsule.height,1.8)
	var low:Vector3=transform*Vector3(0.0,-capsule.height/2.0+capsule.radius,0.0)
	var high:Vector3=transform*Vector3(0.0,capsule.height/2.0-capsule.radius,0.0)
	var foot:Vector3=transform*Vector3(0.0,-capsule.height/2.0,0.0)
	var minimum:float=INF;var nearest:int=-1;var foot_heights:Array=[];var maximum_slope:float=0.0
	for i in native_land_triangles.size():
		var tri:Array=native_land_triangles[i];var a:Vector3=tri[0];var b:Vector3=tri[1];var c:Vector3=tri[2]
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
	var ok:bool=actual_stock_shape and absf(minimum)<=tolerance and delta>=-tolerance and delta<=max_foot_gap and foot.distance_to(contact_player.global_position)<.0001
	return {"ok":ok,"source_keys":LAND_KEYS,"shape_index":0,"foot":_vector3(foot),"player_origin":_vector3(contact_player.global_position),"capsule_axis":[_vector3(low),_vector3(high)],"capsule_radius_m":capsule.radius,"capsule_height_m":capsule.height,"actual_stock_transform":actual_stock_shape,"nearest_land_triangle":nearest,"capsule_land_clearance_m":minimum,"foot_land_y":land_y,"foot_minus_land_m":delta,"foot_source_triangles":foot_heights,"safe_margin_m":contact_player.safe_margin,"solver_qualification_m":tolerance,"slope_derived_maximum_foot_gap_m":max_foot_gap,"scope":"Actual sampled native capsule-to-LAND triangle distance. Negative means geometric overlap;2mm or4x safe-margin bounds solver-scale qualification. Independent of on_floor, empty contacts are retained; no continuous swept-volume proof."}

func _route_frame(spec:Dictionary) -> Dictionary:
	var f:Dictionary=spec.frame
	return {"start":PROTOTYPE._v(f.start),"tangent":PROTOTYPE._v(f.tangent),"normal":PROTOTYPE._v(f.normal)}

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
					if mesh.name=="ProjectedUpperSiding" and absf((midpoint-centre).dot(normal))<.001:skin_area+=box_area
				polygon=triangle.duplicate()
				for plane:Dictionary in planes:polygon=_clip_junction(polygon,plane.origin,plane.axis,plane.limit,true)
				var cone_area:float=_footprint_polygon_area(polygon)
				if cone_area>0.000000001:cone_obstacles.append({"path":str(mesh.get_path()),"surface":surface,"triangle":j/3,"clipped_area_m2":cone_area})
	var size_ok:bool=decal.size.is_equal_approx(Vector3(1.2,.08,.65)) and up.dot(Vector3.UP)>.99999 and absf(normal.y)<.00001 and centre.distance_to(hit_position)<.001
	var skin_ok:bool=absf(skin_area-decal.size.x*decal.size.z)<.0001
	return {"ok":size_ok and skin_ok and framed and box_obstacles.is_empty() and cone_obstacles.is_empty() and unsupported.is_empty(),"size_ok":size_ok,"mapped_front_skin_coverage_ok":skin_ok,"mapped_front_skin_area_m2":skin_area,"whole_rectangle_framed":framed,"centre":_vector3(centre),"actual_hit":_vector3(hit_position),"origin":_vector3(decal.global_position),"basis_x":_vector3(right),"basis_y":_vector3(normal),"basis_z":_vector3(up),"size":_vector3(decal.size),"normal_depth_from_hit_m":[depth_low,depth_high],"corners":corners.map(func(p:Vector3):return _vector3(p)),"pixel_corners":pixels,"camera":_vector3(camera.global_position),"box_nonreceiver_intersections":box_obstacles,"box_receiver_intersections":box_receiver_hits,"camera_cone_intersections":cone_obstacles,"unsupported_surfaces":unsupported,"inspected_meshes":inspected,"triangles_tested":triangle_count,"scope":"Actual complete triangle/box and camera-cone clipping at this camera, including visible source-world geometry and stock avatar. Cone stops 1 mm before the coincident projected front plane; <=1e-9m2 is numerical zero. Full projected front area tolerance.0001m2, hit-origin1mm. This finite geometry result does not replace independent inspection of the whole unchanged SVG in the original PNG."}

func _actual_road_membership(foot:Vector3) -> Dictionary:
	var hits:Array=[]
	for land_key:String in LAND_KEYS:
		var road_key:String="roads:"+land_key.get_slice(":",2)
		for node:Node3D in _record_roots(road_key):
			var mesh:MeshInstance3D=node.get_node("Mesh") as MeshInstance3D
			for surface in mesh.mesh.get_surface_count():
				var arrays:Array=mesh.mesh.surface_get_arrays(surface)
				var vertices:PackedVector3Array=arrays[Mesh.ARRAY_VERTEX];var indices:PackedInt32Array=arrays[Mesh.ARRAY_INDEX]
				for i in range(0,indices.size(),3):
					var a:Vector3=mesh.global_transform*vertices[indices[i]];var b:Vector3=mesh.global_transform*vertices[indices[i+1]];var c:Vector3=mesh.global_transform*vertices[indices[i+2]]
					var den:float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
					if absf(den)<1e-12:continue
					var u:float=((b.z-c.z)*(foot.x-c.x)+(c.x-b.x)*(foot.z-c.z))/den
					var v:float=((c.z-a.z)*(foot.x-c.x)+(a.x-c.x)*(foot.z-c.z))/den
					if minf(u,minf(v,1-u-v))>=-1e-7:hits.append({"source_road_key":road_key,"surface":surface,"triangle":i/3,"barycentric":[u,v,1-u-v],"overlay_y":u*a.y+v*b.y+(1-u-v)*c.y})
	return {"required":true,"ok":not hits.is_empty(),"foot":_vector3(foot),"hits":hits,"support_scope":"Actual source road overlay membership; unchanged LAND remains physical support and its actual contact is checked separately."}

func _return_path_rows(rows:Array,spec:Dictionary) -> Dictionary:
	var path:Array=spec.retreat.planned_path_xz
	var corridor:Dictionary=spec.source_corridor
	var minimum:=INF;var outside:Array=[]
	for i in rows.size():
		var p3:Vector3=PROTOTYPE._v(rows[i].position)
		var p:=Vector2(p3.x,p3.z);var distance:=INF
		for j in range(path.size()-1):
			var a:=Vector2(float(path[j][0]),float(path[j][1]));var b:=Vector2(float(path[j+1][0]),float(path[j+1][1]))
			var ab:Vector2=b-a;var fraction:float=clampf((p-a).dot(ab)/maxf(ab.length_squared(),1e-12),0.0,1.0)
			distance=minf(distance,p.distance_to(a+fraction*ab))
		var clearance:float=float(corridor.half_width_m)-distance-float(corridor.capsule_radius_m)
		minimum=minf(minimum,clearance)
		if clearance<0.0:outside.append({"row":i+1,"physics_counter":rows[i].physics_counter,"clearance_m":clearance})
	return {"ok":not rows.is_empty() and outside.is_empty(),"minimum_capsule_side_clearance_m":minimum,"outside_rows":outside,"half_width_m":corridor.half_width_m,"capsule_radius_m":corridor.capsule_radius_m,"planned_path_xz":path,"scope":spec.retreat.path_scope}

# Synchronous observations only; no activation writes, added waits or mid-route resume.
func _activation_state() -> Dictionary:
	var body:RID=contact_player.get_rid()
	var space:RID=PhysicsServer3D.body_get_space(body)
	var world_space:RID=contact_player.get_world_3d().space
	return {"tree_paused":paused,"player_process_mode":contact_player.process_mode,"main_process_mode":source_main.process_mode,"player_can_process":contact_player.can_process(),"player_physics_processing":contact_player.is_physics_processing(),"player_gameplay_enabled":contact_player._gameplay_enabled,"main_world_ready":source_main._world_ready,"body_space_rid":str(space),"world_space_rid":str(world_space),"body_space_matches_world":space==world_space,"space_active":PhysicsServer3D.space_is_active(space) if space.is_valid() else false,"global_server_active":"Not exposed by this observation; space_active is a distinct flag.","physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"drawn_counter":Engine.get_frames_drawn(),"inside_physics_frame":Engine.is_in_physics_frame()}

func _capture_activation(boundary:String) -> Dictionary:
	var state:Dictionary=_activation_state()
	var server:Transform3D=PhysicsServer3D.body_get_state(contact_player.get_rid(),PhysicsServer3D.BODY_STATE_TRANSFORM)
	var node:Transform3D=contact_player.global_transform
	var record:Dictionary={"boundary":boundary,"activation":state,"body_rid":str(contact_player.get_rid()),"node_transform":str(node),"server_transform":str(server),"native_node_server_equal":node==server,"placements_count":placements.size()}
	activation_observations.append(record)
	return record
