#!/usr/bin/env python3
"""Tree shootout gallery (2026-11-02, evaluation only).

Builds a static HTML page comparing the variant captures from
tools/tree_shootout/shootout_shots.gd side by side, per view and renderer, with
dated private Treasure Island reference photos and the metrics table.

    python3 -I tools/tree_shootout/build_gallery.py --forward DIR --compat DIR \
        --refs /workspaces/landmark-progress-20261007 --out GALLERY_DIR

The gallery holds copies of private reference photos, so it must stay outside
Git and outside game/.
"""

import argparse
import html
import json
import shutil
import subprocess
from pathlib import Path

SPECIES = {
    "palm": "Mexican fan palm (Washingtonia robusta)",
    "cypress": "Monterey cypress (Hesperocyparis macrocarpa)",
}
VIEWS = [
    ("ref", "Reference match", "Free camera at the Street View position, heading, tilt and field of view of the reference photo beside it."),
    ("close", "Close-up, gameplay camera (~6 m)", "Stock player camera at its normal height: the player stands about 1 m from the trunk (palm) or about 6 m outside the crown edge (cypress), aiming level, so the camera is about 6 m from the trunk or crown edge. The palm's crown is out of frame here: it is 17 m up, and the stock camera can tilt up at most 25°."),
    ("crown", "Crown, jetpack height", "Free camera at crown height about 9 m from the crown, as when hovering with the jetpack."),
    ("mid", "Mid, gameplay camera (~25 m)", "Stock player camera about 25 m from the hero tree."),
    ("far", "Far, gameplay camera (~90 m)", "Stock player camera about 90 m from the hero tree (the first direction with land and a clear line of sight)."),
    ("row", "Raised view of the row / grove", "Free camera about 30 m up, looking over all twelve trees."),
]
REFERENCES = {
    "palm": [
        ("building1-references/public-wsw-sep2025.png", "Google Street View, Sep 2025, 1 Avenue of the Palms, looking NE at Building 1. The slim trunk centre-right is a Mexican fan palm (crown cropped); the two thick trunks in front are Canary Island date palms, a different species.", None),
        ("building1-references/northwest-sep2025.png", "Google Street View, Sep 2025, California Ave at Building 1's north pavilion. Crop: a tall fan palm (small round crown, short brown skirt) with wind-shaped Monterey cypress behind.", (140, 270, 200, 230)),
        ("b1-north-se-refs-20261022/16-east-SevenSeas-250.png", "Contributor 360 photo (TyFlow io), Jul 2023, east of Building 1. Crop: a very tall fan palm with a compact crown.", (850, 280, 120, 190)),
        ("large-batch1-references-20261017/palms-n-corner02.png", "Google Street View, Nov 2025, Avenue of the Palms. Tall fan palms in the distance, centre-right.", None),
    ],
    "cypress": [
        ("building1-references/southwest-sep2025.png", "Google Street View, Sep 2025, 17 Treasure Island Rd at Building 1's south pavilion. Crop: Monterey cypresses, a dense dark crown with a flatter-topped one behind.", (690, 290, 330, 220)),
        ("b1-north-se-refs-20261022/16-east-SevenSeas-250.png", "Contributor 360 photo (TyFlow io), Jul 2023, east of Building 1. Crop: flat-topped, wind-shaped Monterey cypresses (centre-right); the tree at left is a broadleaf.", (598, 270, 420, 200)),
        ("building1-references/northwest-sep2025.png", "Google Street View, Sep 2025, California Ave. Crop: wind-swept cypress beside a tall fan palm.", (180, 330, 160, 150)),
    ],
}
SKETCHFAB = [
    {"species": "palm", "role": "Variant B fan palm (first choice)", "title": "Realistic HD Mexican fan palm (10/10)", "author": "PlantCatalog", "url": "https://sketchfab.com/3d-models/realistic-hd-mexican-fan-palm-1010-1205a111ed9a4ba8a94077b58a39d10b", "faces": 185966, "note": "Washingtonia robusta, 19.9 m, 22 materials, LODs included per the model page."},
    {"species": "palm", "role": "Alternate fan palm", "title": "Washingtonia Robusta Palm_01", "author": "André Murrugarra (andre.arq.89)", "url": "https://sketchfab.com/3d-models/washingtonia-robusta-palm-01-e59d8c7f054248fbbf32cfe4851b8911", "faces": 365774, "note": "Albedo, normal, gloss, opacity and translucency maps."},
    {"species": "cypress", "role": "Variant B cypress stand-in (first choice)", "title": "Umbrella Pine", "author": "rhcreations", "url": "https://sketchfab.com/3d-models/umbrella-pine-0de584cdb07a408c8e411d892cb2c9a7", "faces": 13208, "note": "Not a cypress: the closest free flat-topped conifer silhouette found."},
    {"species": "cypress", "role": "Alternate cypress stand-in", "title": "Cedar Of Lebanon", "author": "Valery.Li", "url": "https://sketchfab.com/3d-models/cedar-of-lebanon-6bf28d5c230a4dbcbc350ab7e4964a89", "faces": 206076, "note": "Not a cypress: layered, spreading conifer."},
    {"species": "cypress", "role": "Researched, rejected", "title": "Macrocarpa tree 1, 2, 3", "author": "b_nealie", "url": "https://sketchfab.com/3d-models/macrocarpa-tree-1-49aba64f05104f40b6baf2c721463f88", "faces": 396598, "note": "Photogrammetry of the lower trunk only, no crown, so not usable as a whole tree. The real Monterey cypress models on Sketchfab (meshshape, DATEC Studio) are paid Standard-licence."},
]
CC_BY = "http://creativecommons.org/licenses/by/4.0/"


