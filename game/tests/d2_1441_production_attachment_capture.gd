extends "res://game/tests/isle_house_low_live_evidence_capture.gd"

## Fresh ordinary-main evidence for the uncredited D2 1441 live replacement.
## All travel, aiming, cadence, spray, and roof landing use the real player input
## and controller routes. This file never constructs the facade and never writes
## a PlayerController or Camera3D transform.

class D21441PostPlayerSampler:
	extends Node

	signal post_player_physics_tick(snapshot: Dictionary)

	var _player: PlayerController
	var _chain_start := Vector3.ZERO
	var _chain_tangent := Vector3.FORWARD
	var _sequence := 0
	var _release_action := StringName()
	var _release_sequence := -1
	var latest_snapshot: Dictionary = {}


	func configure(player: PlayerController, chain_start: Vector3, chain_tangent: Vector3) -> void:
		_player = player
		_chain_start = chain_start
		_chain_tangent = chain_tangent
		process_physics_priority = player.process_physics_priority + 100


	func release_input_at_sequence(action: StringName, sequence: int) -> void:
		_release_action = action
		_release_sequence = sequence


	func _physics_process(_delta: float) -> void:
		if not is_instance_valid(_player):
			return
		_sequence += 1
		var position := _player.global_position
		latest_snapshot = {
			"engine_physics_frame": Engine.get_physics_frames(),
			"sampler_sequence_index": _sequence,
			"player_position_m": [position.x, position.y, position.z],
			"chain_u_m": Vector2(position.x - _chain_start.x, position.z - _chain_start.z).dot(Vector2(_chain_tangent.x, _chain_tangent.z)),
		}
		if not _release_action.is_empty() and _sequence == _release_sequence:
			Input.action_release(_release_action)
		post_player_physics_tick.emit(latest_snapshot.duplicate(true))


const D2_SOURCE_KEY := "w95934105"
const D2_WALL_KEY := "building:w95934105:wall"
const D2_ROOF_KEY := "building:w95934105:roof"
const D2_TARGET_CHUNK_ID := "x_-1__z_-1"
const D2_CAPTURE_TIME_METRIC := "8/213"
const D2_PRODUCTION_WORLD := {"rows": 735, "meshes": 959, "surfaces": 974, "triangles": 69252, "bodies": 466, "shapes": 466}
const D2_ACCEPTED_B225_BASELINE := {"rows": 735, "meshes": 952, "surfaces": 967, "triangles": 67716, "bodies": 466, "shapes": 466}
const D2_GENERIC_PAIR := {"meshes": 2, "surfaces": 2, "triangles": 42, "bodies": 2, "shapes": 2}
const D2_LIVE_PAIR := {"meshes": 9, "surfaces": 9, "triangles": 1578, "bodies": 2, "shapes": 2}
const D2_LIVE_DELTA := {"rows": 0, "meshes": 7, "surfaces": 7, "triangles": 1536, "bodies": 0, "shapes": 0}
const D2_MAPPED_RUNS: Array[int] = [10, 12, 13, 15]
const D2_PROTECTED_RUNS: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 11, 14]
const D2_CONFUSION_SOURCES := ["w95934144", "w95934143", "w95934131", "w95934129"]
const D2_FROZEN_CUES := [
	"two projecting windowed outer wings",
	"paired two-level central recess and circulation cadence",
	"shallow dark side-gable and broad projecting eaves",
]
const D2_OUTPUT := "res://evidence/first-playable/d2-1441-production-v8-staging-2026-09-05-009"
const D2_REHEARSAL_OUTPUT := "user://d2-1441-production-v8-complete-rehearsal-2026-09-05"
const D2_APP_BUNDLE_RELATIVE_PATH := "build/d2-1441-production-v8-staging-2026-09-05-009/Treasure Island First Playable.app"
const D2_GENERATOR_PATH := "res://game/tests/d2_1441_production_attachment_capture.gd"
const D2_PARENT_CAPTURE_PATH := "res://game/tests/isle_house_low_live_evidence_capture.gd"
const D2_FOCUSED_PATH := "res://game/tests/headless_d2_1441_production_attachment_contract.gd"
const D2_PACKAGE_PATH := "res://game/tests/headless_d2_1441_production_attachment_package_contract.gd"
const D2_SOURCE_FOCUSED_PATH := "res://game/tests/headless_d2_1441_chinook_live_replacement_contract.gd"
const D2_SOURCE_PACKAGE_PATH := "res://game/tests/headless_d2_1441_chinook_live_replacement_package_contract.gd"
const D2_CONFIG_PATH := "res://game/resources/facades/d2_1441_chinook_live_replacement.json"
const D2_ADAPTER_PATH := "res://game/scripts/world/facades/d2_1441_chinook_live_replacement.gd"
const D2_BUILDER_PATH := "res://game/scripts/world/world_chunk_builder.gd"
const D2_MAIN_SCRIPT_PATH := "res://game/scripts/main.gd"
const D2_MAIN_SCENE_PATH := "res://game/scenes/main.tscn"
const D2_WORLD_SCENE_PATH := "res://game/scenes/world/world_root.tscn"
const D2_CHUNK_PATH := "res://generated/world/chunks/x_-1__z_-1.json"
const D2_MANIFEST_PATH := "res://generated/world/manifest.json"
const D2_REGISTRY_PATH := "res://game/resources/facades/facade-runtime-registry.json"
const D2_CONTRACTS_PATH := "res://game/resources/facades/facade-runtime-adapter-contracts.json"
const D2_CATALOG_PATH := "res://discovery/facades/facade-recognition-catalog.json"
const D2_SCHEMA_PATH := "res://discovery/facades/facade-recognition-catalog.schema.json"
const D2_LOADER_PATH := "res://game/scripts/world/facades/facade_runtime_registry_loader.gd"
const D2_COMPILER_PATH := "res://tools/build_facade_recognition_registry.mjs"
const D2_EXPORT_PRESET_PATH := "res://export_presets.cfg"
const D2_CAPTURE_OVERRIDE := "res://override.cfg"
const D2_CAPTURE_OVERRIDE_SHA256 := "edbc0b9caa60fa0fc6b83cebb3145bce11ce0bd976403ca1d2fbe9b7142b39c3"
const D2_PACKAGE_RECEIPT_FILENAME := "package-verification-receipt.json"
const D2_PACKAGE_RECEIPT_SCHEMA := "ti.d2-1441-production-v8-package-verification/1"
const D2_STATIC_SCHEMA := "ti.d2-1441-production-v8-static-evidence/1"
const D2_MOTION_SCHEMA := "ti.d2-1441-production-v8-motion-telemetry/1"
const D2_VISUAL_SCHEMA := "ti.d2-1441-production-v8-visual-motion/1"
const D2_STATIC_SIZE := Vector2i(1440, 900)
const D2_DEFAULT_SUN := Vector3(-52.0, -28.0, 0.0)
const D2_CHANGED_SUN := Vector3(-26.0, 126.0, 0.0)
const D2_PHYSICS_WORLD_SOLID := 1 << 0
const D2_PHYSICS_SPRAY_SURFACE := 1 << 2
const D2_PHYSICS_HZ := 60
const D2_VISUAL_FIXED_FPS := 60
const D2_MOTION_TELEMETRY_FRAMES := 360
const D2_MOTION_BRAKING_FRAMES := 12
const D2_MOTION_INPUT_ACTION := "move_right"
const D2_TARGET_POINT := Vector3(-258.455, 6.36, -15.544)
const D2_PUBLIC_TANGENT := Vector3(-0.8835687595540772, 0.0, 0.4683014490048790)
const D2_PUBLIC_OUTWARD := Vector3(-0.4678877204190328, 0.0, -0.8837879163470619)
const D2_MOTION_CHAIN_START := Vector3(-252.8442921772453, 6.36, -43.41676024172318)
const D2_MOTION_WALL_START := Vector3(-242.5507623280266, 6.36, -23.973426082087823)
const D2_MOTION_JOIN_U_M: Array[float] = [10.583, 15.223, 20.780]
const D2_VISUAL_TRIGGER_TOLERANCE_M := 0.22
const D2_TRANSIT_LOW_Y := 18.0
const D2_TRANSIT_HIGH_Y := 23.0
const D2_TIMEOUT_SECONDS := 1800.0
const D2_FROZEN_GEOMETRY_SIGNATURE := "b91b373e3bb8238a6f73f05734ef48b3429ae5654eddce89b1981ee41ee89195"
const D2_FROZEN_OWNERSHIP_SIGNATURE := "fcad9968be3d0c9094adef5dcc9c7fabfb7cf1754f780897188a4ec362187e4d"
const D2_WALL_CANONICAL_SHA256 := "00f3cd8b90e7ae93f802842b59bb10274f1fc388433e5b5c6cae1f3e23f4393c"
const D2_ROOF_CANONICAL_SHA256 := "e7da0179f012e928f575ac32440e176a0f3b9651fc325a594de80ce7e3fc9d55"
const D2_EXPECTED_CONTENT_SHA256 := "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
const D2_EXPECTED_MANIFEST_SHA256 := "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
const D2_STILL_FILES := [
	"01-whole-sse-default.png",
	"02-sse-oblique-default.png",
	"03-sse-oblique-changed-light.png",
	"04-whole-sse-default-grayscale.png",
	"05-projecting-wings-paired-recess-close.png",
	"06-shallow-gable-broad-eaves.png",
	"07-nearby-context.png",
	"08-protected-return-run11.png",
	"09-real-spray-eligible-wall.png",
	"10-real-player-roof-landing.png",
	"11-comparator-w95934144.png",
	"12-comparator-w95934143.png",
	"13-comparator-w95934131.png",
	"14-comparator-w95934129.png",
]
const D2_STATIC_VIEWS := [
	{"id": "01-whole-sse-default", "role": "whole_sse_recognizable_ordinary_player_view", "xz": Vector2(-230.0, -65.0), "aim": Vector3(-249.514, 6.36, -26.700), "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "02-sse-oblique-default", "role": "sse_oblique_projecting_wings_and_recess", "xz": Vector2(-245.0, -47.0), "aim": D2_TARGET_POINT, "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "05-projecting-wings-paired-recess-close", "role": "close_two_projecting_wings_and_paired_two_level_recess_circulation", "xz": Vector2(-248.0, -35.0), "aim": Vector3(-258.455, 6.25, -15.544), "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "06-shallow-gable-broad-eaves", "role": "shallow_dark_gable_and_broad_projecting_eaves", "xz": Vector2(-230.0, -65.0), "aim": Vector3(-256.0, 9.05, -16.845), "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "07-nearby-context", "role": "wide_1441_and_nearby_current_world_context", "xz": Vector2(-225.0, -82.0), "aim": D2_TARGET_POINT, "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "08-protected-return-run11", "role": "protected_generic_return_run11_and_adjacent_selected_sse", "xz": Vector2(-257.642, -19.182), "aim": Vector3(-253.2245, 6.1, -21.5235), "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "09-real-spray-eligible-wall", "role": "real_visible_spray_on_exposed_eligible_exact_wall_owner", "xz": Vector2(-251.15, -29.80), "aim": Vector3(-249.514, 6.08, -26.700), "receiver": D2_WALL_KEY, "source": D2_SOURCE_KEY, "support": "ground"},
	{"id": "10-real-player-roof-landing", "role": "real_player_input_jetpack_and_visually_unambiguous_truthful_roof_landing", "xz": Vector2(-247.00, -23.50), "aim": Vector3(-244.50, 8.50, -19.50), "receiver": D2_ROOF_KEY, "source": D2_SOURCE_KEY, "support": "roof"},
	{"id": "11-comparator-w95934144", "role": "current_world_confusion_comparator_1439_chinook", "xz": Vector2(-305.7, -24.7), "aim": Vector3(-292.01, 6.3, 2.02), "receiver": "building:w95934144:wall", "source": "w95934144", "support": "ground"},
	{"id": "12-comparator-w95934143", "role": "current_world_confusion_comparator_1443_chinook", "xz": Vector2(-194.9, 1.6), "aim": Vector3(-216.36, 6.4, -26.08), "receiver": "building:w95934143:wall", "source": "w95934143", "support": "ground"},
	{"id": "13-comparator-w95934131", "role": "current_world_confusion_comparator_1438_chinook", "xz": Vector2(-326.0, -50.0), "aim": Vector3(-298.09, 6.1, -48.58), "receiver": "building:w95934131:wall", "source": "w95934131", "support": "ground"},
	{"id": "14-comparator-w95934129", "role": "current_world_confusion_comparator_1440_chinook", "xz": Vector2(-225.0, -78.0), "aim": Vector3(-242.6555, 6.3, -67.081), "receiver": "building:w95934129:wall", "source": "w95934129", "support": "ground"},
]
const D2_DEPENDENCY_HASHES := {
	"res://project.godot": "305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af",
	D2_MAIN_SCRIPT_PATH: "1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232",
	D2_BUILDER_PATH: "7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a",
	D2_CONFIG_PATH: "aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111",
	D2_ADAPTER_PATH: "bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1",
	D2_SOURCE_FOCUSED_PATH: "5a7e5f7e47e1168490b3a7ef37f9488499cd99540156b2009d9006f9fd559149",
	D2_SOURCE_PACKAGE_PATH: "73a7c945e1a6d2b425a2c829a60803010c6bd8dc374c7e45df592cbde5f5eefe",
	D2_FOCUSED_PATH: "6014498a52676ec93c955ccc672db3d6845c90a0b5e7dbfd1f05df3cf1792986",
	D2_PACKAGE_PATH: "cc2942797cda2c1cb2bef97bd2ef757fc993a6dfce223bbbd96d91e89230e580",
	D2_PARENT_CAPTURE_PATH: "47768e4b2d6288b9c3dbb4b0ad19cd870b61a8804d72673c53bf3326f8f5636a",
	D2_MAIN_SCENE_PATH: "959a0f8a14057ea8402790ba374c7839d5f9835ce20ad194846f0a4d45b43d66",
	D2_WORLD_SCENE_PATH: "ed6dfaa1933cedf2a70ca6afd677a645d588dbf6c823fb04402aaaea4b709ab8",
	D2_CHUNK_PATH: "5e3b7efb7a2c61e1092c6a42ca9c04212c7d2603890b7a3f4c5e46777005f17b",
	D2_MANIFEST_PATH: D2_EXPECTED_MANIFEST_SHA256,
	D2_REGISTRY_PATH: "109f83f40450e9c71ef6d39f1659e76eac5f1457fcfab772538b471cc74c0051",
	D2_CONTRACTS_PATH: "dd2d13e3b0f6eee1f8c5f2957927c4f3caba43b31883beea925f9a91b826d65c",
	D2_CATALOG_PATH: "d95be7bec8f0eabe97a9b5f7fefe1ce54ec7cbf940d85d28518ff6979eeb16ea",
	D2_SCHEMA_PATH: "44584e92e1652fc930f47882b4a83304f5216c14173eb805bc9ce68ea9927cac",
	D2_LOADER_PATH: "12e6c64b23b0783ed240b3d6c02499c3940c2b6a14344caa29778b850db06c04",
	D2_COMPILER_PATH: "eee17772b1beb71b3d6bd87800035a0c1c47a7c80473014c578bb055a5ddf0c9",
	D2_EXPORT_PRESET_PATH: "e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f",
	"res://game/scripts/player/player_controller.gd": "8b114132d66c78dd0bfd09783c7b9a3a3a441a8b1ae14f33f7308bd9b04ed0ea",
	"res://game/scripts/player/player_camera.gd": "90ea739b25eb6cbcf8bacff072599b117fe894fcef08683483e41527d8019636",
	"res://game/scripts/interaction/spray_controller.gd": "9897042fbffc6740ebe3eb4c19da544a0d437391ded9987318edc7238c403da4",
	"res://game/scripts/interaction/tag_instance_pool.gd": "2460b12b9f70945dc88d2e321b72c1779dab4d867fd80f5920f4734213ce0950",
	"res://game/resources/textures/tag/predefined_tag.svg": "9eb345572cd3298ea14bad008fc6405e46123c0243444e4582393d0aa84af885",
	"res://game/scripts/world/facades/d2_1441_chinook_standalone_hero_prototype.gd": "6c0bf201bbb38a424453f753471cb7cb8060d0323e2386a9fda3bad84acd5933",
	"res://game/resources/facades/d2_1441_chinook_standalone_hero_prototype.json": "ebb6be74a630ad405030938dc7d27bc6fed46b2d6892a847ee653d374df57f75",
	"res://game/scripts/world/facades/site_12_housing_kit.gd": "f4ebaf73ec675652579c5d3b0b774a6d15a7a7687df3accc2c5cb53d385bc6cd",
	"res://game/resources/materials/world/site_12_housing/site_12_warm_ivory_stucco.tres": "81fd15832670516b2cc752e89310acda201f30705b01297639703f76f2111a64",
	"res://game/resources/materials/world/site_12_housing/site_12_protected_neutral.tres": "d97d7b4a442ffe8ad9a0b003e5c1d6466f9ef9effc7cdb2be8ef966195e66782",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_roof_surrogate.tres": "389c01066767b085ef8ed8ae4c5e1b06062d9ffb135e3e6a7bfa968b963717d7",
	"res://game/resources/materials/world/site_12_housing/site_12_void_shadow.tres": "4159f82cc5c4c17c0d8173eddbc171120326fbd99578aa68012275b1274ce02d",
	"res://game/resources/materials/world/site_12_housing/site_12_opaque_opening.tres": "eddc4900c351dc3a75d163bd380a8b3a39bf6a1c1c3647299e3af19634a60ead",
	"res://game/resources/materials/world/site_12_housing/site_12_dark_metal.tres": "75c13aa30a4e3c9f49980d78abe41f40c6c7ab270be6152c201eb8a72ebe8720",
	"res://game/resources/textures/world/site_12_housing/warm_ivory_mineral_albedo_v2.png": "af1c7a8f90ab5e60b9ab40a3bcf087aa26b00892edd48a2b4f1c84533f8be51c",
	"res://game/resources/textures/world/polyhaven/bitumen/bitumen_diff_1k.jpg": "fa09ed33d59c3bb90ef70d36352207e2e1ca5564cfc61295c0124d1a7d785808",
	"res://evidence/first-playable/d2-1441-chinook-standalone-hero-2026-09-04/INDEPENDENT_BAR_RAISER_REVIEW.md": "8b259934a3771642efb5902c1fcbba590613e8f1f80e4b7d00a1b4a391862c55",
}

