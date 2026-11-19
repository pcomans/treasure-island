extends RefCounted
## Shared site assembly. Exact source edges and per-instance opening schedules;
## Geometry shared by preview and normal-play attachment; ownership lives in the adapter.
const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const SIDING = preload("res://game/resources/housing_family/siding.gdshader")
const ROOF = preload("res://game/resources/housing_family/roof.gdshader")
# Opt-in garage-court motifs (garage doors, piers, loggias, stairs, vents,
# per-run siding colour); each runs only for its own config key.
const GARAGE_COURT = preload("res://game/scripts/world/facades/housing_garage_court.gd")
# Opt-in unit details (window blinds, utilities by the doors, downspouts, roof
# vents); each runs only for its own config key.
const DETAIL = preload("res://game/scripts/world/facades/housing_unit_detail.gd")

static func vec(a: Array) -> Vector3:
	return Vector3(a[0], a[1], a[2])

static func color(cfg: Dictionary, key: String, fallback: Color) -> Color:
	var a: Array = cfg.get(key, [])
	return Color(a[0], a[1], a[2]) if a.size() == 3 else fallback

static func build(wall: Dictionary, roof: Dictionary, cfg: Dictionary, merge: bool = true) -> Node3D:
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
	# Opt-in unit details (DETAIL): blinds in the front windows, utilities by the
	# front doors and a stronger lap shadow on the siding.
	var blinds: Dictionary = cfg.get("window_blinds", {})
	var blind_buckets: Dictionary = DETAIL.blind_buckets() if not blinds.is_empty() and DETAIL.blinds_valid(root, blinds) else {}
	var utility_kit: Dictionary = cfg.get("utility_kit", {})
	var utilities: Dictionary = DETAIL.utility_context(utility_kit) if not utility_kit.is_empty() and DETAIL.kit_valid(root, utility_kit) else {}
	if cfg.has("siding_course_shadow"):
		var lap: Variant = cfg.siding_course_shadow
		if (lap is float or lap is int) and float(lap) >= 0.0 and float(lap) <= 1.0:
			siding.set_shader_parameter("course_shadow", float(lap))
		else:
			root.set_meta("build_valid",false)
			push_error("Invalid siding_course_shadow (0-1): %s %s" % [cfg.target.source_key, lap])
	var holes_by_run: Dictionary = {}
	var vertices: Array = wall.vertices
	# Opt-in open canopy bays. Authored host runs use the frozen 12-float run
	# layout and follow the source ring, so frames and motifs can open them;
	# listed source runs emit no wall. Unset keys keep the source ring as-is.
	if cfg.has("virtual_wall_runs"):
		vertices = vertices.duplicate()
		for run: Array in cfg.virtual_wall_runs:
			# A short or long run would shift every later run index.
			if run.size() != 12:
				root.set_meta("build_valid",false)
				push_error("Invalid virtual wall run size: %s %s" % [cfg.target.source_key,run.size()])
				continue
			vertices.append_array(run)
	var skip_wall_runs: Dictionary = {}
	for run in cfg.get("skip_wall_runs", []): skip_wall_runs[int(run)] = true
	# A skipped run builds no wall, so no frame may cut openings in it.
	for frame: Dictionary in cfg.target.frames + cfg.get("rear_frames", []):
		for run in frame.get("runs", []):
			if skip_wall_runs.has(int(run)):
				root.set_meta("build_valid",false)
				push_error("Frame uses a skipped wall run: %s %s %s" % [cfg.target.source_key,frame.id,run])
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
	# Opt-in soffit_rgb: the setback's soffit in its own colour (a floor-line shadow).
	var recess_soffit: Material = null
	if recess.has("soffit_rgb"): recess_soffit = PARTS._material(color(recess,"soffit_rgb",Color.GRAY),0.95)
	# Gable runs under an opt-in rake carry it in place of the eave trim.
	var rake_runs: Dictionary = {}
	for run: Variant in cfg.get("gable_rakes", {}).get("runs", []): rake_runs[int(run)] = true
	# The target schedule carries complete motifs. A basis pins each motif to its
	# actual stepped source edge; no row or opening receives a scale transform.
	var opening_frames: Array = cfg.target.frames.duplicate()
	opening_frames.append_array(cfg.get("rear_frames", []))
	for frame: Dictionary in opening_frames:
		var is_rear: bool = str(frame.get("elevation_role", "front")) == "rear"
		for group in ["upper_windows", "lower_windows", "entries", "garage_doors", "loggias"]:
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
					if not utilities.is_empty() and not is_rear:
						DETAIL.add_landing(utilities, point, t, n)
						if motif.has("utilities"):
							DETAIL.entry_utilities(root, utilities, utility_kit, motif, frame, point, t, n, station, float(motif.bottom_y))
				elif group == "garage_doors":
					GARAGE_COURT.garage_door(root,point,t,n,width,height,motif,palette,trim)
				elif group == "loggias":
					GARAGE_COURT.loggia(root,point,t,n,width,height,motif,palette,siding,trim,dark,concrete)
				elif str(motif.get("glazing", "")) == "sidelight":
					# Opt-in: a full-height glazed sidelight beside a door (DETAIL).
					DETAIL.sidelight(root,point,t,n,width,height,trim,dark,glass)
				elif str(motif.get("glazing", "")) == "boarded":
					PARTS._panel(root,point-n*0.03,t,n,Vector3(width,height,0.07),PARTS._material(color(palette,"closure_rgb",Color(0.48,0.40,0.28)),0.96))
					for side in [-1.0,1.0]:
						PARTS._panel(root,point+t*side*(width/2+0.025),t,n,Vector3(0.065,height+0.12,0.09),trim)
						PARTS._panel(root,point+Vector3.UP*side*(height/2+0.025),t,n,Vector3(width+0.12,0.065,0.09),trim)
				else:
					PARTS._recessed_window(root,point,t,n,width,height,trim,dark,glass)
					if not blind_buckets.is_empty() and not is_rear:
						DETAIL.window_blinds(blind_buckets, blinds, point, t, n, width, height)
				if recessed or is_rear or bool(motif.get("wall_receiver", false)):
					for child_index in range(motif_begin, root.get_child_count()):
						var child := root.get_child(child_index)
						child.set_meta("family_role", "support" if child.get_meta("construction_detail", "") == "door_threshold" else "wall")
		# Rear schedules own their openings and optional lower setback only; front trim/site stay intact.
		if is_rear: continue
		GARAGE_COURT.piers(root,frame,palette)
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
		var band_spec: Dictionary = cfg.get("story_band", {})
		if not cfg.has("broad_band") and band_spec.is_empty():
			PARTS._beam(root,Vector3(fa.x,band_y,fa.z)+fn*0.11,Vector3(fb.x,band_y,fb.z)+fn*0.11,0.20,0.09,trim)
			# Thin frontage trim keeps its visible geometry without stippled cast shadows.
			if not recess.is_empty() and str(cfg.target.source_key) in ["w96215661", "w96215669", "w96215672"]:
				var story_trim := root.get_child(-1) as MeshInstance3D
				story_trim.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		elif not cfg.has("broad_band") and float(band_spec.get("height_m", 0.09)) > 0.0:
			# Opt-in story_band {depth_m, height_m}: a slimmer board; height_m 0 draws none,
			# leaving a jetty's own soffit as the floor line.
			var board_d := float(band_spec.get("depth_m", 0.20))
			PARTS._beam(root,Vector3(fa.x,band_y,fa.z)+fn*(0.01+board_d*0.5),Vector3(fb.x,band_y,fb.z)+fn*(0.01+board_d*0.5),board_d,float(band_spec.get("height_m", 0.09)),trim)
		for pipe: Dictionary in frame.get("pipes",[]):
			var basis: Dictionary = pipe.get("basis",frame)
			var p := vec(basis.start)+vec(basis.tangent)*float(pipe.get("local_station_m",pipe.station_m))
			var low := float(pipe.bottom_y)
			var high := float(pipe.top_y)
			if bool(cfg.get("clamp_pipe_to_eave",false)): high=minf(high,float(cfg.wall_top_y)-0.03)
			# Opt-in pipe style: a downspout with its bends, straps and kick-out (DETAIL).
			if str(pipe.get("style", "")) == "downspout":
				# Under a lower-frontage setback the leader bends back to the lower wall below
				# the band board and the setback's soffit.
				var jetty := 0.0 if recess.is_empty() else float(recess.depth_m)
				var jetty_low := 0.0
				if jetty > 0.0:
					jetty_low = minf(float(recess.band_y), band_y - float(band_spec.get("height_m", 0.09)) * 0.5) - 0.08
				DETAIL.downspout(root,p,vec(basis.tangent),vec(basis.normal),low,high,-1000.0 if cfg.has("broad_band") else band_y,jetty,jetty_low,trim,concrete)
				continue
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
		if skip_wall_runs.has(i/12): continue
		var a := Vector3(vertices[i],vertices[i+1],vertices[i+2])
		var b := Vector3(vertices[i+3],vertices[i+4],vertices[i+5])
		var top := float(cfg.get("wall_top_y", maxf(float(vertices[i+7]),float(vertices[i+10]))))
		var holes: Array[Rect2] = []
		for hole: Rect2 in holes_by_run.get(i/12, []): holes.append(hole)
		var wall_begin := root.get_child_count()
		if recess_runs.has(i/12):
			_recessed_wall(root, a, b, top, holes, siding, trim if recess_soffit == null else recess_soffit, vertices, i/12, recess_runs[i/12], recess, recess_runs)
		elif rear_recess_runs.has(i/12):
			_recessed_wall(root, a, b, top, holes, siding, trim, vertices, i/12, rear_recess_runs[i/12], rear_recess, rear_recess_runs)
		elif not (bool(recess.get("join_runs", false)) and _notched_wall(root, a, b, top, holes, siding, vertices, i/12, recess, recess_runs)):
			PARTS._wall_with_openings(root,a,b,top,holes,siding)
		_tag_since(root,wall_begin,"wall")
		GARAGE_COURT.run_siding(root,wall_begin,i/12,cfg,siding)
		var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n := Vector3(-t.z,0,t.x)
		# vertical_seams true trims every run start; opt-in "corners" only those where the
		# wall turns (more than 15 degrees from the run before), as photos show the boards.
		var seams: Variant = cfg.get("vertical_seams",false)
		if (seams is bool and seams) or (str(seams) == "corners" and _turns_at(vertices,i/12)):
			# With join_runs, a corner where a lower storey stands back takes its board in
			# two: the upper storey's on the corner, the lower storey's on its own corner.
			var lower: Variant = _lower_corner(vertices,i/12,recess_runs,float(recess.depth_m)) if bool(recess.get("join_runs", false)) else null
			if lower is Vector2:
				var band := float(recess.band_y)
				PARTS._panel(root,Vector3(a.x,(band+top)/2,a.z),t,n,Vector3(0.08,top-band,0.08),trim)
				PARTS._panel(root,Vector3(a.x+lower.x,(a.y+band)/2,a.z+lower.y),t,n,Vector3(0.08,band-a.y,0.08),trim)
			else:
				PARTS._panel(root,Vector3(a.x,(a.y+top)/2,a.z),t,n,Vector3(0.08,top-a.y,0.08),trim)
		if not bool(cfg.get("public_roof",{}).get("replace_eave_trim",false)) and not rake_runs.has(i/12):
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
		# Opt-in triangular closures (gablets, soffits), wound as authored.
		for triangle: Array in shallow.get("closure_triangles", []):
			PARTS._mesh(root, [vec(triangle[0]), vec(triangle[1]), vec(triangle[2])], PackedInt32Array([0, 1, 2]), siding)
		# Optional facade.eave_rgb colours only these eave fascia beams; without it they keep the trim material.
		var eave: Material = trim
		var facade_cfg: Dictionary = cfg.get("facade", {})
		if facade_cfg.has("eave_rgb"):
			var rgb: Variant = facade_cfg.eave_rgb
			var valid: bool = rgb is Array and (rgb as Array).size() == 3
			if valid:
				for channel: Variant in rgb:
					valid = valid and (channel is float or channel is int) and float(channel) >= 0.0 and float(channel) <= 1.0
			if valid:
				eave = PARTS._material(Color(float(rgb[0]), float(rgb[1]), float(rgb[2])), 0.8)
			else:
				root.set_meta("build_valid",false)
				push_error("Invalid facade.eave_rgb: %s %s" % [cfg.target.source_key, rgb])
		for edge: Array in shallow.eaves:
			PARTS._beam(root, vec(edge[0]), vec(edge[1]), 0.20, 0.12, eave)
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
	GARAGE_COURT.extras(root,cfg,palette,trim)
	var canopies: Array = cfg.get("carports", []).duplicate()
	if cfg.has("carport") and not cfg.carport.is_empty(): canopies.append(cfg.carport)
	for canopy: Dictionary in canopies:
		_canopy(root,canopy,palette,roofing,trim,siding)
	if not blind_buckets.is_empty() or not utilities.is_empty() or cfg.has("roof_vents") or cfg.has("gable_rakes"):
		var ring := PackedVector2Array()
		for i in range(0, (wall.vertices as Array).size(), 12): ring.append(Vector2(wall.vertices[i], wall.vertices[i+2]))
		if not blind_buckets.is_empty(): DETAIL.commit_blinds(root, blind_buckets, blinds)
		if not utilities.is_empty():
			# Utilities stand clear of the lower walls, which a frontage setback moves in.
			var lower_ring := ring
			if not recess.is_empty():
				var shrunk := Geometry2D.offset_polygon(ring, -float(recess.depth_m))
				if shrunk.size() == 1: lower_ring = shrunk[0]
			DETAIL.commit_utilities(root, utilities, lower_ring)
		# Roof details follow the instance's two-slope roof_plane.
		var plane_ok: bool = (cfg.has("roof_vents") or cfg.has("gable_rakes")) and DETAIL.plane_valid(root, cfg.get("roof_plane"))
		if plane_ok and cfg.has("roof_vents") and DETAIL.vents_valid(root, cfg.roof_vents):
			var front: Dictionary = cfg.target.frames[0]
			var ahead := vec(front.start) + vec(front.normal) * 5.0
			DETAIL.roof_vents(root, cfg.roof_vents, cfg.roof_plane, ring, Vector2(ahead.x, ahead.z))
		if plane_ok and cfg.has("gable_rakes") and DETAIL.rakes_valid(root, cfg.gable_rakes, (wall.vertices as Array).size() / 12):
			DETAIL.gable_rakes(root, cfg.gable_rakes, cfg.roof_plane, wall.vertices, roofing, trim)
	if merge: _merge_parts(root)
	return root

