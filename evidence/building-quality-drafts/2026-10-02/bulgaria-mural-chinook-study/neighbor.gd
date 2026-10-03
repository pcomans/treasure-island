extends RefCounted
## Target-specific instance assembly using the maintained Site12 housing kit.
## Local frontage +Z. Dimensions and hidden openings are production inference.
const KIT = preload("site_12_housing_kit.gd")
const COURT = preload("court.gd")
const ROOF = preload("roof.gdshader")
const SIDING = preload("siding.gdshader")

static func build() -> Node3D:
	var r:=Node3D.new()
	r.name="1445ChinookCourt_w95934121_VisualStudy"
	var white:=COURT._concrete(Color("d4d4c9"),0.055,0.12)
	var peach:=COURT._concrete(Color("c3957c"),0.05,0.08)
	var trim:=COURT._mat(Color("d2d0bb"))
	var dark:=COURT._mat(Color("253335"))
	var glass:=COURT._mat(Color("35464a"))
	glass.roughness=0.3
	var rail:=COURT._mat(Color("98645b"))
	var slab:=COURT._concrete(Color("96998a"),0.04,0.18)
	var grass:=COURT._concrete(Color("747b4c"),0.06,0.22)
	var siding:=ShaderMaterial.new()
	siding.shader=SIDING
	siding.set_shader_parameter("wall_color",Color("d5d7ce"))
	var roof:=ShaderMaterial.new()
	roof.shader=ROOF
	roof.set_shader_parameter("roof_color",Color("514338"))
	_box(r,"Lawn",Vector3(36,0.13,21),Vector3(0,-0.065,2.4),grass)
	_box(r,"FrontPath",Vector3(34,0.10,1.1),Vector3(0,-0.035,9.1),slab)
	# Three low-hip roof volumes: two forward garage wings and recessed link.
	for x in [-10.1,10.1]:
		if x<0:
			_box(r,"WingLower",Vector3(9.8,3.0,8.6),Vector3(x,1.5,0.6),white)
		else:
			_box(r,"WingLowerInset",Vector3(8.8,3.0,8.6),Vector3(x-0.5,1.5,0.6),white)
			_box(r,"SouthNookReturn",Vector3(1.0,3.0,0.795),Vector3(14.5,1.5,-5.1025),white)
			_box(r,"SouthNookReturn",Vector3(1.0,3.0,6.955),Vector3(14.5,1.5,1.4225),white)
			_box(r,"SouthNookHeader",Vector3(1.0,0.8,2.65),Vector3(14.5,2.6,-3.38),white)
		# Upper mass steps inward at the east balconies. The south wing also
		# steps inward behind its end balcony, leaving actual architectural void.
		var core_width:float=8.8 if x>0 else 9.8
		var core_x:float=x-0.5 if x>0 else x
		_box(r,"WingUpperInset",Vector3(core_width,2.8,8.6),Vector3(core_x,4.4,0.6),white)
		var balcony_x:float=8.0 if x>0 else -8.0
		_back_shell(r,x-4.9,x+4.9,balcony_x,white)
		if x>0:
			_side_shell(r,15.0,-5.5,4.9,-0.65,2.65,white)
		_box(r,"GarageRecess",Vector3(9.22,2.63,0.14),Vector3(x,1.34,4.93),peach)
		_box(r,"UpperApron",Vector3(9.8,1.35,0.15),Vector3(x,3.53,5.04),white)
		_box(r,"UpperSiding",Vector3(9.8,1.65,0.16),Vector3(x,4.98,5.035),siding)
		for dx in [-3.23,0.0,3.23]:
			_garage(r,x+dx,5.02,peach,trim,dark)
			_window(r,Vector3(x+dx,4.98,5.16),1.42,1.04,Vector3.RIGHT,Vector3.BACK,trim,glass,dark)
		for dx in [-4.82,4.82]:
			_box(r,"GaragePier",Vector3(0.20,2.75,0.25),Vector3(x+dx,1.375,5.13),white)
		_box(r,"Driveway",Vector3(9.8,0.10,3.8),Vector3(x,-0.035,7.0),slab)
		_hip(r,Vector3(x,5.86,-0.3),Vector2(10.65,11.25),1.05,roof,trim)
	_box(r,"RecessedCenterLower",Vector3(10.4,3.0,5.7),Vector3(0,1.5,-0.85),peach)
	_box(r,"RecessedCenterUpper",Vector3(10.4,2.6,5.7),Vector3(0,4.3,-0.85),peach)
	_box(r,"GardenCentralWhiteWall",Vector3(10.4,5.6,1.8),Vector3(0,2.8,-4.6),white)
	_hip(r,Vector3(0,5.66,-1.75),Vector2(11.15,8.25),0.77,roof,trim)
	for x in [-1.6,1.6]:
		for y in [1.35,4.25]:
			_window(r,Vector3(x,y,2.025),1.65,1.18,Vector3.RIGHT,Vector3.BACK,trim,glass,dark)
	# Two actual exterior flights descend toward the west courtyard.
	for x in [-4.2,4.2]:
		_door(r,Vector3(x,0,2.04),peach,trim,dark)
		_door(r,Vector3(x,2.90,2.04),peach,trim,dark)
		_box(r,"UpperLanding",Vector3(1.35,0.20,1.10),Vector3(x,2.8,2.65),slab)
		_stairs(r,x,3.12,2.9,4.25,slab,rail)
	# Garden side: paired outdoor rooms, not windows applied to a solid wall.
	# Broad peach backs, real covered patio voids and upper balcony decks share
	# the same white enclosing structure. Width/depth/cadence are art inference.
	for x in [-8.0,8.0]:
		_garden_bay(r,x,4.6,peach,white,slab,trim,glass,dark)
	for x in [-1.6,1.6]:
		_window(r,Vector3(x,1.4,-5.53),0.78,0.7,Vector3.LEFT,Vector3.FORWARD,trim,glass,dark)
	# South end visible next to the mural: one upper recess and lower covered nook.
	_balcony(r,Vector3(14.025,4.22,-0.65),Vector3.FORWARD,Vector3.RIGHT,2.65,peach,slab,dark)
	_box(r,"SouthNookShadow",Vector3(0.04,2.18,2.65),Vector3(14.04,1.1,-3.38),peach)
	_box(r,"SouthNookAwning",Vector3(1.3,0.20,2.85),Vector3(14.6,2.34,-3.38),white)
	_box(r,"SouthNookPost",Vector3(0.075,2.26,0.075),Vector3(15.17,1.13,-3.38),trim)
	# Restrained roof vent stacks and rainwater goods, inferred placement.
	for x in [-3.2,0.0,3.3]:
		_box(r,"RoofVent",Vector3(0.11,0.6,0.11),Vector3(x,6.3,-3.3),dark)
	for x in [-14.88,14.88]:
		_box(r,"RainwaterPipe",Vector3(0.065,5.5,0.065),Vector3(x,2.75,5.23),trim)
	return r

