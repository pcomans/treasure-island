// Painted sports pitches: a street-detail zone's ground.pitches
// (tools/config/street-detail-zones.json). A pitch is a frame on the ground: its
// centre spot centre_xz (world x, z), its length along axis_xz and its width across,
// with the markings of its layout. The street ground paints them in white street
// paint (tools/lib/street-ground-generation.mjs); a furniture rule of pattern
// centre_spot stands an item on a pitch's centre spot (the match ball) and one of
// pattern goal_lines a goal on the middle of each of its goal lines
// (tools/lib/street-furniture-generation.mjs). The soccer layouts follow the Laws
// of the Game (the small-sided one is read from the aerial), the gaa layout the
// GAA's pitch markings and the rugby_union layout World Rugby's Law 1. All are
// production inference fitted to the dated imagery, not survey data.

import { invariant } from "./world-contract.mjs";

export const PITCH_LAYOUTS = Object.freeze({
  // IFAB Laws of the Game, Law 1: a 9.15 m centre circle and penalty arcs, a
  // 16.5 by 40.32 m penalty area, a 5.5 by 18.32 m goal area, the penalty mark
  // 11 m out and 1 m corner arcs. Lines at most 12 cm wide.
  full_size: Object.freeze({ sport: "soccer", line_m: 0.12, circle_m: 9.15, spot_m: 0.11, penalty_area: Object.freeze([16.5, 40.32]), goal_area: Object.freeze([5.5, 18.32]), mark_m: 11, arc_m: 9.15, corner_m: 1 }),
  // The small pitches marked across the turf's north-west strip: a 4.3 m centre
  // circle (fitted to the aerial) and a small box at each end.
  small_sided: Object.freeze({ sport: "soccer", line_m: 0.1, circle_m: 4.3, spot_m: 0.1, penalty_area: Object.freeze([5, 8]), goal_area: null, mark_m: null, arc_m: null, corner_m: null }),
  // Gaelic football and hurling (the GAA's pitch markings, as SF GAA draws them for
  // Pairc na nGael): 130-145 by 80-90 m; lines across the pitch 13, 20, 45 and 65 m
  // from each end line; a 10 m line at the centre; the 4.5 by 14 m small and 13 by
  // 19 m large rectangles; the penalty spot 11 m out; a 13 m arc on the middle of
  // each 20 m line and a 40 m arc round the middle of each end line, both beyond the
  // 20 m line. Lines about 10 cm wide.
  gaa: Object.freeze({ sport: "gaa", line_m: 0.1, spot_m: 0.11, lines_m: Object.freeze([13, 20, 45, 65]), small: Object.freeze([4.5, 14]), large: Object.freeze([13, 19]), mark_m: 11, arc_line_m: 20, arc_m: 13, wide_arc_m: 40, centre_line_m: 10, length_m: Object.freeze([120, 145]), width_m: Object.freeze([75, 90]) }),
  // Rugby union (World Rugby Law 1): the field of play between the try lines,
  // in-goal areas behind them to the dead-ball lines, solid 22 m and halfway lines,
  // broken 10 m lines either side of halfway and 5 m lines in front of each try
  // line, and broken lines 5 and 15 m in from each touchline; a short mark on the
  // centre. The in-goal depth and the dashes are read from the aerial.
  rugby_union: Object.freeze({ sport: "rugby", line_m: 0.1, in_goal_m: 6, line_22_m: 22, dash_m: 1, gap_m: 2, length_m: Object.freeze([90, 100]), width_m: Object.freeze([60, 70]) }),
});
// The goal props a goal_lines rule may stand on each sport's pitches
// (game/scripts/world/street_furniture_kit.gd).
export const PITCH_GOAL_PROPS = Object.freeze({ soccer: "goal_soccer", gaa: "goal_gaa", rugby: "goal_rugby" });
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
    if (layout.sport === "soccer") {
      // Room for the boxes at both ends and the centre circle.
      const ends = 2 * Math.max(layout.penalty_area[0], layout.mark_m === null ? 0 : layout.mark_m + layout.arc_m) + 2 * layout.circle_m;
      invariant(isFiniteNumber(pitch.length_m) && pitch.length_m > ends && pitch.length_m <= 120, `${pitchLabel} length_m must fit its markings (over ${ends} m, at most 120 m)`);
      invariant(isFiniteNumber(pitch.width_m) && pitch.width_m > Math.max(layout.penalty_area[1], 2 * layout.circle_m) && pitch.width_m < pitch.length_m, `${pitchLabel} width_m must fit its boxes and circle and be under its length`);
    } else {
      // The sport's own range of sizes (its lines and arcs fit any pitch in it).
      const [shortest, longest] = layout.length_m;
      const [narrowest, widest] = layout.width_m;
      invariant(isFiniteNumber(pitch.length_m) && pitch.length_m >= shortest && pitch.length_m <= longest, `${pitchLabel} length_m must be ${shortest}..${longest} m for ${pitch.layout}`);
      invariant(isFiniteNumber(pitch.width_m) && pitch.width_m >= narrowest && pitch.width_m <= widest && pitch.width_m < pitch.length_m, `${pitchLabel} width_m must be ${narrowest}..${widest} m for ${pitch.layout} and under its length`);
    }
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

