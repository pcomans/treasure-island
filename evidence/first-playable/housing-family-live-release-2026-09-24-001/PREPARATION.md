# Shared-family batch release preparation

Adapted six-stage ordering from final-current-package-003. Product author owns the final live adoption validator and authority. This folder owns release execution only.

1. Source component: final shared adoption validator plus unchanged base registry/coverage checks.
2. Export the frozen checkout with existing macOS Private preset.
3. Mount exact exported PCK from runtime-001 outside the checkout; same adoption contract.
4. Existing mounted_pck_content_audit.gd with actual PCK hash and independently frozen generated manifest/content hashes.
5. Exact signed app headless smoke.
6. Exact signed app Metal/Forward+ smoke.

Do not run template directly. Final preparation supplies package-contract.gd, source-pins.json, final source/visual/mechanical decision paths, and run-plan.json after actual measured current topology/adoption binding. The old base-builder vector and new visible/active vector have different meanings; neither substitutes for the other. Keep 34/213 recognition credit and 24 enabled family units distinct.

Use one owned process at a time, fail dependent stages after error, retain terminal logs/status and release the process. After export, bind actual PCK hash into the plan and verify the whole app signature. Independent release review follows complete outputs before main publication or whole-app delivery. No source changes, signing settings or export defaults are made by this preparation.

Preparation review corrections: component/privacy/app stages require their producer PASS markers; no unused source-result JSON is declared. Final harness-pins.json binds run plan, settings, contract and both runners before/after stages. bind-export.py retains prior deep/strict and both-architecture signature checks, universal binary, empty entitlements, expected bundle identity, tracking=false and no quarantine. Mounted/app stages require the same full signed bundle hashes, sizes and modes before/after. Explicit engine logs are scanned alongside stdout. Final source-pins/readiness must bind the successful corrected native stage, not the failed007 aggregate result.

Final coverage: editor-mounted full-world attempts001/002 remain failed (startup timing, then intentional editor-only raw-source validation). The release template help exposes no external script/main-pack options, so no speculative external-script run is made. The existing signed headless smoke invokes the same fatal ADOPTION.validate_live on the exact app normal world and supplies packaged adoption evidence as well as smoke evidence. Mounted privacy still independently audits the same PCK; signed native smoke follows. No product change or re-export.
