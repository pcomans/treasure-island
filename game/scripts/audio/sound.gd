class_name Sound
extends Node
## The game's sound (owner, 2026-11-14): the sound effects of
## game/resources/audio/sounds.json, played from the takes tools/fetch-sfx copies
## into game/resources/audio/sfx/. main.gd makes one at startup; the gameplay code
## asks it for sounds through the static calls (play, play_after, hold), which do
## nothing when there is none, as in a test that builds a part on its own.
##
## The takes: the folder's manifest, sfx.json (tools/sfx/README.md "Levels"),
## lists each sound's takes, whether they loop, and its playback gain (gain_db:
## read in _read_manifest alone; 0 dB where the manifest gives none). A sound with
## no takes is silent: a checkout or build without the audio, which never goes in
## Git (tools/sfx/README.md), plays nothing and reports no error. Everything is
## loaded as the game starts, never at a sound's first use; on the web each take
## is also handed to the browser then (AudioServer.register_stream_as_sample), so
## its first play does not decode it.
##
## Levels: a play's gain is the sound's gain_db, the level plan's (frequent and
## constant sounds are planned low there, so nothing here lifts them), and the
## game's modulation only lowers it: what the code asks (strength 0..1: an
## impact's force, a fall's speed), a little random jitter downward, and the
## distance (a positional sound never plays above its gain however close). The
## buses (bus_layout.tres: SFX, Ambience and UI, each into Master) and the
## player's master volume and mute (Options, 0 dB at most; kept with the other
## settings in ShadowQuality.settings_path, section audio) sit above all of it.
## On the desktop a hard limiter on Master keeps a pile of crashes from clipping;
## the web's browser playback has no bus effects, so it has none there.
##
## One-shots (play): a random take, never the last one twice running, with its
## pitch and gain jittered a little; at most the catalog's voices of a sound at
## once (a new one takes the oldest one's voice) and none sooner than its
## min_gap_s after the last that played, so a pile-up, a run of fence bays or a
## dribbled ball cannot flood the mix; a positional one farther than its max_m
## from the listener is not played. The players are made here, ahead of time, in
## fixed pools: positional ones and the beds pause with the game (World), the
## menus' clicks do not (Interface).
##
## Loops (hold): the code that owns a loop holds it at a level (0..1) each
## physics tick, with its pitch and position (the jet's flame, the driven car's
## engine and tyres); the loop starts when the level rises, follows it, fades when
## it falls and stops a moment after it is silent, or when its owner stops holding
## it or is gone. A loop starts at a random point of its take.
##
## Beds: the wind (louder with height) and the bay's water (by the listener's
## distance to the island's outline, worked out four times a second), from the
## moment play starts (start_beds), fading in.
##
## The listener is Godot's own: the camera showing. Getting in and out of a car
## and the watch from the shore are blends between cameras (vehicle_camera.gd),
## so the listener moves smoothly with the picture; R and the return from the
## water move the car and the camera together, so the engine keeps its level.
##
## Every request is kept in `requests` (the last REQUEST_LOG_SIZE) with what came
## of it: played, silent (no takes), limited (min_gap_s), far, quiet (no
## strength), unknown, or a loop's loop_start, loop_silent and loop_stop. Tests
## read it; nothing in the game does.

const CATALOG_PATH := "res://game/resources/audio/sounds.json"
const DEFAULT_MANIFEST_PATH := "res://game/resources/audio/sfx/sfx.json"
## The hard limiter on Master (desktop): its ceiling (dB).
const LIMITER_CEILING_DB := -0.3
## The player's master volume (0..1) and mute, in the settings file.
const SETTINGS_SECTION := "audio"
const VOLUME_KEY := "volume"
const MUTED_KEY := "muted"
const DEFAULT_VOLUME := 1.0
## The fixed pools of one-shot players.
const WORLD_3D_VOICES := 24
const WORLD_2D_VOICES := 4
const UI_VOICES := 4
const REQUEST_LOG_SIZE := 1024
## A held loop no longer held for this long (game seconds) fades out; its level
## follows a rise in LOOP_ATTACK_S and a fall in LOOP_RELEASE_S, and it stops once
## it has been silent for LOOP_STOP_AFTER_S.
const HOLD_TIMEOUT_S := 0.25
const LOOP_ATTACK_S := 0.03
const LOOP_RELEASE_S := 0.08
const LOOP_STOP_AFTER_S := 0.3
const SILENT_LEVEL := 0.001
## The beds: how long they take to fade in when play starts, how often their
## levels are worked out (the outline's distance walks every vertex of it, as the
## cars' shore check does every 0.25 s) and how fast they follow.
const BED_FADE_IN_S := 2.5
const BED_UPDATE_S := 0.25
const BED_FOLLOW_S := 0.6
const WIND_BED := &"wind_bed"
const WATER_BED := &"bay_water_bed"

