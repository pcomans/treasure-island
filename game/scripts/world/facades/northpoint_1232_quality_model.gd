extends RefCounted

# Reviewed whole-building construction; live factory assigns exact geometry contacts.
# Footprint is read verbatim from the frozen wall record. Unmeasured detail is art inference.
static func build(record: Dictionary, ground: Callable) -> Node3D:
	var root := Node3D.new()
	root.name = "Northpoint1232ScratchStudy"
	var siding := _material(Color(0.65,0.69,0.66),0.86)
	var shader := Shader.new()
	shader.code = "shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float line=smoothstep(0.88,0.98,fract(wp.y/0.155)); float n=fract(sin(dot(floor(wp.xz*45.0),vec2(12.9898,78.233)))*43758.5453); ALBEDO=vec3(0.27,0.33,0.34)*(1.0-line*0.28)+(n-0.5)*0.012; ROUGHNESS=0.86;}"
	var clad := ShaderMaterial.new()
	clad.shader=shader
	var trim := _material(Color(0.87,0.88,0.82),0.72)
	var dark := _material(Color(0.07,0.13,0.16),0.36)
	var glass := _material(Color(0.25,0.34,0.36),0.23)
	var door := _material(Color(0.075,0.13,0.19),0.7)
	var roofshader:=Shader.new()
	roofshader.code="shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float row=floor(wp.x*5.0);float cell=floor(wp.z*4.0+mod(row,2.0)*0.5);float n=fract(sin(row*12.9898+cell*78.233)*43758.5453);ALBEDO=vec3(0.23,0.25,0.23)+(n-0.5)*0.075;ROUGHNESS=0.94;}"
	var roofmat:=ShaderMaterial.new();roofmat.shader=roofshader
	var steel := _material(Color(0.30,0.26,0.20),0.85)
	var fascia_shader:=Shader.new()
	fascia_shader.code="shader_type spatial; varying vec3 wp; void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;} void fragment(){float a=fract(sin(dot(floor(wp.xz*14.0),vec2(12.9898,78.233)))*43758.5453); float b=fract(sin(dot(floor(wp.xz*2.0),vec2(39.346,11.135)))*15347.231); ALBEDO=vec3(0.42,0.43,0.39)+(a-0.5)*0.075+(b-0.5)*0.055; ROUGHNESS=0.95;}"
	var fascia:=ShaderMaterial.new();fascia.shader=fascia_shader
	var rust:=_material(Color(0.39,0.27,0.17),0.95)
	var underside:=_material(Color(0.16,0.20,0.19),0.97)
	var concrete := _material(Color(0.56,0.57,0.51),0.95)
	var asphalt := _material(Color(0.16,0.18,0.18),0.98)
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
	var tan:=Vector2(-0.04894628457,0.9988014123)
	var norm:=Vector2(-0.9988014123,-0.04894628457)
	var ridge_d:=336.328678
	for side in [-1.0,1.0]:
		var clip:=PackedVector2Array()
		for st in [Vector2(-800,0),Vector2(-650,0),Vector2(-650,30*side),Vector2(-800,30*side)]:
			clip.append(tan*st.x+norm*(ridge_d+st.y))
		for part in Geometry2D.intersect_polygons(polygon,clip):
			var ids:=Geometry2D.triangulate_polygon(part)
			var pts:Array=[]
			for p in part: pts.append(Vector3(p.x,9.68-abs(p.dot(norm)-ridge_d)*0.25,p.y))
			_mesh(root,pts,ids,roofmat)
	for edge in edges:
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
	_beam(root,Vector3(ridge_a.x,9.70,ridge_a.y),Vector3(ridge_b.x,9.70,ridge_b.y),0.17,0.075,roofmat)
	for station in [-736.0,-730.0,-723.5,-717.0,-710.5,-704.0]:
		var p:Vector2=tan*station+norm*(ridge_d+0.8)
		var stem:=CylinderMesh.new();stem.top_radius=0.055;stem.bottom_radius=0.055;stem.height=0.28;stem.radial_segments=8
		var pipe:=MeshInstance3D.new();pipe.mesh=stem;pipe.material_override=trim;pipe.position=Vector3(p.x,9.64,p.y);root.add_child(pipe)
		_box(root,Vector3(p.x,9.79,p.y),Vector3(0.16,0.025,0.16),roofmat)
	for i in range(roof_start, root.get_child_count()):
		var roof_mesh := root.get_child(i) as MeshInstance3D
		roof_mesh.set_meta("physical_role", "wall" if roof_mesh.material_override == clad else "roof")
	# Immediate frontage: ground follows actual colliding land; no terrain replacement.
	var origin:=Vector2(-305.509,-741.527)
	for s in range(-14,15,2):
		var center:=origin+tan*(s+1.0)
		_ground_strip(root,center,tan,norm,2.01,0.15,3.0,ground,lawn)
		_ground_strip(root,center,tan,norm,2.01,3.0,4.15,ground,concrete)
		_ground_strip(root,center,tan,norm,2.01,4.15,8.50,ground,asphalt)
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
		_ground_strip(root,origin+tan*s,tan,norm,0.07,4.30,8.40,ground,trim)
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
static func _recessed_window(root:Node3D,p:Vector3,t:Vector3,n:Vector3,w:float,h:float,trim:Material,dark:Material,glass:Material)->void:
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
		var pane:=_material(Color(0.23,0.32,0.35).lerp(Color(0.53,0.57,0.53),value*0.65),0.24)
		pane.metallic=0.22
		_panel(root,p+t*side*w*0.25-n*0.255,t,n,Vector3(w/2.0-0.045,h-0.07,0.02),pane)
	_panel(root,p-n*0.22,t,n,Vector3(0.045,h,0.045),trim)
	_panel(root,p-Vector3(0,h/2.0+0.07,0)+n*0.10,t,n,Vector3(w+0.27,0.065,0.32),trim)
static func _entry(root:Node3D,p:Vector3,t:Vector3,n:Vector3,trim:Material,door:Material,concrete:Material)->void:
	var reveal:=_material(Color(0.34,0.38,0.36),0.88)
	for side in [-1.0,1.0]:
		_panel(root,p+t*side*0.48-n*0.14,t,n,Vector3(0.075,2.20,0.40),reveal)
		_panel(root,p+t*side*0.53+n*0.04,t,n,Vector3(0.085,2.24,0.10),trim)
	_panel(root,p+Vector3(0,1.10,0)-n*0.12,t,n,Vector3(1.10,0.11,0.42),trim)
	_panel(root,p-n*0.32,t,n,Vector3(0.92,2.13,0.06),door)
	_panel(root,p+Vector3(0,-1.035,0)+n*0.04,t,n,Vector3(1.10,0.06,0.50),concrete)
	root.get_child(-1).set_meta("construction_detail", "door_threshold")
	_panel(root,p+t*0.30-n*0.26,t,n,Vector3(0.035,0.12,0.055),trim)
