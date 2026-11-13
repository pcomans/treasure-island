extends RefCounted
## The player at the wheel of a driven car, seen through its glass at the hero
## level: the chest avatar's own parts (chest_avatar_parts.gd: the chest of
## gold, its lid shut, its eyes, the rubber-hose arms and gloves) sitting on
## the driver's seat with both hands on the wheel at ten to two, a little
## smaller than on foot so it fits a car's seat. Still: no getting in or out,
## no steering; the legs are under the dashboard, so it has none. The seat and
## the grips are the hero kit's markers (car_<body>_driver_seat,
## _driver_hand_left, _driver_hand_right, from tools/lib/street-car-parts.mjs
## buildCabin), in the car frame.

const Parts := preload("res://game/scripts/player/chest_avatar_parts.gd")
## The figure's size against the avatar on foot (its chest is wider than a seat).
const SCALE := 0.72


## The figure in the car frame: its chest's bottom on the seat's cushion, facing
## the car's front (-Z); hands are the car frame's grips, left (the car's -X side)
## and right.
static func build(seat: Vector3, hand_left: Vector3, hand_right: Vector3) -> Node3D:
	var m := Parts.make_materials()
	m.eye.set_shader_parameter("look", Vector2(0.0, -0.08))
	m.eye.set_shader_parameter("blink", 0.0)
	var root := Node3D.new()
	root.name = "Driver"
	# The avatar faces its +Z; turned half round it faces the car's -Z.
	root.transform = Transform3D(Basis(Vector3.UP, PI).scaled(Vector3.ONE * SCALE), seat)
	_mesh(root, "Chest", Parts.body(m))
	_mesh(root, "ChestOutline", Parts.body_outline(m))
	var lid := Node3D.new()
	lid.name = "Lid"
	lid.position = Parts.HINGE
	root.add_child(lid)
	_mesh(lid, "LidBoards", Parts.lid(m))
	_mesh(lid, "LidOutline", Parts.lid_outline(m))
	var eyes := Node3D.new()
	eyes.name = "EyeMount"
	eyes.position = Parts.EYE_MOUNT
	lid.add_child(eyes)
	_mesh(eyes, "Eyes", Parts.eyes(m))
	# Arms from the shoulders to the grips, in the figure's frame.
	var to_figure := root.transform.affine_inverse()
	var hose := Parts.hose(Parts.hose_material(Parts.ARM_RADIUS))
	for arm: Array in [[1.0, hand_left], [-1.0, hand_right]]:
		var side := float(arm[0])
		var hand: Vector3 = to_figure * (arm[1] as Vector3)
		var out := Vector3(side, 0.0, 0.0)
		var shoulder := Vector3(side * Parts.SHOULDER.x, Parts.SHOULDER.y, Parts.SHOULDER.z)
		var p0 := shoulder - out * 0.03
		var lam := 0.1 + maxf(0.0, Parts.ARM_LENGTH - p0.distance_to(hand)) * 0.6
		# Out of the shoulder, then forward and down toward the wheel.
		var p1 := p0 + (out * 0.5 + Vector3(0.0, -0.2, 0.6)).normalized() * lam
		var arrive := (hand - (shoulder + out * 0.12)).normalized()
		var p2 := hand - arrive * lam
		var material := Parts.hose_material(Parts.ARM_RADIUS)
		_bend(material, p0, p1, p2, hand, Vector3.BACK)
		var arm_hose := _mesh(root, "ArmHose", hose)
		arm_hose.material_override = material
		arm_hose.custom_aabb = AABB(Vector3(-1.5, -1.0, -1.5), Vector3(3.0, 3.5, 3.0))
		# The glove continues the hose, its palm toward the wheel.
		var y_axis := -(hand - p2).normalized()
		var x_axis := Vector3.RIGHT
		if absf(x_axis.dot(y_axis)) > 0.95:
			x_axis = y_axis.cross(Vector3.BACK).normalized()
		x_axis = (x_axis - y_axis * x_axis.dot(y_axis)).normalized()
		var glove := Node3D.new()
		glove.name = "Glove"
		glove.transform = Transform3D(Basis(x_axis, y_axis, x_axis.cross(y_axis)), hand)
		root.add_child(glove)
		_mesh(glove, "GloveMesh", Parts.glove(m, side, false))
		_mesh(glove, "GloveOutline", Parts.glove(m, side, true))
	return root


static func _mesh(parent: Node3D, node_name: String, mesh: Mesh) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	# The hero level casts no shadow of its own (its shadow caster does).
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance


## A hose's Bezier (as chest_avatar.gd bends its limbs).
static func _bend(material: ShaderMaterial, p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, fallback: Vector3) -> void:
	var plane := (p3 - p0).cross((p1 - p0) + (p2 - p0))
	if plane.length_squared() < 1e-8:
		plane = fallback
	material.set_shader_parameter("p0", p0)
	material.set_shader_parameter("p1", p1)
	material.set_shader_parameter("p2", p2)
	material.set_shader_parameter("p3", p3)
	material.set_shader_parameter("bend_normal", plane.normalized())
