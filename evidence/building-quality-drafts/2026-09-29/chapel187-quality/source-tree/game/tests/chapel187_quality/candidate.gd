extends "res://game/scripts/world/facades/navy_chapel_187_standalone_hero_prototype.gd"
# Reuse the accepted Chapel's source-frame, clockwise mesh and complete box/frame emitters.
# Whole-building proportions are reversible inference from the dated public oblique.
static func build(wall:Dictionary,roof:Dictionary,cfg:Dictionary)->Node3D:
	var model=load("res://game/tests/chapel187_quality/candidate.gd").new()
	model.auto_configure_from_frozen_source=false
	model._compose(wall,roof,cfg)
	return model

func _material(color:Color,roughness:float)->StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=color;m.roughness=roughness
	return m

func _compose(wall:Dictionary,roof_record:Dictionary,cfg:Dictionary)->void:
	name="Chapel187QualityStudy"
	var shell:=_bucket();var roofing:=_bucket();var trim:=_bucket();var cross:=_bucket();var glass:=_bucket();var wood:=_bucket()
	var c:=Vector3(cfg.front_center[0],0,cfg.front_center[2])
	var t:=Vector3(cfg.tangent[0],0,cfg.tangent[2]).normalized()
	var n:=Vector3(cfg.normal[0],0,cfg.normal[2]).normalized()
	for run:int in range(34):
		var f:=_run_frame(wall,run)
		var start:Vector3=f.start;var finish:Vector3=f.end
		var cuts:Array[float]=[0.0,1.0]
		for plane:Array in [[t,float(cfg.width)*.5+.10],[-t,float(cfg.width)*.5+.10]]:
			var av:float=(start-c).dot(plane[0]);var bv:float=(finish-c).dot(plane[0])
			if absf(bv-av)>.00001:
				var fraction:float=(float(plane[1])-av)/(bv-av)
				if fraction>0.0 and fraction<1.0:cuts.append(fraction)
		cuts.sort()
		for i:int in range(cuts.size()-1):
			var left:Vector3=start.lerp(finish,cuts[i]);var right:Vector3=start.lerp(finish,cuts[i+1])
			var middle:Vector3=(left+right)*.5
			var top:float=8.0 if absf((middle-c).dot(t))>float(cfg.width)*.5+.10 else float(cfg.eave_y)
			_append_quad(shell,left,right,Vector3(right.x,top,right.z),Vector3(left.x,top,left.z),f.normal)
	# Retained exact footprint roof closure, lowered for the ancillary wing.
	var lower:Dictionary=roof_record.duplicate(true)
	for k:int in range(1,lower.vertices.size(),3):lower.vertices[k]=8.0
	_append_record_mesh(roofing,lower)
	var inf:Dictionary=JSON.parse_string(FileAccess.get_file_as_string(CONFIG_PATH)).production_inference_m
	inf.main_gable_width=cfg.width;inf.main_gable_length=cfg.main_length
	inf.main_gable_eave_y=cfg.eave_y;inf.main_gable_ridge_y=cfg.ridge_y
	var unused:=_bucket()
	_append_gabled_roof(shell,shell,roofing,unused,Vector3(c.x,cfg.eave_y,c.z),t,n,inf)
	# Source footprint has two transverse wings. Their roof ridges run across the nave.
	for wing:Array in [[1.0,29.86,7.93,8.68],[-1.0,29.705,7.93,9.0]]:
		var direction:float=wing[0]
		var wi:Dictionary=inf.duplicate(true)
		wi.main_gable_width=wing[2];wi.main_gable_length=wing[3]
		wi.main_gable_eave_y=8.0;wi.main_gable_ridge_y=10.25
		var wc:Vector3=c+t*8.18*direction-n*float(wing[1])+Vector3.UP*8.0
		_append_gabled_roof(shell,shell,roofing,unused,wc,-n,-t*direction,wi)
		for edge:float in [-1.0,1.0]:
			_append_box(trim,wc-n*float(wing[2])*.5*edge+t*direction*float(wing[3])*.5,-n,t,.14,.16,float(wing[3])+.16)
	# Windowed public side wing seen in the September2025 oblique.
	for station:float in [1.0,2.7,4.4,6.1]:
		var wing_frame:=_chain_frame(wall,[17,18],station)
		_window(glass,trim,wing_frame.wall_anchor,6.05,7.65,1.25,wing_frame.tangent,wing_frame.normal,0)
	inf.belfry_center_inward_from_sse_m=15.0;inf.belfry_plan_width=4.0;inf.belfry_plan_depth=4.0
	inf.belfry_base_y=13.6;inf.belfry_wall_top_y=19.0;inf.belfry_cap_apex_y=20.2
	inf.cross_vertical_center_y=20.9;inf.cross_vertical_height=1.4;inf.cross_horizontal_center_y=21.05;inf.cross_horizontal_width=.9;inf.cross_member_thickness=.075
	_append_belfry(shell,roofing,cross,unused,c,t,n,inf)
	# Thin shelter, slender paired uprights and warm closed entry; no solid porch block.
	_append_box(trim,c+n*.85+Vector3.UP*7.25,t,n,6.0,.16,1.7)
	for i:int in range(2):
		var x:float=[-2.35,2.35][i]
		var base_y:float=[4.03023606246241, 3.9969126491914935][i] # Minimum of four actual frozen LAND footprint-corner heights; tiny embedding, no floating corner.
		_append_box(trim,c+t*x+n*1.35+Vector3.UP*((base_y+7.24)*.5),t,n,.12,7.24-base_y,.12)
	_append_box(wood,c+n*.045+Vector3.UP*((3.998350+6.795)*.5),t,n,1.6,6.795-3.998350,.08)
	_append_frame(trim,c+n*.11+Vector3.UP*5.42,t,n,1.6,2.75,.12,.15)
	for x:float in [-1.55,1.55]:
		_window(glass,trim,c+t*x,4.35,6.96,1.04,t,n,2)
	for x:float in [-5.7,5.7]:_window(glass,trim,c+t*x,5.0,6.25,.62,t,n,1)
	# The upper glazing follows the gable, with a central weathered opaque panel.
	for column:int in range(7):
		var x:float=(column-3)*.57
		var top:float=14.92-absf(x)*.68
		_window(glass,trim,c+t*x,8.05,top,.48,t,n,2)
	_append_box(wood,c+n*.105+Vector3.UP*9.73,t,n,1.02,3.2,.07)
	# Actual observed long-side groups; hidden continuation remains simple.
	for station:float in [2.0,5.4,8.8]:
		var f:=_chain_frame(wall,OBSERVED_PARTIAL_SIDE_RUNS,station)
		if not f.is_empty():
			for x:float in [-.62,0,.62]:_window(glass,trim,(f.wall_anchor as Vector3)+(f.tangent as Vector3)*x,5.25,9.1,.5,f.tangent,f.normal,1)
	# Continuous, quiet eave/rake boards give the roof a real edge.
	for sign_value:float in [-1.0,1.0]:
		var start:Vector3=c+t*float(cfg.width)*.5*sign_value+Vector3.UP*float(cfg.eave_y)
		_append_box(trim,start-n*float(cfg.main_length)*.5,t,n,.16,.18,float(cfg.main_length)+.35)
		var end:Vector3=c+Vector3.UP*float(cfg.ridge_y)
		var axis:Vector3=(end-start).normalized()
		_append_box(trim,(start+end)*.5+n*.06,axis,n,start.distance_to(end)+.12,.16,.18)
	var specs:Array=[['CreamShell',shell,_material(Color(.72,.70,.61),.88),2,true],['Roof',roofing,_material(Color(.24,.205,.175),.93),1,false],['Trim',trim,_material(Color(.78,.76,.66),.8),2,true],['Cross',cross,_material(Color(.78,.76,.66),.8),1,false],['Glazing',glass,_material(Color(.17,.23,.24),.35),2,true],['Timber',wood,_material(Color(.36,.27,.18),.86),2,true]]
	for spec:Array in specs:
		var bucket:Dictionary=spec[1]
		if bucket.indices.is_empty():continue
		var mesh:=_mesh_instance(spec[0],bucket,spec[2],spec[3]);add_child(mesh)
		var body:=_collision_body(bucket)
		body.name=str(spec[0])+"Contact";body.collision_layer=5;body.collision_mask=0
		var key:String=WALL_KEY if spec[4] else ROOF_KEY
		for owner:Object in [mesh,body,body.get_child(0),(body.get_child(0) as CollisionShape3D).shape]:
			owner.set_meta("derived_object_key",key);owner.set_meta("source_keys",["w291189336"]);owner.set_meta("opaque",true);owner.set_meta("receiver_kind","building_wall" if spec[4] else "none")
		if spec[4]:body.add_to_group("spray_receiver_wall")
		add_child(body)
	set_meta("build_valid",true)

func _window(glass:Dictionary,trim:Dictionary,anchor:Vector3,bottom:float,top:float,width:float,t:Vector3,n:Vector3,dividers:int)->void:
	var center:=Vector3(anchor.x,(bottom+top)*.5,anchor.z)+n*.035
	_append_box(glass,center,t,n,width,top-bottom,.06)
	_append_frame(trim,center+n*.055,t,n,width,top-bottom,.065,.12)
	for i:int in range(1,dividers+1):
		var bar:=center+n*.055;bar.y=lerpf(bottom,top,float(i)/float(dividers+1))
		_append_box(trim,bar,t,n,width,.055,.12)
