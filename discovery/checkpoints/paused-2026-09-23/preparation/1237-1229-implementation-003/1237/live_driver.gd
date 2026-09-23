extends SceneTree
# Source/main startup, actual terrain, stock camera/input, original PNG saves,
# contacts and native teardown reuse the complete1308 live-driver dependencies.
const PROTOTYPE := preload("res://game/scripts/world/facades/northpoint_1237_study.gd")
const WORK := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/northern-canopy-free-family-pilot-001/1237-1229-implementation-003/1237"
const OUTPUT := "/private/tmp/1237-1229-study-001/1237"
const CONFIG_PATH := "res://game/resources/facades/northpoint_1237_study.json"
const CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-4.json"
const WALL_KEY := "building:w96665904:wall"
const ROOF_KEY := "building:w96665904:roof"
const LAND_KEY := "land:w26767313:x_-1__z_-4"
const AREA_KEY := "area:r17241151:x_-1__z_-4"
const ROAD_KEY := "roads:x_-1__z_-4"
const GROUND_MESH_NAMES := ["DrapedEntryPaths", "FootwaySurface"]
const STILL_SIZE := Vector2i(1440,900)
const DEFAULT_SUN := Vector3(-52,-28,0)
const CHANGED_SUN := Vector3(-26,126,0)
const VIEWS := [
	{"id":"01-whole-front-baseline","xz":Vector2(-186.56634720400905,-847.5692674051787),"target":Vector3(-167.94976148166816,7.246,-862.6823323346778),"run":7,"public_front":true,"baseline":true,"sun":Vector3(-52,-28,0)},
	{"id":"02-whole-front-candidate","xz":Vector2(-186.56634720400905,-847.5692674051787),"target":Vector3(-167.94976148166816,7.246,-862.6823323346778),"run":7,"public_front":true,"baseline":false,"sun":Vector3(-52,-28,0)},
	{"id":"03-roof-entry-candidate","xz":Vector2(-178.80257272559328,-853.871949837945),"target":Vector3(-167.94976148166816,7.246,-862.6823323346778),"run":7,"public_front":false,"baseline":false,"sun":Vector3(-26,126,0)},
	{"id":"04-door-path-footway-junction","xz":Vector2(-175.57995595218657,-861.0086460971548),"target":Vector3(-171.8680680573687,4.107727666602257,-867.4996706326008),"run":5,"public_front":false,"baseline":false,"sun":Vector3(-52,-28,0),"junction":true,"junction_station_min":2.05,"junction_station_max":4.25,"junction_depth_min":-0.05,"junction_depth_max":4.4}
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

func _initialize() -> void:
	create_timer(300.0,true,false,true).timeout.connect(_on_timeout)
	call_deferred("_run")
func _run() -> void:
	probe_mode=_argument_value("--probe-mode=")
	_check_contact(probe_mode=="stills","This first study plan is stills-only; no movement run is scheduled.")
	if probe_mode=="stills":_check_contact(DisplayServer.get_name().to_lower()=="macos","Native macOS capture required.")
	var pins:=_json(WORK+"/../source-pins.json")
	for path:String in pins:_check_contact(FileAccess.get_sha256(path)==str(pins[path]),"Frozen source "+path)
	root.size=STILL_SIZE
	if not contact_failures.is_empty():await _end_contact(null);return
	if not await _load_current_world():await _end_contact(source_main);return
	var wall:=PROTOTYPE._record(_json(CHUNK_PATH).records,WALL_KEY)
	if probe_mode=="stills":
		# Full world/source construction is fatal; post-load framing/support
		# diagnostics retain HOLD but do not discard subsequent planned originals.
		for view:Dictionary in VIEWS:await _native_view(view,wall,true)
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
	_check_contact(bool(built.get("ok",false)),"1237 Northpoint source study construction: "+str(built.get("message","")))
	if not bool(built.get("ok",false)):return false
	study_root=built.node as Node3D;study_root.name="CaptureOnlyNorthpoint1237Study"
	var channel_report:Dictionary=_source_channels(wall_root.get_node("Mesh") as MeshInstance3D,roof_root.get_node("Mesh") as MeshInstance3D,study_root)
	world_info["source_channel_comparison"]=channel_report
	_check_contact(bool(channel_report.ok),"Actual original live-world channels including tangent values and protected material/state are preserved.")
	if not bool(channel_report.ok):study_root.free();return false
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
	if source_world!=null and not surface_before.is_empty():_check_contact(surface_before==_surface_state(),"Exact actual land and area survive all phases.")
	_check_contact(source_recoveries.is_empty(),"No recovery substituted for movement.")
	var result:Dictionary={"ok":contact_failures.is_empty(),"mode":probe_mode,"scope":"1237 Northpoint first coherent study001 in frozen capture-time32 world; temporary target swap, no authority/recognition or package claim.","failures":contact_failures,"world":world_info,"surface_before":surface_before,"surface_after":{} if source_world==null else _surface_state(),"captures":junction_captures,"stair_walk_attempts":walk_attempts,"samples":samples,"recoveries":source_recoveries,"controller_or_camera_source_changed":false,"source_terrain_changed":false,"recognition_credit":0}
	_write_json(_argument_value("--output="),result)
	print("Northpoint1237_STUDY_"+("PASS" if contact_failures.is_empty() else "HOLD")+" "+JSON.stringify(contact_failures))
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
		_check_contact(_framing_is_valid(public_framing),str(view.id)+" accepted target front-only scope and actual added facade framing.")
	var junction_framing:Dictionary={}
	if bool(view.get("junction",false)):
		junction_framing=_junction_framing(camera,view)
		_check_contact(_framing_is_valid(junction_framing),str(view.id)+" actual emitted door-to-entry-path-to-footway region fully framed.")
	var visibility_endpoint:Vector3=target+(target-camera.global_position).normalized()*.02
	var los:Dictionary=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.global_position,visibility_endpoint,1,[contact_player.get_rid()]))
	var los_value:Dictionary=_ray_value(los)
	var target_visible:bool=not los.is_empty() and str(los_value.get("derived_object_key","")) in [WALL_KEY,ROOF_KEY,"prototype:"+WALL_KEY,"prototype:"+ROOF_KEY]
	_check_contact(target_visible,str(view.id)+" actual first solid toward unchanged surface target belongs to this building.")
	var projected_routing: Dictionary = {}
	if not baseline and bool(view.public_front):
		projected_routing = _projected_front_routing()
	var row:Dictionary={"id":view.id,"baseline_exact_source":baseline,"requested_xz":[view.xz.x,view.xz.y],"aim_target":_vector3(target),"sun":_vector3(sun.rotation_degrees),"player":_endpoint(f),"camera":_vector3(camera.global_position),"camera_forward":_vector3(-camera.global_basis.z),"camera_fov":camera.fov,"final_camera":final_camera,"framing":framing,"public_front_framing":public_framing,"ground_framing":ground_framing,"junction_framing":junction_framing,"visibility_ray_endpoint":_vector3(visibility_endpoint),"visibility_extension_m":.02,"target_first_solid_visible":target_visible,"first_world_solid_los":_ray_value(los),"source_world_land_and_area_intact":surface_before==_surface_state(),"projected_routing":projected_routing}
	if save:
		var image:=root.get_texture().get_image();var path:=OUTPUT.path_join("images/"+str(view.id)+".png")
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		_check_contact(image!=null and not image.is_empty() and image.get_size()==STILL_SIZE,str(view.id)+" original native dimensions.")
		if image!=null and not image.is_empty():
			var sample:=_sample_image(image);_check_contact(int(sample.unique_colors)>=8 and float(sample.luminance_range)>=.1,"Nonblank native image.")
			_check_contact(image.save_png(path)==OK,"Save original native image.");row["path"]=path;row["sha256"]=FileAccess.get_sha256(path);row["sample"]=sample
		print("Northpoint1237_STUDY_IMAGE "+path)
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
	var land:Dictionary=space.intersect_ray(PhysicsRayQueryParameters3D.create(camera.global_position+Vector3.UP*20.0,camera.global_position-Vector3.UP*20.0,1,[contact_player.get_rid()]))
	var land_value:Dictionary=_ray_value(land)
	var expected_land:Dictionary=_expected_camera_land(camera.global_position)
	var land_ok:bool=bool(expected_land.get("ok",false)) and not land.is_empty() and str(land_value.get("derived_object_key",""))==str(expected_land.get("expected_object_key","")) and int(land_value.get("shape_index",-1))==0
	var clearance:Variant=null
	var above:bool=false
	if not land.is_empty():
		clearance=camera.global_position.y-float(land.position.y)
		above=float(clearance)>=0.0
		land_value["face_index"]=int(land.get("face_index",-1))
	return {"pivot":_vector3(pivot.global_position),"camera":_vector3(camera.global_position),"camera_near":camera.near,"arm_length":arm.spring_length,"arm_hit_length":arm.get_hit_length(),"arm_margin":arm.margin,"arm_collision_mask":arm.collision_mask,"pivot_to_camera_length_m":length_m,"segment_hit":_ray_value(hit),"segment_hit_distance_m":hit_distance,"segment_endpoint_allowance_m":.04,"segment_clear":segment_clear,"land_ray":land_value,"expected_camera_land":expected_land,"land_identity_ok":land_ok,"camera_minus_land_y_m":clearance,"camera_above_land":above,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames()}


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
	_clear_gameplay_input();contact_player.set_gameplay_enabled(false)
	contact_player.global_position=position;contact_player.velocity=Vector3.ZERO;contact_player.force_update_transform()
	_aim_stock_player_camera(contact_player,position-(frame.normal as Vector3)*8+Vector3.UP*2)
	await physics_frame;await process_frame;contact_player.set_gameplay_enabled(true)
	if settle:await _drive([],30,"place_settle")