# The parts above are one node and one mesh each (thousands per instance), which
# exhausts renderer resource IDs at island scale. Combine them into one
# MeshInstance3D per (role, shadow, visibility, collision_only) group, with one
# surface per (material, vertex attributes) in first-appearance order. Each
# part's vertices move by its own transform; normals use that transform's
# inverse transpose (renormalized) as the renderer did for sheared beams, and a
# mirroring transform reverses the triangle winding. Each role keeps its parts'
# child order, so contacts and their faces stay deterministic. Standard
# materials merge by the only properties the kit sets (albedo, roughness,
# metallic); shader materials merge only with themselves.
const MAX_SURFACES := 256

static func _merge_parts(root: Node3D) -> void:
	var groups: Array[Dictionary] = []
	var group_index: Dictionary = {}
	for child: Node in root.get_children():
		var part := child as MeshInstance3D
		if part == null or not _mergeable_part(part):
			continue
		var role := str(part.get_meta("family_role", "support"))
		var collision_only := bool(part.get_meta("collision_only", false))
		# Visual-only parts (DETAIL's blinds and utility shells) never join colliding ones.
		var visual_only := bool(part.get_meta("visual_only", false))
		var node_key := [role, int(part.cast_shadow), part.visible, collision_only, visual_only]
		if not group_index.has(node_key):
			group_index[node_key] = groups.size()
			groups.append({"role": role, "cast_shadow": part.cast_shadow, "visible": part.visible, "collision_only": collision_only, "visual_only": visual_only, "surfaces": [], "surface_index": {}})
		var group: Dictionary = groups[group_index[node_key]]
		for s in part.mesh.get_surface_count():
			var material: Material = part.material_override if part.material_override != null else part.mesh.surface_get_material(s)
			var arrays := part.mesh.surface_get_arrays(s)
			var surface_key := [_material_key(material), _attribute_key(arrays)]
			if not group.surface_index.has(surface_key):
				group.surface_index[surface_key] = group.surfaces.size()
				group.surfaces.append({"material": material, "parts": []})
			(group.surfaces[group.surface_index[surface_key]].parts as Array).append([arrays, part.transform])
		root.remove_child(part)
		part.free()
	for group: Dictionary in groups:
		var surfaces: Array = group.surfaces
		for first in range(0, surfaces.size(), MAX_SURFACES):
			var mesh := ArrayMesh.new()
			for surface: Dictionary in surfaces.slice(first, first + MAX_SURFACES):
				mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, _merged_arrays(surface.parts))
				mesh.surface_set_material(mesh.get_surface_count() - 1, surface.material)
			var node := MeshInstance3D.new()
			node.name = "Merged_%s_%d" % [group.role, root.get_child_count()]
			node.mesh = mesh
			node.cast_shadow = group.cast_shadow
			node.visible = group.visible
			node.set_meta("family_role", group.role)
			if group.collision_only: node.set_meta("collision_only", true)
			if group.visual_only: node.set_meta("visual_only", true)
			root.add_child(node)

