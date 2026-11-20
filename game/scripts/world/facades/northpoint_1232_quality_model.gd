extends RefCounted

# Reviewed whole-building construction; live factory assigns exact geometry contacts.
# The housing family's roof shader, for an opt-in roof_rgb (no new shader program).
const FAMILY_ROOF := preload("res://game/resources/housing_family/roof.gdshader")
## The production roof's frame: along the ridge, across it, and the ridge line's offset
## across. An opt-in roof_plane must be given in this frame.
const ROOF_AXIS := Vector2(-0.04894628457,0.9988014123)
const ROOF_NORMAL := Vector2(-0.9988014123,-0.04894628457)
const ROOF_RIDGE_D := 336.328678
## The frontage's frame origin (stations along ROOF_AXIS, depths along ROOF_NORMAL) and its
## bands, in metres: 2 m strips from FRONTAGE_STATIONS[0] to [1], lawn, walk and parking
## asphalt by depth, stall lines FRONTAGE_LINE_WIDTH_M wide every 4 m from the first station,
## over FRONTAGE_LINE_DEPTH_M of the asphalt, all FRONTAGE_LIFT_M over the colliding land.
const FRONTAGE_ORIGIN := Vector2(-305.509,-741.527)
const FRONTAGE_STATIONS := [-14,16]
const FRONTAGE_LAWN_M := [0.15,3.0]
const FRONTAGE_WALK_M := [3.0,4.15]
const FRONTAGE_ASPHALT_M := [4.15,8.50]
const FRONTAGE_LINE_DEPTH_M := [4.30,8.40]
const FRONTAGE_LINE_WIDTH_M := 0.07
const FRONTAGE_LIFT_M := 0.055
# Footprint is read verbatim from the frozen wall record. Unmeasured detail is art inference.
## options (from the live factory's revision config): "frontage_parking_from_m", the
## frontage station (origin frame below) where the parking begins; north of it the
## lawn and parking strips and stall lines are left out, so the island's own ground
## shows round the walk, as the dated photos show. "frontage_asphalt_rgb": the
## parking strips' colour. "roof_plane" (the housing family config's, which the live
## factory passes on): the roof as one gable per footprint segment (_segment_roof), the
## same description the family's roof details follow. Absent: everything as before.
static func build(record: Dictionary, ground: Callable, options: Dictionary = {}) -> Node3D:
	var root := Node3D.new()
	root.name = "Northpoint1232ScratchStudy"
	var siding := _material(Color(0.65,0.69,0.66),0.86)
	var shader := ShaderWarmUp.shared_shader("shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float line=smoothstep(0.88,0.98,fract(wp.y/0.155)); float n=fract(sin(dot(floor(wp.xz*45.0),vec2(12.9898,78.233)))*43758.5453); ALBEDO=vec3(0.27,0.33,0.34)*(1.0-line*0.28)+(n-0.5)*0.012; ROUGHNESS=0.86;}")
	var clad := ShaderMaterial.new()
	clad.shader=shader
	var trim := _material(Color(0.87,0.88,0.82),0.72)
	var dark := _material(Color(0.07,0.13,0.16),0.36)
	var glass := _material(Color(0.25,0.34,0.36),0.23)
	var door := _material(Color(0.075,0.13,0.19),0.7)
	var roofshader:=ShaderWarmUp.shared_shader("shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float row=floor(wp.x*5.0);float cell=floor(wp.z*4.0+mod(row,2.0)*0.5);float n=fract(sin(row*12.9898+cell*78.233)*43758.5453);ALBEDO=vec3(0.23,0.25,0.23)+(n-0.5)*0.075;ROUGHNESS=0.94;}")
	var roofmat:=ShaderMaterial.new();roofmat.shader=roofshader
	# Opt-in roof_rgb: the roof in the family's roof shader and that colour.
	if options.has("roof_rgb"):
		var roof_rgb: Array = options.roof_rgb
		roofmat.shader=FAMILY_ROOF
		roofmat.set_shader_parameter("roof_color",Color(float(roof_rgb[0]),float(roof_rgb[1]),float(roof_rgb[2])))
	var steel := _material(Color(0.30,0.26,0.20),0.85)
	var fascia_shader:=ShaderWarmUp.shared_shader("shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float a=fract(sin(dot(floor(wp.xz*14.0),vec2(12.9898,78.233)))*43758.5453); float b=fract(sin(dot(floor(wp.xz*2.0),vec2(39.346,11.135)))*15347.231); ALBEDO=vec3(0.42,0.43,0.39)+(a-0.5)*0.075+(b-0.5)*0.055; ROUGHNESS=0.95;}")
	var fascia:=ShaderMaterial.new();fascia.shader=fascia_shader
	var rust:=_material(Color(0.39,0.27,0.17),0.95)
	var underside:=_material(Color(0.16,0.20,0.19),0.97)
	var concrete := _material(Color(0.56,0.57,0.51),0.95)
	var asphalt := _material(Color(0.16,0.18,0.18),0.98)
	if options.has("frontage_asphalt_rgb"):
		var rgb: Array = options.frontage_asphalt_rgb
		asphalt = _material(Color(float(rgb[0]),float(rgb[1]),float(rgb[2])),0.98)
	# The island's asphalt specular (world_chunk_builder.gd ASPHALT_SPECULAR): at the default 0.5
	# the dark pad mirrored the sky at a walker's grazing view and read navy beside the grey road.
	asphalt.metallic_specular = 0.25
	var lawn := _material(Color(0.29,0.36,0.15),0.98)
	var verts: Array=record.vertices
	var polygon := PackedVector2Array()
	var edges: Array=[]
	for i in range(0,verts.size(),12):
		var a:=Vector3(verts[i],verts[i+1],verts[i+2])
		var b:=Vector3(verts[i+3],verts[i+4],verts[i+5])
		polygon.append(Vector2(a.x,a.z));edges.append([a,b])
		var t:=Vector3(b.x-a.x,0,b.z-a.z).normalized()
		var n:=Vector3(-t.z,0,t.x)
		var length:=Vector2(b.x-a.x,b.z-a.z).length()
		var holes:Array[Rect2]=[]
		var index:int=i/12
		if index>=10 and index<=18 and length>2.8:
			var count:=maxi(1,int(round(length/2.8)))
			for j in count:
				var station:float=length*(j+0.5)/count
				var w:float=minf(1.78,length/count-0.55)
				holes.append(Rect2(station-w/2.0,6.30,w,1.30))
				_recessed_window(root,Vector3(a.x,6.95,a.z)+t*station,t,n,w,1.30,trim,dark,glass)
			# The visible lower vocabulary is a grouped entry and wider sitting-room window.
			if length>4.0:
				var window_s:float=length*0.34
				holes.append(Rect2(window_s-0.76,3.55,1.52,1.34))
				_recessed_window(root,Vector3(a.x,4.22,a.z)+t*window_s,t,n,1.52,1.34,trim,dark,glass)
				var door_s:float=length*0.78
				var p:=Vector3(a.x,0,a.z)+t*door_s
				var base:=float(ground.call(Vector2(p.x+n.x*0.25,p.z+n.z*0.25)))+0.025
				holes.append(Rect2(door_s-0.46,base,0.92,2.13))
				_entry(root,p+Vector3(0,base+1.065,0),t,n,trim,door,concrete)
				_ground_strip(root,Vector2(p.x,p.z),Vector2(t.x,t.z),Vector2(n.x,n.z),1.2,0.04,3.15,ground,concrete,0.075)
				var screenp:=Vector3(p.x,base+0.60,p.z)+t*0.85+n*0.66
				_panel(root,screenp,t,n,Vector3(0.055,1.18,1.28),clad)
				root.get_child(-1).set_meta("physical_role", "detail")
				for rail in [0.0,1.18]:
					_panel(root,Vector3(p.x,base+rail,p.z)+t*0.85+n*0.66,t,n,Vector3(0.09,0.065,1.35),trim)
			else:
				holes.append(Rect2(length/2.0-0.69,3.60,1.38,1.22))
				_recessed_window(root,Vector3(a.x,4.21,a.z)+t*length/2.0,t,n,1.38,1.22,trim,dark,glass)
		_wall_with_openings(root,a,b,8.05,holes,clad)
		_beam(root,Vector3(a.x,8.00,a.z)+n*0.15,Vector3(b.x,8.00,b.z)+n*0.15,0.57,0.105,trim)
		_beam(root,Vector3(a.x,8.085,a.z)+n*0.41,Vector3(b.x,8.085,b.z)+n*0.41,0.10,0.18,trim)
		_beam(root,Vector3(a.x,8.135,a.z)+n*0.455,Vector3(b.x,8.135,b.z)+n*0.455,0.065,0.075,roofmat)
		# Foundation trim must not bridge the authored doorway void.
		var band_spans: Array[Vector2] = [Vector2(0.0,length)]
		for hole: Rect2 in holes:
			if hole.position.y > 2.725 or hole.end.y < 2.575: continue
			var next_spans: Array[Vector2] = []
			for span: Vector2 in band_spans:
				var cut_a := maxf(span.x,hole.position.x-0.10)
				var cut_b := minf(span.y,hole.end.x+0.10)
				if cut_a >= cut_b: next_spans.append(span)
				else:
					if cut_a > span.x: next_spans.append(Vector2(span.x,cut_a))
					if cut_b < span.y: next_spans.append(Vector2(cut_b,span.y))
			band_spans = next_spans
		for span: Vector2 in band_spans:
			_beam(root,Vector3(a.x,2.65,a.z)+t*span.x+n*0.012,Vector3(a.x,2.65,a.z)+t*span.y+n*0.012,0.045,0.15,concrete)
		if length>2.5:
			_panel(root,Vector3(a.x,5.30,a.z)+n*0.02,t,n,Vector3(0.09,5.46,0.08),trim)
	var roof_start := root.get_child_count()
	# Two planar roof slopes clipped to the exact footprint; ridge follows long axis.
	var tan:=ROOF_AXIS
	var norm:=ROOF_NORMAL
	var ridge_d:=ROOF_RIDGE_D
	var segmented:=options.has("roof_plane")
	if segmented:
		# The live factory refuses a roof_plane in another frame before it gets here.
		if same_roof_frame(options.roof_plane):
			_segment_roof(root,options.roof_plane,polygon,edges,tan,norm,ridge_d,roofmat,trim,clad)
		else:
			push_error("roof_plane is not in the production roof's frame (ROOF_AXIS, ROOF_NORMAL, ROOF_RIDGE_D)")
	for side in ([] if segmented else [-1.0,1.0]):
		var clip:=PackedVector2Array()
		for st in [Vector2(-800,0),Vector2(-650,0),Vector2(-650,30*side),Vector2(-800,30*side)]:
			clip.append(tan*st.x+norm*(ridge_d+st.y))
		for part in Geometry2D.intersect_polygons(polygon,clip):
			var ids:=Geometry2D.triangulate_polygon(part)
			var pts:Array=[]
			for p in part: pts.append(Vector3(p.x,9.68-abs(p.dot(norm)-ridge_d)*0.25,p.y))
			_mesh(root,pts,ids,roofmat)
	for edge in ([] if segmented else edges):
		var a:Vector3=edge[0];var b:Vector3=edge[1]
		var da:=Vector2(a.x,a.z).dot(norm)-ridge_d
		var db:=Vector2(b.x,b.z).dot(norm)-ridge_d
		var line:Array[Vector3]=[a]
		if da*db<0.0:line.append(a.lerp(b,da/(da-db)))
		line.append(b)
		for j in range(line.size()-1):
			var u:Vector3=line[j];var v:Vector3=line[j+1]
			var uy:float=9.68-abs(Vector2(u.x,u.z).dot(norm)-ridge_d)*0.25
			var vy:float=9.68-abs(Vector2(v.x,v.z).dot(norm)-ridge_d)*0.25
			_quad(root,[Vector3(u.x,8.05,u.z),Vector3(v.x,8.05,v.z),Vector3(v.x,vy,v.z),Vector3(u.x,uy,u.z)],clad)
			_beam(root,Vector3(u.x,uy,u.z),Vector3(v.x,vy,v.z),0.22,0.11,trim)
	# Continuous ridge and small roof penetrations follow the shallow residential roof vocabulary.
	var ridge_a:=tan*(-739.65)+norm*ridge_d
	var ridge_b:=tan*(-696.48)+norm*ridge_d
	if not segmented: _beam(root,Vector3(ridge_a.x,9.70,ridge_a.y),Vector3(ridge_b.x,9.70,ridge_b.y),0.17,0.075,roofmat)
	for station in ([] if segmented else [-736.0,-730.0,-723.5,-717.0,-710.5,-704.0]):
		var p:Vector2=tan*station+norm*(ridge_d+0.8)
		var stem:=CylinderMesh.new();stem.top_radius=0.055;stem.bottom_radius=0.055;stem.height=0.28;stem.radial_segments=8
		var pipe:=MeshInstance3D.new();pipe.mesh=stem;pipe.material_override=trim;pipe.position=Vector3(p.x,9.64,p.y);root.add_child(pipe)
		_box(root,Vector3(p.x,9.79,p.y),Vector3(0.16,0.025,0.16),roofmat)
	for i in range(roof_start, root.get_child_count()):
		var roof_mesh := root.get_child(i) as MeshInstance3D
		roof_mesh.set_meta("physical_role", "wall" if roof_mesh.material_override == clad else "roof")
	# Immediate frontage: ground follows actual colliding land; no terrain replacement.
	var origin:=FRONTAGE_ORIGIN
	var parking_from:=float(options.get("frontage_parking_from_m",-INF))
	_frontage(root,origin,tan,norm,parking_from,ground,lawn,concrete,asphalt,trim)
	# Long flat carport, deliberately light edge and shallow weathered fascia.
	var canopy_a:=origin+tan*(-14.0)+norm*6.35
	var canopy_b:=origin+tan*14.0+norm*6.35
	var ca:=Vector3(canopy_a.x,5.42,canopy_a.y);var cb:=Vector3(canopy_b.x,5.42,canopy_b.y)
	_beam(root,ca,cb,4.15,0.12,roofmat)
	_beam(root,ca-Vector3(0,0.07,0),cb-Vector3(0,0.07,0),3.99,0.02,underside)
	for d in [4.27,8.43]:
		var a2:Vector2=origin+tan*(-14.0)+norm*d;var b2:Vector2=origin+tan*14.0+norm*d
		_beam(root,Vector3(a2.x,5.36,a2.y),Vector3(b2.x,5.36,b2.y),0.11,0.24,fascia)
		_beam(root,Vector3(a2.x,5.49,a2.y),Vector3(b2.x,5.49,b2.y),0.12,0.035,rust)
	for s in range(-14,15,4):
		var inner:Vector2=origin+tan*s+norm*4.35
		var outer:Vector2=origin+tan*s+norm*8.35
		_beam(root,Vector3(inner.x,5.25,inner.y),Vector3(outer.x,5.25,outer.y),0.09,0.18,underside)
		var p:=origin+tan*s+norm*8.35;var y:=float(ground.call(p))
		_box(root,Vector3(p.x,(y+5.28)*0.5,p.y),Vector3(0.085,5.28-y,0.085),steel)
		_box(root,Vector3(p.x,y+0.65,p.y),Vector3(0.095,0.18,0.095),trim)
	# A few small foundation shrubs; no giant foliage used to conceal architecture.
	var green:=_material(Color(0.18,0.26,0.105),0.95)
	for s in [-12.0,-6.0,1.5,10.5]:
		var p:Vector2=origin+tan*s+norm*0.9
		var sphere:=SphereMesh.new();sphere.radius=0.35;sphere.height=0.5
		var mi:=MeshInstance3D.new();mi.mesh=sphere;mi.material_override=green;mi.position=Vector3(p.x,float(ground.call(p))+0.22,p.y);root.add_child(mi);mi.set_meta("physical_role", "ground_visual")
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			if not mesh.has_meta("physical_role"):
				mesh.set_meta("physical_role", "wall" if mesh.material_override == clad else "detail")
	return root

