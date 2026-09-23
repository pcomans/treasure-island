extends RefCounted
# Reviewed composition; exact frozen foundation footprint. Frontage chord alignment up to29.3mm is production inference.
static func mat(c:Color,rough:float=0.8)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=c;m.roughness=rough;return m
static func cladding()->ShaderMaterial:
	var sh:=Shader.new()
	sh.code="""shader_type spatial;
	varying vec3 wp;
	void vertex(){wp=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;}
	void fragment(){
	 float course=fract(wp.y/0.155);
	 float aa=max(fwidth(wp.y/0.155),0.025);
	 float line=1.0-smoothstep(0.02,0.02+aa,course);
	 float subtle=sin(wp.x*1.73+wp.z*2.19)*sin(wp.y*9.0)*0.008;
	 ALBEDO=vec3(0.60,0.645,0.65)*(1.0-line*0.085)+subtle;
	 ROUGHNESS=0.88;
	}"""
	var m:=ShaderMaterial.new();m.shader=sh;return m
static func box(root:Node3D,p:Vector3,s:Vector3,m:Material,angle:float=0.0)->void:
	var n:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=s;n.mesh=mesh;n.material_override=m;n.position=p;n.rotation.y=angle;root.add_child(n)
static func quad(root:Node3D,pts:Array,m:Material)->void:
	var mesh:=ArrayMesh.new();var ar:=[];ar.resize(Mesh.ARRAY_MAX)
	var vs:=PackedVector3Array();var ns:=PackedVector3Array();var uv:=PackedVector2Array()
	var normal:Vector3=(pts[1]-pts[0]).cross(pts[2]-pts[0]).normalized()
	for i in [0,2,1,0,3,2]:vs.append(pts[i]);ns.append(normal);uv.append(Vector2(pts[i].x,pts[i].z))
	ar[Mesh.ARRAY_VERTEX]=vs;ar[Mesh.ARRAY_NORMAL]=ns;ar[Mesh.ARRAY_TEX_UV]=uv;mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,ar)
	var n:=MeshInstance3D.new();n.mesh=mesh;n.material_override=m;root.add_child(n)
static func exterior_quad(root:Node3D,pts:Array,m:Material,outward:Vector3,kind:String)->void:
	var ar:=[];ar.resize(Mesh.ARRAY_MAX)
	var vertices:=PackedVector3Array();var normals:=PackedVector3Array()
	for ids:Array in [[0,1,2],[0,2,3]]:
		var a:Vector3=pts[ids[0]];var b:Vector3=pts[ids[1]];var c:Vector3=pts[ids[2]]
		var cross:Vector3=(b-a).cross(c-a)
		if cross.length_squared()<0.000000000001:continue
		if cross.dot(outward)>0.0:
			var swap:Vector3=b;b=c;c=swap
		var normal:Vector3=-(b-a).cross(c-a).normalized()
		vertices.append_array(PackedVector3Array([a,b,c]));normals.append_array(PackedVector3Array([normal,normal,normal]))
	if vertices.is_empty():return
	ar[Mesh.ARRAY_VERTEX]=vertices;ar[Mesh.ARRAY_NORMAL]=normals
	var mesh:=ArrayMesh.new();mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,ar)
	var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=m
	node.set_meta("exterior_kind",kind);node.set_meta("intended_exterior",outward);root.add_child(node)

static func door_bottom(a:Vector3,t:Vector3,out:Vector3,length:float,k:int,ground:Callable,base:float)->float:
	var p:Vector3=a+t*(length*(float(k)+0.5)/2.0-0.89)+out*0.25
	return float(ground.call(Vector2(p.x,p.z)))+0.060-base

