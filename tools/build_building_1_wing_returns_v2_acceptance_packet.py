#!/usr/bin/env python3
"""Build once, or read-only verify the exact accepted B1 return rehearsal packet.

This only copies reviewed evidence and records scoped acceptance. It does not
render, run Godot, modify authority, or confer release approval. Create mode
requires the retained private originals; normal verification is durable and
needs only this repository, never private scratch or an installed app.
"""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil

ROOT = Path(__file__).resolve().parent.parent
PACKET_ID = "building-1-wing-returns-v2-accepted-2026-09-08-001"
PACKET = ROOT / "evidence/first-playable" / PACKET_ID
SCHEMA = "ti.building-1-wing-returns-v2-acceptance/1"
RECEIPT = "rehearsal-verification-receipt.json"
RECEIPT_SHA = "cae3db47439fa0e4e70fdbb12a37daa7c431cd7bed6574433a701da740073bb0"
TREE_SHA = "5046e9bb1aaec4b79ecc0649087a33e54c6b87de291d1376ed3ad76bce7d6dff"
REUSE_SHA = "a95ceff16effb10ffe918349007539ce363de9434419ff96e1df5c0aec36ee11"
HANDOFF_SHA = "fd746ea5e2645b827e2b65af07d6f70713be5ce20a7da4061700c958ecddb725"
REVIEWS = [
    {"role": "source", "path": "evidence/reviews/building-1-wing-returns-v2-2026-09-08-INDEPENDENT_SOURCE_AUDIT.md", "sha256": "beced0b7bb42589a1214559e193855e46a90a1a0578f5e2a323995a9f2d77958", "token": "PASS_FOR_B1_RETURNS_V2_EVIDENCE_CAPTURE"},
    {"role": "mechanical", "path": "evidence/reviews/building-1-wing-returns-v2-rehearsal-2026-09-08-INDEPENDENT_MECHANICAL_AUDIT.md", "sha256": "63a3ca3368929982e82a74b2ed00a7afbf063c408e21acad2cc9ceed5fdcf13b", "token": "PASS_FOR_B1_RETURNS_V2_REHEARSAL_MECHANICS_ONLY"},
    {"role": "visual", "path": "evidence/reviews/building-1-wing-returns-v2-rehearsal-002-INDEPENDENT_VISUAL_AUDIT.md", "sha256": "98911852167577c750b6b75cb868e228a16f04c1d81e3827e43d5abc23a5c082", "token": "PASS_FOR_B1_RETURNS_V2_REHEARSAL_VISUAL_ONLY"},
]
SEALED = json.loads(r'''
{
  "source_inputs": [
    {
      "path": "game/resources/facades/building_1_public_front_believability.json",
      "sha256": "99117e1af118592db1d1cfa932b44014862cb8be4f47d0b3ea519e24f9e591fb",
      "bytes": 4104
    },
    {
      "path": "game/scripts/world/facades/building_1_hero_model.gd",
      "sha256": "ce2f21dab02163b5f45d9d7e457f5d0ce96089bc55cca6e65aa9924c9f199c5a",
      "bytes": 52707
    },
    {
      "path": "game/tests/headless_building_1_wing_returns_v2_contract.gd",
      "sha256": "3189ccb938d12f86bd27fa7ac8beb7c412d74d60497cb678d89d48e4dad87e92",
      "bytes": 42268
    },
    {
      "path": "game/tests/headless_building_1_hero_returns_v2_contract.gd",
      "sha256": "77349b2d3126c6cb8115983c732a65e1cb038da8b34eb2ab6de37dd2d3d66de3",
      "bytes": 25984
    },
    {
      "path": "game/tests/full_runtime_building_1_returns_v2_integration.gd",
      "sha256": "4a245d32d1087662bc2b2dfc61a3882d2f084ee2747ed410c0f7a3a3009c5424",
      "bytes": 57343
    }
  ],
  "proof_programs": [
    {
      "path": "game/tests/building_1_wing_returns_v2_candidate_capture.gd",
      "sha256": "667b7fde2844d798eb2d13cafaa0fbe802ada1239335c300df40c5e0f0a89fb2"
    },
    {
      "path": "game/tests/headless_building_1_wing_returns_v2_candidate_evidence_contract.gd",
      "sha256": "2e8d103f1db851d0a9dd3a16036abb52ab5e1ecaac24a49e2de9e6bcbfc05540"
    },
    {
      "path": "game/tests/headless_building_1_wing_returns_v2_candidate_package_contract.gd",
      "sha256": "658775e336ac1b582467b4327e34545f5b3bf665708834ef56853a9cfd792289"
    },
    {
      "path": "tools/verify_building_1_wing_returns_v2_candidate_package.py",
      "sha256": "c1abee8975c3ffab69ff00390a16b50712c364688b4cf4956bb798caaae18c7b"
    }
  ],
  "package_proof": {
    "schema_version": "ti.building-1-wing-returns-v2-candidate-package-proof/1",
    "scope": "exact mounted components/materials/collision/D2/privacy plus signed-release native world-ready telemetry",
    "status": "PASS_FOR_B1_RETURNS_V2_SOURCE_CAPTURE",
    "all_owned_processes_terminal": true,
    "full_historical_smoke_pass": false,
    "native_world_telemetry": {
      "historical_smoke_exit": 1,
      "historical_smoke_jetpack_phase_reached": false,
      "historical_smoke_status": "FAIL_RETAINED",
      "load_ms": 5571,
      "scope": "release_world_ready_telemetry_only",
      "world": {
        "bodies": 466,
        "context_rows": 4,
        "meshes": 959,
        "rows": 735,
        "shapes": 466,
        "surfaces": 974,
        "triangles": 70692
      }
    },
    "postpromotion_full_current_release_smoke_required": true,
    "rejection_cause_claim": "historical combined oracle rejected; do not infer triangle count was its sole failing predicate",
    "source_renders_are_package_pixels": false,
    "unprinted_historical_predicates_independently_proven_by_native_log": false,
    "verifier_sha256": "c1abee8975c3ffab69ff00390a16b50712c364688b4cf4956bb798caaae18c7b",
    "original_receipt_sha256": "20a54f0a274d1f750aa4d2c5d48cb6cde34c7b95357426b0766c4d1e7a0e0b04",
    "original_receipt_retained_privately": true,
    "original_receipt_copied_or_rewritten": false,
    "summary_is_not_original_receipt": true,
    "app_bundle_relative_path": "build/building-1-wing-returns-v2-candidate-2026-09-08-001/Treasure Island First Playable.app",
    "bundle_identity_algorithm": "relative_path|sha256|bytes\\n; bytewise_sorted_paths",
    "bundle_identity_sha256": "742f325cd7634d01474105f7c2e01b6f254d72385a78341768148b9b87fc2897",
    "bundle_inventory": [
      {
        "bytes": 1885,
        "path": "Contents/Info.plist",
        "sha256": "12210013168f4197b156c151636a81d27285741b3d2cdd138740d09853a9f085"
      },
      {
        "bytes": 170963648,
        "path": "Contents/MacOS/Treasure Island First Playable",
        "sha256": "7d47d442cf8b19fab0e2628c79d7b5994961f8f2096b58046a14884e9f8f0af6"
      },
      {
        "bytes": 9,
        "path": "Contents/PkgInfo",
        "sha256": "7e50a30efad50208a173203ced60818d693bb61266b75aa10927d1a2adce80cb"
      },
      {
        "bytes": 229,
        "path": "Contents/Resources/PrivacyInfo.xcprivacy",
        "sha256": "0535353bb08c25b8ce5ed9ac7e442a5994f402e0f6cbc4bed668cfc63c2ceac3"
      },
      {
        "bytes": 66572928,
        "path": "Contents/Resources/Treasure Island First Playable.pck",
        "sha256": "59b37cf856dd1ece6aaadeee5c6278327997394339bb8450253193cbd89728da"
      },
      {
        "bytes": 67500,
        "path": "Contents/Resources/icon.icns",
        "sha256": "779ff524928785811d6d4c61f47a26491160b1092db9b610e85fcdfd9b2d2b2a"
      },
      {
        "bytes": 3217,
        "path": "Contents/_CodeSignature/CodeResources",
        "sha256": "214a827a4981045b58df046e7178f7e686573f57ee1d761d4bae1b3ac92f23cd"
      }
    ],
    "checks": {
      "mounted_components": {
        "exit": 0,
        "log_sha256": "a7ad4164b156ba464cdc1438561529e1ee114df0ec539e44f92c0d5fedf097b5",
        "terminal": true
      },
      "mounted_privacy": {
        "exit": 0,
        "log_sha256": "d08ce279e963dd6bdff52fea1e4051d6eca7e15f6c4cc8c3c3076d07e8fbcc85",
        "terminal": true
      },
      "native_world": {
        "engine_log_sha256": "e64123331e21f9325a946154f740b231382e0a3a0b3a094b7d66efac7ddcf3bb",
        "exit": 1,
        "log_sha256": "91574a41b40b7530806601889453e7b9241b66b4e7dc1dba351e85f9134d5c58",
        "terminal": true
      },
      "signature": {
        "exit": 0,
        "log_sha256": "14668a870c61389ee04683b8f359c40f83b9e903fcbe0bfe7e0078e58058962b",
        "terminal": true
      }
    }
  }
}
''')


