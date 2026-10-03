extends RefCounted
## Bulgarian Wall: detached visual study. All metric dimensions are production inference.
## +Z faces court; Y up. No world attachment, gameplay or site-fit claim.
const CONCRETE = preload("concrete.gdshader")
const MURAL_PATH := "mural.png"

static func build() -> Node3D:
	var root := Node3D.new()
	root.name = "BulgarianWallCourtStudy"
	var white := _concrete(Color("d9dcd3"),0.045,0.19)
	var slab := _concrete(Color("828579"),0.055,0.68)
	var earth := _concrete(Color("777766"),0.27,0.38)
	var joint := _mat(Color("62665e"))
	var cap := _concrete(Color("d7d8d1"),0.12,0.12)
	_box(root,"GroundSetting",Vector3(20,0.12,14.5),Vector3(0,-0.23,5.25),earth)
	_box(root,"ConcreteCourtSlab",Vector3(15.45,0.18,10.55),Vector3(0,-0.09,4.9),slab)
	_box(root,"PaintedConcreteBackwall",Vector3(14.8,4.7,0.32),Vector3(0,2.35,0),white)
	for x in [-7.4,0.0,7.4]:
		_return_wall(root,"CourtReturn_%s" % str(x),float(x),white)
		# Slightly projecting weathered concrete top, following the sloped return.
		_beam(root,"ReturnTop_%s" % str(x),Vector3(x,4.716,0.0),Vector3(x,2.616,7.6),0.35,0.045,cap)
	_box(root,"BackwallTop",Vector3(14.86,0.055,0.37),Vector3(0,4.724,0),cap)
	var mural_material := StandardMaterial3D.new()
	var image := Image.load_from_file(CONCRETE.resource_path.get_base_dir().path_join(MURAL_PATH))
	image.generate_mipmaps()
	mural_material.albedo_texture=ImageTexture.create_from_image(image)
	mural_material.roughness=0.97
	mural_material.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	mural_material.texture_repeat=false
	# One continuous finite artwork. Central structural return naturally occludes its narrow strip.
	_quad(root,"BulgariaInTheUSA_PaintedElevation",[
		Vector3(-7.24,0.04,0.164),Vector3(7.24,0.04,0.164),
		Vector3(7.24,4.67,0.164),Vector3(-7.24,4.67,0.164)],mural_material)
	# Irregular fine concrete cracks: production-inference placement, lifted 3mm
	# to avoid coplanar artifacts. Restrained widths survive ordinary view distance.
	_crack(root,"CourtCrackLeft",[Vector3(-6.3,0.003,3.7),Vector3(-4.9,0.003,3.61),Vector3(-3.8,0.003,3.78),Vector3(-2.5,0.003,3.69),Vector3(-1.7,0.003,3.79)],0.024,joint)
	_crack(root,"CourtCrackRight",[Vector3(0.3,0.003,5.9),Vector3(2.0,0.003,6.05),Vector3(3.45,0.003,5.91),Vector3(4.2,0.003,6.08),Vector3(6.9,0.003,6.12)],0.023,joint)
	_crack(root,"CourtCrackBranch",[Vector3(3.45,0.003,5.91),Vector3(3.7,0.003,4.95),Vector3(3.6,0.003,4.25)],0.017,joint)
	# Reference-visible worn asphalt repair rectangles on right return, painted flush.
	var patch := _concrete(Color("979a94"),0.15,0.06)
	_quad(root,"RightReturnRepairLarge",[Vector3(7.228,0.08,1.55),Vector3(7.228,0.08,4.75),Vector3(7.228,1.83,4.75),Vector3(7.228,1.83,1.55)],patch)
	_quad(root,"RightReturnRepairSmall",[Vector3(7.227,0.22,6.30),Vector3(7.227,0.22,6.94),Vector3(7.227,0.83,6.94),Vector3(7.227,0.83,6.30)],patch)
	return root

static func _mat(color: Color) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new()
	m.albedo_color=color
	m.roughness=0.95
	return m

static func _concrete(color: Color, grain: float, weathering: float) -> ShaderMaterial:
	var m:=ShaderMaterial.new()
	m.shader=CONCRETE
	m.set_shader_parameter("base_color",color)
	m.set_shader_parameter("grain",grain)
	m.set_shader_parameter("weathering",weathering)
	return m

static func _box(parent: Node3D,label: String,size: Vector3,pos: Vector3,material: Material) -> void:
	var node:=MeshInstance3D.new()
	node.name=label
	var mesh:=BoxMesh.new()
	mesh.size=size
	node.mesh=mesh
	node.material_override=material
	node.position=pos
	parent.add_child(node)

static func _quad(parent: Node3D,label: String,points: Array,material: Material) -> void:
	var st:=SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var uv:=[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)]
	var normal: Vector3 = (points[1]-points[0]).cross(points[2]-points[0]).normalized()
	# Clockwise front faces in Godot; explicit outward normals.
	for i in [0,2,1,0,3,2]:
		st.set_normal(normal)
		st.set_uv(uv[i])
		st.add_vertex(points[i])
	var node:=MeshInstance3D.new()
	node.name=label
	node.mesh=st.commit()
	node.material_override=material
	parent.add_child(node)

static func _return_wall(parent: Node3D,label: String,x: float,material: Material) -> void:
	var t:=0.16
	var v:=[Vector3(x-t,0,0),Vector3(x+t,0,0),Vector3(x+t,4.7,0),Vector3(x-t,4.7,0),Vector3(x-t,0,7.6),Vector3(x+t,0,7.6),Vector3(x+t,2.6,7.6),Vector3(x-t,2.6,7.6)]
	var faces:=[[1,0,3,2],[4,5,6,7],[0,4,7,3],[5,1,2,6],[3,7,6,2],[0,1,5,4]]
	for i in faces.size():
		var f:Array=faces[i]
		_quad(parent,label+"_Face%d"%i,[v[f[0]],v[f[1]],v[f[2]],v[f[3]]],material)

static func _beam(parent: Node3D,label: String,a: Vector3,b: Vector3,width: float,height: float,material: Material) -> void:
	var node:=MeshInstance3D.new()
	node.name=label
	var mesh:=BoxMesh.new()
	mesh.size=Vector3(width,height,a.distance_to(b))
	node.mesh=mesh
	node.material_override=material
	node.position=(a+b)*0.5
	# A local -Z beam axis follows the two endpoints without entering a SceneTree.
	node.basis=Basis.looking_at((b-a).normalized(),Vector3.UP)
	parent.add_child(node)

static func _crack(parent: Node3D,label: String,points: Array,width: float,material: Material) -> void:
	for i in range(points.size()-1):
		var a: Vector3=points[i]
		var b: Vector3=points[i+1]
		var side: Vector3=(b-a).normalized().cross(Vector3.UP)*width*0.5
		_quad(parent,label+"_%d"%i,[a+side,b+side,b-side,a-side],material)
