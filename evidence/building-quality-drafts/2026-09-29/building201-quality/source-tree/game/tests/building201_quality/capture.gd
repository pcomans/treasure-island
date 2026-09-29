extends "res://game/tests/p1_existing_live_revalidation_capture.gd"
const ART=preload("res://game/tests/building201_quality/candidate.gd")
const CHUNK="res://generated/world/chunks/x_0__z_-2.json"
var _out: String=""
var _diagnostic:=false
var _caster_diagnostic:=false
var _distance_diagnostic:=false
var _cascade_diagnostic:=false
func _run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg=="--diagnostic":_diagnostic=true
		if arg=="--caster-diagnostic":_caster_diagnostic=true
		if arg=="--distance-diagnostic":_distance_diagnostic=true
		if arg=="--cascade-diagnostic":_cascade_diagnostic=true
		if arg.begins_with("--output="):_out=arg.trim_prefix("--output=")
	if not _require(_out.is_absolute_path() and not DirAccess.dir_exists_absolute(_out),"Fresh output required"):_finish(null);return
	DirAccess.make_dir_recursive_absolute(_out)
	var main: GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world: WorldLoader=main.get_node("WorldRoot");var player: PlayerController=main.get_node("Player");var hud: GameHUD=main.get_node("Interface/HUD")
	var ready: Array=[];var errors: Array=[]
	world.world_ready.connect(func(r):ready.append(r));world.world_failed.connect(func(c,m,s):errors.append([c,m,s]))
	root.add_child(main)
	while ready.is_empty() and errors.is_empty():await process_frame
	if not _require(errors.is_empty(),"World failed "+str(errors)):_finish(main);return
	while not player.was_first_reveal_grounded():await physics_frame
	var owners: Array[Node3D]=_nodes_for_keys(world,[ART.LIVE.RECEIVER_KEY,ART.LIVE.ROOF_KEY])
	if not _require(owners.size()==2,"Exact pair required"):_finish(main);return
	var wall_root: Node3D
	for owner: Node3D in owners:
		if owner.get_meta("derived_object_key")==ART.LIVE.RECEIVER_KEY:wall_root=owner
	var attachment:=wall_root.find_child("D1B201LiveAttachment",true,false) as Node3D
	if not _require(attachment!=null,"Existing B201 attachment required"):_finish(main);return
	var chunk: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(CHUNK));var wall: Dictionary={}
	for row: Dictionary in chunk.records:
		if row.object_key==ART.LIVE.RECEIVER_KEY:wall=row
	var surfaces: Array=[]
	for file: String in DirAccess.get_files_at("res://generated/world/chunks"):
		if not file.ends_with(".json"):continue
		var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/"+file))
		for row: Dictionary in data.records:
			if str(row.feature_kind) in ["land_ground","landuse_area","road_surface","pedestrian_surface","area_surface"] or str(row.object_key).begins_with("area:"):
				surfaces.append(row)
	var chain: Dictionary=ART.LIVE._receiver_chain(wall)
	var center: Vector3=(chain.start+chain.end)*0.5
	var near: Vector3=center+chain.tangent*25.0+chain.outward*12.0
	var target: Vector3=center+chain.tangent*25.0;target.y=6.3
	var poses: Array=[{"id":"whole_wsw","requested_xz":Vector2(-8.000708,-214.743366),"aim_target":Vector3(64.282,5.8,-253.463)},{"id":"near_canopy","requested_xz":Vector2(near.x,near.z),"aim_target":target}]
	var pictures: Array=[]
	var before: Array=_source_shapes(owners)
	var baseline: Dictionary=await _picture(player,world,hud,poses[0],"01-baseline-whole.png");pictures.append(baseline)
	if not _require(baseline.ok,"Baseline pose failed: "+str(baseline)):_finish(main);return
	var candidate: Node3D=ART.build(wall,surfaces)
	if not _require(candidate!=null and candidate.get_meta("build_valid",false),"Candidate construction/source ground failed"):_finish(main);return
	attachment.visible=false
	for mesh: Node in wall_root.get_children():
		if mesh is MeshInstance3D:mesh.material_override=ART.wall_material()
	world.add_child(candidate)
	for i in 6:await physics_frame
	if not _require(before==_source_shapes(owners),"Source structural/roof geometry changed"):_finish(main);return
	var native: Dictionary=_native(candidate)
	_write_json(_out.path_join("native.json"),native)
	if not _require(native.ok,"Candidate visible-depth/contact mismatch"):_finish(main);return
	for i in poses.size():
		var picture: Dictionary=await _picture(player,world,hud,poses[i],"0%d-candidate-%s.png"%[i+2,poses[i].id]);pictures.append(picture)
		_write_json(_out.path_join("capture-progress.json"),{"captures":pictures})
		if not _require(picture.ok,"Candidate pose failed: "+str(picture)):_finish(main);return
	var diagnostic: Dictionary={}
	if _diagnostic:diagnostic=await _compare(main,player,wall_root,candidate)
	if _caster_diagnostic:diagnostic=await _compare_casters(main,player,wall_root,candidate)
	if _distance_diagnostic or _cascade_diagnostic:diagnostic=await _compare_distance(main,player,world,hud,poses)
	_clear_gameplay_input();Input.action_release("spray");player.set_gameplay_enabled(false)
	_write_json(_out.path_join("capture.json"),{"scope":"isolated B201 candidate, no promotion/mechanics acceptance","captures":pictures,"diagnostic":diagnostic,"source_shapes_unchanged":true,"source_shapes":before,"contact":native,"candidate_sha256":FileAccess.get_sha256("res://game/tests/building201_quality/candidate.gd"),"shader_sha256":FileAccess.get_sha256("res://game/tests/building201_quality/surface.gdshader"),"source_chunk_sha256":FileAccess.get_sha256(CHUNK)})
	_finish(main)
