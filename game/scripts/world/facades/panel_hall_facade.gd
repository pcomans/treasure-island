extends RefCounted
## Source-relative panel-hall facade family; each target provides observed chains.
## Generated source shells remain the backing wall and authority for footprint/roof.
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const TARGETS := {"building:w34313569:wall": "res://game/resources/facades/austin461_observed.json", "building:r133347:wall": "res://game/resources/facades/personnel_support_observed.json"}

static func matches_record(record: Dictionary) -> bool:
	return TARGETS.has(str(record.get("object_key", "")))

static func build(record: Dictionary) -> Dictionary:
	var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(TARGETS[str(record.object_key)]))
	if not cfg is Dictionary or record.get("source_keys", []) != [cfg.get("source", "")] or record.get("receiver_kind", "") != "building_wall":
		return {"ok":false,"message":"Panel hall exact source configuration required."}
	var inferred: Array[Dictionary] = []
	if cfg.has("inferred_opposite"):
		var checked := _austin_schedule(record, cfg)
		if not bool(checked.ok): return checked
		inferred.assign(checked.schedule)
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
		if str(spec.get("family", "")) == "grid_transom":
			_grid_chain(root,a,t,n,length,floor_y,top,spec,materials)
			continue
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
	if cfg.has("roof_screen"):
		_roof_screen(root,top,cfg.roof_screen,materials)
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
	for spec: Dictionary in inferred:
		_austin_run(root, v, top, spec, materials)
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


static func _grid_chain(root:Node3D,a:Vector3,t:Vector3,n:Vector3,length:float,floor_y:float,top:float,spec:Dictionary,m:Dictionary)->void:
	# Complete source-bound exterior chain. Cadence/infill are production inference;
	# the untouched opaque shell remains behind every closed panel.
	var count := maxi(1,int(round(length/float(spec.bay_width))))
	var step := length/count
	var muted_bays: Array[int]=[]
	var solid_bays: Array[int]=[]
	for value: Variant in spec.muted_bays: muted_bays.append(int(value))
	for value: Variant in spec.solid_bays: solid_bays.append(int(value))
	var bottom := top-6.0
	var bands: Array[float]=[floor_y,bottom+1.10,bottom+2.42,bottom+2.96,bottom+4.13,bottom+5.28,top-.20]
	for i in count:
		var center := (i+.5)*step
		for j in range(bands.size()-1):
			var key := "glazing" if j in [1,2,4,5] else "opaque"
			if i in muted_bays and j < 4: key="muted"
			if i in solid_bays: key="opaque"
			_box(root,"GridInfill",a,t,n,center,(bands[j]+bands[j+1])/2.0,.075,Vector3(step-.10,bands[j+1]-bands[j]-.065,.10),m[key],"wall")
		for y: float in bands:
			_box(root,"GridTransom",a,t,n,center,y,.16,Vector3(step,.075,.22),m.frame,"wall")
	for i in range(count+1):
		var u := clampf(i*step,.065,length-.065)
		_box(root,"GridMullion",a,t,n,u,(floor_y+top-.16)/2.0,.17,Vector3(.13,top-.16-floor_y,.24),m.frame,"wall")
	_box(root,"GridRoofEdge",a,t,n,length/2.0,top-.11,.15,Vector3(length,.16,.58),m.frame,"detail")


static func _roof_screen(root:Node3D,top:float,spec:Dictionary,m:Dictionary)->void:
	# A closed rooftop screen, safely outside the protected courtyard hole.
	var a := Vector3(float(spec.center[0]),top,float(spec.center[1]))
	var t := Vector3(.984,0,-.176).normalized()
	var n := Vector3(-t.z,0,t.x)
	var width := float(spec.size[0]); var height := float(spec.size[1]); var depth := float(spec.size[2])
	_box(root,"RoofScreenCore",a,t,n,0,top+height/2.0,0,Vector3(width,height,depth),m.screen,"detail")
	for i in 9:
		var y := top+.12+i*(height-.24)/8.0
		for d:float in [-depth/2.0-.025,depth/2.0+.025]:
			_box(root,"RoofScreenSlat",a,t,n,0,y,d,Vector3(width+.06,.055,.06),m.frame,"detail")
		for u:float in [-width/2.0-.025,width/2.0+.025]:
			_box(root,"RoofScreenSlat",a,t,n,u,y,0,Vector3(.06,.055,depth),m.frame,"detail")
	_box(root,"RoofScreenCap",a,t,n,0,top+height+.045,0,Vector3(width+.14,.09,depth+.14),m.muted,"detail")