// The middle of each goal line, where a goal_lines rule stands a goal: {s, end},
// end -1 or +1 along the length (the goal faces the other end). A soccer pitch's
// goal lines, a GAA pitch's end lines and a rugby pitch's try lines all lie at
// half its length_m from the centre.
export function pitchGoalEnds(pitch) {
  return [-1, 1].map((end) => ({ end, s: end * pitch.length_m / 2 }));
}

// The markings in the pitch's frame, each one of:
//   {line: [[s0, t0], [s1, t1]]}            a straight line, centred on that segment;
//   {ring: [s, t], radius}                  a full circle;
//   {arc: [s, t], radius, from, to}         part of one, from angle from to angle to (radians
//                                           from +s toward +t, either way round);
//   {disc: [s, t], radius}                  a painted spot.
export function pitchMarkings(pitch) {
  const layout = PITCH_LAYOUTS[pitch.layout];
  if (layout.sport === "gaa") return gaaMarkings(pitch, layout);
  if (layout.sport === "rugby") return rugbyMarkings(pitch, layout);
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

// A line across the pitch at s, from t0 to t1.
const across = (s, t0, t1) => ({ line: [[s, t0], [s, t1]] });
// A line along the pitch at t, from s0 to s1.
const along = (t, s0, s1) => ({ line: [[s0, t], [s1, t]] });

// A rectangle in front of an end line: depth along the pitch, width across it.
function endBox(marks, halfLength, end, depth, width) {
  const front = end * (halfLength - depth);
  const half = width / 2;
  marks.push(along(-half, end * halfLength, front), along(half, end * halfLength, front), across(front, -half, half));
}

function gaaMarkings(pitch, layout) {
  const halfLength = pitch.length_m / 2;
  const halfWidth = pitch.width_m / 2;
  const marks = [
    along(-halfWidth, -halfLength, halfLength),
    along(halfWidth, -halfLength, halfLength),
    across(-halfLength, -halfWidth, halfWidth),
    across(halfLength, -halfWidth, halfWidth),
    across(0, -layout.centre_line_m / 2, layout.centre_line_m / 2),
  ];
  for (const end of [-1, 1]) {
    // Toward the centre from this end, as an angle from +s.
    const toward = end > 0 ? Math.PI : 0;
    for (const distance of layout.lines_m) marks.push(across(end * (halfLength - distance), -halfWidth, halfWidth));
    endBox(marks, halfLength, end, ...layout.small);
    endBox(marks, halfLength, end, ...layout.large);
    marks.push({ disc: [end * (halfLength - layout.mark_m), 0], radius: layout.spot_m });
    // The 13 m arc: the half circle on the middle of the 20 m line, toward the centre.
    marks.push({ arc: [end * (halfLength - layout.arc_line_m), 0], radius: layout.arc_m, from: toward - Math.PI / 2, to: toward + Math.PI / 2 });
    // The 40 m arc round the middle of the end line, beyond the 20 m line.
    const spread = Math.acos(layout.arc_line_m / layout.wide_arc_m);
    marks.push({ arc: [end * halfLength, 0], radius: layout.wide_arc_m, from: toward - spread, to: toward + spread });
  }
  return marks;
}

// Dashes of a broken line from a to b (pitch frame), dash_m painted then gap_m bare.
function dashes(layout, a, b) {
  const total = Math.hypot(b[0] - a[0], b[1] - a[1]);
  const marks = [];
  const step = layout.dash_m + layout.gap_m;
  const count = Math.floor((total + layout.gap_m) / step);
  // Centred on the line, so both ends keep the same gap.
  const start = (total - (count * step - layout.gap_m)) / 2;
  for (let index = 0; index < count; index += 1) {
    const from = (start + index * step) / total;
    const to = (start + index * step + layout.dash_m) / total;
    marks.push({ line: [[a[0] + (b[0] - a[0]) * from, a[1] + (b[1] - a[1]) * from], [a[0] + (b[0] - a[0]) * to, a[1] + (b[1] - a[1]) * to]] });
  }
  return marks;
}

function rugbyMarkings(pitch, layout) {
  const halfLength = pitch.length_m / 2;
  const halfWidth = pitch.width_m / 2;
  const deadBall = halfLength + layout.in_goal_m;
  const marks = [
    along(-halfWidth, -deadBall, deadBall),
    along(halfWidth, -deadBall, deadBall),
    across(0, -halfWidth, halfWidth),
    // The centre mark: a short line along the pitch through the centre.
    along(0, -0.5, 0.5),
  ];
  for (const end of [-1, 1]) {
    marks.push(across(end * deadBall, -halfWidth, halfWidth), across(end * halfLength, -halfWidth, halfWidth), across(end * (halfLength - layout.line_22_m), -halfWidth, halfWidth));
    marks.push(...dashes(layout, [end * 10, -halfWidth], [end * 10, halfWidth]));
    marks.push(...dashes(layout, [end * (halfLength - 5), -halfWidth], [end * (halfLength - 5), halfWidth]));
  }
  for (const side of [-1, 1]) {
    for (const inset of [5, 15]) marks.push(...dashes(layout, [-halfLength, side * (halfWidth - inset)], [halfLength, side * (halfWidth - inset)]));
  }
  return marks;
}
