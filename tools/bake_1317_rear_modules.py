"""Bake the owner-approved (2026-10-22) WSW rear openings of 1317 Gateview (w95934125).

The 1317 live factory draws its modules from baked buckets in
game/resources/facades/d5_1317_quality_study_geometry.json. This tool starts from the
accepted front-only bake (--base-geometry/--base-config, e.g. from
`git show a2dda11:<path>`) and appends cuboids in the accepted module family, so the
accepted batch list is unchanged:
- per unit (two per rear section), one closed ground group (boarded door with jambs and
  head, boarded window with a 4-piece frame) seated on the sampled visible ground, and
  two boarded upper windows (field plus 4-piece pale frame);
- the ground groups join the ClosedLowerModules collision group through their buckets,
  like the front ones.
It also records the placements and the rear runs that take the front's lap siding
(inferred_rear_modules.siding_runs) and refreshes the config's documented batches,
expected counts and geometry hash. Counts and positions are production inference.

Usage (from the repository root):
  git show a2dda11:game/resources/facades/d5_1317_quality_study_geometry.json > /tmp/g.json
  git show a2dda11:game/resources/facades/d5_1317_gateview_quality_study.json > /tmp/c.json
  python3 -I tools/bake_1317_rear_modules.py . --base-geometry /tmp/g.json --base-config /tmp/c.json [--write]
"""
import hashlib, json, math, sys

WT = sys.argv[1]
ARGS = sys.argv[2:]
WRITE = "--write" in ARGS
BASE_GEOM = ARGS[ARGS.index("--base-geometry") + 1]
BASE_CFG = ARGS[ARGS.index("--base-config") + 1]
GEOM = f"{WT}/game/resources/facades/d5_1317_quality_study_geometry.json"
CFG = f"{WT}/game/resources/facades/d5_1317_gateview_quality_study.json"
CHUNK = f"{WT}/generated/world/chunks/x_-3__z_-2.json"
# Rear sections (straight run groups) and their boarding finish; each holds two units.
GROUPS = [("rear-A", [0, 1], "boarded_warm_brown"), ("rear-B", [3, 4, 5], "dark_opaque_closed"), ("rear-C", [7, 8], "boarded_warm_brown")]
# Every WSW rear run, including the short jog faces 2 and 6, takes the front's siding.
SIDING_RUNS = [0, 1, 2, 3, 4, 5, 6, 7, 8]
UPPER = {"width": 1.25, "height": 1.05, "bottom_y": 6.35, "frame": 0.07, "field_d": (0.0, 0.06), "frame_d": (0.0, 0.12)}
GROUND = {"door_off": -0.52, "door_w": 0.9, "door_h": 2.03, "win_off": 0.55, "win_w": 0.9, "win_h": 1.1, "sill": 0.82,
          "frame": 0.07, "field_d": (-0.005, 0.055), "frame_d": (0.035, 0.135)}

chunk = json.load(open(CHUNK))
rec = {r["object_key"]: r for r in chunk["records"]}
wall = rec["building:w95934125:wall"]
V, N = wall["vertices"], wall["normals"]
surfaces = [rec[k] for k in ("area:r17241151:x_-3__z_-2", "area:r17241152:x_-3__z_-2", "land:w26767313:x_-3__z_-2")]


def sample(r, x, z):
    v, idx, hits = r["vertices"], r["indices"], []
    for i in range(0, len(idx), 3):
        a, b, c = (v[3 * idx[i + k]:3 * idx[i + k] + 3] for k in range(3))
        det = (b[2] - c[2]) * (a[0] - c[0]) + (c[0] - b[0]) * (a[2] - c[2])
        if det == 0:
            continue
        l1 = ((b[2] - c[2]) * (x - c[0]) + (c[0] - b[0]) * (z - c[2])) / det
        l2 = ((c[2] - a[2]) * (x - c[0]) + (a[0] - c[0]) * (z - c[2])) / det
        if min(l1, l2, 1 - l1 - l2) >= -1e-9:
            hits.append(l1 * a[1] + l2 * b[1] + (1 - l1 - l2) * c[1])
    return hits


