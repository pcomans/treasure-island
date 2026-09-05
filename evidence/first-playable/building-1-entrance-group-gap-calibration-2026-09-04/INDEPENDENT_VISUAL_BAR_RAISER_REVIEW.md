# Independent visual bar-raiser review — Building 1 entrance-group gap

**Reviewer:** `/root/visual_bar_raiser`
**Date:** 2026-09-04
**Scope:** Existing accepted Building 1 (`r16681702`) quality calibration only; no recognition-inventory credit.

## Evidence identity

- A accepted-control config (`entrance_group_gap = 0.55` m): `fd434eb472f61d93408732841e5993881b23238af8c0518b59181ac0ea535e32`.
- B literal candidate config (`entrance_group_gap = 0.90` m): `7b53847c627d6f0a0d4ebefcc790e8fd3bcaeee6fbdebbf5c6a85f2aeb4a5806`.
- Capture generator: `b1565b71cbda76a8c63204b18d7cac99ad78a6882667bafcd798de5b8dbaf160`.
- Salvage finalizer: `85c2bc869787dcf466540ec40d284419d75acb9e6205ac2e86e69edd50850078`.
- Combined capture manifest/seal: `7dac2b94933dd74642dc0c164e0ce7d6a3b774b7ec265e078e96e34dea199dd2`.
- A stills / motion manifests: `d0193298acb3068722ba63ce6858b698296d4b93a1d75a2b410dd7890b2f2a74` / `8fe4e052bdb0a5c1c89eb5103bfdb3b7a58169a77d3d32bf6c998d92a6181ba8`.
- B stills / motion manifests: `9468170d4f93153c2fe8ae5b282bd99d46bcbd941a4e420072a6068d5c1e0e2a` / `5448bd69ed81588be75c0eff5b47f2185d392b132dd7403577463d63a6f390fd`.
- Preserved B preliminary manifest: `5e541a144aee83d19a26f364454b5bed7b7659a18bdcaff96d9db0f530a26040`.
- A / B normal-forward AVIs: `cf51e56538ba640b083d67c12d3f79e9f1864b57f70cf3ba0015e76c7a66b6ff` / `318718deb113bc9d639db6bed28cd0e8eb30459c3b7754fe39dba5728b6a1e82`.

## Independent review method

I first inspected all eight original 1440×900 A/B images without relying on labels or manifests: matched whole-front color, matched changed-light color, entrance-focused color, and deterministic entrance grayscale. I then inspected original-resolution motion frames and dense paired samples spanning each AVI's full useful process-frame interval `65..330`, including the long-distance, middle, and closest portions of the normal-forward approach. Only after the visual judgment did I inspect the sealed manifests and trajectory contracts.

The motion evidence is genuinely matched. Both clips are 1440×900 Motion-JPEG AVIs with 337 frames. Their useful intervals map to physics frames `131..660`; A and B have exactly matching player paths, LOS samples, start transforms, fixed camera orientation, and 529/529 grounded samples. The route is a nearly normal stock-controller approach from approximately 60 m to 25 m, with no sprint, jetpack, recovery, or player/camera transform writes after motion begins. The matched mild-oblique stills, grayscale derivative, and changed-light mate provide the appropriate supplemental checks for this one-scalar calibration.

## Pixel judgment

A's nominal 0.55 m inter-group gap leaves only 0.07 m of light facade between the adjacent 0.24 m reveal borders, about 0.58 px at the sealed roughly 80 m pose. It therefore tends to collapse into one continuous dark entrance band at whole-building distance.

B leaves 0.42 m of light facade between those reveal borders, about 3.5 px at the same pose. The two separators remain visibly stable in color, grayscale, changed light, and throughout the useful approach. They make exactly **three entrance groups** countable without changing the building's primary facade hierarchy.

The single long canopy, common base, and shared outer-post rhythm continue to bind the groups into one civic entrance ensemble. B does not become three storefront bays. I found no clipping, floating geometry, z-fighting, duplicate-surface pop, or identity-harming shimmer. The larger gap also remains comfortably centered on the curved 58.288 m public-front chain, and the unchanged depth hierarchy remains coherent.

## Verdict

**PASS — promote B's literal `0.90` m entrance-group gap as the accepted Building 1 quality state.**

The evidence is sufficient for this bounded scalar decision. A second motion sweep is not warranted: the continuous grounded approach proves stability across distance, while the matched mild-oblique and changed-light stills test the relevant parallax and value changes.

Nonblocking polish only:

- The outer bronze side framing is slightly busy and could later be reduced in visual weight.
- At roughly 80 m the entrance remains appropriately subordinate to the rotunda, window rhythm, and continuous canopy; closer traversal supplies the intended group count.

This review grants no new building credit and reopens no prior recognition verdict. The recognition numerator remains invariant at **6/213**.
