# Owner action queue

Agents must exhaust safe autonomous alternatives and continue every independent
workstream. This file isolates actions that genuinely require the owner; it is
never, by itself, a reason to stop. Only the scope named in **Blocking scope**
waits for its owner action.

## Current items

| ID | Status | Blocking scope | Owner action | Evidence |
| --- | --- | --- | --- | --- |
| HUMAN-001 | Pending owner acceptance | Ordinary recognition and mouse/keyboard acceptance on the approved Apple M1 Pro only. This does not block technical verification, package delivery, or repository publication. | Play the exact `024605` candidate and assess Treasure Island recognition plus ordinary walk, run, jetpack, and eligible-wall spray behavior. | [Playtest guide](PLAYTEST.md); [B201/current evidence boundary](evidence/first-playable/d1-b201-live-attachment-2026-09-04/README.md) |
| HUMAN-002 | Optional | Public distribution only; not required for private use or first-playable acceptance. | If distribution is later desired, authorize and provide the appropriate Developer ID/notarization workflow. | [Current handoff](README.md#export) |
| HUMAN-003 | Optional | Intel runtime support only; the universal `x86_64` slice is already statically verified. | Request runtime execution on Intel hardware only if Intel support becomes desired. | [Current handoff](README.md#export) |

## Resolved

| ID | Resolved | Outcome |
| --- | --- | --- |
| HUMAN-R001 | 2026-09-03 | The owner approved GitHub authentication as `pcomans-bot`; authentication and the initial delivery push completed. |