# The kit's roof, siding and brick shaders pattern by object-space VERTEX, so a
# moved part with a shader material stays its own node (identity-space parts
# keep the same VERTEX when merged).
static func _mergeable_part(part: MeshInstance3D) -> bool:
	if part.mesh == null or not _mergeable(part.mesh, part.transform):
		return false
	if part.transform != Transform3D.IDENTITY:
		if part.material_override is ShaderMaterial:
			return false
		for s in part.mesh.get_surface_count():
			if part.material_override == null and part.mesh.surface_get_material(s) is ShaderMaterial:
				return false
	return true

# Only triangle parts with attributes the merge carries (vertex, normal,
# tangent, UV, colour, index), an invertible transform, and indexed geometry
# when the transform mirrors, are merged; anything else stays its own node.
static func _mergeable(mesh: Mesh, transform: Transform3D) -> bool:
	var det := transform.basis.determinant()
	if absf(det) < 1e-9:
		return false
	if mesh is ArrayMesh:
		for s in mesh.get_surface_count():
			if (mesh as ArrayMesh).surface_get_primitive_type(s) != Mesh.PRIMITIVE_TRIANGLES:
				return false
	elif not mesh is BoxMesh:
		return false
	for s in mesh.get_surface_count():
		var arrays := mesh.surface_get_arrays(s)
		for a in Mesh.ARRAY_MAX:
			if arrays[a] != null and a not in [Mesh.ARRAY_VERTEX, Mesh.ARRAY_NORMAL, Mesh.ARRAY_TANGENT, Mesh.ARRAY_TEX_UV, Mesh.ARRAY_COLOR, Mesh.ARRAY_INDEX]:
				return false
		if det < 0.0 and arrays[Mesh.ARRAY_INDEX] == null:
			return false
	return true

