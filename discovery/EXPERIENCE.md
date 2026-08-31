# Player-experience discovery

## Owner-approved locomotion amendment (2026-08-28)

The first playable was initially scoped to walking and running. The owner later explicitly changed the current player-facing loop: **before:** walk/run/spray with no vertical locomotion; **after:** walk/run, unlimited hold-to-rise jetpack flight on physical `Space`, slow capped descent on release, and spray. This amendment changes the current experience contract but does not add terrain elevation, fuel, vehicles, missions, or a new dependency. The historical decision-neutral approach conclusion at the end of this discovery document is retained for provenance; the approved Godot approach is recorded in `DECISION_LOG.md`.

## Current milestone and settled scope

- Discovery document date: 2026-08-27.
- Co-primary outcomes are a recognizable Treasure Island and a playable game. Neither is subordinate to the other.
- The current first playable is a third-person **walk/run/jetpack/spray** experience. Walking and running provide ground locomotion; the unlimited jetpack provides vertical locomotion inside the existing Treasure Island boundary.
- Cars and arcade driving remain an eventual idea, explicitly deferred from this milestone.
- The target is the owner’s Mac with mouse and keyboard only.
- Locally inspected, non-sensitive target specifications are: MacBook Pro, Apple M1 Pro, 10-core configuration, and 32 GB memory. Never record or request serial numbers, device names, account details, or other identifiers.
- The playable traversal boundary is Treasure Island. Yerba Buena Island and the Bay Bridge appear as simple non-playable polygonal scenery. San Francisco appears as a non-playable billboard background.
- The island exterior is based on the latest OpenStreetMap snapshot available at acquisition/build time, then frozen and identified for reproducibility.
- Complete coverage means every in-scope Treasure Island exterior feature in that snapshot, including the recorded shoreline, road network, public spaces, exterior building footprints, and a continuous island ground surface.
- Every recorded building footprint receives simple exterior massing. Missing height data uses a conservative reversible default rather than omission.
- Apartments, individual units, rooms, floor plans, interiors, and bespoke facade detail are out of scope.
- Real fenced/private-access restrictions are not researched or reproduced. Outdoor snapshot space is generally traversable except for clear world-boundary, safety, or playability boundaries.
- The current spray content is one predefined tag image placed on eligible building surfaces.

This document does not select an engine, framework, map-production pipeline, technical architecture, detailed visual treatment, or vehicle implementation.

## Experience promise

The owner can enter the actual playable on the target Mac, recognize it as Treasure Island during ordinary play, walk, run, or use the jetpack through the island exterior without a mission gate, place the predefined tag on an eligible building surface, understand an ineligible attempt, and continue playing without a blocker.

“Half-Life-1-like spray” refers only to the interaction fantasy of deliberately placing a visible surface mark with immediate success or rejection feedback. It does not import Half-Life file formats, controls, timing, networking, persistence, or rendering behavior.

## Frozen OpenStreetMap baseline

- Coverage is checked against the identified frozen snapshot, not against a reconstructed real-world state on a particular date.
- Later OpenStreetMap edits or physical-island changes do not invalidate the build.
- OpenStreetMap access tags, road classes, or fences do not create real-access gameplay requirements.
- Complete coverage and recognition are separate: all snapshot content can be present while the island still reads too generically.
- [ISLAND_EVIDENCE.md](./ISLAND_EVIDENCE.md) may supply optional recognition context but cannot override the frozen layout baseline or create a freshness audit.

## KISS implementation defaults

Detailed camera behavior, avatar appearance, color choices, billboard composition, water and shoreline behavior, walk/run and jetpack tuning, starting position, recovery behavior, spray presentation, and tag-instance limits are reversible implementation defaults. They need no owner approval.

Defaults change only when ordinary use reveals a concrete blocker, basic usability problem, recognition failure, or material scope/cost consequence. The owner is not asked to preselect low-impact details.

Basic usability still matters:

- Mouse-and-keyboard controls expose walk, run, Space-held jetpack lift, turn, spray, pause, recovery, and exit consistently.
- The third-person view permits orientation, ground/air movement, and spray targeting without preventing continued use.
- Essential feedback does not rely on color alone.
- Ordinary collision, boundary, shoreline, or stuck cases return the owner to useful play through the chosen default.

## Qualitative blocker-level acceptance check

Use the actual first playable on the owner’s Mac. Record plain observations and the owner’s ordinary comments. This is an ordinary play check, not a lab protocol or preference session.

- **Coverage present:** The frozen OpenStreetMap inventory is represented across Treasure Island, including continuous ground and shoreline, roads, public spaces, and simple massing for every recorded building footprint. The agreed non-playable YBI/Bay Bridge polygons and San Francisco billboard are present.
- **Treasure Island recognizable:** During ordinary play, the owner reports that the world reads as Treasure Island. A natural comment or observation is sufficient; no lab-style recognition protocol is required.
- **Walk/run works:** With mouse and keyboard, the owner can walk, run, stop, turn, traverse ordinary outdoor space, and recover from an ordinary obstruction without developer intervention.
- **Jetpack works:** Holding Space sustains upward travel without fuel, release produces a slow descent, another mid-air press resumes ascent, horizontal steering remains usable, and an ordinary landing does not require recovery.
- **Spray works:** The owner can place the predefined tag on an eligible building surface, sees understandable rejection on an ineligible target, and can inspect the successful mark.
- **Play resumes:** After flight/landing, movement recovery, a successful placement, or a rejected placement, the owner can continue walking, running, flying, or spraying without restarting the project.

Only blocker-level failures in these outcomes prevent the current milestone from passing. Cosmetic differences and delegated defaults do not.

## Material open issues

- Acquire, freeze, and record the exact OpenStreetMap snapshot identifier used for the build.
- Define one consistent eligible/ineligible building-surface rule and clear world/safety/playability boundaries as reversible implementation defaults.
- Escalate to the owner only when a concrete proposal would materially change recognized scope, cost, maintenance, or a settled invariant. Ask one exact question for that proposal rather than reopening generic preferences.

## Deferred later idea: cars and arcade driving

Cars and arcade driving are not part of the current first playable. Their absence cannot fail current coverage, recognition, roaming, spray, usability, or blocker checks.

If a later milestone explicitly activates vehicles, arcade-acceptable driving should be learnable, responsive, predictable, forgiving of ordinary mistakes, and enjoyable enough for the owner to continue. Vehicle controls, handling, recovery, car availability, roster, and interaction with spraying remain deferred until then.

## Resource requests

No new resource, purchase, account, hardware disclosure, or owner preference session is required for this experience pass. Existing snapshot work, the owner’s target Mac, and ordinary observation of the playable are sufficient.

Historical discovery conclusion retained: **No approach selected.** The later approved Godot choice and jetpack amendment are authoritative in `DECISION_LOG.md`.
