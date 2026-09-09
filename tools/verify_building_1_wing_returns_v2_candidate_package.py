#!/usr/bin/env python3
"""Candidate package gate. Does not claim historical smoke PASS or package-rendered pixels."""
from pathlib import Path
import argparse, hashlib, json, os, signal, subprocess, sys
import re

WORLD = r"MAC_EXPORT_WORLD_READY: hash=01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164 spawn=\(-104\.364,3\.457,786\.024\) yaw=-0\.119 chunks=38/38 coverage=735\+4 meshes=959 surfaces=974 triangles=70692 bodies=466 shapes=466 vegetation=124 seed=1414092337 batches=19 load_ms=([1-9][0-9]*)"
VISUAL = "MAC_EXPORT_VISUAL: ambient_source=2 ambient_color=(0.71,0.77,0.82,1.00) ambient_energy=0.65 sky_contribution=0.00 camera_pivot_y=2.00 spring_length=5.50 pitch=-8.0deg semantic_palette=pass"
MOVEMENT = "MAC_EXPORT_MOVEMENT: walk=4.0mps run=20.0mps acceleration=30.0mps2 braking=40.0mps2 defaults=pass"
HISTORICAL_FAILURE = "ERROR: MAC_EXPORT_SMOKE_FAIL: packaged ferry spawn, world counts, player gate, movement defaults, or visual defaults did not match the approved contract"

def parse(text, exit_code):
    if exit_code != 1:
        raise ValueError("Expected preserved historical smoke failure exit 1; never relabel smoke PASS")
    lines = [s.strip() for s in text.splitlines() if s.strip()]
    world = [s for s in lines if s.startswith("MAC_EXPORT_WORLD_READY:")]
    if len(world) != 1 or not (m := re.fullmatch(WORLD, world[0])):
        raise ValueError("Missing, duplicated, or changed release-world telemetry")
    if lines.count(VISUAL) != 1 or lines.count(MOVEMENT) != 1:
        raise ValueError("Visual or movement telemetry changed")
    if not 0 < int(m.group(1)) <= 30000:
        raise ValueError("World load did not finish inside the existing 30-second bound")
    failures = lines.count(HISTORICAL_FAILURE)
    if failures not in [1, 2]:
        raise ValueError("Expected preserved historical assertion failure is absent or duplicated unexpectedly")
    allowed = {world[0], VISUAL, MOVEMENT, HISTORICAL_FAILURE, "at: push_error (core/variant/variant_utility.cpp:1023)", "Godot Engine v4.7.2.stable.official.ed1daf0bf - https://godotengine.org"}
    if any(s not in allowed for s in lines):
        raise ValueError("Unexpected error, failure, or telemetry line")
    return {"scope": "release_world_ready_telemetry_only", "world": {"rows":735,"context_rows":4,"meshes":959,"surfaces":974,"triangles":70692,"bodies":466,"shapes":466}, "historical_smoke_exit": 1, "historical_smoke_status":"FAIL_RETAINED", "historical_smoke_jetpack_phase_reached":False, "load_ms":int(m.group(1))}

