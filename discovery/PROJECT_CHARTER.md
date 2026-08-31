# Project Charter

## Status

Discovery and approach comparison are complete. The owner approved the exact Godot implementation proposal on 2026-08-27, and implementation is active. On 2026-08-28 the owner also approved unlimited Space-held jetpack lift with slow descent; see `DECISION_LOG.md`.

## Approved invariant

Build a private hobby game in which the owner can recognize and roam a contemporary OpenStreetMap-based Treasure Island, San Francisco, and place a spray-tag decal on eligible building surfaces. The eventual concept still includes drivable cars with arcade-acceptable handling, but cars are deferred from the current first playable.

`Model the island` means complete island-scale exterior coverage from a frozen latest-available OpenStreetMap snapshot: Treasure Island's terrain/shoreline features, roads and paths, major public spaces/land use, and exterior building footprints. Missing height information may use simple, explicitly provisional exterior massing. It does not mean individual apartments, floor plans, rooms, or interiors.

## Scope

- Treasure Island only
- Complete island-scale exterior coverage
- No apartment, room, or interior modeling
- Broadly present-day layout baseline: latest OSM snapshot frozen when acquired; no independent currentness reconciliation
- Free roaming
- Third-person walking, running, and unlimited hold-to-rise jetpack flight in the current milestone
- Owner's MacBook Pro with Apple M1 Pro (10-core CPU, 32 GB memory) as the target device
- Mouse and keyboard only
- Outdoor OSM snapshot space is generally traversable; real fenced/private access is not researched or reproduced
- Simple exterior building massing to start
- One predefined spray tag
- San Francisco represented as non-playable billboard background scenery
- Yerba Buena Island and the Bay Bridge represented as simple non-playable polygonal scenery
- Drivable cars and arcade-acceptable handling deferred to a later milestone
- Half-Life 1-like spray interaction on eligible building surfaces
- Private personal use

## First-playable acceptance scenarios

These describe outcomes, not an implementation:

1. The owner can identify the setting as Treasure Island from the playable world rather than from a title card alone.
2. The complete approved Treasure Island exterior world is present: every in-boundary terrain/shoreline feature, road/path, major public-space/land-use feature, and exterior building footprint in the frozen OSM baseline.
3. A third-person player can walk, run, and use the unlimited jetpack throughout the generally traversable outdoor island without a progression blocker; releasing Space produces a slow descent.
4. The player can recover from an ordinary collision or stuck state without restarting the entire project manually.
5. The player can place the one predefined spray tag visibly on at least one eligible building surface and receives understandable feedback when a surface is ineligible.
6. A walk/run/jetpack/spray loop remains playable without a blocking failure.

## Approved success priorities

- Co-primary: the complete island reads recognizably as Treasure Island.
- Co-primary: the third-person walk/run/jetpack/spray experience is playable without blocking failures.
- Supporting quality: clear, enjoyable spray interaction. Arcade driving quality activates when the deferred car milestone begins.
- Hobby constraints: keep time, out-of-pocket cost, and maintenance proportionate; no generic weighting exercise is required.

If a later concrete comparison exposes a real tradeoff between these outcomes, ask one exact decision question at that time rather than reopening broad priorities.

## Reversible defaults and deferred ideas

- Third-person camera tuning, placeholder avatar, simple colors, shoreline response, tag-count limits, and similar low-risk details use KISS implementation defaults. They become owner questions only if a tested default creates a material blocker or tradeoff.
- Recognition-critical landmark emphasis is adjusted from ordinary playtest observations rather than an advance questionnaire.
- Cars, traffic, pedestrians, missions, collectibles, damage, police responses, and cross-session tag persistence are deferred ideas. They have no current acceptance or research work.

## Phase gate

The discovery artifacts, resource register, decision log, and team retrospective are complete. The Godot approach is approved and implemented; later player-facing amendments remain governed by the before→after approval rule in `AGENTS.md`.

Godot approach approved by the owner on 2026-08-27; jetpack amendment approved on 2026-08-28.