var _d2_finished := false
var _d2_production_observation: Dictionary = {}


func _initialize() -> void:
	create_timer(D2_TIMEOUT_SECONDS, true, false, true).timeout.connect(_d2_timeout)
	call_deferred("_d2_run")


func _d2_run() -> void:
	var mode := _argument_value("--capture-mode=")
	if mode == "source-contract":
		if _require(_d2_generator_matches(), "D2 generator SHA argument is absent or stale.") \
		and _require(_d2_dependencies_match(), "D2 production dependency closure drifted.") \
		and _require(not FileAccess.file_exists(D2_CAPTURE_OVERRIDE), "Temporary capture override must be absent for source contract.") \
		and _require(not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(D2_OUTPUT)), "Authoritative D2 production packet already exists before capture."):
			print("PASS: D2 1441 production capture source contract is exact, ordinary-main-only, input-driven, uncredited at v8 8/213, and has no existing packet or override")
		_finish(null)
		return
	if mode == "validate":
		if _require(_d2_generator_matches(), "D2 validator generator SHA argument is absent or stale.") \
		and _require(_d2_dependencies_match(), "D2 validator dependency closure drifted.") \
		and _require(not FileAccess.file_exists(D2_CAPTURE_OVERRIDE), "Temporary capture override must be absent for packet validation.") \
		and _require(_d2_validate_complete_packet(D2_OUTPUT, true), "D2 authoritative packet failed complete disk validation."):
			print("PASS: D2 production packet is exactly 40 acyclic files with 14 static and 21 post-draw motion PNGs plus three manifests, override copy, and external receipt")
		_finish(null)
		return
	if mode not in ["review-stills", "review-telemetry", "review-motion", "stills", "telemetry", "visual-motion"]:
		_fail("Pass one exact D2 capture mode: source-contract, validate, review-stills, review-telemetry, review-motion, stills, telemetry, or visual-motion.")
		_finish(null)
		return
	var visual_motion_mode := mode in ["review-motion", "visual-motion"]
	var authoritative := mode in ["stills", "telemetry", "visual-motion"]
	var output_root := D2_OUTPUT if authoritative else D2_REHEARSAL_OUTPUT
	if not _require(_d2_native_runtime_matches(), "D2 evidence requires Godot 4.7.2, native macOS Metal 4.0 on Apple M2, exact 1440x900, 60 Hz, and interpolation disabled.") \
	or not _require(_d2_generator_matches(), "D2 generator SHA argument is absent or stale.") \
	or not _require(_d2_dependencies_match(), "D2 production dependency closure drifted.") \
	or not _require(_d2_override_matches(), "Temporary exact 1440x900 capture override is absent or drifted.") \
	or not _require(_d2_receipt_argument_matches(), "Fresh acyclic D2 package receipt or receipt SHA argument is absent/drifted.") \
	or not _require(not visual_motion_mode or _d2_visual_fixed_fps_receipt_matches(), "D2 visual motion requires the explicit operator-requested fixed-fps 60 invocation receipt.") \
	or not _require(_d2_output_state_allows(mode, output_root), "D2 output tree is not in the exact prerequisite state for %s." % mode):
		_finish(null)
		return
	var loaded := await _d2_load_ordinary_main()
	if not _require(bool(loaded.get("ok", false)), str(loaded.get("message", "D2 ordinary main failed."))):
		_finish(loaded.get("main", null) as Node)
		return
	var main := loaded.main as GameMain
	var world := loaded.world as WorldLoader
	var player := loaded.player as PlayerController
	var hud := loaded.hud as GameHUD
	var sun := loaded.sun as DirectionalLight3D
	var bindings := loaded.bindings as Dictionary
	if mode in ["review-stills", "stills"]:
		await _d2_capture_stills(main, world, player, hud, sun, bindings, output_root, authoritative)
	elif mode in ["review-telemetry", "telemetry"]:
		await _d2_capture_telemetry(world, player, hud, sun, bindings, output_root, authoritative)
	else:
		await _d2_capture_visual_motion(world, player, hud, sun, bindings, output_root, authoritative)
	_finish(main)