def require(condition, message):
    if not condition:
        raise ValueError(message)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def pinned_json(path, expected):
    require(path.is_file() and not path.is_symlink(), f"Missing or linked input: {path.name}")
    require(digest(path) == expected, f"Hash drift: {path.name}")
    return json.loads(path.read_text())


def safe_path(value):
    p = PurePosixPath(value)
    require(str(p) == value and not p.is_absolute() and ".." not in p.parts and "\\" not in value,
            f"Unsafe relative path: {value}")
    return value


def inventory(root):
    result = []
    for path in root.rglob("*"):
        require(not path.is_symlink(), "Packet contains a symlink")
        if path.is_file():
            result.append({"path": safe_path(path.relative_to(root).as_posix()),
                           "sha256": digest(path), "bytes": path.stat().st_size})
    return sorted(result, key=lambda entry: entry["path"].encode("utf-8"))


def tree(entries):
    material = "".join(f"{e['path']}|{e['sha256']}|{e['bytes']}\n" for e in entries)
    return hashlib.sha256(material.encode("utf-8")).hexdigest()


def validate_dependencies():
    for entry in SEALED["source_inputs"] + SEALED["proof_programs"] + REVIEWS:
        path = ROOT / safe_path(entry["path"])
        require(path.is_file() and not path.is_symlink(), f"Missing dependency: {entry['path']}")
        require(digest(path) == entry["sha256"], f"Dependency drift: {entry['path']}")
        if "bytes" in entry:
            require(path.stat().st_size == entry["bytes"], f"Dependency size: {entry['path']}")
        if "token" in entry:
            require(path.read_text().strip().splitlines()[-1] == entry["token"],
                    f"Review verdict drift: {entry['role']}")


