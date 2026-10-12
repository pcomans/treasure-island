extends RefCounted
## Shared site assembly. Exact source edges and per-instance opening schedules;
## Geometry shared by preview and normal-play attachment; ownership lives in the adapter.
const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const SIDING = preload("res://game/resources/housing_family/siding.gdshader")
const ROOF = preload("res://game/resources/housing_family/roof.gdshader")

static func vec(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])

static func color(cfg: Dictionary, key: String, fallback: Color) -> Color:
	var a: Array = cfg.get(key, [])
	return Color(a[0], a[1], a[2]) if a.size() == 3 else fallback

static func build(wall: Dictionary, roof: Dictionary, cfg: Dictionary) -> Node3D:
	var root := Node3D.new()
	root.set_meta("build_valid",true)
	root.name = "SharedHousing_" + str(cfg.target.source_key)
	root.set_meta("source_key", cfg.target.source_key)
	root.set_meta("scope", "experimental_visual_only_collision_unchanged")
	root.set_meta("dimensions", "production_inference_from_retained_target_schedule")
	var palette: Dictionary = cfg.materials
	var siding := ShaderMaterial.new()
	siding.shader = SIDING
	siding.set_shader_parameter("wall_color", color(palette, "siding_rgb", Color.GRAY))
	siding.set_shader_parameter("weathering_strength", float(cfg.get("weathering_strength", 0.0)))
	siding.set_shader_parameter("weathering_base_y", float(cfg.get("weathering_base_y", 0.0)))
	var trim := PARTS._material(color(palette, "trim_rgb", Color.WHITE), 0.8)
	var door := PARTS._material(color(palette, "door_rgb", Color.DARK_SLATE_GRAY), 0.75)
	var dark := PARTS._material(color(palette, "dark_glass_rgb", Color(0.1,0.15,0.16)), 0.4)
	var glass := PARTS._material(color(palette, "blue_glass_rgb", Color(0.25,0.34,0.36)), 0.25)
	var concrete := PARTS._material(color(palette, "path_rgb", Color(0.55,0.55,0.5)), 0.95)
	var roofing := ShaderMaterial.new()
	roofing.shader = ROOF
	roofing.set_shader_parameter("roof_color",color(cfg.get("facade",{}),"roof_high_rgb",Color(0.52,0.54,0.52)))
	var warm_roof := ShaderMaterial.new()
	warm_roof.shader = ROOF
	warm_roof.set_shader_parameter("roof_color",color(cfg.get("facade",{}),"roof_warm_high_rgb",Color(0.55,0.37,0.25)))
	var holes_by_run: Dictionary = {}
	var vertices: Array = wall.vertices
	var recess: Dictionary = cfg.get("lower_frontage_recess", {})
	var rear_recess: Dictionary = cfg.get("lower_rear_recess", {})
	var rear_recess_runs: Dictionary = {}
	if not rear_recess.is_empty():
		for frame: Dictionary in cfg.get("rear_frames", []):
			for run in frame.runs: rear_recess_runs[int(run)] = frame
	var recess_runs: Dictionary = {}
	if not recess.is_empty():
		for frame: Dictionary in cfg.target.frames:
			for run in frame.runs: recess_runs[int(run)] = frame
	# The target schedule carries complete motifs. A basis pins each motif to its
	# actual stepped source edge; no row or opening receives a scale transform.
	var opening_frames: Array = cfg.target.frames.duplicate()
	opening_frames.append_array(cfg.get("rear_frames", []))
	for frame: Dictionary in opening_frames:
		var is_rear: bool = str(frame.get("elevation_role", "front")) == "rear"
		for group in ["upper_windows", "lower_windows", "entries"]:
			for motif: Dictionary in frame.get(group, []):
				var basis: Dictionary = motif.get("basis", frame)
				var start := vec(basis.start)
				var t := vec(basis.tangent)
				var n := vec(basis.normal)
				var station := float(motif.get("local_station_m", motif.station_m))
				var point := start + t * station
				var run := int(basis.get("source_run", -1))
				if run < 0:
					for r in frame.runs:
						var a := Vector3(vertices[int(r)*12],vertices[int(r)*12+1],vertices[int(r)*12+2])
						var b := Vector3(vertices[int(r)*12+3],vertices[int(r)*12+4],vertices[int(r)*12+5])
						var rt := Vector3(b.x-a.x,0,b.z-a.z).normalized()
						var s := Vector3(point.x-a.x,0,point.z-a.z).dot(rt)
						if s >= 0 and s <= Vector2(b.x-a.x,b.z-a.z).length():
							run = int(r)
							break
				if run < 0:
					root.set_meta("build_valid",false)
					push_error("Unmatched scheduled motif: %s %s" % [cfg.target.source_key,frame.id])
					continue
				var ra := Vector3(vertices[run*12],vertices[run*12+1],vertices[run*12+2])
				var rb := Vector3(vertices[run*12+3],vertices[run*12+4],vertices[run*12+5])
				var rt := Vector3(rb.x-ra.x,0,rb.z-ra.z).normalized()
				var s := Vector3(point.x-ra.x,0,point.z-ra.z).dot(rt)
				var width := float(motif.width_m) if group != "entries" else 0.92
				var height := float(motif.height_m) if group != "entries" else 2.13
				var cy := float(motif.center_y) if group != "entries" else float(motif.bottom_y)+height/2
				# A complete opening can cross a collinear serialization seam.
				# Split only the wall hole; emit the opening once at its original size.
				var covered := 0.0
				for candidate in frame.runs:
					var ci := int(candidate)*12
					var ca := Vector3(vertices[ci],vertices[ci+1],vertices[ci+2])
					var cb := Vector3(vertices[ci+3],vertices[ci+4],vertices[ci+5])
					var ct := Vector3(cb.x-ca.x,0,cb.z-ca.z).normalized()
					if ct.dot(t)<0.995: continue
					var delta := Vector3(point.x-ca.x,0,point.z-ca.z)
					if absf(delta.dot(Vector3(-ct.z,0,ct.x)))>0.05: continue
					var cs := delta.dot(ct)
					var lo := maxf(0,cs-width/2)
					var hi := minf(Vector2(cb.x-ca.x,cb.z-ca.z).length(),cs+width/2)
					if hi<=lo: continue
					if not holes_by_run.has(int(candidate)): holes_by_run[int(candidate)] = []
					holes_by_run[int(candidate)].append(Rect2(lo,cy-height/2,hi-lo,height))
					covered += hi-lo
				if covered < width-0.06:
					root.set_meta("build_valid",false)
					push_error("Incomplete opening containment: %s %s %s" % [cfg.target.source_key,frame.id,station])
				point.y = cy
				var motif_begin := root.get_child_count()
				var active_recess: Dictionary = rear_recess if is_rear else recess
				var recessed: bool = not active_recess.is_empty() and group != "upper_windows"
				if recessed: point -= n * float(active_recess.depth_m)
				if group == "entries":
					var entry_material := door
					if str(motif.get("door_role","")) == "pale":
						entry_material = PARTS._material(color(palette,"pale_door_rgb",Color(0.62,0.65,0.62)),0.85)
					var extend_threshold: bool = motif.has("threshold_bottom_y")
					if extend_threshold and not (motif.threshold_bottom_y is float or motif.threshold_bottom_y is int):
						root.set_meta("build_valid", false)
						push_error("Threshold bottom must be numeric")
						continue
					PARTS._entry(root,point,t,n,trim,entry_material,concrete,float(motif.get("threshold_bottom_y", 0.0)),extend_threshold)
				elif str(motif.get("glazing", "")) == "boarded":
					PARTS._panel(root,point-n*0.03,t,n,Vector3(width,height,0.07),PARTS._material(color(palette,"closure_rgb",Color(0.48,0.40,0.28)),0.96))
					for side in [-1.0,1.0]:
						PARTS._panel(root,point+t*side*(width/2+0.025),t,n,Vector3(0.065,height+0.12,0.09),trim)
						PARTS._panel(root,point+Vector3.UP*side*(height/2+0.025),t,n,Vector3(width+0.12,0.065,0.09),trim)
				else:
					PARTS._recessed_window(root,point,t,n,width,height,trim,dark,glass)
				if recessed or is_rear or bool(motif.get("wall_receiver", false)):
					for child_index in range(motif_begin, root.get_child_count()):
						var child := root.get_child(child_index)
						child.set_meta("family_role", "support" if child.get_meta("construction_detail", "") == "door_threshold" else "wall")
		# Rear schedules own their openings and optional lower setback only; front trim/site stay intact.
		if is_rear: continue
		if cfg.has("broad_band"):
			var band: Dictionary = cfg.broad_band
			var a := vec(frame.start)
			var b := vec(frame.end)
			var n := vec(frame.normal)
			var low := float(band.bottom_y)
			var high := float(band.top_y)
			var projection := float(band.projection_m)
			var p0 := Vector3(a.x,low,a.z)+n*projection
			var p1 := Vector3(b.x,low,b.z)+n*projection
			var p2 := Vector3(b.x,high,b.z)+n*0.025
			var p3 := Vector3(a.x,high,a.z)+n*0.025
			PARTS._quad(root,[p0,p1,p2,p3],siding)
			PARTS._beam(root,p0,p1,0.10,0.10,trim)
			PARTS._quad(root,[Vector3(a.x,low,a.z),Vector3(b.x,low,b.z),p1,p0],trim)
			if bool(band.get("closed_returns",false)):
				PARTS._quad(root,[Vector3(a.x,low,a.z),p0,p3,Vector3(a.x,high,a.z)],siding)
				PARTS._quad(root,[p1,Vector3(b.x,low,b.z),Vector3(b.x,high,b.z),p2],siding)
		var ft := vec(frame.tangent)
		var fn := vec(frame.normal)
		var fa := vec(frame.start)
		var fb := vec(frame.end)
		var band_y := float(cfg.get("facade",{}).get("story_band_y",5.38))
		if not cfg.has("broad_band"):
			PARTS._beam(root,Vector3(fa.x,band_y,fa.z)+fn*0.11,Vector3(fb.x,band_y,fb.z)+fn*0.11,0.20,0.09,trim)
			# Thin frontage trim keeps its visible geometry without stippled cast shadows.
			if not recess.is_empty() and str(cfg.target.source_key) in ["w96215661", "w96215669", "w96215672"]:
				var story_trim := root.get_child(-1) as MeshInstance3D
				story_trim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for pipe: Dictionary in frame.get("pipes",[]):
			var basis: Dictionary = pipe.get("basis",frame)
			var p := vec(basis.start)+vec(basis.tangent)*float(pipe.get("local_station_m",pipe.station_m))
			var low := float(pipe.bottom_y)
			var high := float(pipe.top_y)
			if bool(cfg.get("clamp_pipe_to_eave",false)): high=minf(high,float(cfg.wall_top_y)-0.03)
			p.y=(low+high)/2
			PARTS._panel(root,p+vec(basis.normal)*0.12,vec(basis.tangent),vec(basis.normal),Vector3(0.075,high-low,0.09),trim)
		for screen: Dictionary in frame.get("screens", []):
			var basis: Dictionary = screen.get("basis", frame)
			var t := vec(basis.tangent)
			var n := vec(basis.normal)
			var point := vec(basis.start)+t*float(screen.get("local_station_m",screen.station_m))+n*float(screen.get("depth_m",0.65))
			var h := float(screen.height_m)
			var width := float(screen.width_m)
			point.y = float(screen.bottom_y)+h/2
			var screen_material := PARTS._material(color(screen,"material_rgb",color(palette,"screen_rgb",Color(0.5,0.55,0.57))),0.9)
			_screen(root,point,t,n,width,h,screen_material,str(screen.get("panel_style","boarded")) == "slatted")
			if screen.has("return_length_m"):
				var length := float(screen.return_length_m)
				var return_height := float(screen.get("return_height_m",h))
				_screen(root,point-t*(width/2-0.045)-n*(length/2+0.035)+Vector3.UP*(return_height-h)/2,-n,t,length,return_height,screen_material,true)
	for i in range(0, vertices.size(), 12):
		var a := Vector3(vertices[i],vertices[i+1],vertices[i+2])
		var b := Vector3(vertices[i+3],vertices[i+4],vertices[i+5])
		var top := float(cfg.get("wall_top_y", maxf(float(vertices[i+7]),float(vertices[i+10]))))
		var holes: Array[Rect2] = []
		for hole: Rect2 in holes_by_run.get(i/12, []): holes.append(hole)
		var wall_begin := root.get_child_count()
		if recess_runs.has(i/12):
			_recessed_wall(root, a, b, top, holes, siding, trim, vertices, i/12, recess_runs[i/12], recess)
		elif rear_recess_runs.has(i/12):
			_recessed_wall(root, a, b, top, holes, siding, trim, vertices, i/12, rear_recess_runs[i/12], rear_recess)
		else:
			PARTS._wall_with_openings(root,a,b,top,holes,siding)
		_tag_since(root,wall_begin,"wall")
		var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n := Vector3(-t.z,0,t.x)
		if bool(cfg.get("vertical_seams",false)):
			PARTS._panel(root,Vector3(a.x,(a.y+top)/2,a.z),t,n,Vector3(0.08,top-a.y,0.08),trim)
		if not bool(cfg.get("public_roof",{}).get("replace_eave_trim",false)):
			PARTS._beam(root,Vector3(a.x,top,a.z)+n*0.05,Vector3(b.x,top,b.z)+n*0.05,0.23,0.13,trim)
	var roof_begin := root.get_child_count()
	# Keep the frozen roof footprint; existing observed pitched surfaces are data.
	if cfg.has("shallow_sectional_roof"):
		# Source-triangle subdivision keeps the complete stepped roof footprint.
		# Rise and ridge/eave dimensions are reversible game-art inference.
		var shallow: Dictionary = cfg.shallow_sectional_roof
		for triangle: Array in shallow.triangles:
			var points: Array = [vec(triangle[0]), vec(triangle[1]), vec(triangle[2])]
			var indices := PackedInt32Array([0, 1, 2])
			if (points[1]-points[0]).cross(points[2]-points[0]).y > 0:
				indices = PackedInt32Array([0, 2, 1])
			PARTS._mesh(root, points, indices, roofing)
		for closure: Array in shallow.closures:
			PARTS._quad(root, [vec(closure[0]), vec(closure[1]), vec(closure[2]), vec(closure[3])], siding)
		for edge: Array in shallow.eaves:
			PARTS._beam(root, vec(edge[0]), vec(edge[1]), 0.20, 0.12, trim)
	elif str(cfg.get("roof_kind","")) == "shallow_hip":
		_hip_roof(root,wall,cfg,roofing,trim)
	elif not bool(cfg.get("retain_production_roof",false)):
		var roofpoints: Array = []
		for i in range(0,roof.vertices.size(),3): roofpoints.append(Vector3(roof.vertices[i],roof.vertices[i+1],roof.vertices[i+2]))
		var roof_indices := PackedInt32Array(roof.indices)
		# Regenerated source roofs must face the sky, as in _hip_piece below.
		# Normalize actual orientation instead of applying an instance toggle;
		# already clockwise triangles remain unchanged, including old opt-ins.
		for i in range(0,roof_indices.size(),3):
			var a: Vector3 = roofpoints[roof_indices[i]]
			var b: Vector3 = roofpoints[roof_indices[i+1]]
			var c: Vector3 = roofpoints[roof_indices[i+2]]
			if (b-a).cross(c-a).y > 0:
				var saved := roof_indices[i+1]
				roof_indices[i+1] = roof_indices[i+2]
				roof_indices[i+2] = saved
		PARTS._mesh(root,roofpoints,roof_indices,roofing)
		for triangle: Array in cfg.get("public_roof", {}).get("triangles", []):
			var roof_material: Material = roofing
			var facade: Dictionary = cfg.get("facade",{})
			if facade.has("warm_roof_axis"):
				var center := (vec(triangle[0])+vec(triangle[1])+vec(triangle[2]))/3
				var station := center.x*float(facade.warm_roof_axis[0])+center.z*float(facade.warm_roof_axis[1])
				if station <= float(facade.warm_roof_station_max): roof_material=warm_roof
			PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),roof_material)
		# Optional full-envelope gable/step closures use the existing siding
		# material and roof contact role; unconfigured instances are unchanged.
		for triangle: Array in cfg.get("public_roof", {}).get("closure_triangles", []):
			PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),siding)
		for triangle: Array in cfg.get("public_roof", {}).get("edge_triangles", []):
			PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),trim)
	_tag_since(root,roof_begin,"roof")
	# A retained production roof can own a varying boundary above the family
	# wall top. Target-supplied closures reproduce that boundary as visible,
	# source-owned wall geometry, without reviving the hidden legacy wall body.
	var closure_begin := root.get_child_count()
	for triangle: Array in cfg.get("retained_roof_wall_closures", []):
		PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),siding)
	_tag_since(root,closure_begin,"wall")
	for triangle: Array in cfg.get("shallow_band", {}).get("triangles", []):
		PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),siding)
	var ground_begin := root.get_child_count()
	if not bool(cfg.get("retain_production_roof",false)):
		for surface: Dictionary in cfg.get("local_ground", {}).values():
			var ground_material: Material = concrete
			if surface.has("material_rgb"): ground_material = PARTS._material(color(surface,"material_rgb",Color.GRAY),0.98)
			for triangle: Array in surface.get("top_triangles",[]):
				_ground_triangle(root,triangle,ground_material,not recess.is_empty())
		for frame: Dictionary in cfg.target.frames:
			for entry: Dictionary in frame.get("entries",[]):
				for triangle: Array in entry.get("path_mesh",{}).get("top_triangles",[]):
					_ground_triangle(root,triangle,concrete,not recess.is_empty())
	_tag_since(root,ground_begin,"ground")
	var canopies: Array = cfg.get("carports", []).duplicate()
	if cfg.has("carport") and not cfg.carport.is_empty(): canopies.append(cfg.carport)
	for canopy: Dictionary in canopies:
		_canopy(root,canopy,palette,roofing,trim)
	return root

