extends RefCounted
## Shared site assembly. Exact source edges and per-instance opening schedules;
## render-only experiment, with no authority, receiver or collision mutation.
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
	root.name = "SharedHousing_" + str(cfg.target.source_key)
	root.set_meta("source_key", cfg.target.source_key)
	root.set_meta("scope", "experimental_visual_only_collision_unchanged")
	root.set_meta("dimensions", "production_inference_from_retained_target_schedule")
	var palette: Dictionary = cfg.materials
	var siding := ShaderMaterial.new()
	siding.shader = SIDING
	siding.set_shader_parameter("wall_color", color(palette, "siding_rgb", Color.GRAY))
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
	# The target schedule carries complete motifs. A basis pins each motif to its
	# actual stepped source edge; no row or opening receives a scale transform.
	for frame: Dictionary in cfg.target.frames:
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
					push_error("Incomplete opening containment: %s %s %s" % [cfg.target.source_key,frame.id,station])
				point.y = cy
				if group == "entries":
					PARTS._entry(root,point,t,n,trim,door,concrete)
				elif str(motif.get("glazing", "")) == "boarded":
					PARTS._panel(root,point-n*0.03,t,n,Vector3(width,height,0.07),PARTS._material(Color(0.48,0.40,0.28),0.96))
				else:
					PARTS._recessed_window(root,point,t,n,width,height,trim,dark,glass)
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
		var ft := vec(frame.tangent)
		var fn := vec(frame.normal)
		var fa := vec(frame.start)
		var fb := vec(frame.end)
		var band_y := float(cfg.get("facade",{}).get("story_band_y",5.38))
		if not cfg.has("broad_band"):
			PARTS._beam(root,Vector3(fa.x,band_y,fa.z)+fn*0.11,Vector3(fb.x,band_y,fb.z)+fn*0.11,0.20,0.09,trim)
		for pipe: Dictionary in frame.get("pipes",[]):
			var basis: Dictionary = pipe.get("basis",frame)
			var p := vec(basis.start)+vec(basis.tangent)*float(pipe.get("local_station_m",pipe.station_m))
			var low := float(pipe.bottom_y)
			var high := float(pipe.top_y)
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
			var screen_material := PARTS._material(color(palette,"screen_rgb",Color(0.5,0.55,0.57)),0.9)
			_screen(root,point,t,n,width,h,screen_material,str(screen.get("panel_style","boarded")) == "slatted")
			if screen.has("return_length_m"):
				var length := float(screen.return_length_m)
				_screen(root,point-t*(width/2-0.045)-n*(length/2+0.035),-n,t,length,h,screen_material,true)
	for i in range(0, vertices.size(), 12):
		var a := Vector3(vertices[i],vertices[i+1],vertices[i+2])
		var b := Vector3(vertices[i+3],vertices[i+4],vertices[i+5])
		var top := float(cfg.get("wall_top_y", maxf(float(vertices[i+7]),float(vertices[i+10]))))
		var holes: Array[Rect2] = []
		for hole: Rect2 in holes_by_run.get(i/12, []): holes.append(hole)
		PARTS._wall_with_openings(root,a,b,top,holes,siding)
		var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n := Vector3(-t.z,0,t.x)
		if bool(cfg.get("vertical_seams",false)):
			PARTS._panel(root,Vector3(a.x,(a.y+top)/2,a.z),t,n,Vector3(0.08,top-a.y,0.08),trim)
		PARTS._beam(root,Vector3(a.x,top,a.z)+n*0.05,Vector3(b.x,top,b.z)+n*0.05,0.23,0.13,trim)
	# Keep the frozen roof footprint; existing observed pitched surfaces are data.
	if str(cfg.get("roof_kind","")) == "shallow_hip":
		_hip_roof(root,wall,cfg,roofing,trim)
	elif not bool(cfg.get("retain_production_roof",false)):
		var roofpoints: Array = []
		for i in range(0,roof.vertices.size(),3): roofpoints.append(Vector3(roof.vertices[i],roof.vertices[i+1],roof.vertices[i+2]))
		PARTS._mesh(root,roofpoints,PackedInt32Array(roof.indices),roofing)
		for triangle: Array in cfg.get("public_roof", {}).get("triangles", []):
			var roof_material: Material = roofing
			var facade: Dictionary = cfg.get("facade",{})
			if facade.has("warm_roof_axis"):
				var center := (vec(triangle[0])+vec(triangle[1])+vec(triangle[2]))/3
				var station := center.x*float(facade.warm_roof_axis[0])+center.z*float(facade.warm_roof_axis[1])
				if station <= float(facade.warm_roof_station_max): roof_material=warm_roof
			PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),roof_material)
	for triangle: Array in cfg.get("shallow_band", {}).get("triangles", []):
		PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),siding)
	if not bool(cfg.get("retain_production_roof",false)):
		for surface: Dictionary in cfg.get("local_ground", {}).values():
			for triangle: Array in surface.get("top_triangles",[]):
				PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),concrete)
		for frame: Dictionary in cfg.target.frames:
			for entry: Dictionary in frame.get("entries",[]):
				for triangle: Array in entry.get("path_mesh",{}).get("top_triangles",[]):
					PARTS._mesh(root,[vec(triangle[0]),vec(triangle[1]),vec(triangle[2])],PackedInt32Array([0,1,2]),concrete)
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
	for d in cfg.depth_m:
		PARTS._beam(root,a+n*(float(d)-middle),b+n*(float(d)-middle),0.13,0.29,trim)
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
	var half := (hi.y-lo.y)/2
	var inset := minf(half,(hi.x-lo.x)/2)
	var center := (hi.y+lo.y)/2
	var rise := float(cfg.get("roof_rise_m",0.72))
	var faces: Array = [
		PackedVector2Array([lo,Vector2(hi.x,lo.y),Vector2(hi.x-inset,center),Vector2(lo.x+inset,center)]),
		PackedVector2Array([Vector2(lo.x,hi.y),Vector2(lo.x+inset,center),Vector2(hi.x-inset,center),hi]),
		PackedVector2Array([lo,Vector2(lo.x+inset,center),Vector2(lo.x,hi.y)]),
		PackedVector2Array([Vector2(hi.x,lo.y),hi,Vector2(hi.x-inset,center)])]
	for face: PackedVector2Array in faces:
		for piece in Geometry2D.intersect_polygons(polygon,face):
			var points: Array = []
			for q: Vector2 in piece:
				var p := t*q.x+n*q.y
				var edge_distance := minf(minf(q.y-lo.y,hi.y-q.y),minf(q.x-lo.x,hi.x-q.x))
				points.append(Vector3(p.x,top+0.055+rise*clampf(edge_distance/half,0,1),p.y))
			var indices := Geometry2D.triangulate_polygon(piece)
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
	for i in polygon.size():
		var a := polygon[i]
		var b := polygon[(i+1)%polygon.size()]
		var da := minf(minf(a.y-lo.y,hi.y-a.y),minf(a.x-lo.x,hi.x-a.x))
		var db := minf(minf(b.y-lo.y,hi.y-b.y),minf(b.x-lo.x,hi.x-b.x))
		var pa := t*a.x+n*a.y
		var pb := t*b.x+n*b.y
		var ya := top+0.055+rise*clampf(da/half,0,1)
		var yb := top+0.055+rise*clampf(db/half,0,1)
		PARTS._quad(root,[Vector3(pa.x,top,pa.y),Vector3(pb.x,top,pb.y),Vector3(pb.x,yb,pb.y),Vector3(pa.x,ya,pa.y)],trim)
		PARTS._beam(root,Vector3(pa.x,ya,pa.y),Vector3(pb.x,yb,pb.y),0.16,0.12,trim)

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