def magick(*args):
    subprocess.run(["magick", *map(str, args)], check=True)


def load_metrics(folder):
    path = Path(folder) / "metrics.json"
    return json.loads(path.read_text()) if path.exists() else {}


def copy_capture(source, out_dir, name):
    """Copies a capture as a full-size JPEG for the page plus the PNG original."""
    if not source.exists():
        return None
    out_dir.mkdir(parents=True, exist_ok=True)
    png = out_dir / f"{name}.png"
    jpg = out_dir / f"{name}.jpg"
    shutil.copyfile(source, png)
    magick(png, "-quality", "92", "-sampling-factor", "4:4:4", jpg)
    return jpg


def reference_images(refs_root, out_dir):
    out_dir.mkdir(parents=True, exist_ok=True)
    result = {}
    for species, items in REFERENCES.items():
        result[species] = []
        for index, (relative, caption, crop) in enumerate(items):
            source = Path(refs_root) / relative
            if not source.exists():
                continue
            full = out_dir / f"{species}-{index}-full.jpg"
            magick(source, "-quality", "90", full)
            entry = {"full": full, "caption": caption, "source": relative}
            if crop:
                x, y, w, h = crop
                cropped = out_dir / f"{species}-{index}-crop.jpg"
                magick(source, "-crop", f"{w}x{h}+{x}+{y}", "+repage", "-resize", "300%", "-quality", "90", cropped)
                entry["crop"] = cropped
            result[species].append(entry)
    return result


def fmt_bytes(value):
    return f"{value / 1048576:.1f} MiB" if value else "–"


def rel(path, root):
    return html.escape(str(Path(path).relative_to(root)))


def figure(path, root, caption, kind=""):
    if path is None:
        return f'<figure class="cell missing {kind}"><div class="placeholder">not captured</div><figcaption>{html.escape(caption)}</figcaption></figure>'
    png = Path(path).with_suffix(".png")
    link = png if png.exists() else path
    return (f'<figure class="cell {kind}"><a href="{rel(link, root)}" target="_blank" rel="noopener">'
            f'<img loading="lazy" src="{rel(path, root)}" alt="{html.escape(caption)}"></a>'
            f'<figcaption>{html.escape(caption)}</figcaption></figure>')


