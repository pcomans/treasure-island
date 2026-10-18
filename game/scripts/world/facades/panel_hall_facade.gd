extends RefCounted
## Source-relative panel-hall facade family; each target provides observed chains.
## Generated source shells remain the backing wall and authority for footprint/roof.
const SUPPORT := preload("res://game/scripts/world/facades/housing_quality_support.gd")
const TARGETS := {"building:w34313569:wall": "res://game/resources/facades/austin461_observed.json", "building:r133347:wall": "res://game/resources/facades/personnel_support_observed.json", "building:w34313521:wall": "res://game/resources/facades/job_corps_368_observed.json", "building:w34313546:wall": "res://game/resources/facades/building_202_observed.json", "building:w34313528:wall": "res://game/resources/facades/panel_hall_528_observed.json", "building:w34313512:wall": "res://game/resources/facades/panel_hall_449_observed.json", "building:w110188516:wall": "res://game/resources/facades/panel_hall_516_observed.json"}

static func matches_record(record: Dictionary) -> bool:
	return TARGETS.has(str(record.get("object_key", "")))

static func build(record: Dictionary) -> Dictionary:
	var cfg: Variant = JSON.parse_string(FileAccess.get_file_as_string(TARGETS[str(record.object_key)]))
	if not cfg is Dictionary or record.get("source_keys", []) != [cfg.get("source", "")] or record.get("receiver_kind", "") != "building_wall":
		return {"ok":false,"message":"Panel hall exact source configuration required."}
	var v: Array=record.vertices
	var top := float(record.top_elevation_m)
	for spec: Dictionary in cfg.chains:
		var problem := _chain_problem(spec,v,top)
		if problem != "":
			return {"ok":false,"message":"Panel hall chain %s: %s" % [str(spec.get("runs",[])),problem]}
	var root := Node3D.new(); root.name="ObservedPanelHall"
	var materials := {}
	for key: String in cfg.palette:
		var rgb: Array=cfg.palette[key]
		var mat := StandardMaterial3D.new(); mat.albedo_color=Color(rgb[0],rgb[1],rgb[2]); mat.roughness=.9
		materials[key]=mat
	for spec: Dictionary in cfg.chains:
		var first := int(spec.runs[0])*12
		var last := int(spec.runs[-1])*12
		var a := Vector3(v[first],v[first+1],v[first+2])
		var b := Vector3(v[last+3],v[last+4],v[last+5])
		var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n := Vector3(-t.z,0,t.x)
		var length := Vector2(b.x-a.x,b.z-a.z).length()
		var floor_y := minf(a.y,b.y)-.12
		# Opt-in keys (split_below_top, slot_size, slot_top_offset, split_fascia, storefronts);
		# absent keys keep the original Bldg 461 / 550 4th St geometry exactly.
		var split := top-float(spec.get("split_below_top",4.0))
		if str(spec.get("family", "")) == "grid_transom":
			_grid_chain(root,a,t,n,length,floor_y,top,spec,materials)
			continue
		var openings: Array[Rect2]=[]
		if bool(spec.upper_slots):
			var count := maxi(2,int(round(length/float(spec.bay_width))))
			for i in count:
				var s := length*(i+.5)/count
				if spec.has("slot_size") or spec.has("slot_top_offset"):
					var size: Array=spec.get("slot_size",[.76,1.78])
					var slot_top := top-float(spec.get("slot_top_offset",.22))
					openings.append(Rect2(s-float(size[0])/2.0,slot_top-float(size[1]),float(size[0]),float(size[1])))
				else:
					openings.append(Rect2(s-.38,top-2.00,.76,1.78))
		if bool(spec.lower_row):
			var start := float(spec.row_start); var end := float(spec.row_end)
			var count := maxi(1,int(round((end-start)/float(spec.bay_width))))
			for i in count:
				var s := start+(end-start)*(i+.5)/count
				openings.append(Rect2(s-.56,floor_y+.48,1.12,split-floor_y-.58))
		# Storefront ranges are glazed lower bays [start,end] metres along the chain.
		var fronts: Array[Rect2]=[]
		for range_value: Variant in spec.get("storefronts",[]):
			var r: Array=range_value
			fronts.append(Rect2(float(r[0]),floor_y+.10,float(r[1])-float(r[0]),split-.50-floor_y))
		# Infilled or boarded openings [start,end,height] metres: flush panels in palette
		# "infill" (default "lower"). Positions and sizes are production inference.
		var panels: Array[Rect2]=[]
		for panel_value: Variant in spec.get("infill_panels",[]):
			var p: Array=panel_value
			panels.append(Rect2(float(p[0]),floor_y+.10,float(p[1])-float(p[0]),float(p[2])))
		# Optional rows of dark slots hung under the split, for lower windows or transoms:
		# [{"size":[w,h],"offset":below_split,"bay":b,"range":[start,end]}]. Production inference.
		var split_openings: Array[Rect2]=[]
		for row_value: Variant in spec.get("split_slots",[]):
			var row: Dictionary=row_value
			var span: Array=row.get("range",[0.0,length])
			var row_count := maxi(1,int(round((float(span[1])-float(span[0]))/float(row["bay"]))))
			var slot_top := split-float(row["offset"])
			for i in row_count:
				var s := float(span[0])+(float(span[1])-float(span[0]))*(i+.5)/row_count
				split_openings.append(Rect2(s-float(row["size"][0])/2.0,slot_top-float(row["size"][1]),float(row["size"][0]),float(row["size"][1])))
		var cut_holes: Array[Rect2]=openings.duplicate()
		cut_holes.append_array(fronts)
		cut_holes.append_array(panels)
		cut_holes.append_array(split_openings)
		# Split the two fields around complete recess bounds, not painted windows.
		for field: Array in [[floor_y,split,"lower"],[split,top-.16,"upper"]]:
			var cuts: Array[float]=[0.0,length]
			for hole: Rect2 in cut_holes:
				if hole.end.y>float(field[0]) and hole.position.y<float(field[1]): cuts.append(hole.position.x); cuts.append(hole.end.x)
			cuts.sort()
			for j in range(cuts.size()-1):
				var left := cuts[j]; var right := cuts[j+1]
				if right-left<.001: continue
				var spans: Array[Vector2]=[Vector2(field[0],field[1])]
				for hole: Rect2 in cut_holes:
					# Every hole that reaches into this field is cut out of the remaining spans,
					# so stacked holes (a transom over a roll-up door) both stay open.
					if (left+right)/2.0>hole.position.x and (left+right)/2.0<hole.end.x and hole.end.y>float(field[0]) and hole.position.y<float(field[1]):
						var kept: Array[Vector2]=[]
						for span: Vector2 in spans:
							if hole.position.y>span.x: kept.append(Vector2(span.x,minf(hole.position.y,span.y)))
							if hole.end.y<span.y: kept.append(Vector2(maxf(hole.end.y,span.x),span.y))
						spans=kept
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
		for hole: Rect2 in split_openings:
			_box(root,"ClosedSlot",a,t,n,hole.get_center().x,hole.get_center().y,.035,Vector3(hole.size.x,hole.size.y,.045),materials.recess,"wall")
			_box(root,"SlotSill",a,t,n,hole.get_center().x,hole.position.y,.22,Vector3(hole.size.x+.10,.09,.34),materials.structure,"detail")
			for s: float in [hole.position.x-.065,hole.end.x+.065]:
				_box(root,"SlotReveal",a,t,n,s,hole.get_center().y,.23,Vector3(.13,hole.size.y,.34),materials.lower,"wall")
		# Observed storefronts: recessed dark glazing, pilasters about every 3 m and a fascia
		# over the range. Positions and dimensions are production inference.
		for front: Rect2 in fronts:
			_box(root,"StorefrontGlazing",a,t,n,front.get_center().x,front.get_center().y,.035,Vector3(front.size.x,front.size.y,.045),materials.recess,"wall")
			var bays := maxi(1,int(round(front.size.x/3.0)))
			for i in bays+1:
				_box(root,"StorefrontPilaster",a,t,n,front.position.x+front.size.x*i/bays,(floor_y+split)/2.0,.22,Vector3(.34,split-floor_y,.40),materials.get("pilaster",materials.structure),"wall")
			_box(root,"StorefrontFascia",a,t,n,front.get_center().x,split-.22,.30,Vector3(front.size.x+.60,.44,.56),materials.get("fascia",materials.coping),"detail")
		for panel: Rect2 in panels:
			_box(root,"InfillPanel",a,t,n,panel.get_center().x,panel.get_center().y,.035,Vector3(panel.size.x,panel.size.y,.045),materials.get("infill",materials.lower),"wall")
		if bool(spec.get("split_fascia",false)):
			_box(root,"SplitFascia",a,t,n,length/2.0,split-.12,.30,Vector3(length,.30,.48),materials.get("fascia",materials.coping),"detail")
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
	var result:=SUPPORT.attach(root,record,record,{})
	if not bool(result.get("ok",false)): return result
	var count:=0; var triangles:=0
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			count+=1; triangles+=(child as MeshInstance3D).mesh.get_faces().size()/3
	return {"ok":true,"node":root,"mesh_instances":count,"surfaces":count,"triangles":triangles}