static func _austin_schedule(record: Dictionary, cfg: Dictionary) -> Dictionary:
	# Separate inference, never an extension of the observed chains or other instance.
	if str(record.object_key) != "building:w34313569:wall" or cfg.get("source", "") != "w34313569" or record.get("source_keys", []) != ["w34313569"] or record.get("receiver_kind", "") != "building_wall" or cfg.get("chunk", "") != "x_-1__z_-4":
		return {"ok":false,"message":"Austin inference requires its exact wall/source/chunk."}
	var vertices: Array = record.vertices
	if vertices.size() % 12 != 0 or not cfg.inferred_opposite is Array:
		return {"ok":false,"message":"Austin inference requires complete source runs."}
	# The family receives a record rather than a chunk wrapper. Bind its coordinates
	# to the declared canonical chunk before any geometry is constructed.
	for i in range(0, vertices.size(), 3):
		if not is_finite(float(vertices[i])) or not is_finite(float(vertices[i+1])) or not is_finite(float(vertices[i+2])) or float(vertices[i]) < -256.0 or float(vertices[i]) > 0.0 or float(vertices[i+2]) < -1024.0 or float(vertices[i+2]) > -768.0:
			return {"ok":false,"message":"Austin source outside its canonical chunk."}
	var schedule: Array[Dictionary] = []
	var seen: Array[int] = []
	for item: Variant in cfg.inferred_opposite:
		if not item is Dictionary or not item.get("run") is float and not item.get("run") is int:
			return {"ok":false,"message":"Austin inferred run must be numeric."}
		var raw := float(item.run)
		if not is_finite(raw) or raw != floor(raw) or raw < 11.0 or raw > 26.0 or raw >= vertices.size()/12:
			return {"ok":false,"message":"Austin inferred run outside authorized 11–26."}
		var run := int(raw)
		if run in seen or str(item.get("composition", "")) not in ["hall", "solid", "service", "infill"]:
			return {"ok":false,"message":"Austin inference duplicate run or unknown composition."}
		seen.append(run)
		schedule.append({"run":run,"composition":str(item.composition)})
	seen.sort()
	if seen != range(11, 27):
		return {"ok":false,"message":"Austin inference must cover exactly runs 11–26."}
	return {"ok":true,"schedule":schedule}