static func _material(color:Color,rough:float)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=color;m.roughness=rough;return m
static func _box(root:Node3D,p:Vector3,size:Vector3,m:Material)->MeshInstance3D:
	var mesh:=BoxMesh.new();mesh.size=size;var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=m;node.position=p;root.add_child(node);return node
static func _panel(root:Node3D,p:Vector3,t:Vector3,n:Vector3,size:Vector3,m:Material)->void:
	var node:=_box(root,p+n*0.06,size,m);node.basis=Basis(t,Vector3.UP,n)
static func _beam(root:Node3D,a:Vector3,b:Vector3,depth:float,height:float,m:Material)->void:
	var t:=(b-a).normalized();var n:=Vector3(-t.z,0,t.x);var node:=_box(root,(a+b)*0.5,Vector3(a.distance_to(b),height,depth),m);node.basis=Basis(t,Vector3.UP,n)
static func _quad(root:Node3D,pts:Array,m:Material,wall_face:bool=true)->void:
	_mesh(root,pts,PackedInt32Array([0,2,1,0,3,2]) if wall_face else PackedInt32Array([0,1,2,0,2,3]),m)
static func _mesh(root:Node3D,pts:Array,indices:PackedInt32Array,m:Material)->void:
	var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in indices: st.add_vertex(pts[i])
	st.generate_normals();var node:=MeshInstance3D.new();node.mesh=st.commit();node.material_override=m;root.add_child(node)