ROOT = Path(__file__).resolve().parents[1]
APP_REL = "build/building-1-wing-returns-v2-candidate-2026-09-08-001/Treasure Island First Playable.app"
APP_FILES = [{'path': 'Contents/Info.plist', 'sha256': '12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085', 'bytes': 1885}, {'path': 'Contents/MacOS/Treasure Island First Playable', 'sha256': '7d47d442cf8b19fab0e2628c79d7b5994961f8f2096b58046a14884e9f8f0af6', 'bytes': 170963648}, {'path': 'Contents/PkgInfo', 'sha256': '7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb', 'bytes': 9}, {'path': 'Contents/Resources/PrivacyInfo.xcprivacy', 'sha256': '0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3', 'bytes': 229}, {'path': 'Contents/Resources/Treasure Island First Playable.pck', 'sha256': '59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da', 'bytes': 66572928}, {'path': 'Contents/Resources/icon.icns', 'sha256': '779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a', 'bytes': 67500}, {'path': 'Contents/_CodeSignature/CodeResources', 'sha256': '214a827a4981045b58df046e7178f7e686573f57ee1d761d4bae1b3ac92f23cd', 'bytes': 3217}]
FROZEN = [{'path': 'game/resources/facades/building_1_public_front_believability.json', 'sha256': '99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb', 'bytes': 4104}, {'path': 'game/scripts/world/facades/building_1_hero_model.gd', 'sha256': 'ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a', 'bytes': 52707}, {'path': 'game/tests/headless_building_1_wing_returns_v2_contract.gd', 'sha256': '3189ccb938d12f86bd27fa7ac8beb7c412d74d60497cb678d89d48e4dad87e92', 'bytes': 42268}, {'path': 'game/tests/headless_building_1_hero_returns_v2_contract.gd', 'sha256': '77349b2d3126c6cb8115983c732a65e1cb038da8b34eb2ab6de37dd2d3d66de3', 'bytes': 25984}, {'path': 'game/tests/full_runtime_building_1_returns_v2_integration.gd', 'sha256': '4a245d32d1087662bc2b2dfc61a3882d2f084ee2747ed410c0f7a3a3009c5424', 'bytes': 57343}]
PINS = {
 "game/scripts/main.gd":"1c284eb4d8ee5954500fe36c3ab6845bc7233728da26f5f6848dd8de9a627232",
 "game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd":"658775e336ac1b582467b4327e34545f5b3bf665708834ef56853a9cfd792289",
 "game/tests/mounted_pck_content_audit.gd":"b28bcc1736e6bba7eefd1431cf839f7bae2d3da2355266df2e67b085cc32e464",
 ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot":"c7cccbf8fb143e34e02fd6521e09be2c2b974f0d5db080b19071c9c570718ccf",
 "evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md":"beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958"
}
PCK_SHA = "59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da"
MANIFEST_SHA = "e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3"
CONTENT_SHA = "01af105e30acd8fbddbb69ace1bffdefdf1174dd1f7ee8e66b1fc8808eee7164"

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def verify_inputs():
    app = ROOT / APP_REL
    files = sorted(p for p in app.rglob("*") if p.is_file())
    assert not any(p.is_symlink() for p in app.rglob("*")), "Bundle symlink"
    actual = [{"path": str(p.relative_to(app)), "sha256": sha(p), "bytes": p.stat().st_size} for p in files]
    assert actual == APP_FILES, "Exact seven-file bundle identity changed"
    for rel, expected in PINS.items():
        assert len(expected) == 64 and sha(ROOT / rel) == expected, rel
    for item in FROZEN:
        assert sha(ROOT / item["path"]) == item["sha256"], item["path"]
    material = "".join(f"{x['path']}|{x['sha256']}|{x['bytes']}\n" for x in actual)
    return {"files": actual, "bundle_identity_sha256": hashlib.sha256(material.encode()).hexdigest(), "pins": PINS, "frozen_source_inputs": FROZEN}