# Parts merge only with parts carrying the same vertex attributes and indexing.
static func _attribute_key(arrays: Array) -> Array:
	var present: Array[bool] = []
	for attribute in arrays: present.append(attribute != null)
	return present

static func _merged_arrays(parts: Array) -> Array:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var tangents := PackedFloat32Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	for item: Array in parts:
		var arrays: Array = item[0]
		var xform: Transform3D = item[1]
		var normal_basis := xform.basis.inverse().transposed()
		var base := vertices.size()
		for v: Vector3 in arrays[Mesh.ARRAY_VERTEX]: vertices.append(xform * v)
		if arrays[Mesh.ARRAY_NORMAL] != null:
			for n: Vector3 in arrays[Mesh.ARRAY_NORMAL]: normals.append((normal_basis * n).normalized())
		if arrays[Mesh.ARRAY_TANGENT] != null:
			var t: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]
			for i in range(0, t.size(), 4):
				var d := (xform.basis * Vector3(t[i], t[i + 1], t[i + 2])).normalized()
				tangents.append_array(PackedFloat32Array([d.x, d.y, d.z, t[i + 3]]))
		if arrays[Mesh.ARRAY_TEX_UV] != null: uvs.append_array(arrays[Mesh.ARRAY_TEX_UV])
		if arrays[Mesh.ARRAY_COLOR] != null: colors.append_array(arrays[Mesh.ARRAY_COLOR])
		if arrays[Mesh.ARRAY_INDEX] != null:
			var source: PackedInt32Array = arrays[Mesh.ARRAY_INDEX]
			if xform.basis.determinant() < 0.0:
				for i in range(0, source.size(), 3): indices.append_array(PackedInt32Array([base + source[i], base + source[i + 2], base + source[i + 1]]))
			else:
				for i: int in source: indices.append(base + i)
	var out: Array = []
	out.resize(Mesh.ARRAY_MAX)
	out[Mesh.ARRAY_VERTEX] = vertices
	if not normals.is_empty(): out[Mesh.ARRAY_NORMAL] = normals
	if not tangents.is_empty(): out[Mesh.ARRAY_TANGENT] = tangents
	if not uvs.is_empty(): out[Mesh.ARRAY_TEX_UV] = uvs
	if not colors.is_empty(): out[Mesh.ARRAY_COLOR] = colors
	if not indices.is_empty(): out[Mesh.ARRAY_INDEX] = indices
	return out

