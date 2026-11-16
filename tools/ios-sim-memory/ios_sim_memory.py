#!/usr/bin/env python3
"""Memory of a web page in the iOS Simulator's Safari, measured from the macOS host (ios-sim-memory.yml).

ios_sim_memory.py OUT_DIR             run everything (as the runner's user; uses sudo -n for the sampler)
ios_sim_memory.py --sample OUT.jsonl  the sampler alone (started by the run, under sudo)

The simulator runs the iOS build of WebKit (its WebContent, GPU and Networking processes are ordinary macOS
processes of the host), on the host's Metal device and 16 KiB pages, but with no jetsam: nothing is killed at the
iPhone's per-process limit, so the numbers show how close a page comes to it, not whether a phone would kill it.

Steps: record the host (macOS, Xcode, Metal device); create and boot a fresh iPhone simulator (DEVICE, newest iOS
runtime); start a 1 s sampler of every Safari/WebKit process of the simulator (phys_footprint, the number jetsam
compares with the limit, and its lifetime peak, from proc_pid_rusage; ps RSS); drive Mobile Safari through Apple's
safaridriver (WebDriver, 'safari:useSimulator'): open URL with ?profile_startup=1, inject the test-only memory hook,
wait until the game reports ready, tap its start prompt with a real touch (WebDriver touch actions), then (ROUTE=full)
the desktop study's route with the page helper's keyboard events: stand 45 s, walk to the sedan, drive five circles,
jetpack to Pier 1 and back, stand 60 s; ROUTE=prompt stops at the start prompt and waits IDLE_S. If safaridriver
cannot start a session, it falls back to `simctl openurl` and measures load and the start prompt only (no touch, no
page state). Screenshots come from `simctl io`. Writes footprint.jsonl, labels.jsonl, states.jsonl, run.log,
system.txt, screenshots, footprint/vmmap reports at the end, summary.md (also the job summary) and summary.json.
Env: URL, ROUTE (full|prompt), DEVICE, IDLE_S."""
import ctypes, json, os, re, signal, statistics, subprocess, sys, threading, time, urllib.error, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
MiB = 1048576.0

# ---------------------------------------------------------------------------------------------- the sampler
RU_FIELDS = ['user_time', 'system_time', 'pkg_idle_wkups', 'interrupt_wkups', 'pageins', 'wired_size', 'resident_size',
             'phys_footprint', 'proc_start_abstime', 'proc_exit_abstime', 'child_user_time', 'child_system_time',
             'child_pkg_idle_wkups', 'child_interrupt_wkups', 'child_pageins', 'child_elapsed_abstime', 'diskio_bytesread',
             'diskio_byteswritten', 'cpu_time_qos_default', 'cpu_time_qos_maintenance', 'cpu_time_qos_background',
             'cpu_time_qos_utility', 'cpu_time_qos_legacy', 'cpu_time_qos_user_initiated', 'cpu_time_qos_user_interactive',
             'billed_system_time', 'serviced_system_time', 'logical_writes', 'lifetime_max_phys_footprint', 'instructions',
             'cycles', 'billed_energy', 'serviced_energy', 'interval_max_phys_footprint', 'runnable_time']


class RusageInfoV4(ctypes.Structure):  # <sys/resource.h> struct rusage_info_v4
    _fields_ = [('uuid', ctypes.c_uint8 * 16)] + [(n, ctypes.c_uint64) for n in RU_FIELDS]


# WebKit's processes: XPC services (com.apple.WebKit.WebContent, ...) or, where WebKit runs them as BrowserEngineKit
# extensions, WebContentExtension, GPUExtension and NetworkingExtension.
KINDS = [(('com.apple.WebKit.WebContent', 'WebContentExtension'), 'web'), (('com.apple.WebKit.GPU', 'GPUExtension'), 'gpu'),
         (('com.apple.WebKit.Networking', 'NetworkingExtension'), 'net'), (('/MobileSafari.app/MobileSafari',), 'safari')]