static func _box(r:Node3D,label:String,size:Vector3,pos:Vector3,m:Material)->void:
	var b:Dictionary=KIT.new_bucket()
	KIT.append_box(b,pos,Vector3.RIGHT,Vector3.BACK,size.x,size.y,size.z)
	_emit(r,label,b,m)

static func _emit(r:Node3D,label:String,b:Dictionary,m:Material)->void:
	var arrays:Array=[]
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX]=PackedVector3Array(b.vertices)
	arrays[Mesh.ARRAY_NORMAL]=PackedVector3Array(b.normals)
	arrays[Mesh.ARRAY_TEX_UV]=PackedVector2Array(b.uvs)
	arrays[Mesh.ARRAY_INDEX]=PackedInt32Array(b.indices)
	var mesh:=ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,arrays)
	var n:=MeshInstance3D.new()
	n.name=label
	n.mesh=mesh
	n.material_override=m
	r.add_child(n)

static func _window(r:Node3D,p:Vector3,w:float,h:float,t:Vector3,n:Vector3,trim:Material,glass:Material,dark:Material)->void:
	var opening:Dictionary=KIT.new_bucket()
	var frames:Dictionary=KIT.new_bucket()
	KIT.append_grouped_opening(opening,frames,p,t,n,w,h,0.025,0.055,0.065,0.045)
	_emit(r,"WindowGlass",opening,glass)
	_emit(r,"WindowFrames",frames,dark)
	var sill:Dictionary=KIT.new_bucket()
	KIT.append_box(sill,p-Vector3.UP*(h/2+0.065)+n*0.04,t,n,w+0.19,0.07,0.20)
	_emit(r,"WindowSill",sill,trim)