static func _material_key(material: Material) -> Variant:
	var standard := material as StandardMaterial3D
	if standard != null and standard.get_class() == "StandardMaterial3D":
		return ["standard", standard.albedo_color, standard.roughness, standard.metallic, standard.disable_receive_shadows]
	return material

static func _canopy(root: Node3D, cfg: Dictionary, palette: Dictionary, roof: Material, trim: Material, siding: Material = null) -> void:
	if not cfg.has("frame") or not cfg.has("station_m"): return
	if str(cfg.get("form", "flat")) == "gable":
		_gable_canopy(root, cfg, palette, roof, trim, siding)
		return
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
	# Opt-in underside_rgb lightens the soffit; joist_spacing_m hangs cross joists under it.
	var underside := PARTS._material(color(cfg,"underside_rgb",Color(0.16,0.20,0.19)),0.97)
	PARTS._beam(root,a-Vector3(0,0.10,0),b-Vector3(0,0.10,0),depth-0.10,0.025,underside)
	if cfg.has("joist_spacing_m") and float(cfg.joist_spacing_m) >= 0.5:
		var joist := PARTS._material(color(cfg,"joist_rgb",Color(0.3,0.3,0.29)),0.95)
		var station := float(cfg.station_m[0])+float(cfg.joist_spacing_m)*0.5
		while station < float(cfg.station_m[1]):
			var j := start+t*station
			j.y = a.y-0.1825
			PARTS._beam(root,j+n*(float(cfg.depth_m[0])+0.07),j+n*(float(cfg.depth_m[1])-0.07),0.07,0.14,joist)
			station += float(cfg.joist_spacing_m)
	var steel := PARTS._material(color(palette,"carport_post_rgb",Color(0.35,0.3,0.25)),0.9)
	var fascia: Material = trim
	if cfg.has("fascia_rgb"): fascia = PARTS._material(color(cfg,"fascia_rgb",Color.GRAY),0.96)
	for d in cfg.depth_m:
		PARTS._beam(root,a+n*(float(d)-middle),b+n*(float(d)-middle),0.13,0.29,fascia)
		# Opt-in fascia_top_rgb: a weathered strip along the fascia's top edge.
		if cfg.has("fascia_top_rgb"):
			PARTS._beam(root,a+n*(float(d)-middle)+Vector3(0,0.1575,0),b+n*(float(d)-middle)+Vector3(0,0.1575,0),0.135,0.025,PARTS._material(color(cfg,"fascia_top_rgb",Color.GRAY),0.97))
	for post: Dictionary in cfg.get("posts", []):
		var p := start+t*float(post.station_m)+n*float(post.depth_m)
		var bottom := float(post.bottom_y)
		p.y = (a.y+bottom)/2
		PARTS._panel(root,p,t,n,Vector3(0.09,a.y-bottom,0.09),steel)
		# Opt-in post_bands [[from_m, to_m, rgb], ...]: painted bands up from the post's foot,
		# each stopping at the post's top.
		for band: Array in cfg.get("post_bands", []):
			var low := float(band[0])
			var high := minf(float(band[1]), a.y-bottom)
			if high <= low: continue
			var q := start+t*float(post.station_m)+n*float(post.depth_m)
			q.y = bottom+(low+high)*0.5
			PARTS._panel(root,q,t,n,Vector3(0.1,high-low,0.1),PARTS._material(Color(float(band[2][0]),float(band[2][1]),float(band[2][2])),0.7))

