class_name W34313515LiveModules
extends RefCounted
## Reference-derived WSW family and compatible corner return.
## All cadence, projected stairs and dimensions are reversible production inference.
const SOURCE_KEY := "w34313515"
const RECEIVER_KEY := "building:w34313515:wall"
const REGISTRY_PATH := "res://game/resources/facades/w34313515_quality_family.json"
const CALIBRATION := preload("res://game/tests/support/w34313515_module_calibration.gd")
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const FRAME := preload("res://game/resources/materials/world/w34313515/w34313515_frame.tres")

static func matches_record(record: Dictionary) -> bool:
	return str(record.get("object_key", "")) == RECEIVER_KEY and record.get("source_keys", []) == [SOURCE_KEY] and str(record.get("feature_kind", "")) == "building_wall" and str(record.get("receiver_kind", "")) == "building_wall" and str(record.get("collision_kind", "")) == "world_solid" and bool(record.get("opaque", false))

static func build(record: Dictionary) -> Dictionary:
	if not matches_record(record): return _failure("Wrong source receiver.")
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not parsed is Dictionary: return _failure("Missing family configuration.")
	var cfg: Dictionary = parsed
	if cfg.get("source_key") != SOURCE_KEY or cfg.get("receiver_key") != RECEIVER_KEY: return _failure("Wrong family identity.")
	var root := Node3D.new()
	root.name = "W34313515LiveModules"
	var pale := StandardMaterial3D.new()
	pale.albedo_color = Color(0.77,0.765,0.73)
	pale.roughness = 0.85
	var metal := StandardMaterial3D.new()
	metal.albedo_color = Color(0.43,0.45,0.44)
	metal.roughness = 0.65
	var top := float(record.top_elevation_m)
	var base := float(record.flat_base_elevation_m)
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/w34313515_module_calibration.json"))
	for chain: Dictionary in cfg.chains:
		var runs: Array[int] = []
		for value: Variant in chain.runs: runs.append(int(value))
		var allowed: Array = [0,1,2,3,4,5,6,7,8] if str(chain.name) == "WSW" else [43,44,45,46,47]
		if runs != allowed:
			root.free()
			return _failure("Family chain escaped bounded source runs.")
		var v: Array = record.vertices
		var first := int(runs.front()) * 12
		var last := int(runs.back()) * 12
		var origin := Vector3(v[first],0.0,v[first+2])
		var end := Vector3(v[last+3],0.0,v[last+5])
		var tangent := (end-origin).normalized()
		var normal := tangent.cross(Vector3.UP).normalized()
		var generated := Vector3(record.normals[first],0.0,record.normals[first+2])
		if normal.dot(generated)<0.0: normal = -normal
		var basis := Basis(tangent,Vector3.UP,normal)
		var length_m := origin.distance_to(end)
		for value: Variant in runs:
			var offset := int(value)*12
			for k: int in [0,3]:
				var p := Vector3(v[offset+k],0.0,v[offset+k+2])
				if absf((p-origin).dot(normal)) > 0.025:
					root.free()
					return _failure("Source chain is not planar.")
		for i in chain.bays.size():
			var spec: Array = chain.bays[i]
			var contract: Dictionary = registry.module_contract.duplicate(true)
			contract.opening_per_tier_m = [float(spec[1]),1.72]
			contract.pane_count_per_tier = 3 if float(spec[1])>2.0 else 1
			var bay := CALIBRATION._build_bay(contract)
			var placement := Transform3D(basis, origin + tangent*float(spec[0])+normal*0.07+Vector3.UP*(base+5.35))
			for child: Node in bay.get_children():
				var mesh := child as MeshInstance3D
				bay.remove_child(mesh)
				mesh.name = "%s_Bay%02d_%s" % [chain.name,i,mesh.name]
				mesh.transform = placement*mesh.transform
				_tag(mesh,"wall","FamilyGlazing" if "Glass" in str(mesh.name) else "FamilyFrame")
				root.add_child(mesh)
			bay.free()
			for tier: int in range(3):
				_box(root,"%s_Bay%02d_Horizontal%d" % [chain.name,i,tier],basis,origin,Vector3(float(spec[0]),base+2.2+tier*3.15,0.17),Vector3(float(spec[1]),0.055,0.055),FRAME,"wall","FamilyMullion")
		# Broad full-height pale fields are an observed compositional family, not
		# merely narrow piers between an evenly repeated window grid.
		for interval: Array in chain.get("solid_intervals_m", []):
			var lo := float(interval[0]); var hi := float(interval[1])
			_box(root,"%s_SolidField_%s" % [chain.name,str(lo)],basis,origin,Vector3((lo+hi)*0.5,(base+top)*0.5,0.055),Vector3(hi-lo,top-base-0.3,0.06),pale,"wall","FamilySolidField")
		# Bands terminate at the real projecting stack rather than crossing its path.
		var spans: Array = [[0.10,length_m-0.10]]
		if str(chain.name)=="WSW": spans = [[0.10,25.20],[30.80,64.20],[69.80,length_m-0.10]]
		for span: Array in spans:
			for tier: int in [1,2]:
				_box(root,"%s_Band_%s_%d" % [chain.name,str(span[0]),tier],basis,origin,Vector3((float(span[0])+float(span[1]))*0.5,base+tier*3.15,0.15),Vector3(float(span[1])-float(span[0]),0.22,0.25),pale,"wall","FamilyFloorBand")
		for i in chain.bays.size()-1:
			var a := float(chain.bays[i][0]); var b := float(chain.bays[i+1][0])
			var along := (a+b)*0.5
			var in_stack := false
			for anchor: Variant in chain.stacks:
				if absf(along-float(anchor))<3.1: in_stack=true
			if not in_stack:
				_box(root,"%s_Pier%d" % [chain.name,i],basis,origin,Vector3(along,(base+top)*0.5,0.1),Vector3(0.24,top-base-0.25,0.16),pale,"wall","FamilyPier")
		_box(root,str(chain.name)+"RoofEdge",basis,origin,Vector3(length_m*0.5,top-0.12,0.14),Vector3(length_m-0.12,0.24,0.26),pale,"wall","FamilyRoofEdge")
		if str(chain.name)=="WSW":
			for stair: Dictionary in cfg.stairs:
				_build_stack(root,basis,origin,stair,pale,metal,top)
	var support := SUPPORT.attach(root,record,record,{})
	if not bool(support.get("ok",false)): return support
	var topology := _topology(root)
	var metadata := {"source_key":SOURCE_KEY,"receiver_key":RECEIVER_KEY,"placement_role":"production_inference","source_shell_retained":true,"interior_access":false,"observed_runs":[0,1,2,3,4,5,6,7,8],"limited_corner_runs":[43,44,45,46,47],"projected_stairs":true,"independent_review":"pending"}
	for key: String in metadata: root.set_meta(key,metadata[key])
	return {"ok":true,"node":root,"metadata":metadata,"mesh_instances":topology.mesh_instances,"surfaces":topology.surfaces,"triangles":topology.triangles}

