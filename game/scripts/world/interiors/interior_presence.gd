class_name InteriorPresence
extends Node
## Whether the camera is in an enterable interior, as one eased blend that anything
## changing as the player goes in or out can read (Building 1's floor reflections,
## building_1_hall_reflections.gd, are the first). It hangs under the interior's root,
## the node its builder marks interior_of_source_key, and takes the interior's plan from
## that root's PLAN_META meta:
##   {"kind": "ring_sector", "centre": Vector2(x, z), "radii": Vector2(inner, outer),
##    "angles": Vector2(from, to), "top_y": float}
## an annular sector about a centre (Building 1's crescent), from its inner to its outer
## radius, from the first angle round to the second (atan2 of z over x from the centre,
## either side of the -PI/PI seam or across it; less than a whole turn), below top_y; the
## one kind there is so far (KINDS).
##
## Each frame it reads the current camera's position. The camera is in once it stands
## HYSTERESIS_M inside the plan's bounds, and out again only once it stands as far
## outside them: two lines, so a camera on a doorway does not go in and out frame by
## frame. A progress follows, toward 1 while in and 0 while out, at 1 / fade_s a second
## (a frame counts for at most MAX_STEP_S, so one long frame at the door cannot finish a
## fade), turning round wherever it is when the camera turns back; blend() is that
## progress eased (smoothstep). The signals mark each turn and each end: entering_started and
## leaving_started when the camera goes in or out, fully_inside and fully_outside when
## the progress gets to 1 or 0.
##
## It needs no renderer, physics or scene search, so it runs the same on every renderer
## and headless. Each interior has its own; a frame costs one squared distance from the
## camera to the plan's centre, and while that is beyond the plan's outer radius (and
## the lines) with the progress at 0 nothing else runs (full_tests counts the frames the
## whole test ran). Leaving the tree, it is out at once (fully_outside, if it was not).

signal entering_started
signal fully_inside
signal leaving_started
signal fully_outside

## The meta on the interior's root that holds its plan.
const PLAN_META := "interior_plan"
const KINDS: Array[String] = ["ring_sector"]
## The camera is in this far (m) inside the plan's bounds, out this far outside them.
const HYSTERESIS_M := 0.4
## The most of a frame (s) the progress counts: a longer frame moves it no further.
const MAX_STEP_S := 0.1

## How long (s) the blend takes from one end to the other.
@export var fade_s := 0.5

## How many times the camera has gone in or out.
var switches := 0
## How many frames ran the whole test (the rest stopped at the outer circle).
var full_tests := 0
var _ready_plan := false
var _inside := false
var _progress := 0.0
var _centre := Vector2.ZERO
var _radii := Vector2.ZERO
## The angle halfway round the plan's turn, and half that turn.
var _middle := 0.0
var _half := 0.0
var _top := 0.0
## The squared distance from the centre beyond which the camera cannot be in.
var _reach := 0.0


func _ready() -> void:
	var plan: Variant = get_parent().get_meta(PLAN_META, null) if get_parent() != null else null
	var problem := plan_problem(plan)
	if problem != "":
		push_error("InteriorPresence under %s: %s" % [get_parent().name if get_parent() != null else "nothing", problem])
		set_process(false)
		return
	_centre = plan.centre
	_radii = plan.radii
	_middle = (plan.angles.x + plan.angles.y) * 0.5
	_half = (plan.angles.y - plan.angles.x) * 0.5
	_top = float(plan.top_y)
	_reach = (_radii.y + HYSTERESIS_M) * (_radii.y + HYSTERESIS_M)
	_ready_plan = true


## Why a plan cannot be used, or "" if it can.
static func plan_problem(plan: Variant) -> String:
	if not plan is Dictionary:
		return "no %s meta on the interior's root" % PLAN_META
	if not str(plan.get("kind", "")) in KINDS:
		return "a plan of kind \"%s\"; known: %s" % [plan.get("kind", ""), ", ".join(PackedStringArray(KINDS))]
	if not plan.get("centre") is Vector2 or not plan.get("radii") is Vector2 or not plan.get("angles") is Vector2 or not (plan.get("top_y") is float or plan.get("top_y") is int):
		return "a ring_sector plan needs centre, radii and angles (Vector2) and top_y"
	var radii: Vector2 = plan.radii
	var angles: Vector2 = plan.angles
	if radii.x < 0.0 or radii.y <= radii.x:
		return "a ring_sector plan's radii must run from less to more"
	if angles.y <= angles.x or angles.y - angles.x >= TAU:
		return "a ring_sector plan's angles must run from less to more, less than a whole turn"
	return ""


func _process(delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var at := camera.global_position
	if not _inside and _progress == 0.0 and Vector2(at.x, at.z).distance_squared_to(_centre) > _reach:
		return
	full_tests += 1
	var now := contains(at, -HYSTERESIS_M if _inside else HYSTERESIS_M)
	if now != _inside:
		_inside = now
		switches += 1
		if now:
			entering_started.emit()
		else:
			leaving_started.emit()
	var goal := 1.0 if _inside else 0.0
	if _progress != goal:
		_progress = move_toward(_progress, goal, minf(delta, MAX_STEP_S) / maxf(fade_s, 0.001))
		if _progress == goal:
			if _inside:
				fully_inside.emit()
			else:
				fully_outside.emit()


func _exit_tree() -> void:
	var was := _inside or _progress > 0.0
	_inside = false
	_progress = 0.0
	if was:
		fully_outside.emit()


## Whether the camera is in now (the blend is on its way to 1, or there).
func is_inside() -> bool:
	return _inside


## How far in, 0 to 1, eased: smoothstep of the progress.
func blend() -> float:
	return _progress * _progress * (3.0 - 2.0 * _progress)


## The progress itself, 0 to 1, at 1 / fade_s a second.
func progress() -> float:
	return _progress


## Whether a point is in the plan, margin metres inside its bounds (outside them, for a
## negative margin): between the radii, within the plan's turn (the margin as an arc at
## the point's radius; the angle is taken from the turn's middle and wrapped, so a plan
## either side of the -PI/PI seam or across it holds the same) and below the top.
func contains(at: Vector3, margin := 0.0) -> bool:
	return _ready_plan and _sector_contains(_centre, _radii, _middle, _half, _top, at, margin)


## contains() for a plan that plan_problem() accepts, without a node (the far stand-in's
## switch asks it: InteriorFarStandIn).
static func plan_contains(plan: Dictionary, at: Vector3, margin := 0.0) -> bool:
	var angles: Vector2 = plan.angles
	return _sector_contains(plan.centre, plan.radii, (angles.x + angles.y) * 0.5, (angles.y - angles.x) * 0.5, float(plan.top_y), at, margin)


static func _sector_contains(centre: Vector2, radii: Vector2, middle: float, half: float, top: float, at: Vector3, margin: float) -> bool:
	var offset := Vector2(at.x - centre.x, at.z - centre.y)
	var r := offset.length()
	var off := absf(wrapf(atan2(offset.y, offset.x) - middle, -PI, PI))
	var turn := margin / maxf(r, 1.0)
	return r > radii.x + margin and r < radii.y - margin and off < half - turn and at.y < top - margin