def evidence_inputs(root):
    receipt = pinned_json(root / RECEIPT, RECEIPT_SHA)
    expected = receipt["input_inventory"]
    require(len(expected) == 98 and tree(expected) == TREE_SHA, "Frozen evidence inventory drift")
    require(sum(e["bytes"] for e in expected) == 70133929, "Frozen evidence byte total drift")
    actual = [e for e in inventory(root) if e["path"] not in [RECEIPT, "acceptance-receipt.json"]]
    require(actual == expected, "Evidence missing, changed, or added")
    require(sum(e["path"].endswith(".png") for e in actual) == 92, "PNG count drift")
    require(sum(e["path"].endswith(".json") for e in actual) == 6, "Manifest count drift")
    require(receipt["source_vs_package_provenance"]["render_source"] ==
            "exact_stage_source_checkouts_not_exported_PCKs", "Render provenance drift")
    for entry in actual:
        if entry["path"].endswith(".json"):
            check_sanitized((root / entry["path"]).read_text())
    check_sanitized((root / RECEIPT).read_text())
    return receipt


def motion_inputs(receipt):
    result = [e for e in receipt["input_inventory"]
              if "/motion/" in e["path"] or "/motion-" in e["path"]]
    require(len(result) == 52 and sum(e["path"].endswith(".png") for e in result) == 48,
            "Motion reuse inventory drift")
    return result