def sim_ps():
    """(pid, rss_kib, command) of every process whose executable is inside the simulator's runtime."""
    out = subprocess.run(['ps', '-axww', '-o', 'pid=,rss=,command='], capture_output=True, text=True).stdout
    rows = []
    for line in out.splitlines():
        m = re.match(r'\s*(\d+)\s+(\d+)\s+(.*)$', line)
        if m and ('CoreSimulator' in m.group(3) or '.simruntime' in m.group(3)):
            rows.append((int(m.group(1)), int(m.group(2)), m.group(3)))
    return rows


def sim_processes():
    """(pid, kind, ps_rss_kib) of the simulator's Safari and WebKit processes."""
    found = []
    for pid, rss, command in sim_ps():
        for needles, kind in KINDS:
            if any(n in command for n in needles):
                found.append((pid, kind, rss))
                break
    return found


def sample(path):
    libproc = ctypes.CDLL('/usr/lib/libproc.dylib', use_errno=True)
    libproc.proc_pid_rusage.argtypes = [ctypes.c_int, ctypes.c_int, ctypes.c_void_p]
    stop = []
    signal.signal(signal.SIGTERM, lambda *_: stop.append(1))
    t0 = time.time(); n = 0
    with open(path, 'w', buffering=1) as f:
        f.write(json.dumps({'columns': ['kind', 'pid', 'ps_rss_mib', 'phys_footprint_mib', 'lifetime_max_phys_footprint_mib',
                                        'resident_size_mib', 'interval_max_phys_footprint_mib'], 'uid': os.getuid()}) + '\n')
        while not stop:
            rows, errs = [], []
            for pid, kind, rss in sim_processes():
                ru = RusageInfoV4()
                if libproc.proc_pid_rusage(pid, 4, ctypes.byref(ru)) == 0:
                    rows.append([kind, pid, round(rss / 1024.0, 1), round(ru.phys_footprint / MiB, 1),
                                 round(ru.lifetime_max_phys_footprint / MiB, 1), round(ru.resident_size / MiB, 1),
                                 round(ru.interval_max_phys_footprint / MiB, 1)])
                else:
                    errs.append([pid, ctypes.get_errno()])
                    rows.append([kind, pid, round(rss / 1024.0, 1), None, None, None, None])
            row = {'e': round(time.time(), 2), 'p': rows}
            if errs:
                row['rusage_errors'] = errs
            if n % 10 == 0:
                vm = subprocess.run(['vm_stat'], capture_output=True, text=True).stdout
                ps = int((re.search(r'page size of (\d+) bytes', vm) or [0, 16384])[1])
                pages = {k.strip().strip('"'): int(v.strip().rstrip('.')) for k, v in re.findall(r'^([^:\n]+):\s+(\d+)\.?$', vm, re.M)}
                row['host_mib'] = {k: round(pages[k] * ps / MiB) for k in ('Pages free', 'Pages active', 'Pages inactive', 'Pages wired down',
                                                                         'Pages occupied by compressor') if k in pages}
            f.write(json.dumps(row) + '\n')
            n += 1
            time.sleep(max(0.05, t0 + n - time.time()))


if len(sys.argv) > 2 and sys.argv[1] == '--sample':
    sample(sys.argv[2])
    sys.exit(0)

# ---------------------------------------------------------------------------------------------- the run
OUT = os.path.abspath(sys.argv[1]); os.makedirs(OUT, exist_ok=True)
URL = os.environ.get('URL') or 'https://play-grandtreasureisland.vercel.app/'
ROUTE = os.environ.get('ROUTE') or 'full'
DEVICE = os.environ.get('DEVICE') or 'iPhone 17 Pro'
IDLE_S = int(os.environ.get('IDLE_S') or 120)
LOGF = open(os.path.join(OUT, 'run.log'), 'a', buffering=1)
NOTES = []  # lines for the summary


def log(*a):
    line = time.strftime('%H:%M:%S ', time.gmtime()) + ' '.join(str(x) for x in a)
    print(line, flush=True); LOGF.write(line + '\n')


def note(text):
    NOTES.append(text); log('NOTE', text)


def label(name):
    with open(os.path.join(OUT, 'labels.jsonl'), 'a') as f:
        f.write(json.dumps({'label': name, 'e': round(time.time(), 2)}) + '\n')
    log('LABEL', name)


