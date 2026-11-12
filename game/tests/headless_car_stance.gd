extends SceneTree
## The stock player stands on the street cars as they are drawn: on each body's
## hood, roof and (where it has one) trunk or bed, it comes to rest with its
## feet on the drawn surface, neither floating over it nor sunk into it. Both
## ways a car collides: a parked car (a static body with the kit's pieces, as
## street_clutter_builder.gd makes it) and a driven car (drivable_car.gd's
## rigid body, frozen as it is when left parked). The gap is measured from the
## capsule's lower sphere to the drawn near level (what the web and every car
## past 15 m draw) and the hero level (the desktop's nearest cars).
## Physics only (run with --headless); no world is loaded.

const KIT := preload("res://game/scripts/world/street_clutter_kit.gd")
const DRIVABLE_CAR := preload("res://game/scripts/vehicles/drivable_car.gd")
const PLAYER_SCENE := "res://game/scenes/player/player.tscn"
## How far the feet may rest from what is drawn under them (m): about what a
## shoe's sole shows at a glance.
const STANCE_TOLERANCE_M := 0.03
## Physics ticks to let the player land and settle (the jetpack's slow descent
## brings it down 0.3 m in a fifth of a second).
const SETTLE_TICKS := 90
const PHYSICS_STREET_PROP := 1 << 3

var _failures: Array[String] = []


func _initialize() -> void:
	create_timer(240.0, true, false, true).timeout.connect(func() -> void:
		push_error("car stance: timed out")
		quit(1))
	call_deferred("_run")


func _run() -> void:
	var stage := Node3D.new()
	stage.name = "CarStance"
	root.add_child(stage)
	var ground := StaticBody3D.new()
	ground.collision_layer = 1
	var floor_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(40.0, 1.0, 40.0)
	floor_shape.shape = box
	floor_shape.position = Vector3(0.0, -0.5, 0.0)
	ground.add_child(floor_shape)
	stage.add_child(ground)
	var kit := KIT.new()
	var player := (load(PLAYER_SCENE) as PackedScene).instantiate() as PlayerController
	stage.add_child(player)
	var capsule := (player.get_node("CollisionShape3D") as CollisionShape3D).shape as CapsuleShape3D
	var radius := capsule.radius
	for body: String in KIT.CAR_BODIES:
		var parts := kit.drivable(body)
		if not parts.ok or (parts.hulls as Array).is_empty():
			_failures.append("%s: the kit has no collision pieces for it" % body)
			continue
		var near := kit.parts("parked_car", {"body": body, "paint": "white", "finish": "solid"})
		var drawn := {"near": _faces((near.meshes as Array)[0] as Mesh)}
		var hero := kit.hero(body)
		if hero.ok:
			drawn.hero = _faces(hero.body as Mesh) + _faces(hero.glass as Mesh)
		# The car's own zf (from its front bumper) to the car frame's z.
		var chassis_box := (parts.chassis as Mesh).get_aabb()
		var half_length := -(chassis_box.position.z + 0.06)
		var cabin: Array = DRIVABLE_CAR.BODIES[body].cabin
		var spots := {"hood": 0.55 * float(cabin[0]), "roof": (float(cabin[1]) + float(cabin[2])) * 0.5}
		if float(cabin[3]) < 2.0 * half_length - 0.5:
			spots["trunk or bed"] = (float(cabin[3]) + 2.0 * half_length) * 0.5
		for way: String in ["parked", "driven"]:
			var car := _car(way, body, kit, parts)
			stage.add_child(car)
			for spot: String in spots:
				var z := float(spots[spot]) - half_length
				var surface := _height(drawn.near as PackedVector3Array, Vector3(0.0, 5.0, z))
				player.set_gameplay_enabled(false)
				player.global_position = Vector3(0.0, surface + 0.3, z)
				player.velocity = Vector3.ZERO
				player.set_gameplay_enabled(true)
				for _i in SETTLE_TICKS:
					await physics_frame
				player.set_gameplay_enabled(false)
				var feet := player.global_position
				var centre := feet + Vector3.UP * radius
				var line := "STANCE %s %s %s: feet at %.3f over the ground, on a floor %s" % [body, way, spot, feet.y, player.is_on_floor()]
				var ok := player.is_on_floor() and absf(feet.x) < 0.2 and absf(feet.z - z) < 0.2
				for level: String in drawn:
					var gap := _distance(drawn[level] as PackedVector3Array, centre) - radius
					line += ", %.3f m from the %s level" % [gap, level]
					ok = ok and absf(gap) <= STANCE_TOLERANCE_M
				print(line)
				if not ok:
					_failures.append(line)
			car.free()
	player.free()
	stage.free()
	if _failures.is_empty():
		print("PASS car stance: the stock player rests on the drawn hood, roof and trunk or bed of every body, parked and driven")
		quit(0)
	else:
		for failure in _failures:
			print("FAIL %s" % failure)
		quit(1)


