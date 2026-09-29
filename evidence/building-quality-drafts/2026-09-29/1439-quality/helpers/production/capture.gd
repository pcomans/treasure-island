extends "res://game/tests/rendered_visual_evidence_capture.gd"
var output := ""
var captures:Array=[]
var attachment:Dictionary={}
var native_snapshots:Dictionary={}
var native_fronts:Array=[]
var current_checks:Dictionary={}
const SUPPORT = preload("res://game/scripts/world/facades/housing_quality_support.gd")
const PRIOR_1439 := "/Volumes/Macintosh_HD/Users/user302070/Documents/Codex/2026-09-08/start-from-commit-f377dcac-and-read/work/1439-from-scratch-2026-09-23/design-002/images/geometry-material-native.json"
func _initialize()->void:
	create_timer(240.0,true,false,true).timeout.connect(func(): _fail("Study timeout"); quit(1))
	call_deferred("_run")
func _run()->void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--output="):output=arg.trim_prefix("--output=")
	if not _require(not output.is_empty() and not DirAccess.dir_exists_absolute(output),"Fresh output required"):await _finish(null);return
	DirAccess.make_dir_recursive_absolute(output)
	var main:GameMain=(load("res://game/scenes/main.tscn") as PackedScene).instantiate()
	var world:WorldLoader=main.get_node("WorldRoot")
	var player:PlayerController=main.get_node("Player")
	var ready:Array=[];var errors:Array=[]
	world.world_ready.connect(func(r:Dictionary):ready.append(r))
	world.world_failed.connect(func(c:String,m:String,k:Array):errors.append([c,m,k]))
	root.add_child(main)
	var start:=Time.get_ticks_msec()
	while ready.is_empty() and errors.is_empty() and Time.get_ticks_msec()-start<45000:await process_frame
	if not _require(errors.is_empty() and ready.size()==1 and world.is_world_validated(),"World load failed %s"%[errors]):await _finish(main);return
	(main.get_node("Interface/HUD") as GameHUD).hide()
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	var targets := [{"number":"1439","source":"w95934144","views":[
		{"id":"01-whole","xz":Vector2(-281.0,30.0),"aim":Vector3(-287.0,6.4,11.0)},
		{"id":"02-three-quarter","xz":Vector2(-268.0,23.0),"aim":Vector3(-286.0,6.4,10.0)},
		{"id":"03-near","xz":Vector2(-284.0,22.0),"aim":Vector3(-288.0,6.1,13.0)}]}]
	for target: Dictionary in targets:
		var wall := _record_node_for_key(world,"building:"+str(target.source)+":wall")
		var roof := _record_node_for_key(world,"building:"+str(target.source)+":roof")
		if not _require(wall != null and roof != null,"Actual dispatched target pair absent"): break
		var attachment_row: Dictionary = {"number":target.number,"owners":[],"meshes":0,"shapes":0,"spray_wall_shapes":0,"roof_shapes":0,"detail_shapes":0,"ground_visuals":0}
		for owner: Node3D in [wall,roof]:
			if not _require(str(owner.get_meta("revision_acceptance","")) == "pending" and owner.get_meta("old_collision_proxy_retained",true) == false,"Expected pending actual replacement, no old proxy"): break
			native_snapshots[str(owner.get_meta("derived_object_key"))]=_snapshot(owner)
			_native_front_readback(owner)
			attachment_row.owners.append({"path":str(owner.get_path()),"key":owner.get_meta("derived_object_key"),"art_sha256":owner.get_meta("reviewed_art_sha256")})
			for node: Node in owner.find_children("*","",true,false):
				if node is MeshInstance3D:
					attachment_row.meshes += 1
					if str(node.get_meta("physical_role","")) == "ground_visual":attachment_row.ground_visuals += 1
				if node is CollisionShape3D:
					attachment_row.shapes += 1
					var role := str(node.shape.get_meta("physical_role",""))
					if role == "wall":attachment_row.spray_wall_shapes += 1
					elif role == "roof":attachment_row.roof_shapes += 1
					elif role == "detail":attachment_row.detail_shapes += 1
					else:_fail("Unclassified collision shape")
		if not _require(attachment_row.spray_wall_shapes > 0 and attachment_row.roof_shapes > 0 and attachment_row.detail_shapes > 0,"Current shell contacts incomplete"):break
		attachment[str(target.number)] = attachment_row
		attachment_row.site_readback = _site_readback(str(target.number))
		current_checks[str(target.number)]={"contacts":_collision_readback([wall,roof]),"reviewed_art":_compare_1439_render([wall,roof])}
		for v: Dictionary in target.views:
			var id: String = str(target.number)+"-"+str(v.id)
			var settled := await _settle_player(v.xz,id,world,player)
			if not _require(settled.get("ok",false),str(settled)):break
			_aim_camera_at(player,v.aim)
			for frame in 6:_force_unpaused(player);await physics_frame
			if not await _wait_for_render(player):_fail("Render wait");break
			var cam := player.get_camera()
			var hit := _ground_hit(Vector2(cam.global_position.x,cam.global_position.z),player)
			var row: Dictionary = {"id":id,"region":str(target.number)+" current whole building","intent":"Actual live pending whole-building replacement"}
			var metadata: Dictionary = settled.metadata.duplicate(true)
			metadata.merge({"requested_xz":[v.xz.x,v.xz.y],"aim":[v.aim.x,v.aim.y,v.aim.z],"camera_fov":cam.fov,"camera_ground_clearance":cam.global_position.y-hit.position.y if not hit.is_empty() else -999.0},true)
			var saved := _save_current_view(row,output,player,metadata)
			if not _require(saved.get("ok",false),str(saved)):break
			captures.append(saved.metadata)
	_require(captures.size() == 3,"Complete1439 three-view set required")
	var route_contacts:Array=await _threshold_routes(world,player)
	var file:=FileAccess.open(output.path_join("receipt.json"),FileAccess.WRITE)
	file.store_string(JSON.stringify({"ok":_failure.is_empty(),"failure":_failure,"captures":captures,"attachment":attachment,"actual_target_snapshots":native_snapshots,"native_front_readback":native_fronts,"current_native_checks":current_checks,"threshold_route_diagnostics":route_contacts,"scope":"Actual dispatch and geometry-contact capture; pending independent source/mechanics, visual, candidate and release acceptance; historical 34/213 unchanged"},"\t"))
	await _finish(main)

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
			rows.append({"geometry":geometry,"materials":materials,"fit_detail":str(mesh.get_meta("construction_detail",""))})
	return JSON.parse_string(JSON.stringify(rows)) as Array