static func _austin_run(root: Node3D, vertices: Array, top: float, spec: Dictionary, m: Dictionary) -> void:
	# Complete closed assemblies on each actual source segment. No chord across
	# stepped returns; cadence and closed service treatment are production inference.
	var offset: int = spec.run * 12
	var a := Vector3(vertices[offset], vertices[offset+1], vertices[offset+2])
	var b := Vector3(vertices[offset+3], vertices[offset+4], vertices[offset+5])
	var length := Vector2(b.x-a.x, b.z-a.z).length()
	var t := Vector3(b.x-a.x, 0, b.z-a.z).normalized()
	var n := Vector3(-t.z, 0, t.x)
	var split := top-4.0
	var floor_y := minf(a.y,b.y)-.12
	var openings: Array[Rect2] = []
	var mode: String = spec.composition
	if mode == "hall" and length > 6.0:
		var count := maxi(1, int(floor(length/6.0)))
		for i in count:
			var u := length*(i+.5)/count
			openings.append(Rect2(u-.38,top-2.0,.76,1.65))
			# Lower paired pale panels form groups, leaving generous solid wall bays.
			for shift: float in [-.92,.92]:
				openings.append(Rect2(u+shift-.56,split-3.10,1.12,2.80))
	elif mode == "infill" and length > 4.0:
		for u: float in [length*.35,length*.65]:
			openings.append(Rect2(u-.56,split-3.10,1.12,2.80))
	elif mode == "service" and length > 3.0:
		# A closed service leaf, not a source opening or claim of real access.
		openings.append(Rect2(length*.5-.70,floor_y+.18,1.40,2.60))
	# Piecewise source-bottom strips keep the complete field down to local grade.
	var cuts: Array[float] = [0.0,length]
	for i in range(1, int(ceil(length))): cuts.append(length*i/ceil(length))
	for hole: Rect2 in openings: cuts.append(hole.position.x); cuts.append(hole.end.x)
	cuts.sort()
	for j in range(cuts.size()-1):
		var left := cuts[j]; var right := cuts[j+1]
		if right-left < .0001: continue
		var local_floor := minf(lerpf(a.y,b.y,left/length),lerpf(a.y,b.y,right/length))-.12
		for field: Array in [[local_floor,split,"lower"],[split,top-.16,"upper"]]:
			var spans: Array[Vector2] = [Vector2(field[0],field[1])]
			for hole: Rect2 in openings:
				if (left+right)*.5 > hole.position.x and (left+right)*.5 < hole.end.x and hole.end.y > field[0] and hole.position.y < field[1]:
					spans.clear()
					if hole.position.y > field[0]: spans.append(Vector2(field[0],minf(hole.position.y,field[1])))
					if hole.end.y < field[1]: spans.append(Vector2(maxf(hole.end.y,field[0]),field[1]))
			for span: Vector2 in spans:
				if span.y-span.x > .0001:
					var field_left := left
					var field_right := right
					if length > 2.0:
						# Bury only terminal side caps inside the unchanged end piers.
						if left == 0.0: field_left += .04
						if right == length: field_right -= .04
						if spec.run == 24 and left == 0.0 and field[2] == "lower":
							# This terminal's 1.98 mm lower sliver is below local LAND.
							span.x = maxf(span.x,lerpf(a.y,b.y,.14/length)-.14)
					_box(root,"InferredAustinField",a,t,n,(field_left+field_right)*.5,(span.x+span.y)*.5,.16,Vector3(field_right-field_left,span.y-span.x,.30),m[field[2]],"wall")
	for hole: Rect2 in openings:
		var is_upper := hole.position.y > split
		var is_service := mode == "service"
		if is_upper or is_service:
			_box(root,"InferredAustinClosedBack",a,t,n,hole.get_center().x,hole.get_center().y,.035,Vector3(hole.size.x,hole.size.y,.045),m.recess if is_upper else m.structure,"wall")
		else:
			_box(root,"InferredAustinClosedBack",a,t,n,hole.get_center().x,hole.position.y+(hole.size.y-.34)*.5,.12,Vector3(hole.size.x,hole.size.y-.34,.08),m.upper,"wall")
			_box(root,"InferredAustinClosedBack",a,t,n,hole.get_center().x,hole.end.y-.17,.035,Vector3(hole.size.x,.34,.045),m.recess,"wall")
		for u: float in [hole.position.x-.065,hole.end.x+.065]:
			_box(root,"InferredAustinReveal",a,t,n,u,hole.get_center().y,.23,Vector3(.13,hole.size.y,.34),m.upper,"wall")
		_box(root,"InferredAustinSill",a,t,n,hole.get_center().x,hole.position.y,.22,Vector3(hole.size.x+.13,.08,.34),m.structure,"detail")
		if is_service:
			_box(root,"InferredAustinServiceHead",a,t,n,hole.get_center().x,hole.end.y+.12,.28,Vector3(hole.size.x+.40,.24,.48),m.upper,"wall")
	# Broad, pale end divisions and restrained piers establish a hierarchy without
	# adding a fictitious entrance pavilion or changing the retained roof.
	if length > 2.0:
		var pier_width := .40 if mode in ["solid","service"] else .28
		for u: float in [pier_width*.5,length-pier_width*.5]:
			var base := lerpf(a.y,b.y,u/length)-.14
			_box(root,"InferredAustinPier",a,t,n,u,(base+top-.16)*.5,.24,Vector3(pier_width,top-.16-base,.46),m.upper,"wall")
	_box(root,"InferredAustinCoping",a,t,n,length*.5,top-.065,.18,Vector3(length,.13,.52),m.coping,"detail")