## The manifest the bank reads; a test points it at one of its own first.
static var manifest_path := DEFAULT_MANIFEST_PATH
## The sound manager playing now, or null.
static var current: Sound

## Every request, newest last (see above).
var requests: Array[Dictionary] = []
## The master volume and mute on now.
var volume := DEFAULT_VOLUME
var muted := false

var _catalog: Dictionary = {}
var _takes: Dictionary = {}
var _levels: Dictionary = {}
var _last_take: Dictionary = {}
var _last_played: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _world: Node3D
var _interface: Node
var _pools: Dictionary = {}
var _loops: Dictionary = {}
var _pending: Array[Dictionary] = []
## Game time (s): stops with the pause, as the world's sounds do.
var _game_s := 0.0
var _beds_from := -1.0
var _boundary: WorldBoundary
var _bed_clock := 0.0
var _bed_targets := {WIND_BED: 0.0, WATER_BED: 0.0}
var _bed_levels := {WIND_BED: 0.0, WATER_BED: 0.0}
var _registered := false


class LoopVoice:
	extends RefCounted
	var id: StringName
	var player: Node
	var holder: WeakRef
	var target := 0.0
	var level := 0.0
	var pitch := 1.0
	var at := Vector3.INF
	var held_s := 0.0
	var quiet_s := 0.0
	var started := false


func _init() -> void:
	name = "Sound"
	# The menus' clicks play in the pause; the world's sounds pause (World).
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_world = Node3D.new()
	_world.name = "World"
	_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_world)
	_interface = Node.new()
	_interface.name = "Interface"
	_interface.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_interface)
	_pools = {"3d": _make_pool(_world, WORLD_3D_VOICES, true), "2d": _make_pool(_world, WORLD_2D_VOICES, false), "ui": _make_pool(_interface, UI_VOICES, false)}
	_catalog = load_catalog()
	_read_manifest()
	_limit_master()


## A hard limiter on Master, once (desktop; the web's browser playback runs no bus
## effects).
static func _limit_master() -> void:
	if OS.has_feature("web"):
		return
	var master := AudioServer.get_bus_index(&"Master")
	for index in AudioServer.get_bus_effect_count(master):
		if AudioServer.get_bus_effect(master, index) is AudioEffectHardLimiter:
			return
	var limiter := AudioEffectHardLimiter.new()
	limiter.ceiling_db = LIMITER_CEILING_DB
	AudioServer.add_bus_effect(master, limiter)


func _enter_tree() -> void:
	current = self


func _exit_tree() -> void:
	if current == self:
		current = null


# --- What the gameplay code calls.

## Plays a one-shot of sound id: at a world position when it is positional, its
## gain times strength (1 as the take is, 0.5 about 6 dB down) and its pitch times
## pitch.
static func play(id: StringName, at: Vector3 = Vector3.INF, strength: float = 1.0, pitch: float = 1.0) -> void:
	if current != null:
		current.request(id, at, strength, pitch)


## Plays a one-shot delay_s of game time from now, where follow is then (or where
## it was, if it is gone).
static func play_after(delay_s: float, id: StringName, follow: Node3D, strength: float = 1.0, pitch: float = 1.0) -> void:
	if current != null:
		current.schedule(delay_s, id, follow, strength, pitch)


## Holds the loop id of holder at level (0 silent, 1 as the take is) this tick,
## at a world position when it is positional, at pitch.
static func hold(id: StringName, holder: Object, level: float, at: Vector3 = Vector3.INF, pitch: float = 1.0) -> void:
	if current != null:
		current.hold_loop(id, holder, level, at, pitch)


## Lets holder's loop id fade out now.
static func release(id: StringName, holder: Object) -> void:
	if current != null:
		current.release_loop(id, holder)


## Whether sound id has takes to play.
static func has_takes(id: StringName) -> bool:
	return current != null and current.takes_of(id) > 0


# --- The catalog and the takes.