func _d2_load_ordinary_main() -> Dictionary:
	var packed := load(D2_MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		return {"ok": false, "message": "Ordinary main scene did not load."}
	var main := packed.instantiate() as GameMain
	var world := main.get_node("WorldRoot") as WorldLoader
	var player := main.get_node("Player") as PlayerController
	var hud := main.get_node("Interface/HUD") as GameHUD
	var sun := main.get_node("Sun") as DirectionalLight3D
	var ready: Array[Dictionary] = []
	var failures: Array[Dictionary] = []
	world.world_ready.connect(func(report: Dictionary) -> void: ready.append(report.duplicate(true)))
	world.world_failed.connect(func(code: String, message: String, sources: Array) -> void: failures.append({"code": code, "message": message, "sources": sources.duplicate()}))
	root.add_child(main)
	var started := Time.get_ticks_msec()
	while ready.is_empty() and failures.is_empty() and Time.get_ticks_msec() - started < 60000:
		await process_frame
	if not failures.is_empty() or ready.size() != 1:
		return {"ok": false, "message": "Ordinary main did not reach exactly one clean world_ready: %s" % failures, "main": main}
	var topology_at_ready := _d2_runtime_topology(world)
	var roots_at_ready := _d2_target_roots(world)
	if topology_at_ready != D2_PRODUCTION_WORLD or not bool(roots_at_ready.get("ok", false)):
		return {"ok": false, "message": "D2 attachment was not already integrated at world_ready: %s %s" % [topology_at_ready, roots_at_ready], "main": main}
	_d2_production_observation = {
		"ordinary_main_already_integrated": true,
		"attachment_present_at_world_ready": true,
		"world_ready_runtime_topology": topology_at_ready.duplicate(true),
		"capture_harness_adapter_or_factory_activation_count": 0,
		"capture_harness_standalone_scene_activation_count": 0,
		"world_ready_activation_count": 0,
	}
	while not player.was_first_reveal_grounded() and Time.get_ticks_msec() - started < 60000:
		await physics_frame
	if not player.was_first_reveal_grounded() or not player.visible:
		return {"ok": false, "message": "Real player did not complete ordinary ferry-spawn grounding.", "main": main}
	if str(ready[0].get("content_sha256", "")) != D2_EXPECTED_CONTENT_SHA256 \
	or FileAccess.get_sha256(D2_MANIFEST_PATH) != D2_EXPECTED_MANIFEST_SHA256 \
	or _d2_runtime_topology(world) != D2_PRODUCTION_WORLD:
		return {"ok": false, "message": "Generated world identity/topology drifted after startup.", "main": main}
	var bindings := _d2_validate_bindings(world)
	if not bool(bindings.get("ok", false)):
		return {"ok": false, "message": str(bindings.get("message", "D2 binding failed.")), "main": main}
	return {"ok": true, "main": main, "world": world, "player": player, "hud": hud, "sun": sun, "bindings": bindings.metadata}


func _d2_target_roots(world: WorldLoader) -> Dictionary:
	var walls := _record_nodes(world, D2_WALL_KEY)
	var roofs := _record_nodes(world, D2_ROOF_KEY)
	return {"ok": walls.size() == 1 and roofs.size() == 1, "walls": walls, "roofs": roofs}


func _d2_validate_bindings(world: WorldLoader) -> Dictionary:
	var roots := _d2_target_roots(world)
	if not bool(roots.get("ok", false)):
		return {"ok": false, "message": "Expected one exact D2 wall and roof root."}
	var wall := (roots.walls as Array[Node3D])[0]
	var roof := (roots.roofs as Array[Node3D])[0]
	var wall_measure := _d2_measure(wall)
	var roof_measure := _d2_measure(roof)
	var wall_body := wall.get_node_or_null("Collision") as StaticBody3D
	var roof_body := roof.get_node_or_null("Collision") as StaticBody3D
	var wall_shape := wall.get_node_or_null("Collision/Shape") as CollisionShape3D
	var roof_shape := roof.get_node_or_null("Collision/Shape") as CollisionShape3D
	var metadata := wall.get_meta("d2_1441_chinook_live_replacement", {}) as Dictionary
	var relief_triangles := 0
	var mesh_names: Array[String] = []
	for node: Node in wall.find_children("*", "MeshInstance3D", true, false):
		var instance := node as MeshInstance3D
		mesh_names.append(instance.name)
		if instance.name not in ["ProtectedExactWallRuns", "MappedSSEExactStuccoWallRuns"]:
			relief_triangles += int(instance.mesh.get_faces().size() / 3)
	mesh_names.sort()
	var standalone_nodes := world.find_children("*D2*Standalone*", "", true, false)
	if wall.name != "D21441ChinookLiveWallReplacement" or roof.name != "D21441ChinookLiveRoofReplacement" \
	or wall.get_node_or_null("Mesh") != null or roof.get_node_or_null("Mesh") != null \
	or wall_measure != {"meshes": 8, "surfaces": 8, "triangles": 1568, "bodies": 1, "shapes": 1} \
	or roof_measure != {"meshes": 1, "surfaces": 1, "triangles": 10, "bodies": 1, "shapes": 1} \
	or wall_body == null or roof_body == null or wall_shape == null or roof_shape == null \
	or not (wall_shape.shape is ConcavePolygonShape3D) or not (roof_shape.shape is ConcavePolygonShape3D) \
	or (wall_shape.shape as ConcavePolygonShape3D).get_faces().size() != 96 \
	or (roof_shape.shape as ConcavePolygonShape3D).get_faces().size() != 30 \
	or relief_triangles != 1536 or not wall_body.is_in_group("spray_receiver_wall") \
	or roof_body.is_in_group("spray_receiver_wall") or str(roof_body.get_meta("receiver_kind", "invalid")) != "none" \
	or not bool(roof_body.get_meta("spray_ray_blocking", false)) or not bool(roof_body.get_meta("roof_landing_world_solid", false)) \
	or str(metadata.get("geometry_signature", "")) != D2_FROZEN_GEOMETRY_SIGNATURE \
	or str(metadata.get("live_ownership_signature", "")) != D2_FROZEN_OWNERSHIP_SIGNATURE \
	or str(metadata.get("accepted_authority_schema", "")) != "ti.facade-runtime-registry/8" \
	or str(metadata.get("accepted_recognition_metric", "")) != D2_CAPTURE_TIME_METRIC \
	or int(metadata.get("candidate_recognition_credit", -1)) != 0 \
	or bool(metadata.get("recognition_accepted", true)) or bool(metadata.get("believability_accepted", true)) \
	or not standalone_nodes.is_empty():
		return {"ok": false, "message": "D2 ordinary-main pair topology/ownership/signature/standalone boundary drifted: wall=%s roof=%s relief=%d standalone=%d" % [wall_measure, roof_measure, relief_triangles, standalone_nodes.size()]}
	var ids := {
		"wall_root": str(wall.get_instance_id()),
		"roof_root": str(roof.get_instance_id()),
		"wall_body": str(wall_body.get_instance_id()),
		"roof_body": str(roof_body.get_instance_id()),
		"wall_shape": str(wall_shape.shape.get_instance_id()),
		"roof_shape": str(roof_shape.shape.get_instance_id()),
	}
	return {"ok": true, "metadata": {
		"source_key": D2_SOURCE_KEY,
		"wall_key": D2_WALL_KEY,
		"roof_key": D2_ROOF_KEY,
		"wall_topology": wall_measure,
		"roof_topology": roof_measure,
		"combined_factory_topology": D2_LIVE_PAIR.duplicate(true),
		"wall_collision_triangles": 32,
		"roof_collision_triangles": 10,
		"decorative_relief_triangles": 1536,
		"decorative_relief_collision_triangles": 0,
		"mapped_public_sse_runs": D2_MAPPED_RUNS,
		"protected_runs": D2_PROTECTED_RUNS,
		"mesh_names": mesh_names,
		"geometry_signature": D2_FROZEN_GEOMETRY_SIGNATURE,
		"live_ownership_signature": D2_FROZEN_OWNERSHIP_SIGNATURE,
		"live_instance_ids": ids,
		"ordinary_main_already_integrated": true,
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
	}}


func _d2_runtime_topology(world: WorldLoader) -> Dictionary:
	var evidence := world.get_runtime_evidence()
	return {"rows": evidence.playable_rows, "meshes": evidence.mesh_instances, "surfaces": evidence.surfaces, "triangles": evidence.triangles, "bodies": evidence.static_bodies, "shapes": evidence.shapes}


func _d2_measure(node: Node) -> Dictionary:
	var result := {"meshes": 0, "surfaces": 0, "triangles": 0, "bodies": 0, "shapes": 0}
	for current: Node in _d2_all_nodes(node):
		if current is MeshInstance3D:
			var mesh := (current as MeshInstance3D).mesh
			result.meshes += 1
			result.surfaces += mesh.get_surface_count()
			result.triangles += int(mesh.get_faces().size() / 3)
		elif current is StaticBody3D:
			result.bodies += 1
		elif current is CollisionShape3D:
			result.shapes += 1
	return result


func _d2_all_nodes(node: Node) -> Array[Node]:
	var result: Array[Node] = [node]
	for child: Node in node.get_children():
		result.append_array(_d2_all_nodes(child))
	return result


func _d2_input_aim(player: PlayerController, target: Vector3, horizontal_only: bool = false) -> Dictionary:
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var delta := target - rig.global_position
	if horizontal_only:
		delta.y = 0.0
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.001:
		return {"ok": false, "message": "Input aim target is vertically singular."}
	# CameraPivot yaw is local to the player, whose ordinary spawn transform has
	# a non-zero world yaw. Convert the world-space aim vector to that local
	# basis before emitting mouse input so the stock camera actually faces the
	# requested world point.
	var parent_basis := (rig.get_parent() as Node3D).global_basis
	var local_delta := parent_basis.inverse() * delta
	var desired_yaw := atan2(-local_delta.x, -local_delta.z)
	var desired_pitch := 0.0 if horizontal_only else atan2(delta.y, horizontal)
	if desired_pitch < deg_to_rad(rig.minimum_pitch_degrees) or desired_pitch > deg_to_rad(rig.maximum_pitch_degrees):
		return {"ok": false, "message": "Input aim pitch %.3f escaped stock limits." % rad_to_deg(desired_pitch)}
	player.set_gameplay_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	for _attempt in 3:
		var yaw_delta := angle_difference(rig.rotation.y, desired_yaw)
		var pitch_delta := desired_pitch - arm.rotation.x
		if absf(yaw_delta) <= 0.0001 and absf(pitch_delta) <= 0.0001:
			break
		var event := InputEventMouseMotion.new()
		event.relative = Vector2(-yaw_delta / rig.look_sensitivity, -pitch_delta / rig.look_sensitivity)
		Input.parse_input_event(event)
		await process_frame
	var yaw_error := absf(angle_difference(rig.rotation.y, desired_yaw))
	var pitch_error := absf(arm.rotation.x - desired_pitch)
	return {
		"ok": yaw_error <= 0.001 and pitch_error <= 0.001,
		"yaw_degrees": rad_to_deg(rig.rotation.y),
		"pitch_degrees": rad_to_deg(arm.rotation.x),
		"yaw_error_degrees": rad_to_deg(yaw_error),
		"pitch_error_degrees": rad_to_deg(pitch_error),
		"input_route": "Input.parse_input_event_to_PlayerCamera_unhandled_input",
	}


func _d2_input_travel_to(world: WorldLoader, player: PlayerController, hud: GameHUD, requested_xz: Vector2, aim_target: Vector3, pose_id: String, support_kind: String) -> Dictionary:
	if not world.get_boundary().contains_position(Vector3(requested_xz.x, 0.0, requested_xz.y)):
		return {"ok": false, "message": "%s is outside playable boundary." % pose_id}
	_clear_input()
	player.set_gameplay_enabled(true)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var start_position := player.global_position
	var travel_ticks := 0
	var jetpack_ticks := 0
	var boundary_ok := true
	var reached_cruise := false
	var target3 := Vector3(requested_xz.x, player.global_position.y, requested_xz.y)
	var initial_aim := await _d2_input_aim(player, target3, true)
	if not bool(initial_aim.get("ok", false)):
		return {"ok": false, "message": "%s initial travel aim failed: %s" % [pose_id, initial_aim]}
	Input.action_press("move_forward")
	Input.action_press("run")
	Input.action_press("jetpack")
	for tick in 7200:
		if tick % 30 == 0:
			target3 = Vector3(requested_xz.x, player.global_position.y, requested_xz.y)
			var travel_aim := await _d2_input_aim(player, target3, true)
			if not bool(travel_aim.get("ok", false)):
				_clear_input()
				return {"ok": false, "message": "%s travel re-aim failed." % pose_id}
		var distance := Vector2(player.global_position.x, player.global_position.z).distance_to(requested_xz)
		if player.global_position.y >= D2_TRANSIT_LOW_Y:
			reached_cruise = true
		if player.global_position.y <= D2_TRANSIT_LOW_Y:
			Input.action_press("jetpack")
		elif player.global_position.y >= D2_TRANSIT_HIGH_Y:
			Input.action_release("jetpack")
		if Input.is_action_pressed("jetpack"):
			jetpack_ticks += 1
		if distance <= 9.0:
			Input.action_release("run")
		if distance <= 1.25:
			Input.action_release("move_forward")
			break
		await physics_frame
		travel_ticks += 1
		_clean_hud(hud)
		boundary_ok = boundary_ok and world.get_boundary().contains_position(player.global_position)
		if int(world.get_runtime_evidence().recovery_count) != recoveries_before:
			_clear_input()
			return {"ok": false, "message": "%s triggered recovery during input transit." % pose_id}
	Input.action_release("move_forward")
	Input.action_release("run")
	for brake_tick in 45:
		if player.global_position.y <= D2_TRANSIT_LOW_Y:
			Input.action_press("jetpack")
		elif player.global_position.y >= D2_TRANSIT_HIGH_Y:
			Input.action_release("jetpack")
		await physics_frame
		travel_ticks += 1
		boundary_ok = boundary_ok and world.get_boundary().contains_position(player.global_position)
	# Close the final sub-meter error at stock walk speed. Each correction is
	# still ordinary input and is followed by controller braking.
	for _correction in 4:
		var distance := Vector2(player.global_position.x, player.global_position.z).distance_to(requested_xz)
		if distance <= 0.65:
			break
		target3 = Vector3(requested_xz.x, player.global_position.y, requested_xz.y)
		var correction_aim := await _d2_input_aim(player, target3, true)
		if not bool(correction_aim.get("ok", false)):
			_clear_input()
			return {"ok": false, "message": "%s corrective input aim failed." % pose_id}
		Input.action_press("move_forward")
		for _tick in 120:
			if Vector2(player.global_position.x, player.global_position.z).distance_to(requested_xz) <= 0.35:
				break
			if player.global_position.y <= D2_TRANSIT_LOW_Y:
				Input.action_press("jetpack")
			elif player.global_position.y >= D2_TRANSIT_HIGH_Y:
				Input.action_release("jetpack")
			await physics_frame
			travel_ticks += 1
		Input.action_release("move_forward")
		for _brake in 15:
			await physics_frame
			travel_ticks += 1
	Input.action_release("jetpack")
	# Ordinary controller descent ends on either generated ground/road or, for
	# the one roof proof, the exact live roof collider.
	var landed := false
	var descent_ticks := 0
	for _tick in 1200:
		await physics_frame
		descent_ticks += 1
		travel_ticks += 1
		_clean_hud(hud)
		boundary_ok = boundary_ok and world.get_boundary().contains_position(player.global_position)
		if player.is_on_floor() and absf(player.velocity.y) <= 0.05:
			landed = true
			break
	_clear_input()
	var support := _d2_support_below(player)
	var final_distance := Vector2(player.global_position.x, player.global_position.z).distance_to(requested_xz)
	var support_ok := bool(support.get("ok", false)) and (
		(str(support.get("object_key", "")) == D2_ROOF_KEY and support_kind == "roof")
		or (support_kind == "ground" and str(support.get("feature_kind", "")) in ["land_ground", "road_path"])
	)
	if not landed or not support_ok or final_distance > 2.0 or not boundary_ok \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "%s input landing failed: landed=%s support=%s distance=%.3f boundary=%s recovery=%d position=%s" % [pose_id, landed, support, final_distance, boundary_ok, int(world.get_runtime_evidence().recovery_count) - recoveries_before, player.global_position]}
	var final_aim := await _d2_input_aim(player, aim_target, false)
	if not bool(final_aim.get("ok", false)):
		player.set_gameplay_enabled(false)
		return {"ok": false, "message": "%s final input aim failed: %s" % [pose_id, final_aim]}
	player.set_gameplay_enabled(false)
	if not await _wait_for_render(main_from_player(player), player, hud):
		return {"ok": false, "message": "%s render settle failed." % pose_id}
	var camera := player.get_camera()
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var arm := rig.get_node("SpringArm3D") as SpringArm3D
	var actual_spring := camera.global_position.distance_to(rig.global_position)
	if not is_equal_approx(camera.fov, 70.0) or not is_equal_approx(arm.spring_length, 5.5) or actual_spring < 1.0:
		return {"ok": false, "message": "%s stock camera contract failed: fov=%.3f spring=%.3f actual=%.3f" % [pose_id, camera.fov, arm.spring_length, actual_spring]}
	return {"ok": true, "metadata": {
		"pose_id": pose_id,
		"input_only_route": true,
		"input_actions": ["move_forward", "run", "jetpack"],
		"input_aim_route": str(final_aim.input_route),
		"requested_xz": [requested_xz.x, requested_xz.y],
		"start_player_position_m": _vector3(start_position),
		"player_position_m": _vector3(player.global_position),
		"camera_position_m": _vector3(camera.global_position),
		"camera_forward": _vector3(-camera.global_basis.z),
		"aim_target_m": _vector3(aim_target),
		"horizontal_error_m": final_distance,
		"transit_physics_ticks": travel_ticks,
		"descent_physics_ticks": descent_ticks,
		"jetpack_pressed_ticks": jetpack_ticks,
		"reached_safe_transit_altitude": reached_cruise,
		"physics_grounded": player.is_on_floor(),
		"support": support,
		"in_boundary_entire_route": boundary_ok,
		"recovery_delta": 0,
		"camera_fov_degrees": camera.fov,
		"configured_spring_length_m": arm.spring_length,
		"actual_spring_length_m": actual_spring,
		"camera_yaw_degrees": float(final_aim.yaw_degrees),
		"camera_pitch_degrees": float(final_aim.pitch_degrees),
		"player_transform_writes": 0,
		"camera_transform_writes": 0,
	}}


func _d2_support_below(player: PlayerController) -> Dictionary:
	var start := player.global_position + Vector3.UP * 1.0
	var query := PhysicsRayQueryParameters3D.create(start, start + Vector3.DOWN * 6.0, D2_PHYSICS_WORLD_SOLID, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return {"ok": false}
	var collider := hit.get("collider") as CollisionObject3D
	var parent := collider.get_parent() if collider != null else null
	return {
		"ok": collider != null,
		"object_key": "" if collider == null else str(collider.get_meta("derived_object_key", "")),
		"source_keys": [] if collider == null else collider.get_meta("source_keys", []),
		"feature_kind": "" if parent == null else str(parent.get_meta("feature_kind", "")),
		"collider_path": "" if collider == null else str(collider.get_path()),
		"hit_position_m": _vector3(hit.position as Vector3),
		"hit_normal": _vector3(hit.normal as Vector3),
	}


func _d2_center_los(player: PlayerController, receiver: String, source: String, pose_id: String) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 2000.0, D2_PHYSICS_WORLD_SOLID, [player.get_rid()])
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var collider := hit.get("collider") as CollisionObject3D if not hit.is_empty() else null
	var actual_receiver := "" if collider == null else str(collider.get_meta("derived_object_key", ""))
	var actual_sources: Array = [] if collider == null else collider.get_meta("source_keys", [])
	if actual_receiver != receiver or actual_sources != [source]:
		return {"ok": false, "message": "%s center LOS hit %s %s, expected %s [%s]." % [pose_id, actual_receiver, actual_sources, receiver, source]}
	return {"ok": true, "metadata": {
		"receiver_first_los": true,
		"first_los_hit_receiver": actual_receiver,
		"first_los_hit_source_keys": actual_sources,
		"first_los_hit_position_m": _vector3(hit.position as Vector3),
		"first_los_hit_normal": _vector3(hit.normal as Vector3),
		"first_los_hit_distance_m": origin.distance_to(hit.position as Vector3),
	}}


