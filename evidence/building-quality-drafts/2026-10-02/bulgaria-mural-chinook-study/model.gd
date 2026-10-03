extends RefCounted
const COURT = preload("court.gd")
const NEIGHBOR = preload("neighbor.gd")
static func build() -> Node3D:
	var root := Node3D.new()
	root.name = "BulgarianWallAnd1445ChinookStudy"
	root.add_child(COURT.build())
	var building := NEIGHBOR.build()
	building.position = Vector3(-17.8,0,-8)
	building.rotation.y = -PI/2.0
	root.add_child(building)
	return root
