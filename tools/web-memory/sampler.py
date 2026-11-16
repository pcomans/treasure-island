#!/usr/bin/env python3
"""tools/web-memory/sampler.py XDG_RUNTIME_DIR OUT.jsonl [interval_s]: every process of one measured
browser session, found by its environment (XDG_RUNTIME_DIR names this session's private directory, so another
agent's browser never counts) and, for children whose environment cannot be read, by ancestry from such a process.
Each sample (default every 1 s) records per process: kind, pid, VmRSS, RssAnon, RssFile, RssShmem, VmHWM, VmSwap
(MiB, from /proc/PID/status) and the GPU memory its DRM clients hold (amdgpu fdinfo: drm-memory-vram/gtt, the
resident set, deduplicated by drm-client-id; MiB). Every 5th sample adds Pss/Pss_Anon/Pss_File/Pss_Shmem from
/proc/PID/smaps_rollup. Kinds: WebKit (GTK) ui/web/network/gpu, Chrome browser/renderer/gpu-process/utility, weston.
Stops on SIGTERM."""
import json, os, re, signal, sys, time

xdg, out = sys.argv[1], sys.argv[2]
step = float(sys.argv[3]) if len(sys.argv) > 3 else 1.0
tag = ('XDG_RUNTIME_DIR=' + xdg).encode()
COMM = {'MiniBrowser': 'ui', 'WebKitWebProces': 'web', 'WebKitNetworkPr': 'network', 'WebKitGPUProces': 'gpu',
        'weston': 'weston'}
stop = []
signal.signal(signal.SIGTERM, lambda *_: stop.append(1))
known = {}


def read(path, mode='r'):
    with open(path, mode) as f:
        return f.read()


def kind_of(pid, comm):
    if comm in COMM:
        return COMM[comm]
    if 'chrome' in comm:
        cmd = read(f'/proc/{pid}/cmdline').replace('\0', ' ')
        k = re.search(r'--type=([a-z-]+)', cmd)
        sub = re.search(r'--utility-sub-type=([a-zA-Z_.-]+)', cmd)
        return (k.group(1) if k else 'browser') + ('/' + sub.group(1) if sub else '')
    return None


def scan():
    parents, comms = {}, {}
    for pid in filter(str.isdigit, os.listdir('/proc')):
        if pid in known:
            continue
        try:
            comms[pid] = read(f'/proc/{pid}/comm').strip()
            parents[pid] = read(f'/proc/{pid}/stat').rsplit(')', 1)[1].split()[1]
        except OSError:
            continue
    tagged = set()
    for pid, comm in comms.items():
        try:
            if tag in read(f'/proc/{pid}/environ', 'rb'):
                tagged.add(pid)
        except OSError:
            pass
    for pid, comm in comms.items():
        p, hit = pid, False
        for _ in range(64):
            if p in tagged or p in known:
                hit = True
                break
            if p not in parents:
                break
            p = parents[p]
        if not hit:
            continue
        try:
            k = kind_of(pid, comm)
        except OSError:
            continue
        if k:
            known[pid] = k


def gpu_of(pid):
    seen, mem = set(), {}
    try:
        fds = os.listdir(f'/proc/{pid}/fdinfo')
    except OSError:
        return mem
    for fd in fds:
        try:
            text = read(f'/proc/{pid}/fdinfo/{fd}')
        except OSError:
            continue
        m = re.search(r'drm-client-id:\s+(\d+)', text)
        if not m or m.group(1) in seen:
            continue
        seen.add(m.group(1))
        for key, value, unit in re.findall(r'^(drm-(?:memory|total|resident|shared)-\w+|amd-[\w-]+):\s+(\d+)\s*(\w*)', text, re.M):
            v = int(value) * (1024 if unit == 'KiB' else 1048576 if unit == 'MiB' else 1)
            if v:
                mem[key] = mem.get(key, 0) + v
    return {k: round(v / 1048576.0, 1) for k, v in mem.items()}


def status(pid):
    s = read(f'/proc/{pid}/status')
    g = lambda k: round(int((re.search(k + r':\s+(\d+)', s) or [0, 0])[1]) / 1024.0, 1)
    return [g('VmRSS'), g('RssAnon'), g('RssFile'), g('RssShmem'), g('VmHWM'), g('VmSwap')]


def pss(pid):
    s = read(f'/proc/{pid}/smaps_rollup')
    g = lambda k: round(int((re.search('^' + k + r':\s+(\d+)', s, re.M) or [0, 0])[1]) / 1024.0, 1)
    return [g('Pss'), g('Pss_Anon'), g('Pss_File'), g('Pss_Shmem')]


t0 = time.time()
n = 0
with open(out, 'w', buffering=1) as f:
    f.write(json.dumps({'columns': ['kind', 'pid', 'rss', 'anon', 'file', 'shmem', 'hwm', 'swap'], 'gpu': 'MiB by fdinfo key',
                        'pss_columns': ['pss', 'pss_anon', 'pss_file', 'pss_shmem'], 'xdg': xdg, 'step_s': step}) + '\n')
    while not stop:
        if n % 2 == 0:
            scan()
        rows, gpu, pss_rows = [], {}, {}
        for pid, kind in list(known.items()):
            try:
                rows.append([kind, int(pid)] + status(pid))
                g = gpu_of(pid)
                if g:
                    gpu[pid] = g
                if n % 5 == 0 and kind != 'weston':
                    pss_rows[pid] = pss(pid)
            except OSError:
                known.pop(pid, None)
        row = {'e': round(time.time(), 2), 't': round(time.time() - t0, 2), 'p': rows, 'gpu': gpu}
        if pss_rows:
            row['pss'] = pss_rows
        f.write(json.dumps(row) + '\n')
        n += 1
        time.sleep(max(0.05, t0 + n * step - time.time()))
