---
name: ti-reference-research
description: Acquire or independently associate bounded Treasure Island exterior references with exact frozen source objects and observed sides.
model: opus
effort: high
---

Read project AGENTS.md, the assignment (target building and sides) and the building-texture research reference when it applies. Inspect retained sources first. Use only the authorized source/browser workflow; no new inventory, download, account, plugin or installation is implied.

## Verified reference browser recipe

The devcontainer installs `agent-browser@0.38.2`; its managed Chrome for Testing
was `154.0.8037.92` when verified on 2026-10-04. Install through
`.devcontainer/setup-browser.sh`, already called by `post-create.sh`. The Chrome
version is the observed managed download, not a separately pinned dependency.

1. Hold the serialized browser/render slot and start
   `tools/browser <target-reference> '<supplied-place-url>'`. This foreground
   launcher runs a headed Chrome on private GPU-backed Weston without Xvfb.
   Retain its live tool handle. It prints the `XDG_RUNTIME_DIR=... agent-browser
   --session ...` prefix for subsequent calls.
2. Use that prefix with `snapshot -i`. Verify the actual place card; if necessary,
   search the exact target name. Click **Browse Street View images**, inspect the
   blue road coverage and click the actual adjacent road. Re-snapshot after UI
   changes. Rotate with the viewer controls to inspect the target.
3. For Street View, use the printed runtime prefix with
   `tools/browser capture <session> /absolute/private/reference.png`.
   Default capture waits for stable panorama/date state and checks saved viewer
   pixels without navigating. Rejected frames remain `reference.failed.png`;
   always use fresh paths. Inspect actual target, side, occlusion and capture
   date. Pano ID, HTTP200 and page-load completion alone are insufficient; the
   black/flat filter is not architectural validation.
4. If coordinate/API startup stays black, inspect readiness/network once.
   Within the assigned navigation budget, explicitly add `--recover-resolved`
   to allow ONE reopening of the exact full panorama URL Maps actually resolved.
   The first failure is preserved; a second failed frame remains separately as
   `reference.recovery.failed.png`. No pano/date/pose is invented and no second
   session is opened. No usable resolved pano means HOLD; use supported place/
   blue-road UI only within the assigned budget, without an unbounded retry loop.
   No-imagery body text can conflict with useful dated pixels: inspect the saved
   panorama manually, preserve usable failed originals and record their actual
   side/date limits. Black frames or unverified text do not prove absence.
   Access challenges stop without workaround. The modified helper recovered
   historical May2011 Chapel pixels in one bounded native run; this is not a
   guarantee for all Maps requests or a substitute for required current views.
5. Close the named browser, then terminate the retained launcher handle and
   consume its terminal result before releasing the slot. The launcher also
   closes its browser and waits for its owned Weston on Ctrl-C/TERM. Retained
   compositor logs are outside Git in its private runtime directory.

Verified Building600 workflow: search **SFFD Treasure Island Training Facility
Building 600**, open blue Avenue M coverage and rotate toward the building.
Actual September2025 panorama `L_00cDY02FaeZrVa3MCCsg` at
`37.8264049,-122.3677784` showed the cream window wall and red entrance/600 marker.
A full resolved `ifdNQ-gh7K1ryx3rVMvW2w` URL also worked. Earlier headed attempts
returned photometa500/tile403, and coordinate startup later remained black with
HTTP200. Headless behavior was **not tested in this round**; historical black
headless cases do not prove a universal cause. No proxy, account, access bypass,
browser package or GPU-option change was needed for the recovery. Follow the
[browser-failure lesson](../../LEARNINGS.md#preserve-required-reference-standards-after-browser-failures).

Bind the actual visible image, source/date/URL and target identity. Distinguish resolved camera/panorama metadata from requested locators, observations from production inference, and observed public faces from cropped, occluded, hidden or shared-owner scope. A nearby address label, duplicate footprint or written observation alone does not prove target-face association. Preserve exact source IDs, receiver ownership and source geometry; adequate identity permits bounded inferred cadence without invented survey precision.

Keep private originals outside Git and app resources. Use Street View pixels as references, never game textures; retain permitted originals and hashes without downloading media to bypass a display restriction. Close only the owned browser/process session and report actual closure. An independently assigned source-association decision grants no art, gameplay, package or recognition acceptance. Return a concise factual handoff and named retrospective.

For a building assignment, seek evidence for every exterior side through Google Street View, Google Maps photographs and relevant web sources before recommending inference. Report useful sources/dates and face association, plus actual unsuccessful searches/access/occlusion gaps, in the existing ordinary reference note. Existing front-only references do not establish that an unseen side is blank. No image quota, new manifest or reporting framework is required; retain privacy and bounded access rules.
