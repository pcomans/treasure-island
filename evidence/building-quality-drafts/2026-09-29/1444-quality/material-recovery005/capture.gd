extends "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/housing-quality-second-pair-2026-09-23/capture.gd"
func _run()->void:
	var ordinary_only:=false
	for arg in OS.get_cmdline_user_args():
		if arg=="--ordinary-only":ordinary_only=true
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output),"Fresh output"):await _finish(null);return
	DirAccess.make_dir_recursive_absolute(output)
	var main:GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world:WorldLoader=main.get_node("WorldRoot")
	var player:PlayerController=main.get_node("Player")
	var ready:Array=[];var errors:Array=[]
	world.world_ready.connect(func(r:Dictionary):ready.append(r))
	world.world_failed.connect(func(c:String,m:String,k:Array):errors.append([c,m,k]))
	root.add_child(main)
	while ready.is_empty() and errors.is_empty():await process_frame
	if not _require(errors.is_empty() and ready.size()==1 and world.is_world_validated(),"World load: %s"%[errors]):await _finish(main);return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var wall:=_record_node_for_key(world,"building:w95934117:wall")
	var roof:=_record_node_for_key(world,"building:w95934117:roof")
	if not _require(wall!=null and roof!=null,"Exact 1444 source pair"):await _finish(main);return
	for owner:Node3D in [wall,roof]:
		if not _require(owner.get_meta("revision_acceptance","")=="pending" and owner.get_meta("old_collision_proxy_retained",true)==false,"Current visible contact owner"):await _finish(main);return
		_native_front_readback(owner)
	var contact_checks:=_collision_readback([wall,roof])
	var contact_flags:Array=[]
	for owner:Node3D in [wall,roof]:
		for body:Node in owner.get_children():
			if not body is StaticBody3D:continue
			for holder:CollisionShape3D in body.get_children():
				contact_flags.append({"body":str(body.name),"shape":str(holder.name),"disabled":holder.disabled,"backface_collision":holder.shape.backface_collision,"ok":not holder.disabled and holder.shape.backface_collision})
	var snapshots:Dictionary={"wall":_snapshot(wall),"roof":_snapshot(roof)}
	var original:Dictionary=_json_file("/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/housing-quality-second-pair-2026-09-23/1444-ceiling-native-diagnostic-001/diagnostic-001/images/receipt.json").before
	# Native snapshot flags are INT; JSON baseline flags are FLOAT. All geometry,
	# transforms and metadata are already exact Variant-byte hex strings.
	var current_geometry:Dictionary=JSON.parse_string(JSON.stringify(_geometry_contacts(snapshots)))
	var original_geometry:Dictionary=JSON.parse_string(JSON.stringify(_geometry_contacts(original)))
	var differences:Array=[]
	_geometry_differences(current_geometry,original_geometry,"",differences)
	var exact:bool=current_geometry==original_geometry
	var comparison:=FileAccess.open(output.path_join("original-contact-comparison.json"),FileAccess.WRITE)
	comparison.store_string(JSON.stringify({"exact_original_geometry_contacts_roles":exact,"current_geometry_contacts":current_geometry,"original_geometry_contacts":original_geometry,"differences":differences,"native_front_readback":native_fronts,"contact_checks":contact_checks,"contact_flags":contact_flags,"prior_failure":_failure,"original_receipt_sha256":"33a573a8512845ebd683d9d6bd4229daf9b703e664478ad1e844ad8ca4eb9632"},"\t"))
	comparison.close()
	if not _require(exact,"Original C2 geometry/contact/role bytes must match") or not _failure.is_empty():await _finish(main);return
	var views:Array=[
		{"id":"1444-01-whole","xz":Vector2(-390.0,-41.0),"aim":Vector3(-366.5,5.7,-46.0)},
		{"id":"1444-02-three-quarter","xz":Vector2(-388.0,-61.0),"aim":Vector3(-367.5,5.7,-47.0)},
		{"id":"1444-03-near","xz":Vector2(-381.0,-42.0),"aim":Vector3(-370.0,5.6,-43.5)}]
	for view:Dictionary in views:
		var settled:=await _settle_player(view.xz,view.id,world,player)
		if not _require(settled.get("ok",false),str(settled)):break
		_aim_camera_at(player,view.aim)
		for frame in 6:_force_unpaused(player);await physics_frame
		if not await _wait_for_render(player):_fail("Render wait");break
		var saved:=_save_current_view({"id":view.id,"region":"1444 whole sheltered opening","intent":"Unaccepted candidate; independent art review required"},output,player,settled.metadata)
		if not _require(saved.get("ok",false),str(saved)):break
		captures.append(saved.metadata)
	if not ordinary_only:
		var plan:Dictionary=_json_file("/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/housing-quality-second-pair-2026-09-23/1444-ceiling-native-diagnostic-001/plan.json")
		var live_camera:Camera3D=player.get_camera();var camera:=Camera3D.new()
		for property:String in ["near","far","keep_aspect","projection","size","frustum_offset","h_offset","v_offset","cull_mask"]:camera.set(property,live_camera.get(property))
		main.add_child(camera);camera.current=true
		for pose:Dictionary in plan.poses:
			camera.fov=float(pose.fov);camera.global_position=_v3(pose.camera)
			camera.look_at(camera.global_position+_v3(pose.forward),Vector3.UP)
			for tick in 8:await process_frame
			await RenderingServer.frame_post_draw
			var image:=root.get_texture().get_image();var path:=output.path_join(str(pose.id)+"-candidate.png")
			_require(image.save_png(path)==OK,"Close PNG saved")
			captures.append({"id":pose.id,"path":path,"camera_transform":var_to_bytes(camera.global_transform).hex_encode(),"projection":var_to_bytes(camera.get_camera_projection()).hex_encode(),"size":[image.get_width(),image.get_height()]})
	_require(captures.size()==(3 if ordinary_only else 5),"Selected ordinary-only3 or full5 views")
	_require(snapshots=={"wall":_snapshot(wall),"roof":_snapshot(roof)},"No runtime product mutation")
	var file:=FileAccess.open(output.path_join("receipt.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"ok":_failure.is_empty(),"failure":_failure,"captures":captures,"selection":"ordinary-only" if ordinary_only else "full-five","completed_close_donor":"capture-002/images/119-candidate.png and588-candidate.png" if ordinary_only else "","snapshots":snapshots,"native_front_readback":native_fronts,"contact_checks":contact_checks,"visibility_bindings":wall.get_meta("shelter_visibility_bindings",[]),"visibility_sha256":wall.get_meta("shelter_visibility_sha256",""),"scope":"1444 isolated current MAIN runtime, early source candidate only; no mechanical/art/release acceptance."},"\t"))
	await _finish(main)

func _geometry_contacts(pair:Dictionary)->Dictionary:
	var result:Dictionary={}
	for key:String in ["wall","roof"]:result[key]=_geometry_node(pair[key])
	return result
func _geometry_node(node:Dictionary)->Dictionary:
	var out:Dictionary={"class":node.get("class"),"transform":node.get("transform"),"children":[]}
	if node.get("class")=="StaticBody3D" or node.get("class")=="CollisionShape3D":return node
	if node.has("surfaces"):
		out["mesh_class"]=node.mesh_class;out["layers"]=node.layers;out["shadow"]=node.shadow;out["metadata"]=node.metadata;out["arrays"]=[]
		for surface:Dictionary in node.surfaces:out.arrays.append(surface.arrays)
	for child:Dictionary in node.get("children",[]):out.children.append(_geometry_node(child))
	return out

# Explain every unequal leaf without excluding fields or changing array order.
func _geometry_differences(current:Variant,original:Variant,path:String,rows:Array)->void:
	if typeof(current)!=typeof(original):
		rows.append({"path":path,"predicate":"same_type","current_type":typeof(current),"original_type":typeof(original)})
		return
	if current is Dictionary:
		for key in current:
			if not original.has(key):rows.append({"path":path+"/"+str(key),"predicate":"original_has_key"})
			else:_geometry_differences(current[key],original[key],path+"/"+str(key),rows)
		for key in original:
			if not current.has(key):rows.append({"path":path+"/"+str(key),"predicate":"current_has_key"})
	elif current is Array:
		if current.size()!=original.size():rows.append({"path":path,"predicate":"same_length","current":current.size(),"original":original.size()})
		for i in mini(current.size(),original.size()):_geometry_differences(current[i],original[i],path+"/"+str(i),rows)
	elif current!=original:rows.append({"path":path,"predicate":"exact_value","current":current,"original":original})
