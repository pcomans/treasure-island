extends "res://game/tests/housing_family_experiment/normal_capture.gd"
const ADOPTION = preload("res://game/scripts/world/facades/housing_family_live_attachment.gd")
const NEW_SOURCES = ["w96698634"]
var measurement_only := true
var unit_results: Array = []
var motion_trace: Array = []
var sampled_frames: int = 0
var active_source := ""
var safe_final := false
var contact_samples: Array=[]

func _initialize() -> void:
	create_timer(900.0,true,false,true).timeout.connect(func(): _fail("Integration timeout"); _receipt(); quit(1))
	call_deferred("_run")

func _run() -> void:
	var manifest_path := ""
	for arg in OS.get_cmdline_user_args():
		if arg=="--measure-candidate": measurement_only=true
		if arg.begins_with("--manifest="): manifest_path=arg.trim_prefix("--manifest=")
		if arg.begins_with("--output="): output=arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output),"Fresh integration output"):
		await _finish(null)
		return
	DirAccess.make_dir_recursive_absolute(output)
	# Focused source representation controls inside the already needed invocation.
	var dependency_path: String="game/scripts/world/facades/housing_site_family.gd"
	var digest: String=FileAccess.get_sha256("res://"+dependency_path)
	var representation: Dictionary=ADOPTION.dependency_representation(dependency_path,digest)
	var source_controls: Array[bool]=[
		bool(representation.get("ok",false)) and str(representation.get("kind",""))=="source",
		not bool(ADOPTION.dependency_representation(dependency_path,"0".repeat(64)).get("ok",false)),
		not bool(ADOPTION.dependency_representation("game/scripts/world/world_loader.gd",digest).get("ok",false)),
		not bool(ADOPTION.dependency_representation("game/scripts/missing-family-dependency.gd",digest).get("ok",false)),
		not bool(ADOPTION.dependency_representation("../project.godot",digest).get("ok",false))]
	checks.append({"source_representation_controls":source_controls})
	if not _require(not false in source_controls,"Source dependency representation positive/negative controls"):
		_receipt()
		await _finish(null)
		return
	var manifest: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	var main := (load("res://game/scenes/main.tscn") as PackedScene).instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var ready: Array=[]
	var errors: Array=[]
	world.world_ready.connect(func(r: Dictionary): ready.append(r))
	world.world_failed.connect(func(c: String,m: String,k: Array): errors.append([c,m,k]))
	root.add_child(main)
	var began := Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-began<90000: await physics_frame
	if not _require(errors.is_empty() and ready.size()==1 and world.is_world_validated(),"Normal world identity/load: "+str(errors)):
		await _finish(main)
		return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if measurement_only:
		var additions: Array=[]
		var chunks: Array=[]
		var normal: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(ADOPTION.CONFIG))
		var seen: Dictionary={}
		for item: Dictionary in normal.instances: seen[str(item.source_key)]=true
		if not _require(seen.size()==33,"Fixture baseline exact33 membership"):
			await _finish(main)
			return
		for target: Dictionary in manifest.targets:
			if not _require(str(target.source_key) in NEW_SOURCES and not seen.has(str(target.source_key)),"Candidate addition disjoint exact new1"):
				await _finish(main)
				return
			seen[str(target.source_key)]=true
			additions.append({"source_key":target.source_key,"config":target.config,"chunk":target.chunk})
			chunks.append(JSON.parse_string(FileAccess.get_file_as_string(target.chunk)))
		if not _require(seen.size()==34 and additions.size()==1,"Candidate union exact34"):
			await _finish(main)
			return
		var baseline := ADOPTION.validate_live(world)
		if not _require(bool(baseline.get("ok",false)),"Normal33 baseline before fixture: "+str(baseline)):
			await _finish(main)
			return
		var installed := ADOPTION.install(world.buildings,chunks,{"instances":additions})
		if not _require(installed.get("ok",false),"Candidate construction: "+str(installed)):
			_receipt()
			await _finish(main)
			return
		var actual: Dictionary={}
		for node: Node in world.find_children("SharedHousing_*","Node3D",true,false):
			var source := str(node.get_meta("source_key",""))
			if not _require(not actual.has(source) and seen.has(source) and node.get_meta("build_valid",false) and str(node.get_parent().get_meta("derived_object_key",""))=="building:"+source+":wall","Candidate actual instance identity/owner"):
				_receipt()
				await _finish(main)
				return
			actual[source]=true
		var actual_ids: Array=actual.keys()
		var declared_ids: Array=seen.keys()
		actual_ids.sort()
		declared_ids.sort()
		if not _require(actual_ids==declared_ids,"Candidate exact actual34 union"):
			_receipt()
			await _finish(main)
			return
		checks.append({"candidate_actual_sources":actual_ids,"scope":"normal33 plus fixture1"})
	await physics_frame
	await physics_frame
	current_topology=ADOPTION.measure_world(world)
	checks.append({"topology":current_topology,"scope":"fixture34; normal authority remains33"})
	if not measurement_only:
		var live := ADOPTION.validate_live(world)
		if not _require(live.get("ok",false) and int(live.get("instances",0))==33,"Exact normal33 adoption: "+str(live)):
			_receipt()
			await _finish(main)
			return
	# All useful views precede contact and movement diagnostics.
	var view_targets: Array=manifest.get("views",manifest.targets)
	for target: Dictionary in view_targets:
		var row: Dictionary=target.duplicate(true)
		row.requested_xz=_near_front_anchor(target)
		row.aim_target=FAMILY.vec(target.aim_target)
		var settled := await _settle_player(row.requested_xz,row.id,world,player)
		if not _require(settled.get("ok",false),str(settled)): break
		_aim_camera_at(player,row.aim_target)
		if not await _wait_for_render(player): break
		row.id=target.id+"-INSTALLED"
		var metadata: Dictionary=settled.metadata.duplicate(true)
		metadata.merge({"source_key":target.source_key,"phase":"fixture34"})
		var saved := _save_current_view(row,output,player,metadata)
		if not _require(saved.get("ok",false),str(saved)): break
		rows.append(saved.metadata)
		_receipt()
	if rows.size()!=view_targets.size():
		_fail("Incomplete integrated views")
		_receipt()
		await _finish(main)
		return
	if not await _rest(world,player,"views-complete"):
		_receipt()
		await _finish(main)
		return
	player.set_gameplay_enabled(false)
	var fit := _verify_family(world,true)
	if not fit and not _failure.begins_with("Aggregate exposed contact HOLD"):
		_receipt()
		await _finish(main)
		return
	for target: Dictionary in manifest.targets:
		active_source=str(target.source_key)
		var contact_hold := false
		for check: Dictionary in checks:
			if str(check.get("source",""))==active_source and int(check.get("failures",0))>0: contact_hold=true
		if contact_hold:
			unit_results.append({"source":active_source,"ok":false,"hold":"contact mismatch; dependent motion skipped"})
			continue
		var result: Dictionary
		if active_source in NEW_SOURCES:
			var crossing := await _pedestrian_crossing(target,world,player)
			if not bool(crossing.get("ok",false)):
				unit_results.append(crossing)
				_receipt()
				if not bool(crossing.get("safe_rest",false)) or bool(crossing.get("fatal",false)): break
				continue
			result=await _unit_motion(target,world,player)
			result["pedestrian_crossing"]=crossing
		else:
			result=await _unit_motion(target,world,player)
		if bool(result.get("ok",false)):
			var rear: Dictionary=await _rear_spray(target,world,player)
			result["rear_spray"]=rear
			result.ok=bool(rear.ok)
			result.safe_rest=bool(rear.safe_rest)
			result["fatal"]=bool(rear.fatal)
		unit_results.append(result)
		_receipt()
		if not bool(result.get("safe_rest",false)) or bool(result.get("fatal",false)): break
	# A real loader reload must emit a new ready signal and preserve exact totals.
	if unit_results.size()==1 and unit_results.all(func(r: Dictionary): return bool(r.get("safe_rest",false)) and not bool(r.get("fatal",false))) and await _rest(world,player,"pre-reload"):
		player.set_gameplay_enabled(false)
		var prior: Dictionary=current_topology.duplicate(true)
		world.load_world()
		began=Time.get_ticks_msec()
		while (ready.size()<2 or not player.is_on_floor()) and errors.is_empty() and Time.get_ticks_msec()-began<90000: await physics_frame
		var live := ADOPTION.validate_live(world)
		safe_final=await _rest(world,player,"post-reload")
		var reinstalled := _reinstall_fixture(world,manifest)
		await physics_frame
		await physics_frame
		var reload_ok := _require(reinstalled and errors.is_empty() and ready.size()==2 and world.is_world_validated() and live.get("ok",false) and ADOPTION.topology_matches(ADOPTION.measure_world(world),prior) and _connections_once(main),"Actual reload/single connections/topology")
		checks.append({"reload":reload_ok,"ready_signals":ready.size(),"safe_rest":safe_final})
		player.set_gameplay_enabled(false)
		completed=reload_ok and safe_final and unit_results.all(func(r: Dictionary): return r.get("ok",false))
	_receipt()
	await _finish(main)