func _picture(player: PlayerController,world: WorldLoader,hud: GameHUD,pose: Dictionary,name: String) -> Dictionary:
	var ground: Dictionary=_ground_hit(player,pose.requested_xz)
	if ground.is_empty():return {"ok":false,"message":"Missing source LAND"}
	for height: float in [0.05,SETTLE_START_HEIGHT_M]:
		var q:=PhysicsShapeQueryParameters3D.new();q.shape=player.collision_shape.shape
		q.transform=Transform3D(Basis.IDENTITY,Vector3(pose.requested_xz.x,float(ground.position.y)+height,pose.requested_xz.y))*player.collision_shape.transform
		q.collision_mask=1;q.exclude=[player.get_rid()]
		if not player.get_world_3d().direct_space_state.intersect_shape(q,8).is_empty():return {"ok":false,"message":"Anchor stock capsule blocked"}
	var settled: Dictionary=await _settle_and_aim(world,player,hud,pose)
	if not settled.get("ok",false):return {"ok":false,"pose":settled}
	for i in 6:await physics_frame
	var camera:=player.get_camera();var arm:=player.get_node("CameraPivot/SpringArm3D") as SpringArm3D
	var q:=PhysicsShapeQueryParameters3D.new();q.shape=arm.shape;q.transform=Transform3D(Basis.IDENTITY,camera.global_position);q.collision_mask=1;q.exclude=[player.get_rid()]
	if not player.get_world_3d().direct_space_state.intersect_shape(q,8).is_empty():return {"ok":false,"message":"Stock camera hull blocked"}
	await RenderingServer.frame_post_draw
	var path: String=_out.path_join(name)
	return {"ok":root.get_texture().get_image().save_png(path)==OK,"file":path,"pose":settled.metadata}
func _source_shapes(owners: Array[Node3D]) -> Array:
	var rows: Array=[]
	for owner: Node3D in owners:
		for body: StaticBody3D in owner.find_children("*","StaticBody3D",true,false):
			for shape: CollisionShape3D in body.get_children():
				rows.append({"owner":owner.get_meta("derived_object_key"),"body":str(body.name),"shape":str(shape.name),"layer":body.collision_layer,"transform":str(body.global_transform),"faces":str((shape.shape as ConcavePolygonShape3D).get_faces())})
	return rows
func _native(candidate: Node3D) -> Dictionary:
	var visual:=PackedVector3Array();var layers_ok:=true
	for mesh: Node in candidate.get_children():
		if mesh is MeshInstance3D:
			layers_ok=layers_ok and mesh.layers==2
			for p: Vector3 in mesh.mesh.get_faces():visual.append(mesh.transform*p)
	var body:=candidate.get_node("FamilyContact_wall") as StaticBody3D
	var holder:=body.get_child(0) as CollisionShape3D
	var faces: PackedVector3Array=(holder.shape as ConcavePolygonShape3D).get_faces()
	var same: bool=faces.size()==visual.size()
	var max_error:=0.0
	if same:
		for i in faces.size():max_error=maxf(max_error,(body.transform*holder.transform*faces[i]).distance_to(visual[i]))
	var identity: bool=body.collision_layer==5 and body.is_in_group("spray_receiver_wall") and body.get_meta("derived_object_key")==ART.LIVE.RECEIVER_KEY and body.get_meta("source_keys")==[ART.LIVE.SOURCE_KEY] and holder.shape.get_meta("receiver_kind")=="building_wall"
	return {"ok":same and max_error<0.0001 and layers_ok and identity,"triangles":faces.size()/3,"max_contact_error_m":max_error,"render_layers":2,"receiver_kind":"building_wall","source":ART.LIVE.SOURCE_KEY,"apron":"render1 no collider, draped original support","stock_mechanics":"pending"}

