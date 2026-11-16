#!/usr/bin/env python3
"""tools/web-memory/summarize.py RUN_OUT_DIR... [--series N] [--json]: one block per measured session, WebKit or
Chrome, read only from the session's own files: proc.jsonl (sampler.py, 1 s), labels.jsonl, hook-end.json (memhook.js)
and, for Chrome, cdp.jsonl (V8 heap). Processes are grouped by role: page = WebKit's WebKitWebProcess / Chrome's
largest renderer; gpu = WebKitGPUProcess / Chrome's gpu-process; net = WebKitNetworkProcess / Chrome's network
utility; ui = MiniBrowser / Chrome's browser process. For each role: RSS plus VmSwap (MiB; this machine swaps to zram
when other work presses on memory, and a swapped page still belongs to the process) as the load peak (navigate..ready,
sampled max, and the kernel's VmHWM at ready), the start-prompt level (median ready..playing), the play range (min /
median / max, playing..settle_end) and slope (least squares, MiB/min) with first- and last-minute medians; the same
for the GPU memory the role's DRM clients hold (amdgpu fdinfo VRAM+GTT; on an APU both are system RAM). --series N
prints the roles every N seconds from navigate; --json writes summary.json beside each run."""
import json, os, statistics, sys

args = [a for a in sys.argv[1:] if not a.startswith('--')]
series_step = None
if '--series' in sys.argv:
    series_step = float(sys.argv[sys.argv.index('--series') + 1]); args = [a for a in args if a != sys.argv[sys.argv.index('--series') + 1]]
write_json = '--json' in sys.argv
MiB = 1048576.0


def jl(path):
    if not os.path.exists(path):
        return []
    out = []
    for line in open(path):
        line = line.strip()
        if line:
            try:
                out.append(json.loads(line))
            except ValueError:
                pass
    return out


def role(kind):
    if kind in ('web', 'renderer'):
        return 'page'
    if kind in ('gpu', 'gpu-process'):
        return 'gpu'
    if kind == 'network' or 'network' in kind.lower():
        return 'net'
    if kind in ('ui', 'browser'):
        return 'ui'
    if kind == 'weston':
        return 'weston'
    return 'other'


def gpu_mb(g):
    if not g:
        return 0.0
    vram = g.get('drm-total-vram', g.get('drm-memory-vram', 0.0))
    gtt = g.get('drm-total-gtt', g.get('drm-memory-gtt', 0.0))
    return vram + gtt


def load_run(out):
    rows = jl(os.path.join(out, 'proc.jsonl'))
    head = rows[0] if rows and 'columns' in rows[0] else None
    rows = [r for r in rows if 'p' in r]
    labels = {}
    for r in jl(os.path.join(out, 'labels.jsonl')):
        labels.setdefault(r['label'], float(r['e']))
    S = []  # epoch, {role: (rss, anon, hwm, gpu, pid)}
    for r in rows:
        per = {}
        for p in r['p']:
            kind, pid, rss, anon, file_, shmem, hwm, swap = p
            rss = rss + swap  # a page swapped out (zram) under another process's pressure still belongs to the process
            ro = role(kind)
            g = gpu_mb(r.get('gpu', {}).get(str(pid)))
            if ro == 'page':
                # the game page: the largest renderer (Chrome may keep a spare renderer)
                if 'page' in per and per['page'][0] >= rss:
                    continue
                per['page'] = (rss, anon, hwm, g, pid)
            else:
                old = per.get(ro)
                per[ro] = (rss + (old[0] if old else 0), anon + (old[1] if old else 0), max(hwm, old[2] if old else 0), g + (old[3] if old else 0), pid)
        S.append((r['e'], per))
    hook = None
    for name in ('hook-end.json', 'hook-failure.json', 'hook-notready.json'):
        p = os.path.join(out, name)
        if os.path.exists(p):
            hook = json.load(open(p)); hook['_file'] = name
            break
    cdp = [r for r in jl(os.path.join(out, 'cdp.jsonl')) if isinstance(r.get('heap'), dict) and 'usedSize' in r['heap']]
    return labels, S, hook, cdp


def val(S, ro, col):
    return [(e, per[ro][col]) for e, per in S if ro in per]


def window(points, a, b):
    return [v for e, v in points if a <= e <= b]