def pending(caption):
    return (f'<figure class="cell pending"><div class="placeholder">{html.escape(caption)}</div>'
            '<figcaption>B · waiting for the Sketchfab download</figcaption></figure>')


def view_meta(metrics, key):
    view = metrics.get("views", {}).get(key)
    if not view:
        return ""
    parts = [view.get("kind", ""), f"camera {view.get('distance_to_hero_m', '?')} m from the hero tree (horizontal)"]
    if view.get("hero_lod"):
        parts.append(f"hero shows {view['hero_lod']}")
    return " · ".join(html.escape(str(part)) for part in parts if part)


def perf_rows(forward, compat):
    rows = []
    names = [("none", "No trees (baseline)"), ("A_palm", "A palm, LODs on"), ("A_palm_lod0_only", "A palm, LOD0 everywhere"),
             ("B_palm_reduced", "B palm, reduced"), ("A_cypress", "A cypress, LODs on"),
             ("A_cypress_lod0_only", "A cypress, LOD0 everywhere"), ("B_cypress_reduced", "B cypress, reduced")]
    for key, label in names:
        cells = []
        present = False
        for metrics in (compat, forward):
            perf = metrics.get("perf", {})
            base = perf.get("none")
            item = perf.get(key)
            if item:
                present = True
                delta = ""
                if base and key != "none":
                    delta = f" (+{item['frame_ms_median'] - base['frame_ms_median']:.2f})"
                draws = f"{int(item['draw_calls_median'])}"
                if base and key != "none":
                    draws += f" (+{int(item['draw_calls_median'] - base['draw_calls_median'])})"
                cells += [f"{item['frame_ms_median']:.2f}{delta}", f"{item['frame_ms_p95']:.2f}", f"{item['fps_median']:.0f}",
                          f"{item.get('gpu_ms_median', 0):.2f}", draws, f"{int(item['primitives_median']):,}"]
            else:
                cells += ["–"] * 6
        if present or key.startswith("B_"):
            label_html = html.escape(label) + (" <em>(pending)</em>" if not present else "")
            rows.append("<tr><th scope=row>" + label_html + "</th>" + "".join(f"<td>{c}</td>" for c in cells) + "</tr>")
    return "\n".join(rows)


def variant_rows(forward):
    rows = []
    variants = forward.get("variants", {})
    for species in ("palm", "cypress"):
        a = variants.get(f"A_{species}")
        if a:
            tex = a.get("textures", {})
            formats = ", ".join(sorted({t["format"] for t in tex.get("list", [])}))
            ranges = a.get("ranges_m", [])
            rows.append(
                f"<tr><th scope=row>A {species}</th><td>{a['lod0']:,}</td><td>{a['lod1']:,}</td><td>{a.get('impostor', '–')}</td>"
                f"<td>{a['draw_surfaces']['lod0']} / {a['draw_surfaces']['lod1']} / {a['draw_surfaces']['impostor']}</td>"
                f"<td>{fmt_bytes(tex.get('total_bytes', 0))} ({html.escape(formats)}, mipmapped)</td>"
                f"<td>LOD0 &lt; {ranges[0]:.0f} m, LOD1 &lt; {ranges[1]:.0f} m, impostor beyond</td></tr>")
        b = variants.get(f"B_{species}")
        if b:
            raw, reduced = b["raw"], b["reduced"]
            rows.append(
                f"<tr><th scope=row>B {species}</th><td>raw {raw['triangles']:,}</td><td>reduced {reduced['triangles']:,}</td><td>–</td>"
                f"<td>{raw['draw_surfaces']} / {reduced['draw_surfaces']}</td><td>{fmt_bytes(raw['textures']['total_bytes'])}</td><td>Godot-generated LODs at runtime</td></tr>")
        else:
            faces = next(m["faces"] for m in SKETCHFAB if m["species"] == species)
            rows.append(f"<tr><th scope=row>B {species}</th><td colspan=6 class=muted>Not downloaded yet: needs the owner's Sketchfab login. The first-choice model page lists {faces:,} triangles (raw).</td></tr>")
    return "\n".join(rows)