## The catalog's sounds: id -> settings.
static func load_catalog() -> Dictionary:
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
	var sounds: Variant = (data as Dictionary).get("sounds") if data is Dictionary else null
	if not sounds is Dictionary:
		push_error("Sound: %s has no sounds" % CATALOG_PATH)
		return {}
	var catalog := {}
	for id: String in sounds:
		catalog[StringName(id)] = sounds[id]
	return catalog


## Reads the manifest's takes, loops and gains for the catalog's sounds (the one
## place that reads a sound's gain: tools/sfx/README.md "Levels", gain_db); a
## missing manifest, sound or take is silence.
func _read_manifest() -> void:
	_takes.clear()
	_levels.clear()
	var text := FileAccess.get_file_as_string(manifest_path) if FileAccess.file_exists(manifest_path) else ""
	var data: Variant = JSON.parse_string(text) if not text.is_empty() else null
	var sounds: Dictionary = {}
	if data is Dictionary and (data as Dictionary).get("sounds") is Dictionary:
		sounds = (data as Dictionary).sounds
	elif not text.is_empty():
		push_warning("Sound: %s does not read as a sound manifest; the game is silent" % manifest_path)
	var folder := manifest_path.get_base_dir()
	for id: StringName in _catalog:
		var entry: Dictionary = sounds.get(String(id), {}) if sounds.get(String(id)) is Dictionary else {}
		var gain: Variant = entry.get("gain_db")
		_levels[id] = float(gain) if (gain is float or gain is int) and is_finite(float(gain)) else 0.0
		var loop := bool(entry.get("loop", (_catalog[id] as Dictionary).get("loop", false)))
		var takes: Array[AudioStream] = []
		var listed: Array = entry.get("takes") if entry.get("takes") is Array else []
		for take: Variant in listed:
			var path := folder.path_join(str(take))
			if not str(take).is_valid_filename() or not ResourceLoader.exists(path):
				continue
			var stream := load(path) as AudioStream
			if stream == null:
				continue
			if loop:
				_make_loop(stream)
			takes.append(stream)
		_takes[id] = takes


## A take that loops, whatever its kind.
static func _make_loop(stream: AudioStream) -> void:
	if stream is AudioStreamWAV:
		var wav := stream as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.get_length() * wav.mix_rate)
	elif "loop" in stream:
		stream.set("loop", true)


## On the web the browser plays the takes (Godot's sample playback): each is
## handed to it now, under the loading screen, rather than at its first play.
func prepare_for_play() -> void:
	if _registered or not OS.has_feature("web"):
		return
	_registered = true
	for id: StringName in _takes:
		for stream: AudioStream in _takes[id]:
			if not AudioServer.is_stream_registered_as_sample(stream):
				AudioServer.register_stream_as_sample(stream)


func takes_of(id: StringName) -> int:
	return (_takes.get(id, []) as Array).size()


## A sound's playback gain from the manifest (dB; 0 where it gives none).
func level_db(id: StringName) -> float:
	return float(_levels.get(id, 0.0))


# --- One-shots.

func request(id: StringName, at: Vector3, strength: float, pitch: float) -> Dictionary:
	var entry := {"id": id, "at": at, "strength": strength}
	var settings: Dictionary = _catalog.get(id, {})
	if settings.is_empty() or bool(settings.get("loop", false)):
		push_error("Sound: %s is not a one-shot in %s" % [id, CATALOG_PATH])
		return _log(entry, "unknown")
	var now := _clock(settings)
	entry["time"] = now
	entry["level_db"] = level_db(id)
	if now - float(_last_played.get(id, -INF)) < float(settings.get("min_gap_s", 0.0)):
		return _log(entry, "limited")
	var takes: Array = _takes.get(id, [])
	if takes.is_empty():
		return _log(entry, "silent")
	if strength <= 0.0:
		return _log(entry, "quiet")
	var positional := str(settings.get("space", "3d")) == "3d"
	if positional and at.is_finite() and _listener_distance(at) > float(settings.get("max_m", INF)):
		return _log(entry, "far")
	var pool: Array = _pools["3d" if positional else ("ui" if str(settings.get("bus", "")) == "UI" else "2d")]
	var player := _voice(pool, id, int(settings.get("voices", 2)))
	var take := _pick(id, takes.size())
	# The modulation only lowers the sound's gain: strength at most 1, jitter down.
	var jitter := float(settings.get("gain_jitter_db", 0.0))
	var gain_db := linear_to_db(minf(strength, 1.0))
	var volume_db := level_db(id) + gain_db - _rng.randf_range(0.0, jitter)
	var pitch_jitter := float(settings.get("pitch_jitter", 0.0))
	var pitch_scale := maxf(0.05, pitch * (1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)))
	player.stop()
	player.set("stream", takes[take])
	player.set("bus", StringName(str(settings.get("bus", "SFX"))))
	player.set("volume_db", volume_db)
	player.set("pitch_scale", pitch_scale)
	if player is AudioStreamPlayer3D:
		var spatial := player as AudioStreamPlayer3D
		spatial.unit_size = float(settings.get("unit_m", 10.0))
		spatial.max_distance = float(settings.get("max_m", 0.0))
		spatial.global_position = at if at.is_finite() else _listener_position()
	player.set_meta("sound_id", id)
	player.set_meta("started", now)
	player.call("play")
	_last_played[id] = now
	entry.merge({"gain_db": gain_db, "volume_db": volume_db, "pitch": pitch_scale, "take": take})
	return _log(entry, "played")


