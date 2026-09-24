from pathlib import Path
import json,html
ROOT=Path(__file__).resolve().parents[3];out=ROOT/'evidence/housing-family-experiment'
manifest=json.loads((ROOT/'game/tests/housing_family_experiment/all23.json').read_text())
extra=json.loads((ROOT/'game/tests/housing_family_experiment/quality_round4.json').read_text())
manifest['targets'] += extra['targets']
# Reviewed capture selection, not a claim that every image reflects current source.
CAPTURE_OVERRIDES = {'w96215691': 'quality-round1-003', 'w96665911': 'quality-round1-003', 'w96215678': 'quality-round2-004', 'w96665904': 'quality-round2-004', 'w96215670': 'quality-round3-001', 'w96215646': 'quality-round4-002'}
parts=['<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Housing family comparison</title><style>body{background:#161c20;color:#eee;font:16px system-ui;max-width:1600px;margin:24px auto;padding:0 20px}a{color:#9cd8ff}.pair{display:grid;grid-template-columns:1fr 1fr;gap:12px}img{width:100%;display:block}section{margin:36px 0;border-top:1px solid #48545c;padding-top:12px}small,p{color:#bdc8ce}nav{display:flex;gap:8px;flex-wrap:wrap}nav a{background:#29333a;padding:6px 10px;border-radius:4px}h2{margin-bottom:4px}@media(max-width:800px){.pair{grid-template-columns:1fr}}</style><h1>Existing / Shared housing family</h1><p>Latest independently reviewed pairs for 24 provisional candidates: 1204 and 1229 use focused round 1, 1205 and 1237 use focused round 2, 1397 uses focused round 3, 1394 uses focused round 4, and the other 18 reuse their prior run 006 captures. These retained images are not current-source proof. Each pair preserves its original matching camera and lighting. Select an image for its original 1440 × 900 pixels.</p><p>Existing is baseline <code>9c7f244</code>. Shared family is a render-only branch experiment: original collisions and receivers remain. No production, physics or recognition acceptance is implied.</p><nav>']
for t in manifest['targets']:parts.append(f'<a href="#{t["source_key"]}">{html.escape(t["label"])}</a>')
parts.append('</nav>')
for t in manifest['targets']:
 run=CAPTURE_OVERRIDES.get(t['source_key'],'all23-006')
 notes=['Provisional branch study — no production acceptance', 'Capture: '+run]
 if t['source_key'] in {'w96665904','w96215691','w96215678','w96665911','w96215670'}:notes.append('Incomplete regional study — unverified facade regions remain')
 if t['source_key']=='w96665911':notes.append('Focused round 1 improves roof/apron readability; proportions remain art inference')
 if t['source_key'] in {'w96215673','w96215674'}:notes.append('Retains production roof and tagged site components')
 if t['source_key'] in {'w96215652','w96215677','w96215678','w96215685','w96665911'}:notes.append('Sloped story band')
 if t['source_key'] in {'w96665904','w96665911'}:notes.append('Shared shallow hip roof variant; visual readability under review')
 if t['source_key'] in {'w96215673','w96215674','w96215659','w96215688','w96215651','w96215691','w96215666','w96215653','w96215682'}:notes.append('Per-site canopy segments')
 if t['source_key']=='w96215670':notes.append('Canopy ownership unknown; no attachment invented')
 parts.append(f'<section id="{t["source_key"]}"><h2>{html.escape(t["label"])}</h2><p><code>{t["source_key"]}</code> · {" · ".join(notes)}</p><div class="pair">')
 for phase,label in [('A','Existing'),('B','Shared family')]:
  src=f'{run}/images/{t["id"]}-{phase}.png';assert (out/src).exists();parts.append(f'<div><h3>{label}</h3><a href="{src}"><img loading="lazy" src="{src}" alt="{html.escape(t["label"])} — {label}"></a></div>')
 parts.append('</div>')
 if t['source_key']=='w96215646':
  parts.append('<p><a href="quality-round4.html">Focused comparison</a>. Pale canopy fascia and parking/ground separation remain fidelity limitations; inferred support is not structural ownership.</p>')
 elif t['source_key'] in CAPTURE_OVERRIDES:
  comparison=run.rsplit('-',1)[0]+'.html'
  parts.append(f'<p>Historical run 006: <a href="all23-006/images/{t["id"]}-A.png">Existing A</a> · <a href="all23-006/images/{t["id"]}-B.png">Previous shared B</a>. <a href="{comparison}">Focused three-way comparison</a>.</p>')
 parts.append('</section>')
parts.append('<section><h2>Scope and remaining inventory</h2><p>These 24 source-associated frontages were selected from March 2025 reference photographs. Private originals remain outside this gallery. Dimensions and obscured details are production inference or unknown.</p><p>This gallery selects 24 reviewed A/B pairs while preserving their original capture dates and sources. See the <a href="../../discovery/HOUSING_FAMILY_INSTANCES.md">canonical target inventory</a> for current reference coverage and remaining candidates; the original all23 manifest remains frozen; 1394 adds a separate provisional pair without acceptance credit.</p><p>Final native originals are included; failed and earlier visual HOLD attempts remain locally retained outside this checkpoint. Reproduction instructions: <code>game/tests/housing_family_experiment/README.md</code>. Run 006 remains the prior reviewed evidence for unchanged selections; focused rounds materially improved 1204/1229 and 1205/1237 as provisional studies. Historical images remain accessible above. Simplified recesses/screens/ground and unverified regions remain; 1227 and 1234 screens are denser than the baseline, and 1226 is partly occluded. No game export or production promotion was performed.</p></section></html>')
(out/'index.html').write_text(''.join(parts))
print(out/'index.html')
