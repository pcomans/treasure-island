// Painted sports pitches: a street-detail zone's ground.pitches
// (tools/config/street-detail-zones.json). A pitch is a frame on the ground: its
// centre spot centre_xz (world x, z), its length along axis_xz and its width across,
// with the markings of its layout. The street ground paints them in white street
// paint (tools/lib/street-ground-generation.mjs), and a furniture rule of pattern
// centre_spot stands an item on a pitch's centre spot (the match ball,
// tools/lib/street-furniture-generation.mjs). The full-size layout follows the Laws
// of the Game; the small-sided one is read from the aerial. Both are production
// inference fitted to the dated imagery, not survey data.

import { invariant } from "./world-contract.mjs";

export const PITCH_LAYOUTS = Object.freeze({
  // IFAB Laws of the Game, Law 1: a 9.15 m centre circle and penalty arcs, a
  // 16.5 by 40.32 m penalty area, a 5.5 by 18.32 m goal area, the penalty mark
  // 11 m out and 1 m corner arcs. Lines at most 12 cm wide.
  full_size: Object.freeze({ line_m: 0.12, circle_m: 9.15, spot_m: 0.11, penalty_area: Object.freeze([16.5, 40.32]), goal_area: Object.freeze([5.5, 18.32]), mark_m: 11, arc_m: 9.15, corner_m: 1 }),
  // The small pitches marked across the turf's north-west strip: a 4.3 m centre
  // circle (fitted to the aerial) and a small box at each end.
  small_sided: Object.freeze({ line_m: 0.1, circle_m: 4.3, spot_m: 0.1, penalty_area: Object.freeze([5, 8]), goal_area: null, mark_m: null, arc_m: null, corner_m: null }),
});
const PITCH_FIELDS = ["axis_xz", "centre_xz", "evidence", "id", "layout", "length_m", "reason", "width_m"];
const SAFE_ID = /^[a-z][a-z0-9_]*$/u;

function isFiniteNumber(value) {
  return typeof value === "number" && Number.isFinite(value);
}

export function validatePitches(pitches, label) {
  invariant(Array.isArray(pitches) && pitches.length > 0, `${label} pitches must be a nonempty list`);
  const ids = new Set();
  for (const pitch of pitches) {
    const pitchLabel = `${label} pitch ${pitch?.id}`;
    invariant(JSON.stringify(Object.keys(pitch ?? {}).sort()) === JSON.stringify(PITCH_FIELDS), `${pitchLabel} must have exactly ${PITCH_FIELDS.join(", ")}`);
    invariant(typeof pitch.id === "string" && SAFE_ID.test(pitch.id) && !ids.has(pitch.id), `${pitchLabel} needs a unique lower_snake id`);
    ids.add(pitch.id);
    const layout = PITCH_LAYOUTS[pitch.layout];
    invariant(layout !== undefined, `${pitchLabel} layout must be one of ${Object.keys(PITCH_LAYOUTS).join(", ")}`);
    for (const field of ["centre_xz", "axis_xz"]) {
      invariant(Array.isArray(pitch[field]) && pitch[field].length === 2 && pitch[field].every(isFiniteNumber), `${pitchLabel} ${field} must be [x, z]`);
    }
    invariant(Math.hypot(...pitch.axis_xz) > 1e-6, `${pitchLabel} axis_xz must not be zero`);
    // Room for the boxes at both ends and the centre circle.
    const ends = 2 * Math.max(layout.penalty_area[0], layout.mark_m === null ? 0 : layout.mark_m + layout.arc_m) + 2 * layout.circle_m;
    invariant(isFiniteNumber(pitch.length_m) && pitch.length_m > ends && pitch.length_m <= 120, `${pitchLabel} length_m must fit its markings (over ${ends} m, at most 120 m)`);
    invariant(isFiniteNumber(pitch.width_m) && pitch.width_m > Math.max(layout.penalty_area[1], 2 * layout.circle_m) && pitch.width_m < pitch.length_m, `${pitchLabel} width_m must fit its boxes and circle and be under its length`);
    for (const field of ["reason", "evidence"]) invariant(typeof pitch[field] === "string" && pitch[field].trim() !== "", `${pitchLabel} needs ${field}`);
  }
}

// The unit vector along the pitch's length, world x, z.
export function pitchAxis(pitch) {
  const size = Math.hypot(...pitch.axis_xz);
  return [pitch.axis_xz[0] / size, pitch.axis_xz[1] / size];
}

// A point of the pitch's own frame in world x, z: s metres along its length and t
// across it (the axis turned a right angle toward +z), from the centre spot.
export function pitchPoint(pitch, s, t) {
  const [ax, az] = pitchAxis(pitch);
  return [pitch.centre_xz[0] + ax * s - az * t, pitch.centre_xz[1] + az * s + ax * t];
}

// The markings in the pitch's frame, each one of:
//   {line: [[s0, t0], [s1, t1]]}            a straight line, centred on that segment;
//   {ring: [s, t], radius}                  a full circle;
//   {arc: [s, t], radius, from, to}         part of one, from angle from to angle to (radians
//                                           from +s toward +t, either way round);
//   {disc: [s, t], radius}                  a painted spot.
export function pitchMarkings(pitch) {
  const layout = PITCH_LAYOUTS[pitch.layout];
  const halfLength = pitch.length_m / 2;
  const halfWidth = pitch.width_m / 2;
  const marks = [
    { line: [[-halfLength, -halfWidth], [halfLength, -halfWidth]] },
    { line: [[-halfLength, halfWidth], [halfLength, halfWidth]] },
    { line: [[-halfLength, -halfWidth], [-halfLength, halfWidth]] },
    { line: [[halfLength, -halfWidth], [halfLength, halfWidth]] },
    { line: [[0, -halfWidth], [0, halfWidth]] },
    { ring: [0, 0], radius: layout.circle_m },
    { disc: [0, 0], radius: layout.spot_m },
  ];
  const box = (end, depth, width) => {
    const front = end * (halfLength - depth);
    const half = width / 2;
    marks.push({ line: [[end * halfLength, -half], [front, -half]] }, { line: [[end * halfLength, half], [front, half]] }, { line: [[front, -half], [front, half]] });
  };
  for (const end of [-1, 1]) {
    box(end, ...layout.penalty_area);
    if (layout.goal_area !== null) box(end, ...layout.goal_area);
    if (layout.mark_m !== null) {
      const mark = end * (halfLength - layout.mark_m);
      marks.push({ disc: [mark, 0], radius: layout.spot_m });
      // The penalty arc: the part of the circle round the mark beyond the area's front.
      const spread = Math.acos((layout.penalty_area[0] - layout.mark_m) / layout.arc_m);
      const toward = end > 0 ? Math.PI : 0;
      marks.push({ arc: [mark, 0], radius: layout.arc_m, from: toward - spread, to: toward + spread });
    }
    if (layout.corner_m !== null) {
      for (const side of [-1, 1]) {
        // A quarter circle in the pitch's corner: from inward along the touchline
        // (-end along s) a right angle round to inward along the goal line (-side along t).
        const inward = end > 0 ? Math.PI : 0;
        marks.push({ arc: [end * halfLength, side * halfWidth], radius: layout.corner_m, from: inward, to: inward + end * side * Math.PI / 2 });
      }
    }
  }
  return marks;
}