func _drive(actions: Array,frames: int,label: String) -> void:
	_clear_gameplay_input()
	for action: String in actions:Input.action_press(action)
	for i in frames:
		await physics_frame;await process_frame
		var camera:=contact_player.get_camera();var pivot:=contact_player.get_node("CameraPivot") as Node3D
		var hit:=contact_player.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pivot.global_position,camera.global_position,1,[contact_player.get_rid()]))
		_check_contact(hit.is_empty() or pivot.global_position.distance_to(hit.position)>=pivot.global_position.distance_to(camera.global_position)-.04,"Stock camera segment stays clear during "+label)
		if not active_walk_label.is_empty():
			walk_trace.append({"input_frame":i+1,"physics_counter":Engine.get_physics_frames(),"process_counter":Engine.get_process_frames(),"phase":active_walk_label,"actions":actions.duplicate(),"planar_forward":_vector3(contact_player.camera_rig.planar_forward()),"position":_vector3(contact_player.global_position),"velocity":_vector3(contact_player.velocity),"on_floor":contact_player.is_on_floor(),"slide_contacts":_walk_contacts()})
		if i%10==0 or i==frames-1:samples.append({"phase":label,"frame":i,"position":_vector3(contact_player.global_position),"camera":_vector3(camera.global_position),"on_floor":contact_player.is_on_floor(),"actions":actions.duplicate()})
	_clear_gameplay_input()


