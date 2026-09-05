# Owner action queue

Agents must exhaust safe autonomous alternatives and continue every independent
workstream. This file isolates actions that genuinely require the owner; it is
never, by itself, a reason to stop. Only the scope named in **Blocking scope**
waits for its owner action.

## Current items

| ID | Status | Blocking scope | Owner action | Evidence |
| --- | --- | --- | --- | --- |
| HUMAN-001 | Pending owner acceptance | Ordinary recognition and mouse/keyboard acceptance on the approved Apple M1 Pro only. This does not block technical verification, package delivery, or repository publication. | Play exact candidate `d1-b225-postpromotion-v8-2026-09-05-001` and assess Treasure Island recognition plus ordinary walk, run, jetpack, and eligible-wall spray behavior. | [Playtest guide](PLAYTEST.md); [B225 v8 packet](evidence/first-playable/d1-b225-postpromotion-v8-2026-09-05/capture-manifest.json); [mechanical release audit](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_CONTRACT_AUDIT.md); [visual release review](evidence/reviews/d1-b225-postpromotion-v8-2026-09-05-INDEPENDENT_VISUAL_REVIEW.md) |
| HUMAN-002 | Optional | Public distribution only; not required for private use or first-playable acceptance. | If distribution is later desired, authorize and provide the appropriate Developer ID/notarization workflow. | [Current handoff](README.md#export) |
| HUMAN-003 | Optional | Intel runtime support only; the universal `x86_64` slice is already statically verified. | Request runtime execution on Intel hardware only if Intel support becomes desired. | [Current handoff](README.md#export) |

## Resolved

| ID | Resolved | Outcome |
| --- | --- | --- |
| HUMAN-R001 | 2026-09-03 | The owner approved GitHub authentication as `pcomans-bot`; authentication and the initial delivery push completed. |
