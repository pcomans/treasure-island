class_name GameStats
extends Node
## What the game is doing, for the anonymous statistics (owner, 2026-11-17: how many
## people play, on what systems, when it crashes, how it performs, where on the island
## they spend their time, how long they play; "After 1 minute, then every 5"). This is
## the one definition of every field, band and bucket edge that the web page
## (game/web/shell.html's tiReporting, through CrashReports) and the desktop builds'
## reports send, so both say the same thing the same way:
##   - snapshot(): the game's state now, in bands and coarse values, never an exact
##     position, free text or anything that identifies a person. Refreshed once a second
##     of play and handed on (snapshot_changed); the page attaches the latest to every
##     report and keeps it with its record of the visit, so the report of a visit that
##     ended unexpectedly carries the last one it had.
##   - The timed stats (stats_due): one after STATS_FIRST_S seconds of play, then one every
##     STATS_EVERY_S, counting play time only: never while the game is paused, at the
##     start prompt or, on the web, hidden (main pauses it then). Each carries the
##     snapshot, the whole minutes played so far, the window's frame rate second by second
##     as its median, 5th percentile and worst second, the seconds spent in each map cell
##     (the TOP_AREAS cells with the most, the rest together as "other": a histogram with
##     no order and no times, never a trail), the seconds on foot, with the jetpack and in
##     a car, and the graphics settings changed during the window. There is no message at
##     the end of a visit.
##   - FUNNEL_STEPS, the loading funnel's step names, and the anonymous id's rule
##     (anonymous_id), which the web page applies in its own code before the engine runs
##     (tools/check_web_reporting.mjs checks that it uses these names and sizes).
## Main adds it once the world is ready, where the statistics have somewhere to go (on the
## web, a page that sends them). It runs only while play does (pausable), and does a few
## additions a frame and the snapshot once a second.

## The snapshot's and the stats' contents, as sent.
signal snapshot_changed(snapshot: Dictionary)
signal stats_due(stats: Dictionary)

## The map's cells: AREA_CELL_M square, named "column,row" from the island's origin
## (x east, z south, in metres: the cell "-2,7" spans x -200 to -100 and z 700 to 800).
const AREA_CELL_M := 100.0
## Bands, each the range between two edges ("<5", "5-20", ..., "150+"): the height above
## sea level of the player or their car (m), its speed (m/s), the frame rate over the last
## RECENT_FPS_S seconds of play, and the minutes since the game started.
const HEIGHT_EDGES := [5.0, 20.0, 50.0, 150.0]
const SPEED_EDGES := [0.5, 4.0, 10.0, 25.0]
const FPS_EDGES := [10.0, 20.0, 30.0, 45.0, 55.0]
const SESSION_EDGES_MIN := [1.0, 5.0, 15.0, 30.0, 60.0]
const RECENT_FPS_S := 5
## How the player moves: on foot (on the ground), with the jetpack (in the air, rising or
## floating down) or in a car.
const MOVEMENTS := ["on_foot", "jetpack", "in_car"]
## The screen's class by its shorter side in logical pixels: small below the first edge
## (a phone), medium below the second (a tablet, a small window), else large.
const SCREEN_EDGES := [500.0, 900.0]
const SCREEN_CLASSES := ["small", "medium", "large"]
## The timed stats: the first after this much play, then one every STATS_EVERY_S.
const STATS_FIRST_S := 60.0
const STATS_EVERY_S := 300.0
## The cells a stats message names; the rest go under "other".
const TOP_AREAS := 8
## Graphics changes a stats message lists at most.
const MAX_CHANGES := 10
## A frame longer than this is not play (a stall of the page while hidden, say).
const MAX_FRAME_S := 2.0
## The loading funnel, in order: the page opened (with the statistics allowed), its files
## downloaded, the start prompt up, play started (its tap or click), and play still going
## after STATS_FIRST_S (the first timed stats).
const FUNNEL_STEPS := ["page_opened", "download_finished", "start_prompt", "play_started", "playing_1min"]
## The anonymous id (owner, 2026-11-17: "Let's just switch to permanent IDs ... People can
## just turn off analytics if they don't like it"): ANONYMOUS_ID_BYTES random bytes, as
## hex, made the first time the statistics are sent and kept with the reporting state (on
## the web, the browser's storage for the site) until the player turns the statistics off,
## which deletes it (turning them on again makes a new one), or clears the site's data.
## Never derived from anything about the device or the player; sent only in the reports,
## as their user id, so Sentry counts players and returning players.
const ANONYMOUS_ID_BYTES := 16

## The game whose state this reads.
var main: GameMain
## When the game started (Time.get_ticks_msec), for the minutes in the session.
var started_msec := 0
## The graphics adapter's name as the platform gives it, coarsened (coarse_gpu).
var gpu := "unknown"
## The clock, in microseconds (a test gives its own).
var now_usec := func() -> int: return Time.get_ticks_usec()

