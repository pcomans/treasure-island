# Facade recognition infrastructure

Checked: **2026-09-04**

This Phase 1 infrastructure creates a fail-closed data boundary for all physical
buildings in the frozen facade receiver inventory. It changes no world runtime
behavior and makes no new visual or whole-building acceptance claim.

## Canonical unit model

- **215 source records** are partitioned into **213 physical recognition
  units**.
- **212** units are standalone building footprints with one direct wall
  receiver each.
- Isle House is one composite recognition unit: parent `w1249412094` plus
  parts `w1282547786` and `w1282547787`, backed by the two part wall receivers.
- The units therefore own exactly **214 direct wall receivers** and **4,971
  visible wall runs** without double-counting either Isle House part as another
  building.

The authoring catalog is
[`facade-recognition-catalog.json`](facade-recognition-catalog.json), governed
by
[`facade-recognition-catalog.schema.json`](facade-recognition-catalog.schema.json).
It is pinned to the exact receiver-inventory and generated-world hashes. The
dependency-free validator applies the catalog to the complete local JSON
Schema semantics used here, including nested `additionalProperties`, enums,
cardinalities, uniqueness, and local `$ref` resolution. The compiler refuses a
changed source hash, missing or duplicate source/receiver, malformed wall-run
quad, changed composite relationship, invalid run, unknown claim status,
unsupported acceptance, unresolved schema reference, or source/package
boundary leak.

## Claim boundary

Every unit carries four independent statuses:

- `receiver_complete`: exact generated receiver binding only;
- `game_distinctive`: distinguishability inside this game;
- `reference_recognizable`: independent matching to target-identifiable
  reference evidence in an ordinary gameplay view;
- `as_built_fidelity`: a separate surveyed/as-built claim.

Phase 1 verifies `receiver_complete` for all 213 units and intentionally leaves
the other 639 unit-claim cells unaccepted: game distinctiveness and reference
recognition are `not_evaluated`, and as-built fidelity is `unclaimed`.
Addresses, names, fictional identifiers, source-key patterns, and
implementation metadata cannot satisfy `reference_recognizable` by
themselves.

Identity research is also kept separate from the frozen source seed. The
catalog's `identity_evidence_records` cite a primary source and a source-only
research packet, repeat the exact immutable field/value, state whether
currentness is claimed, and carry a separate evidenced value. The two seeded
NPS corrections therefore retain frozen `ref:nrhp=08000081` for Buildings 2
and 3 while recording `08000082` and `08000083`, respectively. The compiler
will fail if either frozen value is changed. Its runtime summaries contain the
old and evidenced values plus an explicit preservation flag, but no URL or
research path. A correction does not silently rewrite identity or claim that
the rest of the record is current.

Ten still-current independently accepted target-specific receiver adapters
are imported as `legacy_adapter` metadata. Their accepted exact-run scopes and
module counts are retained. Isle House is explicitly mixed: high part
`w1282547786` uses its legacy adapter while low part `w1282547787` remains a
generated placeholder, so the physical unit is never classified as wholly
adapted.

Building 1 main `r16681702` and observation tower `w1222720021` are two
separate physical units and two separate active receiver contracts. Both are
bound to the exact-current `building_1_hero_model.gd` dispatch, config, and
explicitly enumerated material set, with the tower remaining independently
reviewable. Building 3 `w34313540` is a third active receiver contract: its
package-safe plan pins the wall-and-roof massing wrapper/config, facade
script/scenes/layout/materials, collision congruence, wall-only spray ownership,
roof landing, and four deterministic geometry/facade signatures. Its historical
NPS URL remains byte-preserved in a discovery-only capture-source snapshot; the
executable config is semantically identical after removing only that URL. The obsolete
`building_1_recognizable_facade` claim is excluded. All 13 current adapters
still have `recognition_claim_effect: none` and
`whole_building_recognizability_imported: false`: active or accepted facade
content is not silently promoted into a whole-building recognition verdict.

