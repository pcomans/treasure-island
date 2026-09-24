"""Build the offline, pinned MAIN / TEST contact sheet; no runtime changes."""
from pathlib import Path
import html
import json

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'evidence/housing-family-experiment'
MAIN = '9c7f2440d3db6a7f2d0a5d474c612c0362a01c16'
TEST = '431343935f6ac9e693db511b9b0c7c8050136565'
RUN = 'main-vs-test-001'
recent = ['w96215646', 'w96215653', 'w96215659', 'w96215670', 'w96215691', 'w96665911', 'w96215678', 'w96665904']
notes = {
    'w96215646': 'Dark canopy fascia; parking, walk and lawn separation. Canopy supports and extent remain inferred.',
    'w96215653': 'Tall open slats beside short solid screens; simplified recess and screen details remain.',
    'w96215659': 'Tall open slats beside short solid screens; simplified recess and screen details remain.',
    'w96215670': 'Restored lower frontage. Canopy attachment and ownership remain unknown.',
    'w96215691': 'Restored lower openings and pale entry variation; unverified facade regions remain.',
    'w96665911': 'Roof/apron and boarded-opening study; roof proportions remain inferred.',
    'w96215678': 'Restored frontage groups and broad apron; roof rise and screen depth remain inferred.',
    'w96665904': 'Restored frontage groups and thin story edge; roof rise and screen depth remain inferred.',
    'w96215673': 'Richer original roof and tagged site components retained in the preview.',
    'w96215674': 'Richer original roof and tagged site components retained in the preview.',
    'w96215685': 'Broad story-band variant; foreground canopy partly occludes this view.',
}
targets = json.loads((ROOT / 'game/tests/housing_family_experiment/main_vs_test.json').read_text())['targets']
targets.sort(key=lambda t: (recent.index(t['source_key']) if t['source_key'] in recent else len(recent), t['label']))
e = html.escape
parts = [f'''<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Treasure Island · MAIN / TEST</title>
<style>
:root{{color-scheme:dark;--bg:#11191e;--panel:#1c282f;--line:#344750;--muted:#b5c4cc;--accent:#bce0d4}}*{{box-sizing:border-box}}body{{margin:0;background:var(--bg);color:#edf3f5;font:16px/1.55 system-ui,sans-serif}}a{{color:var(--accent)}}header,main,footer{{max-width:1900px;margin:auto;padding:28px clamp(18px,3vw,56px)}}header{{padding-bottom:16px}}.eyebrow{{color:var(--accent);font-size:12px;font-weight:700;letter-spacing:.16em;text-transform:uppercase}}h1{{font-size:clamp(30px,4vw,52px);line-height:1.1;margin:12px 0}}h2{{font-size:22px;margin:0}}p{{margin:10px 0}}.intro{{max-width:1000px;color:var(--muted)}}.notice{{border-left:3px solid #e9ba77;background:#2a2925;padding:14px 18px;max-width:1100px}}details{{font-size:14px;color:var(--muted)}}summary{{cursor:pointer;color:var(--accent)}}details code{{overflow-wrap:anywhere}}.versions{{display:flex;gap:22px;flex-wrap:wrap;margin:14px 0}}.versions span{{display:block;color:var(--muted);font-size:12px;overflow-wrap:anywhere}}code{{font-size:.85em}}.toolbar{{position:sticky;top:0;z-index:2;background:#172127f5;border-block:1px solid var(--line);padding:12px clamp(18px,3vw,56px);display:flex;gap:12px;align-items:center;flex-wrap:wrap}}input,select,button{{font:inherit;color:inherit;background:var(--panel);border:1px solid #52646e;border-radius:6px;padding:9px 12px}}input{{width:min(420px,100%)}}select{{max-width:100%}}button{{cursor:pointer}}button:hover,a:hover{{filter:brightness(1.2)}}#count{{color:var(--muted);font-size:14px}}main{{padding-top:8px}}article{{scroll-margin-top:100px;border-bottom:1px solid var(--line);padding:28px 0 34px}}.cardhead{{display:flex;align-items:baseline;gap:14px;flex-wrap:wrap}}.id{{color:var(--muted);font-family:monospace}}.tag{{color:var(--accent);font-size:12px;border:1px solid #45675f;border-radius:20px;padding:2px 9px}}.note{{color:var(--muted);max-width:1150px;font-size:14px;margin-bottom:16px}}.pair{{display:grid;grid-template-columns:1fr 1fr;gap:16px}}figure{{margin:0;min-width:0;background:#0a1014;border:1px solid var(--line);border-radius:8px;overflow:hidden}}figcaption{{display:flex;justify-content:space-between;padding:10px 14px;font-size:13px;background:var(--panel)}}figcaption b{{letter-spacing:.06em}}figcaption span{{color:var(--muted)}}img{{display:block;width:100%;height:auto;aspect-ratio:8/5;object-fit:contain}}.empty{{padding:40px 0;color:var(--muted)}}footer{{color:var(--muted);font-size:14px}}[hidden]{{display:none!important}}@media(max-width:760px){{.pair{{grid-template-columns:1fr}}.toolbar{{position:static}}article{{scroll-margin-top:12px}}figcaption span{{font-size:11px}}}}@media print{{.toolbar{{display:none}}article{{break-inside:avoid}}}}
</style></head><body><header><div class="eyebrow">Treasure Island · saved art comparison</div><h1>MAIN / TEST</h1><p class="intro">24 matched pairs: MAIN left, TEST right (stacked on narrow screens). Recent refinements first; select an image to enlarge.</p>
<div class="notice"><b>TEST housing is a preview.</b> Enabling it in normal gameplay is a separate integration step.</div>
<div class="versions"><div><b>MAIN · existing scene</b><span><code>{MAIN[:7]}</code></span></div><div><b>TEST · shared-family preview</b><span><code>{TEST[:7]}</code></span></div></div>
<details><summary>Capture details</summary><p class="intro">The driver switches A/B visuals in the same loaded world with matching cameras and lighting; these are not separate gameplay launches. Normal gameplay is unchanged, and merging this code alone does not enable the preview.</p><p class="intro">Capture: <code>{RUN}</code> · originals: 1440 × 900.<br>Finished <time datetime="2026-09-24T21:02:22.194725Z">2026-09-24 21:02:22 UTC</time>.</p><p class="intro">MAIN <code>{MAIN}</code><br>TEST <code>{TEST}</code></p></details></header>
<div class="toolbar"><label for="filter">Find a building</label><input id="filter" type="search" placeholder="Address or source ID" autocomplete="off"><label for="jump">Jump to</label><select id="jump"><option value="">Choose a building…</option>''']
for t in targets:
    parts.append(f'<option value="{e(t["source_key"])}">{e(t["label"])} · {e(t["source_key"])}</option>')
