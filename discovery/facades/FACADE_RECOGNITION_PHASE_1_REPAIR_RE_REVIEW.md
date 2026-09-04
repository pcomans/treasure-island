# Facade recognition Phase 1 repair re-review

Checked: **2026-09-04**

Reviewer: **`/root/independent_tower_rereview`**, independent of the Phase 1
catalog/compiler implementation and its repair.

This review supersedes the **FAIL** decision in
`FACADE_RECOGNITION_PHASE_1_INDEPENDENT_REVIEW.md` for the repaired byte state.
The original review remains historical evidence of the defects it found.

## Verdict

**PASS — all four reported defects are closed. Phase 1 may proceed to bounded
runtime integration.**

That authorization is deliberately narrower than “the registry is already a
complete executable facade runtime.” Twelve source-bearing direct inputs remain
represented only by pathless, hash-bound metadata projections. A later runtime
integration must supply package-safe executable adapters for those projections
and prove behavior parity before it removes the existing receiver-specific
paths.

## Exact results

| Gate | Independent result | Verdict |
| --- | --- | --- |
| Physical recognition units | `213` = `212` standalone + `1` composite | **PASS** |
| Direct wall receivers | `214`, unique | **PASS** |
| Source records | `215`, unique | **PASS** |
| Visible wall runs | `4,971` | **PASS** |
| Runtime adapter receivers | `13` = `11` legacy + `2` active Building 1 hero | **PASS** |
| Whole-building acceptance imported | `0` game-distinctive / `0` reference-recognizable / `0` as-built | **PASS** |
| Schema mutation cases | `4 / 4` rejected | **PASS** |
| Compiler determinism | two independent `--check` runs emitted identical summaries and preserved identical registry/report bytes | **PASS** |
| Node / Godot registry checks | both exit `0` | **PASS** |
| Building 1 hero contract | exit `0`; four source identities remain separate | **PASS** |
| Full runtime integration | exit `0`; gameplay, reload, topology, physics, and interactions pass | **PASS** |
| Diff hygiene | `git diff --check` clean; no tracked `generated/`, `data/`, `HUMAN.md`, or `AGENTS.md` change | **PASS** |

## Independent denominator derivation

The totals above were re-derived without reading them from the compiler report:

1. Python's standard CSV reader parsed
   `data/osm/treasure-island-source-inventory.csv` as `739` rows / `739` unique
   source keys, including `735` playable rows, `213` building members, and `2`
   non-overlapping building-part members.
2. The facade inventory independently contained `215` rows / `215` unique
   source keys. Its relationship records partitioned into `212` standalone
   footprints, one composite parent, and two part records.
3. All `38` generated chunk descriptors were checked against their byte counts
   and SHA-256 values before their records were read. Their direct wall records
   totalled `214` unique object keys / `214` direct source keys and `4,971`
   isolated wall runs.
4. The CSV building/building-part key union and inventory source-key set had an
   empty symmetric difference.

The one composite is still Isle House: parent `w1249412094` plus parts
`w1282547786` and `w1282547787`. The separately keyed Building 1 tower
`w1222720021` remains one of the 212 standalone physical units; it is not merged
into `r16681702` to reduce the denominator.

## Prior defect closure

### 1. Exact-current Building 1 and separate tower adapters — closed

The catalog and compiled registry now contain two active receiver contracts:

- `physical-building:r16681702` owns only
  `building:r16681702:wall`, mode `active_building_1_hero`;
- `physical-building:w1222720021` owns only
  `building:w1222720021:wall`, mode `active_building_1_hero`.

Each physical unit has exactly one active adapter ID and no legacy adapter ID.
Both contracts pin the current hero adapter, config, world-builder dispatch,
six Building 1 materials, and
`tower_remains_separately_reviewable: true`. The registry contains no
`building_1_recognizable_facade` or
`building_1_recognizability_placements` string.

The compiler does not merely trust the catalog declaration. It derives the two
expected active seeds from the exact-current config and source text, checks that
`world_chunk_builder.gd` preloads the hero adapter and dispatches matching
records before generic construction, checks the four hero target constants,
and refuses the obsolete adapter. The Node suite's removed-dispatch mutation
fails closed. A fresh hero contract also proved four separate wall/roof source
identities, exact horizontal plans, deterministic replacement, and congruent
collision ownership:

```text
building:r16681702:wall     5 meshes / 5 surfaces / 8,026 triangles
building:r16681702:roof     2 meshes / 2 surfaces /   579 triangles
building:w1222720021:wall   3 meshes / 3 surfaces /   760 triangles
building:w1222720021:roof   1 mesh   / 1 surface  /    14 triangles
```

No recognition acceptance is inferred from active content. Both units remain
`reference_recognizable=not_evaluated` in this Phase 1 seed.

### 2. Recursive package boundary and sanitized projections — closed