Future facade batches add observed-region `reference_records`, receiver/run
bounded `recognition_cues`, protected scopes, and an ordinary-third-person
`capture_contract`. A reference-recognizable acceptance fails closed unless
every cue cites an observation, every cue is required by the configured
primary/alternate capture, and an independent reference-recognition review
accepts a hashed evidence manifest. Fictional signage, game-only color coding,
or other `game_distinctive` cues can never substitute for this gate. Complete
motifs cannot be tiled or clipped across arbitrary runs, and protected scopes
cannot be claimed as authored cues.

## Source and package boundary

The compiler reads source-only inventory and authoring records under
`discovery/`, then emits the standalone runtime-safe registry at
[`game/resources/facades/facade-runtime-registry.json`](../../game/resources/facades/facade-runtime-registry.json).
The emitted registry contains frozen source/receiver identities, generated
geometry hashes, claim states, accepted scope summaries, and only package-safe
`res://` asset hashes. Every textual asset is followed recursively through its
`res://` dependency closure. If that closure contains a `discovery/` or
`evidence/` path, reference URL, or absolute workstation path, the compiler
does not emit a runtime path: it emits only a pathless, hash-bound sanitized
metadata projection and marks that adapter as still needing a package-safe
integration. The source-side report retains the diagnostic path/violation
details. The current audit partitions 53 unique direct inputs into 41 clean
runtime references and 12 sanitized projections; all emitted runtime reference
closures are clean. Future configured ordinary-player poses and
receiver/run-bounded cue summaries are compiled there too, so a capture
harness or generic facade runtime never has to discover authoring files.

The compiler's exact result is recorded in
[`facade-recognition-validation-report.json`](facade-recognition-validation-report.json).
That source-side report lists all 61 units that currently lack both name and
address evidence. Work may continue on reference-ready units. After a bounded
autonomous identity/reference attempt, only a dependency that genuinely needs
owner evidence belongs in `HUMAN.md`; it blocks that unit, not other batches.
Per-building report records stay compact: hashes and receiver/run/cue IDs are
the durable ledger, while reference pixels and review captures remain in their
source/evidence manifests rather than being duplicated into the catalog or
runtime package.

## Build and checks

The one-time seed command refuses to overwrite an existing catalog:

```sh
node tools/build_facade_recognition_registry.mjs --seed-catalog --write
```

Normal authored changes use the existing catalog and regenerate only the
runtime registry and validation report:

```sh
node tools/build_facade_recognition_registry.mjs --write
node tools/build_facade_recognition_registry.mjs --check
node tools/test_facade_recognition_registry.mjs
.tools/godot/4.7.2/Godot.app/Contents/MacOS/Godot \
  --headless --path . \
  --script game/tests/headless_facade_recognition_registry_contract.gd
```

`--check` performs no writes and requires checked-in generated bytes to equal a
fresh compile. The Node test independently checks unit/source/receiver
partitions, run topology, schema application, claim neutrality, exact-current
Building 1 dispatch, complete Building 3 wall/roof parity, Isle House receiver state, recursive package closures,
runtime asset hashes, mutation failures for each repaired defect, and two
in-memory serializations. The Godot contract reads only the packaged registry
and its clean `res://` assets and repeats the receiver/adapter and dependency
closure checks.

## Next integration seam

A later approved runtime batch should load the registry once in a generic
facade runtime system and adapt the current receiver-specific paths behind that
single lookup. It should first prove semantic, transform, material, topology,
collision, navigation, and spray parity for all 13 current receiver adapters.
The 12 projected source-bearing direct assets need purpose-built package-safe
runtime adapters or summaries before they can become executable registry
dependencies; the fail-closed registry will not point at them as-is. This
Phase 1.5 work deliberately does not wire the registry loader into
`world_chunk_builder.gd`, edit Building 1 runtime/model files, alter generated
world data, or independently change facade behavior.