static func _canopy(root: Node3D, cfg: Dictionary, palette: Dictionary, roof: Material, trim: Material) -> void:
	if not cfg.has("frame") or not cfg.has("station_m"): return
	var frame: Dictionary = cfg.frame
	var start := vec(frame.start)
	var t := vec(frame.tangent)
	var n := vec(frame.normal)
	var depth := float(cfg.depth_m[1])-float(cfg.depth_m[0])
	var middle := (float(cfg.depth_m[0])+float(cfg.depth_m[1]))/2
	var a := start+t*float(cfg.station_m[0])+n*middle
	var b := start+t*float(cfg.station_m[1])+n*middle
	a.y = float(cfg.roof_y)
	b.y = a.y
	PARTS._beam(root,a,b,depth,0.16,roof)
	var underside := PARTS._material(Color(0.16,0.20,0.19),0.97)
	PARTS._beam(root,a-Vector3(0,0.10,0),b-Vector3(0,0.10,0),depth-0.10,0.025,underside)
	var steel := PARTS._material(color(palette,"carport_post_rgb",Color(0.35,0.3,0.25)),0.9)
	var fascia: Material = trim
	if cfg.has("fascia_rgb"): fascia = PARTS._material(color(cfg,"fascia_rgb",Color.GRAY),0.96)
	for d in cfg.depth_m:
		PARTS._beam(root,a+n*(float(d)-middle),b+n*(float(d)-middle),0.13,0.29,fascia)
	for post: Dictionary in cfg.get("posts", []):
		var p := start+t*float(post.station_m)+n*float(post.depth_m)
		var bottom := float(post.bottom_y)
		p.y = (a.y+bottom)/2
		PARTS._panel(root,p,t,n,Vector3(0.09,a.y-bottom,0.09),steel)