func _d2_capture_stills(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_root.path_join("images"))) != OK:
		_fail("Could not create D2 static evidence directory.")
		return
	if not _d2_copy_override(output_root) or not _d2_copy_receipt(output_root):
		_fail("Could not copy exact capture override/package receipt into D2 packet.")
		return
	var captures: Array[Dictionary] = []
	var original_sun := sun.rotation_degrees
	for value: Variant in D2_STATIC_VIEWS:
		var view := value as Dictionary
		sun.rotation_degrees = D2_DEFAULT_SUN
		var pose := await _d2_input_travel_to(world, player, hud, view.xz as Vector2, view.aim as Vector3, str(view.id), str(view.support))
		if not _require(bool(pose.get("ok", false)), str(pose.get("message", "%s input pose failed." % view.id))):
			return
		var los := _d2_center_los(player, str(view.receiver), str(view.source), str(view.id))
		if not _require(bool(los.get("ok", false)), str(los.get("message", "%s LOS failed." % view.id))):
			return
		var extra := (pose.metadata as Dictionary).duplicate(true)
		extra.merge(los.metadata as Dictionary, true)
		extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
		extra["support_kind"] = str(view.support)
		if str(view.id) == "01-whole-sse-default":
			var whole := _d2_whole_projection(player.get_camera())
			if not _require(bool(whole.get("ok", false)), str(whole.get("message", "Whole SSE projection failed."))):
				return
			extra.merge(whole.metadata as Dictionary, true)
		if str(view.id) == "09-real-spray-eligible-wall":
			var spray := await _d2_place_real_spray(main, world, player, hud)
			if not _require(bool(spray.get("ok", false)), str(spray.get("message", "Real D2 spray failed."))):
				return
			extra.merge(spray.metadata as Dictionary, true)
		if str(view.id) == "10-real-player-roof-landing":
			extra["real_player_jetpack_route"] = true
			extra["roof_landing_world_solid"] = true
			extra["roof_is_not_spray_receiver"] = true
		var saved := await _d2_save_still(main, player, hud, output_root, str(view.id), str(view.role), "world_default", extra)
		if not _d2_append_saved(captures, saved):
			return
		if str(view.id) == "01-whole-sse-default":
			var gray := _d2_save_grayscale(output_root, "images/01-whole-sse-default.png", "images/04-whole-sse-default-grayscale.png")
			if not _d2_append_saved(captures, gray):
				return
		if str(view.id) == "02-sse-oblique-default":
			var frozen_player := player.global_transform
			var frozen_camera := player.get_camera().global_transform
			sun.rotation_degrees = D2_CHANGED_SUN
			if not await _wait_for_render(main, player, hud):
				_fail("Changed-light render did not settle.")
				return
			var changed_extra := (pose.metadata as Dictionary).duplicate(true)
			changed_extra.merge(los.metadata as Dictionary, true)
			changed_extra["sun_rotation_degrees"] = _vector3(sun.rotation_degrees)
			changed_extra["same_pose_source_capture"] = "images/02-sse-oblique-default.png"
			changed_extra["player_transform_exactly_reused"] = player.global_transform.is_equal_approx(frozen_player)
			changed_extra["camera_transform_exactly_reused"] = player.get_camera().global_transform.is_equal_approx(frozen_camera)
			var changed := await _d2_save_still(main, player, hud, output_root, "03-sse-oblique-changed-light", "same_pose_sse_oblique_under_materially_changed_light", "frozen_changed_light", changed_extra)
			if not _d2_append_saved(captures, changed):
				return
			sun.rotation_degrees = D2_DEFAULT_SUN
	sun.rotation_degrees = original_sun
	captures.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return str(left.id) < str(right.id))
	if captures.size() != D2_STILL_FILES.size():
		_fail("D2 static capture wrote %d/%d images." % [captures.size(), D2_STILL_FILES.size()])
		return
	var receipt := _d2_receipt_from_argument()
	var manifest := {
		"schema_version": D2_STATIC_SCHEMA,
		"capture_date": "2026-09-05",
		"candidate_status": "uncommitted_production_candidate_pending_two_independent_audits",
		"review_status": "pending_independent_production_contract_and_visual_audits_not_self_accepted",
		"recognition_status": "uncredited_prepromotion_candidate_authority_remains_v8_8_of_213",
		"production_stage": "d2_1441_prepromotion_production_v8_uncommitted_candidate",
		"authoritative_candidate_packet": authoritative,
		"uncommitted_candidate": true,
		"pending_independent_contract_audit": true,
		"pending_independent_visual_review": true,
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
		"capture_time_recognition_metric": D2_CAPTURE_TIME_METRIC,
		"proof_role": "native_ordinary_main_already_integrated_input_only_static_production_evidence",
		"target": {
			"canonical_name": "1441 Chinook Court",
			"source_key": D2_SOURCE_KEY,
			"wall_object_key": D2_WALL_KEY,
			"roof_object_key": D2_ROOF_KEY,
			"chunk_id": D2_TARGET_CHUNK_ID,
			"mapped_public_sse_runs": D2_MAPPED_RUNS,
			"protected_runs": D2_PROTECTED_RUNS,
			"confusion_set": D2_CONFUSION_SOURCES,
			"reference_supported_cues": D2_FROZEN_CUES,
		},
		"truth_boundary": {
			"ordinary_main_already_integrated": true,
			"capture_harness_loaded_or_called_adapter": false,
			"capture_harness_loaded_or_called_factory": false,
			"capture_harness_instantiated_standalone_scene": false,
			"player_transform_writes": 0,
			"camera_transform_writes": 0,
			"camera_tricks_or_signage_used": false,
			"hue_or_address_relied_on": false,
			"genai_stucco_role": "micro_surface_only_not_identity_evidence",
			"recognition_accepted": false,
			"believability_accepted": false,
			"as_built_fidelity_claimed": false,
			"unsurveyed_dimensions_and_counts": "reversible_production_inference",
		},
		"runtime_topology": D2_PRODUCTION_WORLD.duplicate(true),
		"accepted_b225_baseline_topology": D2_ACCEPTED_B225_BASELINE.duplicate(true),
		"generic_pair_replaced": D2_GENERIC_PAIR.duplicate(true),
		"live_pair_topology": D2_LIVE_PAIR.duplicate(true),
		"live_delta_from_accepted_b225_baseline": D2_LIVE_DELTA.duplicate(true),
		"bindings": bindings,
		"production_path_observation": _d2_production_observation.duplicate(true),
		"capture_time_authority": _d2_authority_receipt(),
		"source_dependency_hashes": D2_DEPENDENCY_HASHES.duplicate(true),
		"generator": D2_GENERATOR_PATH.trim_prefix("res://"),
		"generator_sha256": FileAccess.get_sha256(D2_GENERATOR_PATH),
		"generator_sha256_argument": _argument_value("--generator-sha256="),
		"package_verification_receipt_sha256": _argument_value("--package-verification-receipt-sha256="),
		"package_verification_receipt": receipt,
		"package_verification_receipt_copied_into_packet": true,
		"capture_override_sha256": FileAccess.get_sha256(D2_CAPTURE_OVERRIDE),
		"runtime_environment": _d2_runtime_environment(),
		"capture_command": ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot --path . --display-driver macos --rendering-method forward_plus --rendering-driver metal --audio-driver Dummy --resolution 1440x900 --script game/tests/d2_1441_production_attachment_capture.gd -- --capture-mode=%s --generator-sha256=<exact> --package-verification-receipt=<external> --package-verification-receipt-sha256=<exact>" % ("stills" if authoritative else "review-stills"),
		"stock_camera": {"fov_degrees": 70.0, "configured_spring_length_m": 5.5},
		"lighting": {"default_sun_rotation_degrees": _vector3(D2_DEFAULT_SUN), "changed_sun_rotation_degrees": _vector3(D2_CHANGED_SUN), "same_pose_pair": ["02-sse-oblique-default", "03-sse-oblique-changed-light"]},
		"captures": captures,
		"static_image_count": captures.size(),
		"visual_verdict": "pending_independent_production_visual_review",
		"postcapture_catalog_or_registry_mutation": false,
	}
	if not _write_new_json(output_root.path_join("capture-manifest.json"), manifest):
		_fail("Could not write D2 static manifest without overwrite.")
		return
	if not _d2_validate_static_stage(output_root, authoritative):
		_fail("D2 static stage failed disk-roundtrip validation.")
		return
	print("PASS: captured 14 native D2 production stills from ordinary main with input-only travel/aim, same-pose changed light, grayscale, spray, roof landing, protected return, and four current-world comparators")


func _d2_whole_projection(camera: Camera3D) -> Dictionary:
	var corners := [
		Vector3(-273.405, 3.1, -29.372), Vector3(-273.405, 10.4, -29.372),
		Vector3(-238.303, 3.1, -17.739), Vector3(-238.303, 10.4, -17.739),
		Vector3(-266.933, 3.1, -1.620), Vector3(-266.933, 10.4, -1.620),
	]
	var viewport := camera.get_viewport().get_visible_rect()
	var pixels: Array[Array] = []
	for corner: Vector3 in corners:
		if camera.is_position_behind(corner):
			return {"ok": false, "message": "Whole SSE corner is behind camera."}
		var pixel := camera.unproject_position(corner)
		if not viewport.grow(-15.0).has_point(pixel):
			return {"ok": false, "message": "Whole SSE corner escaped viewport at %s." % pixel}
		pixels.append([pixel.x, pixel.y])
	return {"ok": true, "metadata": {"complete_sse_subject_visible": true, "source_footprint_projection_pixels": pixels}}


func _d2_place_real_spray(main: GameMain, world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, D2_PHYSICS_SPRAY_SURFACE, [player.get_rid()])
	var hit := player.get_world_3d().direct_space_state.intersect_ray(query)
	var collider := hit.get("collider", null) as CollisionObject3D
	if hit.is_empty() or collider == null or str(collider.get_meta("derived_object_key", "")) != D2_WALL_KEY \
	or not collider.is_in_group("spray_receiver_wall") or player.global_position.distance_to(hit.position as Vector3) > player.get_spray_controller().maximum_range_m:
		return {"ok": false, "message": "D2 spray pose did not first-hit the exact eligible wall within real controller range: %s" % hit}
	var controller := player.get_spray_controller()
	var before := controller.tag_instances.active_count()
	var placed_before := int((world.get_runtime_evidence().spray_counts as Dictionary).placed)
	controller.attempt_spray()
	await process_frame
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "D2 real spray render did not settle."}
	if controller.tag_instances.active_count() != before + 1 or int((world.get_runtime_evidence().spray_counts as Dictionary).placed) != placed_before + 1:
		return {"ok": false, "message": "Real SprayController did not place exactly one D2 tag."}
	var tag := controller.tag_instances.get_child(controller.tag_instances.get_child_count() - 1) as Decal
	if tag == null or str(tag.get_meta("derived_object_key", "")) != D2_WALL_KEY or tag.get_meta("source_keys", []) != [D2_SOURCE_KEY]:
		return {"ok": false, "message": "Placed D2 tag identity drifted."}
	var visual := _d2_tag_visual_evidence(camera, tag, hit.position as Vector3)
	if not bool(visual.get("ok", false)):
		return visual
	var metadata := {
		"spray_result": "placed",
		"spray_controller_route": "real_SprayController_attempt_spray",
		"spray_first_hit_object": D2_WALL_KEY,
		"spray_first_hit_sources": [D2_SOURCE_KEY],
		"spray_first_hit_position_m": _vector3(hit.position as Vector3),
		"spray_first_hit_normal": _vector3(hit.normal as Vector3),
		"tag_position_m": _vector3(tag.global_position),
		"tag_visible_in_tree": tag.is_visible_in_tree(),
		"sole_wall_spray_owner": true,
	}
	metadata.merge(visual.metadata as Dictionary, true)
	return {"ok": true, "metadata": metadata}


func _d2_tag_visual_evidence(camera: Camera3D, tag: Decal, hit_position: Vector3) -> Dictionary:
	if not tag.is_visible_in_tree() or camera.is_position_behind(hit_position):
		return {"ok": false, "message": "Placed D2 tag is not in the camera-visible half-space."}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE:
		return {"ok": false, "message": "Placed D2 tag visibility image is unavailable."}
	var projected := camera.unproject_position(hit_position)
	var viewport_center := Vector2(image.get_size()) * 0.5
	if projected.distance_to(viewport_center) > 2.0:
		return {"ok": false, "message": "Placed D2 tag escaped the ordinary-camera center: %s." % projected}
	var minimum_x := maxi(0, int(floor(projected.x)) - 96)
	var maximum_x := mini(image.get_width() - 1, int(ceil(projected.x)) + 96)
	var minimum_y := maxi(0, int(floor(projected.y)) - 32)
	var maximum_y := mini(image.get_height() - 1, int(ceil(projected.y)) + 32)
	var cyan_pixels := 0
	var yellow_pixels := 0
	for y in range(minimum_y, maximum_y + 1):
		for x in range(minimum_x, maximum_x + 1):
			var color := image.get_pixel(x, y)
			if color.g > 0.42 and color.b > 0.34 and color.g > color.r * 1.30 and color.b > color.r * 1.18:
				cyan_pixels += 1
			if color.r > 0.45 and color.g > 0.34 and color.r > color.b * 1.35 and color.g > color.b * 1.18:
				yellow_pixels += 1
	if cyan_pixels < 8 or yellow_pixels < 1:
		return {"ok": false, "message": "Real predefined tag is not visibly discernible at its projected center: cyan=%d yellow=%d." % [cyan_pixels, yellow_pixels]}
	return {"ok": true, "metadata": {
		"tag_render_visible": true,
		"tag_projected_pixel": [projected.x, projected.y],
		"tag_visibility_sample_rect": [minimum_x, minimum_y, maximum_x, maximum_y],
		"tag_cyan_pixels": cyan_pixels,
		"tag_yellow_pixels": yellow_pixels,
		"tag_visibility_color_gate": "predefined_svg_cyan_and_yellow_present_around_exact_projected_hit",
	}}