# Opt-in gable-front canopy over an open bay: the ridge runs along the frame
# normal from the host wall to the bay front. Its two roof planes carry the
# bay's roof role; gable ends, soffit, trim and posts keep the flat carport's
# support role. The gables take the instance siding unless gable_rgb is set;
# roof_rgb gives the canopy its own roofing colour. Dimensions are
# instance-config production inference.
static func _gable_canopy(root: Node3D, cfg: Dictionary, palette: Dictionary, roof: Material, trim: Material, siding: Material) -> void:
	var frame: Dictionary = cfg.frame
	var o := vec(frame.start)
	var t := vec(frame.tangent)
	var n := vec(frame.normal)
	var s0 := float(cfg.station_m[0])
	var s1 := float(cfg.station_m[1])
	var d0 := float(cfg.depth_m[0])
	var d1 := float(cfg.depth_m[1])
	var eave := float(cfg.eave_y)
	var ridge := float(cfg.ridge_y)
	var soffit := float(cfg.get("soffit_y", eave - 0.16))
	var mid := (s0 + s1) * 0.5
	var gable: Material = siding if siding != null else trim
	if cfg.has("gable_rgb"): gable = PARTS._material(color(cfg, "gable_rgb", Color.WHITE), 0.9)
	var roofing := roof
	if cfg.has("roof_rgb"):
		var own_roof := ShaderMaterial.new()
		own_roof.shader = ROOF
		own_roof.set_shader_parameter("roof_color", color(cfg, "roof_rgb", Color(0.52, 0.54, 0.52)))
		roofing = own_roof
	var under := PARTS._material(color(cfg, "soffit_rgb", Color(0.78, 0.78, 0.75)), 0.95)
	var steel := PARTS._material(color(palette, "carport_post_rgb", Color(0.35, 0.3, 0.25)), 0.9)
	var l0 := _bay_point(o, t, n, s0, eave, d0)
	var l1 := _bay_point(o, t, n, s0, eave, d1)
	var r0 := _bay_point(o, t, n, s1, eave, d0)
	var r1 := _bay_point(o, t, n, s1, eave, d1)
	var k0 := _bay_point(o, t, n, mid, ridge, d0)
	var k1 := _bay_point(o, t, n, mid, ridge, d1)
	var sl0 := _bay_point(o, t, n, s0, soffit, d0)
	var sl1 := _bay_point(o, t, n, s0, soffit, d1)
	var sr0 := _bay_point(o, t, n, s1, soffit, d0)
	var sr1 := _bay_point(o, t, n, s1, soffit, d1)
	for plane: Array in [[l0, l1, k1, k0], [k0, k1, r1, r0]]:
		_facing(root, plane, Vector3.UP, roofing)
		root.get_child(-1).set_meta("family_role", "roof")
	_facing(root, [sl0, sr0, sr1, sl1], Vector3.DOWN, under)
	_facing(root, [sl0, sl1, l1, l0], -t, trim)
	_facing(root, [sr0, sr1, r1, r0], t, trim)
	_facing(root, [sl1, sr1, r1, l1], n, trim)
	_facing(root, [l1, r1, k1], n, gable)
	_facing(root, [sl0, sr0, r0, l0], -n, gable)
	_facing(root, [l0, r0, k0], -n, gable)
	# Rake boards stand just proud of the front gable; eave boards follow each side.
	var edge := float(cfg.get("trim_width_m", 0.07))
	_edge_beam(root, l1 + n * (edge * 0.5 + 0.005), k1 + n * (edge * 0.5 + 0.005), edge, trim)
	_edge_beam(root, k1 + n * (edge * 0.5 + 0.005), r1 + n * (edge * 0.5 + 0.005), edge, trim)
	_edge_beam(root, l0 - t * edge * 0.5, l1 - t * edge * 0.5, edge, trim)
	_edge_beam(root, r0 + t * edge * 0.5, r1 + t * edge * 0.5, edge, trim)
	var post_width := float(cfg.get("post_width_m", 0.12))
	for post: Dictionary in cfg.get("posts", []):
		var bottom := float(post.bottom_y)
		var center := _bay_point(o, t, n, float(post.station_m), (bottom + soffit) * 0.5, float(post.depth_m))
		var node := PARTS._box(root, center, Vector3(post_width, soffit - bottom, post_width), steel)
		node.basis = Basis(t, Vector3.UP, n)