## The frontage's lawn, walk and parking asphalt with its stall lines, as one mesh per
## surface. The walk runs the whole frontage; lawn and asphalt only the 2 m strips whose
## middle lies at or past parking_from, as do the stall lines. The lines are cut into the
## asphalt rather than laid over it, and every corner is sampled from the land once and
## shared by the cells that meet there, so no two surfaces overlap (nothing to z-fight) and
## no seam opens between them. Each mesh carries its ground_surface (lawn, walk, asphalt or
## paint).
static func _frontage(root:Node3D,origin:Vector2,tan:Vector2,norm:Vector2,parking_from:float,ground:Callable,lawn:Material,concrete:Material,asphalt:Material,paint:Material)->void:
	var first:int=FRONTAGE_STATIONS[0];var last:int=FRONTAGE_STATIONS[1]
	var parked:=float(last)
	for s in range(first,last,2):
		if s+1.0>=parking_from:
			parked=float(s);break
	var lines:Array[Vector2]=[]
	for s in range(first,last,4):
		if parked>=float(last) or float(s)<parking_from: continue
		var a:=clampf(float(s)-FRONTAGE_LINE_WIDTH_M*0.5,parked,float(last)-FRONTAGE_LINE_WIDTH_M)
		lines.append(Vector2(a,a+FRONTAGE_LINE_WIDTH_M))
	var stations:Array[float]=[]
	for s in range(first,last+1,2): stations.append(float(s))
	for line in lines: stations.append_array([line.x,line.y])
	stations.sort()
	var corners:={}
	var at:=func(s:float,d:float)->Vector3:
		var key:=Vector2(s,d)
		if not corners.has(key):
			var p:Vector2=origin+tan*s+norm*d
			corners[key]=Vector3(p.x,float(ground.call(p))+FRONTAGE_LIFT_M,p.y)
		return corners[key]
	var bands:Array=[["lawn",lawn,parked,FRONTAGE_LAWN_M],["walk",concrete,float(first),FRONTAGE_WALK_M],["asphalt",asphalt,parked,[FRONTAGE_ASPHALT_M[0],FRONTAGE_LINE_DEPTH_M[0],FRONTAGE_LINE_DEPTH_M[1],FRONTAGE_ASPHALT_M[1]]]]
	var tools:={}
	for band:Array in bands:
		var depths:Array=band[3]
		for i in range(stations.size()-1):
			var s0:float=stations[i];var s1:float=stations[i+1]
			if s0<float(band[2])-0.0001 or s1-s0<0.0001: continue
			# A strip boundary may cross a line, so a line can span more than one interval.
			var line:=false
			for l in lines: line=line or (s0>=l.x-0.0001 and s1<=l.y+0.0001)
			for j in range(depths.size()-1):
				var d0:float=depths[j];var d1:float=depths[j+1]
				var surface:String=band[0]
				var m:Material=band[1]
				if surface=="asphalt" and line and is_equal_approx(d0,FRONTAGE_LINE_DEPTH_M[0]):
					surface="paint";m=paint
				if not tools.has(surface):
					var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
					tools[surface]=[st,m]
				var pts:Array=[at.call(s0,d0),at.call(s1,d0),at.call(s1,d1),at.call(s0,d1)]
				for k in [0,1,2,0,2,3]: (tools[surface][0] as SurfaceTool).add_vertex(pts[k])
	for surface:String in ["lawn","walk","asphalt","paint"]:
		if not tools.has(surface): continue
		var st:SurfaceTool=tools[surface][0]
		st.generate_normals()
		var node:=MeshInstance3D.new();node.name="Frontage_"+surface;node.mesh=st.commit();node.material_override=tools[surface][1];root.add_child(node)
		node.set_meta("physical_role","ground_visual")
		node.set_meta("ground_surface",surface)