static func build(record:Dictionary,ground:Callable)->Node3D:
	var root:=Node3D.new();root.name="Northpoint1241ScratchStudy"
	var siding:=cladding();var trim:=mat(Color("d3d5cb"));var dark:=mat(Color("303b40"));var door:=mat(Color("533a40"));var glass:=mat(Color("405561"),0.25);var roofmat:=mat(Color("626965"));var concrete:=mat(Color("96978b"));var grass:=mat(Color("69734b"));var asphalt:=mat(Color("414745"));var seam:=mat(Color("8d9899"));var warm:=mat(Color("8c8d7f"))
	var v:Array=record.vertices;var base:float=record.flat_base_elevation_m;var top:=base+5.65
	var points:Array=[]
	for i in range(0,v.size(),12):points.append(Vector3(v[i],base,v[i+2]))
	# Keep source footprint vertices; stitch collinear source seams into three architectural frontage wings.
	var fronts:=[[0,4],[5,9],[10,13]]
	var skip:={}
	for span in fronts:
		for j in range(span[0],span[1]):skip[j]=true
	for j in points.size():
		if skip.has(j):continue
		var a:Vector3=points[j];var b:Vector3=points[(j+1)%points.size()]
		quad(root,[a,b,b+Vector3.UP*5.65,a+Vector3.UP*5.65],siding)
	# Frontage is composed in complete residential bays, independent of converter splits.
	for span in fronts:
		var a:Vector3=points[span[0]];var b:Vector3=points[span[1]];var t:Vector3=(b-a).normalized();var out:=Vector3(-t.z,0,t.x);var length:float=a.distance_to(b);var angle:=atan2(-t.z,t.x)
		var holes:Array=[]
		for k in 3:
			var center:float=length*(float(k)+0.5)/3.0
			holes.append(Rect2(center-0.86,3.68,1.72,1.35))
		for k in 2:
			var center:float=length*(float(k)+0.5)/2.0
			var bottom:float=door_bottom(a,t,out,length,k,ground,base)
			holes.append(Rect2(center-1.35,bottom,0.92,2.29-bottom));holes.append(Rect2(center+0.35,0.88,1.7,1.35))
		var xs:Array[float]=[0.0,length];var ys:Array[float]=[0.0,5.65]
		for h in holes:xs.append(h.position.x);xs.append(h.end.x);ys.append(h.position.y);ys.append(h.end.y)
		xs.sort();ys.sort()
		for xi in range(xs.size()-1):
			for yi in range(ys.size()-1):
				if xs[xi+1]-xs[xi]<0.001 or ys[yi+1]-ys[yi]<0.001:continue
				var mid:=Vector2((xs[xi]+xs[xi+1])*0.5,(ys[yi]+ys[yi+1])*0.5);var empty:=false
				for h in holes:if h.has_point(mid):empty=true
				if not empty:box(root,a+t*mid.x+Vector3.UP*mid.y-out*0.10,Vector3(xs[xi+1]-xs[xi],ys[yi+1]-ys[yi],0.20),siding,angle)

		for h in holes:
			var center:Vector2=h.get_center();var isdoor:bool=h.position.y<0.5;var pos:=a+t*center.x+Vector3.UP*center.y
			box(root,pos-out*0.135,Vector3(h.size.x,h.size.y,0.045),door if isdoor else glass,angle)
			for dx in [-1.0,1.0]:box(root,pos+t*(dx*(h.size.x*0.5+0.035))-out*0.02,Vector3(0.075,h.size.y+0.14,0.22),trim,angle)
			for dy in ([1.0] if isdoor else [-1.0,1.0]):box(root,pos+Vector3.UP*(dy*(h.size.y*0.5+0.035))-out*0.02,Vector3(h.size.x+0.15,0.07,0.22),trim,angle)
			if isdoor:
				box(root,a+t*center.x+Vector3.UP*(h.position.y-0.010)+out*0.11,Vector3(h.size.x,0.020,0.36),concrete,angle)
				root.get_child(-1).set_meta("construction_detail","door_threshold")
			if not isdoor:
				box(root,pos-out*0.075,Vector3(0.045,h.size.y,0.06),trim,angle)
				box(root,pos-out*0.085,Vector3(h.size.x,0.035,0.06),trim,angle)
				box(root,pos-Vector3.UP*(h.size.y*0.5+0.055)+out*0.08,Vector3(h.size.x+0.26,0.065,0.34),trim,angle)
				# Interior blind behind glass, restrained varied lower light.
				box(root,pos+Vector3.UP*0.29-out*0.095,Vector3(h.size.x-0.12,0.43,0.018),warm,angle)
			else:
				box(root,pos+t*0.27-out*0.085,Vector3(0.035,0.16,0.055),trim,angle)
				box(root,pos-Vector3.UP*0.95-out*0.10,Vector3(0.7,0.11,0.03),dark,angle)
				box(root,a+t*(center.x+0.7)+Vector3.UP*2.17+out*0.10,Vector3(0.17,0.22,0.16),dark,angle)
		box(root,(a+b)*0.5+Vector3.UP*5.64+out*0.15,Vector3(length+0.32,0.18,0.45),trim,angle)
		box(root,(a+b)*0.5+Vector3.UP*2.79+out*0.022,Vector3(length,0.07,0.08),trim,angle)
		for p in [a,b]:box(root,p+Vector3.UP*2.79+out*0.015,Vector3(0.12,5.58,0.09),trim,angle)
	var roof_start := root.get_child_count()
	# Very shallow planar roof, honest inferred unseen closure inside exact horizontal footprint.
	var poly:=PackedVector2Array();for p in points:poly.append(Vector2(p.x,p.z))
	var tri:=Geometry2D.triangulate_polygon(poly)
	for k in range(0,tri.size(),3):
		var p0:Vector3=points[tri[k]]+Vector3.UP*5.73;var p1:Vector3=points[tri[k+1]]+Vector3.UP*5.73;var p2:Vector3=points[tri[k+2]]+Vector3.UP*5.73
		exterior_quad(root,[p0,p1,p2,p2],roofmat,Vector3.UP,"roof_top")
	for i in range(roof_start, root.get_child_count()):
		root.get_child(i).set_meta("physical_role", "roof")
	# Independent detached carport, deep dark underside and slender paired support lines.
	var origin:=Vector3(-138.932,0,-765.783);var tangent:=Vector3(0.2441683,0,0.9697329);var outward:=Vector3(-0.9697329,0,0.2441683);var ang:=atan2(-tangent.z,tangent.x)
	# Corner sampling follows the source land slope; no flat tiles intersect its surface.
	for station in range(-14,29):
		for depth in range(0,9):
			var corners:Array=[]
			for offset in [Vector2(0,0),Vector2(0,1),Vector2(1,1),Vector2(1,0)]:
				var p:Vector3=origin+tangent*(float(station)+offset.x)+outward*(float(depth)+offset.y)
				p.y=float(ground.call(Vector2(p.x,p.z)))+0.04
				corners.append(p)
			quad(root,corners,grass if depth<3 else (concrete if depth<4 else asphalt))
			root.get_child(-1).set_meta("physical_role", "ground_visual")
	# Plain concrete entrance paths cross the lawn to the public footway.
	for span in fronts:
		var a:Vector3=points[span[0]];var b:Vector3=points[span[1]];var t:Vector3=(b-a).normalized();var out:=Vector3(-t.z,0,t.x);var length:float=a.distance_to(b)
		for k in 2:
			var doorpos:Vector3=a+t*(length*(float(k)+0.5)/2.0-0.89)
			var corners:Array=[]
			for offset in [Vector2(-0.58,0),Vector2(-0.58,4.8),Vector2(0.58,4.8),Vector2(0.58,0)]:
				var p:Vector3=doorpos+t*offset.x+out*offset.y
				p.y=float(ground.call(Vector2(p.x,p.z)))+0.052
				corners.append(p)
			quad(root,corners,concrete)
			root.get_child(-1).set_meta("physical_role", "ground_visual")

	var shelter:=origin+tangent*7.2+outward*6.3;shelter.y=6.28
	box(root,shelter,Vector3(43.2,0.14,4.7),roofmat,ang)
	for d in [3.94,8.66]:
		box(root,origin+tangent*7.2+outward*d+Vector3.UP*6.19,Vector3(43.3,0.25,0.12),trim,ang)
	for s in [-13.7,-6.6,0.5,7.6,14.7,21.8,28.4]:
		box(root,origin+tangent*s+outward*6.3+Vector3.UP*6.10,Vector3(0.095,0.20,4.62),dark,ang)
		for d in [4.10,8.40]:
			var p:Vector3=origin+tangent*s+outward*d;var gy:float=ground.call(Vector2(p.x,p.z))
			box(root,Vector3(p.x,(gy+6.07)*0.5,p.z),Vector3(0.095,6.07-gy,0.095),trim,ang)
	# Frozen source-edge closure, cut coherently below each locally grounded doorway.
	for edge in points.size():
		var offset:int=edge*12
		var a:=Vector3(v[offset],v[offset+1],v[offset+2]);var b:=Vector3(v[offset+3],v[offset+4],v[offset+5])
		var axis:Vector3=(Vector3(b.x,base,b.z)-Vector3(a.x,base,a.z)).normalized()
		var edge_outward:=Vector3(-axis.z,0,axis.x)
		var cuts:Array[float]=[0.0,1.0];var doors:Array=[];var chord_a:=Vector3.ZERO;var chord_axis:=Vector3.ZERO
		for span in fronts:
			if edge<int(span[0]) or edge>=int(span[1]):continue
			chord_a=points[span[0]];var chord_b:Vector3=points[span[1]]
			chord_axis=(chord_b-chord_a).normalized();var length:float=chord_a.distance_to(chord_b)
			var sa:float=(a-chord_a).dot(chord_axis);var sb:float=(b-chord_a).dot(chord_axis)
			for k in 2:
				var center:float=length*(float(k)+0.5)/2.0-0.89
				var top_y:float=base+door_bottom(chord_a,chord_axis,Vector3(-chord_axis.z,0,chord_axis.x),length,k,ground,base)-0.020
				doors.append({"left":center-0.46,"right":center+0.46,"top":top_y})
				for station:float in [center-0.46,center+0.46]:
					var ratio:float=(station-sa)/(sb-sa)
					if ratio>0.000001 and ratio<0.999999:cuts.append(ratio)
		cuts.sort()
		for part in range(cuts.size()-1):
			var pa:Vector3=a.lerp(b,cuts[part]);var pb:Vector3=a.lerp(b,cuts[part+1]);var top_y:float=base
			if chord_axis!=Vector3.ZERO:
				var middle:float=((pa+pb)*0.5-chord_a).dot(chord_axis)
				for entry:Dictionary in doors:
					if middle>float(entry.left) and middle<float(entry.right):top_y=minf(top_y,float(entry.top))
			var at:=Vector3(pa.x,maxf(pa.y,top_y),pa.z);var bt:=Vector3(pb.x,maxf(pb.y,top_y),pb.z)
			exterior_quad(root,[pa,pb,bt,at],siding,edge_outward,"source_lower_wall")
			if chord_axis==Vector3.ZERO:continue
			var aa:Vector3=chord_a+chord_axis*(at-chord_a).dot(chord_axis);aa.y=at.y
			var bb:Vector3=chord_a+chord_axis*(bt-chord_a).dot(chord_axis);bb.y=bt.y
			var da:float=(at-aa).dot(Vector3(-chord_axis.z,0,chord_axis.x));var db:float=(bt-bb).dot(Vector3(-chord_axis.z,0,chord_axis.x))
			if da*db<0.0:
				var crossing:Vector3=at.lerp(bt,da/(da-db))
				exterior_quad(root,[at,crossing,crossing,aa],siding,Vector3.UP,"foundation_chord_cap")
				exterior_quad(root,[crossing,bt,bb,crossing],siding,Vector3.UP,"foundation_chord_cap")
			else:exterior_quad(root,[at,bt,bb,aa],siding,Vector3.UP,"foundation_chord_cap")
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			var mesh := child as MeshInstance3D
			if not mesh.has_meta("physical_role"):
				mesh.set_meta("physical_role", "wall" if mesh.material_override == siding else "detail")
	return root
