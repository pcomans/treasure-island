extends RefCounted
## Source-relative panel-hall facade family; each target provides observed chains.
## Generated source shells remain the backing wall and authority for footprint/roof.
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const TARGETS := {"building:w34313569:wall": "res://game/resources/facades/austin461_observed.json"}

static func matches_record(record: Dictionary) -> bool:
	return TARGETS.has(str(record.get("object_key", "")))

static func build(record: Dictionary) -> Dictionary:
	var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(TARGETS[str(record.object_key)]))
	if not cfg is Dictionary or record.get("source_keys", []) != [cfg.get("source", "")] or record.get("receiver_kind", "") != "building_wall":
		return {"ok":false,"message":"Panel hall exact source configuration required."}
	var root := Node3D.new(); root.name="ObservedPanelHall"
	var materials := {}
	for key: String in cfg.palette:
		var rgb: Array=cfg.palette[key]
		var mat := StandardMaterial3D.new(); mat.albedo_color=Color(rgb[0],rgb[1],rgb[2]); mat.roughness=.9
		materials[key]=mat
	var v: Array=record.vertices
	var top := float(record.top_elevation_m)
	for spec: Dictionary in cfg.chains:
		var first := int(spec.runs[0])*12
		var last := int(spec.runs[-1])*12
		var a := Vector3(v[first],v[first+1],v[first+2])
		var b := Vector3(v[last+3],v[last+4],v[last+5])
		var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n := Vector3(-t.z,0,t.x)
		var length := Vector2(b.x-a.x,b.z-a.z).length()
		var floor_y := minf(a.y,b.y)-.12
		var split := top-4.0
		var openings: Array[Rect2]=[]
		if bool(spec.upper_slots):
			var count := maxi(2,int(round(length/float(spec.bay_width))))
			for i in count:
				var s := length*(i+.5)/count
				openings.append(Rect2(s-.38,top-2.00,.76,1.78))
		if bool(spec.lower_row):
			var start := float(spec.row_start); var end := float(spec.row_end)
			var count := maxi(1,int(round((end-start)/float(spec.bay_width))))
			for i in count:
				var s := start+(end-start)*(i+.5)/count
				openings.append(Rect2(s-.56,floor_y+.48,1.12,split-floor_y-.58))
		# Split the two fields around complete recess bounds, not painted windows.
		for field: Array in [[floor_y,split,"lower"],[split,top-.16,"upper"]]:
			var cuts: Array[float]=[0.0,length]
			for hole: Rect2 in openings:
				if hole.end.y>float(field[0]) and hole.position.y<float(field[1]): cuts.append(hole.position.x); cuts.append(hole.end.x)
			cuts.sort()
			for j in range(cuts.size()-1):
				var left := cuts[j]; var right := cuts[j+1]
				if right-left<.001: continue
				var spans: Array[Vector2]=[Vector2(field[0],field[1])]
				for hole: Rect2 in openings:
					if (left+right)/2.0>hole.position.x and (left+right)/2.0<hole.end.x:
						spans=[]
						if hole.position.y>float(field[0]): spans.append(Vector2(field[0],minf(hole.position.y,field[1])))
						if hole.end.y<float(field[1]): spans.append(Vector2(maxf(hole.end.y,field[0]),field[1]))
				for span: Vector2 in spans:
					if span.y-span.x>.001: _box(root,"PanelField",a,t,n,(left+right)/2.0,(span.x+span.y)/2.0,.16,Vector3(right-left,span.y-span.x,.30),materials[field[2]],"wall")
		for hole: Rect2 in openings:
			if bool(spec.lower_row):
				# Observed lower bays are pale infill behind projecting piers, with
				# only a short dark head. Dimensions are production inference.
				var head_height := .34
				var infill_height := hole.size.y-head_height
				_box(root,"ClosedSlot",a,t,n,hole.get_center().x,hole.position.y+infill_height/2.0,.14,Vector3(hole.size.x,infill_height,.08),materials.lower,"wall")
				_box(root,"ClosedSlot",a,t,n,hole.get_center().x,hole.end.y-head_height/2.0,.035,Vector3(hole.size.x,head_height,.045),materials.recess,"wall")
			else:
				_box(root,"ClosedSlot",a,t,n,hole.get_center().x,hole.get_center().y,.035,Vector3(hole.size.x,hole.size.y,.045),materials.recess,"wall")
			_box(root,"SlotSill",a,t,n,hole.get_center().x,hole.position.y,.22,Vector3(hole.size.x+.10,.09,.34),materials.structure,"detail")
			for s: float in [hole.position.x-.065,hole.end.x+.065]:
				_box(root,"SlotReveal",a,t,n,s,hole.get_center().y,.23,Vector3(.13,hole.size.y,.34),materials.lower,"wall")
		for s: float in [.16,length-.16]:
			_box(root,"TerminalPier",a,t,n,s,(floor_y+top-.16)/2.0,.24,Vector3(.32,top-.16-floor_y,.46),materials.structure,"wall")
		_box(root,"ThinCoping",a,t,n,length/2.0,top-.065,.18,Vector3(length,.13,.52),materials.coping,"detail")
		if bool(spec.get("terminal_projection",false)):
			_box(root,"PaleEndProjection",a,t,n,length-2.10,(floor_y+top-.18)/2.0,.73,Vector3(4.20,top-.18-floor_y,1.48),materials.upper,"wall")
			_box(root,"ProjectionLowerField",a,t,n,length-2.10,(floor_y+split)/2.0,1.49,Vector3(4.20,split-floor_y,.045),materials.lower,"wall")
			_box(root,"ProjectionCap",a,t,n,length-2.10,top-.12,.73,Vector3(4.30,.12,1.57),materials.coping,"detail")
	for key: String in cfg.site:
		var spec: Dictionary=cfg.site[key]
		var points := PackedVector3Array(); var normals:=PackedVector3Array()
		for tri: Array in spec.triangles:
			for p: Array in tri: points.append(Vector3(p[0],p[1],p[2])); normals.append(Vector3.UP)
		if points.is_empty(): root.free(); return {"ok":false,"message":"Panel hall site coverage missing."}
		var arrays: Array=[]; arrays.resize(Mesh.ARRAY_MAX); arrays[Mesh.ARRAY_VERTEX]=points; arrays[Mesh.ARRAY_NORMAL]=normals
		var mesh:=ArrayMesh.new(); mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
		var mat:=StandardMaterial3D.new(); mat.albedo_color=Color(.49,.49,.43); mat.roughness=.97; mesh.surface_set_material(0,mat)
		var node:=MeshInstance3D.new(); node.name=key; node.mesh=mesh; node.set_meta("physical_role","ground_visual"); root.add_child(node)
	var result:=SUPPORT.attach(root,record,record,{})
	if not bool(result.get("ok",false)): return result
	var count:=0; var triangles:=0
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			count+=1; triangles+=(child as MeshInstance3D).mesh.get_faces().size()/3
	return {"ok":true,"node":root,"mesh_instances":count,"surfaces":count,"triangles":triangles}

static func _box(root: Node3D,label:String,a:Vector3,t:Vector3,n:Vector3,s:float,y:float,d:float,size:Vector3,mat:Material,role:String)->void:
	var mesh:=BoxMesh.new(); mesh.size=size; mesh.material=mat
	var node:=MeshInstance3D.new(); node.name=label; node.mesh=mesh
	node.transform=Transform3D(Basis(t,Vector3.UP,n),Vector3(a.x,y,a.z)+t*s+n*d)
	node.set_meta("physical_role",role); node.set_meta("construction_detail",label); root.add_child(node)