def check_sanitized(text):
    require(not re.search(r"/(?:Users|Volumes|private|tmp|home)/|file://|[A-Za-z]:\\", text),
            "Private absolute path in durable text")


def acceptance(receipt):
    return {
        "schema_version": SCHEMA,
        "packet_id": PACKET_ID,
        "pass_id": "building-1-wing-window-returns-v2-2026-09-08",
        "acceptance_date": "2026-09-08",
        "status": "accepted_scoped_wing_return_visual_improvement",
        "scope": "Local jamb and sill construction-depth improvement; whole-front gain is modest.",
        "recognition_credit_delta": 0,
        "recognition_metric": "9/213",
        "existing_building_1_and_tower_credit_preserved": True,
        "quality_floor_policy": "Substantive local improvement over accepted older assets; no comprehensive Building 1 redesign or new quality ceiling claimed.",
        "source_inputs": SEALED["source_inputs"],
        "proof_programs": SEALED["proof_programs"],
        "reviews": REVIEWS,
        "candidate_verification": {
            "path": RECEIPT, "sha256": RECEIPT_SHA,
            "candidate_packet_id": receipt["packet_id"],
            "input_tree_algorithm": "relative_path|sha256|bytes\n; bytewise_sorted_paths",
            "input_tree_sha256": TREE_SHA, "input_total_bytes": 70133929,
            "input_count": 98, "original_pngs": 92, "manifests": 6,
            "input_inventory": receipt["input_inventory"],
            "capture_time_candidate_labels_preserved": True,
            "receipt_copied_byte_identically": True,
        },
        "package_capture_handoff_sha256": HANDOFF_SHA,
        "package_proof": SEALED["package_proof"],
        "motion_reuse": {
            "original_provenance_sha256": REUSE_SHA,
            "source_rehearsal_id": "b1-returns-v2-rehearsal-001",
            "destination_rehearsal_id": "b1-returns-v2-rehearsal-002",
            "reason": "Reuse the valid paired motion evidence; recapture only the failed still pairing at fixed 60 FPS without changing tolerances or sealed programs.",
            "copied_original_motion_pngs": 48, "copied_original_motion_manifests": 4,
            "newly_captured_fixed60_still_pngs": 44, "newly_captured_still_manifests": 2,
            "failed_still_pair_original_bundle_preserved_at_acceptance": True,
            "copied_byte_identically": True, "files": motion_inputs(receipt),
        },
        "proof_boundaries": {
            "baseline_source_commit": "b4ab09356c8a15843fa295af024434f97027e1fe",
            "render_source": "exact_stage_source_checkouts_not_exported_PCKs",
            "source_renders_are_package_pixels": False,
            "sampled_motion_is_continuous_video": False,
            "ordinary_app_observation": "OS-visible no-argument window and clean log only; scoped screenshot capture failed, so no player-pixel or interaction claim follows.",
            "full_current_release_pass": False,
            "full_postpromotion_release_checks_required": True,
            "frozen_v1_remains_rejected": True,
            "new_authority_or_compiler_hashes_in_this_receipt": False,
            "dependency_direction": "frozen source and proof inputs, reviewed evidence and leaf reviews -> acceptance receipt -> downstream authority",
        },
        "receipt_generator": {
            "path": Path(__file__).resolve().relative_to(ROOT).as_posix(),
            "sha256": digest(Path(__file__)),
        },
    }