func _compare_1439_render(owners:Array)->Dictionary:
	var prior:Dictionary=_json_file(PRIOR_1439)
	var expected:Array=[]
	var changed_prior_keys:Array[String]=["17","45","71","83","180","181","182","183","185","188","189","190","191","193"]
	var changed_prior:Array=[]
	for key:String in prior.geometry:
		var geometry:Dictionary=prior.geometry[key].duplicate(true)
		if str(geometry.get("class",""))!="MeshInstance3D":continue
		geometry.erase("layers") # Production receiver layers are checked against physical roles separately.
		var materials:Array=[]
		for surface in geometry.surfaces.size():materials.append(prior.materials[key+"/surface"+str(int(surface))])
		if key in changed_prior_keys:changed_prior.append({"prior_key":key,"geometry":geometry,"materials":materials})
		else:expected.append({"geometry":geometry,"materials":materials})
	var current:Array=_render_rows(owners);var remaining:Array=expected.duplicate(true);var unmatched:Array=[];var changed_current:Array=[]
	for row:Dictionary in current:
		var fit:bool=str(row.get("fit_detail",""))=="1439_grounded_loggia_fit"
		row.erase("fit_detail")
		if fit:
			changed_current.append(row)
			continue
		var index:=remaining.find(row)
		if index<0:unmatched.append(row)
		else:remaining.remove_at(index)

	var result:Dictionary={"changed_prior":changed_prior,"changed_current":changed_current,"expected_meshes":expected.size(),"current_meshes":current.size(),"unmatched_current":unmatched,"missing_prior":remaining,"unchanged_render_streams_transforms_and_full_materials_equal":unmatched.is_empty() and remaining.is_empty(),"excluded_from_render_join":["study collision hierarchy replaced by exact current role contacts","render receiver layers separately role-checked","14 specified former lower-contact meshes replaced by10 tagged lower-contact meshes; all retained214 exact including roof and upper facade"],"current":current}
	_require(current.size()==224 and expected.size()==214 and changed_prior.size()==14 and changed_current.size()==10 and result.unchanged_render_streams_transforms_and_full_materials_equal,"Exact1439 unchanged214 render streams/materials plus declared14old-to10ground-contact meshes")
	return result