static func _hip_roof(root: Node3D, wall: Dictionary, cfg: Dictionary, material: Material, trim: Material) -> void:
	# Four planar slopes clipped to the frozen outline. Pitch/height are bounded
	# art inference, not a surveyed roof or a collision replacement.
	var tangent := vec(cfg.target.frames[0].tangent)
	var t := Vector2(tangent.x,tangent.z).normalized()
	var n := Vector2(-t.y,t.x)
	var polygon := PackedVector2Array()
	var lo := Vector2(INF,INF)
	var hi := Vector2(-INF,-INF)
	var top := -INF
	var values: Array = wall.vertices
	for i in range(0,values.size(),12):
		var p := Vector2(values[i],values[i+2])
		var q := Vector2(p.dot(t),p.dot(n))
		polygon.append(q)
		lo=lo.min(q)
		hi=hi.max(q)
		top=maxf(top,float(values[i+7]))
	top = float(cfg.get("wall_top_y",top))
	if bool(cfg.get("segmented_roof",false)):
		var boundaries: Array[float] = [lo.x]
		var frames: Array = cfg.target.frames
		for j in range(frames.size()-1):
			var a := vec(frames[j].end)
			var b := vec(frames[j+1].start)
			boundaries.append((Vector2(a.x,a.z).dot(t)+Vector2(b.x,b.z).dot(t))/2)
		boundaries.append(hi.x)
		for j in range(boundaries.size()-1):
			var slab := PackedVector2Array([Vector2(boundaries[j],lo.y-1),Vector2(boundaries[j+1],lo.y-1),Vector2(boundaries[j+1],hi.y+1),Vector2(boundaries[j],hi.y+1)])
			for piece in Geometry2D.intersect_polygons(polygon,slab):
				_hip_piece(root,piece,t,n,top,float(cfg.get("roof_rise_m",0.72)),material,trim,polygon,float(cfg.get("roof_eave_depth_m",0.16)))
	else:
		_hip_piece(root,polygon,t,n,top,float(cfg.get("roof_rise_m",0.72)),material,trim,polygon,float(cfg.get("roof_eave_depth_m",0.16)))