def build(args):
    root = Path(args.out)
    root.mkdir(parents=True, exist_ok=True)
    forward = load_metrics(args.forward)
    compat = load_metrics(args.compat)
    refs = reference_images(args.refs, root / "refs")
    renderers = [("forward", "Forward+ (desktop)", Path(args.forward)), ("compat", "Compatibility (web stand-in)", Path(args.compat))]
    has_b = any(f"B_{s}" in forward.get("variants", {}) for s in SPECIES)
    sections = []
    for species, title in SPECIES.items():
        ref_cards = []
        for entry in refs.get(species, []):
            shown = entry.get("crop", entry["full"])
            ref_cards.append(
                f'<figure class="ref"><a href="{rel(entry["full"], root)}" target="_blank" rel="noopener">'
                f'<img loading="lazy" src="{rel(shown, root)}" alt="reference"></a>'
                f'<figcaption>{html.escape(entry["caption"])}</figcaption></figure>')
        blocks = []
        for view, label, description in VIEWS:
            cells = []
            if view == "ref" and refs.get(species):
                cells.append(figure(refs[species][0]["full"], root, "Reference photo", "refcell"))
            for variant in ("A", "B"):
                for key, renderer_label, folder in renderers:
                    capture = folder / f"{species}-{view}-{variant}.png"
                    if variant == "B" and not capture.exists():
                        if key == "forward":
                            cells.append(pending(f"B · {SPECIES[species].split(' (')[0]}"))
                        continue
                    copied = copy_capture(capture, root / "img" / key, f"{species}-{view}-{variant}")
                    cells.append(figure(copied, root, f"{variant} · {renderer_label}"))
            blocks.append(
                f'<article class="view"><h3>{html.escape(label)}</h3><p class="desc">{html.escape(description)}</p>'
                f'<p class="meta">{view_meta(forward, f"{species}-{view}")}</p><div class="cells">{"".join(cells)}</div></article>')
        lod_cells = []
        for key, renderer_label, folder in renderers:
            for lod, lod_label in (("lod0", "LOD0"), ("lod1", "LOD1"), ("impostor", "Impostor")):
                copied = copy_capture(folder / f"{species}-lod-{lod}-A.png", root / "img" / key, f"{species}-lod-{lod}-A")
                lod_cells.append(figure(copied, root, f"A {lod_label} · {renderer_label}"))
            for lod, lod_label in (("raw", "raw"), ("reduced", "reduced")):
                capture = folder / f"{species}-lod-{lod}-B.png"
                if capture.exists():
                    copied = copy_capture(capture, root / "img" / key, f"{species}-lod-{lod}-B")
                    lod_cells.append(figure(copied, root, f"B {lod_label} · {renderer_label}"))
        blocks.append(
            '<article class="view"><h3>Levels of detail, forced</h3><p class="desc">The same raised camera on the hero tree with one level forced on. In play, LOD0 shows up close, LOD1 in the middle distance and the impostor (a camera-facing image baked from LOD0) far away.</p>'
            f'<div class="cells">{"".join(lod_cells)}</div></article>')
        sections.append(
            f'<section id="{species}"><h2>{html.escape(title)}</h2><div class="refs">{"".join(ref_cards)}</div>{"".join(blocks)}</section>')
    perf_cells = []
    for key, renderer_label, folder in renderers:
        for species in SPECIES:
            for variant in ("A", "B"):
                capture = folder / f"perf-{species}-{variant}.png"
                if capture.exists():
                    copied = copy_capture(capture, root / "img" / key, f"perf-{species}-{variant}")
                    perf_cells.append(figure(copied, root, f"{variant} {species} field · {renderer_label}"))
    renderer_info = []
    for metrics, label in ((forward, "Forward+"), (compat, "Compatibility")):
        info = metrics.get("renderer", {})
        if info:
            renderer_info.append(f"{label}: {html.escape(info.get('method', ''))} on {html.escape(info.get('adapter', ''))}, {html.escape(info.get('display', ''))}, {info.get('resolution', ['?', '?'])[0]}×{info.get('resolution', ['?', '?'])[1]}")
    trees = compat.get("perf", {}).get("trees", forward.get("perf", {}).get("trees", "?"))
    attributions = "\n".join(
        f'<li><strong>{html.escape(m["role"])}:</strong> “<a href="{html.escape(m["url"])}">{html.escape(m["title"])}</a>” by {html.escape(m["author"])}, '
        f'licensed under <a href="{CC_BY}">CC BY 4.0</a>. Model page: {m["faces"]:,} triangles. {html.escape(m["note"])}'
        f'<br><span class="muted">Attribution text: “{html.escape(m["title"])}” by {html.escape(m["author"])} ({html.escape(m["url"])}), CC BY 4.0 ({CC_BY}).</span></li>'
        for m in SKETCHFAB)
    b_status = ("Variant B models are included below." if has_b else
                "Variant B is <strong>not downloaded yet</strong>: this machine has no Sketchfab session or token, and Sketchfab's download API requires one (it answered 401). Once the owner signs in and downloads the two models, the same driver adds B to every view with no other changes.")
    page = f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Tree shootout</title>