static func _garage(r:Node3D,x:float,z:float,peach:Material,trim:Material,dark:Material)->void:
	_box(r,"GarageReveal",Vector3(2.8,2.22,0.05),Vector3(x,1.14,z+0.01),dark)
	_box(r,"GarageDoor",Vector3(2.66,2.12,0.04),Vector3(x,1.12,z+0.045),peach)
	for dx in [-1.39,1.39]:_box(r,"GarageJamb",Vector3(0.10,2.29,0.16),Vector3(x+dx,1.16,z+0.12),peach)
	_box(r,"GarageHeader",Vector3(2.87,0.11,0.16),Vector3(x,2.29,z+0.12),peach)
	for y in [0.58,1.1,1.62]:
		_box(r,"GaragePanelSeam",Vector3(2.57,0.015,0.014),Vector3(x,y,z+0.071),trim)
	_box(r,"GarageHandle",Vector3(0.13,0.035,0.035),Vector3(x,1.04,z+0.09),dark)

static func _door(r:Node3D,p:Vector3,peach:Material,trim:Material,dark:Material)->void:
	_box(r,"EntryReveal",Vector3(0.99,2.23,0.06),p+Vector3(0,1.115,0),dark)
	_box(r,"EntryDoor",Vector3(0.84,2.10,0.05),p+Vector3(0,1.07,0.038),peach)
	_box(r,"DoorHandle",Vector3(0.035,0.13,0.055),p+Vector3(0.30,1.02,0.08),dark)

static func _hip(r:Node3D,p:Vector3,size:Vector2,rise:float,m:Material,trim:Material)->void:
	var x:=size.x/2.0
	var z:=size.y/2.0
	var ridge:=maxf(0.25,x-z*0.65)
	var a:=p+Vector3(-x,0,-z)
	var b:=p+Vector3(x,0,-z)
	var c:=p+Vector3(x,0,z)
	var d:=p+Vector3(-x,0,z)
	var e:=p+Vector3(-ridge,rise,0)
	var f:=p+Vector3(ridge,rise,0)
	COURT._quad(r,"HipFront",[d,c,f,e],m)
	COURT._quad(r,"HipRear",[b,a,e,f],m)
	_triangle(r,[a,d,e],m)
	_triangle(r,[c,b,f],m)
	_box(r,"EaveFasciaFront",Vector3(size.x,0.15,0.11),p+Vector3(0,-0.06,z),trim)
	_box(r,"EaveFasciaRear",Vector3(size.x,0.15,0.11),p+Vector3(0,-0.06,-z),trim)
	_box(r,"EaveFasciaEnd",Vector3(0.11,0.15,size.y),p+Vector3(x,-0.06,0),trim)
	_box(r,"EaveFasciaEnd",Vector3(0.11,0.15,size.y),p+Vector3(-x,-0.06,0),trim)

static func _triangle(r:Node3D,v:Array,m:Material)->void:
	var b:Dictionary=KIT.new_bucket()
	var normal:Vector3=(v[1]-v[0]).cross(v[2]-v[0]).normalized()
	if normal.y<0:
		var swap:Vector3=v[1];v[1]=v[2];v[2]=swap
		normal=-normal
	b.vertices=v
	b.normals=[normal,normal,normal]
	b.uvs=[Vector2.ZERO,Vector2(1,0),Vector2(0,1)]
	b.indices=[0,2,1]
	_emit(r,"HipEnd",b,m)

static func _balcony(r:Node3D,p:Vector3,t:Vector3,n:Vector3,w:float,back:Material,slab:Material,rail:Material)->void:
	var voids:Dictionary=KIT.new_bucket()
	var slabs:Dictionary=KIT.new_bucket()
	var rails:Dictionary=KIT.new_bucket()
	KIT.append_recessed_balcony_or_breezeway(voids,slabs,rails,p,t,n,w,2.25,0.04,0.16,1.00,p.y-0.60,0.9,0.045,0.022,0.16,0.04)
	_emit(r,"BalconyBacking",voids,back)
	_emit(r,"BalconySlab",slabs,slab)
	for sign_value in [-1.0,1.0]:
		KIT.append_simple_rail(rails,p+t*(w*0.5-0.07)+n*0.56-Vector3.UP*0.60 if sign_value>0 else p-t*(w*0.5-0.07)+n*0.56-Vector3.UP*0.60,n,t,0.95,0.9,0.045,0.022,0.16,0.04)
	_emit(r,"BalconyRail",rails,rail)
	_window(r,p+n*0.045+Vector3(0,0.13,0),0.97,1.3,t,n,slab,rail,rail)