def visible_y(x, z):
    """Highest visible area surface at the point, else land; and the land below it."""
    areas = [h for r in surfaces[:2] for h in sample(r, x, z)]
    land = sample(surfaces[2], x, z)
    assert len(land) == 1, ("land", x, z, land)
    return (max(areas) if areas else land[0]), land[0]


def frame_for(runs):
    a = V[runs[0] * 12:runs[0] * 12 + 3]
    b = V[runs[-1] * 12 + 3:runs[-1] * 12 + 6]
    L = math.hypot(b[0] - a[0], b[2] - a[2])
    t = ((b[0] - a[0]) / L, (b[2] - a[2]) / L)
    n = (N[runs[0] * 12], N[runs[0] * 12 + 2])
    for r in runs:  # straight, consecutive, outward normal shared
        o = r * 12
        for p in (V[o:o + 3], V[o + 3:o + 6]):
            assert abs((p[0] - a[0]) * n[0] + (p[2] - a[2]) * n[1]) < 0.02, ("not straight", runs)
        assert abs(N[o] - n[0]) < 0.01 and abs(N[o + 2] - n[1]) < 0.01, ("normal", r)
    assert abs(t[0] * n[0] + t[1] * n[1]) < 0.01 and abs((-t[1]) - n[0]) < 0.01, ("normal = tangent x up", runs)
    return {"o": (a[0], a[2]), "t": t, "n": n, "L": L}


def cuboid(bucket, f, s0, s1, y0, y1, d0, d1):
    t, n, o = f["t"], f["n"], f["o"]
    P = lambda s, y, d: (o[0] + t[0] * s + n[0] * d, y, o[1] + t[1] * s + n[1] * d)
    T, U, NN = (t[0], 0.0, t[1]), (0.0, 1.0, 0.0), (n[0], 0.0, n[1])
    neg = lambda v: tuple(-x for x in v)
    faces = [  # (normal, CCW corners seen from outside)
        (NN, [P(s0, y0, d1), P(s1, y0, d1), P(s1, y1, d1), P(s0, y1, d1)]),
        (neg(NN), [P(s1, y0, d0), P(s0, y0, d0), P(s0, y1, d0), P(s1, y1, d0)]),
        (U, [P(s0, y1, d1), P(s1, y1, d1), P(s1, y1, d0), P(s0, y1, d0)]),
        (neg(U), [P(s0, y0, d0), P(s1, y0, d0), P(s1, y0, d1), P(s0, y0, d1)]),
        (T, [P(s1, y0, d1), P(s1, y0, d0), P(s1, y1, d0), P(s1, y1, d1)]),
        (neg(T), [P(s0, y0, d0), P(s0, y0, d1), P(s0, y1, d1), P(s0, y1, d0)]),
    ]
    for normal, c in faces:
        for tri in ((c[0], c[1], c[2]), (c[0], c[2], c[3])):
            base = len(bucket["vertices"]) // 3
            for p in tri:
                bucket["vertices"].extend(p)
                bucket["normals"].extend(normal)
                bucket["uvs"].extend((-(p[0] * t[0] + p[2] * t[1]), p[1]))
            bucket["indices"].extend((base, base + 2, base + 1))


def frame4(bucket, f, s, w, y0, h, fw, d):
    cuboid(bucket, f, s - w / 2 - fw, s + w / 2 + fw, y0 - fw, y0, *d)
    cuboid(bucket, f, s - w / 2 - fw, s + w / 2 + fw, y0 + h, y0 + h + fw, *d)
    cuboid(bucket, f, s - w / 2 - fw, s - w / 2, y0, y0 + h, *d)
    cuboid(bucket, f, s + w / 2, s + w / 2 + fw, y0, y0 + h, *d)


