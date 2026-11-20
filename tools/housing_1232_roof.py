#!/usr/bin/env python3
"""1232 Northpoint's roof as segment gables: the one generator of its roof data.

The March 2025 photos show each of 1232's three segments (north, middle, south) under its
own gable roof, its ridge on the segment's centre line, the eaves level, and a rake at the
steps between segments. This script writes that roof, from the frozen wall record, into
game/resources/housing_family/w96215673.json:

  roof_plane                    the description both builders follow: the production roof
                                (northpoint_1232_quality_model.gd, via the live factory) and
                                the family's roof details (housing_unit_detail.gd);
  retained_roof_wall_closures   the siding between the family's 8.05 m wall top and that
                                roof along every run, and the gable ends where neighbouring
                                segments' roofs differ at a step;
  roof_vents.avoid              the production roof's six pipe vents where the segment roof
                                puts them (0.8 m from their ridge), for the details to keep
                                clear of.

Usage: tools/housing_1232_roof.py [--check]
--check writes nothing and fails if the config differs from what it would write.
game/tests/headless_housing_unit_detail_contract.gd checks the written data against itself
(closures and vents on the roof surface, the model's frame).

Pitch 0.36 and the segment outlines are production inference: the pitch from the north-end
photo through its solved camera (the north gable's apex, its west rake and the ridge's
silhouette over units 1-2), the outlines from the frozen footprint's outermost walls.
"""
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CONFIG = os.path.join(ROOT, "game/resources/housing_family/w96215673.json")
CHUNK = os.path.join(ROOT, "generated/world/chunks/x_-2__z_-3.json")
WALL_KEY = "building:w96215673:wall"

# The production roof's frame (northpoint_1232_quality_model.gd ROOF_AXIS, ROOF_NORMAL,
# ROOF_RIDGE_D): t along the ridge (north to south grows), d across it (west positive).
TAN = (-0.04894628457, 0.9988014123)
NORM = (-0.9988014123, -0.04894628457)
RIDGE_D = 336.328678
WALL_TOP = 8.05
SLOPE = 0.36
EAVE = 8.073
# Each segment's outermost west and east walls (d) in the frozen footprint, north first.
OUTLINES = [(6.429, -4.493), (5.170, -6.429), (6.251, -4.706)]
# Each step's west and east lines (t): runs 14 and 6, then 19 and 2, each on the side its
# step wall's roof belongs to.
STEPS = [(-725.67, -725.58), (-711.16, -710.43)]
EXTENT_T = [-739.65, -696.48]
PRODUCTION_VENTS_T = (-736.0, -730.0, -723.5, -717.0, -710.5, -704.0)
EVIDENCE = ("Google Street View, March 2025: 1232 west front (pano CN9mis-1NnYxLSEucK7PvQ, heading 90.7) and north end "
            "with the west front (heading 162.5, Maps label 1227): each segment under its own gable roof with a rake at the steps "
            "(front photo, the north step); the north gable's apex on that segment's centre line. Pitch 0.36 from the north-end "
            "photo through its solved camera (apex, west rake, ridge silhouette); production inference. Written by "
            "tools/housing_1232_roof.py.")


def td(x, z):
    return x * TAN[0] + z * TAN[1], x * NORM[0] + z * NORM[1] - RIDGE_D


def xz(t, d):
    return (TAN[0] * t + NORM[0] * (RIDGE_D + d), TAN[1] * t + NORM[1] * (RIDGE_D + d))


class Roof:
    """Segments [{"ridge_offset", "ridge_y"}] and cuts [{"west_t", "east_t", "jog_d"}]: a point
    lies before cut k where t <= west_t for d >= jog_d, east_t otherwise."""

    def __init__(self, slope, segments, cuts):
        self.slope = slope
        self.segments = segments
        self.cuts = cuts

    def segment(self, t, d):
        for k, c in enumerate(self.cuts):
            if t <= (c["west_t"] if d >= c["jog_d"] else c["east_t"]):
                return k
        return len(self.cuts)

    def h(self, t, d, k=None):
        if k is None:
            k = self.segment(t, d)
        s = self.segments[k]
        return s["ridge_y"] - abs(d - s["ridge_offset"]) * self.slope