func _d2_save_still(main: GameMain, player: PlayerController, hud: GameHUD, output_root: String, id: String, role: String, lighting: String, extra: Dictionary) -> Dictionary:
	if not await _wait_for_render(main, player, hud):
		return {"ok": false, "message": "%s render did not stabilize." % id}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE:
		return {"ok": false, "message": "%s image is empty or wrong-sized." % id}
	var sample := _sample_image(image)
	if int(sample.unique_colors) < 8 or float(sample.luminance_range) < 0.1:
		return {"ok": false, "message": "%s appears blank." % id}
	var relative := "images/%s.png" % id
	var path := output_root.path_join(relative)
	if FileAccess.file_exists(path) or image.save_png(path) != OK:
		return {"ok": false, "message": "%s would overwrite or failed PNG save." % id}
	var metadata := {
		"id": id,
		"role": role,
		"lighting": lighting,
		"file": relative,
		"sha256": FileAccess.get_sha256(path),
		"bytes": FileAccess.get_file_as_bytes(path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"sample_unique_colors": int(sample.unique_colors),
		"sample_luminance_range": float(sample.luminance_range),
		"debug_labels_visible": false,
		"source_photography_in_frame": false,
		"crop_or_postprocess": false,
		"camera_trick": false,
		"visual_verdict": "pending_independent_production_visual_review",
	}
	metadata.merge(extra, true)
	print("D2_1441_PRODUCTION_CAPTURE: id=%s sha256=%s" % [id, metadata.sha256])
	return {"ok": true, "metadata": metadata}


func _d2_save_grayscale(output_root: String, source_relative: String, target_relative: String) -> Dictionary:
	var source_path := output_root.path_join(source_relative)
	var target_path := output_root.path_join(target_relative)
	if FileAccess.file_exists(target_path):
		return {"ok": false, "message": "D2 grayscale target already exists."}
	var image := Image.load_from_file(source_path)
	if image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE:
		return {"ok": false, "message": "D2 grayscale source is invalid."}
	image.convert(Image.FORMAT_L8)
	if image.save_png(target_path) != OK:
		return {"ok": false, "message": "D2 grayscale PNG failed."}
	return {"ok": true, "metadata": {
		"id": "04-whole-sse-default-grayscale",
		"role": "lossless_grayscale_recognizability_check_without_hue_reliance",
		"lighting": "derived_from_world_default",
		"file": target_relative,
		"sha256": FileAccess.get_sha256(target_path),
		"bytes": FileAccess.get_file_as_bytes(target_path).size(),
		"dimensions": [image.get_width(), image.get_height()],
		"derivation_source": source_relative,
		"derivation_source_sha256": FileAccess.get_sha256(source_path),
		"crop_or_postprocess": false,
		"grayscale_only": true,
		"visual_verdict": "pending_independent_production_visual_review",
	}}


func _d2_append_saved(captures: Array[Dictionary], result: Dictionary) -> bool:
	if not _require(bool(result.get("ok", false)), str(result.get("message", "D2 capture save failed."))):
		return false
	captures.append(result.metadata as Dictionary)
	return true


func _d2_capture_telemetry(world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	sun.rotation_degrees = D2_DEFAULT_SUN
	var prepared := await _d2_prepare_motion(world, player, hud)
	if not _require(bool(prepared.get("ok", false)), str(prepared.get("message", "D2 telemetry start failed."))):
		return
	var sampler := prepared.sampler as D21441PostPlayerSampler
	var baseline := prepared.baseline as Dictionary
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var camera_basis := player.get_camera().global_basis
	var start_position := player.global_position
	var start_frame := int(baseline.engine_physics_frame)
	var start_sequence := int(baseline.sampler_sequence_index)
	var previous_frame := start_frame
	var previous_u := _d2_chain_u(player.global_position)
	var samples: Array[Dictionary] = []
	var joins: Array[Dictionary] = []
	player.set_gameplay_enabled(true)
	Input.action_press(D2_MOTION_INPUT_ACTION)
	for index in D2_MOTION_TELEMETRY_FRAMES:
		var value: Variant = await sampler.post_player_physics_tick
		var snapshot := value as Dictionary
		var frame := int(snapshot.get("engine_physics_frame", -1))
		var sequence := int(snapshot.get("sampler_sequence_index", -1))
		var state := _d2_motion_state(world, player, camera_basis, recoveries_before, previous_u, true)
		if frame != previous_frame + 1 or frame != start_frame + index + 1 \
		or sequence != start_sequence + index + 1 or not _d2_snapshot_matches(snapshot, player) \
		or not bool(state.get("ok", false)):
			_d2_stop_sampler(player, sampler)
			_fail("D2 telemetry lost consecutive post-player truth at sample %d: frame=%d previous=%d state=%s" % [index + 1, frame, previous_frame, state])
			return
		var metadata := state.metadata as Dictionary
		metadata["sample_index"] = index + 1
		metadata["engine_physics_frame"] = frame
		metadata["sampler_sequence_index"] = sequence
		metadata["sampled_after_player_physics_process"] = true
		samples.append(metadata)
		var u := float(metadata.chain_u_m)
		for join_index in D2_MOTION_JOIN_U_M.size():
			var join_u := D2_MOTION_JOIN_U_M[join_index]
			if previous_u < join_u and u >= join_u:
				joins.append({"join_index": join_index + 1, "join_u_m": join_u, "previous_sample_index": index, "current_sample_index": index + 1, "previous_u_m": previous_u, "current_u_m": u, "previous_engine_physics_frame": previous_frame, "current_engine_physics_frame": frame})
		previous_u = u
		previous_frame = frame
	var input_end_position := player.global_position
	var input_end_u := _d2_chain_u(input_end_position)
	Input.action_release(D2_MOTION_INPUT_ACTION)
	var braking: Array[Dictionary] = []
	for index in D2_MOTION_BRAKING_FRAMES:
		var value: Variant = await sampler.post_player_physics_tick
		var snapshot := value as Dictionary
		var frame := int(snapshot.get("engine_physics_frame", -1))
		var state := _d2_motion_state(world, player, camera_basis, recoveries_before, previous_u, false)
		if frame != previous_frame + 1 or not _d2_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_d2_stop_sampler(player, sampler)
			_fail("D2 braking telemetry drifted at sample %d: %s" % [index + 1, state])
			return
		var metadata := state.metadata as Dictionary
		metadata["braking_sample_index"] = index + 1
		metadata["engine_physics_frame"] = frame
		metadata["sampler_sequence_index"] = int(snapshot.sampler_sequence_index)
		braking.append(metadata)
		previous_u = float(metadata.chain_u_m)
		previous_frame = frame
	_d2_stop_sampler(player, sampler)
	if samples.size() != D2_MOTION_TELEMETRY_FRAMES or braking.size() != D2_MOTION_BRAKING_FRAMES \
	or previous_frame - start_frame != D2_MOTION_TELEMETRY_FRAMES + D2_MOTION_BRAKING_FRAMES \
	or joins.size() != 3 or input_end_u <= D2_MOTION_JOIN_U_M[-1] \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		_fail("D2 telemetry closure failed: samples=%d braking=%d joins=%d end_u=%.3f frame_span=%d recovery=%d" % [samples.size(), braking.size(), joins.size(), input_end_u, previous_frame - start_frame, int(world.get_runtime_evidence().recovery_count) - recoveries_before])
		return
	var manifest := {
		"schema_version": D2_MOTION_SCHEMA,
		"capture_date": "2026-09-05",
		"candidate_status": "uncommitted_production_candidate_pending_two_independent_audits",
		"review_status": "pending_independent_production_contract_and_visual_audits_not_self_accepted",
		"recognition_status": "uncredited_prepromotion_candidate_authority_remains_v8_8_of_213",
		"production_stage": "d2_1441_prepromotion_production_v8_uncommitted_candidate",
		"authoritative_candidate_packet": authoritative,
		"uncommitted_candidate": true,
		"pending_independent_contract_audit": true,
		"pending_independent_visual_review": true,
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
		"capture_time_recognition_metric": D2_CAPTURE_TIME_METRIC,
		"proof_role": "exact_consecutive_real_PlayerController_grounded_motion_telemetry",
		"generator": D2_GENERATOR_PATH.trim_prefix("res://"),
		"generator_sha256": FileAccess.get_sha256(D2_GENERATOR_PATH),
		"package_verification_receipt_sha256": _argument_value("--package-verification-receipt-sha256="),
		"source_dependency_hashes": D2_DEPENDENCY_HASHES.duplicate(true),
		"bindings": bindings,
		"production_path_observation": _d2_production_observation.duplicate(true),
		"runtime_topology": D2_PRODUCTION_WORLD.duplicate(true),
		"motion_pose": prepared.pose,
		"input_action": D2_MOTION_INPUT_ACTION,
		"run_action_pressed": false,
		"jetpack_action_pressed": false,
		"recovery_action_pressed": false,
		"input_baseline_engine_physics_frame": start_frame,
		"input_end_engine_physics_frame": start_frame + D2_MOTION_TELEMETRY_FRAMES,
		"input_elapsed_physics_ticks": D2_MOTION_TELEMETRY_FRAMES,
		"input_duration_seconds": float(D2_MOTION_TELEMETRY_FRAMES) / D2_PHYSICS_HZ,
		"input_sample_count": samples.size(),
		"physics_ticks_per_second": D2_PHYSICS_HZ,
		"start_position_m": _vector3(start_position),
		"input_end_position_m": _vector3(input_end_position),
		"start_chain_u_m": _d2_chain_u(start_position),
		"input_end_chain_u_m": input_end_u,
		"input_horizontal_displacement_m": Vector2(input_end_position.x - start_position.x, input_end_position.z - start_position.z).length(),
		"player_transform_writes": 0,
		"camera_transform_writes": 0,
		"sampler_phase": "dedicated_node_physics_callback_strictly_after_PlayerController",
		"sampler_priority_strictly_after_player": true,
		"all_input_samples_consecutive": true,
		"all_input_samples_grounded": true,
		"all_input_samples_in_boundary": true,
		"all_input_center_hits_exact_wall": true,
		"chain_u_monotonic_non_decreasing": true,
		"actual_signature_join_crossings": joins,
		"all_three_signature_joins_crossed": true,
		"braking_sample_count": braking.size(),
		"braking_samples_recorded_separately": true,
		"recovery_delta": 0,
		"samples": samples,
		"braking_samples": braking,
		"visual_verdict": "pending_independent_production_visual_review",
		"postcapture_catalog_or_registry_mutation": false,
	}
	if not _write_new_json(output_root.path_join("motion-telemetry.json"), manifest):
		_fail("Could not write D2 telemetry manifest without overwrite.")
		return
	if not _d2_validate_telemetry_stage(output_root, authoritative):
		_fail("D2 telemetry stage failed disk-roundtrip validation.")
		return
	print("PASS: recorded exactly 360 consecutive post-PlayerController ticks (6.0 seconds) plus 12 braking ticks across all three 1441 signature joins with zero transform writes/recoveries")


func _d2_capture_visual_motion(world: WorldLoader, player: PlayerController, hud: GameHUD, sun: DirectionalLight3D, bindings: Dictionary, output_root: String, authoritative: bool) -> void:
	sun.rotation_degrees = D2_DEFAULT_SUN
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_root.path_join("visual-motion-frames"))) != OK:
		_fail("Could not create D2 visual-motion directory.")
		return
	var prepared := await _d2_prepare_motion(world, player, hud)
	if not _require(bool(prepared.get("ok", false)), str(prepared.get("message", "D2 visual motion start failed."))):
		return
	var sampler := prepared.sampler as D21441PostPlayerSampler
	var baseline := prepared.baseline as Dictionary
	var thresholds := _d2_motion_thresholds()
	var pending_frames: Array[Dictionary] = []
	var recoveries_before := int(world.get_runtime_evidence().recovery_count)
	var camera_basis := player.get_camera().global_basis
	var start_position := player.global_position
	var start_frame := int(baseline.engine_physics_frame)
	var start_sequence := int(baseline.sampler_sequence_index)
	var release_sequence := start_sequence + D2_MOTION_TELEMETRY_FRAMES
	sampler.release_input_at_sequence(D2_MOTION_INPUT_ACTION, release_sequence)
	player.set_gameplay_enabled(true)
	Input.action_press(D2_MOTION_INPUT_ACTION)
	var next_threshold := 0
	var previous_u := _d2_chain_u(player.global_position)
	var last_frame := start_frame
	while int(sampler.latest_snapshot.get("sampler_sequence_index", 0)) < release_sequence:
		var value: Variant = await sampler.post_player_physics_tick
		var snapshot := value as Dictionary
		var current_u := float(snapshot.get("chain_u_m", -INF))
		var state := _d2_motion_state(world, player, camera_basis, recoveries_before, previous_u, Input.is_action_pressed(D2_MOTION_INPUT_ACTION))
		if not _d2_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_d2_stop_sampler(player, sampler)
			_fail("D2 visual motion state drifted: %s" % state)
			return
		if next_threshold < thresholds.size() and current_u >= float((thresholds[next_threshold] as Dictionary).trigger_u_m):
			var threshold := thresholds[next_threshold] as Dictionary
			var trigger_frame := int(snapshot.engine_physics_frame)
			var trigger_sequence := int(snapshot.sampler_sequence_index)
			await RenderingServer.frame_post_draw
			var actual := sampler.latest_snapshot.duplicate(true)
			var staged := _d2_stage_motion_frame(threshold, trigger_frame, trigger_sequence, current_u, actual)
			if not _require(bool(staged.get("ok", false)), str(staged.get("message", "D2 motion frame failed."))):
				_d2_stop_sampler(player, sampler)
				return
			pending_frames.append(staged)
			next_threshold += 1
		previous_u = current_u
		last_frame = int(snapshot.engine_physics_frame)
	# The sampler released the action after PlayerController processed exactly
	# the 360th input tick, even when post-draw image waits skipped signal reads.
	if Input.is_action_pressed(D2_MOTION_INPUT_ACTION):
		_d2_stop_sampler(player, sampler)
		_fail("D2 visual sampler did not release input at exact sequence.")
		return
	var input_end_position := player.global_position
	var input_end_u := _d2_chain_u(input_end_position)
	var braking: Array[Dictionary] = []
	var braking_target := release_sequence + D2_MOTION_BRAKING_FRAMES
	while int(sampler.latest_snapshot.get("sampler_sequence_index", 0)) < braking_target:
		var value: Variant = await sampler.post_player_physics_tick
		var snapshot := value as Dictionary
		var state := _d2_motion_state(world, player, camera_basis, recoveries_before, previous_u, false)
		if not _d2_snapshot_matches(snapshot, player) or not bool(state.get("ok", false)):
			_d2_stop_sampler(player, sampler)
			_fail("D2 visual braking state drifted: %s" % state)
			return
		var metadata := state.metadata as Dictionary
		metadata["sampler_sequence_index"] = int(snapshot.sampler_sequence_index)
		metadata["engine_physics_frame"] = int(snapshot.engine_physics_frame)
		braking.append(metadata)
		previous_u = float(metadata.chain_u_m)
		last_frame = int(snapshot.engine_physics_frame)
	_d2_stop_sampler(player, sampler)
	if pending_frames.size() != 21 or next_threshold != thresholds.size() \
	or input_end_u <= D2_MOTION_JOIN_U_M[-1] \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		_fail("D2 visual-motion pre-encoding closure failed: pending=%d/%d end_u=%.3f recovery=%d" % [pending_frames.size(), thresholds.size(), input_end_u, int(world.get_runtime_evidence().recovery_count) - recoveries_before])
		return
	var written := _d2_write_motion_frames(output_root, pending_frames)
	if not _require(bool(written.get("ok", false)), str(written.get("message", "D2 deferred motion-frame write failed."))):
		return
	var captures: Array[Dictionary] = []
	for value: Variant in written.get("captures", []):
		if not value is Dictionary:
			_fail("D2 deferred motion-frame write returned invalid metadata.")
			return
		captures.append(value as Dictionary)
	var brackets := _d2_visual_join_brackets(captures)
	var unique := _d2_visual_unique(captures)
	if captures.size() != 21 \
	or not bool(brackets.get("ok", false)) or not bool(unique.get("ok", false)) \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before:
		_fail("D2 visual-motion closure failed: captures=%d/%d end_u=%.3f brackets=%s unique=%s recovery=%d" % [captures.size(), thresholds.size(), input_end_u, brackets, unique, int(world.get_runtime_evidence().recovery_count) - recoveries_before])
		return
	var manifest := {
		"schema_version": D2_VISUAL_SCHEMA,
		"capture_date": "2026-09-05",
		"candidate_status": "uncommitted_production_candidate_pending_two_independent_audits",
		"review_status": "pending_independent_production_contract_and_visual_audits_not_self_accepted",
		"recognition_status": "uncredited_prepromotion_candidate_authority_remains_v8_8_of_213",
		"production_stage": "d2_1441_prepromotion_production_v8_uncommitted_candidate",
		"authoritative_candidate_packet": authoritative,
		"uncommitted_candidate": true,
		"pending_independent_contract_audit": true,
		"pending_independent_visual_review": true,
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
		"capture_time_recognition_metric": D2_CAPTURE_TIME_METRIC,
		"proof_role": "post_draw_real_controller_far_mid_near_and_three_signature_join_visual_evidence",
		"generator": D2_GENERATOR_PATH.trim_prefix("res://"),
		"generator_sha256": FileAccess.get_sha256(D2_GENERATOR_PATH),
		"package_verification_receipt_sha256": _argument_value("--package-verification-receipt-sha256="),
		"source_dependency_hashes": D2_DEPENDENCY_HASHES.duplicate(true),
		"bindings": bindings,
		"production_path_observation": _d2_production_observation.duplicate(true),
		"runtime_topology": D2_PRODUCTION_WORLD.duplicate(true),
		"motion_pose": prepared.pose,
		"visual_fixed_fps_operator_request": D2_VISUAL_FIXED_FPS,
		"fixed_fps_receipt_argument": _argument_value("--fixed-fps-receipt="),
		"fixed_fps_receipt_is_operator_invocation_disclosure_not_engine_observation": true,
		"input_action": D2_MOTION_INPUT_ACTION,
		"input_baseline_engine_physics_frame": start_frame,
		"input_baseline_sampler_sequence_index": start_sequence,
		"input_release_sampler_sequence_index": release_sequence,
		"input_elapsed_physics_ticks": D2_MOTION_TELEMETRY_FRAMES,
		"input_duration_seconds": float(D2_MOTION_TELEMETRY_FRAMES) / D2_PHYSICS_HZ,
		"start_position_m": _vector3(start_position),
		"input_end_position_m": _vector3(input_end_position),
		"start_chain_u_m": _d2_chain_u(start_position),
		"input_end_chain_u_m": input_end_u,
		"input_horizontal_displacement_m": Vector2(input_end_position.x - start_position.x, input_end_position.z - start_position.z).length(),
		"player_transform_writes": 0,
		"camera_transform_writes": 0,
		"sampler_phase": "dedicated_node_physics_callback_strictly_after_PlayerController",
		"sampler_priority_strictly_after_player": true,
		"thresholds_are_triggers_not_claimed_positions": true,
		"dense_frame_thresholds": thresholds,
		"dense_visual_frames": captures,
		"dense_visual_frame_count": captures.size(),
		"all_frames_queried_after_frame_post_draw": true,
		"all_frames_state_matches_latest_post_player_sampler": true,
		"all_images_copied_in_memory_before_next_physics_await": true,
		"png_encoding_deferred_until_after_input_release_and_braking": true,
		"png_encoding_or_file_write_during_live_input_loop": false,
		"all_frame_hashes_and_engine_frames_unique": true,
		"actual_signature_join_brackets": brackets.joins,
		"all_three_signature_joins_bracketed": true,
		"far_mid_near_frames_present": true,
		"braking_sample_count": braking.size(),
		"braking_samples_recorded_separately": true,
		"braking_samples": braking,
		"last_observed_engine_physics_frame": last_frame,
		"recovery_delta": 0,
		"visual_verdict": "pending_independent_production_visual_review",
		"postcapture_catalog_or_registry_mutation": false,
	}
	if not _write_new_json(output_root.path_join("visual-motion.json"), manifest):
		_fail("Could not write D2 visual-motion manifest without overwrite.")
		return
	if not _d2_validate_complete_packet(output_root, authoritative):
		_fail("D2 visual stage failed complete disk-roundtrip validation.")
		return
	print("PASS: captured 21 unique post-draw D2 visual frames including far/mid/near and five actual before/after frames at each of three signature joins; input released after exactly 360 ticks")