def sh(cmd, timeout=120, quiet=False):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        if not quiet:
            log('$', ' '.join(cmd), '->', r.returncode, (r.stderr or '').strip()[-300:])
        return r.returncode, r.stdout, r.stderr
    except subprocess.TimeoutExpired:
        log('$', ' '.join(cmd), '-> TIMEOUT', timeout)
        return 124, '', 'timeout'


def host_info():
    parts = []
    for cmd in (['sw_vers'], ['uname', '-a'], ['sysctl', 'hw.memsize', 'hw.ncpu', 'hw.pagesize', 'machdep.cpu.brand_string'],
                ['system_profiler', 'SPDisplaysDataType'], ['xcode-select', '-p'], ['xcodebuild', '-version'],
                ['xcrun', 'simctl', 'list', 'runtimes']):
        rc, out, err = sh(cmd, timeout=180, quiet=True)
        parts.append('$ ' + ' '.join(cmd) + '\n' + out + err)
    text = '\n'.join(parts)
    open(os.path.join(OUT, 'system.txt'), 'w').write(text)
    gpu = re.findall(r'(Chipset Model|Metal Support|Metal Family|Total Number of Cores|Vendor):\s*(.+)', text)
    note('host: ' + ' / '.join(l.split(':', 1)[1].strip() for l in text.splitlines() if l.startswith('ProductVersion') or l.startswith('BuildVersion'))
         + '; ' + '; '.join('%s %s' % (k, v.strip()) for k, v in gpu))
    return text


def boot_simulator():
    rc, out, _ = sh(['xcrun', 'simctl', 'list', '-j', 'runtimes', 'devicetypes'], timeout=180, quiet=True)
    data = json.loads(out)
    runtimes = [r for r in data['runtimes'] if r.get('platform') == 'iOS' and r.get('isAvailable')]
    runtimes.sort(key=lambda r: [int(x) for x in re.findall(r'\d+', r['version'])])
    if not runtimes:
        raise RuntimeError('no available iOS simulator runtime')
    rt = runtimes[-1]
    supported = [d for d in rt.get('supportedDeviceTypes', []) if d.get('productFamily') == 'iPhone']
    if not supported:  # an older simctl lists the device types only at the top level
        supported = [d for d in data.get('devicetypes', []) if d.get('productFamily') == 'iPhone' or d.get('name', '').startswith('iPhone')]
    dt = next((d for d in supported if d['name'] == DEVICE), supported[-1] if supported else None)
    if dt is None:
        raise RuntimeError('no iPhone device type for ' + rt['identifier'])
    note('simulator: %s on iOS %s (%s), device type %s' % (dt['name'], rt['version'], rt.get('buildversion', '?'), dt['identifier']))
    rc, out, err = sh(['xcrun', 'simctl', 'create', 'ios-sim-memory', dt['identifier'], rt['identifier']], timeout=300)
    udid = out.strip()
    if rc != 0 or not udid:
        raise RuntimeError('simctl create failed: ' + err[-300:])
    t0 = time.time()
    sh(['xcrun', 'simctl', 'boot', udid], timeout=600)
    rc, _, _ = sh(['xcrun', 'simctl', 'bootstatus', udid, '-b'], timeout=900)
    note('simulator %s booted in %.0f s (bootstatus rc %d)' % (udid, time.time() - t0, rc))
    return udid


def dump_sim_ps(name):
    """The simulator's processes by RSS (how WebKit's processes are named in this runtime)."""
    rows = sorted(sim_ps(), key=lambda r: -r[1])
    with open(os.path.join(OUT, 'sim-ps-%s.txt' % name), 'w') as f:
        for pid, rss, command in rows:
            f.write('%7d %9.1f MiB  %s\n' % (pid, rss / 1024.0, command))


def screenshot(udid, name):
    path = os.path.join(OUT, 'sim-%s.png' % name)
    rc, _, _ = sh(['xcrun', 'simctl', 'io', udid, 'screenshot', '--type=png', path], timeout=60, quiet=True)
    log('SCREENSHOT', name, 'ok' if rc == 0 else 'FAILED rc=%d' % rc)


# ---------------------------------------------------------------------------------------------- WebDriver
WD = 'http://127.0.0.1:4444'


class WDError(Exception):
    pass