func _sample(world: WorldLoader,player: PlayerController,label: String,extra: Dictionary={}) -> Dictionary:
	var position := player.global_position
	var hit := world.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(position+Vector3.UP*0.3,position-Vector3.UP*0.6,1,[player.get_rid()]))
	var support := "" if hit.is_empty() else _derived_object_key_for_collider(hit.collider)
	var collisions: Array=[]
	for i in player.get_slide_collision_count():
		var col := player.get_slide_collision(i)
		collisions.append({"owner":_derived_object_key_for_collider(col.get_collider()),"normal":_v(col.get_normal()),"position":_v(col.get_position())})
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
	_clear_gameplay_input()
	player.set_gameplay_enabled(true)
	for frame in 45:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label)
	var last: Dictionary=motion_trace[-1]
	var good: bool = player.is_on_floor() and player.velocity.length()<0.05 and not str(last.support).is_empty() and last.controller_enabled and last.released_inputs
	return _require(good,"Supported input-released stock rest: "+label)

func _segment(world: WorldLoader,player: PlayerController,label: String,actions: Array,frames: int) -> Dictionary:
	var start := player.global_position
	var recovery := world.get_runtime_evidence().recovery_count
	player.set_gameplay_enabled(true)
	for action: String in actions: Input.action_press(action)
	for frame in frames:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label)
		if world.get_runtime_evidence().recovery_count!=recovery: break
	_clear_gameplay_input()
	var rest := await _rest(world,player,label+"-rest")
	return {"stage":label,"start":_v(start),"end":_v(player.global_position),"distance":start.distance_to(player.global_position),"safe_rest":rest,"recovery_delta":world.get_runtime_evidence().recovery_count-recovery}