func schedule(delay_s: float, id: StringName, follow: Node3D, strength: float, pitch: float) -> void:
	var at := follow.global_position if is_instance_valid(follow) and follow.is_inside_tree() else Vector3.INF
	_pending.append({"due": _game_s + delay_s, "id": id, "follow": weakref(follow), "at": at, "strength": strength, "pitch": pitch})


## The voice for a new play of id: the oldest of its own when it has its cap,
## else a free one, else the oldest playing.
func _voice(pool: Array, id: StringName, cap: int) -> Node:
	var free: Node = null
	var oldest_own: Node = null
	var oldest: Node = null
	var own := 0
	for player: Node in pool:
		if not bool(player.get("playing")):
			if free == null:
				free = player
			continue
		var started := float(player.get_meta("started", 0.0))
		if StringName(player.get_meta("sound_id", &"")) == id:
			own += 1
			if oldest_own == null or started < float(oldest_own.get_meta("started", 0.0)):
				oldest_own = player
		if oldest == null or started < float(oldest.get_meta("started", 0.0)):
			oldest = player
	if own >= maxi(cap, 1) and oldest_own != null:
		return oldest_own
	return free if free != null else oldest


## A random take of id, never the last one twice running.
func _pick(id: StringName, count: int) -> int:
	var last := int(_last_take.get(id, -1))
	var take := _rng.randi_range(0, count - 1)
	if count > 1 and take == last:
		take = (take + 1 + _rng.randi_range(0, count - 2)) % count
	_last_take[id] = take
	return take


## The clock a sound's rate limit counts in: game time, which stops in the pause,
## for the world's sounds; real time for the menus', which play in the pause.
func _clock(settings: Dictionary) -> float:
	return Time.get_ticks_usec() / 1000000.0 if str(settings.get("bus", "")) == "UI" else _game_s


func _log(entry: Dictionary, result: String) -> Dictionary:
	entry["result"] = result
	entry["frame"] = Engine.get_process_frames()
	requests.append(entry)
	while requests.size() > REQUEST_LOG_SIZE:
		requests.pop_front()
	return entry


## The requests for sound id, oldest first (tests).
func requested(id: StringName) -> Array[Dictionary]:
	var found: Array[Dictionary] = []
	for entry: Dictionary in requests:
		if entry.id == id:
			found.append(entry)
	return found


## How many plays of sound id are sounding now.
func voices_of(id: StringName) -> int:
	var count := 0
	for pool: Array in _pools.values():
		for player: Node in pool:
			if bool(player.get("playing")) and StringName(player.get_meta("sound_id", &"")) == id:
				count += 1
	return count


static func _make_pool(parent: Node, count: int, positional: bool) -> Array:
	var pool := []
	for index in count:
		var player: Node
		if positional:
			player = _positional_player()
		else:
			player = AudioStreamPlayer.new()
		player.name = "%s%d" % ["Voice3D" if positional else "Voice", index]
		parent.add_child(player)
		pool.append(player)
	return pool


## A positional player: quieter with distance (inverse, past its unit size), never
## louder than its gain however close (max_db 0), no Doppler.
static func _positional_player() -> AudioStreamPlayer3D:
	var spatial := AudioStreamPlayer3D.new()
	spatial.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	spatial.doppler_tracking = AudioStreamPlayer3D.DOPPLER_TRACKING_DISABLED
	spatial.max_db = 0.0
	return spatial


# --- Loops.

