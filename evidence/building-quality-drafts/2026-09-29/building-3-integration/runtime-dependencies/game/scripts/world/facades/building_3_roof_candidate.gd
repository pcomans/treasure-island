extends RefCounted
## Opt-in source-world candidate. No shipping registry or builder attachment.
const MODEL = preload("res://game/scripts/world/facades/building_3_roof_candidate_model.gd")
const CHUNK := "res://generated/world/chunks/x_1__z_1.json"
const WALL := "building:w34313540:wall"
const ROOF := "building:w34313540:roof"
const ORIGIN := Vector3(507.8695,3.478,448.885)
static func frame() -> Basis:
	var x := Vector3(528.784-486.955,0,488.910-408.860).normalized()
	return Basis(x,Vector3.UP,Vector3(x.z,0,-x.x))
static func world_point(p: Vector3) -> Vector3:
	return ORIGIN + frame()*p
static func records() -> Dictionary:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(CHUNK))
	var out := {}
	for r: Dictionary in data.records:
		if str(r.object_key) in [WALL,ROOF]: out[str(r.object_key)] = r
	return out
static func build(roof_longitudinal_span: float = 0.0) -> Dictionary:
	var source := records()
	if FileAccess.get_sha256(CHUNK)!="784d89c2ac1392f5ff329b8c6c437ad9050363e9f00b4f993dd9d378851f1758" or source.size()!=2: return {"ok":false,"message":"Missing frozen B3 source pair"}
	var roots := {}
	for key: String in [WALL,ROOF]:
		var r := Node3D.new()
		r.name = key.validate_node_name()
		for field: String in ["object_key","source_keys","feature_kind"]:
			r.set_meta("derived_object_key" if field=="object_key" else field,source[key][field])
		r.set_meta("candidate_unaccepted",true)
		roots[key]=r
	var model: Node3D = MODEL.build()
	var converted := 0
	var land := _land_triangles()
	for child: Node in model.get_children():
		if child is Label3D:
			child.position = world_point(child.position)
			child.rotation.y = atan2(frame().z.x,frame().z.z)
			child.reparent(roots[WALL],false)
			continue
		if not child is MeshInstance3D: continue
		var original := child as MeshInstance3D
		var role := str(original.get_meta("surface_role","wall"))
		var key := ROOF if role=="roof" else WALL
		var fitted_bottom := INF
		if bool(original.get_meta("fit_bottom_to_land",false)):
			var bounds := original.mesh.get_aabb()
			for ix in range(27):
				for iz in range(3):
					var point := world_point(original.position+Vector3(bounds.position.x+bounds.size.x*ix/26.0,0,bounds.position.z+bounds.size.z*iz/2.0))
					fitted_bottom=minf(fitted_bottom,_land_height(point,land)-0.025)
		var mesh := ArrayMesh.new()
		var faces := PackedVector3Array()
		for si in original.mesh.get_surface_count():
			var a := original.mesh.surface_get_arrays(si)
			if original.get_index()==2 and roof_longitudinal_span>0.0:
				a=_subdivide_barrel(a,roof_longitudinal_span)
			var v: PackedVector3Array = a[Mesh.ARRAY_VERTEX]
			var n: PackedVector3Array = a[Mesh.ARRAY_NORMAL]
			for i in v.size():
				var local: Vector3 = original.transform*v[i]
				v[i] = world_point(local)
				if fitted_bottom<INF and local.y<0.01: v[i].y=fitted_bottom
				# Exact source wall bottoms preserve the terrain foundation skirt.
				if original.get_index()==0 and abs(local.y)<0.001:
					var raw: Array = source[WALL].vertices
					for j in range(0,raw.size(),12):
						for k in [0,3]:
							if Vector2(v[i].x,v[i].z).distance_to(Vector2(raw[j+k],raw[j+k+2]))<0.002:
								v[i].y = float(raw[j+k+1])
				if n.size()>i:
					var transformed_normal: Vector3=frame()*original.basis*n[i]
					n[i]=transformed_normal if original.get_index()==2 and roof_longitudinal_span>0.0 else transformed_normal.normalized()
			var ids := PackedInt32Array()
			if a[Mesh.ARRAY_INDEX]!=null: ids=a[Mesh.ARRAY_INDEX]
			if ids.is_empty():
				for i in v.size(): ids.append(i)
			# Study frame is reflected; reverse once after baking into world space.
			for i in range(0,ids.size(),3):
				var temp := ids[i+1]; ids[i+1]=ids[i+2]; ids[i+2]=temp
				for k in 3: faces.append(v[ids[i+k]])
			a[Mesh.ARRAY_VERTEX]=v; a[Mesh.ARRAY_NORMAL]=n; a[Mesh.ARRAY_INDEX]=ids
			a[Mesh.ARRAY_TANGENT]=null
			mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,a)
		var mi := MeshInstance3D.new()
		mi.name="CandidateMesh%d"%converted; mi.mesh=mesh; mi.material_override=original.material_override
		if mi.material_override is ShaderMaterial:
			var material: ShaderMaterial = mi.material_override.duplicate()
			var shader := Shader.new()
			shader.code = material.shader.code.replace("varying vec3 pos;", "uniform mat4 local_from_world;\nvarying vec3 pos;").replace("pos=VERTEX;", "pos=(local_from_world*vec4(VERTEX,1.0)).xyz;")
			material.shader=shader
			material.set_shader_parameter("local_from_world",Transform3D(frame(),ORIGIN).affine_inverse())
			mi.material_override=material
		mi.layers=2 if key==WALL else 1
		roots[key].add_child(mi)
		var body := StaticBody3D.new()
		body.name="Collision%d"%converted
		body.collision_layer=5 if key==WALL else 1; body.collision_mask=0
		body.set_meta("derived_object_key",key); body.set_meta("source_keys",["w34313540"])
		body.set_meta("receiver_kind","building_wall" if key==WALL else "none")
		body.set_meta("opaque",true)
		if key==WALL: body.add_to_group("spray_receiver_wall")
		var shape := ConcavePolygonShape3D.new(); shape.set_faces(faces)
		shape.set_meta("derived_object_key",key); shape.set_meta("source_keys",["w34313540"])
		shape.set_meta("receiver_kind","building_wall" if key==WALL else "none"); shape.set_meta("opaque",true)
		var cs := CollisionShape3D.new(); cs.shape=shape; body.add_child(cs); roots[key].add_child(body)
		converted+=1
	model.free()
	_add_apron(roots[WALL])
	return {"ok":true,"wall":roots[WALL],"roof":roots[ROOF],"mesh_count":converted}