static func _build_stack(root: Node3D, basis: Basis, origin: Vector3, cfg: Dictionary, pale: Material, metal: Material, top: float) -> void:
	var anchor := float(cfg.anchor_m)
	var base := float(cfg.base_y_m)
	var label := "Stack%d" % int(anchor)
	# Actual volumetric exterior adaptation: the retained source wall is backing.
	# Landings stop outside it; no invented doorway or interior connection.
	for side: float in [-2.6,2.6]:
		_box(root,label+"Side"+str(side),basis,origin,Vector3(anchor+side,(base+top)*0.5,1.52),Vector3(0.2,top-base,3.0),pale,"detail","StairSidewall")
	_box(root,label+"Cap",basis,origin,Vector3(anchor,top-0.12,1.52),Vector3(5.4,0.24,3.0),pale,"detail","StairCanopy")
	for level: int in range(3):
		var y := base+float(level)*3.15
		if level == 0:
			_box(root,label+"MainLanding0",basis,origin,Vector3(anchor-2.0,y-0.09,0.87),Vector3(1.2,0.18,1.5),pale,"detail","StairLanding")
		else:
			_box(root,label+"MainLanding%d" % level,basis,origin,Vector3(anchor-2.0,y-0.09,1.52),Vector3(1.2,0.18,2.8),pale,"detail","StairLanding")
			_box(root,label+"LandingRail%d" % level,basis,origin,Vector3(anchor-2.0,y+0.55,2.97),Vector3(1.2,1.1,0.055),metal,"detail","StairRail")
		if level<2:
			_box(root,label+"HalfLanding%d" % level,basis,origin,Vector3(anchor+2.0,y+1.575-0.09,1.52),Vector3(1.2,0.18,2.8),pale,"detail","StairLanding")
	for flight: int in range(4):
		var forward := flight%2==0
		var y := base+float(flight)*1.575
		var lane := 0.82 if forward else 2.22
		for step: int in range(10):
			var along := -1.4+(float(step)+0.5)*0.28
			if not forward: along = -along
			var tread_y := y+float(step+1)*0.1575
			_box(root,"%s_Flight%d_Tread%02d" % [label,flight,step],basis,origin,Vector3(anchor+along,tread_y-0.055,lane),Vector3(0.28,0.11,1.10),pale,"stair_visual","StairTread")
		# Reuse the Mersea nosing-plane support approach without changing controls.
		# The support passes through each visible leading tread edge, then the top.
		var sign_x := 1.0 if forward else -1.0
		var bottom_x := anchor-1.68*sign_x
		var top_x := anchor+1.12*sign_x
		var end_x := anchor+1.4*sign_x
		var support_points: Array[Vector3] = [Vector3(bottom_x,y,lane-0.55),Vector3(bottom_x,y,lane+0.55),Vector3(top_x,y+1.575,lane+0.55),Vector3(top_x,y+1.575,lane-0.55),Vector3(end_x,y+1.575,lane+0.55),Vector3(end_x,y+1.575,lane-0.55)]
		_surface(root,"%s_Flight%d_NosingSupport" % [label,flight],basis,origin,support_points,[0,2,1,0,3,2,3,4,2,3,5,4],pale,"stair_support","StairNosingSupport",false)
		# Stringers and rails follow the real flight slope, outside clear walk lane.
		var a := Vector3(anchor+(-1.4 if forward else 1.4),y,lane)
		var b := Vector3(anchor+(1.4 if forward else -1.4),y+1.575,lane)
		for edge: float in [-0.60,0.60]:
			_beam(root,"%s_Flight%d_Stringer%s" % [label,flight,str(edge)],basis,origin,a+Vector3(0,-0.12,edge),b+Vector3(0,-0.12,edge),0.12,0.18,metal,"StairStringer")
			_beam(root,"%s_Flight%d_Rail%s" % [label,flight,str(edge)],basis,origin,a+Vector3(0,1.0,edge),b+Vector3(0,1.0,edge),0.055,0.055,metal,"StairRail")
			for post: int in range(5):
				var p := a.lerp(b,float(post)/4.0)+Vector3(0,0.5,edge)
				_box(root,"%s_Flight%d_Post%s_%d" % [label,flight,str(edge),post],basis,origin,p,Vector3(0.045,1.0,0.045),metal,"detail","StairRail")
	# The ground approach is visible real geometry, draped at its outer edge.
	var land := SUPPORT.land_triangles(["res://generated/world/chunks/x_-1__z_1.json"])
	var approach: Array[Vector3] = []
	for x: float in [anchor-2.6,anchor-1.4]:
		var p := origin+basis*Vector3(x,0.0,2.92)
		var land_y := SUPPORT.height_at(Vector2(p.x,p.z),land.triangles)
		approach.append(Vector3(x,land_y+0.05,2.92))
	approach.append(Vector3(anchor-1.4,base,1.62))
	approach.append(Vector3(anchor-2.6,base,1.62))
	_surface(root,label+"GroundApproach",basis,origin,approach,[0,2,1,0,3,2],pale,"detail","StairGroundApproach",true)
	for child: Node in root.get_children():
		var name := str(child.name)
		if not name.begins_with(label): continue
		for flight: int in range(4):
			var flight_id := "%s_Flight%d" % [label,flight]
			if name.begins_with(flight_id+"_"): child.set_meta("stair_flight_id",flight_id)
		if "MainLanding" in name:
			var level := int(name.right(1))
			var ids: Array[String] = []
			if level>0: ids.append("%s_Flight%d" % [label,level*2-1])
			if level<2: ids.append("%s_Flight%d" % [label,level*2])
			child.set_meta("stair_flight_ids",ids)
		if "HalfLanding" in name:
			var level := int(name.right(1))
			child.set_meta("stair_flight_ids",["%s_Flight%d" % [label,level*2],"%s_Flight%d" % [label,level*2+1]])
		if "GroundApproach" in name: child.set_meta("stair_flight_id",label+"_Flight0")
	# Supports descend through the visible area skin to colliding LAND.
	for along: float in [-2.45,2.45]:
		for depth: float in [0.25,2.8]:
			var bottom := float(cfg.land_min_m)-0.08
			_box(root,"%s_Column%s_%s" % [label,str(along),str(depth)],basis,origin,Vector3(anchor+along,(bottom+base+6.3)*0.5,depth),Vector3(0.18,base+6.3-bottom,0.18),pale,"detail","StairColumn")