func _d2_prepare_motion(world: WorldLoader, player: PlayerController, hud: GameHUD) -> Dictionary:
	if Engine.physics_ticks_per_second != D2_PHYSICS_HZ:
		return {"ok": false, "message": "D2 motion physics tick rate is not exactly 60 Hz."}
	var requested := Vector2(D2_MOTION_CHAIN_START.x, D2_MOTION_CHAIN_START.z)
	var pose := await _d2_input_travel_to(world, player, hud, requested, Vector3(D2_MOTION_WALL_START.x, 6.36, D2_MOTION_WALL_START.z), "d2-1441-signature-motion-start", "ground")
	if not bool(pose.get("ok", false)):
		return pose
	# The input-only transit may stop within its truthful two-metre tolerance,
	# so re-aim from the achieved ground pose along the exact facade normal.
	# This keeps move_right aligned to the public tangent without writing either
	# the player or camera transform.
	var tangent_aim_target := player.global_position - D2_PUBLIC_OUTWARD * 40.0
	var tangent_aim := await _d2_input_aim(player, tangent_aim_target, true)
	if not bool(tangent_aim.get("ok", false)):
		return {"ok": false, "message": "D2 motion tangent input aim failed: %s" % tangent_aim}
	var los := _d2_center_los(player, D2_WALL_KEY, D2_SOURCE_KEY, "d2-1441-signature-motion-start")
	if not bool(los.get("ok", false)):
		return los
	var rig := player.get_node("CameraPivot") as PlayerCamera
	var right_dot := rig.planar_right().dot(D2_PUBLIC_TANGENT)
	if right_dot < 0.995:
		return {"ok": false, "message": "D2 motion camera right does not align positive public tangent: %.6f." % right_dot}
	var sampler := D21441PostPlayerSampler.new()
	sampler.name = "D21441PostPlayerPhysicsSampler"
	sampler.configure(player, D2_MOTION_CHAIN_START, D2_PUBLIC_TANGENT)
	if sampler.process_physics_priority <= player.process_physics_priority:
		sampler.queue_free()
		return {"ok": false, "message": "D2 sampler priority is not after PlayerController."}
	player.get_parent().add_child(sampler)
	player.set_gameplay_enabled(true)
	var baseline_value: Variant = await sampler.post_player_physics_tick
	var baseline := baseline_value as Dictionary
	player.set_gameplay_enabled(false)
	if not _d2_snapshot_matches(baseline, player) or absf(_d2_chain_u(player.global_position)) > 2.0:
		sampler.queue_free()
		return {"ok": false, "message": "D2 motion baseline is not coherent/near chain start: %s u=%.3f." % [baseline, _d2_chain_u(player.global_position)]}
	var metadata := pose.metadata as Dictionary
	metadata.merge(los.metadata as Dictionary, true)
	metadata["camera_planar_right_dot_public_tangent"] = right_dot
	metadata["motion_tangent_input_aim"] = tangent_aim
	metadata["motion_tangent_aim_target_m"] = _vector3(tangent_aim_target)
	metadata["motion_chain_start_m"] = _vector3(D2_MOTION_CHAIN_START)
	metadata["motion_wall_start_m"] = _vector3(D2_MOTION_WALL_START)
	return {"ok": true, "sampler": sampler, "baseline": baseline, "pose": metadata}


func _d2_motion_state(world: WorldLoader, player: PlayerController, camera_basis: Basis, recoveries_before: int, previous_u: float, input_expected: bool) -> Dictionary:
	var u := _d2_chain_u(player.global_position)
	var collider := _d2_camera_spray_collider(player)
	var input_pressed := Input.is_action_pressed(D2_MOTION_INPUT_ACTION)
	if not player.is_on_floor() or not world.get_boundary().contains_position(player.global_position) \
	or input_pressed != input_expected \
	or Input.is_action_pressed("run") or Input.is_action_pressed("jetpack") or Input.is_action_pressed("recover") \
	or not player.get_camera().global_basis.is_equal_approx(camera_basis) \
	or int(world.get_runtime_evidence().recovery_count) != recoveries_before \
	or u < previous_u - 0.0001 \
	or collider == null or str(collider.get_meta("derived_object_key", "")) != D2_WALL_KEY \
	or collider.get_meta("source_keys", []) != [D2_SOURCE_KEY]:
		return {"ok": false, "message": "u=%.3f grounded=%s boundary=%s input=%s recovery=%d collider=%s" % [u, player.is_on_floor(), world.get_boundary().contains_position(player.global_position), input_pressed, int(world.get_runtime_evidence().recovery_count) - recoveries_before, str(collider)]}
	return {"ok": true, "metadata": {
		"player_position_m": _vector3(player.global_position),
		"chain_u_m": u,
		"velocity_mps": _vector3(player.velocity),
		"grounded": true,
		"in_boundary": true,
		"input_action_pressed": input_pressed,
		"run_action_pressed": false,
		"jetpack_action_pressed": false,
		"recovery_action_pressed": false,
		"center_spray_ray_receiver": D2_WALL_KEY,
		"center_spray_ray_sources": [D2_SOURCE_KEY],
		"camera_basis_unchanged": true,
		"recovery_delta": 0,
	}}


func _d2_snapshot_matches(snapshot: Dictionary, player: PlayerController) -> bool:
	var values := snapshot.get("player_position_m", []) as Array
	if values.size() != 3 or int(snapshot.get("engine_physics_frame", -1)) != Engine.get_physics_frames():
		return false
	var sampled := Vector3(float(values[0]), float(values[1]), float(values[2]))
	return sampled.is_equal_approx(player.global_position) and absf(float(snapshot.get("chain_u_m", INF)) - _d2_chain_u(player.global_position)) <= 0.0001


func _d2_stop_sampler(player: PlayerController, sampler: D21441PostPlayerSampler) -> void:
	Input.action_release(D2_MOTION_INPUT_ACTION)
	_clear_input()
	player.set_gameplay_enabled(false)
	if is_instance_valid(sampler):
		sampler.set_physics_process(false)
		sampler.queue_free()


func _d2_chain_u(position: Vector3) -> float:
	return Vector2(position.x - D2_MOTION_CHAIN_START.x, position.z - D2_MOTION_CHAIN_START.z).dot(Vector2(D2_PUBLIC_TANGENT.x, D2_PUBLIC_TANGENT.z))


func _d2_camera_spray_collider(player: PlayerController) -> CollisionObject3D:
	var camera := player.get_camera()
	var center := camera.get_viewport().get_visible_rect().size * 0.5
	var origin := camera.project_ray_origin(center)
	var direction := camera.project_ray_normal(center).normalized()
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 1000.0, D2_PHYSICS_SPRAY_SURFACE, [player.get_rid()])
	return player.get_world_3d().direct_space_state.intersect_ray(query).get("collider", null) as CollisionObject3D


func _d2_motion_thresholds() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for u: float in [1.0, 4.0, 7.0, 21.5, 22.4, 23.1]:
		result.append({"trigger_u_m": u, "role": "far_mid_near", "join_index": 0, "join_u_m": 0.0, "intended_join_offset_m": 0.0, "actual_trigger_tolerance_m": D2_VISUAL_TRIGGER_TOLERANCE_M})
	for join_index in D2_MOTION_JOIN_U_M.size():
		var join_u := D2_MOTION_JOIN_U_M[join_index]
		for offset: float in [-0.20, -0.07, 0.0, 0.07, 0.20]:
			result.append({"trigger_u_m": join_u + offset, "role": "signature_join_%d_adjacent" % (join_index + 1), "join_index": join_index + 1, "join_u_m": join_u, "intended_join_offset_m": offset, "actual_trigger_tolerance_m": D2_VISUAL_TRIGGER_TOLERANCE_M})
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool: return float(left.trigger_u_m) < float(right.trigger_u_m))
	for index in result.size():
		result[index]["index"] = index + 1
	return result