func _compare(main: GameMain,player: PlayerController,wall_root: Node3D,candidate: Node3D) -> Dictionary:
	var materials: Array[ShaderMaterial]=[]
	for owner: Node3D in [wall_root,candidate]:
		for mesh: MeshInstance3D in owner.find_children("*","MeshInstance3D",true,false):
			if mesh.material_override is ShaderMaterial and mesh.material_override.shader==ART.SURFACE and not materials.has(mesh.material_override):materials.append(mesh.material_override)
	var sun:=main.get_node("Sun") as DirectionalLight3D
	var shadow_before: bool=sun.shadow_enabled
	var fixed_camera: Transform3D=player.get_camera().global_transform
	var files: Array=[]
	for mode: String in ["A-normal","B-procedural-variation-zero","C-shadow-disabled-diagnostic"]:
		for material: ShaderMaterial in materials:material.set_shader_parameter("variation_gain",0.0 if mode.begins_with("B-") else 1.0)
		sun.shadow_enabled=false if mode.begins_with("C-") else shadow_before
		for i in 8:await physics_frame
		await RenderingServer.frame_post_draw
		var file: String=_out.path_join("diagnostic-"+mode+".png")
		var same: bool=player.get_camera().global_transform.is_equal_approx(fixed_camera)
		var saved: bool=root.get_texture().get_image().save_png(file)==OK
		files.append({"mode":mode,"file":file,"saved":saved,"camera_unchanged":same,"shadow_enabled":sun.shadow_enabled})
		if not saved or not same:_fail("Diagnostic capture/pose mismatch");break
	for material: ShaderMaterial in materials:material.set_shader_parameter("variation_gain",1.0)
	sun.shadow_enabled=shadow_before
	for i in 4:await physics_frame
	return {"files":files,"material_count":materials.size(),"sun_restored":sun.shadow_enabled==shadow_before,"camera_restored":player.get_camera().global_transform.is_equal_approx(fixed_camera),"diagnostic_only":"C is not a candidate/shipping appearance; no renderer settings changed"}

func _compare_casters(main: GameMain,player: PlayerController,wall_root: Node3D,candidate: Node3D) -> Dictionary:
	var canopy: Array[MeshInstance3D]=[]
	var source: Array[MeshInstance3D]=[]
	var expected: Array[Vector3]=[Vector3(ART.LIVE.CHAIN_LENGTH_M-1.4,0.16,1.90),Vector3(ART.LIVE.CHAIN_LENGTH_M-1.4,0.24,0.11),Vector3(ART.LIVE.CHAIN_LENGTH_M-1.4,0.045,0.17)]
	for size: Vector3 in expected:
		var matches: Array[MeshInstance3D]=[]
		for node: Node in candidate.get_children():
			if node is MeshInstance3D and node.mesh is BoxMesh and node.mesh.size.is_equal_approx(size):matches.append(node)
		if not _require(matches.size()==1,"Exact canopy caster selection failed"):return {"ok":false}
		canopy.append(matches[0])
	for node: Node in wall_root.get_children():
		if node is MeshInstance3D:source.append(node)
	if not _require(not source.is_empty(),"Source wall caster absent"):return {"ok":false}
	var all_meshes: Array[MeshInstance3D]=[];all_meshes.append_array(canopy);all_meshes.append_array(source)
	var states: Array[int]=[];var identities: Array=[]
	for mesh: MeshInstance3D in all_meshes:
		states.append(mesh.cast_shadow)
		identities.append({"path":str(mesh.get_path()),"cast_shadow":mesh.cast_shadow,"transform":str(mesh.global_transform),"layers":mesh.layers,"faces":mesh.mesh.get_faces().size(),"material_id":mesh.material_override.get_instance_id()})
	var sun:=main.get_node("Sun") as DirectionalLight3D
	var shadow_before: bool=sun.shadow_enabled
	var fixed_camera: Transform3D=player.get_camera().global_transform
	var files: Array=[];var ok:=true
	for mode: String in ["A-normal","B-canopy-casting-off","C-source-wall-casting-off"]:
		for i in all_meshes.size():all_meshes[i].cast_shadow=states[i]
		var excluded: Array[MeshInstance3D]=[]
		if mode.begins_with("B-"):excluded.append_array(canopy)
		if mode.begins_with("C-"):excluded.append_array(source)
		for mesh: MeshInstance3D in excluded:mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in 8:await physics_frame
		await RenderingServer.frame_post_draw
		var file: String=_out.path_join("caster-"+mode+".png")
		var same: bool=player.get_camera().global_transform.is_equal_approx(fixed_camera) and sun.shadow_enabled==shadow_before
		var saved: bool=root.get_texture().get_image().save_png(file)==OK
		var active_states: Array=[]
		for mesh: MeshInstance3D in all_meshes:active_states.append(mesh.cast_shadow)
		files.append({"mode":mode,"file":file,"saved":saved,"camera_and_sun_unchanged":same,"cast_states":active_states})
		if not saved or not same:ok=false;_fail("Caster diagnostic capture/state mismatch");break
	for i in all_meshes.size():all_meshes[i].cast_shadow=states[i]
	for i in 4:await physics_frame
	var restored:=true
	for i in all_meshes.size():restored=restored and all_meshes[i].cast_shadow==states[i]
	return {"ok":ok and restored,"files":files,"canopy_count":canopy.size(),"source_count":source.size(),"identities":identities,"cast_states_restored":restored,"sun_unchanged":sun.shadow_enabled==shadow_before,"camera_unchanged":player.get_camera().global_transform.is_equal_approx(fixed_camera),"diagnostic_only":"Caster exclusions only; received shadows and all material/geometry/contact inputs unchanged; not shipping appearance"}