def slope(points, a, b):
    pts = [(e, v) for e, v in points if a <= e <= b]
    if len(pts) < 10:
        return None
    n = len(pts); mx = sum(e for e, _ in pts) / n; my = sum(v for _, v in pts) / n
    den = sum((e - mx) ** 2 for e, _ in pts)
    return None if den == 0 else sum((e - mx) * (v - my) for e, v in pts) / den * 60.0


def fmt(v, nd=0):
    return '-' if v is None else (('%.' + str(nd) + 'f') % v)


def summarize(out):
    labels, S, hook, cdp = load_run(out)
    name = out.rstrip('/').split('/')[-2] if out.rstrip('/').endswith('out') else out.rstrip('/').split('/')[-1]
    nav, ready, play = labels.get('navigate'), labels.get('ready'), labels.get('playing')
    end = labels.get('settle_end') or (S[-1][0] if S else None)
    res = {'run': name, 'labels': {k: round(v - nav, 1) for k, v in labels.items()} if nav else labels, 'roles': {}}
    roles = sorted({ro for _, per in S for ro in per}, key=lambda r: ['page', 'gpu', 'net', 'ui', 'weston', 'other'].index(r))
    for ro in roles:
        rss = val(S, ro, 0); hwm = val(S, ro, 2); g = val(S, ro, 3)
        d = {}
        if nav and ready:
            w = window(rss, nav, ready); d['load_peak_rss'] = max(w) if w else None
            w = window(hwm, nav, ready + 1.5); d['hwm_at_ready'] = max(w) if w else None
            w = window(g, nav, ready); d['load_peak_gpu'] = max(w) if w else None
        if ready and play:
            w = window(rss, ready, play); d['prompt_rss'] = statistics.median(w) if w else None
            w = window(g, ready, play); d['prompt_gpu'] = statistics.median(w) if w else None
        if play and end:
            w = window(rss, play, end)
            if w:
                d.update(play_min=min(w), play_med=statistics.median(w), play_max=max(w))
            d['play_slope'] = slope(rss, play, end)
            f1 = window(rss, play, play + 60); l1 = window(rss, end - 60, end)
            d['first_min_med'] = statistics.median(f1) if f1 else None
            d['last_min_med'] = statistics.median(l1) if l1 else None
            w = window(g, play, end)
            if w:
                d.update(play_gpu_min=min(w), play_gpu_max=max(w))
            d['play_gpu_slope'] = slope(g, play, end)
        allr = [v for _, v in rss]; d['max_rss_all'] = max(allr) if allr else None
        allh = [v for _, v in hwm]; d['hwm_end'] = max(allh) if allh else None
        res['roles'][ro] = d
    if hook:
        t0 = hook['t0'] / 1000.0
        H = sorted([(t0 + r['t'] / 1000.0, r) for r in hook['marks'] + hook['ticks'] + [hook['now']]], key=lambda x: x[0])
        def at(e):
            return min(H, key=lambda x: abs(x[0] - e))[1] if H and e else None
        hr = {}
        for lab, e in (('ready', ready), ('playing', play), ('end', end)):
            r = at(e)
            if r:
                hr[lab] = {'wasm': r['wasm'] / MiB, 'gl_tex': r['gl_tex'] / MiB, 'gl_buf': r['gl_buf'] / MiB, 'gl_bufN': r['gl_bufN'],
                           'js_used': (r['js_used'] or 0) / MiB if r.get('js_used') is not None else None,
                           'audioBuffers': r.get('audioBuffers'), 'audioMiB': (r.get('audioBytes') or 0) / MiB}
        hr['wasm_max'] = max(r['wasm'] for _, r in H) / MiB
        hr['grows'] = len(hook.get('grows', []))
        a = hook.get('audio') or {}
        hr['audio_total'] = {'buffers': a.get('buffers'), 'MiB': (a.get('bytes') or 0) / MiB, 'sources': a.get('sources'), 'contexts': a.get('contexts')}
        if play and end:
            p0, p1 = at(play), at(end)
            if p0 and p1:
                hr['audio_MiB_per_min_in_play'] = ((p1.get('audioBytes') or 0) - (p0.get('audioBytes') or 0)) / MiB / max((end - play) / 60.0, 1e-9)
        res['hook'] = hr
    if cdp:
        def cd(a, b):
            w = [r['heap']['usedSize'] / MiB for r in cdp if a <= r['e'] <= b]
            return w
        js = {}
        if nav and ready:
            w = cd(nav, ready); js['load_peak'] = max(w) if w else None
        if play and end:
            w = cd(play, end)
            if w:
                js.update(play_min=min(w), play_max=max(w))
        gc = [r for r in cdp if r.get('label') == 'after_gc']
        if gc:
            js['after_gc'] = gc[-1]['heap']['usedSize'] / MiB
        res['v8_heap'] = js
    res['_series'] = S
    res['_labels'] = labels
    return res