func _motion_image(player: PlayerController,stage: String) -> void:
	await _wait_for_active_render(player)
	var shot: Dictionary=_save_current_view({"id":active_source+"-"+stage,"region":active_source,"intent":"Sampled actual stock motion: "+stage},output,player,{"source_key":active_source,"phase":stage,"physics_frame":Engine.get_physics_frames(),"movement_proof":true,"physics_grounded":player.is_on_floor(),"controller_enabled":bool(player.get("_gameplay_enabled")),"actions":_input_state(),"scope":"Single sampled frame; physics trace has gaps while awaiting renderer"})
	if _require(shot.get("ok",false),"Mandatory motion sample "+active_source+" "+stage): rows.append(shot.metadata)

func _unit_motion(target: Dictionary,world: WorldLoader,player: PlayerController) -> Dictionary:
	var result := {"source":target.source_key,"ok":false,"safe_rest":false,"stages":[]}
	var cfg: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.config))
	var frame: Dictionary=cfg.target.frames[1]
	var entry: Dictionary=frame.entries[0]
	var basis: Dictionary=entry.get("basis",frame)
	var outward := FAMILY.vec(basis.normal)
	var door := FAMILY.vec(basis.start)+FAMILY.vec(basis.tangent)*float(entry.get("local_station_m",entry.station_m))
	door.y=float(entry.bottom_y)+1.1
	# Start outside the parking canopy; the stock approach then crosses beneath it.
	var anchor := door+outward*(16.0 if cfg.has("carports") else (10.0 if cfg.has("carport") else 4.0))
	var settled := await _settle_player(Vector2(anchor.x,anchor.z),active_source+"-approach",world,player)
	if not _require(settled.get("ok",false),str(settled)): return result
	_aim_camera_at(player,door)
	if not await _rest(world,player,"approach-start"): return result
	var approach := await _segment(world,player,"walk-to-closed-threshold",["move_forward"],240 if cfg.has("carports") else (160 if cfg.has("carport") else 70))
	approach["threshold_outward_distance"]=(player.global_position-door).dot(outward)
	result.stages.append(approach)
	if not approach.safe_rest: return result
	if approach.recovery_delta!=0:
		_require(false,"Recovery during approach: "+active_source)
		result.safe_rest=true
		result["fatal"]=true
		player.set_gameplay_enabled(false)
		return result
	var retreat := await _segment(world,player,"walk-retreat",["move_back"],40)
	result.stages.append(retreat)
	if not retreat.safe_rest: return result
	if retreat.recovery_delta!=0:
		_require(false,"Recovery during retreat: "+active_source)
		result.safe_rest=true
		result["fatal"]=true
		player.set_gameplay_enabled(false)
		return result
	var run := await _segment(world,player,"short-run-retreat",["move_back","run"],12)
	result.stages.append(run)
	if not run.safe_rest: return result
	if run.recovery_delta!=0:
		_require(false,"Recovery during run: "+active_source)
		result.safe_rest=true
		result["fatal"]=true
		player.set_gameplay_enabled(false)
		return result
	if not _require(approach.distance>0.5 and approach.threshold_outward_distance>0.0 and approach.threshold_outward_distance<1.2 and retreat.distance>0.5 and run.distance>0.15 and approach.recovery_delta==0 and retreat.recovery_delta==0 and run.recovery_delta==0,"Stock approach/retreat/run "+active_source):
		result.safe_rest=true
		result["fatal"]=approach.recovery_delta!=0 or retreat.recovery_delta!=0 or run.recovery_delta!=0
		player.set_gameplay_enabled(false)
		return result
	# The near-front source-LAND anchor is outside the roof; ascend with stock input.
	settled=await _settle_player(_near_front_anchor(target),active_source+"-jetpack",world,player)
	if not _require(settled.get("ok",false),str(settled)): return result
	_aim_camera_at(player,FAMILY.vec(target.aim_target))
	if not await _rest(world,player,"jetpack-start"): return result
	var start := player.global_position
	var recovery := world.get_runtime_evidence().recovery_count
	await _motion_image(player,"jetpack-start")
	Input.action_press("jetpack")
	for tick in 85:
		await physics_frame
		_sample(world,player,"jetpack-ascent")
		if world.get_runtime_evidence().recovery_count!=recovery: break
		if tick==40: await _motion_image(player,"jetpack-ascent")
	Input.action_release("jetpack")
	if world.get_runtime_evidence().recovery_count!=recovery:
		_require(false,"Recovery during jetpack ascent "+active_source)
		result.safe_rest=await _rest(world,player,"recovery-stop")
		result["fatal"]=true
		player.set_gameplay_enabled(false)
		return result
	var peak := player.global_position
	await _motion_image(player,"jetpack-release")
	if active_source in NEW_SOURCES:
		_aim_camera_at(player,Vector3(target.aim_target[0],8.95,target.aim_target[2]))
		await _wait_for_active_render(player)
		var shot := _save_current_view({"id":active_source+"-stock-roof-oblique","region":active_source,"intent":"Roof observed during actual stock jetpack ascent/release"},output,player,{"source_key":active_source,"phase":"stock-jetpack","movement_proof":true,"physics_grounded":player.is_on_floor(),"scope":"Actual stock airborne view; not settled ground"})
		if shot.get("ok",false): rows.append(shot.metadata)
	for tick in 480:
		await physics_frame
		_sample(world,player,"jetpack-descent")
		if world.get_runtime_evidence().recovery_count!=recovery: break
		if tick==45: await _motion_image(player,"jetpack-descent")
		if player.is_on_floor() and player.velocity.length()<0.05: break
	var landed := await _rest(world,player,"jetpack-landed")
	if landed: await _motion_image(player,"jetpack-landed")
	result.stages.append({"stage":"stock-jetpack","start":_v(start),"released":_v(peak),"landed":_v(player.global_position),"safe_rest":landed,"recovery_delta":world.get_runtime_evidence().recovery_count-recovery})
	if not landed: return result
	if not _require(peak.y-start.y>3.0 and absf(player.global_position.y-start.y)<0.12 and world.get_runtime_evidence().recovery_count==recovery,"Controlled stock ascent/descent "+active_source):
		result.safe_rest=true
		result["fatal"]=world.get_runtime_evidence().recovery_count!=recovery
		player.set_gameplay_enabled(false)
		return result
	# Select an exact front solid band, clear of openings and screen modules.
	var spray_point := FAMILY.vec(frame.start)+FAMILY.vec(frame.tangent)*0.7
	spray_point.y=float(cfg.wall_top_y)-2.55
	var spray_anchor := spray_point+FAMILY.vec(frame.normal)*2.0
	settled=await _settle_player(Vector2(spray_anchor.x,spray_anchor.z),active_source+"-spray",world,player)
	if not _require(settled.get("ok",false),str(settled)): return result
	_aim_camera_at(player,spray_point)
	if not await _rest(world,player,"spray-start"): return result
	await _wait_for_render(player)
	var hit := _camera_spray_hit(player)
	if not _require(not hit.is_empty() and _derived_object_key_for_collider(hit.collider)=="building:"+active_source+":wall","Stock source first spray hit "+active_source):
		result.safe_rest=true
		result["fatal"]=true
		player.set_gameplay_enabled(false)
		return result
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	controller.attempt_spray()
	await process_frame
	var tag: Decal=null
	if controller.tag_instances.get_child_count()>before:
		tag=controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
	var valid: bool = controller.tag_instances.active_count()==before+1 and tag!=null and tag.cull_mask==2 and str(tag.get_meta("derived_object_key",""))=="building:"+active_source+":wall" and tag.get_meta("source_keys",[])==[active_source] and tag.global_position.distance_to(hit.position)<0.05
	_require(valid,"Actual stock decal identity/cull/position "+active_source)
	result.stages.append({"stage":"stock-spray","ok":valid,"first_hit":_v(hit.position),"cull_mask":0 if tag==null else tag.cull_mask})
	var image_result := _save_current_view({"id":active_source+"-stock-spray","region":active_source,"intent":"Per-unit stock wall spray"},output,player,{"source_key":active_source,"phase":"stock-spray","physics_grounded":player.is_on_floor()})
	if image_result.get("ok",false): rows.append(image_result.metadata)
	result.safe_rest=await _rest(world,player,"unit-final")
	player.set_gameplay_enabled(false)
	result["disabled_final"]=not bool(player.get("_gameplay_enabled")) and player.velocity.length()==0.0 and _released()
	var samples_complete: bool=true
	for stage: String in ["jetpack-start","jetpack-ascent","jetpack-release","jetpack-descent","jetpack-landed"]:
		var found: bool=false
		for row: Dictionary in rows:
			if str(row.id)==active_source+"-"+stage: found=true
		samples_complete=samples_complete and found
	_require(samples_complete,"All mandatory sampled motion images "+active_source)
	result["fatal"]=not valid
	result.ok=valid and result.safe_rest and result.disabled_final and samples_complete
	return result