The compiler recursively follows textual `res://` dependencies through `.gd`,
`.gdshader`, `.json`, `.tres`, and `.tscn` inputs. It rejects missing
dependencies and classifies any closure containing `discovery/`, `evidence/`,
a reference URL, or an absolute workstation path as source-bearing.

The source-side audit currently reports:

| Package measure | Count |
| --- | ---: |
| Adapter direct-asset occurrences | `59` |
| Unique direct inputs | `45` |
| Unique clean direct inputs emitted as runtime paths | `33` |
| Unique source-bearing direct inputs emitted as projections | `12` |
| Assets visited across all clean and dirty source closures | `133` |
| Source-bearing assets detected in those source closures | `13` |

Duplicate use across adapters explains why the registry has `45` clean runtime
asset occurrences and `14` projection occurrences while the unique partition is
`33 + 12 = 45`.

An independent closure walker then started only from the `33` unique emitted
runtime paths. It reached `67` unique assets and found **zero** discovery paths,
evidence paths, URLs, or absolute workstation paths. The registry JSON itself
also contains zero forbidden tokens.

Every source-side audit occurrence was independently reconciled to the emitted
adapter:

- a clean occurrence has the exact `res://game/...` path and current SHA-256;
- a dirty occurrence has no emitted path and has a projection ID derived from
  adapter ID + source path + source SHA-256, plus the exact source hash/type;
- every dirty direct path is absent from the runtime registry;
- all projection objects have exactly the pathless
  `sanitized_adapter_metadata_summary_only` contract.

The package boundary is therefore honest: current dirty source assets are not
misrepresented as executable runtime dependencies. The explicit
`sanitized_summary_requires_future_package_safe_adapter` state prevents a later
loader from silently treating those projections as ready code or resources.

### 3. Isle House mixed receiver state — closed

The compiled unit `physical-building:w1249412094` is now receiver-specific:

| Receiver | Runs | Runtime state |
| --- | ---: | --- |
| high part `building-composite:w1249412094:w1282547786:wall` | `13` (`3` shared-above-lower) | `legacy_adapter`, with its exact adapter ID |
| low part `building-composite:w1249412094:w1282547787:wall` | `13` | `generated_placeholder`, null adapter ID |

The unit summary is
`mixed_legacy_adapter_and_generated_placeholder`, not wholly adapted. Its
recognition status remains unaccepted. Compiler, Node, and Godot checks assert
the partition, and the Node mutation that assigns the high adapter to the low
receiver fails closed.

### 4. Actual JSON-Schema application — closed

The compiler loads and validates the schema document, then applies it to the
authoring catalog at the start of every compile before semantic inventory and
runtime checks. The dependency-free validator implements every schema keyword
used by this document and refuses unsupported keywords; it is not a silent hash
or five-field spot check.

In addition to the checked-in Node mutation suite, an independent in-memory
harness passed the valid catalog and rejected all four required defect probes:

| Mutation | Rejection |
| --- | --- |
| unexpected nested `identity.illegal` property | nested `additionalProperties: false` |
| invalid `game_distinctive` value | enum violation |
| remove one catalog unit | `212` is below the required `213` cardinality |
| redirect the unit `$ref` to a missing definition | unresolved local `$ref` |

The checked-in suite additionally rejects stale active-adapter classification,
a removed Building 1 dispatch hook, a dirty asset inserted as a runtime path, a
path smuggled into a sanitized projection, and the Isle House low-receiver
collapse. Semantic cross-file checks remain in place; JSON Schema is not being
used as a substitute for source/receiver ownership validation.

## Claim and identity preservation

The authoring catalog independently sums to:

- `0` capture contracts;
- `0` unit reference records, recognition cues, acceptance records, protected
  scopes, or human dependencies;
- `213` receiver-complete units;
- `0` accepted game-distinctive units;
- `0` accepted reference-recognizable units;
- `0` limited or claimed as-built units.

All 13 adapter records state
`whole_building_recognizability_imported=false` and
`recognition_claim_effect=none`.

The two NPS identity corrections also remain separated from frozen provenance.
For both Building 2 and Building 3, the inventory retains frozen
`ref:nrhp=08000081`; the source-only authoring assertions record `08000082` and
`08000083`, respectively, with `currentness_claimed=false`. Runtime summaries
preserve both old and evidenced values but contain neither source URL nor
research path.

## Determinism and runtime checks

Two separate invocations of
`node tools/build_facade_recognition_registry.mjs --check` produced identical
summaries. Before and after each invocation, the checked-in files remained:

- runtime registry
  `e6a5f6223f176917a5553498bf7548d68a64ebc22beb641559611ca3471d48c1`;
- validation report
  `3f4ccf4a51b274900c71d0a24b2c5de714cfc18c30a14c76ce5a5b0b5d400896`.

The Node registry test passed, including a second in-memory compilation whose
stable serialization matched the checked-in registry bytes.

