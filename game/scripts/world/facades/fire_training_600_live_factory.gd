extends RefCounted
## Builds Building 600 for the live island from its source records: the model
## (fire_training_600_model.gd) as the wall node, with its roof mesh and roof
## collision moved into a separate roof node (one node per source record).
const MODEL := preload("res://game/scripts/world/facades/fire_training_600_model.gd")
const SOURCE := "w34313548"
const ROOF := "building:w34313548:roof"


static func build(roof: Dictionary, wall: Dictionary, land_records: Array) -> Dictionary:
	var model: Node3D = MODEL.new()
	var built: Dictionary = model.build(roof, wall, land_records)
	if not built.get("ok", false):
		model.free()
		return {"ok": false, "message": str(built.get("message", "Building 600 construction failed."))}
	model.set_meta("feature_kind", "building_wall")
	var roof_root := Node3D.new()
	roof_root.name = "FireTraining600Roof"
	roof_root.transform = model.transform
	for child: Node in model.get_children():
		if str(child.get_meta("derived_object_key", "")) == ROOF:
			model.remove_child(child)
			roof_root.add_child(child)
	roof_root.set_meta("source_keys", [SOURCE])
	roof_root.set_meta("derived_object_key", ROOF)
	roof_root.set_meta("feature_kind", "building_roof")
	return {"ok": true, "wall": _result(model), "roof": _result(roof_root)}


## The node plus the counts the world builder adds to its totals.
static func _result(root: Node3D) -> Dictionary:
	var meshes := 0
	var surfaces := 0
	var triangles := 0
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := (node as MeshInstance3D).mesh
		meshes += 1
		surfaces += mesh.get_surface_count()
		triangles += mesh.get_faces().size() / 3
	var bodies := root.find_children("*", "CollisionObject3D", true, false)
	var shapes := root.find_children("*", "CollisionShape3D", true, false)
	return {"ok": true, "node": root, "mesh_instances": meshes, "surfaces": surfaces, "triangles": triangles, "static_bodies": bodies.size(), "shapes": shapes.size()}