static func _hip_piece(root: Node3D, polygon: PackedVector2Array, t: Vector2, n: Vector2, top: float, rise: float, material: Material, trim: Material, outline: PackedVector2Array, eave_depth: float) -> void:
	var lo := Vector2(INF,INF)
	var hi := Vector2(-INF,-INF)
	for q: Vector2 in polygon:
		lo=lo.min(q)
		hi=hi.max(q)
	var half := (hi.y-lo.y)/2
	var inset := minf(half,(hi.x-lo.x)/2)
	var center := (hi.y+lo.y)/2
	var faces: Array = [
		PackedVector2Array([lo,Vector2(hi.x,lo.y),Vector2(hi.x-inset,center),Vector2(lo.x+inset,center)]),
		PackedVector2Array([Vector2(lo.x,hi.y),Vector2(lo.x+inset,center),Vector2(hi.x-inset,center),hi]),
		PackedVector2Array([lo,Vector2(lo.x+inset,center),Vector2(lo.x,hi.y)]),
		PackedVector2Array([Vector2(hi.x,lo.y),hi,Vector2(hi.x-inset,center)])]
	for face: PackedVector2Array in faces:
		for clipped in Geometry2D.intersect_polygons(polygon,face):
			# Remove exact duplicate clipping vertices only; never silently discard
			# a positive-area triangulation failure. Area uses local scalar products
			# to avoid float32 cancellation at large world coordinates.
			var piece := PackedVector2Array()
			for q: Vector2 in clipped:
				if piece.is_empty() or q.distance_to(piece[-1])>0.0: piece.append(q)
			if piece.size()>1 and piece[0].distance_to(piece[-1])==0.0:
				piece.resize(piece.size()-1)
			var area := _polygon_area(piece)
			if piece.size()<3 or area==0.0:
				continue
			var points: Array = []
			for q: Vector2 in piece:
				var p := t*q.x+n*q.y
				var edge_distance := minf(minf(q.y-lo.y,hi.y-q.y),minf(q.x-lo.x,hi.x-q.x))
				points.append(Vector3(p.x,top+0.055+rise*clampf(edge_distance/half,0,1),p.y))
			# Translate only the triangulation input. Indices still address the
			# original point array; no emitted coordinate or positive area is lost.
			var local_polygon := PackedVector2Array()
			for q: Vector2 in piece: local_polygon.append(q-piece[0])
			var indices := PackedInt32Array([0,1,2]) if piece.size()==3 else Geometry2D.triangulate_polygon(local_polygon)
			if indices.is_empty():
				root.set_meta("build_valid",false)
				push_error("Nondegenerate roof triangulation failed: %s area=%s vertices=%s" % [root.get_meta("source_key"),area,piece])
				continue
			# Roof normals must face the sky independent of polygon winding.
			for i in range(0,indices.size(),3):
				var a: Vector3 = points[indices[i]]
				var b: Vector3 = points[indices[i+1]]
				var c: Vector3 = points[indices[i+2]]
				if (b-a).cross(c-a).y>0:
					var temp := indices[i+1]
					indices[i+1]=indices[i+2]
					indices[i+2]=temp
			PARTS._mesh(root,points,indices,material)
			var roof_mesh := root.get_child(-1) as MeshInstance3D
			roof_mesh.name = "HipSurface"
	for i in polygon.size():
		var a := polygon[i]
		var b := polygon[(i+1)%polygon.size()]
		# Section cuts share a roof junction, not a doubled fascia or closure face.
		var midpoint := (a+b)/2
		var exterior := false
		for edge in outline.size():
			var oa := outline[edge]
			var ob := outline[(edge+1)%outline.size()]
			if Geometry2D.get_closest_point_to_segment(midpoint,oa,ob).distance_to(midpoint)<0.005:
				exterior=true
				break
		if not exterior: continue
		var da := minf(minf(a.y-lo.y,hi.y-a.y),minf(a.x-lo.x,hi.x-a.x))
		var db := minf(minf(b.y-lo.y,hi.y-b.y),minf(b.x-lo.x,hi.x-b.x))
		var pa := t*a.x+n*a.y
		var pb := t*b.x+n*b.y
		var ya := top+0.055+rise*clampf(da/half,0,1)
		var yb := top+0.055+rise*clampf(db/half,0,1)
		PARTS._quad(root,[Vector3(pa.x,top,pa.y),Vector3(pb.x,top,pb.y),Vector3(pb.x,yb,pb.y),Vector3(pa.x,ya,pa.y)],trim)
		PARTS._beam(root,Vector3(pa.x,ya,pa.y),Vector3(pb.x,yb,pb.y),eave_depth,0.12,trim)