The Godot registry contract passed the same registry hash and repeated the
counts, claim-neutrality, exact active adapters, separate tower, mixed Isle
House state, runtime hashes, and clean dependency closures.

Full runtime integration then passed at the same byte state:

```text
38 chunks / 729 record nodes
725 generic record meshes / 735 surfaces / 48,059 triangles
931 total runtime meshes / 941 surfaces / 59,778 triangles
466 static bodies / 466 shapes / 738 geometry source identities
```

Walk, run, jetpack rise/slow descent/renewed rise/landing, boundary recovery,
spray placement/rejection, camera compression/restoration, failed-closed reload,
and scene cleanup all passed. This proves no current behavior regression; it
does not claim that the not-yet-consumed registry has already achieved generic
loader parity.

`node --check` passed for the compiler, Node test, and schema validator.
`git diff --check` also passed. Concurrent Building 3 work visible elsewhere in
the dirty tree was outside this Phase 1 review and receives no acceptance here.

## Exact reviewed hashes

| Artifact | SHA-256 |
| --- | --- |
| source inventory CSV | `fdf57f37f5507a7cb9b64a7fc530eabb22e29f3742324d5347c0f6b1949cb4cb` |
| facade receiver inventory | `0136d02466e46258207cb30658ceadddd5d9e16d785238e3f1ef270fd26ed94f` |
| generated manifest | `e501236d0908a1a1fd41b3973e7adbd3e94d32bb658cc3f1e44f7731f00a1fb3` |
| catalog compiler | `35a74c8d743076c3613d2450337a61236a15bd01529dfa4505f07ce5806a2d73` |
| Node registry test | `8996e9e9d9d5d12163b5cd6acaf35cceba883c5b4ebce40f60c602f2ad9c176c` |
| dependency-free schema validator | `e2c883ec6f834aa8339204f0eb444e86e73830ec98d421449445321c98e9e79a` |
| catalog schema | `24d92c31db1678ab67037208d692ec50130638adcdc67591025520c1532b3d40` |
| authoring catalog | `917235d09b8eb4f45c917f1c54d22260380f034674e788448a8ad1e8a61d75dd` |
| validation report | `3f4ccf4a51b274900c71d0a24b2c5de714cfc18c30a14c76ce5a5b0b5d400896` |
| runtime registry | `e6a5f6223f176917a5553498bf7548d68a64ebc22beb641559611ca3471d48c1` |
| infrastructure handoff | `be9cc66ff9be63182ff9b69be31274422f3c756bd8bd2e2b9f047f17c7939510` |
| Godot registry contract | `3d0cbb3fe42f064b984c04bcbd8dc69cdecd59c04ff713548d28f41ce0ae7ed1` |
| full runtime integration contract | `a39a80e2ce96329ae1f1a5edf815f9d2640aee372a1e44bbc416d00acbf2db7e` |
| world chunk builder | `ab79117f85a1c266b42a62054a9a39f6822713528ae2d70cfeab0cbfd7169ccd` |
| Building 1 hero adapter | `1487ee41870a03ad79118936d0f3f563644ef617ca2722fe64778d80e85a3495` |
| Building 1 hero config | `6c99f43550631a1e6bca1f52764ad23c6a5b8b891403f30c78ff9b9545192690` |
| superseded Phase 1 review | `b155dd4064ad1c13057a970abc2e11d0885fcf3a0039173aace7fb1aae0e2062` |

## Residual risks and next gate

1. **Registry consumption is still absent.** Runtime integration may now begin,
   but it must prove semantic, transform, material, topology, collision,
   navigation, and spray parity before deleting any existing dispatch path.
2. **Twelve dirty direct inputs are projections, not executable assets.** Build
   package-safe adapters or runtime summaries for them. Their explicit
   `requires_future_package_safe_adapter` state must remain fail-closed until
   that work passes independent review.
3. **The schema validator is intentionally bounded.** It fully applies the
   keywords used by the current schema and rejects unknown keywords. Any schema
   expansion must extend/test the validator or adopt a pinned full Draft
   2020-12 implementation before relying on new vocabulary.
4. **Compiler v1 is a zero-acceptance seed.** Its current final validation
   intentionally rejects genuine reference-recognition promotion. Version and
   independently review that gate before the first accepted batch enters the
   catalog.
5. **Building 1 lifecycle state remains claim-neutral here.** Independent visual
   reviews exist outside this Phase 1 seed, but their results are not imported.
   Reconcile them through the future acceptance ledger rather than changing
   status from runtime presence alone.
6. **The shared tree is dirty and contains concurrent work.** This review binds
   only the hashes above; later changes require `--check`, Node, Godot registry,
   and full-runtime revalidation before commit.

With those boundaries preserved, **Phase 1 is accepted and may proceed to the
runtime-integration phase**.