runs = [summarize(o) for o in args]
for r in runs:
    print('=' * 100)
    print('RUN', r['run'], ' labels (s after navigate):', ', '.join('%s %s' % (k, v) for k, v in r['labels'].items() if k in ('ready', 'playing', 'drive_start', 'drive_end', 'fly_start', 'fly_end', 'settle_end', 'closed')))
    print('%-7s %9s %9s %9s %9s | %8s %8s %8s %9s %8s %8s | %9s %9s %9s' % ('role', 'loadPeak', 'HWM@rdy', 'prompt', 'gpu@prmt', 'playMin', 'playMed', 'playMax', 'slope/min', '1stMin', 'lastMin', 'gpuPlayMx', 'gpuSlope', 'HWM@end'))
    for ro, d in r['roles'].items():
        print('%-7s %9s %9s %9s %9s | %8s %8s %8s %9s %8s %8s | %9s %9s %9s' % (ro, fmt(d.get('load_peak_rss')), fmt(d.get('hwm_at_ready')), fmt(d.get('prompt_rss')), fmt(d.get('prompt_gpu')),
              fmt(d.get('play_min')), fmt(d.get('play_med')), fmt(d.get('play_max')), fmt(d.get('play_slope'), 1), fmt(d.get('first_min_med')), fmt(d.get('last_min_med')),
              fmt(d.get('play_gpu_max')), fmt(d.get('play_gpu_slope'), 1), fmt(d.get('hwm_end'))))
    h = r.get('hook')
    if h:
        print('hook:', ' '.join('%s[wasm %.0f tex %.0f buf %.0f (%s) js %s audio %s/%.0f MiB]' % (k, v['wasm'], v['gl_tex'], v['gl_buf'], v['gl_bufN'], fmt(v['js_used']), v['audioBuffers'], v['audioMiB'])
                                for k, v in h.items() if isinstance(v, dict) and 'wasm' in v),
              '| wasm max %.0f, grows %d | audio total %s | audio MiB/min in play %s' % (h['wasm_max'], h['grows'], json.dumps(h['audio_total'])[:200], fmt(h.get('audio_MiB_per_min_in_play'), 1)))
    if r.get('v8_heap'):
        print('V8 heap (CDP):', json.dumps({k: round(v, 1) for k, v in r['v8_heap'].items() if v is not None}))
    if series_step:
        labels = r['_labels']; nav = labels.get('navigate'); S = r['_series']
        order = sorted(labels.items(), key=lambda kv: kv[1])
        roles = list(r['roles'].keys())
        print('series every %.0f s (RSS MiB; gpu = DRM VRAM+GTT MiB):' % series_step)
        print('%6s %-12s ' % ('t', 'phase') + ' '.join('%14s' % (ro + ' rss/gpu') for ro in roles))
        t = 0.0
        while S and nav + t <= S[-1][0]:
            e = nav + t
            pts = [x for x in S if abs(x[0] - e) <= series_step / 2]
            ph = [k for k, v in order if v <= e]
            cells = []
            for ro in roles:
                rs = [x[1][ro][0] for x in pts if ro in x[1]]; gs = [x[1][ro][3] for x in pts if ro in x[1]]
                cells.append('%14s' % ('%s/%s' % (fmt(max(rs)) if rs else '-', fmt(max(gs)) if gs else '-')))
            print('%6.0f %-12s ' % (t, (ph[-1] if ph else '-')[:12]) + ' '.join(cells))
            t += series_step
    if write_json:
        out = [a for a in args if r['run'] in a][0]
        json.dump({k: v for k, v in r.items() if not k.startswith('_')}, open(os.path.join(out, 'summary.json'), 'w'), indent=1)
