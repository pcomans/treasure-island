#!/usr/bin/env node
// Checks the drive trace's page side (game/web/shell.html's trace script; the game's
// side is game/scripts/debug/drive_trace.gd) with stand-ins for the browser:
//   - without ?trace=drive (normal play) it does nothing: no WebGL, WebAssembly or
//     Web Audio call is wrapped, no frame loop or timer starts, no listener or
//     observer is added, nothing is read from or written to storage, and it defines
//     no global name (the script runs as a page's script would, in a context of its
//     own whose global names are checked after it);
//   - with ?trace=drive it wraps WebGL's stalling calls (and only times them: each
//     wrapped call returns what the browser's did), keeps a frame loop, and once the
//     game's records come in, names what each long frame's time went to: a frame whose
//     shader compiles took its time is a shader compile (gpu), one whose physics step
//     grew is the physics step (main thread), one the engine finished early but the
//     next frame came late is outside the engine (browser); it shows the results and
//     keeps them on the device. It sends nothing anywhere: no fetch, XMLHttpRequest,
//     sendBeacon, WebSocket, EventSource, RTCPeerConnection, dynamic import, image,
//     script, frame or link element, or src set to an address.
// Node only, no browser; under a second. Part of tools/test.sh.
//
//   node tools/check_web_trace.mjs [SHELL]   (SHELL: another copy of the page's shell)
import {readFileSync} from 'node:fs';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';
import {dirname, join} from 'node:path';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const shell = readFileSync(process.argv[2] || join(root, 'game/web/shell.html'), 'utf8');
const script = [...shell.matchAll(/<script>([\s\S]*?)<\/script>/g)].map((m) => m[1]).find((code) => code.includes('function tiTraceAnalyze('));
const failures = [];
const check = (ok, what) => { if (!ok) failures.push(what); };
if (!script) {
  console.log('FAIL: game/web/shell.html has no inline script with function tiTraceAnalyze');
  process.exit(1);
}
const NETWORK = [
  [/\bfetch\s*\(/, 'fetch'], [/XMLHttpRequest/, 'XMLHttpRequest'], [/sendBeacon/, 'sendBeacon'], [/WebSocket/, 'WebSocket'],
  [/EventSource/, 'EventSource'], [/RTCPeerConnection/, 'RTCPeerConnection'], [/\bimport\s*\(/, 'import()'],
  [/new\s+Image\b/, 'new Image'], [/createElement\s*\(\s*['"`](script|img|iframe|link)['"`]/, 'a script, img, iframe or link element'],
  [/\.src\s*=\s*['"`]?(https?:|\/\/)/, 'src set to an address'],
];
for (const [pattern, what] of NETWORK) check(!pattern.test(script), `the trace script must make no network call: it has ${what}`);

// A browser of stand-ins, counting every use the trace could make of it.
function browser(search) {
  const used = [];
  const use = (what) => used.push(what);
  let clock = 1000;
  const frames = [];
  const intervals = [];
  const element = () => {
    const el = {style: {}, children: [], value: '', textContent: '', width: 0, height: 0,
      append: (...c) => el.children.push(...c), appendChild: (c) => { el.children.push(c); return c; }, remove: () => {},
      addEventListener: () => {}, focus: () => {}, select: () => {}, setSelectionRange: () => {}, click: () => {},
      getContext: () => new Proxy({}, {get: (t, k) => (k in t ? t[k] : () => {}), set: (t, k, v) => { t[k] = v; return true; }})};
    return el;
  };
  const body = element();
  const gl = {};
  for (const name of ['shaderSource', 'compileShader', 'getShaderParameter', 'attachShader', 'linkProgram', 'getProgramParameter',
    'texImage2D', 'texSubImage2D', 'compressedTexImage2D', 'compressedTexSubImage2D', 'texImage3D', 'texSubImage3D',
    'compressedTexImage3D', 'texStorage2D', 'texStorage3D', 'generateMipmap', 'bufferData', 'readPixels', 'getBufferSubData',
    'clientWaitSync', 'finish', 'getError']) {
    gl[name] = function () { return 'gl:' + name; };
  }
  // A shader's compile status waits for its compile: 110 ms here.
  gl.getShaderParameter = function () { clock += 110; return true; };
  gl.getProgramParameter = function () { clock += 10; return true; };
  const audio = {createBufferSource: function () { return 'source'; }};
  const memoryProto = {grow: function () { return 1; }};
  const wasm = {Memory: function () {}, instantiate: () => Promise.resolve({instance: {exports: {}}}), instantiateStreaming: () => Promise.resolve({instance: {exports: {}}})};
  wasm.Memory.prototype = memoryProto;
  const originals = {gl: {...gl}, audio: audio.createBufferSource, grow: memoryProto.grow, instantiate: wasm.instantiate, streaming: wasm.instantiateStreaming};
  const storage = {data: {}, getItem(k) { use('storage'); return this.data[k] ?? null; }, setItem(k, v) { use('storage'); this.data[k] = String(v); }};
  const win = {location: {search, pathname: '/'}, devicePixelRatio: 3, isSecureContext: true, top: null, self: null,
    addEventListener: () => use('window listener'), matchMedia: () => ({matches: false}),
    WebGL2RenderingContext: {prototype: gl}, BaseAudioContext: {prototype: audio}};
  Object.defineProperty(win, 'localStorage', {get: () => { use('storage'); return storage; }});
  const doc = {visibilityState: 'visible', body, getElementById: (id) => (id === 'canvas' ? null : null), createElement: () => element(),
    addEventListener: () => use('document listener'), querySelector: () => null, execCommand: () => true};
  const globals = {
    window: win, location: win.location, document: doc, navigator: {userAgent: 'stand-in', maxTouchPoints: 5, hardwareConcurrency: 8},
    screen: {width: 874, height: 402}, innerWidth: 874, innerHeight: 402, devicePixelRatio: 3,
    performance: {now: () => clock, memory: null}, WebGL2RenderingContext: win.WebGL2RenderingContext, BaseAudioContext: win.BaseAudioContext,
    WebAssembly: wasm, PerformanceObserver: function () { use('observer'); return {observe: () => {}}; },
    requestAnimationFrame: (cb) => { use('frame loop'); frames.push(cb); return frames.length; },
    setInterval: (cb) => { use('timer'); intervals.push(cb); return intervals.length; },
    setTimeout: () => 0, matchMedia: win.matchMedia, Blob: function () {}, URL: {createObjectURL: () => 'blob:x', revokeObjectURL: () => {}},
    URLSearchParams, console,
  };
  // The script runs as a page's classic script does, at the top of a context of its own:
  // a name it declares there is a global name of that context.
  const before = new Set(Object.keys(globals));
  const context = vm.createContext(globals);
  vm.runInContext(script, context);
  const added = Object.keys(context).filter((name) => !before.has(name));
  for (const name of ['TI_TRACE_FRAME', 'TI_TRACE_CAUSES', 'tiTraceFrames', 'tiTraceAnalyze', 'tiTraceText']) {
    if (!added.includes(name) && vm.runInContext(`typeof ${name}`, context) !== 'undefined') added.push(name);
  }
  const exports = win.__tiTraceLib || {};
  return {exports, added, used, win, gl, audio, memoryProto, wasm, originals, frames, intervals, storage,
    tick: (ms) => { clock += ms; const due = frames.splice(0); for (const cb of due) cb(clock); }, advance: (ms) => { clock += ms; }, clock: () => clock};
}

// Normal play: the script does nothing.
{
  const b = browser('');
  check(b.used.length === 0, `without ?trace=drive the trace must use nothing of the browser, but it used: ${[...new Set(b.used)].join(', ')}`);
  check(Object.entries(b.originals.gl).every(([name, fn]) => b.gl[name] === fn), 'without ?trace=drive no WebGL call may be wrapped');
  check(b.audio.createBufferSource === b.originals.audio && b.memoryProto.grow === b.originals.grow
    && b.wasm.instantiate === b.originals.instantiate && b.wasm.instantiateStreaming === b.originals.streaming, 'without ?trace=drive no Web Audio or WebAssembly call may be wrapped');
  check(b.win.__tiTrace === undefined && b.win.__tiTraceLib === undefined && b.added.length === 0, `without ?trace=drive the page must have no global of the trace's, but it has: ${[...b.added, ...(b.win.__tiTrace ? ['window.__tiTrace'] : []), ...(b.win.__tiTraceLib ? ['window.__tiTraceLib'] : [])].join(', ')}`);
}
for (const other of ['?trace=other', '?trace=', '?store=1&profile_startup=1']) {
  const b = browser(other);
  check(b.used.length === 0 && b.win.__tiTrace === undefined && b.added.length === 0, `${other} is not the drive trace, but the trace script ran or left a name`);
}

// The drive trace: wrappers that only time, a frame loop, and the analysis.
{
  const b = browser('?trace=drive');
  const {tiTraceText} = b.exports;
  check(typeof b.win.__tiTrace === 'object', 'with ?trace=drive the page must have window.__tiTrace');
  check(b.used.includes('frame loop'), 'with ?trace=drive the trace must keep a frame loop');
  check(b.gl.compileShader !== b.originals.gl.compileShader && b.gl.texImage2D !== b.originals.gl.texImage2D, 'with ?trace=drive WebGL\'s stalling calls must be wrapped');
  const ctx = Object.assign(Object.create(b.gl), {COMPILE_STATUS: 1, LINK_STATUS: 2});
  const shader = {};
  check(ctx.compileShader(shader) === 'gl:compileShader' && ctx.texImage2D(1, 0, 1, 4, 4, 0, 1, 1, null, 0) === 'gl:texImage2D', 'a wrapped WebGL call must return what the browser\'s returned');
  // The game's header as play starts, then frames: each page frame k at raf[k], the
  // game's frame starting 0.5 ms after it.
  const fields = ['t', 'dt', 'gap', 'phys_n', 'phys_ms', 'sphys_ms', 'vphys_ms', 'proc_ms', 'sproc_ms', 'vproc_ms', 'draw_ms', 'dc', 'obj', 'prim_k', 'x', 'y', 'z', 'speed', 'flags', 'step', 'leg', 'nadd', 'nrem', 'tex_mb', 'buf_mb', 'act', 'pairs'];
  const steps = ['wait', 'baseline', 'to_car', 'drive', 'stop', 'out', 'walk', 'run', 'rise', 'hover', 'drop', 'landed', 'done'];
  b.tick(16.7);
  const origin = b.clock() + 0.5;
  b.win.__tiTrace.begin(JSON.stringify({fields, steps, page_ms_at_origin: origin, route: [[0, 0], [10, 10]], outline: [], viewport: [1956, 900], scale_3d: 0.67}));
  const rows = [];
  const frame = (i, kind) => {
    // Frame i: 16.7 ms, or a long one of kind compile (shader compiles in its drawing),
    // physics (its physics step) or outside (the engine done early, the next frame late).
    const t = b.clock() + 0.5 - origin;
    const row = new Array(fields.length).fill(0);
    Object.assign(row, {0: t, 3: 1, 4: 2, 5: 1, 7: 1, 8: 0.5, 10: 3, 11: 400, 14: i, 16: -i, 17: 10, 19: 3, 20: 1});
    let ms = 16.7;
    if (kind === 'compile') { row[10] = 123; ctx.compileShader(shader); ctx.getShaderParameter(shader, 1); ms = 130; }
    if (kind === 'physics') { row[4] = 80; row[3] = 4; ms = 90; }
    if (kind === 'outside') { ms = 160; }
    b.advance(ms - (kind === 'compile' ? 110 : 0));
    rows.push(...row);
    b.tick(0);
  };
  for (let i = 0; i < 300; i += 1) frame(i, i === 100 ? 'compile' : i === 150 ? 'physics' : i === 200 ? 'outside' : '');
  b.win.__tiTrace.engine(JSON.stringify({rows, events: [[150 * 16.7, 'node+', '3: 3x Vehicles Node3D (Car)', 3]], fields: fields.length}));
  b.win.__tiTrace.end(JSON.stringify({result: 'complete', frames: 300}));
  const a = b.win.__tiTrace.analysis();
  const byCause = Object.fromEntries(a.worst.map((w) => [Math.round(w.x), w.cause]));
  check(a.long === 3 && a.very_long === 2, `three long frames (two of 100 ms or more) must be found, not ${a.long} (${a.very_long})`);
  check(byCause[100] === 'compile' && a.causes.compile && a.causes.compile.class === 'gpu', `a frame whose shader compiles took its time must be a shader compile (gpu), not ${byCause[100]}`);
  check(byCause[150] === 'phys_engine' && a.causes.phys_engine && a.causes.phys_engine.class === 'main thread', `a frame whose physics step grew must be the physics step (main thread), not ${byCause[150]}`);
  check(byCause[200] === 'outside' && a.causes.outside && a.causes.outside.class === 'browser', `a frame the engine finished early but came late must be outside the engine (browser), not ${byCause[200]}`);
  check(typeof tiTraceText === 'function', 'with ?trace=drive the page must give its analysis as window.__tiTraceLib');
  const text = typeof tiTraceText === 'function' ? tiTraceText({run: 'check'}, a) : '';
  check(/Long frames \(33 ms or more\): 3/.test(text) && /shader compile/.test(text), 'the results text must give the long frames and their causes');
  const kept = JSON.parse(b.storage.data['ti-trace:meta'] || 'null');
  check(kept && kept.status === 'done' && b.storage.data['ti-trace:text'], 'the results must be kept on the device when the drive ends');
}

if (failures.length) {
  for (const f of failures) console.log('FAIL: ' + f);
  process.exit(1);
}
console.log('PASS: the drive trace\'s page side does nothing without ?trace=drive (no wrapper, frame loop, timer, listener, observer, storage or global name), has no network call of any kind, and with it times WebGL\'s stalling calls without changing what they return and names a long frame\'s cause: shader compile (gpu), the physics step (main thread), outside the engine (browser); its results are kept on the device');