static func _screen(root: Node3D, point: Vector3, t: Vector3, n: Vector3, width: float, height: float, material: Material, slatted: bool = false) -> void:
	if width < 0.16:
		PARTS._panel(root,point,t,n,Vector3(width,height,0.08),material)
		return
	for side in [-1.0,1.0]:
		PARTS._panel(root,point+t*side*(width/2-0.045),t,n,Vector3(0.09,height,0.09),material)
	for y in [-0.36,0.36]:
		PARTS._panel(root,point+Vector3.UP*height*y-n*0.04,t,n,Vector3(maxf(0.08,width-0.1),0.075,0.065),material)
	var count := maxi(2,int(floor((width-0.16)/(0.115 if slatted else 0.105))))
	for i in count:
		var station := lerpf(-width/2+0.13,width/2-0.13,float(i)/float(count-1))
		PARTS._panel(root,point+t*station+n*0.02,t,n,Vector3(0.078 if slatted else (width-0.16)/count,height-0.08,0.04),material)

static func _polygon_area(polygon: PackedVector2Array) -> float:
	if polygon.size()<3: return 0.0
	var origin := polygon[0]
	var sum := 0.0
	for j in polygon.size():
		var a := polygon[j]
		var b := polygon[(j+1)%polygon.size()]
		var ax := float(a.x)-float(origin.x)
		var ay := float(a.y)-float(origin.y)
		var bx := float(b.x)-float(origin.x)
		var by := float(b.y)-float(origin.y)
		sum += ax*by-ay*bx
	return absf(sum)*0.5