## Opt-in chain data is checked before any geometry exists, so a malformed entry
## fails the build like a source mismatch instead of making negative or stray boxes.
static func _chain_problem(spec: Dictionary,v: Array,top: float)->String:
	var first := int(spec.runs[0])*12
	var last := int(spec.runs[-1])*12
	var length := Vector2(float(v[last+3])-float(v[first]),float(v[last+5])-float(v[first+2])).length()
	var floor_y := minf(float(v[first+1]),float(v[last+4]))-.12
	if spec.has("slot_size") and (not _numbers(spec.slot_size,2) or float(spec.slot_size[0])<=0.0 or float(spec.slot_size[1])<=0.0):
		return "slot_size needs two positive numbers"
	if spec.has("slot_top_offset") and (not _numbers([spec.slot_top_offset],1) or float(spec.slot_top_offset)<0.0):
		return "slot_top_offset must be a number of at least 0"
	if spec.has("split_below_top") and (not _numbers([spec.split_below_top],1) or float(spec.split_below_top)<=0.0):
		return "split_below_top must be a positive number"
	var split := top-float(spec.get("split_below_top",4.0))
	for key: String in ["storefronts","infill_panels"]:
		var entries: Variant=spec.get(key,[])
		if not entries is Array:
			return key+" must be a list"
		var count := 3 if key=="infill_panels" else 2
		for entry: Variant in entries:
			if not _numbers(entry,count):
				return "%s entries need %d numbers" % [key,count]
			if float(entry[0])<0.0 or float(entry[0])>=float(entry[1]) or float(entry[1])>length:
				return "%s %s must lie within 0..%.2f m" % [key,str(entry),length]
			if count==3 and (float(entry[2])<=0.0 or floor_y+.10+float(entry[2])>top-.16):
				return "infill_panels height must be positive and stay below the coping"
			if count==2 and split-.50<=floor_y+.10:
				return "storefronts need a lower field taller than 0.6 m"
	var rows: Variant=spec.get("split_slots",[])
	if not rows is Array:
		return "split_slots must be a list"
	for row: Variant in rows:
		if not row is Dictionary:
			return "split_slots rows must be dictionaries"
		if not _numbers(row.get("size"),2) or float(row["size"][0])<=0.0 or float(row["size"][1])<=0.0:
			return "split_slots size needs two positive numbers"
		if not _numbers([row.get("offset")],1) or float(row["offset"])<0.0:
			return "split_slots offset must be a number of at least 0"
		if not _numbers([row.get("bay")],1) or float(row["bay"])<=0.0:
			return "split_slots bay must be positive"
		var span: Variant=row.get("range",[0.0,length])
		if not _numbers(span,2) or float(span[0])<0.0 or float(span[0])>=float(span[1]) or float(span[1])>length:
			return "split_slots range must lie within 0..%.2f m" % length
		var row_count := maxi(1,int(round((float(span[1])-float(span[0]))/float(row["bay"]))))
		if float(row["size"][0])+.26>(float(span[1])-float(span[0]))/row_count:
			return "split_slots are wider than their spacing"
		var slot_top := split-float(row["offset"])
		if slot_top>top-.16 or slot_top-float(row["size"][1])<floor_y+.10:
			return "split_slots must stay inside the wall height"
	return ""

static func _numbers(value: Variant,count: int)->bool:
	if not value is Array or (value as Array).size()!=count:
		return false
	for item: Variant in value:
		if not (item is float or item is int):
			return false
	return true

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