def encoded(value):
    return (json.dumps(value, indent=2, ensure_ascii=True) + "\n").encode("utf-8")


def verify():
    validate_dependencies()
    receipt = evidence_inputs(PACKET)
    expected = encoded(acceptance(receipt))
    require((PACKET / "acceptance-receipt.json").read_bytes() == expected,
            "Acceptance receipt differs from sealed scoped claims")
    check_sanitized(expected.decode())
    files = inventory(PACKET)
    require(len(files) == 100, "Durable packet must contain exactly 100 files")
    return {"status": "PASS_B1_RETURNS_V2_ACCEPTANCE_PACKET", "mode": "read_only_verify",
            "packet_path": PACKET.relative_to(ROOT).as_posix(),
            "file_count": len(files), "total_bytes": sum(e["bytes"] for e in files),
            "packet_tree_sha256": tree(files), "evidence_input_tree_sha256": TREE_SHA,
            "acceptance_receipt_path": (PACKET / "acceptance-receipt.json").relative_to(ROOT).as_posix(),
            "acceptance_receipt_sha256": digest(PACKET / "acceptance-receipt.json")}


def create(args):
    require(not PACKET.exists(), "Refusing to overwrite an existing durable packet")
    validate_dependencies()
    capture = Path(args.capture_root).resolve()
    receipt = evidence_inputs(capture)
    package = pinned_json(Path(args.package_receipt), SEALED["package_proof"]["original_receipt_sha256"])
    handoff = pinned_json(Path(args.handoff), HANDOFF_SHA)
    reuse = pinned_json(Path(args.motion_reuse), REUSE_SHA)
    require(package["inputs_before"] == package["inputs_after"], "Package inputs drifted during proof")
    require(package["inputs_before"]["files"] == SEALED["package_proof"]["bundle_inventory"], "App inventory differs")
    require(handoff["frozen_source_inputs"] == SEALED["source_inputs"], "Source handoff differs")
    reused = sorted(reuse["files"], key=lambda e: e["path"].encode("utf-8"))
    require(reused == motion_inputs(receipt), "Original motion reuse provenance differs")
    prior = Path(args.prior_motion_root).resolve()
    require(prior.name == "b1-returns-v2-rehearsal-001", "Wrong retained prior rehearsal")
    for entry in reused:
        path = prior / safe_path(entry["path"])
        require(path.is_file() and not path.is_symlink() and digest(path) == entry["sha256"]
                and path.stat().st_size == entry["bytes"], "Retained prior motion differs")
    app = ROOT / SEALED["package_proof"]["app_bundle_relative_path"]
    observed = inventory(app)
    require(observed == SEALED["package_proof"]["bundle_inventory"], "Candidate app bytes differ")
    require(tree(observed) == SEALED["package_proof"]["bundle_identity_sha256"], "Candidate app identity differs")
    payload = encoded(acceptance(receipt))
    check_sanitized(payload.decode())
    PACKET.mkdir(parents=True)
    for entry in receipt["input_inventory"] + [{"path": RECEIPT}]:
        rel = safe_path(entry["path"])
        target = PACKET / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(capture / rel, target)
    (PACKET / "acceptance-receipt.json").write_bytes(payload)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--create", action="store_true")
    for flag in ["capture-root", "package-receipt", "motion-reuse", "prior-motion-root", "handoff"]:
        parser.add_argument("--" + flag)
    args = parser.parse_args()
    if args.create:
        require(all(getattr(args, k) for k in ["capture_root", "package_receipt", "motion_reuse", "prior_motion_root", "handoff"]),
                "Create requires all five original provenance inputs")
        create(args)
    else:
        require(not any(getattr(args, k) for k in ["capture_root", "package_receipt", "motion_reuse", "prior_motion_root", "handoff"]),
                "Original provenance arguments apply only to --create")
    print(json.dumps(verify(), indent=2))


if __name__ == "__main__":
    main()