func _check_contact(ok: bool,message: String) -> void:
	if not ok and message not in contact_failures:contact_failures.append(message)


func _trace_phase(actions: Array, frames: int, label: String) -> Array:
	walk_trace = []
	active_walk_label = label
	await _drive(actions, frames, label)
	active_walk_label = ""
	return walk_trace.duplicate(true)


func _endpoint(frame: Dictionary) -> Dictionary:
	var contacts := _walk_contacts()
	var upward: Array = []
	for hit: Dictionary in contacts:
		if float(hit.normal[1]) > 0.7: upward.append(hit)
	return {"position":_vector3(contact_player.global_position),"depth_m":(contact_player.global_position - (frame.start as Vector3)).dot(frame.normal),"station_m":(contact_player.global_position - (frame.start as Vector3)).dot(frame.tangent),"on_floor":contact_player.is_on_floor(),"slide_contacts":contacts,"upward_slide_contacts":upward,"unfiltered_world_solid_ray":_ray_value(_support_ray(contact_player.global_position))}


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
	return row


func _ray_value(hit: Dictionary) -> Dictionary:
	if hit.is_empty(): return {"hit":false,"excludes_only_player":true}
	var row := _collider_identity(hit.collider as Node, int(hit.shape))
	row.merge({"hit":true,"position":_vector3(hit.position),"normal":_vector3(hit.normal),"excludes_only_player":true,"not_a_stock_contact_claim":true})
	return row