<style>
:root {{ --bg: #f6f5f1; --panel: #ffffff; --ink: #1d2124; --muted: #5f6870; --line: #d9d6cf; --accent: #2f6b4f; --pending: #efe9dc; }}
@media (prefers-color-scheme: dark) {{ :root:not([data-theme="light"]) {{ --bg: #15181a; --panel: #1e2326; --ink: #e9ece8; --muted: #9aa5a0; --line: #343b3f; --accent: #8fd1ad; --pending: #2a2722; }} }}
:root[data-theme="dark"] {{ --bg: #15181a; --panel: #1e2326; --ink: #e9ece8; --muted: #9aa5a0; --line: #343b3f; --accent: #8fd1ad; --pending: #2a2722; }}
* {{ box-sizing: border-box; }}
body {{ margin: 0; background: var(--bg); color: var(--ink); font: 15px/1.5 system-ui, -apple-system, "Segoe UI", sans-serif; }}
header, section, footer {{ max-width: 1700px; margin: 0 auto; padding: 16px; }}
h1 {{ font-size: 1.6rem; margin: 8px 0; }}
h2 {{ font-size: 1.3rem; border-bottom: 2px solid var(--accent); padding-bottom: 4px; margin-top: 32px; }}
h3 {{ font-size: 1.05rem; margin: 0 0 4px; }}
nav {{ position: sticky; top: 0; background: var(--bg); border-bottom: 1px solid var(--line); z-index: 2; }}
nav div {{ max-width: 1700px; margin: 0 auto; padding: 8px 16px; display: flex; gap: 16px; flex-wrap: wrap; }}
nav a, a {{ color: var(--accent); }}
.muted, .desc, .meta {{ color: var(--muted); }}
.desc, .meta {{ margin: 0 0 8px; font-size: 0.9rem; }}
.view {{ background: var(--panel); border: 1px solid var(--line); border-radius: 8px; padding: 12px; margin: 16px 0; }}
.cells {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 380px), 1fr)); gap: 10px; }}
.refs {{ display: grid; grid-template-columns: repeat(auto-fill, minmax(min(100%, 300px), 1fr)); gap: 10px; }}
figure {{ margin: 0; }}
figure img {{ width: 100%; height: auto; display: block; border-radius: 4px; border: 1px solid var(--line); }}
figcaption {{ font-size: 0.85rem; color: var(--muted); margin-top: 4px; }}
.ref figcaption {{ font-size: 0.8rem; }}
.refcell figcaption {{ color: var(--accent); font-weight: 600; }}
.placeholder {{ aspect-ratio: 16 / 9; display: grid; place-items: center; text-align: center; padding: 12px; background: var(--pending); border: 1px dashed var(--line); border-radius: 4px; color: var(--muted); }}
table {{ border-collapse: collapse; width: 100%; font-size: 0.9rem; background: var(--panel); }}
th, td {{ border: 1px solid var(--line); padding: 6px 8px; text-align: left; vertical-align: top; }}
thead th {{ background: var(--bg); }}
.scroll {{ overflow-x: auto; }}
ul {{ padding-left: 20px; }}
</style>
</head>
<body>
<header>
<h1>Tree shootout: fan palm and Monterey cypress</h1>
<p>Evaluation only (2026-11-02); nothing here goes to main. Both species stand at their real Treasure Island spots: a row of twelve fan palms along Building 1's Avenue of the Palms frontage (the parking-lot edge, OSM w96665914) and a grove of twelve cypresses on the open ground south of Building 1. Each view uses one camera for every variant; only the trees change. The island's current placeholder vegetation, the HUD and the player avatar are hidden.</p>
<ul>
<li><strong>A — generated in code.</strong> Parametric GDScript trees with LOD0, LOD1 and a far impostor, using alpha-scissor foliage cards. Their bark, frond and foliage textures are original images made with <code>tools/generate-texture</code>.</li>
<li><strong>B — Sketchfab CC BY.</strong> {b_status}</li>
<li>SpeedTree was dropped by owner decision.</li>
</ul>
<p class="muted">{"<br>".join(renderer_info)}</p>
</header>
<nav><div><a href="#palm">Fan palm</a><a href="#cypress">Monterey cypress</a><a href="#metrics">Metrics</a><a href="#attributions">Attributions</a></div></nav>
{"".join(sections)}
<section id="metrics">
<h2>Metrics</h2>
<p class="muted">Triangles and texture sizes are counted from the actual meshes and the imported textures. A tree costs one draw per mesh surface, before shadow passes. Texture memory is the GPU size as imported: VRAM-compressed (BC1/BC3 on desktop) with mipmaps.</p>
<div class="scroll"><table>
<thead><tr><th>Variant</th><th>LOD0 tris</th><th>LOD1 tris</th><th>Far tris</th><th>Surfaces (draws) per tree</th><th>Texture memory</th><th>LOD switching</th></tr></thead>
<tbody>{variant_rows(forward)}</tbody></table></div>
<h3 style="margin-top:16px">Frame cost with {trees} trees</h3>
<p class="muted">These are narrow local measurements: this devcontainer and GPU at 1600×900 with vsync off, one camera at the spawn point looking east over {trees} trees spread around Building 1, and medians over 240 frames after 90 warm-up frames. They are not Mac or browser numbers. They include the whole island. The values in brackets are the cost added over the no-tree baseline.</p>
<div class="scroll"><table>
<thead><tr><th rowspan=2>Configuration</th><th colspan=6>Compatibility (web stand-in)</th><th colspan=6>Forward+</th></tr>
<tr><th>frame ms</th><th>p95 ms</th><th>FPS</th><th>GPU ms</th><th>draw calls</th><th>primitives</th><th>frame ms</th><th>p95 ms</th><th>FPS</th><th>GPU ms</th><th>draw calls</th><th>primitives</th></tr></thead>
<tbody>{perf_rows(forward, compat)}</tbody></table></div>
<div class="cells" style="margin-top:10px">{"".join(perf_cells)}</div>
</section>
<section id="attributions">
<h2>Sketchfab models and attributions</h2>
<ul>{attributions}</ul>
<p class="muted">Variant A uses no third-party assets. Its textures were generated for this project and are not copies of any photograph. The reference photos on this page are private research captures and are not shipped anywhere.</p>
</section>
<footer class="muted">Built by tools/tree_shootout/build_gallery.py from the captures in {html.escape(str(args.forward))} and {html.escape(str(args.compat))}.</footer>
</body>
</html>
"""
    (root / "index.html").write_text(page)
    print(f"wrote {root / 'index.html'}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--forward", required=True)
    parser.add_argument("--compat", required=True)
    parser.add_argument("--refs", required=True)
    parser.add_argument("--out", required=True)
    build(parser.parse_args())


if __name__ == "__main__":
    main()
