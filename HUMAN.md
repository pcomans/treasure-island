# Owner action queue

Agents must exhaust safe autonomous alternatives and continue every independent
workstream. This file isolates actions that genuinely require the owner; it is
never, by itself, a reason to stop. Only the scope named in **Blocking scope**
waits for its owner action.

## Current items

| ID | Status | Blocking scope | Owner action | Evidence |
| --- | --- | --- | --- | --- |
| HUMAN-001 | Pending owner acceptance | Ordinary recognition and mouse/keyboard acceptance on the approved Apple M1 Pro only. This does not block technical verification, package delivery, or repository publication. | Play the exact `111725` candidate and assess Treasure Island recognition plus ordinary walk, run, jetpack, and eligible-wall spray behavior. | [Playtest guide](PLAYTEST.md); [final package evidence](evidence/first-playable/final-verification-2026-09-03-105408/README.md) |
| HUMAN-002 | Optional | Public distribution only; not required for private use or first-playable acceptance. | If distribution is later desired, authorize and provide the appropriate Developer ID/notarization workflow. | [Final package evidence](evidence/first-playable/final-verification-2026-09-03-105408/README.md) |
| HUMAN-003 | Optional | Intel runtime support only; the universal `x86_64` slice is already statically verified. | Request runtime execution on Intel hardware only if Intel support becomes desired. | [Final package evidence](evidence/first-playable/final-verification-2026-09-03-105408/README.md) |

## Resolved

| ID | Resolved | Outcome |
| --- | --- | --- |
| HUMAN-R001 | 2026-09-03 | The owner approved GitHub authentication as `pcomans-bot`; repository push may proceed. |