static func _ground_strip(root:Node3D,c:Vector2,t:Vector2,n:Vector2,w:float,d0:float,d1:float,ground:Callable,m:Material,lift:float=0.055)->void:
	# Paving sits20mm above lawn; the former coplanar surfaces competed in depth.
	var pts:Array=[]
	for q in [Vector2(-w/2,d0),Vector2(w/2,d0),Vector2(w/2,d1),Vector2(-w/2,d1)]:
		var p:Vector2=c+t*q.x+n*q.y;pts.append(Vector3(p.x,float(ground.call(p))+lift,p.y))
	_quad(root,pts,m,false)
	root.get_child(-1).set_meta("physical_role", "ground_visual")

static func _wall_with_openings(root:Node3D,a:Vector3,b:Vector3,top:float,holes:Array[Rect2],m:Material)->void:
	var length:=Vector2(b.x-a.x,b.z-a.z).length();var t:=Vector3(b.x-a.x,0,b.z-a.z).normalized()
	var xs:Array[float]=[0.0,length];var ys:Array[float]=[minf(a.y,b.y),top]
	for hole in holes:
		xs.append(hole.position.x);xs.append(hole.end.x);ys.append(hole.position.y);ys.append(hole.end.y)
	xs.sort();ys.sort()
	for i in range(xs.size()-1):
		if xs[i+1]-xs[i]<0.0001:continue
		for j in range(ys.size()-1):
			if ys[j+1]-ys[j]<0.0001:continue
			var center:=Vector2((xs[i]+xs[i+1])*0.5,(ys[j]+ys[j+1])*0.5)
			var omit:=false
			for hole in holes:
				if hole.has_point(center):omit=true;break
			if omit:continue
			var p0:=Vector3(a.x,maxf(ys[j],lerpf(a.y,b.y,xs[i]/length)),a.z)+t*xs[i]
			var p1:=Vector3(a.x,maxf(ys[j],lerpf(a.y,b.y,xs[i+1]/length)),a.z)+t*xs[i+1]
			_quad(root,[p0,p1,Vector3(p1.x,ys[j+1],p1.z),Vector3(p0.x,ys[j+1],p0.z)],m)