def wd(method, path, body=None, timeout=330):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(WD + path, data=data, method=method, headers={'Content-Type': 'application/json; charset=utf-8'})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return json.loads(r.read().decode() or '{}').get('value')
    except urllib.error.HTTPError as e:
        raise WDError('%s %s -> HTTP %d %s' % (method, path, e.code, e.read().decode(errors='replace')[:600]))
    except (urllib.error.URLError, TimeoutError, OSError) as e:
        raise WDError('%s %s -> %s' % (method, path, e))


class Page:
    def __init__(self, sid):
        self.sid = sid

    def js(self, body, timeout=120):
        return wd('POST', '/session/%s/execute/sync' % self.sid, {'script': body, 'args': []}, timeout)

    def js_async(self, expr, timeout=300):
        """expr evaluates to a promise; its result comes back through the WebDriver callback."""
        body = 'const done = arguments[arguments.length - 1]; Promise.resolve(%s).then((r) => done(r), (e) => done("ERROR " + e));' % expr
        return wd('POST', '/session/%s/execute/async' % self.sid, {'script': body, 'args': []}, timeout)

    def tap(self, x, y, kind='touch'):
        wd('POST', '/session/%s/actions' % self.sid, {'actions': [{'type': 'pointer', 'id': 'finger1', 'parameters': {'pointerType': kind}, 'actions': [
            {'type': 'pointerMove', 'duration': 0, 'origin': 'viewport', 'x': int(x), 'y': int(y)},
            {'type': 'pointerDown', 'button': 0}, {'type': 'pause', 'duration': 100}, {'type': 'pointerUp', 'button': 0}]}]}, 60)
        try:
            wd('DELETE', '/session/%s/actions' % self.sid, None, 30)
        except WDError:
            pass


READY_JS = """return (() => {
  const marks = {};
  for (const m of performance.getEntriesByType('mark')) if (m.name.startsWith('TI_BOOT:') || m.name.startsWith('TI:')) marks[m.name] = Math.round(m.startTime);
  let state = null;
  if (typeof window.__tiReadback === 'function') { try { window.__tiReadback(); state = JSON.parse(window.__tiState || 'null'); } catch (e) { state = {readback_error: String(e)}; } }
  const status = document.getElementById('status'); const notice = document.getElementById('status-notice');
  return JSON.stringify({readyState: document.readyState, overlay: status ? getComputedStyle(status).visibility : null, notice: notice ? notice.textContent : null,
    ready: !!(state && state.ready), prompt: state ? state.start_prompt : null, touch: state ? state.touch_visible : null, marks});
})()"""
STATE_JS = """return (() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); return JSON.stringify({ready: s.ready, paused: s.paused,
  input: s.input, grounded: s.grounded, driving: s.driving, position: s.position, prompt: s.start_prompt, touch: s.touch_visible,
  fps: s.graphics && s.graphics.fps, scale: s.graphics && s.graphics.scale, sound: s.sound,
  hook: window.__mem ? {wasm_mib: window.__mem.wasm ? window.__mem.wasm.buffer.byteLength / 1048576 : null, audio: {buffers: window.__mem.audio.buffers, mib: window.__mem.audio.bytes / 1048576, sources: window.__mem.audio.sources}, gl_tex_mib: window.__mem.gl ? window.__mem.gl.tex / 1048576 : null, gl_buf_mib: window.__mem.gl ? window.__mem.gl.buf / 1048576 : null, contexts: window.__mem.audioState ? window.__mem.audioState() : null} : null}); })()"""
ENV_JS = """return (() => { const c = document.createElement('canvas').getContext('webgl2'); const d = c && c.getExtension('WEBGL_debug_renderer_info'); const cv = document.getElementById('canvas');
  return JSON.stringify({webgl2: !!c, renderer: d ? c.getParameter(d.UNMASKED_RENDERER_WEBGL) : null, vendor: d ? c.getParameter(d.UNMASKED_VENDOR_WEBGL) : null,
    max_texture: c ? c.getParameter(c.MAX_TEXTURE_SIZE) : null, dpr: window.devicePixelRatio, canvas: cv ? [cv.width, cv.height] : null,
    css: cv ? [cv.clientWidth, cv.clientHeight] : null, ua: navigator.userAgent, touch_points: navigator.maxTouchPoints,
    performance_memory: typeof performance.memory, measureUserAgentSpecificMemory: typeof performance.measureUserAgentSpecificMemory,
    deviceMemory: navigator.deviceMemory ?? null, hook_wasm_mib: window.__mem && window.__mem.wasm ? window.__mem.wasm.buffer.byteLength / 1048576 : null,
    compressed: c ? c.getSupportedExtensions().filter((e) => /compress/i.test(e)) : null}); })()"""