func _collision_readback(owners:Array)->Dictionary:
	var rows:Array=[];var bodies:=0;var shapes:=0
	for owner:Node3D in owners:
		var by_role:Dictionary={"wall":[],"detail":[],"roof":[]}
		for node:Node in owner.get_children():
			if node is MeshInstance3D:
				var role:String=str(node.get_meta("physical_role",""))
				if role=="ground_visual":continue
				var faces:=PackedVector3Array();var raw:PackedVector3Array=node.mesh.get_faces()
				for i in range(0,raw.size(),3):
					var a:Vector3=node.transform*raw[i];var b:Vector3=node.transform*raw[i+1];var c:Vector3=node.transform*raw[i+2]
					if (b-a).cross(c-a).length_squared()>=0.000000000001:faces.append_array(PackedVector3Array([a,b,c]))
				if not faces.is_empty():by_role[role].append({"mesh":str(node.name),"faces":faces})
				_require(node.layers==(3 if role=="wall" else 1),"Exact role-specific receiver render layer")
		for node:Node in owner.get_children():
			if not node is StaticBody3D:continue
			bodies+=1;var role:String=str(node.get_meta("physical_role",""));var expected:Array=by_role[role]
			_require(node.collision_layer==5 and node.is_in_group("spray_receiver_wall")== (role=="wall"),"Current role collision/receiver ownership")
			_require(node.get_child_count()==expected.size(),"No duplicate or missing current contact shape")
			for i in mini(node.get_child_count(),expected.size()):
				var shape_node:=node.get_child(i) as CollisionShape3D;shapes+=1
				var same:bool=shape_node!=null and shape_node.shape is ConcavePolygonShape3D and shape_node.shape.get_faces()==expected[i].faces
				rows.append({"role":role,"mesh":expected[i].mesh,"shape":str(shape_node.name),"exact_faces":same,"triangles":expected[i].faces.size()/3})
				_require(same and not shape_node.disabled and shape_node.shape.backface_collision,"Visible nondegenerate triangles exactly own current contact")
	_require(bodies==3,"Exactly three classified bodies; no study collision stack")
	return {"bodies":bodies,"shapes":shapes,"rows":rows}

func _site_readback(number:String)->Dictionary:
	var config_path:String="res://game/resources/facades/chinook_1439_quality_revision.json"
	var cfg:Dictionary=_json_file(config_path)
	var land:Dictionary=SUPPORT.land_triangles(cfg.ground_chunks)
	var source:Dictionary=_json_file("res://generated/world/chunks/x_-2__z_0.json")
	var rows:Array=[]
	for record:Dictionary in source.records:
		if str(record.object_key)!="building:w95934144:wall":continue
		var v:Array=record.vertices
		for i in range(0,v.size(),12):
			var a:=Vector3(v[i],v[i+1],v[i+2]);var b:=Vector3(v[i+3],v[i+4],v[i+5]);var midpoint:Vector3=(a+b)*0.5
			var ground_y:float=SUPPORT.height_at(Vector2(midpoint.x,midpoint.z),land.triangles)
			_require(is_finite(ground_y),"Actual bound land covers source edge")
			rows.append({"run":i/12,"a":_visibility_v3(a),"b":_visibility_v3(b),"source_midpoint_y":midpoint.y,"colliding_land_y":ground_y,"flat_base_y":record.flat_base_elevation_m,"flat_base_minus_land":float(record.flat_base_elevation_m)-ground_y})
	return {"source_edges":rows,"land_ok":land.ok,"land_triangles":land.triangles.size(),"land_chunks":cfg.ground_chunks,"scope":"Frozen source edge versus actual consumed colliding-land triangles. Full lower-closure mesh/contact arrays retained separately; visible-area overlays are not substituted for land."}