## A car at the origin facing -Z: parked (a static body with the kit's pieces)
## or driven (the drivable car itself, frozen as when it is left parked).
func _car(way: String, body: String, kit: KIT, parts: Dictionary) -> Node3D:
	if way == "parked":
		var built := kit.parts("parked_car", {"body": body, "paint": "white", "finish": "solid"})
		var parked := StaticBody3D.new()
		parked.collision_layer = PHYSICS_STREET_PROP
		parked.collision_mask = 0
		for piece: Dictionary in built.shapes:
			var shape := CollisionShape3D.new()
			shape.shape = piece.shape
			shape.transform = piece.transform
			parked.add_child(shape)
		return parked
	var custom: Dictionary = KIT.car_custom({"body": body, "paint": "white", "finish": "solid"})
	var car := DRIVABLE_CAR.new()
	var none: Array[RID] = []
	car.setup(body, parts, kit.material(), custom.custom, Transform3D.IDENTITY, none)
	car.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	car.freeze = true
	return car


## A mesh's triangles, three points each.
func _faces(mesh: Mesh) -> PackedVector3Array:
	return mesh.get_faces()


## The highest drawn surface under a point (a ray straight down).
func _height(faces: PackedVector3Array, from: Vector3) -> float:
	var best := -INF
	for i in range(0, faces.size(), 3):
		var hit: Variant = Geometry3D.ray_intersects_triangle(from, Vector3.DOWN, faces[i], faces[i + 1], faces[i + 2])
		if hit is Vector3:
			best = maxf(best, (hit as Vector3).y)
	return best


## The distance from a point to the nearest drawn triangle.
func _distance(faces: PackedVector3Array, p: Vector3) -> float:
	var best := INF
	for i in range(0, faces.size(), 3):
		var a := faces[i]
		if absf(a.x - p.x) > 1.0 or absf(a.z - p.z) > 1.0:
			continue
		best = minf(best, p.distance_to(_closest_on_triangle(p, a, faces[i + 1], faces[i + 2])))
	return best


## The point of triangle abc nearest p (Ericson, Real-Time Collision Detection 5.1.5).
static func _closest_on_triangle(p: Vector3, a: Vector3, b: Vector3, c: Vector3) -> Vector3:
	var ab := b - a
	var ac := c - a
	var ap := p - a
	var d1 := ab.dot(ap)
	var d2 := ac.dot(ap)
	if d1 <= 0.0 and d2 <= 0.0:
		return a
	var bp := p - b
	var d3 := ab.dot(bp)
	var d4 := ac.dot(bp)
	if d3 >= 0.0 and d4 <= d3:
		return b
	var vc := d1 * d4 - d3 * d2
	if vc <= 0.0 and d1 >= 0.0 and d3 <= 0.0:
		return a + ab * (d1 / (d1 - d3))
	var cp := p - c
	var d5 := ab.dot(cp)
	var d6 := ac.dot(cp)
	if d6 >= 0.0 and d5 <= d6:
		return c
	var vb := d5 * d2 - d1 * d6
	if vb <= 0.0 and d2 >= 0.0 and d6 <= 0.0:
		return a + ac * (d2 / (d2 - d6))
	var va := d3 * d6 - d5 * d4
	if va <= 0.0 and d4 - d3 >= 0.0 and d5 - d6 >= 0.0:
		return b + (c - b) * ((d4 - d3) / ((d4 - d3) + (d5 - d6)))
	var denom := 1.0 / (va + vb + vc)
	return a + ab * (vb * denom) + ac * (vc * denom)