func _compare_distance(main: GameMain,player: PlayerController,world: WorldLoader,hud: GameHUD,poses: Array) -> Dictionary:
	var sun:=main.get_node("Sun") as DirectionalLight3D
	var properties: Array[String]=["directional_shadow_mode","directional_shadow_split_1","directional_shadow_split_2","directional_shadow_split_3","directional_shadow_blend_splits","directional_shadow_fade_start","directional_shadow_max_distance","shadow_bias","shadow_normal_bias","shadow_blur","light_angular_distance","shadow_enabled"]
	var original: Dictionary={}
	for key: String in properties:original[key]=sun.get(key)
	if not _require(is_equal_approx(sun.directional_shadow_max_distance,800.0) and sun.directional_shadow_mode==DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS,"Expected 800m/four cascade hypothesis setup"):return {"ok":false,"original":original}
	var filter_settings: Dictionary={}
	for key: String in ["rendering/lights_and_shadows/directional_shadow/size","rendering/lights_and_shadows/directional_shadow/soft_shadow_filter_quality"]:filter_settings[key]=ProjectSettings.get_setting(key)
	var views: Array=[poses[1],poses[0],{"id":"hawkins_context","requested_xz":Vector2(2.37,556.10),"aim_target":Vector3(-60.610,14.774,503.550)}]
	var files: Array=[];var ok:=true
	for pose: Dictionary in views:
		sun.directional_shadow_max_distance=800.0
		for key: String in ["directional_shadow_split_1","directional_shadow_split_2","directional_shadow_split_3"]:sun.set(key,original[key])
		var control: Dictionary=await _picture(player,world,hud,pose,("cascade-" if _cascade_diagnostic else "distance-")+str(pose.id)+"-control.png")
		files.append(control)
		if not control.get("ok",false):ok=false;_fail("Distance control pose failed");break
		var fixed_camera: Transform3D=player.get_camera().global_transform
		if _cascade_diagnostic:
			sun.directional_shadow_split_1=0.025;sun.directional_shadow_split_2=0.10;sun.directional_shadow_split_3=0.25
		else:sun.directional_shadow_max_distance=200.0
		for i in 8:await physics_frame
		await RenderingServer.frame_post_draw
		var file: String=_out.path_join(("cascade-" if _cascade_diagnostic else "distance-")+str(pose.id)+"-trial.png")
		var same: bool=player.get_camera().global_transform.is_equal_approx(fixed_camera)
		var saved: bool=root.get_texture().get_image().save_png(file)==OK
		files.append({"ok":saved and same,"file":file,"camera_unchanged":same,"camera_far":player.get_camera().far,"shadow_distance_m":sun.directional_shadow_max_distance,"splits":[sun.directional_shadow_split_1,sun.directional_shadow_split_2,sun.directional_shadow_split_3]})
		if not saved or not same:ok=false;_fail("Distance comparison capture mismatch");break
	sun.directional_shadow_max_distance=float(original.directional_shadow_max_distance)
	for key: String in ["directional_shadow_split_1","directional_shadow_split_2","directional_shadow_split_3"]:sun.set(key,original[key])
	for i in 4:await physics_frame
	var restored:=true
	for key: String in properties:restored=restored and sun.get(key)==original[key]
	return {"ok":ok and restored,"files":files,"original_light_settings":original,"filter_settings":filter_settings,"light_state_restored":restored,"scope":"unpromoted scene-wide shadow allocation/distance experiment; all casters/materials retained, no performance or distant-coverage acceptance"}