func hold_loop(id: StringName, holder: Object, level: float, at: Vector3, pitch: float) -> void:
	var voice := _voice_of(id, holder)
	if voice == null:
		var settings: Dictionary = _catalog.get(id, {})
		if settings.is_empty() or not bool(settings.get("loop", false)) or holder == null:
			push_error("Sound: %s is not a loop in %s" % [id, CATALOG_PATH])
			return
		if level <= SILENT_LEVEL:
			return
		voice = LoopVoice.new()
		voice.id = id
		voice.holder = weakref(holder)
		var held: Dictionary = _loops.get(holder.get_instance_id(), {})
		held[id] = voice
		_loops[holder.get_instance_id()] = held
	# As for one-shots, the level only lowers the sound's gain.
	voice.target = clampf(level, 0.0, 1.0)
	voice.pitch = maxf(0.05, pitch)
	if at.is_finite():
		voice.at = at
	voice.held_s = _game_s


func release_loop(id: StringName, holder: Object) -> void:
	var voice := _voice_of(id, holder)
	if voice != null:
		voice.target = 0.0
		voice.held_s = -INF


## A loop's level now (0 when it is not held), for tests.
func loop_level(id: StringName, holder: Object) -> float:
	var voice := _voice_of(id, holder)
	return voice.level if voice != null else 0.0


## Whether a loop is sounding now, for tests.
func loop_playing(id: StringName, holder: Object) -> bool:
	var voice := _voice_of(id, holder)
	return voice != null and voice.player != null and bool(voice.player.get("playing"))


## Holder's loop id, or null: the loops are kept by holder, then by sound.
func _voice_of(id: StringName, holder: Object) -> LoopVoice:
	if holder == null:
		return null
	var held: Variant = _loops.get(holder.get_instance_id())
	return (held as Dictionary).get(id) as LoopVoice if held != null else null


func _step_loops(delta: float) -> void:
	for holder_id: int in _loops.keys():
		var held: Dictionary = _loops[holder_id]
		for id: StringName in held.keys():
			_step_loop(held, id, held[id] as LoopVoice, delta)
		if held.is_empty():
			_loops.erase(holder_id)


## One loop's level, start, volume, pitch and place this frame; it is dropped from
## held once it has stopped.
func _step_loop(held: Dictionary, key: StringName, voice: LoopVoice, delta: float) -> void:
	var alive := voice.holder.get_ref() != null
	var target := voice.target if alive and _game_s - voice.held_s <= HOLD_TIMEOUT_S else 0.0
	var tau := LOOP_ATTACK_S if target > voice.level else LOOP_RELEASE_S
	voice.level = lerpf(voice.level, target, 1.0 - exp(-delta / tau))
	if target <= SILENT_LEVEL and voice.level < SILENT_LEVEL:
		voice.level = 0.0
	if voice.level > SILENT_LEVEL:
		voice.quiet_s = 0.0
		if not voice.started:
			voice.started = true
			_start_loop(voice)
		if voice.player != null:
			voice.player.set("volume_db", level_db(voice.id) + linear_to_db(voice.level))
			voice.player.set("pitch_scale", voice.pitch)
			if voice.player is AudioStreamPlayer3D and voice.at.is_finite():
				(voice.player as AudioStreamPlayer3D).global_position = voice.at
		return
	voice.quiet_s += delta
	if voice.quiet_s >= LOOP_STOP_AFTER_S or not alive:
		if voice.player != null:
			_log({"id": voice.id, "at": voice.at, "time": _game_s}, "loop_stop")
			voice.player.queue_free()
		held.erase(key)


func _start_loop(voice: LoopVoice) -> void:
	var settings: Dictionary = _catalog[voice.id]
	var takes: Array = _takes.get(voice.id, [])
	var entry := {"id": voice.id, "at": voice.at, "time": _game_s, "level_db": level_db(voice.id)}
	if takes.is_empty():
		_log(entry, "loop_silent")
		return
	var positional := str(settings.get("space", "3d")) == "3d"
	var player: Node
	if positional:
		var spatial := _positional_player()
		spatial.unit_size = float(settings.get("unit_m", 10.0))
		spatial.max_distance = float(settings.get("max_m", 0.0))
		player = spatial
	else:
		player = AudioStreamPlayer.new()
	player.name = "Loop_%s" % voice.id
	var take := _pick(voice.id, takes.size())
	var stream: AudioStream = takes[take]
	player.set("stream", stream)
	player.set("bus", StringName(str(settings.get("bus", "SFX"))))
	player.set("volume_db", level_db(voice.id) + linear_to_db(maxf(voice.level, SILENT_LEVEL)))
	player.set("pitch_scale", voice.pitch)
	_world.add_child(player)
	if player is AudioStreamPlayer3D and voice.at.is_finite():
		(player as AudioStreamPlayer3D).global_position = voice.at
	player.call("play", _rng.randf() * maxf(stream.get_length() - 0.05, 0.0))
	voice.player = player
	entry["take"] = take
	_log(entry, "loop_start")