def segment_roof():
    """Each ridge on its segment's centre line, its eaves at EAVE; a cut's jog where its two
    neighbours' slopes cross between their ridges (one height both sides, so no wall)."""
    segments = []
    for d_west, d_east in OUTLINES:
        segments.append({"ridge_offset": round((d_west + d_east) / 2, 4), "ridge_y": round(EAVE + (d_west - d_east) / 2 * SLOPE, 4),
                         "half_width": round((d_west - d_east) / 2, 4)})
    cuts = []
    for k, (west_t, east_t) in enumerate(STEPS):
        a, b = segments[k], segments[k + 1]
        if a["ridge_offset"] > b["ridge_offset"]:
            jog = (b["half_width"] - a["half_width"] + a["ridge_offset"] + b["ridge_offset"]) / 2
        else:
            jog = (a["half_width"] - b["half_width"] + a["ridge_offset"] + b["ridge_offset"]) / 2
        cuts.append({"west_t": west_t, "east_t": east_t, "jog_d": round(jog, 4)})
    return Roof(SLOPE, segments, cuts)


def ring_from_chunk(path=CHUNK, key=WALL_KEY):
    c = json.load(open(path))
    v = [r for r in c["records"] if r["object_key"] == key][0]["vertices"]
    return [(v[i], v[i + 2]) for i in range(0, len(v), 12)]


def _crossings(roof, a, b):
    (ta, da), (tb, db) = td(*a), td(*b)
    out = set()
    for c in roof.cuts:
        for limit, west in ((c["west_t"], True), (c["east_t"], False)):
            if (ta - limit) * (tb - limit) < 0:
                lam = (limit - ta) / (tb - ta)
                if (da + (db - da) * lam >= c["jog_d"]) == west:
                    out.add(lam)
    for k, s in enumerate(roof.segments):
        dc = s["ridge_offset"]
        if (da - dc) * (db - dc) < 0:
            lam = (dc - da) / (db - da)
            if roof.segment(ta + (tb - ta) * lam, dc) == k:
                out.add(lam)
    return sorted(out)


def _lerp(a, b, lam):
    return (a[0] + (b[0] - a[0]) * lam, a[1] + (b[1] - a[1]) * lam)


def edge_closures(roof, ring):
    """Wall-top-to-roof triangles along every run, split at the cuts and ridges, wound as the
    family's retained closures are (front faces outward)."""
    tris = []
    for i in range(len(ring)):
        a, b = ring[i], ring[(i + 1) % len(ring)]
        lams = [0.0] + _crossings(roof, a, b) + [1.0]
        for j in range(len(lams) - 1):
            u, v = _lerp(a, b, lams[j]), _lerp(a, b, lams[j + 1])
            k = roof.segment(*td(*_lerp(a, b, (lams[j] + lams[j + 1]) / 2)))
            uy, vy = roof.h(*td(*u), k=k), roof.h(*td(*v), k=k)
            tris.append([[u[0], WALL_TOP, u[1]], [v[0], vy, v[1]], [v[0], WALL_TOP, v[1]]])
            tris.append([[u[0], WALL_TOP, u[1]], [u[0], uy, u[1]], [v[0], vy, v[1]]])
    return tris


def _line_bounds(ring, t):
    out = []
    for i in range(len(ring)):
        (ta, da), (tb, db) = td(*ring[i]), td(*ring[(i + 1) % len(ring)])
        if (ta - t) * (tb - t) < 0:
            out.append(da + (db - da) * (t - ta) / (tb - ta))
    return sorted(out)


