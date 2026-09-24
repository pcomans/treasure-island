from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[3];out=ROOT/'evidence/housing-family-experiment'
manifest=json.loads((ROOT/'game/tests/housing_family_experiment/all23.json').read_text())
parts=['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Housing family comparison</title><style>body{background:#161c20;color:#eee;font:16px system-ui;max-width:1600px;margin:24px auto;padding:0 20px}a{color:#9cd8ff}.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px}img{width:100%;display:block}section{margin:36px 0;border-top:1px solid #48545c;padding-top:12px}small,p{color:#bdc8ce}nav{display:flex;gap:8px;flex-wrap:wrap}nav a{background:#29333a;padding:6px 10px;border-radius:4px}h2{margin-bottom:4px}@media(max-width:800px){.pair{grid-template-columns:1fr}}</style><h1>Existing / Shared housing family</h1><p>23 provisional candidates in the actual source world. Each pair uses the same camera and lighting. Select an image for its original 1440 × 900 pixels.</p><p>Existing is baseline <code>9c7f244</code>. Shared family is a render-only branch experiment: original collisions and receivers remain. No production, physics or recognition acceptance is implied.</p><nav>']
for t in manifest['targets']:parts.append(f'<a href="#{t["source_key"]}">{html.escape(t["label"])}</a>')
parts.append('</nav>')
for t in manifest['targets']:
 cfg=json.loads((ROOT/t['config'].replace('res://','')).read_text())
 notes=['Provisional branch study — no production acceptance']
 if t['source_key'] in {'w96665904','w96215691','w96215678','w96665911','w96215670'}:notes.append('Incomplete regional study — blank lower fields and unverified elevations remain')
 if t['source_key']=='w96665911':notes.append('Farther three-quarter view; shallow roof silhouette remains a review limitation')
 if cfg.get('retain_production_roof'):notes.append('Retains production roof and tagged site components')
 if cfg.get('broad_band'):notes.append('Sloped story band')
 if cfg.get('roof_kind'):notes.append('Shared shallow hip roof variant; visual readability under review')
 if cfg.get('carport') or cfg.get('carports'):notes.append('Per-site canopy segments')
 if t['source_key']=='w96215670':notes.append('Canopy ownership unknown; no attachment invented')
 parts.append(f'<section id="{t["source_key"]}"><h2>{html.escape(t["label"])}</h2><p><code>{t["source_key"]}</code> · {" · ".join(notes)}</p><div class="pair">')
 for phase,label in [('A','Existing'),('B','Shared family')]:
  src=f'all23-006/images/{t["id"]}-{phase}.png';assert (out/src).exists();parts.append(f'<div><h3>{label}</h3><a href="{src}"><img loading="lazy" src="{src}" alt="{html.escape(t["label"])} — {label}"></a></div>')
 parts.append('</div></section>')
parts.append('<section><h2>Scope and remaining inventory</h2><p>These 23 source-associated frontages were selected from March 2025 reference photographs. Private originals remain outside this gallery. Dimensions and obscured details are production inference or unknown.</p><p>This gallery preserves the 23-target, 46-image checkpoint. See the <a href="../../discovery/HOUSING_FAMILY_INSTANCES.md">canonical target inventory</a> for current reference coverage and remaining candidates; later reference-only confirmation does not add captured or accepted buildings here.</p><p>Final native originals are included; failed and earlier visual HOLD attempts remain locally retained outside this checkpoint. Reproduction instructions: <code>game/tests/housing_family_experiment/README.md</code>. This gallery presents final run 006. Independent visual review found a useful provisional A/B experiment: shared trim and screen regressions substantially repaired and 1221 roof variation restored. Five incomplete regional studies remain labeled above. 1229 roof/apron fidelity remains unresolved; 1227 and 1234 screens are denser than the baseline, and 1226 is partly occluded. No game export or production promotion was performed.</p></section></html>')
(out/'index.html').write_text(''.join(parts))
print(out/'index.html')