static func _tag_since(root: Node3D, begin: int, role: String) -> void:
	for i in range(begin,root.get_child_count()):
		root.get_child(i).set_meta("family_role",role)

# Keep the upper receiver and frozen roof in place. The complete lower wall,
# openings and return shell move inward; dimensions are production inference.
static func _recessed_wall(root: Node3D, a: Vector3, b: Vector3, top: float, holes: Array[Rect2], siding: Material, soffit: Material, vertices: Array, run: int, frame: Dictionary, recess: Dictionary) -> void:
	var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var n := Vector3(-t.z,0,t.x)
	var length := Vector2(b.x-a.x,b.z-a.z).length()
	var band := float(recess.band_y)
	var depth := float(recess.depth_m)
	# Rear cavity ends face the exposed setback, not the solid building interior.
	var cavity_facing_returns := bool(recess.get("cavity_facing_returns", false))
	var runs: Array[int] = []
	for source_run in frame.runs: runs.append(int(source_run))
	var position: int = runs.find(run)
	var lo := 0.05 if position == 0 else 0.0
	var hi := length-0.05 if position == runs.size()-1 else length
	var outer_a := a.lerp(b,lo/length)
	var outer_b := a.lerp(b,hi/length)
	var inner_a := outer_a-n*depth
	var inner_b := outer_b-n*depth
	# Adjacent serialized source runs meet at a shared offset-line miter.
	if position > 0:
		var previous := runs[position-1]*12
		var pt := Vector3(vertices[previous+3]-vertices[previous],0,vertices[previous+5]-vertices[previous+2]).normalized()
		var pn := Vector3(-pt.z,0,pt.x)
		inner_a = outer_a-(n+pn)*depth/(1.0+n.dot(pn))
	if position < runs.size()-1:
		var following := runs[position+1]*12
		var nt := Vector3(vertices[following+3]-vertices[following],0,vertices[following+5]-vertices[following+2]).normalized()
		var nn := Vector3(-nt.z,0,nt.x)
		inner_b = outer_b-(n+nn)*depth/(1.0+n.dot(nn))
	PARTS._wall_with_openings(root,Vector3(a.x,band,a.z),Vector3(b.x,band,b.z),top,_clipped_holes(holes,0,length,band,top),siding)
	var shift := Vector3(inner_a.x-a.x,0,inner_a.z-a.z).dot(t)
	PARTS._wall_with_openings(root,inner_a,inner_b,band,_clipped_holes(holes,shift,shift+inner_a.distance_to(Vector3(inner_b.x,inner_a.y,inner_b.z)),minf(a.y,b.y),band),siding)
	if lo > 0:
		PARTS._wall_with_openings(root,a,outer_a,band,[],siding)
		PARTS._quad(root,[outer_a,inner_a,Vector3(inner_a.x,band,inner_a.z),Vector3(outer_a.x,band,outer_a.z)],siding,cavity_facing_returns)
	if hi < length:
		PARTS._wall_with_openings(root,outer_b,b,band,[],siding)
		PARTS._quad(root,[inner_b,outer_b,Vector3(outer_b.x,band,outer_b.z),Vector3(inner_b.x,band,inner_b.z)],siding,cavity_facing_returns)
	PARTS._quad(root,[Vector3(outer_a.x,band,outer_a.z),Vector3(outer_b.x,band,outer_b.z),Vector3(inner_b.x,band,inner_b.z),Vector3(inner_a.x,band,inner_a.z)],soffit,false)

static func _clipped_holes(holes: Array[Rect2], start: float, end: float, bottom: float, top: float) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var bounds := Rect2(start,bottom,end-start,top-bottom)
	for hole: Rect2 in holes:
		var clipped := hole.intersection(bounds)
		if clipped.has_area():
			clipped.position.x -= start
			result.append(clipped)
	return result

static func _ground_triangle(root: Node3D, triangle: Array, material: Material, orient_up: bool) -> void:
	# Determine winding after conversion to the actual native Vector3 precision.
	# Thin clipped pieces can reverse orientation when their doubles are rounded.
	var points: Array = [vec(triangle[0]),vec(triangle[1]),vec(triangle[2])]
	var indices := PackedInt32Array([0,1,2])
	if orient_up and (points[1]-points[0]).cross(points[2]-points[0]).y > 0:
		indices = PackedInt32Array([0,2,1])
	PARTS._mesh(root,points,indices,material)