func _surface_state() -> Dictionary:
	var state: Dictionary = {}
	for key: String in [LAND_KEY, AREA_KEY, ROAD_KEY, "land:w26767313:x_-2__z_-4", "area:r17241151:x_-2__z_-4", "roads:x_-2__z_-4"]:
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
	return {"ok": behind < points.size(), "scope": "Bounded accepted public-front regions, shallow roof strips, no authored canopies, locally inferred entries and local ground; hidden/cropped geometry unclaimed.", "source_runs": PROTOTYPE.TARGET_RUNS, "mesh_labels": labels, "metadata": {"target_bounds_point_count": points.size(), "target_bounds_points_behind_camera": behind, "target_projected_min_px": [minimum.x, minimum.y], "target_projected_max_px": [maximum.x, maximum.y], "target_projected_width_ratio": size.x / STILL_SIZE.x, "target_projected_height_ratio": size.y / STILL_SIZE.y, "target_bounds_fully_in_frame": minimum.x >= 0.0 and minimum.y >= 0.0 and maximum.x <= STILL_SIZE.x and maximum.y <= STILL_SIZE.y}}


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
	for label: String in ["MaroonClosedDoors", "PaleCompleteTrim", "DrapedEntryPaths", "FootwaySurface", "ExactSourceRoad"]:
		var vertices: Array[Vector3] = []; var indices: Array[int] = []
		if label == "ExactSourceRoad":
			for tile:String in ["x_-1__z_-4"]:
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
	return {"ok":labels.size()==4 and not points.is_empty(), "scope":"Actual near-2 first complete door/trim and its approach, bounded footway junction in the explicit 2.2m station strip. Original road and surrounding ground stay unchanged.", "station_interval_m":[view.junction_station_min,view.junction_station_max], "depth_interval_m":[view.junction_depth_min,view.junction_depth_max], "height_max_m":top, "mesh_labels":labels, "metadata":{"target_bounds_point_count":points.size(),"target_bounds_points_behind_camera":behind,"target_projected_min_px":[minimum.x,minimum.y],"target_projected_max_px":[maximum.x,maximum.y],"target_projected_width_ratio":size.x/STILL_SIZE.x,"target_projected_height_ratio":size.y/STILL_SIZE.y,"target_bounds_fully_in_frame":minimum.x>=0.0 and minimum.y>=0.0 and maximum.x<=STILL_SIZE.x and maximum.y<=STILL_SIZE.y}}

func _projected_front_routing() -> Dictionary:
	# Read-only rays in the existing still stage; no spray/decal creation, input, or added wait.
	var config := _json(CONFIG_PATH)
	var rows: Array = []
	for frame: Dictionary in config.target.frames:
		var normal := PROTOTYPE._v(frame.normal)
		var station: float = float(frame.routing_station_m)
		var front := PROTOTYPE._point(frame, station, (float(config.facade.story_band_y)+float(frame.top_y))*.5, float(config.facade.upper_projection_m))
		var underside := PROTOTYPE._point(frame, station, float(config.facade.story_band_y), float(config.facade.upper_projection_m)/2.0)
		var specs: Array = [
			{"kind":"eligible_front", "from":front + normal * 1.0, "to":front - normal * .1, "eligible":true},
			{"kind":"underside", "from":underside + Vector3.DOWN * .5, "to":underside + Vector3.UP * .1, "eligible":false}
		]
		for spec: Dictionary in specs:
			var query := PhysicsRayQueryParameters3D.create(spec["from"], spec["to"], 4, [contact_player.get_rid()])
			var hit: Dictionary = contact_player.get_world_3d().direct_space_state.intersect_ray(query)
			var collider := hit.get("collider") as CollisionObject3D
			var metadata: Dictionary = {}
			if collider != null:
				for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys"]: metadata[key] = collider.get_meta(key) if collider.has_meta(key) else null
				var shape_index: int = int(hit.get("shape", -1))
				if shape_index >= 0:
					var owner: int = collider.shape_find_owner(shape_index)
					if owner != 0 and collider.shape_owner_get_shape_count(owner) > 0:
						var shape := collider.shape_owner_get_shape(owner, 0)
						for key: String in ["receiver_kind", "opaque", "derived_object_key", "source_keys"]:
							if shape.has_meta(key): metadata[key] = shape.get_meta(key)
			var eligible: bool = collider != null and collider.is_in_group("spray_receiver_wall") and str(metadata.get("receiver_kind", "")) == "building_wall" and bool(metadata.get("opaque", false))
			var owner_ok: bool = str(metadata.get("derived_object_key", "")) == (WALL_KEY if bool(spec.eligible) else "prototype:" + WALL_KEY)
			var passed: bool = not hit.is_empty() and eligible == bool(spec.eligible) and owner_ok
			if bool(spec.eligible):
				passed = passed and metadata.get("source_keys", []) == ["w96665904"] and absf((hit.get("normal", Vector3.ZERO) as Vector3).y) <= .3 and (hit.get("position", Vector3.ZERO) as Vector3).distance_to(front) < .003 and (study_root.get_node("ProjectedUpperSiding") as MeshInstance3D).layers == 2
			_check_contact(passed, str(frame.id) + " actual projected " + str(spec.kind) + " ray/receiver routing.")
			rows.append({"frame":frame.id,"kind":spec.kind,"from":_vector3(spec["from"]),"to":_vector3(spec["to"]),"physics_mask":4,"hit":_ray_value(hit),"resolved_metadata":metadata,"eligible":eligible,"expected_eligible":spec.eligible,"ok":passed})
	return {"scope":"Two read-only stock-mask rays per target field; no tag placement or motion claim", "rows":rows}