var _snapshot := {}
var _graphics := {}
var _last_usec := 0
var _second_s := 0.0
var _frames := 0
## The frame rate of each of the last RECENT_FPS_S seconds of play.
var _recent: Array[float] = []
## Play time since play started, and when the next stats are due.
var _play_s := 0.0
var _next_stats_s := STATS_FIRST_S
var _stats_sent := 0
## This window's play time, frame rate of each second, seconds per cell and per movement,
## and graphics changes.
var _window_s := 0.0
var _rates := PackedFloat32Array()
var _areas := {}
var _movements := {}
var _changes: Array[Dictionary] = []


func _init(game: GameMain = null, game_started_msec := 0, adapter := "") -> void:
	main = game
	started_msec = game_started_msec
	gpu = coarse_gpu(adapter)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_last_usec = now_usec.call()
	refresh()


func _notification(what: int) -> void:
	# A pause (the pause menu, a hidden page, a lost focus) is not play time.
	if what == NOTIFICATION_UNPAUSED:
		_last_usec = now_usec.call()


func _process(_delta: float) -> void:
	var now: int = now_usec.call()
	var frame_s := (now - _last_usec) / 1000000.0
	_last_usec = now
	if frame_s <= 0.0 or frame_s > MAX_FRAME_S:
		return
	_play_s += frame_s
	_window_s += frame_s
	_second_s += frame_s
	_frames += 1
	var cell := str(_snapshot.get("area", ""))
	_areas[cell] = float(_areas.get(cell, 0.0)) + frame_s
	var movement := str(_snapshot.get("movement", ""))
	_movements[movement] = float(_movements.get(movement, 0.0)) + frame_s
	if _second_s >= 1.0:
		var rate := _frames / _second_s
		_rates.append(rate)
		_recent.append(rate)
		if _recent.size() > RECENT_FPS_S:
			_recent.pop_front()
		_frames = 0
		_second_s = 0.0
		refresh()
	if _play_s >= _next_stats_s:
		stats_due.emit(take_stats())
		_next_stats_s += STATS_EVERY_S


## Takes the snapshot now, notes any graphics setting changed since the last, and hands
## it on.
func refresh() -> void:
	_snapshot = snapshot()
	var graphics := {}
	for key: String in ["resolution", "shadows", "frame_rate_limit"]:
		graphics[key] = _snapshot[key]
	for key: String in graphics:
		if not _graphics.is_empty() and graphics[key] != _graphics[key] and _changes.size() < MAX_CHANGES:
			_changes.append({"setting": key, "from": _graphics[key], "to": graphics[key]})
	_graphics = graphics
	snapshot_changed.emit(_snapshot.duplicate())


## The game's state now (the fields above).
func snapshot() -> Dictionary:
	var player := main.player
	var car: DrivableCar = main.vehicles.active_car() if main.vehicles != null and main.vehicles.is_driving() else null
	var at := car.global_position if car != null else player.global_position
	var velocity := car.linear_velocity if car != null else player.velocity
	var recent := Engine.get_frames_per_second()
	if not _recent.is_empty():
		recent = 0.0
		for rate: float in _recent:
			recent += rate
		recent /= _recent.size()
	var screen := Vector2(DisplayServer.screen_get_size()) / maxf(DisplayServer.screen_get_scale(), 0.01)
	return {
		"area": area_of(at),
		"movement": "in_car" if car != null else ("on_foot" if player.is_on_floor() else "jetpack"),
		"height_m": band(at.y, HEIGHT_EDGES),
		"speed_m_s": band(velocity.length(), SPEED_EDGES),
		"fps": band(recent, FPS_EDGES),
		"session_min": band((Time.get_ticks_msec() - started_msec) / 60000.0, SESSION_EDGES_MIN),
		"resolution": str(main.graphics.current.get(GraphicsSettings.RESOLUTION_KEY, "")),
		"shadows": str(main.shadows.current),
		"frame_rate_limit": str(main.graphics.current.get(GraphicsSettings.FRAME_RATE_KEY, "")),
		"gpu": gpu,
		"screen": screen_class(screen),
		"input": "touch" if main.has_touch_controls() else "keyboard_mouse",
		"video_mb": _megabytes(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED),
		"texture_mb": _megabytes(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED),
		"buffer_mb": _megabytes(RenderingServer.RENDERING_INFO_BUFFER_MEM_USED),
	}