func _d2_stage_motion_frame(threshold: Dictionary, trigger_frame: int, trigger_sequence: int, trigger_u: float, actual: Dictionary) -> Dictionary:
	var actual_u := float(actual.get("chain_u_m", -INF))
	var deviation := actual_u - float(threshold.trigger_u_m)
	if deviation < -0.0001 or deviation > float(threshold.actual_trigger_tolerance_m):
		return {"ok": false, "message": "D2 visual frame %d escaped trigger tolerance: trigger=%.3f actual=%.3f." % [int(threshold.index), float(threshold.trigger_u_m), actual_u]}
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE:
		return {"ok": false, "message": "D2 motion image is empty or wrong-sized."}
	var relative := "visual-motion-frames/%02d-%s-u%05.2f.png" % [int(threshold.index), str(threshold.role), float(threshold.trigger_u_m)]
	return {"ok": true, "image": image, "metadata": {
		"index": int(threshold.index),
		"file": relative,
		"dimensions": [image.get_width(), image.get_height()],
		"role": str(threshold.role),
		"join_index": int(threshold.join_index),
		"join_u_m": float(threshold.join_u_m),
		"intended_join_offset_m": float(threshold.intended_join_offset_m),
		"threshold_trigger_u_m": float(threshold.trigger_u_m),
		"trigger_engine_physics_frame": trigger_frame,
		"trigger_sampler_sequence_index": trigger_sequence,
		"trigger_observed_u_m": trigger_u,
		"actual_engine_physics_frame": int(actual.get("engine_physics_frame", -1)),
		"actual_sampler_sequence_index": int(actual.get("sampler_sequence_index", -1)),
		"actual_player_position_m": actual.get("player_position_m", []),
		"actual_u_m": actual_u,
		"actual_join_offset_m": actual_u - float(threshold.join_u_m),
		"actual_minus_trigger_u_m": deviation,
		"actual_within_declared_trigger_tolerance": true,
		"state_queried_after_frame_post_draw": true,
		"actual_state_matches_latest_post_player_sampler": true,
		"image_copied_in_memory_before_next_physics_await": true,
		"png_encoded_after_input_release_and_braking": true,
	}}


func _d2_write_motion_frames(output_root: String, pending_frames: Array[Dictionary]) -> Dictionary:
	var captures: Array[Dictionary] = []
	for pending: Dictionary in pending_frames:
		var image := pending.get("image") as Image
		var metadata := (pending.get("metadata", {}) as Dictionary).duplicate(true)
		var relative := str(metadata.get("file", ""))
		var path := output_root.path_join(relative)
		if image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE:
			return {"ok": false, "message": "Deferred D2 motion image is empty or wrong-sized: %s." % relative}
		if FileAccess.file_exists(path) or image.save_png(path) != OK:
			return {"ok": false, "message": "Deferred D2 motion frame would overwrite or failed: %s." % relative}
		metadata["sha256"] = FileAccess.get_sha256(path)
		metadata["bytes"] = FileAccess.get_file_as_bytes(path).size()
		captures.append(metadata)
	return {"ok": true, "captures": captures}


func _d2_visual_join_brackets(captures: Array[Dictionary]) -> Dictionary:
	var result: Array[Dictionary] = []
	for join_index in 3:
		var members: Array[Dictionary] = []
		for capture: Dictionary in captures:
			if int(capture.join_index) == join_index + 1:
				members.append(capture)
		if members.size() != 5:
			return {"ok": false, "message": "Join %d has %d/5 images." % [join_index + 1, members.size()]}
		var before := 0
		var after := 0
		var offsets: Array[float] = []
		for member: Dictionary in members:
			var offset := float(member.actual_join_offset_m)
			offsets.append(offset)
			if offset < -0.02:
				before += 1
			if offset > 0.02:
				after += 1
		if before < 1 or after < 1:
			return {"ok": false, "message": "Join %d lacks actual before/after images: %s." % [join_index + 1, offsets]}
		result.append({"join_index": join_index + 1, "join_u_m": D2_MOTION_JOIN_U_M[join_index], "actual_offsets_m": offsets, "before_count": before, "after_count": after})
	return {"ok": true, "joins": result}


func _d2_visual_unique(captures: Array[Dictionary]) -> Dictionary:
	var frames := {}
	var hashes := {}
	var previous_frame := -1
	var previous_u := -INF
	for capture: Dictionary in captures:
		var frame := int(capture.actual_engine_physics_frame)
		var hash := str(capture.sha256)
		var u := float(capture.actual_u_m)
		if frames.has(frame) or hashes.has(hash) or frame <= previous_frame or u <= previous_u:
			return {"ok": false, "message": "Visual frames are not unique/ordered at %d." % int(capture.index)}
		frames[frame] = true
		hashes[hash] = true
		previous_frame = frame
		previous_u = u
	return {"ok": true}


func _d2_generator_matches() -> bool:
	var expected := _argument_value("--generator-sha256=")
	return _d2_lower_sha256(expected) and expected == FileAccess.get_sha256(D2_GENERATOR_PATH)


func _d2_visual_fixed_fps_receipt_matches() -> bool:
	return _argument_value("--fixed-fps-receipt=") == str(D2_VISUAL_FIXED_FPS)


func _d2_dependencies_match() -> bool:
	for path: String in D2_DEPENDENCY_HASHES:
		if FileAccess.get_sha256(path) != str(D2_DEPENDENCY_HASHES[path]):
			push_error("D2_1441_CAPTURE_DEPENDENCY: %s expected=%s actual=%s" % [path, D2_DEPENDENCY_HASHES[path], FileAccess.get_sha256(path)])
			return false
	return _d2_authority_is_exact()


func _d2_authority_is_exact() -> bool:
	var registry := _json(D2_REGISTRY_PATH)
	var contracts := _json(D2_CONTRACTS_PATH)
	var catalog := _json(D2_CATALOG_PATH)
	var metric := registry.get("recognition_metric", {}) as Dictionary
	var accepted := metric.get("accepted_physical_unit_ids", []) as Array
	var registry_unit := _d2_record_for(registry.get("units", []) as Array, "unit_id", "physical-building:w95934105")
	var catalog_unit := _d2_record_for(catalog.get("units", []) as Array, "unit_id", "physical-building:w95934105")
	var plans := contracts.get("plans", []) as Array
	var ready := plans.filter(func(value: Variant) -> bool: return str((value as Dictionary).get("integration_state", "")) == "package_safe_ready_for_integration")
	return str(registry.get("schema_version", "")) == "ti.facade-runtime-registry/8" \
		and str(catalog.get("schema_version", "")) == "ti.facade-recognition-catalog/8" \
		and str(contracts.get("schema_version", "")) == "ti.facade-runtime-adapter-contracts/7" \
		and str((registry.get("compatibility_contract", {}) as Dictionary).get("compiler_version", "")) == "1.7.0" \
		and str((registry.get("compatibility_contract", {}) as Dictionary).get("loader_api_version", "")) == "ti.facade-runtime-registry-loader/7" \
		and int(metric.get("numerator", -1)) == 8 and int(metric.get("denominator", -1)) == 213 and str(metric.get("display", "")) == D2_CAPTURE_TIME_METRIC \
		and accepted.size() == 8 and "physical-building:w95934105" not in accepted \
		and (registry.get("units", []) as Array).size() == 213 \
		and (registry.get("active_runtime_adapters", []) as Array).size() == 7 \
		and plans.size() == 16 and ready.size() == 10 \
		and registry_unit.get("active_runtime_adapter_ids", []) == [] \
		and str(registry_unit.get("runtime_content_mode", "")) == "all_receivers_generated_placeholder" \
		and (registry_unit.get("acceptance_records", []) as Array).is_empty() \
		and str((registry_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated" \
		and (catalog_unit.get("acceptance_records", []) as Array).is_empty() \
		and str((catalog_unit.get("claim_status", {}) as Dictionary).get("reference_recognizable", "")) == "not_evaluated"


func _d2_authority_receipt() -> Dictionary:
	return {
		"catalog_schema_version": "ti.facade-recognition-catalog/8",
		"runtime_registry_schema_version": "ti.facade-runtime-registry/8",
		"adapter_contracts_schema_version": "ti.facade-runtime-adapter-contracts/7",
		"loader_api_version": "ti.facade-runtime-registry-loader/7",
		"compiler_version": "1.7.0",
		"recognition_metric": D2_CAPTURE_TIME_METRIC,
		"accepted_physical_units": 8,
		"physical_unit_inventory": 213,
		"not_evaluated_physical_units": 205,
		"active_adapters": 7,
		"integration_plans": 16,
		"package_safe_ready_plans": 10,
		"disabled_plans": 6,
		"d2_1441_authority_mode": "all_receivers_generated_placeholder",
		"d2_1441_live_runtime_candidate_uncredited": true,
		"d2_1441_acceptance_records": 0,
		"d2_1441_active_authority_adapters": 0,
		"recognition_credit": false,
		"additional_recognition_credit": false,
		"promotion": false,
	}


func _d2_native_runtime_matches() -> bool:
	return str(Engine.get_version_info().get("string", "")).begins_with("4.7.2-stable") \
		and DisplayServer.get_name() == "macOS" \
		and str(RenderingServer.get_current_rendering_method()) == "forward_plus" \
		and str(RenderingServer.get_current_rendering_driver_name()) == "metal" \
		and str(RenderingServer.get_video_adapter_api_version()) == "4.0" \
		and str(RenderingServer.get_video_adapter_name()).begins_with("Apple M2") \
		and DisplayServer.window_get_size() == D2_STATIC_SIZE \
		and Vector2i(root.get_texture().get_size()) == D2_STATIC_SIZE \
		and Engine.physics_ticks_per_second == D2_PHYSICS_HZ \
		and not bool(ProjectSettings.get_setting("physics/common/physics_interpolation", false)) \
		and not is_physics_interpolation_enabled()


func _d2_override_matches() -> bool:
	return FileAccess.file_exists(D2_CAPTURE_OVERRIDE) \
		and FileAccess.get_sha256(D2_CAPTURE_OVERRIDE) == D2_CAPTURE_OVERRIDE_SHA256 \
		and int(ProjectSettings.get_setting("display/window/size/window_width_override", -1)) == D2_STATIC_SIZE.x \
		and int(ProjectSettings.get_setting("display/window/size/window_height_override", -1)) == D2_STATIC_SIZE.y


func _d2_receipt_argument_matches() -> bool:
	var path := _argument_value("--package-verification-receipt=")
	var expected := _argument_value("--package-verification-receipt-sha256=")
	if path.is_empty() or not path.is_absolute_path() or not FileAccess.file_exists(path) \
	or not _d2_lower_sha256(expected) or FileAccess.get_sha256(path) != expected:
		return false
	var receipt := _d2_json_absolute(path)
	return str(receipt.get("schema_version", "")) == D2_PACKAGE_RECEIPT_SCHEMA \
		and str(receipt.get("candidate_status", "")) == "uncommitted_production_candidate_pending_two_independent_audits" \
		and str(receipt.get("app_bundle_relative_path", "")) == D2_APP_BUNDLE_RELATIVE_PATH \
		and str(receipt.get("capture_time_recognition_metric", "")) == D2_CAPTURE_TIME_METRIC \
		and _d2_topology_values_match(receipt.get("runtime_topology", {})) \
		and _d2_receipt_target_binding_matches(receipt) \
		and not bool(receipt.get("recognition_credit", true)) \
		and not bool(receipt.get("additional_recognition_credit", true)) \
		and not bool(receipt.get("promotion", true)) \
		and not _d2_contains_absolute_path(receipt)


static func d2_receipt_target_payload_matches(receipt: Dictionary, expected_geometry_signature: String, expected_ownership_signature: String) -> bool:
	var target_value: Variant = receipt.get("d2_target")
	if not target_value is Dictionary:
		return false
	var target := target_value as Dictionary
	return target.size() == 12 \
		and str(target.get("canonical_name", "")) == "1441 Chinook Court" \
		and str(target.get("source_key", "")) == D2_SOURCE_KEY \
		and str(target.get("wall_object_key", "")) == D2_WALL_KEY \
		and str(target.get("roof_object_key", "")) == D2_ROOF_KEY \
		and str(target.get("physical_unit_id", "")) == "physical-building:w95934105" \
		and _d2_integer_sequence_matches(target.get("mapped_public_sse_runs"), D2_MAPPED_RUNS) \
		and _d2_integer_sequence_matches(target.get("protected_runs"), D2_PROTECTED_RUNS) \
		and target.get("confusion_set", []) == D2_CONFUSION_SOURCES \
		and str(target.get("geometry_signature", "")) == expected_geometry_signature \
		and str(target.get("live_ownership_signature", "")) == expected_ownership_signature \
		and str(target.get("wall_canonical_hash", "")) == D2_WALL_CANONICAL_SHA256 \
		and str(target.get("roof_canonical_hash", "")) == D2_ROOF_CANONICAL_SHA256


static func _d2_integer_sequence_matches(value: Variant, expected: Array[int]) -> bool:
	if not value is Array:
		return false
	var actual := value as Array
	if actual.size() != expected.size():
		return false
	for index in expected.size():
		var item: Variant = actual[index]
		if (not item is int and not item is float) or float(item) != float(expected[index]):
			return false
	return true


static func d2_visual_motion_payload_matches(payload: Dictionary) -> bool:
	var fixed_fps: Variant = payload.get("visual_fixed_fps_operator_request")
	var receipt: Variant = payload.get("fixed_fps_receipt_argument")
	var disclosure: Variant = payload.get("fixed_fps_receipt_is_operator_invocation_disclosure_not_engine_observation")
	var copied: Variant = payload.get("all_images_copied_in_memory_before_next_physics_await")
	var deferred: Variant = payload.get("png_encoding_deferred_until_after_input_release_and_braking")
	var live_write: Variant = payload.get("png_encoding_or_file_write_during_live_input_loop")
	return (fixed_fps is int or fixed_fps is float) and float(fixed_fps) == float(D2_VISUAL_FIXED_FPS) \
		and receipt is String and str(receipt) == str(D2_VISUAL_FIXED_FPS) \
		and disclosure is bool and bool(disclosure) \
		and copied is bool and bool(copied) \
		and deferred is bool and bool(deferred) \
		and live_write is bool and not bool(live_write)


func _d2_receipt_target_binding_matches(receipt: Dictionary) -> bool:
	var config := _json(D2_CONFIG_PATH)
	var target := config.get("target", {}) as Dictionary
	var reviewed_art := config.get("reviewed_art", {}) as Dictionary
	var adapter_source := FileAccess.get_file_as_string(D2_ADAPTER_PATH)
	var geometry_marker := 'const EXPECTED_GEOMETRY_SIGNATURE := "%s"' % D2_FROZEN_GEOMETRY_SIGNATURE
	var ownership_marker := 'const EXPECTED_LIVE_OWNERSHIP_SIGNATURE := "%s"' % D2_FROZEN_OWNERSHIP_SIGNATURE
	return str(reviewed_art.get("factory_geometry_signature", "")) == D2_FROZEN_GEOMETRY_SIGNATURE \
		and str(target.get("canonical_wall_record_sha256", "")) == D2_WALL_CANONICAL_SHA256 \
		and str(target.get("canonical_roof_record_sha256", "")) == D2_ROOF_CANONICAL_SHA256 \
		and adapter_source.count(geometry_marker) == 1 \
		and adapter_source.count(ownership_marker) == 1 \
		and d2_receipt_target_payload_matches(receipt, D2_FROZEN_GEOMETRY_SIGNATURE, D2_FROZEN_OWNERSHIP_SIGNATURE)


func _d2_topology_values_match(value: Variant) -> bool:
	if not value is Dictionary:
		return false
	var topology: Dictionary = value
	if topology.size() != D2_PRODUCTION_WORLD.size():
		return false
	for key in D2_PRODUCTION_WORLD:
		if not topology.has(key) or int(topology.get(key, -1)) != int(D2_PRODUCTION_WORLD[key]):
			return false
	return true


func _d2_receipt_from_argument() -> Dictionary:
	return _d2_json_absolute(_argument_value("--package-verification-receipt="))


func _d2_output_state_allows(mode: String, output_root: String) -> bool:
	var authoritative_root_absent := not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(D2_OUTPUT))
	if mode == "review-stills":
		return authoritative_root_absent and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(D2_REHEARSAL_OUTPUT))
	if mode == "stills":
		return authoritative_root_absent
	if mode in ["review-telemetry", "telemetry"]:
		return (authoritative_root_absent if mode == "review-telemetry" else true) \
			and _d2_validate_static_stage(output_root, mode == "telemetry", "static") \
			and not FileAccess.file_exists(output_root.path_join("motion-telemetry.json")) \
			and not FileAccess.file_exists(output_root.path_join("visual-motion.json"))
	if mode in ["review-motion", "visual-motion"]:
		return (authoritative_root_absent if mode == "review-motion" else true) \
			and _d2_validate_static_stage(output_root, mode == "visual-motion", "telemetry") \
			and _d2_validate_telemetry_stage(output_root, mode == "visual-motion", "telemetry") \
			and not FileAccess.file_exists(output_root.path_join("visual-motion.json")) \
			and not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(output_root.path_join("visual-motion-frames")))
	return false


