// tools/web_trace/after_loading.mjs OUT_DIR: what a drive-trace session (tools/web_trace/session.sh) saw compiled
// once loading had ended. Reads OUT_DIR/log.json (the page's records: every WebGL program it saw linked, with the
// page's time, its kind, #defines and identifiers) and OUT_DIR/marks.json (the game's startup marks: each loading
// line as it went up, and TI:play_handoff, where the loading screen hands over to play). Writes
// OUT_DIR/programs.txt: each loading line's time, then every program compiled after the handoff, with the window it
// fell in (the start prompt and the trace's census, a step of the drive, a trigger) and its decoded variant.
// Prints one summary line (JSON) and exits 1 if any program was compiled after loading, 2 if the records are missing.
import fs from 'node:fs';
import path from 'node:path';

// The scene shader's specialization bits (Godot 4.7.2 drivers/gles3/shaders/scene.glsl) and its variants' defines:
// how a program is drawn, as opposed to which shader it is.
const SPEC = ['DISABLE_LIGHTMAP', 'DISABLE_LIGHT_DIRECTIONAL', 'DISABLE_LIGHT_OMNI', 'DISABLE_LIGHT_SPOT', 'DISABLE_LIGHT_AREA',
  'DISABLE_REFLECTION_PROBE', 'DISABLE_FOG', 'USE_DEPTH_FOG', 'USE_SUN_SCATTER', 'USE_RADIANCE_MAP', 'USE_LIGHTMAP', 'USE_SH_LIGHTMAP',
  'USE_LIGHTMAP_CAPTURE', 'USE_MULTIVIEW', 'RENDER_SHADOWS', 'RENDER_SHADOWS_LINEAR', 'SHADOW_MODE_PCF_5', 'SHADOW_MODE_PCF_13',
  'LIGHT_USE_PSSM2', 'LIGHT_USE_PSSM4', 'LIGHT_USE_PSSM_BLEND', 'BASE_PASS', 'USE_ADDITIVE_LIGHTING', 'APPLY_TONEMAPPING',
  'ADDITIVE_OMNI', 'ADDITIVE_SPOT', 'RENDER_MATERIAL', 'SECOND_REFLECTION_PROBE', 'LIGHTMAP_BICUBIC_FILTER', 'RENDER_MOTION_VECTORS',
  'USE_INSTANCING', 'MODE_RENDER_DEPTH'];
const DEFAULT = ['DISABLE_REFLECTION_PROBE', 'USE_RADIANCE_MAP', 'BASE_PASS', 'APPLY_TONEMAPPING'];

const dir = process.argv[2];
if (!dir) {
  console.error('usage: node tools/web_trace/after_loading.mjs OUT_DIR');
  process.exit(2);
}
const read = (name) => {
  try { return JSON.parse(fs.readFileSync(path.join(dir, name), 'utf8')); } catch (e) { return null; }
};
const log = read('log.json') || read('log-partial.json');
const marks = read('marks.json');
if (!log || !Array.isArray(log.programs) || !Array.isArray(marks)) {
  console.log(JSON.stringify({dir, error: 'no log.json with programs, or no marks.json'}));
  process.exit(2);
}
const handoff = (marks.find((m) => m[0] === 'TI:play_handoff') || marks.find((m) => m[0] === 'TI_BOOT:play_ready') || [])[1];
if (handoff === undefined) {
  console.log(JSON.stringify({dir, error: 'no TI:play_handoff mark: was the page opened with profile_startup=1, and did play start?'}));
  process.exit(2);
}
const lines = [];
// The loading screen's lines (main.gd marks each as "line <text>") and how long each stayed up.
const shown = marks.filter((m) => m[0].startsWith('TI:line ')).sort((a, b) => a[1] - b[1]);
shown.forEach((m, i) => {
  const until = i + 1 < shown.length ? shown[i + 1][1] : handoff;
  lines.push({line: m[0].slice('TI:line '.length).replace(/ /g, ' '), at_ms: m[1], ms: Math.round((until - m[1]) * 10) / 10});
});
// The windows after the handoff: the start prompt and the census until the trace's first step, then its steps and
// triggers (the page keeps the game's markers on its own clock).
const windows = [{at: handoff, name: 'start prompt and census'}];
for (const e of log.events || []) {
  if (e[1] === 'step' || e[1] === 'trigger') windows.push({at: e[0], name: e[1] === 'step' ? 'step ' + e[2] : 'trigger ' + e[2]});
}
windows.sort((a, b) => a.at - b.at);
const windowOf = (t) => {
  let name = windows[0].name;
  for (const w of windows) if (w.at <= t) name = w.name;
  return name;
};
const decode = (d) => {
  if (!d) return {kind: '?', variant: '?', features: '', ids: ''};
  const defines = String(d.defines || '').split(/\s+/).filter(Boolean);
  const own = new Set(defines);
  const spec = SPEC.filter((s) => own.has(s));
  const isDefault = DEFAULT.every((s) => own.has(s)) && spec.filter((s) => s !== 'USE_INSTANCING' && s !== 'MODE_RENDER_DEPTH').length === DEFAULT.length;
  const variant = (own.has('MODE_RENDER_DEPTH') ? 'depth' : 'color') + (own.has('USE_INSTANCING') ? '+instancing' : '') +
    (isDefault ? ' default' : own.has('MODE_RENDER_DEPTH') ? '' : own.has('DISABLE_REFLECTION_PROBE') ? '' : own.has('SECOND_REFLECTION_PROBE') ? ' in two probes' : ' in a probe');
  const features = defines.filter((s) => /^[A-Z][A-Z0-9_]+$/.test(s) && !SPEC.includes(s) && !s.endsWith('_CODE_USED')).join(' ');
  return {kind: d.kind, variant, features, ids: String(d.ids || '').split(',').slice(0, 8).join(',')};
};
const after = log.programs.filter((p) => p[0] > handoff).map((p) => ({t_s: Math.round((p[0] - handoff) / 100) / 10, ms: p[1], window: windowOf(p[0]), ...decode(p[3])}));
const byWindow = {};
for (const p of after) byWindow[p.window] = (byWindow[p.window] || 0) + 1;
const loading = log.programs.filter((p) => p[0] <= handoff);
const text = [
  `${dir}`,
  `loading: ${loading.length} programs (${Math.round(loading.reduce((s, p) => s + p[1], 0))} ms of compiling) before the play handoff at ${Math.round(handoff)} ms`,
  ...lines.map((l) => `  ${String(l.ms).padStart(8)} ms  ${l.line}`),
  `after loading: ${after.length} programs (${Math.round(after.reduce((s, p) => s + p.ms, 0))} ms)`,
  ...Object.entries(byWindow).map(([w, n]) => `  ${String(n).padStart(4)}  ${w}`),
  ...after.map((p) => `  ${String(p.t_s).padStart(7)} s  ${String(p.ms).padStart(6)} ms  ${p.window}  ${p.kind} ${p.variant}  [${p.features}]  ${p.ids}`),
].join('\n');
fs.writeFileSync(path.join(dir, 'programs.txt'), text + '\n');
console.log(JSON.stringify({dir, loading_programs: loading.length, after_loading: after.length, by_window: byWindow, handoff_ms: handoff, lines: lines.length}));
process.exit(after.length === 0 ? 0 : 1);