## Whether a roof_plane is given in this model's roof frame (axis, normal, ridge_d).
static func same_roof_frame(plane:Dictionary)->bool:
	var axis:Array=plane.get("axis",[])
	var normal:Array=plane.get("normal",[])
	return axis.size()==2 and normal.size()==2 and is_equal_approx(float(axis[0]),ROOF_AXIS.x) and is_equal_approx(float(axis[1]),ROOF_AXIS.y) \
		and is_equal_approx(float(normal[0]),ROOF_NORMAL.x) and is_equal_approx(float(normal[1]),ROOF_NORMAL.y) and is_equal_approx(float(plane.get("ridge_d",0.0)),ROOF_RIDGE_D)

## Opt-in roof_plane {"slope", "segments": [{"ridge_offset", "ridge_y"}], "cuts":
## [{"west_t", "east_t", "jog_d"}], "extent_t": [t0, t1]}: the roof as one gable per
## footprint segment, each ridge on its segment's centre line ridge_offset across from
## ridge_d, the surface ridge_y - |d - ridge_offset| * slope. Cut k divides segment k
## from k+1: t <= west_t where d >= jog_d, east_t elsewhere; at the jog the two roofs
## stand at one height. Builds the slopes clipped to the footprint, the wall-to-roof
## closures (the legacy wall role) and edge boards along every run, a rake board along
## the higher roof where neighbours differ at a cut, each segment's ridge board and the
## six pipe vents on their segment's slope.
static func _segment_roof(root:Node3D,spec:Dictionary,polygon:PackedVector2Array,edges:Array,tan:Vector2,norm:Vector2,ridge_d:float,roofmat:Material,trim:Material,clad:Material)->void:
	var slope:=float(spec.slope)
	var segs:Array=spec.segments
	var cuts:Array=spec.cuts
	var extent:Array=spec.get("extent_t",[-739.65,-696.48])
	var count:=segs.size()
	# Slopes: per segment and side of its ridge, the footprint inside (t, d) rectangles
	# whose t bounds step where the bounding cuts jog.
	for k in count:
		var dc:=float(segs[k].ridge_offset)
		for side in [-1.0,1.0]:
			var d_lo:=dc if side>0.0 else dc-30.0
			var d_hi:=dc+30.0 if side>0.0 else dc
			var breaks:Array[float]=[d_lo,d_hi]
			for j in [k-1,k]:
				if j>=0 and j<cuts.size() and float(cuts[j].jog_d)>d_lo and float(cuts[j].jog_d)<d_hi: breaks.append(float(cuts[j].jog_d))
			breaks.sort()
			for b in breaks.size()-1:
				var mid:=(breaks[b]+breaks[b+1])*0.5
				var t0:=-800.0 if k==0 else _segment_cut_t(cuts[k-1],mid)
				var t1:=-650.0 if k==count-1 else _segment_cut_t(cuts[k],mid)
				var clip:=PackedVector2Array([tan*t0+norm*(ridge_d+breaks[b]),tan*t1+norm*(ridge_d+breaks[b]),tan*t1+norm*(ridge_d+breaks[b+1]),tan*t0+norm*(ridge_d+breaks[b+1])])
				for part in Geometry2D.intersect_polygons(polygon,clip):
					var ids:=Geometry2D.triangulate_polygon(part)
					var pts:Array=[]
					for p in part: pts.append(Vector3(p.x,float(segs[k].ridge_y)-abs(p.dot(norm)-ridge_d-dc)*slope,p.y))
					_mesh(root,pts,ids,roofmat)
	# Closures and edge boards along the runs, split at the cuts and the runs' ridges.
	for edge in edges:
		var a:Vector3=edge[0];var b:Vector3=edge[1]
		var ta:=Vector2(a.x,a.z).dot(tan);var tb:=Vector2(b.x,b.z).dot(tan)
		var da:=Vector2(a.x,a.z).dot(norm)-ridge_d;var db:=Vector2(b.x,b.z).dot(norm)-ridge_d
		var lams:Array[float]=[0.0,1.0]
		for cut in cuts:
			for limit_west in [[float(cut.west_t),true],[float(cut.east_t),false]]:
				var limit:float=limit_west[0]
				if (ta-limit)*(tb-limit)<0.0:
					var lam:=(limit-ta)/(tb-ta)
					if ((da+(db-da)*lam)>=float(cut.jog_d))==bool(limit_west[1]): lams.append(lam)
		for k in count:
			var dc:=float(segs[k].ridge_offset)
			if (da-dc)*(db-dc)<0.0:
				var lam:=(dc-da)/(db-da)
				if _segment_of(ta+(tb-ta)*lam,dc,cuts)==k: lams.append(lam)
		lams.sort()
		for j in lams.size()-1:
			var u:=a.lerp(b,lams[j]);var v:=a.lerp(b,lams[j+1])
			var m:=Vector2(a.x,a.z).lerp(Vector2(b.x,b.z),(lams[j]+lams[j+1])*0.5)
			var k:=_segment_of(m.dot(tan),m.dot(norm)-ridge_d,cuts)
			var dc:=float(segs[k].ridge_offset);var ry:=float(segs[k].ridge_y)
			var uy:float=ry-abs(Vector2(u.x,u.z).dot(norm)-ridge_d-dc)*slope
			var vy:float=ry-abs(Vector2(v.x,v.z).dot(norm)-ridge_d-dc)*slope
			_quad(root,[Vector3(u.x,8.05,u.z),Vector3(v.x,8.05,v.z),Vector3(v.x,vy,v.z),Vector3(u.x,uy,u.z)],clad)
			_beam(root,Vector3(u.x,uy,u.z),Vector3(v.x,vy,v.z),0.22,0.11,trim)
	# Rake boards where neighbouring roofs differ, along each cut's lines inside the
	# footprint (from the jog out to the walls), on the higher roof's edge.
	for k in cuts.size():
		var cut:Dictionary=cuts[k]
		for line in [[float(cut.west_t),true],[float(cut.east_t),false]]:
			var t:float=line[0]
			var crossings:Array[float]=[]
			for i in polygon.size():
				var pa:=polygon[i];var pb:=polygon[(i+1)%polygon.size()]
				var sa:=pa.dot(tan);var sb:=pb.dot(tan)
				if (sa-t)*(sb-t)<0.0: crossings.append(pa.dot(norm)-ridge_d+((pb.dot(norm)-pa.dot(norm))*(t-sa)/(sb-sa)))
			var jog:=float(cut.jog_d)
			var d0:=jog;var d1:=jog
			if bool(line[1]):
				d1=INF
				for d in crossings: if d>jog: d1=minf(d1,d)
			else:
				d0=-INF
				for d in crossings: if d<jog: d0=maxf(d0,d)
			if not is_finite(d0) or not is_finite(d1): continue
			var breaks:Array[float]=[d0,d1]
			for j in [k,k+1]:
				var dc:=float(segs[j].ridge_offset)
				if dc>d0 and dc<d1: breaks.append(dc)
			breaks.sort()
			for j in breaks.size()-1:
				var pts:Array[Vector3]=[]
				for d:float in [breaks[j],breaks[j+1]]:
					var h0:float=float(segs[k].ridge_y)-absf(d-float(segs[k].ridge_offset))*slope
					var h1:float=float(segs[k+1].ridge_y)-absf(d-float(segs[k+1].ridge_offset))*slope
					var p:Vector2=tan*t+norm*(ridge_d+d)
					pts.append(Vector3(p.x,maxf(h0,h1),p.y))
				if pts[0].distance_to(pts[1])>0.05: _beam(root,pts[0],pts[1],0.22,0.11,trim)
	# Ridge boards and the six pipe vents, on their segments.
	for k in count:
		var dc:=float(segs[k].ridge_offset)
		var t0:=float(extent[0]) if k==0 else _segment_cut_t(cuts[k-1],dc)
		var t1:=float(extent[1]) if k==count-1 else _segment_cut_t(cuts[k],dc)
		var ra:=tan*t0+norm*(ridge_d+dc);var rb:=tan*t1+norm*(ridge_d+dc)
		var ry:=float(segs[k].ridge_y)+0.02
		_beam(root,Vector3(ra.x,ry,ra.y),Vector3(rb.x,ry,rb.y),0.17,0.075,roofmat)
	for foot:Vector3 in segment_vents(spec):
		var stem:=CylinderMesh.new();stem.top_radius=0.055;stem.bottom_radius=0.055;stem.height=0.3;stem.radial_segments=8
		var pipe:=MeshInstance3D.new();pipe.mesh=stem;pipe.material_override=trim;pipe.position=foot+Vector3(0,0.12,0);root.add_child(pipe)
		_box(root,foot+Vector3(0,0.28,0),Vector3(0.16,0.025,0.16),roofmat)