def start_session(udid):
    sh(['sudo', '-n', 'safaridriver', '--enable'], timeout=60)
    drv = subprocess.Popen(['safaridriver', '-p', '4444'], stdout=open(os.path.join(OUT, 'safaridriver.log'), 'w'), stderr=subprocess.STDOUT)
    for _ in range(60):
        try:
            if wd('GET', '/status', None, 5) is not None:
                break
        except WDError:
            time.sleep(1)
    base = {'browserName': 'Safari', 'platformName': 'iOS', 'safari:useSimulator': True}
    for extra, attempts in (({'safari:deviceUDID': udid}, (1, 2)), ({'safari:deviceName': DEVICE}, (1,)), ({}, (1,))):
        caps = dict(base, **extra)
        for attempt in attempts:
            try:
                v = wd('POST', '/session', {'capabilities': {'alwaysMatch': caps}}, 240)
                note('safaridriver session with %s (attempt %d): %s' % (json.dumps(extra), attempt, json.dumps(v.get('capabilities', {}))[:400]))
                return drv, v['sessionId']
            except WDError as e:
                log('SESSION_FAILED', json.dumps(extra), 'attempt', attempt, str(e)[:500])
                time.sleep(15)
    note('safaridriver could not start a session on the simulator; falling back to simctl openurl (load and start prompt only)')
    return drv, None


def wait_ready(page, deadline_s):
    t0 = time.time(); last = None
    while time.time() - t0 < deadline_s:
        try:
            r = json.loads(page.js(READY_JS, 60))
            with open(os.path.join(OUT, 'readback.log'), 'a') as f:
                f.write('%.1f %s\n' % (time.time() - t0, json.dumps(r)))
            line = 'ready=%s overlay=%s play_ready=%s notice=%s' % (r['ready'], r['overlay'], r['marks'].get('TI_BOOT:play_ready'), r['notice'])
            if 'TI_BOOT:failed' in r['marks']:
                note('the page reported a failed start: %s' % r['notice']); return False
            if r['ready'] and r['marks'].get('TI_BOOT:play_ready') is not None and r['overlay'] == 'hidden':
                log('READY', '%.0f s' % (time.time() - t0), json.dumps(r['marks'])[:600]); return True
        except (WDError, ValueError, KeyError) as e:
            line = 'POLL ' + str(e)[:200]
        if line != last:
            log('%.0f' % (time.time() - t0), line); last = line
        time.sleep(3)
    note('the game did not report ready within %d s' % deadline_s)
    return False


def state(page, name):
    try:
        r = page.js(STATE_JS, 60)
    except WDError as e:
        r = 'ERROR ' + str(e)[:300]
    with open(os.path.join(OUT, 'states.jsonl'), 'a') as f:
        f.write(json.dumps({'name': name, 'e': round(time.time(), 2), 'r': r}) + '\n')
    log('STATE_' + name, str(r)[:400])
    try:
        return json.loads(r)
    except (TypeError, ValueError):
        return None


class RouteFail(Exception):
    pass