static func _add_apron(root: Node3D) -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://game/resources/facades/building_3_candidate_apron.json"))
	var st := SurfaceTool.new(); st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var v: Array = data.vertices
	for i in range(0,v.size(),3):
		var a := Vector3(v[i][0],v[i][1],v[i][2]); var b := Vector3(v[i+1][0],v[i+1][1],v[i+1][2]); var c := Vector3(v[i+2][0],v[i+2][1],v[i+2][2])
		if (a-c).cross(a-b).y<0:
			var tmp:=b; b=c; c=tmp
		for point in [a,b,c]: st.add_vertex(point)
	st.generate_normals()
	var mi := MeshInstance3D.new();mi.name="RenderOnlyDrapedApron";mi.mesh=st.commit()
	var material: ShaderMaterial = _apron_material()
	mi.material_override=material;root.add_child(mi)

static func _land_triangles() -> Array:
	var result: Array=[]
	for chunk in ["x_1__z_1","x_2__z_1"]:
		var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://generated/world/chunks/"+chunk+".json"))
		for r: Dictionary in data.records:
			if str(r.feature_kind)!="land_ground":continue
			for i in range(0,r.indices.size(),3):
				var tri: Array=[]
				for k in 3:
					var j:=int(r.indices[i+k])*3
					tri.append(Vector3(r.vertices[j],r.vertices[j+1],r.vertices[j+2]))
				result.append(tri)
	return result
static func _land_height(p: Vector3, triangles: Array) -> float:
	for tri: Array in triangles:
		var a: Vector3=tri[0];var b: Vector3=tri[1];var c: Vector3=tri[2]
		var den: float=(b.z-c.z)*(a.x-c.x)+(c.x-b.x)*(a.z-c.z)
		if absf(den)<0.000001:continue
		var u: float=((b.z-c.z)*(p.x-c.x)+(c.x-b.x)*(p.z-c.z))/den
		var v: float=((c.z-a.z)*(p.x-c.x)+(a.x-c.x)*(p.z-c.z))/den
		if minf(u,minf(v,1-u-v))>=-0.00001:return u*a.y+v*b.y+(1-u-v)*c.y
	push_error("B3 ground-fit sample outside source LAND")
	return INF
