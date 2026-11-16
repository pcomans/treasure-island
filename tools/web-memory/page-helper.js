// tools/web-memory/page-helper.js: test-only browser helper (from grab-bag-20261111's web smoke), injected by route.cjs; never shipped.
// Adapted from release-batch-f-20261108's page-helper.js (stock keyboard events on the canvas, the
// game's ?profile_startup=1 readback, the pointer-lock shim answering the game's own requests, mouse
// look, aim and the closed-loop autopilot), without its spray click, plus: the arrow keys, Escape and
// C (the autopilot's landing holds C, the fast drop, instead of waiting for the slow descent), and a
// click at a HUD button's content position. The real browser pointer-lock API, which crashed Chromium
// on headless Weston (LEARNINGS), is never called.
(() => {
  if (window.__pc) return JSON.stringify({already: true});
  const c = document.getElementById('canvas');
  const K = {w: ['w', 'KeyW', 87], a: ['a', 'KeyA', 65], s: ['s', 'KeyS', 83], d: ['d', 'KeyD', 68],
    up: ['ArrowUp', 'ArrowUp', 38], down: ['ArrowDown', 'ArrowDown', 40], left: ['ArrowLeft', 'ArrowLeft', 37], right: ['ArrowRight', 'ArrowRight', 39],
    space: [' ', 'Space', 32], shift: ['Shift', 'ShiftLeft', 16], f: ['f', 'KeyF', 70], r: ['r', 'KeyR', 82],
    c: ['c', 'KeyC', 67], esc: ['Escape', 'Escape', 27]};
  const held = {};
  const send = (type, k) => {
    const [key, code, kc] = K[k];
    c.dispatchEvent(new KeyboardEvent(type, {key, code, keyCode: kc, which: kc,
      shiftKey: k === 'shift' ? type === 'keydown' : !!held.shift, bubbles: true}));
  };
  // Space needs Shift (a bare Space is ui_accept on a focused button): pressing Space presses Shift first.
  const set = (k, on) => {
    if (!!held[k] === on) return;
    if (k === 'space' && on && !held.shift) set('shift', true);
    if (k === 'shift' && !on && held.space) set('space', false);
    held[k] = on; send(on ? 'keydown' : 'keyup', k);
  };
  const releaseAll = () => { set('space', false); for (const k of Object.keys(K)) set(k, false); };
  const read = () => { window.__tiReadback(); return JSON.parse(window.__tiState); };
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const wrap = (a) => Math.atan2(Math.sin(a), Math.cos(a));
  const yawOf = (fx, fz) => Math.atan2(-fx, -fz);
  const pc = {held, set, releaseAll, read, ap: null, cam: null};
  c.focus();

  pc.hold = (keys, ms) => { for (const k of keys) set(k, true); setTimeout(() => { for (const k of keys) set(k, false); }, ms); return 'holding'; };
  pc.tap = (k) => { set(k, true); setTimeout(() => set(k, false), 120); return 'tapped ' + k; };

  pc.calibrate = async (ms) => {
    const p0 = read().position; pc.hold(['w'], ms); await sleep(ms + 900);
    const p1 = read().position; pc.hold(['s'], ms); await sleep(ms + 900);
    const p2 = read().position;
    const dx = p1[0] - p0[0], dz = p1[2] - p0[2], len = Math.hypot(dx, dz);
    return {f: [dx / len, dz / len], psi: yawOf(dx / len, dz / len), forward_m: len,
      back_m: Math.hypot(p2[0] - p1[0], p2[2] - p1[2]), residual_m: Math.hypot(p2[0] - p0[0], p2[2] - p0[2]), p0, p1, p2};
  };

  // The same, in the air clear of everything near (a car just left stands right
  // beside the player): rise on the jetpack for riseMs, then calibrate while the slow
  // descent brings it down a few metres.
  pc.calibrateAir = async (riseMs, ms) => {
    set('space', true); await sleep(riseMs); set('space', false); set('shift', false);
    await sleep(200);
    const r = await pc.calibrate(ms);
    r.rose_to_y = r.p0[1];
    return r;
  };

  pc.installShim = () => {
    if (pc.shimInstalled) return JSON.stringify({already: true, own_request: Object.prototype.hasOwnProperty.call(c, 'requestPointerLock'), own_exit: Object.prototype.hasOwnProperty.call(document, 'exitPointerLock')});  // release-batch-20261114b: a second call (after start_play) reports as the first
    let locked = false;
    Object.defineProperty(document, 'pointerLockElement', {configurable: true, get: () => (locked ? c : null)});
    c.requestPointerLock = function () { locked = true; setTimeout(() => document.dispatchEvent(new Event('pointerlockchange')), 0); return Promise.resolve(); };
    document.exitPointerLock = function () { locked = false; setTimeout(() => document.dispatchEvent(new Event('pointerlockchange')), 0); };
    pc.shimInstalled = true;
    pc.isLocked = () => locked;
    return JSON.stringify({own_request: Object.prototype.hasOwnProperty.call(c, 'requestPointerLock'),
      own_exit: Object.prototype.hasOwnProperty.call(document, 'exitPointerLock')});
  };

  // A left click at a point in the game's content coordinates (as the readback reports buttons).
  pc.clickContent = (xy) => {
    const s = read(); const r = c.getBoundingClientRect();
    const x = r.left + xy[0] * r.width / s.viewport[0], y = r.top + xy[1] * r.height / s.viewport[1];
    const o = {bubbles: true, cancelable: true, clientX: x, clientY: y};
    c.focus();
    c.dispatchEvent(new MouseEvent('mouseover', o));
    window.dispatchEvent(new PointerEvent('pointermove', {...o, movementX: 0, movementY: 0}));
    c.dispatchEvent(new MouseEvent('mousedown', {...o, button: 0, buttons: 1}));
    window.dispatchEvent(new MouseEvent('mouseup', {...o, button: 0, buttons: 0}));
    return JSON.stringify({x, y, content: xy, locked: pc.isLocked ? pc.isLocked() : null});
  };
  // The HUD's "Click to look" button: centre-top, 20-68 px down in the content.
  pc.clickLook = () => pc.clickContent([read().viewport[0] / 2, 44]);

  pc.speedTest = async (keys, ms, fromMs) => {
    const start = read();
    for (const k of keys) set(k, true);
    await sleep(fromMs);
    const a = read(); const ta = performance.now();
    await sleep(ms - fromMs);
    const b = read(); const tb = performance.now();
    for (const k of keys.slice().reverse()) set(k, false);
    await sleep(900);
    const rest = read();
    return {keys, speed_mps: Math.hypot(b.position[0] - a.position[0], b.position[2] - a.position[2]) * 1000 / (tb - ta),
      grounded: b.grounded, moved_m: Math.hypot(rest.position[0] - start.position[0], rest.position[2] - start.position[2]),
      end: rest.position, paused: rest.paused};
  };

  pc.turn = (px, py) => {
    const r = c.getBoundingClientRect(); const o = {bubbles: true, clientX: r.left + r.width / 2, clientY: r.top + r.height / 2};
    py = py || 0;
    const n = Math.max(1, Math.ceil(Math.max(Math.abs(px), Math.abs(py)) / 40));
    let sx = 0, sy = 0;
    for (let i = 1; i <= n; i++) {
      const tx = Math.round(px * i / n), ty = Math.round(py * i / n);
      window.dispatchEvent(new PointerEvent('pointermove', {...o, movementX: tx - sx, movementY: ty - sy}));
      sx = tx; sy = ty;
    }
    return {events: n, px: sx, py: sy};
  };
  pc.turnTo = async (psiFrom, psiT, g, ms) => {
    const px = Math.round(-wrap(psiT - psiFrom) / g);
    const t = pc.turn(px, 0); await sleep(400);
    const m = await pc.calibrate(ms);
    const turned = wrap(m.psi - psiFrom);
    return {px: t.px, measured: m, gain: Math.abs(t.px) > 0 ? -turned / t.px : g, residual_deg: wrap(psiT - m.psi) * 180 / Math.PI};
  };
  pc.aim = (T) => {
    const s = read(); const p = s.position; const pivot = [p[0], p[1] + 2.0, p[2]];
    const dx = T[0] - pivot[0], dy = T[1] - pivot[1], dz = T[2] - pivot[2];
    const psiT = Math.atan2(-dx, -dz), thetaT = Math.max(-1.04, Math.min(0.43, Math.atan2(dy, Math.hypot(dx, dz))));
    const px = Math.round(-wrap(psiT - pc.cam.psi) / pc.cam.g), py = Math.round((pc.cam.theta - thetaT) / pc.cam.g);
    const t = pc.turn(px, py);
    pc.cam.psi = wrap(pc.cam.psi - t.px * pc.cam.g); pc.cam.theta = pc.cam.theta - t.py * pc.cam.g;
    return {at: p, target: T, distance_m: Math.hypot(dx, dz), psi_deg: pc.cam.psi * 180 / Math.PI, theta_deg: pc.cam.theta * 180 / Math.PI};
  };
  pc.forward = () => [-Math.sin(pc.cam.psi), -Math.cos(pc.cam.psi)];

  // Closed-loop autopilot (the release's), through waypoints; opts: cruise, mode 'land', deadline (s).
  // Travel runs at run speed; the last 20 m are walked with Space released; landing holds C.
  pc.go = (points, opts) => {
    pc.stop();
    const [fx, fz] = pc.forward(); const rx = -fz, rz = fx;
    const t0 = performance.now();
    const ap = {phase: 'cruise', wp: 0, done: false, result: '', log: [], points, opts, prev: null};
    if (opts.cruise && read().position[1] < opts.cruise - 0.5) ap.phase = 'climb';
    pc.ap = ap;
    const fmt = (s) => s.position.map((v) => v.toFixed(2)).join(',');
    const finish = (why, s) => { releaseAll(); clearInterval(ap.timer); ap.done = true;
      ap.result = why + (s ? ` el=${((performance.now() - t0) / 1000).toFixed(1)} at=${fmt(s)} grounded=${s.grounded}` : ''); };
    const jet = (on) => set('space', on);
    ap.timer = setInterval(() => {
      let s;
      try { s = read(); } catch (e) { finish('readback_error ' + e); return; }
      const el = (performance.now() - t0) / 1000;
      if (s.paused || !s.input) { finish(`aborted paused=${s.paused} input=${s.input}`, s); return; }
      if (el > opts.deadline) { finish('deadline', s); return; }
      const [x, y, z] = s.position;
      if (ap.prev && Math.hypot(x - ap.prev[0], z - ap.prev[2]) > 30) { finish(`recovery_jump from=${ap.prev.map((v) => v.toFixed(1)).join(',')}`, s); return; }
      ap.prev = s.position;
      const last = ap.wp === points.length - 1;
      const [tx, tz] = points[ap.wp];
      const dx = tx - x, dz = tz - z, dist = Math.hypot(dx, dz);
      const fw = dx * fx + dz * fz, rt = dx * rx + dz * rz;
      const steer = (db) => { set('w', fw > db); set('s', fw < -db); set('d', rt > db); set('a', rt < -db); };
      if (ap.phase === 'climb') {
        jet(true); steer(1e9);
        if (y >= opts.cruise) ap.phase = 'cruise';
      } else if (ap.phase === 'cruise') {
        if (!last && dist < 10) { ap.log.push(`${el.toFixed(1)} waypoint ${ap.wp}`); ap.wp += 1; return; }
        if (!last || dist > 20) { set('c', false); set('shift', true); steer(2); jet(!!opts.cruise && y < opts.cruise); }
        else { jet(false); set('shift', false); set('c', !s.grounded); steer(0.3); }
        if (last && dist < 0.5) { steer(1e9); ap.phase = opts.mode; }
      } else if (ap.phase === 'land') {
        jet(false); set('shift', false); set('c', !s.grounded); steer(0.3);
        if (s.grounded && Math.hypot(...s.velocity) < 0.05) { finish('landed', s); return; }
      }
      if (el - (ap.lastLog ?? -1) >= 1) { ap.lastLog = el; ap.log.push(`${el.toFixed(1)} ${ap.phase} wp=${ap.wp} ${x.toFixed(1)},${y.toFixed(1)},${z.toFixed(1)} d=${dist.toFixed(1)} keys=${Object.keys(held).filter((k) => held[k]).join('+')}`); }
    }, 50);
    return 'started';
  };
  pc.stop = () => { if (pc.ap && !pc.ap.done) { clearInterval(pc.ap.timer); pc.ap.done = true; pc.ap.result = pc.ap.result || 'stopped'; } releaseAll(); return 'stopped'; };

  // Dribble toward goal point G [x, z]: walk the ball in, lining up behind it on the ball-to-goal line
  // before each push (a walk's push sends it along the contact). Stops on a goal or the deadline.
  pc.dribbleTo = async (G, deadlineMs) => {
    const g0 = read().ball.goals; const t0 = performance.now(); let s = read();
    const log = []; let pushes = 0; let mode = '';
    while (performance.now() - t0 < deadlineMs) {
      s = read();
      if (s.ball.goals > g0 || s.paused) break;
      const b = s.ball.position, p = s.position;
      let ux = G[0] - b[0], uz = G[1] - b[2]; const ul = Math.hypot(ux, uz); ux /= ul; uz /= ul;
      const vx = p[0] - b[0], vz = p[2] - b[2];
      const along = vx * ux + vz * uz, across = -vx * uz + vz * ux;
      let T;
      if (along < -0.2 && Math.abs(across) < 0.15) { T = [G[0], G[1]]; if (mode !== 'push') pushes += 1; mode = 'push'; }
      else { T = [b[0] - ux * 1.2, b[2] - uz * 1.2]; mode = 'line up'; }
      const dx = T[0] - p[0], dz = T[1] - p[2], dist = Math.hypot(dx, dz);
      if (dist > 0.05) {
        const px = Math.round(-wrap(Math.atan2(-dx, -dz) - pc.cam.psi) / pc.cam.g);
        if (px !== 0) { const t = pc.turn(px, 0); pc.cam.psi = wrap(pc.cam.psi - t.px * pc.cam.g); }
      }
      // Lining up walks right onto the point (round 2 stood 0.24 m off it, out of line, for 130 s).
      set('w', mode === 'push' || dist > 0.08);
      if (log.length === 0 || performance.now() - log[log.length - 1][0] > 1000) log.push([performance.now(), mode, p.map((v) => +v.toFixed(2)), b.map((v) => +v.toFixed(2)), +across.toFixed(2)]);
      await sleep(50);
    }
    const ms = performance.now() - t0;
    pc.dribbleLog = log.map((r) => [Math.round(r[0] - t0), r[1], r[2], r[3], r[4]]);
    return JSON.stringify({goals: s.ball.goals - g0, ms: Math.round(ms), pushes, ball: s.ball, player: s.position, paused: s.paused});
  };

  // The dribble, started in the page and left to run (a single evaluation that waits for
  // it outlasts the browser's command timeout); dribbleResult holds its result when done.
  pc.dribbleStart = (G, deadlineMs) => {
    pc.dribbleResult = null;
    pc.dribbleTo(G, deadlineMs).then((r) => { pc.dribbleResult = r; }, (e) => { pc.dribbleResult = JSON.stringify({error: String(e)}); });
    return 'dribbling';
  };

  window.__pc = pc;
  return JSON.stringify({installed: true, canvas: [c.width, c.height], dpr: window.devicePixelRatio});
})()