static func _bay_point(o: Vector3, t: Vector3, n: Vector3, station: float, y: float, depth: float) -> Vector3:
	var p := o + t * station + n * depth
	p.y = y
	return p

# One planar convex polygon whose rendered face points along outward
# (the producer's clockwise convention: rendered normal is -(b-a)x(c-a)).
static func _facing(root: Node3D, pts: Array, outward: Vector3, m: Material) -> void:
	var a: Vector3 = pts[0]
	var b: Vector3 = pts[1]
	var c: Vector3 = pts[2]
	var flip := (b - a).cross(c - a).dot(outward) > 0.0
	var indices := PackedInt32Array()
	for i in range(1, pts.size() - 1):
		indices.append_array(PackedInt32Array([0, i + 1, i]) if flip else PackedInt32Array([0, i, i + 1]))
	PARTS._mesh(root, pts, indices, m)

static func _edge_beam(root: Node3D, a: Vector3, b: Vector3, width: float, m: Material) -> void:
	var x := (b - a).normalized()
	var z := x.cross(Vector3.UP).normalized()
	var node := PARTS._box(root, (a + b) * 0.5, Vector3(a.distance_to(b), width, width), m)
	node.basis = Basis(x, z.cross(x), z)

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

## Whether the wall ring turns more than 15 degrees where run `run` starts (from the
## run before it in the ring).
static func _turns_at(vertices: Array, run: int) -> bool:
	var count := vertices.size() / 12
	var before := posmod(run - 1, count) * 12
	var here := run * 12
	var a := Vector2(float(vertices[before + 3]) - float(vertices[before]), float(vertices[before + 5]) - float(vertices[before + 2])).normalized()
	var b := Vector2(float(vertices[here + 3]) - float(vertices[here]), float(vertices[here + 5]) - float(vertices[here + 2])).normalized()
	return a.dot(b) < cos(deg_to_rad(15.0))


static func _tag_since(root: Node3D, begin: int, role: String) -> void:
	for i in range(begin,root.get_child_count()):
		root.get_child(i).set_meta("family_role",role)