# Diagnostic stock-input attempts after the first three originals survive.
# A raised threshold may block entry; record destination rather than assert success.
func _threshold_routes(world:WorldLoader,player:PlayerController)->Array:
	var rows:Array=[]
	var completed_routes:int=0
	var origin:=Vector3(-297.278,3.536,17.494)
	var along:Vector3=(Vector3(-274.662,3.536,5.972)-origin).normalized()
	var outward:=Vector3(-along.z,0,along.x)
	for station:float in [4.625,16.05]:
		var mouth:Vector3=origin+along*station
		var start:Vector3=mouth+outward*3.0
		var settled:Dictionary=await _settle_player(Vector2(start.x,start.z),"1439-threshold-"+str(station),world,player)
		var row:Dictionary={"station":station,"settled":settled,"grounded_loggia_fit":"intact LAND; old raised floor/bottom return/mouth strip removed","samples":[]}
		rows.append(row)
		if not _require(bool(settled.get("ok",false)),"1439 threshold route settlement failed: "+str(station)):
			row["route_complete"]=false
			continue
		player.set_gameplay_enabled(true)
		row["enabled_before_first_physics"]={"gameplay_enabled":bool(player.get("_gameplay_enabled")),"physics_processing":player.is_physics_processing(),"position":_visibility_v3(player.global_position)}
		_require(row.enabled_before_first_physics.gameplay_enabled and row.enabled_before_first_physics.physics_processing,"Stock player enabled before threshold physics/input")
		_aim_camera_at(player,mouth-outward*2.0+Vector3.UP*1.0)
		for frame in 6:_force_unpaused(player);await physics_frame
		for action:String in ["move_forward","move_back"]:
			row[action+"_start"]=_visibility_v3(player.global_position)
			_clear_gameplay_input();Input.action_press(action)
			for frame in 70:
				_force_unpaused(player);await physics_frame
				var contacts:Array=[]
				for i in player.get_slide_collision_count():
					var hit:KinematicCollision3D=player.get_slide_collision(i)
					var body:Node=hit.get_collider() as Node
					contacts.append({"body":str(body.get_path()) if body!=null else "","key":str(body.get_meta("derived_object_key","")) if body!=null else "","role":str(body.get_meta("physical_role","")) if body!=null else "","position":_visibility_v3(hit.get_position()),"normal":_visibility_v3(hit.get_normal())})
				row.samples.append({"action":action,"frame":frame,"position":_visibility_v3(player.global_position),"velocity":_visibility_v3(player.velocity),"on_floor":player.is_on_floor(),"mouth_depth":(player.global_position-mouth).dot(outward),"gameplay_enabled":bool(player.get("_gameplay_enabled")),"physics_processing":player.is_physics_processing(),"input_strength":Input.get_action_strength(action),"contacts":contacts})
			_clear_gameplay_input()
			for frame in 12:_force_unpaused(player);await physics_frame
			row[action+"_destination"]=_visibility_v3(player.global_position)
			row[action+"_destination_state"]={"velocity":_visibility_v3(player.velocity),"on_floor":player.is_on_floor(),"gameplay_enabled":bool(player.get("_gameplay_enabled")),"physics_processing":player.is_physics_processing(),"input_released":Input.get_action_strength(action)==0.0}
		_clear_gameplay_input()
		var forward_count:int=0;var back_count:int=0;var active_samples:bool=true
		for sample:Dictionary in row.samples:
			if sample.action=="move_forward":forward_count+=1
			if sample.action=="move_back":back_count+=1
			active_samples=active_samples and bool(sample.gameplay_enabled) and bool(sample.physics_processing) and float(sample.input_strength)>0.0
		var complete:bool=forward_count==70 and back_count==70 and active_samples and row.has("move_forward_destination_state") and row.has("move_back_destination_state")
		var min_depth:float=INF
		for sample:Dictionary in row.samples:
			if sample.action=="move_forward":min_depth=minf(min_depth,float(sample.mouth_depth))
		var destination:Array=row.get("move_back_destination",[0,0,0])
		var retreat_depth:float=(Vector3(destination[0],destination[1],destination[2])-mouth).dot(outward)
		row["minimum_forward_depth"]=min_depth;row["retreat_depth"]=retreat_depth
		row["entered_exterior_recess"]=min_depth< -0.60
		row["returned_to_exterior"]=retreat_depth>2.0
		_require(row.entered_exterior_recess and row.returned_to_exterior,"Both grounded recess entry and retreat required after physical fit correction")
		row["route_complete"]=complete
		row["forward_samples"]=forward_count;row["back_samples"]=back_count
		row["outcome_scope"]="Completed stock-input attempt; threshold entry may be blocked. Inspect recorded actual destinations and contacts, not sample count alone."
		if _require(complete,"Both complete active 70-frame threshold phases and actual destinations required"):completed_routes+=1
	_require(rows.size()==2 and completed_routes==2,"Two successfully settled, complete active threshold route attempts required")
	return rows