## The production roof's six pipe vents under a roof_plane: at their stations along the
## ridge, 0.8 m down the front slope of the segment there, each on the roof's surface.
## (The family config's roof_vents.avoid keeps its vents clear of these.)
static func segment_vents(spec:Dictionary)->Array[Vector3]:
	var out:Array[Vector3]=[]
	var segs:Array=spec.segments
	var cuts:Array=spec.cuts
	for station in [-736.0,-730.0,-723.5,-717.0,-710.5,-704.0]:
		for k in segs.size():
			var dc:=float(segs[k].ridge_offset)
			if _segment_of(station,dc+0.8,cuts)!=k: continue
			var p:Vector2=ROOF_AXIS*station+ROOF_NORMAL*(ROOF_RIDGE_D+dc+0.8)
			out.append(Vector3(p.x,float(segs[k].ridge_y)-0.8*float(spec.slope),p.y))
			break
	return out

static func _segment_cut_t(cut:Dictionary,d:float)->float:
	return float(cut.west_t) if d>=float(cut.jog_d) else float(cut.east_t)

static func _segment_of(t:float,d:float,cuts:Array)->int:
	for k in cuts.size():
		if t<=_segment_cut_t(cuts[k],d): return k
	return cuts.size()

static func _recessed_window(root:Node3D,p:Vector3,t:Vector3,n:Vector3,w:float,h:float,trim:Material,dark:Material,glass:Material,sill_out:float=-1.0,pane_finish:Vector2=Vector2(-1.0,-1.0),pane_lift:float=0.0)->void:
	# Hole is cut through the outer facade. Deep reveals and a recessed opaque back preserve exterior-only scope.
	var reveal:=_material(Color(0.50,0.54,0.51),0.9)
	for side in [-1.0,1.0]:
		_panel(root,p+t*side*(w/2.0+0.035)-n*0.11,t,n,Vector3(0.075,h+0.10,0.34),reveal)
		_panel(root,p+t*side*(w/2.0+0.055)+n*0.035,t,n,Vector3(0.095,h+0.20,0.09),trim)
	for side in [-1.0,1.0]:
		_panel(root,p+Vector3(0,side*(h/2.0+0.035),0)-n*0.11,t,n,Vector3(w+0.07,0.075,0.34),reveal)
		_panel(root,p+Vector3(0,side*(h/2.0+0.055),0)+n*0.035,t,n,Vector3(w+0.20,0.095,0.09),trim)
	_panel(root,p-n*0.29,t,n,Vector3(w,h,0.025),dark)
	for side in [-1.0,1.0]:
		var value:float=fposmod(sin(p.x*3.12+p.z*5.17+side)*412.7,1.0)
		# Opt-in pane_lift: the pane toward a pale sky grey, as glass that takes the light.
		var pane_color:=Color(0.23,0.32,0.35).lerp(Color(0.53,0.57,0.53),value*0.65)
		if pane_lift>0.0: pane_color=pane_color.lerp(Color(0.66,0.72,0.77),pane_lift)
		var pane:=_material(pane_color,0.24 if pane_finish.x<0.0 else pane_finish.x)
		pane.metallic=0.22 if pane_finish.y<0.0 else pane_finish.y
		_panel(root,p+t*side*w*0.25-n*0.255,t,n,Vector3(w/2.0-0.045,h-0.07,0.02),pane)
	_panel(root,p-n*0.22,t,n,Vector3(0.045,h,0.045),trim)
	# Opt-in sill_out: how far the sill stands out of the wall (default 0.26 m).
	if sill_out<0.0: _panel(root,p-Vector3(0,h/2.0+0.07,0)+n*0.10,t,n,Vector3(w+0.27,0.065,0.32),trim)
	else: _panel(root,p-Vector3(0,h/2.0+0.07,0)+n*((sill_out-0.06)*0.5),t,n,Vector3(w+0.27,0.065,sill_out+0.06),trim)
