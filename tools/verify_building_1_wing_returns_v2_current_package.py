#!/usr/bin/env python3
"""Exact current B1 package and complete internal headless/native release smoke; no pixel capture."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
APP_REL = "build/building-1-wing-returns-v2-current-2026-09-08-001/Treasure Island First Playable.app"
APP_FILES = [{'path': 'Contents/Info.plist', 'bytes': 1885, 'sha256': '12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085'}, {'path': 'Contents/MacOS/Treasure Island First Playable', 'bytes': 170963648, 'sha256': 'ac0aa612c576e039b04b743c2da5783fd0736a7312be4c88e31210b672845031'}, {'path': 'Contents/PkgInfo', 'bytes': 9, 'sha256': '7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb'}, {'path': 'Contents/Resources/PrivacyInfo.xcprivacy', 'bytes': 229, 'sha256': '0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3'}, {'path': 'Contents/Resources/Treasure Island First Playable.pck', 'bytes': 66600060, 'sha256': '454b913537742c8b605f41db8730c860de3ab37d08c4a3bfab5e15dc40f69403'}, {'path': 'Contents/Resources/icon.icns', 'bytes': 67500, 'sha256': '779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a'}, {'path': 'Contents/_CodeSignature/CodeResources', 'bytes': 3217, 'sha256': '864a2b44c7ef7a2dc739cfada1056edad99f06cd69e4c215abf3feae44496449'}]
FROZEN = [{'path': 'tools/build_facade_recognition_registry.mjs', 'sha256': '9b6ee97d19e069a0cfc0dc0e043e856e8618c407361b508527ce764b9a71be37'}, {'path': 'tools/test_facade_recognition_registry.mjs', 'sha256': '1765d01fe56bfbdf51682aabbf7d6d5d9e4cb497de3000b1b13cdeb02ace6ccf'}, {'path': 'tools/test_facade_runtime_loader_contract.mjs', 'sha256': 'aab19a319f0991e6ec5c7db20ef54a5a268da7be26edbc9afed9eff88c175873'}, {'path': 'game/scripts/world/facades/facade_runtime_registry_loader.gd', 'sha256': '6571e85914e604e16a8294cc8835dba033454907a3bc1da8bb9d9fd36e35789f'}, {'path': 'game/scripts/main.gd', 'sha256': 'a5cedea1c9861aca393787f7d1a26bfcee3a8a17b08ec4a8bd889fb79a2c7057'}, {'path': 'game/tests/headless_facade_recognition_registry_contract.gd', 'sha256': '83b0d1ddd4ef1faa75c00b41caa6c03b5fe3ac0f2914add7313454219284911f'}, {'path': 'game/tests/headless_facade_runtime_registry_loader_contract.gd', 'sha256': '079a8bd2986dd58d76ba47ccec124c29095e2438b837feb48a09ba43922339ed'}, {'path': 'game/tests/headless_precommit_package_sanitization_contract.gd', 'sha256': '7330126efdaaf46bd30d27a37e43f43559225e3f9b56336a01d812734bad4bfa'}, {'path': 'game/tests/headless_startup_configuration_contract.gd', 'sha256': '407663c24d8f5effc69f29976d0e4316bba144814498b30361e56d752461655e'}, {'path': 'game/tests/headless_building_1_wing_returns_v2_current_contract.gd', 'sha256': '6963ffa0775e1d2296afc73e899a8c1abbffcf3bd0e411da984d71fb7fe1cc7a'}, {'path': 'game/tests/README.md', 'sha256': '9b05319533eba23336fbb185e5b0635163a9d50c4fbd4a608fc5e71662255d6a'}, {'path': 'discovery/facades/facade-recognition-catalog.json', 'sha256': '6987ab1db4d58096ae9189803a48b8015dca8154a23b55470ab166af76a2d50c'}, {'path': 'discovery/facades/facade-recognition-catalog.schema.json', 'sha256': '2835742a7f54d4d70e7bc90ff739ce33350954cf9daa69eb01eb1e20588c4687'}, {'path': 'discovery/facades/facade-recognition-validation-report.json', 'sha256': 'bc2e6bb25f9de9c5c2007c51b3007c4da63081e32328bc9a99d1aed740448a3b'}, {'path': 'game/resources/facades/facade-runtime-registry.json', 'sha256': 'c6780895e339919f7ebe0900814afaa46fd15f31958946ec81b4391091a1d46f'}, {'path': 'game/resources/facades/facade-runtime-adapter-contracts.json', 'sha256': '24efc72b3315540f31dc112949ac108509cdc0e4eb9f5e20ef0d4b45ce41ac49'}, {'path': 'tools/build_building_1_wing_returns_v2_acceptance_packet.py', 'sha256': '1cb081a2c8aa755430cf40ceb681229b0023c424fa343f5080e84c84d3e64504'}, {'path': 'game/resources/facades/building_1_public_front_believability.json', 'sha256': '99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb'}, {'path': 'game/scripts/world/facades/building_1_hero_model.gd', 'sha256': 'ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a'}, {'path': 'game/tests/headless_building_1_wing_returns_v2_contract.gd', 'sha256': '3189ccb938d12f86bd27fa7ac8beb7c412d74d60497cb678d89d48e4dad87e92'}, {'path': 'game/tests/headless_building_1_hero_returns_v2_contract.gd', 'sha256': '77349b2d3126c6cb8115983c732a65e1cb038da8b34eb2ab6de37dd2d3d66de3'}, {'path': 'game/tests/full_runtime_building_1_returns_v2_integration.gd', 'sha256': '4a245d32d1087662bc2b2dfc61a3882d2f084ee2747ed410c0f7a3a3009c5424'}, {'path': 'game/resources/materials/world/building_1/building_1_blue_door.tres', 'sha256': '6554b282d6a77bcc50859b03eaea4889c18868d1f3a1580dbaa4bc2a9a6ff361'}, {'path': 'game/resources/materials/world/building_1/building_1_bluegrey_glass.tres', 'sha256': '41c1c31d4a78da25d4abfac59e82fe919fbb539afa479ab7601d0fb51939d59f'}, {'path': 'game/resources/materials/world/building_1/building_1_bronze.tres', 'sha256': '7948c9fca74345f4ff5e57a44191beb59300847b66cc54ddc176c5ca1b315ca3'}, {'path': 'game/resources/materials/world/building_1/building_1_canopy_underside.tres', 'sha256': '661a7b8cfaef2394e47a42f9bbd04df5fdfbb2cd4be9e6733d5bf3101817cea9'}, {'path': 'game/resources/materials/world/building_1/building_1_chain_metres_aperiodic_field.gdshader', 'sha256': 'a4a5df4fbb8fd4f13187ec284708879b540677ac2c827642b4c3040b4bce4c09'}, {'path': 'game/resources/materials/world/building_1/building_1_light_trim.tres', 'sha256': '6e543d57ff078c267e952f633f4cee232e0743e30218d2f341dc3f31e4a4c8d9'}, {'path': 'game/resources/materials/world/building_1/building_1_projecting_base_stone.tres', 'sha256': '8bdd85aa10ac78c9225c59aad5ed9d26266ae517ea3f5910b8be3daf41f131ab'}, {'path': 'game/resources/materials/world/building_1/building_1_reveal_shadow.tres', 'sha256': '2e1f36f163c037fe060a1ecfcdcc5dd062849290a96c508970384585b176e14a'}, {'path': 'game/resources/materials/world/building_1/building_1_roof_metal.tres', 'sha256': '8bee442442f8b7bc3004cd3f703ce4e21eb9bc3b1f4d3d8800b02a77268329c8'}, {'path': 'game/resources/materials/world/building_1/building_1_rose_base.tres', 'sha256': 'dd0ad6a95267c6be55ae415d8e044847b3ac53b7c1fceb823b12bb1a4fe44514'}, {'path': 'game/resources/materials/world/building_1/building_1_warm_ivory.tres', 'sha256': '572c3165cec91f74a49066873c31c071ae02333f85721bbd6b43981d814cdabb'}, {'path': 'game/resources/materials/world/building_1/building_1_warm_ivory_exact_trial.tres', 'sha256': '12d059d9d806c629225254f1aaf945be69a00ce5878db276ce299ad0c8cdbb9a'}, {'path': 'game/tests/full_runtime_integration.gd', 'sha256': 'c3dfefb96eac27b2cd0b73f97accdd6d333d1203115a4198de8302149044ed38'}, {'path': 'generated/world/chunks/x_-1__z_2.json', 'sha256': 'dab2fba3bc12f82ae84be88d54b01dbfe4f2ae20948e8776e59e01fc1c482dce'}, {'path': 'generated/world/chunks/x_0__z_2.json', 'sha256': '886f4e6ecfbf570dac9cb36f682a089a0cfe51b735692e3220df4d5b4ac3d7b6'}, {'path': 'game/resources/facades/d2_1441_chinook_live_replacement.json', 'sha256': 'aef5717332cda1cf2ba1457ce9e9e92aaaceae46345595a979813b9369ad8111'}, {'path': 'game/scripts/world/facades/d2_1441_chinook_live_replacement.gd', 'sha256': 'bf51562a211126c0ea7b631321dfb021171ad68bffd6dd07667ad504d770b9a1'}, {'path': 'game/scripts/world/world_chunk_builder.gd', 'sha256': '7107dc0789e8ca8ee13d53510293a39b3f64e9a92e0ee81bef7317d90a08a87a'}, {'path': 'game/resources/facades/building_1_hero_model.json', 'sha256': 'f10bc92a6e74cbae41347e742e6c68c50faccddbd52ab3ecce210ac8243bc6e9'}, {'path': 'game/tests/headless_building_1_public_front_believability_contract.gd', 'sha256': '0c73a6dbc9028b7a3cb7fac5e474f93b32cf823dc74a44aefba275723f1184e2'}, {'path': 'game/tests/headless_building_1_hero_model_contract.gd', 'sha256': '24831f23cad27004f36851d7dbbedd02ca607190b7543a2f378897e12ba31bf2'}, {'path': 'game/tests/building_1_wing_window_reveal_candidate_capture.gd', 'sha256': '20363d664e268e4760ba8d5817c71553a9237a6df442931185fdc69c752f05d4'}, {'path': 'game/tests/headless_building_1_wing_window_reveal_candidate_evidence_contract.gd', 'sha256': '0c60baadc8bbb218493c70275b97df5db7ccd074c1a58b043728db20216a6807'}, {'path': 'game/tests/headless_building_1_wing_window_reveal_candidate_package_contract.gd', 'sha256': 'fdf42f697312c0149ebbfbb385ece6cc2fa675f623769c4634f37e3311450190'}, {'path': 'evidence/reviews/building-1-wing-window-reveal-candidate-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md', 'sha256': 'c70a364dc90746f5e5b6f2e1021f68c8cd94dcc52761516538d19a3edaed24a0'}, {'path': 'evidence/reviews/building-1-wing-window-reveal-rehearsal-004-INDEPENDENT_MECHANICAL_AUDIT.md', 'sha256': 'b580e998d350f07368d73cc857f14872a254e99cc1d6aafed1b77add15a87271'}, {'path': 'evidence/reviews/building-1-wing-window-reveal-rehearsal-004-INDEPENDENT_VISUAL_HOLD.md', 'sha256': '26c1327118db37f18e7082c99bd9e0b4c96e76b97b30fb2a7f9fe5fd6c3edcba'}, {'path': 'game/tests/headless_d2_1441_postpromotion_v9_contract.gd', 'sha256': '64a7bdc8d770254df26a56b51493d9e8c7e29a1f786e2ed5888822b7747b870b'}, {'path': 'game/tests/headless_d2_1441_postpromotion_v9_package_contract.gd', 'sha256': '03a2276ec072a27ddc63ad1b0b8551a9c8e2d30586c317c67883b9b3f2965630'}]
PINS = {'project.godot': '305bfb3bf0493c485f48ea8a01d4effccb58d9dd74ad6dc9be78a64ed23981af', 'export_presets.cfg': 'e54969d6127ee55691113217e5129a7c5e9b3e841168a6b91f3fc74ba278456f', '.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot': 'c7cccbf8fb143e34e02fd6521e09be2c2b974f0d5db080b19071c9c570718ccf', 'game/tests/mounted_pck_content_audit.gd': 'b28bcc1736e6bba7eefd1431cf839f7bae2d3da2355266df2e67b085cc32e464', 'game/tests/headless_building_1_wing_returns_v2_current_package_contract.gd': '3fefb93de5bb6b5ac40f1e2ee82aba95c1426fe5a54d9aca3788b8f89dc5149c', 'game/tests/building_1_wing_returns_v2_candidate_capture.gd': '667b7fde2844d798eb2d13cafaa0fbe802ada1239335c300df40c5e0f0a89fb2', 'game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd': '658775e336ac1b582467b4327e34545f5b3bf665708834ef56853a9cfd792289', 'game/tests/headless_building_1_wing_returns_v2_candidate_evidence_contract.gd': '2e8d103f1db851d0a9dd3a16036abb52ab5e1ecaac24a49e2de9e6bcbfc05540', 'tools/verify_building_1_wing_returns_v2_candidate_package.py': 'c1abee8975c3ffab69ff00390a16b50712c364688b4cf4956bb798caaae18c7b'}
PCK_SHA = "454b913537742c8b605f41db8730c860de3ab37d08c4a3bfab5e15dc40f69403"
MANIFEST_SHA = "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
CONTENT_SHA = "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"
AUTHORITY_AUDIT = "evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_AUTHORITY_AUDIT.md"
AUTHORITY_SHA = "14b3e5e8b432b4feca522dd18b48d4a4bfbcd95f44e881ae381de39689f69469"
WORLD = r"MAC_EXPORT_WORLD_READY: hash=01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164 spawn=\(-104\.364,3\.457,786\.024\) yaw=-0\.119 chunks=38/38 coverage=735\+4 meshes=959 surfaces=974 triangles=70692 bodies=466 shapes=466 vegetation=124 seed=1414092337 batches=19 load_ms=([1-9][0-9]*)"
VISUAL = "MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass"
MOVEMENT = "MAC_EXPORT_MOVEMENT: walk=4.0mps run=20.0mps acceleration=30.0mps2 braking=40.0mps2 defaults=pass"
SUCCESS = "PASS: packaged main scene reached full world_ready, verified movement defaults, enabled the player, and exercised jetpack rise/slow descent"
NUMBER = r"(-?[0-9]+\.[0-9]{3})"


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def parse_smoke(text, exit_code):
    assert exit_code == 0, "Complete current smoke must exit zero"
    lines = [line.strip() for line in text.splitlines() if line.strip()]
    telemetry = [line for line in lines if line.startswith("MAC_EXPORT_") or line.startswith("PASS:")]
    assert len(telemetry) == 10, "Missing, duplicate or unexpected smoke phase"
    world = re.fullmatch(WORLD, telemetry[0])
    assert world and 0 < int(world[1]) <= 30000, "Exact full-world telemetry/load limit changed"
    assert telemetry[1:5] == [VISUAL, MOVEMENT, "MAC_EXPORT_JETPACK_PHASE: grounding_start", "MAC_EXPORT_JETPACK_PHASE: grounding_complete grounded=true"], "Defaults or successful player grounding changed"
    start = re.fullmatch(r"MAC_EXPORT_JETPACK_PHASE: ascent_start y=" + NUMBER, telemetry[5])
    ascent = re.fullmatch(r"MAC_EXPORT_JETPACK_PHASE: ascent_complete rise=" + NUMBER + " velocity=" + NUMBER, telemetry[6])
    threshold = re.fullmatch(r"MAC_EXPORT_JETPACK_PHASE: descent_threshold reached=true velocity=" + NUMBER, telemetry[7])
    jetpack = re.fullmatch(r"MAC_EXPORT_JETPACK: rise=" + NUMBER + "m ascent_velocity=" + NUMBER + "mps slow_descent=" + NUMBER + "m minimum_velocity=" + NUMBER + "mps", telemetry[8])
    assert start and ascent and threshold and jetpack and telemetry[9] == SUCCESS, "Complete player/jetpack phase sequence did not succeed"
    rise, velocity, descent, minimum = map(float, jetpack.groups())
    assert rise > 1.5 and 0.0 < velocity <= 5.01 and 0.1 < descent < 0.5 and -1.51 <= minimum < 0, "Jetpack measurements violate shipped contract"
    assert -1.51 <= float(threshold[1]) <= -1.45, "Slow descent threshold changed"
    assert abs(float(ascent[1]) - rise) <= 0.001 and abs(float(ascent[2]) - velocity) <= 0.001, "Jetpack phase/final telemetry disagree"
    for line in lines:
        if line in telemetry:
            continue
        if line == "Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org":
            continue
        if re.fullmatch(r"Metal .+ - Forward\+ - Using Device #0: Apple - .+", line):
            continue
        raise AssertionError("Unexpected smoke log line: " + line)
    return {"world": {"records": 735, "context_records": 4, "meshes": 959, "surfaces": 974, "triangles": 70692, "bodies": 466, "shapes": 466}, "world_load_ms": int(world[1]), "player_grounded": True, "jetpack_rise_m": rise, "jetpack_ascent_velocity_mps": velocity, "jetpack_slow_descent_m": descent, "jetpack_minimum_velocity_mps": minimum, "full_internal_smoke_pass": True, "telemetry": telemetry}


def parser_controls(text):
    parse_smoke(text, 0)
    mutations = [
        (text, 1),
        (text.replace(SUCCESS, ""), 0),
        (text + "\n" + SUCCESS, 0),
        (text.replace("triangles=70692", "triangles=69252"), 0),
        (text.replace(VISUAL, ""), 0),
        (text.replace("defaults=pass", "defaults=fail"), 0),
        (text.replace("grounded=true", "grounded=false"), 0),
        (text.replace("reached=true", "reached=false"), 0),
        (re.sub(r"load_ms=[0-9]+", "load_ms=30001", text), 0),
        (re.sub(r"rise=[0-9.]+m", "rise=1.000m", text), 0),
        (re.sub(r"ascent_velocity=[0-9.]+mps", "ascent_velocity=6.000mps", text), 0),
        (re.sub(r"slow_descent=[0-9.]+m", "slow_descent=0.050m", text), 0),
        (re.sub(r"minimum_velocity=-?[0-9.]+mps", "minimum_velocity=-2.000mps", text), 0),
        (text + "\nERROR: unrelated runtime error", 0),
        (text + "\nMAC_EXPORT_SMOKE_TIMEOUT: unfinished", 0),
        (text + "\nunrelated output", 0),
        (text.replace("MAC_EXPORT_WORLD_READY:", "MAC_EXPORT_WORLD_FAILED:"), 0),
    ]
    for changed, code in mutations:
        assert changed != text or code != 0, "Ineffective parser negative"
        try:
            parse_smoke(changed, code)
        except AssertionError:
            continue
        raise AssertionError("Invalid complete smoke was accepted")
    return len(mutations)


def verify_inputs():
    assert len(APP_FILES) == 7 and len(FROZEN) == 51 and PINS, "Current proof is not sealed"
    app = ROOT / APP_REL
    entries = sorted(app.rglob("*"))
    assert not any(path.is_symlink() for path in entries), "App symlink is forbidden"
    actual = [{"path": str(path.relative_to(app)), "bytes": path.stat().st_size, "sha256": sha(path)} for path in entries if path.is_file()]
    assert actual == APP_FILES, "Exact seven-file signed app identity changed"
    assert sha(ROOT / AUTHORITY_AUDIT) == AUTHORITY_SHA and "PASS_FOR_B1_RETURNS_V2_AUTHORITY_EXPORT" in (ROOT / AUTHORITY_AUDIT).read_text(), "Independent authority export gate changed"
    for item in FROZEN:
        assert re.fullmatch(r"[0-9a-f]{64}", item["sha256"]) and sha(ROOT / item["path"]) == item["sha256"], item["path"]
    for relative, expected in PINS.items():
        assert re.fullmatch(r"[0-9a-f]{64}", expected) and sha(ROOT / relative) == expected, relative
    assert any(item["sha256"] == PCK_SHA and item["path"].endswith(".pck") for item in actual), "Current PCK seal absent"
    identity = "".join(f"{item['path']}|{item['sha256']}|{item['bytes']}\n" for item in actual)
    return {"app_relative_path": APP_REL, "app_files": actual, "bundle_identity_algorithm": "relative_path|sha256|bytes\\n; bytewise_sorted_paths", "bundle_identity_sha256": hashlib.sha256(identity.encode()).hexdigest(), "frozen_authority_source_lineage": FROZEN, "proof_input_pins": PINS, "authority_audit_sha256": AUTHORITY_SHA, "verifier_sha256": sha(Path(__file__))}


def run(command, cwd, log, timeout=90):
    assert not log.exists(), "Refuse to overwrite a process log"
    print("START " + json.dumps(command), flush=True)
    started = time.time()
    process = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    observed = subprocess.run(["/bin/ps", "-p", str(process.pid), "-o", "comm="], capture_output=True, text=True).stdout.strip()
    exact = str(Path(command[0]).resolve())
    assert observed == exact or (not observed and process.poll() is not None), "Launched executable path mismatch"
    record = {"pid": process.pid, "command": command, "cwd": str(cwd), "executable": exact, "observed_executable": observed}
    (cwd / "live-process.json").write_text(json.dumps(record, indent=2) + "\n")
    try:
        output, _ = process.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        current = subprocess.run(["/bin/ps", "-p", str(process.pid), "-o", "comm="], capture_output=True, text=True).stdout.strip()
        if current == exact:
            process.terminate()
        output, _ = process.communicate(timeout=15)
        log.write_text(output)
        raise AssertionError("Exact owned process timed out; dependent package phase stopped")
    log.write_text(output)
    record.update(exit_code=process.returncode, terminal=True, elapsed_seconds=round(time.time() - started, 3), log=str(log), log_sha256=sha(log), output=output)
    (cwd / "live-process.json").write_text(json.dumps(record, indent=2) + "\n")
    print("END PID=%s exit=%s seconds=%s" % (process.pid, process.returncode, record["elapsed_seconds"]), flush=True)
    return record


def require_success(check, token=None):
    assert check["exit_code"] == 0, "Process failed: " + check["log"]
    assert not any(word in check["output"] for word in ["ERROR:", "SCRIPT ERROR", "world_failed", "MAC_EXPORT_SMOKE_FAIL", "MAC_EXPORT_SMOKE_TIMEOUT"]), "Runtime diagnostic in " + check["log"]
    if token:
        assert check["output"].count(token) == 1, "Expected unique PASS missing: " + check["log"]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root", required=True, type=Path)
    args = parser.parse_args()
    out = args.output_root
    assert out.is_absolute() and str(out).startswith("/private/tmp/") and not out.exists(), "Use a fresh source-free /private/tmp output directory"
    out.mkdir(parents=True)
    before = verify_inputs()
    assert not (out / "project.godot").exists() and not (out / "game").exists(), "Runtime directory contains a source checkout"
    app = ROOT / APP_REL
    executable = app / "Contents/MacOS/Treasure Island First Playable"
    pck = app / "Contents/Resources/Treasure Island First Playable.pck"
    editor = ROOT / ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
    checks = {}
    checks["signature"] = run(["/usr/bin/codesign", "--verify", "--deep", "--strict", "--verbose=4", str(app)], out, out / "signature.log")
    require_success(checks["signature"])
    checks["architectures"] = run(["/usr/bin/lipo", "-archs", str(executable)], out, out / "architectures.log")
    require_success(checks["architectures"])
    assert set(checks["architectures"]["output"].split()) == {"x86_64", "arm64"}, "Universal executable architectures changed"
    for label, relative in [("info", "Contents/Info.plist"), ("privacy", "Contents/Resources/PrivacyInfo.xcprivacy")]:
        checks["plist_" + label] = run(["/usr/bin/plutil", "-convert", "json", "-o", "-", str(app / relative)], out, out / ("plist-" + label + ".log"))
        require_success(checks["plist_" + label])
    info = json.loads(checks["plist_info"]["output"])
    privacy = json.loads(checks["plist_privacy"]["output"])
    assert info["CFBundleIdentifier"] == "local.treasure-island.first-playable" and privacy == {"NSPrivacyTracking": False}, "App identity/privacy manifest changed"
    component = ROOT / "game/tests/headless_building_1_wing_returns_v2_current_package_contract.gd"
    checks["mounted_current_graph"] = run([str(editor), "--headless", "--main-pack", str(pck), "--script", str(component), "--", "--current-pck=" + str(pck), "--current-pck-sha256=" + PCK_SHA], out, out / "mounted-current-graph.log")
    require_success(checks["mounted_current_graph"], "PASS: mounted Building 1 wing-return v2 current PCK")
    privacy_program = ROOT / "game/tests/mounted_pck_content_audit.gd"
    checks["mounted_privacy"] = run([str(editor), "--headless", "--main-pack", str(pck), "--script", str(privacy_program), "--", "--pck-audit-pck=" + str(pck), "--pck-audit-pck-sha256=" + PCK_SHA, "--pck-audit-manifest-sha256=" + MANIFEST_SHA, "--pck-audit-content-sha256=" + CONTENT_SHA], out, out / "mounted-privacy.log")
    require_success(checks["mounted_privacy"], "PASS: direct-mounted PCK matches")
    assert "private_paths=0 private_raw=0 banned=0" in checks["mounted_privacy"]["output"]
    smokes = {}
    for mode in ["headless", "native"]:
        engine_log = out / (mode + "-smoke-engine.log")
        command = [str(executable)] + (["--headless"] if mode == "headless" else []) + ["--log-file", str(engine_log), "--", "--mac-export-smoke"]
        check = run(command, out, out / (mode + "-smoke-process.log"))
        checks[mode + "_smoke"] = check
        require_success(check, SUCCESS)
        parsed = parse_smoke(engine_log.read_text(), check["exit_code"])
        assert parsed["telemetry"] == parse_smoke(check["output"], check["exit_code"])["telemetry"], "Process and engine logs disagree"
        parsed["negative_controls_rejected"] = parser_controls(engine_log.read_text())
        check.update(engine_log=str(engine_log), engine_log_sha256=sha(engine_log))
        smokes[mode] = parsed
    after = verify_inputs()
    assert before == after, "Current source/authority/app/proof identity changed during verification"
    receipt = {"schema_version": "ti.building-1-wing-returns-v2-current-package-proof/1", "status": "PASS_FOR_B1_RETURNS_V2_CURRENT_PACKAGE_REVIEW", "scope": "exact signed current package, mounted current B1/D2 graph/privacy and complete headless/native internal release smoke", "recognition_metric": "9/213", "recognition_credit_delta": 0, "source_render_evidence_is_package_pixels": False, "fresh_release_pixels_captured": False, "independent_package_review_required": True, "independent_release_visual_review_pending": True, "mounted_graph_boundary": "Exact runtime JSON plus exported remap-resolvable assets and instantiated B1/D2 geometry; executable source SHA fields are provenance, not a claim that compiled GDC bytes equal source text", "source_free_runtime_directory": str(out), "inputs_before": before, "inputs_after": after, "privacy_manifest": privacy, "checks": checks, "complete_internal_smokes": smokes, "all_owned_processes_terminal": True}
    receipt_path = out / "current-package-proof-receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print(receipt["status"] + " " + str(receipt_path) + " SHA256=" + sha(receipt_path), flush=True)


if __name__ == "__main__":
    main()