def step_closures(roof, ring):
    """The gable ends exposed where neighbouring segments' roofs differ, along each cut's two
    lines from the jog out to the walls, wound to face the lower roof's side."""
    tris = []
    for k, c in enumerate(roof.cuts):
        for t, west in ((c["west_t"], True), (c["east_t"], False)):
            bounds = _line_bounds(ring, t)
            if west:
                above = [d for d in bounds if d > c["jog_d"]]
                if not above:
                    continue
                d0, d1 = c["jog_d"], min(above)
            else:
                below = [d for d in bounds if d < c["jog_d"]]
                if not below:
                    continue
                d0, d1 = max(below), c["jog_d"]
            breaks = sorted({d0, d1} | {s["ridge_offset"] for s in roof.segments[k:k + 2] if d0 < s["ridge_offset"] < d1})
            for j in range(len(breaks) - 1):
                da, db = breaks[j], breaks[j + 1]
                ha = (roof.h(t, da, k), roof.h(t, da, k + 1))
                hb = (roof.h(t, db, k), roof.h(t, db, k + 1))
                if max(ha) - min(ha) < 0.005 and max(hb) - min(hb) < 0.005:
                    continue
                before_higher = (ha[0] + hb[0]) > (ha[1] + hb[1])
                pa, pb = xz(t, da), xz(t, db)
                a0, a1 = (pa[0], min(ha), pa[1]), (pa[0], max(ha), pa[1])
                b0, b1 = (pb[0], min(hb), pb[1]), (pb[0], max(hb), pb[1])
                vis = TAN if before_higher else (-TAN[0], -TAN[1])
                for tri in ([a0, b1, b0], [a0, a1, b1]):
                    e1 = [tri[1][i] - tri[0][i] for i in range(3)]
                    e2 = [tri[2][i] - tri[0][i] for i in range(3)]
                    cx = e1[1] * e2[2] - e1[2] * e2[1]
                    cy = e1[2] * e2[0] - e1[0] * e2[2]
                    cz = e1[0] * e2[1] - e1[1] * e2[0]
                    # Front faces wind so that this cross points away from the viewer.
                    if cx * vis[0] + cz * vis[1] > 0:
                        tri = [tri[0], tri[2], tri[1]]
                    if cx * cx + cy * cy + cz * cz > 1e-10:
                        tris.append([list(p) for p in tri])
    return tris


def roof_data(ring):
    roof = segment_roof()
    plane = {
        "evidence": EVIDENCE,
        "axis": list(TAN), "normal": list(NORM), "ridge_d": RIDGE_D, "slope": SLOPE,
        "segments": [{"ridge_offset": s["ridge_offset"], "ridge_y": s["ridge_y"]} for s in roof.segments],
        "cuts": roof.cuts, "extent_t": EXTENT_T,
    }
    closures = [[[round(c, 4) for c in p] for p in tri] for tri in edge_closures(roof, ring) + step_closures(roof, ring)]
    avoid = []
    for station in PRODUCTION_VENTS_T:
        for k, seg in enumerate(roof.segments):
            if roof.segment(station, seg["ridge_offset"] + 0.8) == k:
                x, z = xz(station, seg["ridge_offset"] + 0.8)
                avoid.append([round(x, 3), round(z, 3)])
                break
    return plane, closures, avoid


def apply(cfg, ring):
    plane, closures, avoid = roof_data(ring)
    cfg["roof_plane"] = plane
    cfg["retained_roof_wall_closures"] = closures
    cfg["retained_roof_wall_closure_inference"] = ("The segment gables' boundary down to the unchanged 8.05 m family wall top along every run "
                                                   "(split at the cuts and ridges), and the exposed gable ends where neighbouring segments' "
                                                   "roofs differ at the steps; exact source XZ, no hidden openings inferred. Written by "
                                                   "tools/housing_1232_roof.py.")
    if "roof_vents" in cfg:
        cfg["roof_vents"]["avoid"] = avoid
    return cfg


def main():
    check = "--check" in sys.argv[1:]
    current = json.load(open(CONFIG))
    expected = apply(json.loads(json.dumps(current)), ring_from_chunk())
    if check:
        if expected != current:
            keys = [k for k in ("roof_plane", "retained_roof_wall_closures", "roof_vents") if expected.get(k) != current.get(k)]
            print("FAIL: %s differs from tools/housing_1232_roof.py in %s" % (os.path.relpath(CONFIG, ROOT), ", ".join(keys)))
            sys.exit(1)
        print("PASS: %s's roof data is what tools/housing_1232_roof.py writes" % os.path.relpath(CONFIG, ROOT))
        return
    json.dump(expected, open(CONFIG, "w"), indent=2)
    open(CONFIG, "a").write("\n")
    print("wrote roof_plane, %d closures and %d vents to avoid" % (len(expected["retained_roof_wall_closures"]), len(expected.get("roof_vents", {}).get("avoid", []))))


if __name__ == "__main__":
    main()