static func _surface(root: Node3D, label: String, basis: Basis, origin: Vector3, points: Array[Vector3], indices: Array, material: Material, role: String, detail: String, shown: bool) -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# Godot front faces are clockwise: upward-facing sheets have cross Y < 0.
	# Normalize both flight directions and the visible ground approach alike.
	for i in range(0,indices.size(),3):
		var a := points[int(indices[i])]
		var b := points[int(indices[i+1])]
		var c := points[int(indices[i+2])]
		if (b-a).cross(c-a).y > 0.0:
			var swap := b
			b=c
			c=swap
		st.add_vertex(a)
		st.add_vertex(b)
		st.add_vertex(c)
	st.generate_normals()
	var node := MeshInstance3D.new()
	node.name=label
	node.mesh=st.commit()
	node.transform=Transform3D(basis,origin)
	node.material_override=material
	node.visible=shown
	_tag(node,role,detail)
	root.add_child(node)

static func _beam(root: Node3D, label: String, basis: Basis, origin: Vector3, a: Vector3, b: Vector3, width: float, height: float, material: Material, detail: String) -> void:
	var delta := b-a
	var direction := delta.normalized()
	var local_basis := Basis(direction,Vector3(-direction.y,direction.x,0.0),Vector3.BACK)
	var node := MeshInstance3D.new()
	node.name=label
	var mesh := BoxMesh.new()
	mesh.size=Vector3(delta.length(),height,width)
	node.mesh=mesh
	node.material_override=material
	var midpoint := (a+b)*0.5
	node.transform=Transform3D(basis*local_basis,origin+basis*midpoint)
	_tag(node,"detail",detail)
	root.add_child(node)