# Keep the upper receiver and frozen roof in place. The complete lower wall,
# openings and return shell move inward; dimensions are production inference.
## recessed: every run with this setback (run -> frame). Opt-in recess.join_runs takes a
## run's neighbours from the wall ring instead of its frame: a recessed neighbour in any
## frame meets it at the offset-line miter, and next to an unrecessed one the lower wall
## runs to the corner with no terminal strip (_notched_wall meets it there).
static func _recessed_wall(root: Node3D, a: Vector3, b: Vector3, top: float, holes: Array[Rect2], siding: Material, soffit: Material, vertices: Array, run: int, frame: Dictionary, recess: Dictionary, recessed: Dictionary = {}) -> void:
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
	var join := bool(recess.get("join_runs", false))
	var count := vertices.size() / 12
	var before := -1
	var after := -1
	if join:
		if recessed.has(posmod(run-1,count)): before = posmod(run-1,count)
		if recessed.has(posmod(run+1,count)): after = posmod(run+1,count)
	else:
		if position > 0: before = runs[position-1]
		if position < runs.size()-1: after = runs[position+1]
	var lo := 0.05 if before < 0 and not join else 0.0
	var hi := length-0.05 if after < 0 and not join else length
	var outer_a := a.lerp(b,lo/length)
	var outer_b := a.lerp(b,hi/length)
	var inner_a := outer_a-n*depth
	var inner_b := outer_b-n*depth
	# Adjacent serialized source runs meet at a shared offset-line miter.
	if before >= 0:
		var previous := before*12
		var pt := Vector3(vertices[previous+3]-vertices[previous],0,vertices[previous+5]-vertices[previous+2]).normalized()
		var pn := Vector3(-pt.z,0,pt.x)
		inner_a = outer_a-(n+pn)*depth/(1.0+n.dot(pn))
	if after >= 0:
		var following := after*12
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

## recess.join_runs: an unrecessed run beside a recessed one (in the wall ring). Its
## upper storey runs the whole run; its lower storey stops short of an outside corner,
## or runs on past an inside one, to meet the neighbour's set-back lower wall under the
## overhang. Returns false, building nothing, when neither neighbour is recessed.
static func _notched_wall(root: Node3D, a: Vector3, b: Vector3, top: float, holes: Array[Rect2], siding: Material, vertices: Array, run: int, recess: Dictionary, recessed: Dictionary) -> bool:
	var count := vertices.size() / 12
	var previous := posmod(run-1,count)
	var following := posmod(run+1,count)
	if not (recessed.has(previous) or recessed.has(following)):
		return false
	var t := Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var length := Vector2(b.x-a.x,b.z-a.z).length()
	var band := float(recess.band_y)
	var depth := float(recess.depth_m)
	var start := 0.0
	var end := length
	# Where this run's line meets the neighbour's set-back line (depth behind its face).
	if recessed.has(previous):
		var k := Vector2(t.x,t.z).dot(_run_normal(vertices,previous))
		if absf(k) > 0.25: start = -depth/k
	if recessed.has(following):
		var k := Vector2(t.x,t.z).dot(_run_normal(vertices,following))
		if absf(k) > 0.25: end = length-depth/k
	PARTS._wall_with_openings(root,Vector3(a.x,band,a.z),Vector3(b.x,band,b.z),top,_clipped_holes(holes,0,length,band,top),siding)
	var low_a := a+t*start
	var low_b := a+t*end
	low_a.y = lerpf(a.y,b.y,start/length)
	low_b.y = lerpf(a.y,b.y,end/length)
	PARTS._wall_with_openings(root,low_a,low_b,band,_clipped_holes(holes,start,end,minf(a.y,b.y),band),siding)
	return true


## recess.join_runs: where the lower storey's walls meet at the start of run `run`,
## as an XZ offset from the run's start: the crossing of the two runs' lower wall
## lines, each `depth` behind its face when recessed. Null when neither is recessed
## or the runs are nearly parallel.
static func _lower_corner(vertices: Array, run: int, recessed: Dictionary, depth: float) -> Variant:
	var previous := posmod(run-1,vertices.size()/12)
	var dp := depth if recessed.has(previous) else 0.0
	var di := depth if recessed.has(run) else 0.0
	if dp == 0.0 and di == 0.0:
		return null
	var np := _run_normal(vertices,previous)
	var ni := _run_normal(vertices,run)
	var det := np.x*ni.y-np.y*ni.x
	if absf(det) < 0.2:
		return null
	return Vector2((-dp*ni.y+di*np.y)/det,(-di*np.x+dp*ni.x)/det)


## A ring run's outward normal in XZ.
static func _run_normal(vertices: Array, run: int) -> Vector2:
	var i := run*12
	var t := Vector2(float(vertices[i+3])-float(vertices[i]),float(vertices[i+5])-float(vertices[i+2])).normalized()
	return Vector2(-t.y,t.x)


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