parts.append('</select><button id="clear" type="button">Clear</button><span id="count" role="status" aria-live="polite">24 of 24 buildings</span></div><main><p id="empty" class="empty" hidden>No matching buildings. Try a street name or source ID.</p>')
for t in targets:
    sid = t['source_key']
    parts.append(f'<article id="{e(sid)}" data-search="{e(t["label"].lower()+" "+sid)}"><div class="cardhead"><h2>{e(t["label"])}</h2><span class="id">{e(sid)}</span>'+('<span class="tag">Recently refined</span>' if sid in recent else '')+f'</div><p class="note">{e(notes.get(sid,"Shared-family frontage study; dimensions and obscured or hidden details remain inferred or unverified."))}</p><div class="pair">')
    for phase,label,desc in [('A','MAIN','Existing scene'),('B','TEST','Shared-family preview')]:
        src=f'{RUN}/images/{sid}-{phase}.png'
        parts.append(f'<figure><figcaption><b>{label}</b><span>{desc} · original image ↗</span></figcaption><a href="{src}" target="_blank" rel="noopener" aria-label="Open {e(t["label"])} {label} original"><img src="{src}" loading="lazy" width="1440" height="900" alt="{e(t["label"])} — {label}"></a></figure>')
    parts.append('</div></article>')
parts.append('''</main><footer><p>Frontage comparisons, not whole-building acceptance. Source identity, gameplay integration, collision fit and release decisions remain separate. Private reference photographs are not included.</p><p><a href="index.html">Earlier comparison gallery</a> · <a href="../../discovery/HOUSING_FAMILY_INSTANCES.md">Canonical inventory and scope</a> · <a href="../../game/tests/housing_family_experiment/README.md">Reproduction notes</a> · <a href="main-vs-test-001/images/capture-receipt.json">Capture receipt</a> · <a href="main-vs-test-001/result.json">Native result</a></p></footer>
<script>
const filter=document.querySelector('#filter'), cards=[...document.querySelectorAll('article')], count=document.querySelector('#count'), jump=document.querySelector('#jump');
function apply(){const q=filter.value.trim().toLowerCase();let n=0;for(const card of cards){card.hidden=!card.dataset.search.includes(q);if(!card.hidden)n++;}count.textContent=`${n} of ${cards.length} buildings`;document.querySelector('#empty').hidden=n!==0;}
filter.addEventListener('input',apply);document.querySelector('#clear').addEventListener('click',()=>{filter.value='';apply();filter.focus();});jump.addEventListener('change',()=>{if(!jump.value)return;filter.value='';apply();const card=document.getElementById(jump.value);card.scrollIntoView({behavior:'smooth',block:'start'});history.replaceState(null,'','#'+jump.value);});
</script></body></html>''')
(OUT/'main-vs-test.html').write_text(''.join(parts))
print(OUT/'main-vs-test.html')