static func _box(root: Node3D, label: String, basis: Basis, origin: Vector3, center: Vector3, size: Vector3, material: Material, role: String, detail: String) -> void:
	var node := MeshInstance3D.new()
	node.name=label
	var mesh := BoxMesh.new()
	mesh.size=size
	node.mesh=mesh
	node.material_override=material
	node.transform=Transform3D(basis,origin+basis.x*center.x+basis.z*center.z+Vector3.UP*center.y)
	_tag(node,role,detail)
	root.add_child(node)

static func _tag(node: MeshInstance3D, role: String, detail: String) -> void:
	node.set_meta("physical_role",role)
	node.set_meta("construction_detail",detail)
	node.set_meta("source_keys",[SOURCE_KEY])
	node.set_meta("derived_object_key",RECEIVER_KEY)
	node.set_meta("placement_status","production_inference")

static func _topology(node: Node) -> Dictionary:
	var result := {"mesh_instances":0,"surfaces":0,"triangles":0}
	if node is MeshInstance3D:
		var mesh := (node as MeshInstance3D).mesh
		result={"mesh_instances":1,"surfaces":mesh.get_surface_count(),"triangles":mesh.get_faces().size()/3}
	for child: Node in node.get_children():
		var count := _topology(child)
		for key: String in result: result[key]+=int(count[key])
	return result

static func _failure(message: String) -> Dictionary:
	return {"ok":false,"code":"w34313515_quality_family","message":message,"source_keys":[SOURCE_KEY]}