def route(page, udid):
    """The desktop study's route without its camera aiming (touch controls take mouse look away)."""
    sleep = time.sleep

    def calibrate(name, how):
        r = page.js_async('window.__pc.%s.then((r) => JSON.stringify(r))' % how, 120)
        log('CAL_' + name, str(r)[:300])
        try:
            psi = json.loads(r)['psi']
        except (TypeError, ValueError, KeyError):
            raise RouteFail('calibration ' + name)
        page.js('window.__pc.cam = {psi: %r, theta: -8 * Math.PI / 180, g: 0.003}; return "ok";' % psi)

    def go(name, points, opts, tries):
        log('GO_' + name, page.js('return window.__pc.go(%s, %s);' % (points, opts)))
        r = ''
        for _ in range(tries):
            sleep(2)
            r = page.js('return JSON.stringify({done: window.__pc.ap.done, phase: window.__pc.ap.phase, result: window.__pc.ap.result, last: window.__pc.ap.log.slice(-1)[0]});')
            if '"done":true' in r:
                break
        log('AP_' + name, r)
        if 'landed' not in r:
            raise RouteFail('%s did not land: %s' % (name, r))

    calibrate('spawn', 'calibrate(500)')
    label('look1_start'); sleep(45); state(page, 'look1'); label('look1_end')
    label('walk_start')
    for name, x, z in (('walk-a', -91.18, 778.26), ('walk-b', -78.0, 770.5), ('walk-door', -68.17, 769.79)):
        go(name, '[[%r, %r]]' % (x, z), "{mode: 'land', deadline: 60}", 40)
    label('walk_end')
    page.js("return window.__pc.tap('f');"); sleep(1.5)
    s = state(page, 'in')
    if not s or s.get('driving') is not True:
        raise RouteFail('F beside the sedan did not get in')
    label('drive_start')
    for n in range(1, 6):
        page.js("return window.__pc.hold(['w', 'a'], 18000);"); sleep(20); state(page, 'drive-%d' % n)
    label('drive_end')
    page.js("return window.__pc.tap('f');"); sleep(2)
    s = state(page, 'out')
    if not s or s.get('driving') is not False:
        raise RouteFail('F did not get out')
    calibrate('air', 'calibrateAir(1500, 500)')
    label('fly_start')
    go('pier', '[[636.0, 324.0]]', "{cruise: 40, mode: 'land', deadline: 150}", 90)
    state(page, 'pier'); screenshot(udid, 'pier')
    calibrate('pier', 'calibrate(500)')
    go('back', '[[-104.36, 786.02]]', "{cruise: 40, mode: 'land', deadline: 150}", 90)
    label('fly_end')
    calibrate('back', 'calibrate(500)')
    label('look2_start'); sleep(60); state(page, 'look2'); label('look2_end')


def drive(udid):
    drv, sid = start_session(udid)
    url = URL + ('&' if '?' in URL else '?') + 'profile_startup=1'
    if sid is None:
        label('navigate')
        sh(['xcrun', 'simctl', 'openurl', udid, url], timeout=60)
        for k in range(12):
            time.sleep(15); screenshot(udid, 'openurl-%03d' % ((k + 1) * 15))
        label('ready_guess'); dump_sim_ps('ready_guess')
        time.sleep(IDLE_S)
        label('settle_end')
        return drv, None
    page = Page(sid)
    try:
        wd('POST', '/session/%s/timeouts' % sid, {'script': 600000, 'pageLoad': 600000, 'implicit': 0}, 30)
        label('navigate')
        wd('POST', '/session/%s/url' % sid, {'url': url}, 620)
        log('NAVIGATED')
        try:
            log('HOOK', page.js(open(os.path.join(HERE, 'memhook.js')).read() + '\nreturn window.__mem ? "installed" : "missing";', 60))
        except WDError as e:
            note('the memory hook could not be installed: %s' % str(e)[:200])
        ok = wait_ready(page, 900)
        label('ready')
        screenshot(udid, 'prompt'); dump_sim_ps('ready')
        env = page.js(ENV_JS, 60) if ok else None
        log('ENV', env)
        if env:
            open(os.path.join(OUT, 'env.json'), 'w').write(env)
        if not ok:
            return drv, sid
        log('HELPER', page.js('return ' + open(os.path.join(HERE, 'page-helper.js')).read().strip().rstrip(';') + ';', 60))
        log('SHIM', page.js('return window.__pc.installShim();'))
        before = json.loads(page.js("""return (() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); const r = document.getElementById('canvas').getBoundingClientRect();
          return JSON.stringify({prompt: s.start_prompt, paused: s.paused, touch_visible: s.touch_visible, x: Math.round(r.left + s.resume_button[0] * r.width / s.viewport[0]),
            y: Math.round(r.top + s.resume_button[1] * r.height / s.viewport[1]), viewport: s.viewport, rect: [r.left, r.top, r.width, r.height]}); })()"""))
        log('PROMPT_BEFORE', json.dumps(before))
        if ROUTE == 'prompt':
            log('ROUTE prompt: staying at the start prompt for %d s' % IDLE_S)
            time.sleep(IDLE_S); label('settle_end')
            return drv, sid
        for kind in ('touch', 'mouse'):
            label('prompt_tap')
            try:
                page.tap(before['x'], before['y'], kind)
            except WDError as e:
                log('TAP_FAILED', kind, str(e)[:300]); continue
            time.sleep(1.5)
            after = json.loads(page.js("return (() => { window.__tiReadback(); const s = JSON.parse(window.__tiState); return JSON.stringify({prompt: s.start_prompt, paused: s.paused, input: s.input}); })()"))
            log('PROMPT_AFTER', kind, json.dumps(after))
            if after.get('paused') is False and not after.get('prompt'):
                note('play started with a WebDriver %s tap on "%s" at %d,%d' % (kind, before['prompt'], before['x'], before['y']))
                break
        else:
            note('no tap started play; measuring the start prompt only')
            time.sleep(IDLE_S); label('settle_end')
            return drv, sid
        label('playing')
        time.sleep(2); state(page, 'spawn'); screenshot(udid, 'playing')
        try:
            route(page, udid)
        except (RouteFail, WDError, ValueError) as e:
            note('the route stopped early: %s; standing for %d s instead' % (str(e)[:300], IDLE_S))
            try:
                page.js('return window.__pc.stop();')
            except WDError:
                pass
            time.sleep(IDLE_S)
        label('settle_end')
        state(page, 'end'); screenshot(udid, 'end'); dump_sim_ps('end')
        try:
            open(os.path.join(OUT, 'hook-end.json'), 'w').write(page.js('return window.__mem ? window.__mem.dump() : "null";', 120))
        except WDError as e:
            log('HOOK_DUMP_FAILED', str(e)[:200])
    except WDError as e:
        note('WebDriver error: %s' % str(e)[:400])
    return drv, sid