## The stats of the window now ending, and a new window started.
func take_stats() -> Dictionary:
	var rates := Array(_rates)
	rates.sort()
	var count := rates.size()
	var cells := _areas.keys()
	cells.sort_custom(func(a: String, b: String) -> bool: return _areas[a] > _areas[b])
	var areas := {}
	var other := 0.0
	for index in cells.size():
		if index < TOP_AREAS:
			areas[cells[index]] = roundi(_areas[cells[index]])
		else:
			other += _areas[cells[index]]
	if other > 0.0:
		areas["other"] = roundi(other)
	var movements := {}
	for movement: String in MOVEMENTS:
		movements[movement] = roundi(float(_movements.get(movement, 0.0)))
	var stats := {
		"first": _stats_sent == 0,
		"play_min": floori(_play_s / 60.0),
		"window_s": roundi(_window_s),
		"fps_median": snappedf(_percentile(rates, 0.5), 0.1) if count > 0 else 0.0,
		"fps_p05": snappedf(_percentile(rates, 0.05), 0.1) if count > 0 else 0.0,
		"fps_worst": snappedf(rates[0], 0.1) if count > 0 else 0.0,
		"areas_s": areas,
		"movement_s": movements,
		"graphics_changes": _changes.duplicate(true),
		"snapshot": _snapshot.duplicate(),
	}
	_stats_sent += 1
	_window_s = 0.0
	_rates = PackedFloat32Array()
	_areas = {}
	_movements = {}
	_changes = []
	return stats


## The band VALUE falls in between EDGES: "<first", "a-b", ..., "last+".
static func band(value: float, edges: Array) -> String:
	if value < float(edges[0]):
		return "<%s" % _number(edges[0])
	for index in range(1, edges.size()):
		if value < float(edges[index]):
			return "%s-%s" % [_number(edges[index - 1]), _number(edges[index])]
	return "%s+" % _number(edges.back())


## The map cell a position is in ("column,row", AREA_CELL_M square).
static func area_of(position: Vector3) -> String:
	return "%d,%d" % [floori(position.x / AREA_CELL_M), floori(position.z / AREA_CELL_M)]


## The screen's class from its logical size.
static func screen_class(size: Vector2) -> String:
	var shorter := minf(size.x, size.y)
	for index in SCREEN_EDGES.size():
		if shorter < float(SCREEN_EDGES[index]):
			return SCREEN_CLASSES[index]
	return SCREEN_CLASSES.back()


## A graphics adapter's name as a model, without what tells one machine from another of
## the same kind: ANGLE's wrapping (its vendor and backend), device and revision ids in
## brackets, driver and API versions. "ANGLE (NVIDIA, NVIDIA GeForce RTX 3080
## (0x00002206) Direct3D11 vs_5_0 ps_5_0, D3D11)" becomes "NVIDIA GeForce RTX 3080",
## "ANGLE (Apple, ANGLE Metal Renderer: Apple M1 Pro, Unspecified Version)" "Apple M1
## Pro", "AMD Radeon 780M (radeonsi, gfx1103_r1, LLVM 19.1.1, DRM 3.59, 6.12.0)" "AMD
## Radeon 780M". At most 60 characters; "unknown" for nothing.
static func coarse_gpu(adapter: String) -> String:
	var text := adapter.strip_edges()
	var angle := RegEx.create_from_string("^ANGLE \\([^,]*,\\s*(.*),[^,]*\\)$").search(text)
	if angle != null:
		text = angle.get_string(1)
	text = text.replace("ANGLE Metal Renderer:", "")
	text = RegEx.create_from_string("\\([^()]*\\)").sub(text, "", true)
	text = RegEx.create_from_string("(?i)\\b(Direct3D\\S*|D3D\\S*|vs_\\S+|ps_\\S+|OpenGL( ES)?\\S*|Vulkan\\S*|Unspecified Version)").sub(text, "", true)
	text = RegEx.create_from_string("\\s+").sub(text, " ", true).strip_edges(true, true).trim_suffix(",").strip_edges()
	return text.left(60) if not text.is_empty() else "unknown"


## The anonymous id to use: KEPT when it is one (ANONYMOUS_ID_BYTES bytes as lowercase
## hex), else new random bytes for the caller to keep. For the desktop builds; the web
## page applies the same rule in its own code.
static func anonymous_id(kept: String) -> String:
	if kept.length() == ANONYMOUS_ID_BYTES * 2 and kept == kept.to_lower() and kept.is_valid_hex_number():
		return kept
	return Crypto.new().generate_random_bytes(ANONYMOUS_ID_BYTES).hex_encode()


static func _number(value: float) -> String:
	return str(int(value)) if is_equal_approx(value, roundf(value)) else str(value)


## The value at SHARE of a sorted list, between neighbours.
static func _percentile(sorted: Array, share: float) -> float:
	var at := share * (sorted.size() - 1)
	var below := floori(at)
	var above := mini(below + 1, sorted.size() - 1)
	return lerpf(float(sorted[below]), float(sorted[above]), at - below)


static func _megabytes(info: RenderingServer.RenderingInfo) -> int:
	return roundi(RenderingServer.get_rendering_info(info) / 1048576.0)