static func _stairs(r:Node3D,x:float,z:float,rise:float,run:float,slab:Material,rail:Material)->void:
	var count:=17
	for i in count:
		var y:=rise*(1.0-float(i)/count)
		_box(r,"StairTread",Vector3(1.20,0.12,run/count+0.015),Vector3(x,y-0.06,z+(i+0.5)*run/count),slab)
	for side in [-0.63,0.63]:
		var a:=Vector3(x+side,rise+0.91,z)
		var b:=Vector3(x+side,0.91,z+run)
		COURT._beam(r,"StairHandrail",a,b,0.055,0.055,rail)
		COURT._beam(r,"StairStringer",a-Vector3.UP*1.05,b-Vector3.UP*1.05,0.10,0.18,rail)
		for i in range(0,count+1,2):
			var f:=float(i)/count
			_box(r,"StairPicket",Vector3(0.032,0.93,0.032),Vector3(x+side,rise*(1-f)+0.46,z+run*f),rail)

static func _back_shell(r:Node3D,lo:float,hi:float,opening_x:float,m:Material,top:float=5.8)->void:
	var width:=4.6
	var left:=opening_x-width/2.0
	var right:=opening_x+width/2.0
	# The opaque core ends at z=-3.7; returns run to the original z=-5.5 face.
	_box(r,"GardenLeftReturn",Vector3(left-lo,top,1.8),Vector3((lo+left)/2,top/2,-4.6),m)
	_box(r,"GardenRightReturn",Vector3(hi-right,top,1.8),Vector3((hi+right)/2,top/2,-4.6),m)
	_box(r,"GardenUpperHeader",Vector3(width,top-5.35,1.8),Vector3(opening_x,(top+5.35)/2,-4.6),m)
	_box(r,"GardenFloorFascia",Vector3(width,0.28,1.8),Vector3(opening_x,2.93,-4.6),m)

static func _garden_bay(r:Node3D,x:float,width:float,peach:Material,white:Material,slab:Material,trim:Material,glass:Material,dark:Material)->void:
	# Backings are inset 1.76 m from the white garden face, leaving actual air.
	_box(r,"PatioPeachBack",Vector3(width,2.79,0.04),Vector3(x,1.395,-3.72),peach)
	_box(r,"BalconyPeachBack",Vector3(width,2.28,0.04),Vector3(x,4.21,-3.72),peach)
	_box(r,"PatioPaving",Vector3(width,0.12,1.95),Vector3(x,0.02,-4.655),slab)
	_window(r,Vector3(x-0.55,1.40,-3.77),1.65,1.15,Vector3.LEFT,Vector3.FORWARD,trim,glass,dark)
	_window(r,Vector3(x-0.55,4.28,-3.77),1.45,1.25,Vector3.LEFT,Vector3.FORWARD,trim,glass,dark)
	var rails:Dictionary=KIT.new_bucket()
	KIT.append_simple_rail(rails,Vector3(x,3.54,-5.48),Vector3.LEFT,Vector3.FORWARD,width-0.12,0.9,0.045,0.022,0.16,0.04)
	_emit(r,"GardenBalconyRail",rails,dark)

static func _side_shell(r:Node3D,x:float,lo:float,hi:float,opening_z:float,width:float,m:Material)->void:
	var left:=opening_z-width/2
	var right:=opening_z+width/2
	_box(r,"SouthBalconyReturn",Vector3(1.0,2.8,left-lo),Vector3(x-0.5,4.4,(lo+left)/2),m)
	_box(r,"SouthBalconyReturn",Vector3(1.0,2.8,hi-right),Vector3(x-0.5,4.4,(right+hi)/2),m)
	_box(r,"SouthBalconyHeader",Vector3(1.0,0.455,width),Vector3(x-0.5,5.5725,opening_z),m)
	_box(r,"SouthBalconySillWall",Vector3(1.0,0.095,width),Vector3(x-0.5,3.0475,opening_z),m)