static func _entry(root:Node3D,p:Vector3,t:Vector3,n:Vector3,trim:Material,door:Material,concrete:Material,threshold_bottom_y:float=0.0,extend_threshold:bool=false)->void:
	var threshold_center: Vector3 = p+Vector3(0,-1.035,0)+n*0.04
	var threshold_height: float = 0.06
	if extend_threshold:
		var threshold_top: float = threshold_center.y + Vector3(0,0.06,0).y / 2.0
		var old_bottom: float = threshold_center.y - Vector3(0,0.06,0).y / 2.0
		if not is_finite(threshold_bottom_y) or threshold_bottom_y > old_bottom:
			root.set_meta("build_valid", false)
			push_error("Threshold bottom must be finite and extend downward")
			return
		threshold_height = threshold_top - threshold_bottom_y
		threshold_center.y = (threshold_top + threshold_bottom_y) / 2.0
		if not is_finite(Vector3(0,threshold_height,0).y) or not is_finite(threshold_center.y) or threshold_height <= 0.0:
			root.set_meta("build_valid", false)
			push_error("Threshold extension cannot form finite positive geometry")
			return
	var reveal:=_material(Color(0.34,0.38,0.36),0.88)
	for side in [-1.0,1.0]:
		_panel(root,p+t*side*0.48-n*0.14,t,n,Vector3(0.075,2.20,0.40),reveal)
		_panel(root,p+t*side*0.53+n*0.04,t,n,Vector3(0.085,2.24,0.10),trim)
	_panel(root,p+Vector3(0,1.10,0)-n*0.12,t,n,Vector3(1.10,0.11,0.42),trim)
	_panel(root,p-n*0.32,t,n,Vector3(0.92,2.13,0.06),door)
	_panel(root,threshold_center,t,n,Vector3(1.10,threshold_height,0.50),concrete)
	root.get_child(-1).set_meta("construction_detail", "door_threshold")
	_panel(root,p+t*0.30-n*0.26,t,n,Vector3(0.035,0.12,0.055),trim)