# ---------------------------------------------------------------------------------------------- summary
def summarize():
    rows = []
    for line in open(os.path.join(OUT, 'footprint.jsonl')):
        try:
            r = json.loads(line)
        except ValueError:
            continue
        if 'p' in r:
            rows.append(r)
    labels = {}
    if os.path.exists(os.path.join(OUT, 'labels.jsonl')):
        for line in open(os.path.join(OUT, 'labels.jsonl')):
            r = json.loads(line); labels.setdefault(r['label'], r['e'])
    nav = labels.get('navigate'); ready = labels.get('ready') or labels.get('ready_guess'); play = labels.get('playing')
    end = labels.get('settle_end') or (rows[-1]['e'] if rows else None)
    # per kind: the largest process of that kind at each sample (the page's WebContent is the largest one)
    series = {}
    for r in rows:
        best = {}
        for kind, pid, rss, fp, peak, res, imax in r['p']:
            if fp is None:
                continue
            if kind not in best or fp > best[kind][1]:
                best[kind] = (pid, fp, peak, rss)
        for kind, v in best.items():
            series.setdefault(kind, []).append((r['e'],) + v)

    def win(pts, a, b):
        return [p[2] for p in pts if a is not None and b is not None and a <= p[0] <= b]
    out = {'labels': {k: round(v - nav, 1) for k, v in labels.items()} if nav else labels, 'kinds': {}, 'notes': NOTES}
    md = ['## iOS Simulator memory', '', 'URL: `%s`, route `%s`, device `%s`.' % (URL, ROUTE, DEVICE), '']
    md += ['- ' + n for n in NOTES]
    md += ['', 'phys_footprint (MiB) of the largest simulator process of each kind, sampled every second from the host; '
           '"peak" is the kernel\'s lifetime maximum for that process (catches spikes between samples).', '',
           '| process | load peak | at start prompt | play min | play median | play max | play slope MiB/min | lifetime peak |',
           '|---|---|---|---|---|---|---|---|']
    f = lambda v: '-' if v is None else '%.0f' % v
    for kind in ('web', 'gpu', 'net', 'safari'):
        pts = series.get(kind)
        if not pts:
            continue
        d = {}
        w = win(pts, nav, ready); d['load_peak'] = max(w) if w else None
        w = win(pts, ready, play or end); d['prompt_median'] = statistics.median(w) if w else None
        w = win(pts, play, end)
        if w:
            d.update(play_min=min(w), play_median=statistics.median(w), play_max=max(w))
            sel = [(p[0], p[2]) for p in pts if play <= p[0] <= end]
            if len(sel) > 10:
                mx = sum(e for e, _ in sel) / len(sel); my = sum(v for _, v in sel) / len(sel)
                den = sum((e - mx) ** 2 for e, _ in sel)
                d['play_slope'] = sum((e - mx) * (v - my) for e, v in sel) / den * 60 if den else None
        d['lifetime_peak'] = max(p[3] for p in pts if p[3] is not None) if any(p[3] is not None for p in pts) else None
        d['max_sampled'] = max(p[2] for p in pts)
        out['kinds'][kind] = d
        md.append('| %s | %s | %s | %s | %s | %s | %s | %s |' % ({'web': 'WebContent', 'gpu': 'GPU', 'net': 'Networking', 'safari': 'MobileSafari'}[kind],
                  f(d.get('load_peak')), f(d.get('prompt_median')), f(d.get('play_min')), f(d.get('play_median')), f(d.get('play_max')),
                  '-' if d.get('play_slope') is None else '%.1f' % d['play_slope'], f(d.get('lifetime_peak'))))
    md += ['', 'Phases (s after navigate): ' + ', '.join('%s %s' % (k, v) for k, v in out['labels'].items()), '',
           'The simulator has no jetsam: these processes are never killed at an iPhone\'s limit, and its GPU is the runner\'s '
           '(see system.txt), so read the numbers as how close the page comes, not as an iPhone measurement.']
    json.dump(out, open(os.path.join(OUT, 'summary.json'), 'w'), indent=1)
    open(os.path.join(OUT, 'summary.md'), 'w').write('\n'.join(md) + '\n')
    if os.environ.get('GITHUB_STEP_SUMMARY'):
        open(os.environ['GITHUB_STEP_SUMMARY'], 'a').write('\n'.join(md) + '\n')
    print('\n'.join(md))