# --- Beds.

## Play has started: the beds fade in, the water's by the distance from the
## listener to this outline.
func start_beds(boundary: WorldBoundary) -> void:
	_boundary = boundary
	_beds_from = _game_s
	_bed_clock = BED_UPDATE_S


func _step_beds(delta: float) -> void:
	if _beds_from < 0.0:
		return
	_bed_clock += delta
	if _bed_clock >= BED_UPDATE_S:
		_bed_clock = 0.0
		var at := _listener_position()
		if at.is_finite():
			# Louder with height (the jetpack): open air, no shelter.
			_bed_targets[WIND_BED] = 0.45 + 0.55 * smoothstep(8.0, 70.0, at.y)
			var shore := 0.0
			if _boundary != null and _boundary.is_configured() and _boundary.contains_position(at):
				shore = _boundary.edge_distance(at)
			_bed_targets[WATER_BED] = (1.0 - smoothstep(12.0, 150.0, shore)) * (1.0 - 0.6 * smoothstep(20.0, 120.0, at.y))
	var fade := clampf((_game_s - _beds_from) / BED_FADE_IN_S, 0.0, 1.0)
	for bed: StringName in _bed_levels:
		_bed_levels[bed] = lerpf(float(_bed_levels[bed]), float(_bed_targets[bed]), 1.0 - exp(-delta / BED_FOLLOW_S))
		hold_loop(bed, self, float(_bed_levels[bed]) * fade, Vector3.INF, 1.0)


## A bed's level now (before the manifest's level), for tests.
func bed_level(bed: StringName) -> float:
	return float(_bed_levels.get(bed, 0.0))


# --- The clock, the listener and the pending plays.

func _process(delta: float) -> void:
	# The pause stops game time (main.gd's PauseClock sets the time scale to 0).
	if delta <= 0.0:
		return
	_game_s += delta
	for index in range(_pending.size() - 1, -1, -1):
		var due: Dictionary = _pending[index]
		if _game_s < float(due.due):
			continue
		_pending.remove_at(index)
		var follow := (due.follow as WeakRef).get_ref() as Node3D
		var at: Vector3 = follow.global_position if is_instance_valid(follow) and follow.is_inside_tree() else due.at
		request(due.id, at, float(due.strength), float(due.pitch))
	_step_beds(delta)
	_step_loops(delta)


func _listener_position() -> Vector3:
	var camera := get_viewport().get_camera_3d() if is_inside_tree() else null
	return camera.global_position if camera != null else Vector3.INF


func _listener_distance(at: Vector3) -> float:
	var listener := _listener_position()
	return listener.distance_to(at) if listener.is_finite() else 0.0


# --- The player's master volume and mute.

## The volume and mute kept in the settings file ({volume, muted}); the defaults
## where it has none or cannot be read.
static func saved_settings() -> Dictionary:
	var file := ConfigFile.new()
	var kept := {"volume": DEFAULT_VOLUME, "muted": false}
	if file.load(ShadowQuality.settings_path) == OK:
		var level: Variant = file.get_value(SETTINGS_SECTION, VOLUME_KEY, DEFAULT_VOLUME)
		if (level is float or level is int) and is_finite(float(level)):
			kept.volume = clampf(float(level), 0.0, 1.0)
		var off: Variant = file.get_value(SETTINGS_SECTION, MUTED_KEY, false)
		kept.muted = off if off is bool else false
	return kept


## Keeps the volume and mute for the next run, with whatever else the file
## holds; where storage fails (a private browser window) this keeps nothing.
static func save_settings(level: float, off: bool) -> void:
	var file := ConfigFile.new()
	file.load(ShadowQuality.settings_path)
	file.set_value(SETTINGS_SECTION, VOLUME_KEY, clampf(level, 0.0, 1.0))
	file.set_value(SETTINGS_SECTION, MUTED_KEY, off)
	file.save(ShadowQuality.settings_path)


## Puts a master volume (0..1) and mute on, at once.
func apply_settings(level: float, off: bool) -> void:
	volume = clampf(level, 0.0, 1.0)
	muted = off
	var master := AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_volume_linear(master, volume)
	AudioServer.set_bus_mute(master, muted)
