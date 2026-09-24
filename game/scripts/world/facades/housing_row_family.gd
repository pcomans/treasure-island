extends RefCounted
## Reusable visual study, assembled in metres with +Z frontage and root scale1.
## Reuse decision:1232's recessed openings/entry construction suits this row family;
## fixed site geometry does not, so repeat bays + terminal caps replace its layout.
## All dimensions/cadence are production inference; no address, land or collision claim.
const PARTS = preload("res://game/scripts/world/facades/northpoint_1232_quality_model.gd")
const VariantConfig = preload("res://game/scripts/world/facades/housing_family_variant.gd")
const SIDING = preload("res://game/resources/housing_family/siding.gdshader")
const ROOF = preload("res://game/resources/housing_family/roof.gdshader")
const BAY_WIDTH := 6.0
const DEPTH := 8.0
const EAVE := 5.4
const RIDGE := 6.5
var _bay: PackedScene
var _cap: PackedScene
var _canopy: PackedScene
var _canopy_end: PackedScene
var _materials: Dictionary

func _init() -> void:
	var walls := ShaderMaterial.new()
	walls.shader = SIDING
	var roof := ShaderMaterial.new()
	roof.shader = ROOF
	_materials = {
		"walls": walls, "roof": roof,
		"doors": PARTS._material(Color(0.075, 0.13, 0.19), 0.7),
		"trim": PARTS._material(Color(0.87, 0.88, 0.82), 0.72),
		"dark": PARTS._material(Color(0.07, 0.13, 0.16), 0.36),
		"glass": PARTS._material(Color(0.25, 0.34, 0.36), 0.23),
		"concrete": PARTS._material(Color(0.56, 0.57, 0.51), 0.95),
		"steel": PARTS._material(Color(0.30, 0.26, 0.20), 0.85),
		"fascia": PARTS._material(Color(0.42, 0.43, 0.39), 0.95),
		"rust": PARTS._material(Color(0.39, 0.27, 0.17), 0.95),
		"underside": PARTS._material(Color(0.16, 0.20, 0.19), 0.97),
	}
	_bay = _make_bay()
	_cap = _make_cap()
	_canopy = _make_canopy(false)
	_canopy_end = _make_canopy(true)

func instantiate(config: Resource) -> Node3D:
	if not config is VariantConfig or not config.is_valid():
		push_error("Invalid housing family variant: canopy must fit the row.")
		return null
	var root := Node3D.new()
	root.name = "HousingFamilyStudy"
	root.set_meta("asset_scope", "structural_visual_study_no_site_identity")
	root.set_meta("row_length", config.bay_count * BAY_WIDTH)
	for i in config.bay_count:
		_place(root, _bay, "Bay_%02d" % i, Vector3(i * BAY_WIDTH, 0, 0))
	_place(root, _cap, "LeftCap", Vector3.ZERO)
	var right := _place(root, _cap, "RightCap", Vector3(config.bay_count * BAY_WIDTH, 0, -DEPTH))
	right.rotation.y = PI
	for i in config.canopy_bays:
		_place(root, _canopy, "Canopy_%02d" % i, Vector3((config.canopy_start + i) * BAY_WIDTH, 0, 0))
	if config.canopy_bays > 0:
		_place(root, _canopy_end, "CanopyEnd", Vector3((config.canopy_start + config.canopy_bays) * BAY_WIDTH, 0, 0))
	# Meshes are shared between all modules/instances. Every finish is instance-local.
	var material_copies: Dictionary = {}
	for node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh := node as MeshInstance3D
		var original := mesh.material_override
		if not material_copies.has(original): material_copies[original] = original.duplicate(true)
		mesh.material_override = material_copies[original]
		match str(mesh.get_meta("appearance_slot", "")):
			"walls": mesh.material_override.set_shader_parameter("wall_color", config.walls)
			"doors": mesh.material_override.albedo_color = config.doors
	return root

func _place(root: Node3D, scene: PackedScene, label: String, position: Vector3) -> Node3D:
	var node := scene.instantiate() as Node3D
	node.name = label
	node.position = position
	root.add_child(node)
	return node

func _pack(root: Node3D) -> PackedScene:
	for node: MeshInstance3D in root.get_children():
		node.owner = root
		if node.material_override == _materials.walls: node.set_meta("appearance_slot", "walls")
		elif node.material_override == _materials.doors: node.set_meta("appearance_slot", "doors")
	var packed := PackedScene.new()
	packed.pack(root)
	root.free()
	return packed

func _box(root: Node3D, p: Vector3, size: Vector3, material: String) -> void:
	PARTS._box(root, p, size, _materials[material])