static func _apron_material() -> ShaderMaterial:
	var shader:=Shader.new()
	shader.code="""shader_type spatial;
render_mode cull_back;
uniform mat4 local_from_world;
uniform vec4 base : source_color = vec4(0.40,0.38,0.33,1.0);
varying vec2 p;
float hash(vec2 q){return fract(sin(dot(q,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 q){vec2 i=floor(q),f=fract(q);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){p=(local_from_world*vec4(VERTEX,1.0)).xz;}
void fragment(){
float broad=noise(p*0.18);float grain=noise(p*9.0);
vec2 grid=p/vec2(7.5,9.0);vec2 edge=min(fract(grid),1.0-fract(grid))*vec2(7.5,9.0);
vec2 aa=max(fwidth(p),vec2(0.01));
float joint=max(1.0-smoothstep(0.028,0.028+aa.x,edge.x),1.0-smoothstep(0.025,0.025+aa.y,edge.y));
float slab=hash(floor(grid));
float wear=smoothstep(0.35,0.73,noise(p*0.075+3.2));
float weather=noise(p*0.36+noise(p*0.09)*3.0);
ALBEDO=mix(base.rgb,base.rgb*vec3(0.82,0.79,0.72),wear*0.5)*(0.78+broad*0.30+grain*0.12+slab*0.035+weather*0.16)*(1.0-joint*0.075);
ROUGHNESS=0.95;
}
"""
	var material:=ShaderMaterial.new();material.shader=shader
	material.set_shader_parameter("local_from_world",Transform3D(frame(),ORIGIN).affine_inverse())
	return material

# Experimental tessellation only: clip existing triangles into longitudinal strips.
# Interpolate original normals without renormalizing: preserve their original
# barycentric field, including the original diagonal and material coordinates.
static func _subdivide_barrel(arrays: Array, maximum_span: float) -> Array:
	var source: PackedVector3Array=arrays[Mesh.ARRAY_VERTEX]
	var normals: PackedVector3Array=arrays[Mesh.ARRAY_NORMAL]
	var indices:=PackedInt32Array()
	if arrays[Mesh.ARRAY_INDEX]!=null:indices=arrays[Mesh.ARRAY_INDEX]
	var vertices:=PackedVector3Array();var out_normals:=PackedVector3Array()
	var segments: int=ceili(129.0/maximum_span)
	var count: int=indices.size() if not indices.is_empty() else source.size()
	for t in range(0,count,3):
		var triangle: Array=[]
		for k in 3:
			var index: int=indices[t+k] if not indices.is_empty() else t+k
			triangle.append({"p":source[index],"n":normals[index]})
		for j in segments:
			var low: float=-134.0+129.0*float(j)/float(segments)
			var high: float=-134.0+129.0*float(j+1)/float(segments)
			var polygon: Array=_clip_longitudinal(_clip_longitudinal(triangle,low,true),high,false)
			for k in range(1,polygon.size()-1):
				var a: Vector3=polygon[0].p;var b: Vector3=polygon[k].p;var c: Vector3=polygon[k+1].p
				if (b-a).cross(c-a).length_squared()<0.000000000001:continue
				for corner: Dictionary in [polygon[0],polygon[k],polygon[k+1]]:
					vertices.append(corner.p);out_normals.append(corner.n)
	var result: Array=arrays.duplicate()
	result[Mesh.ARRAY_VERTEX]=vertices;result[Mesh.ARRAY_NORMAL]=out_normals;result[Mesh.ARRAY_INDEX]=PackedInt32Array()
	return result
static func _clip_longitudinal(polygon: Array,plane: float,keep_above: bool) -> Array:
	var out: Array=[]
	if polygon.is_empty():return out
	var previous: Dictionary=polygon.back()
	var previous_inside: bool=previous.p.z>=plane if keep_above else previous.p.z<=plane
	for current: Dictionary in polygon:
		var inside: bool=current.p.z>=plane if keep_above else current.p.z<=plane
		if inside!=previous_inside:
			var ratio: float=(plane-previous.p.z)/(current.p.z-previous.p.z)
			out.append({"p":(previous.p as Vector3).lerp(current.p,ratio),"n":(previous.n as Vector3).lerp(current.n,ratio)})
		if inside:out.append(current)
		previous=current;previous_inside=inside
	return out