func _connections_once(main: GameMain) -> bool:
	var evidence=main.world_root.get_runtime_evidence()
	var spray=main.player.get_spray_controller()
	var pairs=[[main.player.feedback_requested,main.hud.show_feedback],[main.player.spray_result,evidence.record_spray],[main.player.recovered,evidence.record_recovery],[spray.spray_identity,evidence.record_spray_identity],[spray.tag_instances.active_count_changed,evidence.set_active_decals],[spray.tag_instances.oldest_tag_removed,evidence.record_tag_eviction]]
	for pair: Array in pairs:
		var matches := 0
		for connection: Dictionary in (pair[0] as Signal).get_connections():
			if connection.callable==pair[1]: matches+=1
		if not _require(matches==1,"GameMain runtime signal connected exactly once"): return false
	return true

func _receipt() -> void:
	if output.is_empty() or not DirAccess.dir_exists_absolute(output): return
	var data := {"ok":completed and _failure.is_empty(),"failure":_failure,"captures":rows,"checks":checks,"unit_results":unit_results,"sampled_frames":sampled_frames,"stored_frames":motion_trace.size(),"safe_final":safe_final,"topology":current_topology,"contact_samples":contact_samples,"scope":"normal33 plus fixture1 live source mechanics; no authority/promotion"}
	var file := FileAccess.open(output.path_join("capture-receipt.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(data,"\t")+"\n")
	file=FileAccess.open(output.path_join("motion-trace.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify(motion_trace)+"\n")

func _verify_family(world: WorldLoader, sample_contacts := true) -> bool:
	var found: Dictionary = {}
	var sampled := 0
	var contact_failures: Array[String] = []
	for node: Node in world.find_children("SharedHousing_*","Node3D",true,false):
		var source := str(node.get_meta("source_key",""))
		if not _require(not found.has(source),"Duplicate live instance "+source): return false
		found[source]=true
		if source in NEW_SOURCES:
			var expected: Dictionary={"wall":PackedVector3Array(),"roof":PackedVector3Array(),"support":PackedVector3Array(),"ground":PackedVector3Array()}
			for mesh: Node in node.get_children():
				if not mesh is MeshInstance3D: continue
				var role := str(mesh.get_meta("family_role","support"))
				var faces: PackedVector3Array=expected[role]
				for vertex: Vector3 in mesh.mesh.get_faces(): faces.append(mesh.transform*vertex)
				expected[role]=faces
			var native_roles: Array=[]
			for body: Node in node.get_children():
				if not body is StaticBody3D: continue
				var role := str(body.get_meta("family_role",""))
				var local_faces := PackedVector3Array()
				for vertex: Vector3 in expected[role]: local_faces.append(vertex-body.position)
				var shape: ConcavePolygonShape3D=body.get_child(0).shape
				if not _require(not local_faces.is_empty() and local_faces==shape.get_faces(),"Exact native render/contact local arrays "+source+" "+role): return false
				native_roles.append(role)
			checks.append({"source":source,"native_array_roles":native_roles,"render_contact_arrays_exact":true})
			var geometry: Dictionary={}
			for role: String in expected:
				var vertices: Array=[]
				for vertex: Vector3 in expected[role]: vertices.append(_v(vertex))
				geometry[role]=vertices
			var geometry_file := FileAccess.open(output.path_join(source+"-native-faces.json"),FileAccess.WRITE)
			geometry_file.store_string(JSON.stringify(geometry)+"\n")
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
				if not sample_contacts or source not in NEW_SOURCES: continue
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
				else:
					mesh_samples+=1
					contact_samples.append({"source":source,"role":role,"mesh_index":mesh.get_index(),"point":_v(center),"land_clearance":chosen.land_clearance,"hit":_v(hit.position),"owner":_derived_object_key_for_collider(hit.collider),"shape":hit.shape})
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
	return _require(found.size()==34,"Expected34 fixture installed instances")

func _reinstall_fixture(world: WorldLoader,manifest: Dictionary) -> bool:
	var additions: Array=[]
	var chunks: Array=[]
	for target: Dictionary in manifest.targets:
		additions.append({"source_key":target.source_key,"config":target.config,"chunk":target.chunk})
		chunks.append(JSON.parse_string(FileAccess.get_file_as_string(target.chunk)))
	var installed := ADOPTION.install(world.buildings,chunks,{"instances":additions})
	return _require(bool(installed.get("ok",false)) and int(installed.get("instances",0))==1,"Reinstall exact fixture1 after normal reload")

func _pedestrian_crossing(target: Dictionary,world: WorldLoader,player: PlayerController) -> Dictionary:
	var cfg: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.config))
	var frame_index: int=1
	var frame: Dictionary=cfg.target.frames[frame_index]
	var entry_index: int=0
	var entry: Dictionary=frame.entries[entry_index]
	var anchor: Vector3=FAMILY.vec(frame.start)+FAMILY.vec(frame.tangent)*float(entry.station_m)
	var normal: Vector3=FAMILY.vec(frame.normal)
	var triangles: Array=cfg.local_ground["entry-"+str(frame_index)+"-"+str(entry_index)].top_triangles
	var endpoint: float=-INF
	for triangle: Array in triangles:
		for point: Array in triangle: endpoint=maxf(endpoint,(FAMILY.vec(point)-anchor).dot(normal))
	var outer: Vector3=anchor+normal*(endpoint+1.0)
	var inner: Vector3=anchor+normal*2.8
	var setup := await _settle_player(Vector2(outer.x,outer.z),active_source+"-pedestrian-connection",world,player)
	if not _require(bool(setup.get("ok",false)),"Pedestrian connection setup "+str(setup)): return {"source":active_source,"ok":false,"safe_rest":false,"fatal":true,"connection_setup":setup}
	if not await _rest(world,player,"connection-start"): return {"source":active_source,"ok":false,"safe_rest":false,"fatal":true}
	var inward := await _cross_leg(inner,anchor,normal,"outer-connection-to-entry-path",world,player)
	if not bool(inward.safe_rest) or bool(inward.fatal): return {"source":active_source,"ok":false,"safe_rest":inward.safe_rest,"fatal":true,"inward":inward}
	if not bool(inward.ok):
		player.set_gameplay_enabled(false)
		return {"source":active_source,"ok":false,"safe_rest":true,"fatal":false,"inward":inward,"dependent_return_skipped":true}
	var outward := await _cross_leg(outer,anchor,normal,"entry-path-to-outer-connection",world,player)
	player.set_gameplay_enabled(false)
	var disabled: bool=not bool(player.get("_gameplay_enabled")) and player.velocity==Vector3.ZERO and _released()
	return {"source":active_source,"ok":bool(inward.ok) and bool(outward.ok) and disabled,"safe_rest":outward.safe_rest,"fatal":outward.fatal,"disabled_final":disabled,"inward":inward,"outward":outward}

func _cross_leg(destination: Vector3,anchor: Vector3,normal: Vector3,label: String,world: WorldLoader,player: PlayerController) -> Dictionary:
	var aim := destination
	aim.y=player.global_position.y+2.0
	_aim_camera_at(player,aim)
	var before: int=int(world.get_runtime_evidence().recovery_count)
	var start_index: int=motion_trace.size()
	var arrived := false
	player.set_gameplay_enabled(true)
	Input.action_press("move_forward")
	for i in 240:
		_force_unpaused(player)
		await physics_frame
		_sample(world,player,label,{"path_depth_m":(player.global_position-anchor).dot(normal)})
		if int(world.get_runtime_evidence().recovery_count)!=before: break
		if Vector2(player.global_position.x-destination.x,player.global_position.z-destination.z).length()<0.16:
			arrived=true
			break
	_clear_gameplay_input()
	var rest := await _rest(world,player,label+"-rest")
	var recovery: bool=int(world.get_runtime_evidence().recovery_count)!=before
	var end_depth: float=(player.global_position-anchor).dot(normal)
	var ok: bool=arrived and rest and not recovery and absf(end_depth-(destination-anchor).dot(normal))<0.25
	_require(ok,"Stock pedestrian connection crossing "+label)
	return {"ok":ok,"safe_rest":rest,"fatal":recovery or not rest,"arrived":arrived,"final_depth_m":end_depth,"destination_depth_m":(destination-anchor).dot(normal),"trace_start":start_index,"trace_end":motion_trace.size(),"recovery_delta":int(world.get_runtime_evidence().recovery_count)-before}

func _near_front_anchor(target: Dictionary) -> Vector2:
	return Vector2(target.requested_xz[0],target.requested_xz[1])

func _rear_spray(target: Dictionary,world: WorldLoader,player: PlayerController) -> Dictionary:
	var cfg: Dictionary=JSON.parse_string(FileAccess.get_file_as_string(target.config))
	var frame: Dictionary=cfg.target.frames[4]
	var point: Vector3=FAMILY.vec(frame.start)+FAMILY.vec(frame.tangent)*0.7
	point.y=float(cfg.wall_top_y)-2.55
	var anchor: Vector3=point+FAMILY.vec(frame.normal)*2.0
	var setup: Dictionary=await _settle_player(Vector2(anchor.x,anchor.z),active_source+"-rear-spray",world,player)
	if not _require(bool(setup.get("ok",false)),"Rear spray setup "+str(setup)):return {"ok":false,"safe_rest":false,"fatal":true}
	_aim_camera_at(player,point)
	if not await _rest(world,player,"rear-spray-start"):return {"ok":false,"safe_rest":false,"fatal":true}
	await _wait_for_render(player)
	var hit: Dictionary=_camera_spray_hit(player)
	if not _require(not hit.is_empty() and _derived_object_key_for_collider(hit.collider)=="building:"+active_source+":wall","Rear stock first receiver"):
		player.set_gameplay_enabled(false)
		return {"ok":false,"safe_rest":true,"fatal":true}
	var controller:=player.get_spray_controller()
	var before: int=controller.tag_instances.active_count()
	controller.attempt_spray()
	await process_frame
	var tag: Decal=null
	if controller.tag_instances.get_child_count()>before:tag=controller.tag_instances.get_child(controller.tag_instances.get_child_count()-1) as Decal
	var valid: bool=controller.tag_instances.active_count()==before+1 and tag!=null and tag.cull_mask==2 and str(tag.get_meta("derived_object_key",""))=="building:"+active_source+":wall" and tag.get_meta("source_keys",[])==[active_source] and tag.global_position.distance_to(hit.position)<0.05
	_require(valid,"Rear actual stock decal identity/cull/position")
	var shot: Dictionary=_save_current_view({"id":active_source+"-rear-stock-spray","region":active_source,"intent":"Observed rear receiver stock spray"},output,player,{"source_key":active_source,"phase":"rear-stock-spray","physics_grounded":player.is_on_floor()})
	if shot.get("ok",false):rows.append(shot.metadata)
	var rest: bool=await _rest(world,player,"rear-final")
	player.set_gameplay_enabled(false)
	var disabled: bool=not bool(player.get("_gameplay_enabled")) and player.velocity==Vector3.ZERO and _released()
	return {"ok":valid and rest and disabled,"safe_rest":rest,"fatal":not valid or not rest,"disabled_final":disabled,"first_hit":_v(hit.position),"cull_mask":0 if tag==null else tag.cull_mask}