func _make_bay() -> PackedScene:
	var root := Node3D.new()
	root.set_meta("module_span", Vector2(0, BAY_WIDTH))
	root.set_meta("opening_dimensions", Vector4(1.78, 1.30, 0.92, 2.13))
	# Full recessed motifs, never stretched when changing row length.
	for back in [false, true]:
		var start := Vector3(BAY_WIDTH, 0, -DEPTH) if back else Vector3.ZERO
		var t := Vector3.LEFT if back else Vector3.RIGHT
		var n := Vector3.FORWARD if back else Vector3.BACK
		var holes: Array[Rect2] = []
		for station in [1.5, 4.5]:
			holes.append(Rect2(station - 0.89, 3.65, 1.78, 1.30))
			PARTS._recessed_window(root, start + t * station + Vector3.UP * 4.30, t, n, 1.78, 1.30, _materials.trim, _materials.dark, _materials.glass)
		holes.append(Rect2(1.34, 0.90, 1.52, 1.34))
		PARTS._recessed_window(root, start + t * 2.1 + Vector3.UP * 1.57, t, n, 1.52, 1.34, _materials.trim, _materials.dark, _materials.glass)
		if not back:
			holes.append(Rect2(4.24, 0.03, 0.92, 2.13))
			PARTS._entry(root, start + t * 4.7 + Vector3.UP * 1.095, t, n, _materials.trim, _materials.doors, _materials.concrete)
			_box(root, Vector3(4.7, 0.005, 1.53), Vector3(1.1, 0.05, 2.65), "concrete")
		PARTS._wall_with_openings(root, start, start + t * BAY_WIDTH, EAVE, holes, _materials.walls)
		_box(root, Vector3(3, EAVE - 0.06, -DEPTH if back else 0.0), Vector3(BAY_WIDTH, 0.16, 0.32), "trim")
		# Foundation band is split around the entry instead of bridging the doorway.
		if back: _box(root, Vector3(3, 0.10, -DEPTH - 0.01), Vector3(BAY_WIDTH, 0.20, 0.05), "concrete")
		else:
			_box(root, Vector3(2.07, 0.10, 0.01), Vector3(4.14, 0.20, 0.05), "concrete")
			_box(root, Vector3(5.63, 0.10, 0.01), Vector3(0.74, 0.20, 0.05), "concrete")
	# Adjacent roof strips meet at x=0/6 exactly; only terminal caps overhang.
	_roof_strip(root, 0.0, BAY_WIDTH)
	var pipe := CylinderMesh.new()
	pipe.top_radius = 0.055
	pipe.bottom_radius = 0.055
	pipe.height = 0.28
	pipe.radial_segments = 8
	var vent := MeshInstance3D.new()
	vent.mesh = pipe
	vent.material_override = _materials.trim
	vent.position = Vector3(3.8, RIDGE - 0.02, -3.45)
	root.add_child(vent)
	_box(root, Vector3(3.8, RIDGE + 0.12, -3.45), Vector3(0.16, 0.025, 0.16), "roof")
	return _pack(root)

func _roof_strip(root: Node3D, left: float, right: float) -> void:
	for z in [0.4, -DEPTH - 0.4]:
		var pts := [Vector3(left, EAVE - 0.11, z), Vector3(right, EAVE - 0.11, z), Vector3(right, RIDGE, -DEPTH / 2), Vector3(left, RIDGE, -DEPTH / 2)]
		# Explicit upwards winding for the two opposing slopes.
		if z < 0: pts.reverse()
		PARTS._quad(root, pts, _materials.roof)
		root.get_child(-1).set_meta("module_surface", "roof_slope")
	_box(root, Vector3((left + right) / 2, RIDGE + 0.018, -DEPTH / 2), Vector3(right - left, 0.065, 0.17), "roof")

func _make_cap() -> PackedScene:
	var root := Node3D.new()
	PARTS._quad(root, [Vector3(0, 0, -DEPTH), Vector3(0, 0, 0), Vector3(0, EAVE, 0), Vector3(0, EAVE, -DEPTH)], _materials.walls)
	PARTS._mesh(root, [Vector3(0, EAVE, 0), Vector3(0, RIDGE, -DEPTH / 2), Vector3(0, EAVE, -DEPTH)], PackedInt32Array([0, 2, 1]), _materials.walls)
	root.get_child(-1).set_meta("module_surface", "gable")
	for z in [0.0, -DEPTH]:
		_box(root, Vector3(-0.015, EAVE / 2, z), Vector3(0.09, EAVE, 0.10), "trim")
		PARTS._beam(root, Vector3(-0.12, EAVE - 0.11, z + (0.4 if z == 0 else -0.4)), Vector3(-0.12, RIDGE, -DEPTH / 2), 0.12, 0.16, _materials.trim)
	_roof_strip(root, -0.35, 0.0)
	return _pack(root)

func _make_canopy(terminal: bool) -> PackedScene:
	var root := Node3D.new()
	root.set_meta("module_span", Vector2(0, 0 if terminal else BAY_WIDTH))
	# One post line per seam, plus one final line; no doubled internal supports.
	for z in [3.25, 7.15]:
		_box(root, Vector3(0, 1.32, z), Vector3(0.085, 2.64, 0.085), "steel")
		_box(root, Vector3(0, 0.65, z), Vector3(0.095, 0.18, 0.095), "trim")
	_box(root, Vector3(0, 2.67, 5.2), Vector3(0.095, 0.18, 4.05), "underside")
	if not terminal:
		_box(root, Vector3(3, 2.83, 5.2), Vector3(BAY_WIDTH, 0.12, 4.25), "roof")
		_box(root, Vector3(3, 2.76, 5.2), Vector3(BAY_WIDTH, 0.02, 4.10), "underside")
		for z in [3.08, 7.32]:
			_box(root, Vector3(3, 2.78, z), Vector3(BAY_WIDTH, 0.24, 0.11), "fascia")
			_box(root, Vector3(3, 2.91, z), Vector3(BAY_WIDTH, 0.025, 0.12), "rust")
	else:
		_box(root, Vector3(0, 2.78, 5.2), Vector3(0.11, 0.24, 4.25), "fascia")
	return _pack(root)