func _d2_validate_static_stage(output_root: String, authoritative: bool, packet_stage: String = "static") -> bool:
	var manifest_path := output_root.path_join("capture-manifest.json")
	var manifest := _json(manifest_path)
	var captures := manifest.get("captures", []) as Array
	if str(manifest.get("schema_version", "")) != D2_STATIC_SCHEMA \
	or bool(manifest.get("authoritative_candidate_packet", not authoritative)) != authoritative \
	or bool(manifest.get("recognition_credit", true)) or bool(manifest.get("additional_recognition_credit", true)) or bool(manifest.get("promotion", true)) \
	or str(manifest.get("capture_time_recognition_metric", "")) != D2_CAPTURE_TIME_METRIC \
	or captures.size() != 14 \
	or FileAccess.get_sha256(output_root.path_join("capture-override.cfg")) != D2_CAPTURE_OVERRIDE_SHA256 \
	or FileAccess.get_sha256(output_root.path_join(D2_PACKAGE_RECEIPT_FILENAME)) != _argument_value("--package-verification-receipt-sha256=") \
	or _d2_contains_absolute_path(manifest):
		return false
	var expected := {}
	for file: String in D2_STILL_FILES:
		expected["images/%s" % file] = true
	for value: Variant in captures:
		if not value is Dictionary:
			return false
		var capture := value as Dictionary
		var relative := str(capture.get("file", ""))
		var path := output_root.path_join(relative)
		var image := Image.load_from_file(path)
		if not expected.has(relative) or image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE \
		or FileAccess.get_sha256(path) != str(capture.get("sha256", "")) \
		or FileAccess.get_file_as_bytes(path).size() != int(capture.get("bytes", -1)):
			return false
		expected.erase(relative)
	return expected.is_empty() and _d2_top_level_matches(output_root, packet_stage)


func _d2_validate_telemetry_stage(output_root: String, authoritative: bool, packet_stage: String = "telemetry") -> bool:
	if not _d2_validate_static_stage(output_root, authoritative, packet_stage):
		return false
	var manifest := _json(output_root.path_join("motion-telemetry.json"))
	return str(manifest.get("schema_version", "")) == D2_MOTION_SCHEMA \
		and bool(manifest.get("authoritative_candidate_packet", not authoritative)) == authoritative \
		and int(manifest.get("input_elapsed_physics_ticks", -1)) == D2_MOTION_TELEMETRY_FRAMES \
		and is_equal_approx(float(manifest.get("input_duration_seconds", -1.0)), 6.0) \
		and int(manifest.get("input_sample_count", -1)) == D2_MOTION_TELEMETRY_FRAMES \
		and (manifest.get("samples", []) as Array).size() == D2_MOTION_TELEMETRY_FRAMES \
		and int(manifest.get("braking_sample_count", -1)) == D2_MOTION_BRAKING_FRAMES \
		and (manifest.get("braking_samples", []) as Array).size() == D2_MOTION_BRAKING_FRAMES \
		and (manifest.get("actual_signature_join_crossings", []) as Array).size() == 3 \
		and not bool(manifest.get("recognition_credit", true)) \
		and not bool(manifest.get("promotion", true)) \
		and not _d2_contains_absolute_path(manifest) \
		and _d2_top_level_matches(output_root, packet_stage)


func _d2_validate_complete_packet(output_root: String, authoritative: bool) -> bool:
	if not _d2_validate_telemetry_stage(output_root, authoritative, "visual"):
		return false
	var visual := _json(output_root.path_join("visual-motion.json"))
	var captures := visual.get("dense_visual_frames", []) as Array
	if str(visual.get("schema_version", "")) != D2_VISUAL_SCHEMA \
	or bool(visual.get("authoritative_candidate_packet", not authoritative)) != authoritative \
	or int(visual.get("input_elapsed_physics_ticks", -1)) != D2_MOTION_TELEMETRY_FRAMES \
	or int(visual.get("dense_visual_frame_count", -1)) != 21 or captures.size() != 21 \
	or not d2_visual_motion_payload_matches(visual) \
	or (visual.get("actual_signature_join_brackets", []) as Array).size() != 3 \
	or not bool(visual.get("all_three_signature_joins_bracketed", false)) \
	or not bool(visual.get("far_mid_near_frames_present", false)) \
	or bool(visual.get("recognition_credit", true)) or bool(visual.get("additional_recognition_credit", true)) or bool(visual.get("promotion", true)) \
	or not _d2_lower_sha256(str(visual.get("generator_sha256", ""))) \
	or _d2_contains_absolute_path(visual):
		return false
	var seen := {}
	var thresholds := _d2_motion_thresholds()
	for index in captures.size():
		var value: Variant = captures[index]
		if not value is Dictionary:
			return false
		var capture := value as Dictionary
		var threshold := thresholds[index] as Dictionary
		var relative := str(capture.get("file", ""))
		var path := output_root.path_join(relative)
		var image := Image.load_from_file(path)
		var actual_u := float(capture.get("actual_u_m", -INF))
		var trigger_u := float(threshold.trigger_u_m)
		var deviation := actual_u - trigger_u
		if seen.has(relative) or image == null or image.is_empty() or image.get_size() != D2_STATIC_SIZE \
		or int(capture.get("index", -1)) != index + 1 \
		or str(capture.get("role", "")) != str(threshold.role) \
		or not is_equal_approx(float(capture.get("threshold_trigger_u_m", INF)), trigger_u) \
		or deviation < -0.0001 or deviation > D2_VISUAL_TRIGGER_TOLERANCE_M \
		or not bool(capture.get("actual_within_declared_trigger_tolerance", false)) \
		or not bool(capture.get("image_copied_in_memory_before_next_physics_await", false)) \
		or not bool(capture.get("png_encoded_after_input_release_and_braking", false)) \
		or FileAccess.get_sha256(path) != str(capture.get("sha256", "")) \
		or FileAccess.get_file_as_bytes(path).size() != int(capture.get("bytes", -1)):
			return false
		seen[relative] = true
	var files := _d2_recursive_files(output_root)
	return seen.size() == 21 and files.size() == 40 and _d2_top_level_matches(output_root, "visual")


func _d2_top_level_matches(output_root: String, stage: String) -> bool:
	var absolute := ProjectSettings.globalize_path(output_root)
	var files: Array[String] = []
	for value: String in DirAccess.get_files_at(absolute):
		files.append(value)
	var directories: Array[String] = []
	for value: String in DirAccess.get_directories_at(absolute):
		directories.append(value)
	var expected_files := ["capture-manifest.json", "capture-override.cfg", D2_PACKAGE_RECEIPT_FILENAME]
	var expected_directories := ["images"]
	if stage in ["telemetry", "visual"]:
		expected_files.append("motion-telemetry.json")
	if stage == "visual":
		expected_files.append("visual-motion.json")
		expected_directories.append("visual-motion-frames")
	files.sort()
	directories.sort()
	expected_files.sort()
	expected_directories.sort()
	return files == expected_files and directories == expected_directories


func _d2_recursive_files(output_root: String) -> Array[String]:
	var root_absolute := ProjectSettings.globalize_path(output_root)
	var result: Array[String] = []
	_d2_collect_files(root_absolute, root_absolute, result)
	result.sort()
	return result


func _d2_collect_files(root_absolute: String, directory: String, result: Array[String]) -> void:
	for file: String in DirAccess.get_files_at(directory):
		result.append(directory.path_join(file).trim_prefix(root_absolute + "/"))
	for child: String in DirAccess.get_directories_at(directory):
		_d2_collect_files(root_absolute, directory.path_join(child), result)


func _d2_copy_override(output_root: String) -> bool:
	var target := output_root.path_join("capture-override.cfg")
	if FileAccess.file_exists(target):
		return false
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(FileAccess.get_file_as_bytes(D2_CAPTURE_OVERRIDE))
	file.close()
	return FileAccess.get_sha256(target) == D2_CAPTURE_OVERRIDE_SHA256


func _d2_copy_receipt(output_root: String) -> bool:
	var source := _argument_value("--package-verification-receipt=")
	var target := output_root.path_join(D2_PACKAGE_RECEIPT_FILENAME)
	if not _d2_receipt_argument_matches() or FileAccess.file_exists(target):
		return false
	var file := FileAccess.open(target, FileAccess.WRITE)
	if file == null:
		return false
	file.store_buffer(FileAccess.get_file_as_bytes(source))
	file.close()
	return FileAccess.get_sha256(target) == _argument_value("--package-verification-receipt-sha256=")


func _write_new_json(path: String, value: Dictionary) -> bool:
	if FileAccess.file_exists(path):
		return false
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(value, "  ") + "\n")
	file.close()
	return true


func _d2_runtime_environment() -> Dictionary:
	return {
		"godot_version": Engine.get_version_info().get("string", "unknown"),
		"display_server": DisplayServer.get_name(),
		"rendering_method": str(RenderingServer.get_current_rendering_method()),
		"rendering_driver": str(RenderingServer.get_current_rendering_driver_name()),
		"video_adapter_api": str(RenderingServer.get_video_adapter_api_version()),
		"video_adapter": RenderingServer.get_video_adapter_name(),
		"native_window": [DisplayServer.window_get_size().x, DisplayServer.window_get_size().y],
		"viewport": [root.get_texture().get_width(), root.get_texture().get_height()],
		"physics_ticks_per_second": Engine.physics_ticks_per_second,
		"physics_interpolation_project_setting_effective": bool(ProjectSettings.get_setting("physics/common/physics_interpolation", false)),
		"scene_tree_physics_interpolation_enabled": is_physics_interpolation_enabled(),
	}


func _d2_record_for(records: Array, field: String, expected: String) -> Dictionary:
	for value: Variant in records:
		if value is Dictionary and str((value as Dictionary).get(field, "")) == expected:
			return value as Dictionary
	return {}


func _d2_json_absolute(path: String) -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return value as Dictionary if value is Dictionary else {}


func _d2_contains_absolute_path(value: Variant) -> bool:
	if value is String:
		var text := value as String
		return "/Volumes/" in text or "/Users/" in text or "file://" in text
	if value is Dictionary:
		for key: Variant in (value as Dictionary):
			if _d2_contains_absolute_path(key) or _d2_contains_absolute_path((value as Dictionary)[key]):
				return true
	if value is Array:
		for item: Variant in value as Array:
			if _d2_contains_absolute_path(item):
				return true
	return false


func _d2_lower_sha256(value: String) -> bool:
	if value.length() != 64 or value != value.to_lower():
		return false
	for index in value.length():
		if value[index] not in "0123456789abcdef":
			return false
	return true


func _d2_timeout() -> void:
	if not _finished:
		_fail("D2 1441 production evidence timed out after %.0f seconds." % D2_TIMEOUT_SECONDS)
		_finish(null)