def main():
    log('START url=%s route=%s device=%s' % (URL, ROUTE, DEVICE))
    host_info()
    udid = boot_simulator()
    sampler = subprocess.Popen(['sudo', '-n', sys.executable, os.path.abspath(__file__), '--sample', os.path.join(OUT, 'footprint.jsonl')])
    time.sleep(3)
    if sampler.poll() is not None:
        note('the sampler did not start under sudo (rc %s); running it as the runner user' % sampler.returncode)
        sampler = subprocess.Popen([sys.executable, os.path.abspath(__file__), '--sample', os.path.join(OUT, 'footprint.jsonl')])
    drv = sid = None
    try:
        drv, sid = drive(udid)
    except Exception as e:  # keep the measurement and the summary whatever the driver did
        note('driver error: %r' % e)
    finally:
        for pid, kind, _ in sim_processes():
            if kind in ('web', 'gpu'):
                for tool, args in (('footprint', [str(pid)]), ('vmmap', ['--summary', str(pid)])):
                    rc, out, err = sh(['sudo', '-n', tool] + args, timeout=180, quiet=True)
                    open(os.path.join(OUT, '%s-%s-%d.txt' % (tool, kind, pid)), 'w').write(out + err)
        if sid:
            try:
                wd('DELETE', '/session/' + sid, None, 60)
            except WDError as e:
                log('SESSION_DELETE_FAILED', str(e)[:200])
        if drv:
            drv.terminate()
        subprocess.run(['sudo', '-n', 'kill', '-TERM', str(sampler.pid)])
        sampler.terminate()
        try:
            sampler.wait(20)
        except subprocess.TimeoutExpired:
            subprocess.run(['sudo', '-n', 'kill', '-KILL', str(sampler.pid)])
        sh(['xcrun', 'simctl', 'shutdown', udid], timeout=120)
        sh(['xcrun', 'simctl', 'delete', udid], timeout=120)
        summarize()
        subprocess.run(['sudo', '-n', 'chmod', '-R', 'a+rX', OUT])
    log('END')


main()
