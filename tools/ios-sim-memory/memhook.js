// memhook.js (tools/ios-sim-memory; webkit-memory-20261116 memhook-wk.js): test-only, injected over WebDriver; never shipped. memhook3.js plus a record of the AudioContexts (M.audio.contexts, M.audioState()).
// memhook3.js: memhook2.js plus a live GL buffer size histogram (log2) and the totals with each buffer rounded up to
// 4 KiB and to 16 KiB pages (gl.bufHist, gl.buf4k, gl.buf16k).
// memhook2.js (iphone-memory-20261116 takeover): memhook.js plus a count of reads from the downloaded pack, to see
// whether anything still reads it after the game is ready (the "free the pack after load" question). Emscripten's
// MEMFS reads a file with contents.subarray(); the pack is the only typed array over 100 MB that is not the wasm
// memory, so subarray() calls on it are the pack reads (calls, bytes, and the time of each of the last 200).
// Test-only memory hook for iphone-memory-20261116, run as a tools/browser init script (AGENT_BROWSER_INIT_SCRIPTS)
// before the page's own scripts; never shipped, changes no game behaviour. Adapted from web-memory-20261106's
// mem-hook.js without its pack-read tracking (it wrapped Uint8Array.prototype.subarray). Records: the wasm Memory
// (exported or constructed in JS) and its byte length, performance.memory, and WebGL2 allocations by object (texture
// levels, buffers, renderbuffers, programs and shaders, with the formats and sizes asked for) at every
// performance.mark, at every wasm memory growth, and every TICK_MS; M.dump() returns everything as JSON.
(() => {
  if (window.__mem) return;
  const TICK_MS = 10000;
  const M = (window.__mem = {wasm: null, marks: [], ticks: [], grows: [], t0: performance.timeOrigin, audio: {buffers: 0, bytes: 0, sources: 0}, pack: {calls: 0, bytes: 0, size: 0, last: []}});
  const origSubarray = Uint8Array.prototype.subarray;
  Uint8Array.prototype.subarray = function (a, b) {
    const r = origSubarray.call(this, a, b);
    if (this.byteLength > 100000000 && !(M.wasm && this.buffer === M.wasm.buffer)) {
      M.pack.calls += 1; M.pack.bytes += r.byteLength; M.pack.size = this.byteLength;
      if (M.pack.last.length >= 200) M.pack.last.shift();
      M.pack.last.push([Math.round(performance.now()), a, r.byteLength]);
    }
    return r;
  };
  // Web Audio: every AudioBuffer made (Godot's sample playback makes one per registered take, and duplicates the
  // take's buffer for every play) and every buffer source started, so the garbage sound makes can be counted.
  // webkit-memory-20261116: also keep each AudioContext the page makes, to read its state and clock (the same hook
  // runs in WebKit and Chrome; it changes no behaviour).
  M.audio.contexts = [];
  for (const name of ['AudioContext', 'webkitAudioContext']) {
    const Orig = window[name];
    if (!Orig) continue;
    const Wrapped = function (...a) { const ctx = new Orig(...a); M.audio.contexts.push(ctx); return ctx; };
    Wrapped.prototype = Orig.prototype;
    Object.setPrototypeOf(Wrapped, Orig);
    window[name] = Wrapped;
  }
  M.audioState = () => M.audio.contexts.map((c) => ({state: c.state, time: Math.round(c.currentTime * 1000) / 1000, rate: c.sampleRate, base: c.baseLatency ?? null}));
  // tools/ios-sim-memory: when a WebGL context is lost or restored (the GPU process died, or the system took it back).
  M.glEvents = [];
  for (const type of ['webglcontextlost', 'webglcontextrestored']) {
    window.addEventListener(type, (e) => { M.glEvents.push([type, Math.round(performance.now())]); }, true);
  }
  const AC = window.BaseAudioContext && BaseAudioContext.prototype;
  if (AC && AC.createBuffer) {
    const origCreateBuffer = AC.createBuffer;
    AC.createBuffer = function (channels, length, rate) { M.audio.buffers += 1; M.audio.bytes += channels * length * 4; return origCreateBuffer.call(this, channels, length, rate); };
  }
  if (AC && AC.createBufferSource) {
    const origSource = AC.createBufferSource;
    AC.createBufferSource = function () { M.audio.sources += 1; return origSource.call(this); };
  }
  const wasmBytes = () => { try { return M.wasm ? M.wasm.buffer.byteLength : 0; } catch (e) { return -1; } };
  const row = (name) => {
    const m = performance.memory || {};
    const g = M.gl || {};
    return {name, t: Math.round(performance.now()), wasm: wasmBytes(), js_used: m.usedJSHeapSize ?? null, js_total: m.totalJSHeapSize ?? null,
      gl_tex: g.tex || 0, gl_texN: g.texN || 0, gl_buf: g.buf || 0, gl_bufN: g.bufN || 0, gl_buf4k: g.buf4k || 0, gl_buf16k: g.buf16k || 0, gl_rb: g.rb || 0, gl_rbN: g.rbN || 0,
      programs: g.programs || 0, programsLive: g.programsLive || 0, shaders: g.shaders || 0, vaos: g.vaosLive || 0,
      audioBuffers: M.audio.buffers, audioBytes: M.audio.bytes, audioSources: M.audio.sources,
      packReads: M.pack.calls, packReadBytes: M.pack.bytes};
  };
  M.snap = (name) => { const r = row(name); M.marks.push(r); return r; };
  setInterval(() => { M.ticks.push(row('tick')); }, TICK_MS);
  // The wasm memory: an exported one at instantiation, or one made in JS (Emscripten imports its own when built so).
  const OrigMemory = WebAssembly.Memory;
  WebAssembly.Memory = function (desc) {
    const mem = new OrigMemory(desc);
    if (!M.wasm) { M.wasm = mem; M.memDesc = desc; }
    return mem;
  };
  WebAssembly.Memory.prototype = OrigMemory.prototype;
  const origGrow = OrigMemory.prototype.grow;
  OrigMemory.prototype.grow = function (pages) {
    const before = this.buffer.byteLength;
    const result = origGrow.call(this, pages);
    if (this === M.wasm) M.grows.push({t: Math.round(performance.now()), from: before, to: this.buffer.byteLength, pages});
    return result;
  };
  const capture = (r) => {
    const inst = r.instance || r;
    if (inst && inst.exports) for (const k of Object.keys(inst.exports)) if (inst.exports[k] instanceof OrigMemory) { M.wasm = inst.exports[k]; M.memExport = k; }
    M.snap('wasm_instantiated');
    return r;
  };
  for (const name of ['instantiate', 'instantiateStreaming']) {
    const orig = WebAssembly[name];
    if (orig) WebAssembly[name] = function (...a) { return orig.apply(this, a).then(capture); };
  }
  const mark = performance.mark.bind(performance);
  performance.mark = function (name, ...rest) { M.snap(name); return mark(name, ...rest); };

  const GLP = window.WebGL2RenderingContext && WebGL2RenderingContext.prototype;
  const acc = (M.gl = {tex: 0, texN: 0, buf: 0, bufN: 0, rb: 0, rbN: 0, texPeak: 0, bufPeak: 0, rbPeak: 0, bufNPeak: 0, texNPeak: 0,
    sizes: {}, bufByTarget: {}, programs: 0, programsLive: 0, shaders: 0, shaderSourceBytes: 0, vaosLive: 0, compressedCalls: 0, uncompressedTexCalls: 0,
    bufferDataCalls: 0, bufferSubDataCalls: 0, bufferSubDataBytes: 0, texSubCalls: 0, contexts: 0, extensions: null,
    bufHist: {}, buf4k: 0, buf16k: 0, buf16kPeak: 0});
  if (GLP) {
    // Bytes per pixel of the uncompressed internal formats Godot's Compatibility renderer asks for (4 if unknown).
    const BPP = {0x8058: 4, 0x8C43: 4, 0x8051: 3, 0x8C41: 3, 0x8229: 1, 0x822B: 2, 0x881A: 8, 0x8814: 16, 0x822D: 2, 0x822F: 4, 0x822E: 4, 0x8230: 8,
      0x881B: 6, 0x8059: 4, 0x8C3A: 4, 0x81A6: 4, 0x8CAC: 4, 0x88F0: 4, 0x8CAD: 8, 0x81A5: 2, 0x1908: 4, 0x1907: 3, 0x1903: 1, 0x8227: 2, 0x8D62: 2,
      0x190A: 2, 0x1909: 1, 0x8C3D: 4, 0x8D7C: 4, 0x8D70: 16, 0x8D76: 4, 0x8232: 1, 0x8238: 2, 0x823C: 4, 0x8231: 1, 0x8233: 1, 0x8235: 4, 0x8236: 4};
    const bpp = (f) => BPP[f] || 4;
    const texLevels = new Map(); const bufBytes = new Map(); const bufTarget = new Map(); const rbBytes = new Map();
    const bound = {}; let unit = 0;
    const key = (target) => (target >= 0x8515 && target <= 0x851A ? 0x8513 : target);
    const curTex = (target) => bound[unit + ':' + key(target)];
    const setTex = (tex, slot, bytes, label) => {
      if (!tex) return;
      let m = texLevels.get(tex);
      if (!m) { m = new Map(); texLevels.set(tex, m); acc.texN += 1; acc.texNPeak = Math.max(acc.texNPeak, acc.texN); }
      acc.tex += bytes - (m.get(slot) || 0); m.set(slot, bytes);
      acc.texPeak = Math.max(acc.texPeak, acc.tex);
      if (label) { const r = (acc.sizes[label] ||= [0, 0]); r[0] += 1; r[1] += bytes; }
    };
    const wrap = (name, fn) => { const orig = GLP[name]; if (!orig) return; GLP[name] = function (...a) { fn.call(this, a); return orig.apply(this, a); }; };
    const after = (name, fn) => { const orig = GLP[name]; if (!orig) return; GLP[name] = function (...a) { const r = orig.apply(this, a); fn.call(this, a, r); return r; }; };
    wrap('activeTexture', (a) => { unit = a[0]; });
    wrap('bindTexture', (a) => { bound[unit + ':' + a[0]] = a[1]; });
    wrap('deleteTexture', (a) => { const m = texLevels.get(a[0]); if (m) { for (const v of m.values()) acc.tex -= v; texLevels.delete(a[0]); acc.texN -= 1; } });
    wrap('texImage2D', (a) => { if (a.length >= 9) { acc.uncompressedTexCalls += 1; setTex(curTex(a[0]), a[0] + ':' + a[1], a[3] * a[4] * bpp(a[2]), a[1] === 0 ? (a[0] !== 0x0DE1 ? 't' + a[0].toString(16) + ':' : '') + a[3] + 'x' + a[4] + ':' + a[2].toString(16) : null); } });
    wrap('texImage3D', (a) => { setTex(curTex(a[0]), a[0] + ':' + a[1], a[3] * a[4] * a[5] * bpp(a[2]), a[1] === 0 ? a[3] + 'x' + a[4] + 'x' + a[5] + ':' + a[2].toString(16) : null); });
    wrap('texStorage2D', (a) => { let b = 0; for (let i = 0; i < a[1]; i++) b += Math.max(a[3] >> i, 1) * Math.max(a[4] >> i, 1) * bpp(a[2]); setTex(curTex(a[0]), 'storage', (a[0] === 0x8513 ? 6 : 1) * b, (a[0] === 0x8513 ? 'cube' : '') + a[3] + 'x' + a[4] + ':s' + a[2].toString(16) + 'L' + a[1]); });
    wrap('texStorage3D', (a) => { let b = 0; for (let i = 0; i < a[1]; i++) b += Math.max(a[3] >> i, 1) * Math.max(a[4] >> i, 1) * a[5] * bpp(a[2]); setTex(curTex(a[0]), 'storage', b, a[3] + 'x' + a[4] + 'x' + a[5] + ':s' + a[2].toString(16)); });
    wrap('compressedTexImage2D', (a) => { acc.compressedCalls += 1; const n = a.length > 8 ? a[8] : (a[6] && a[6].byteLength) || 0; setTex(curTex(a[0]), a[0] + ':' + a[1], n, a[1] === 0 ? a[3] + 'x' + a[4] + ':c' + a[2].toString(16) : null); });
    wrap('texSubImage2D', () => { acc.texSubCalls += 1; });
    const buf = {};
    wrap('bindBuffer', (a) => { buf[a[0]] = a[1]; });
    wrap('bindBufferBase', (a) => { buf[a[0]] = a[2]; });
    wrap('bindBufferRange', (a) => { buf[a[0]] = a[2]; });
    const account = (n, sign, target) => { acc.buf += sign * n; acc.bufN += sign; const t = (acc.bufByTarget[target] ||= [0, 0]); t[0] += sign; t[1] += sign * n;
      const k = n > 0 ? Math.ceil(Math.log2(n)) : -1; acc.bufHist[k] = (acc.bufHist[k] || 0) + sign;
      acc.buf4k += sign * Math.ceil(n / 4096) * 4096; acc.buf16k += sign * Math.ceil(n / 16384) * 16384; acc.buf16kPeak = Math.max(acc.buf16kPeak, acc.buf16k); };
    wrap('deleteBuffer', (a) => { if (bufBytes.has(a[0])) { account(bufBytes.get(a[0]), -1, bufTarget.get(a[0])); bufBytes.delete(a[0]); bufTarget.delete(a[0]); } });
    wrap('bufferData', (a) => {
      acc.bufferDataCalls += 1;
      const o = buf[a[0]]; if (!o) return;
      const n = typeof a[1] === 'number' ? a[1] : (a.length > 4 && a[4] ? a[4] : (a[1] ? a[1].byteLength : 0));
      if (bufBytes.has(o)) account(bufBytes.get(o), -1, bufTarget.get(o));
      account(n, 1, a[0].toString(16)); bufBytes.set(o, n); bufTarget.set(o, a[0].toString(16));
      acc.bufPeak = Math.max(acc.bufPeak, acc.buf); acc.bufNPeak = Math.max(acc.bufNPeak, acc.bufN);
    });
    wrap('bufferSubData', (a) => { acc.bufferSubDataCalls += 1; acc.bufferSubDataBytes += a.length > 4 && a[4] ? a[4] : (a[2] && a[2].byteLength) || 0; });
    wrap('linkProgram', () => { acc.programs += 1; });
    after('createProgram', () => { acc.programsLive += 1; });
    wrap('deleteProgram', (a) => { if (a[0]) acc.programsLive -= 1; });
    wrap('compileShader', () => { acc.shaders += 1; });
    wrap('shaderSource', (a) => { acc.shaderSourceBytes += a[1].length; });
    after('createVertexArray', () => { acc.vaosLive += 1; });
    wrap('deleteVertexArray', (a) => { if (a[0]) acc.vaosLive -= 1; });
    let rbo = null;
    const setRb = (n) => { if (!rbo) return; if (!rbBytes.has(rbo)) acc.rbN += 1; acc.rb += n - (rbBytes.get(rbo) || 0); rbBytes.set(rbo, n); acc.rbPeak = Math.max(acc.rbPeak, acc.rb); };
    wrap('bindRenderbuffer', (a) => { rbo = a[1]; });
    wrap('deleteRenderbuffer', (a) => { if (rbBytes.has(a[0])) { acc.rb -= rbBytes.get(a[0]); rbBytes.delete(a[0]); acc.rbN -= 1; } });
    wrap('renderbufferStorage', (a) => setRb(a[2] * a[3] * bpp(a[1])));
    wrap('renderbufferStorageMultisample', (a) => setRb(a[3] * a[4] * bpp(a[2]) * Math.max(a[1], 1)));
    // The extensions the page's own WebGL2 context offers (texture formats among them), once.
    const getContext = HTMLCanvasElement.prototype.getContext;
    HTMLCanvasElement.prototype.getContext = function (type, ...rest) {
      const ctx = getContext.call(this, type, ...rest);
      if (ctx && type === 'webgl2' && !acc.extensions) { acc.contexts += 1; try { acc.extensions = ctx.getSupportedExtensions(); acc.contextAttributes = ctx.getContextAttributes(); } catch (e) { acc.extensions = ['error ' + e]; } }
      return ctx;
    };
  }
  M.dump = () => JSON.stringify({t0: M.t0, memDesc: M.memDesc || null, memExport: M.memExport || null, marks: M.marks, ticks: M.ticks, grows: M.grows,
    gl: M.gl, pack: M.pack, audio: {buffers: M.audio.buffers, bytes: M.audio.bytes, sources: M.audio.sources, contexts: M.audioState()}, glEvents: M.glEvents, now: row('dump')});
})();