def run(command, cwd, log_path, timeout=90):
    assert not log_path.exists(), "Refuse log overwrite"
    print("RUN " + json.dumps(command), flush=True)
    p = subprocess.Popen(command, cwd=cwd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    live = {"pid": p.pid, "executable": str(Path(command[0]).resolve()), "command": command}
    print("OWNED_PROCESS " + json.dumps(live), flush=True)
    try:
        output, _ = p.communicate(timeout=timeout)
    except subprocess.TimeoutExpired:
        observed = subprocess.run(["/bin/ps", "-p", str(p.pid), "-o", "comm="], capture_output=True, text=True).stdout.strip()
        if observed == live["executable"]:
            p.terminate()
        output, _ = p.communicate(timeout=15)
        log_path.write_text(output)
        raise RuntimeError("Owned exact process timed out; package gate failed")
    log_path.write_text(output)
    return {**live, "exit": p.returncode, "terminal": True, "log": str(log_path), "log_sha256": sha(log_path), "output": output}

def successful(check, token):
    assert check["exit"] == 0, check["output"]
    assert check["output"].count(token) == 1, check["output"]
    assert not any(s in check["output"] for s in ["ERROR:", "SCRIPT ERROR", "world_failed"]), check["output"]

def self_test(log):
    text = log.read_text(); parse(text, 1)
    mutations = [("", 1), (text, 0), (text, 2), (text + "\nSCRIPT ERROR: unrelated\n", 1), (text + text, 1)]
    for a,b in [("triangles=70692","triangles=69252"),("coverage=735+4","coverage=734+4"),("chunks=38/38","chunks=37/38"),("bodies=466","bodies=465"),("shapes=466","shapes=465"),("meshes=959","meshes=958"),("surfaces=974","surfaces=973"),("semantic_palette=pass","semantic_palette=fail"),("defaults=pass","defaults=fail"),("hash=01af","hash=11af"),("yaw=-0.119","yaw=-0.118")]:
        mutations.append((text.replace(a,b),1))
    mutations.append((re.sub(r"load_ms=\d+", "load_ms=30001", text), 1))
    for t,e in mutations:
        try: parse(t,e)
        except ValueError: continue
        raise AssertionError("Mutated release telemetry was accepted")
    print(f"PASS: exact native telemetry plus {len(mutations)} negative controls; historical smoke remains FAIL_RETAINED")

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output-root", type=Path)
    parser.add_argument("--self-test-log", type=Path)
    args = parser.parse_args()
    if args.self_test_log:
        self_test(args.self_test_log); return
    out = args.output_root
    assert out and out.is_absolute() and not out.exists(), "Use a fresh absolute output directory"
    assert str(out).startswith("/private/tmp/"), "Package proof must remain outside the repository"
    out.mkdir(parents=True)
    before = verify_inputs()
    app = ROOT / APP_REL
    exe = app / "Contents/MacOS/Treasure Island First Playable"
    pck = app / "Contents/Resources/Treasure Island First Playable.pck"
    editor = ROOT / ".tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot"
    checks = {}
    checks["signature"] = run(["/usr/bin/codesign", "--verify", "--deep", "--strict", "--verbose=4", str(app)], out, out / "signature.log")
    assert checks["signature"]["exit"] == 0
    for name in ["Info.plist", "Resources/PrivacyInfo.xcprivacy"]:
        value = json.loads(subprocess.check_output(["/usr/bin/plutil", "-convert", "json", "-o", "-", str(app / "Contents" / name)]))
        if name == "Info.plist": assert value["CFBundleIdentifier"] == "local.treasure-island.first-playable"
        else: assert value == {"NSPrivacyTracking": False}
    contract = ROOT / "game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd"
    checks["mounted_components"] = run([str(editor), "--headless", "--main-pack", str(pck), "--script", str(contract), "--", "--candidate-pck=" + str(pck), "--candidate-pck-sha256=" + PCK_SHA], out, out / "mounted-components.log")
    successful(checks["mounted_components"], "PASS: mounted Building 1 wing-return v2 candidate PCK")
    privacy = ROOT / "game/tests/mounted_pck_content_audit.gd"
    checks["mounted_privacy"] = run([str(editor), "--headless", "--main-pack", str(pck), "--script", str(privacy), "--", "--pck-audit-pck=" + str(pck), "--pck-audit-pck-sha256=" + PCK_SHA, "--pck-audit-manifest-sha256=" + MANIFEST_SHA, "--pck-audit-content-sha256=" + CONTENT_SHA], out, out / "mounted-privacy.log")
    successful(checks["mounted_privacy"], "PASS: direct-mounted PCK matches")
    assert "private_paths=0 private_raw=0 banned=0" in checks["mounted_privacy"]["output"]
    native_log = out / "native-world-engine.log"
    checks["native_world"] = run([str(exe), "--headless", "--log-file", str(native_log), "--", "--mac-export-smoke"], out, out / "native-world-process.log")
    telemetry = parse(native_log.read_text(), checks["native_world"]["exit"])
    checks["native_world"]["engine_log"] = str(native_log)
    checks["native_world"]["engine_log_sha256"] = sha(native_log)
    self_test(native_log)
    after = verify_inputs()
    assert after == before, "Source or exact package changed during proof"
    receipt = {"schema_version": "ti.building-1-wing-returns-v2-candidate-package-proof/1", "status": "PASS_FOR_B1_RETURNS_V2_SOURCE_CAPTURE", "scope": "exact mounted components/materials/collision/D2/privacy plus signed-release native world-ready telemetry", "source_renders_are_package_pixels": False, "full_historical_smoke_pass": False, "unprinted_historical_predicates_independently_proven_by_native_log": False, "rejection_cause_claim": "historical combined oracle rejected; do not infer triangle count was its sole failing predicate", "postpromotion_full_current_release_smoke_required": True, "native_world_telemetry": telemetry, "inputs_before": before, "inputs_after": after, "verifier_path": str(Path(__file__).resolve()), "verifier_sha256": sha(Path(__file__)), "checks": checks, "all_owned_processes_terminal": True}
    receipt_path = out / "package-proof-receipt.json"
    receipt_path.write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n")
    print("PASS_FOR_B1_RETURNS_V2_SOURCE_CAPTURE " + str(receipt_path) + " SHA256=" + sha(receipt_path), flush=True)

if __name__ == "__main__":
    main()