geom = json.load(open(BASE_GEOM))
B = geom["buckets"]
before = {k: len(b["indices"]) // 3 for k, b in B.items()}
report, record = [], []
for name, runs, finish in GROUPS:
    f = frame_for(runs)
    L = f["L"]
    half = L / 2
    upper_bucket = B["UpperWarmBoardedFields" if finish == "boarded_warm_brown" else "UpperDarkOpaqueFields"]
    for unit in range(2):
        u0 = unit * half
        for s in (round(u0 + half * 0.27, 3), round(u0 + half * 0.73, 3)):
            u = UPPER
            cuboid(upper_bucket, f, s - u["width"] / 2, s + u["width"] / 2, u["bottom_y"], u["bottom_y"] + u["height"], *u["field_d"])
            frame4(B["PaleUpperFrames"], f, s, u["width"], u["bottom_y"], u["height"], u["frame"], u["frame_d"])
            record.append({"group": name, "unit": unit, "runs": runs, "kind": "upper", "station_m": s, "finish": finish})
        s = round(u0 + half * 0.5, 3)
        g = GROUND
        ds, ws = s + g["door_off"], s + g["win_off"]
        # Seat the door on the highest visible surface under its footprint, as the front groups.
        pts = [(f["o"][0] + f["t"][0] * q + f["n"][0] * d, f["o"][1] + f["t"][1] * q + f["n"][1] * d)
               for q in (ds - g["door_w"] / 2, ds, ds + g["door_w"] / 2) for d in (0.0, 0.1)]
        vis, land = zip(*(visible_y(x, z) for x, z in pts))
        datum = max(vis)
        bottom = datum - 0.04
        assert bottom > max(land) - 0.06, ("door bottom below land", name, bottom, land)
        top = datum + g["door_h"]
        cuboid(B["ClosedGroundBoardedFields"], f, ds - g["door_w"] / 2, ds + g["door_w"] / 2, bottom, top, *g["field_d"])
        fw = g["frame"]
        cuboid(B["PaleGroundFrames"], f, ds - g["door_w"] / 2 - fw, ds - g["door_w"] / 2, bottom, top, *g["frame_d"])
        cuboid(B["PaleGroundFrames"], f, ds + g["door_w"] / 2, ds + g["door_w"] / 2 + fw, bottom, top, *g["frame_d"])
        cuboid(B["PaleGroundFrames"], f, ds - g["door_w"] / 2 - fw, ds + g["door_w"] / 2 + fw, top, top + fw, *g["frame_d"])
        sill = datum + g["sill"]
        cuboid(B["ClosedGroundBoardedFields"], f, ws - g["win_w"] / 2, ws + g["win_w"] / 2, sill, sill + g["win_h"], *g["field_d"])
        frame4(B["PaleGroundFrames"], f, ws, g["win_w"], sill, g["win_h"], fw, g["frame_d"])
        record.append({"group": name, "unit": unit, "runs": runs, "kind": "ground", "station_m": s, "door_station_m": round(ds, 3),
                       "window_station_m": round(ws, 3), "visible_datum_y": round(datum, 4), "door_bottom_y": round(bottom, 4)})
        report.append(f"{name}/{unit} runs={runs} L={L:.2f} ground@{s:.2f} datum={datum:.4f} land={min(land):.4f}..{max(land):.4f}")
after = {k: len(b["indices"]) // 3 for k, b in B.items()}
print("\n".join(report))
print("triangles added", {k: after[k] - before[k] for k in after if after[k] != before[k]})
if WRITE:
    text = json.dumps(geom, separators=(",", ":")) + "\n"
    open(GEOM, "w").write(text)
    cfg = json.load(open(BASE_CFG))
    added = sum(after[k] - before[k] for k in after)
    added_collision = sum(after[k] - before[k] for k in ("ClosedGroundBoardedFields", "PaleGroundFrames"))
    cfg["batches"] = {k: after.get(k, v) for k, v in cfg["batches"].items()}
    cfg["expected"]["render_triangles"] = cfg["expected"]["render_triangles"] + added
    cfg["expected"]["collision_triangles"] = cfg["expected"]["collision_triangles"] + added_collision
    cfg["geometry_sha256"] = hashlib.sha256(text.encode()).hexdigest()
    cfg["inferred_rear_modules"] = {
        "inference": "production_inference: owner-approved openings on the unphotographed WSW rear (2026-10-22): per unit an entry, a ground window and two upper windows in the accepted boarded family, baked into the existing buckets by tools/bake_1317_rear_modules.py; the rear runs take the front's lap siding; counts and positions are not as-built",
        "siding_runs": SIDING_RUNS,
        "modules": record}
    open(CFG, "w").write(json.dumps(cfg, indent=2) + "\n")
    print("WROTE", GEOM, CFG, "added", added, "collision", added_collision)
