// Drawing primitives for tools/building_plan.mjs, written out as SVG and as
// ImageMagick's MVG (which `magick` turns into the PNG), so both images come
// from the same pixel coordinates. Coordinates are pixels, y down.
//
//   { type: "polygon", rings, fill, fillOpacity, stroke, width, dash }
//   { type: "line", points, stroke, width, dash, opacity }
//   { type: "circle", centre, radius, fill, stroke, width }
//   { type: "text", at, text, size, anchor, fill, bold, rotate, halo }
//
// Any item may carry a `name`, written as its SVG class, and `data`, written as
// data-* attributes (a ruler label's metres and its tick's exact pixel).

const FONT_SVG = "DejaVu Sans, Verdana, Arial, sans-serif";
const FONT_MVG = "DejaVu Sans";

function number(value) {
  return Number(value.toFixed(2)).toString();
}

function escapeXml(text) {
  return String(text)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeMvg(text) {
  return String(text).replaceAll("\\", "\\\\").replaceAll("'", "\\'");
}

function ringPath(rings) {
  return rings
    .filter((ring) => ring.length >= 2)
    .map((ring) => `M ${ring.map((point) => `${number(point[0])} ${number(point[1])}`).join(" L ")} Z`)
    .join(" ");
}

function linePath(points) {
  return `M ${points.map((point) => `${number(point[0])} ${number(point[1])}`).join(" L ")}`;
}

function hexOpacity(color, opacity) {
  if (opacity == null || opacity >= 1) return color;
  const alpha = Math.round(Math.max(0, Math.min(1, opacity)) * 255).toString(16).padStart(2, "0");
  return `${color}${alpha}`;
}

// An item's `name` becomes its SVG class (the generated outline, a member, a
// ruler label), so a reader or a check can find it without knowing its colour.
export function toSvg(items, width, height, title) {
  const out = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    `<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}">`,
    `<title>${escapeXml(title)}</title>`,
    `<rect x="0" y="0" width="${width}" height="${height}" fill="#ffffff"/>`,
  ];
  for (const item of items) {
    const data = Object.entries(item.data ?? {}).map(([key, value]) => ` data-${key}="${escapeXml(value)}"`).join("");
    const name = `${item.name ? ` class="${escapeXml(item.name)}"` : ""}${data}`;
    if (item.type === "polygon") {
      const dash = item.dash ? ` stroke-dasharray="${item.dash.join(" ")}"` : "";
      const fill = item.fill ? `fill="${item.fill}" fill-opacity="${item.fillOpacity ?? 1}"` : 'fill="none"';
      const stroke = item.stroke ? ` stroke="${item.stroke}" stroke-width="${item.width ?? 1}" stroke-linejoin="round"${dash}` : "";
      out.push(`<path${name} d="${ringPath(item.rings)}" fill-rule="evenodd" ${fill}${stroke}/>`);
    } else if (item.type === "line") {
      const dash = item.dash ? ` stroke-dasharray="${item.dash.join(" ")}"` : "";
      const opacity = item.opacity != null ? ` stroke-opacity="${item.opacity}"` : "";
      out.push(`<path${name} d="${linePath(item.points)}" fill="none" stroke="${item.stroke}" stroke-width="${item.width ?? 1}" stroke-linejoin="round" stroke-linecap="${item.cap ?? "butt"}"${dash}${opacity}/>`);
    } else if (item.type === "circle") {
      const stroke = item.stroke ? ` stroke="${item.stroke}" stroke-width="${item.width ?? 1}"` : "";
      out.push(`<circle${name} cx="${number(item.centre[0])}" cy="${number(item.centre[1])}" r="${number(item.radius)}" fill="${item.fill ?? "none"}"${stroke}/>`);
    } else if (item.type === "text") {
      const anchor = item.anchor ?? "start";
      const transform = item.rotate ? ` transform="rotate(${number(item.rotate)} ${number(item.at[0])} ${number(item.at[1])})"` : "";
      const weight = item.bold ? ' font-weight="bold"' : "";
      const halo = item.halo === false ? "" : ' stroke="#ffffff" stroke-width="3" stroke-linejoin="round" paint-order="stroke"';
      out.push(`<text${name} x="${number(item.at[0])}" y="${number(item.at[1])}" font-family="${FONT_SVG}" font-size="${item.size ?? 12}" text-anchor="${anchor}" fill="${item.fill ?? "#222222"}"${weight}${halo}${transform}>${escapeXml(item.text)}</text>`);
    }
  }
  out.push("</svg>", "");
  return out.join("\n");
}

export function toMvg(items, width, height) {
  const out = [`viewbox 0 0 ${width} ${height}`, "fill '#ffffff'", `rectangle 0,0 ${width},${height}`];
  for (const item of items) {
    out.push("push graphic-context");
    if (item.type === "polygon") {
      out.push("fill-rule evenodd");
      out.push(item.fill ? `fill '${hexOpacity(item.fill, item.fillOpacity)}'` : "fill none");
      if (item.stroke) {
        out.push(`stroke '${item.stroke}'`, `stroke-width ${item.width ?? 1}`, "stroke-linejoin round");
        if (item.dash) out.push(`stroke-dasharray ${item.dash.join(" ")}`);
      } else {
        out.push("stroke none");
      }
      out.push(`path '${ringPath(item.rings)}'`);
    } else if (item.type === "line") {
      out.push("fill none", `stroke '${hexOpacity(item.stroke, item.opacity)}'`, `stroke-width ${item.width ?? 1}`, "stroke-linejoin round", `stroke-linecap ${item.cap ?? "butt"}`);
      if (item.dash) out.push(`stroke-dasharray ${item.dash.join(" ")}`);
      out.push(`path '${linePath(item.points)}'`);
    } else if (item.type === "circle") {
      out.push(`fill '${item.fill ?? "none"}'`);
      out.push(item.stroke ? `stroke '${item.stroke}'` : "stroke none", `stroke-width ${item.width ?? 1}`);
      out.push(`circle ${number(item.centre[0])},${number(item.centre[1])} ${number(item.centre[0] + item.radius)},${number(item.centre[1])}`);
    } else if (item.type === "text") {
      out.push(`font-family '${FONT_MVG}'`, `font-size ${item.size ?? 12}`, `text-anchor ${item.anchor ?? "start"}`);
      if (item.bold) out.push("font-weight bold");
      if (item.rotate) out.push(`translate ${number(item.at[0])},${number(item.at[1])}`, `rotate ${number(item.rotate)}`);
      const at = item.rotate ? "0,0" : `${number(item.at[0])},${number(item.at[1])}`;
      if (item.halo !== false) {
        out.push("stroke '#ffffff'", "stroke-width 3", "stroke-linejoin round", "fill '#ffffff'", `text ${at} '${escapeMvg(item.text)}'`);
      }
      out.push("stroke none", `fill '${item.fill ?? "#222222"}'`, `text ${at} '${escapeMvg(item.text)}'`);
    }
    out.push("pop graphic-context");
  }
  return `${out.join("\n")}\n`;
}

// Liang-Barsky: the part of segment a-b inside the box, or null.
function clipSegment(a, b, box) {
  let t0 = 0;
  let t1 = 1;
  const dx = b[0] - a[0];
  const dy = b[1] - a[1];
  for (const [p, q] of [[-dx, a[0] - box.minX], [dx, box.maxX - a[0]], [-dy, a[1] - box.minY], [dy, box.maxY - a[1]]]) {
    if (p === 0) {
      if (q < 0) return null;
    } else {
      const t = q / p;
      if (p < 0) t0 = Math.max(t0, t);
      else t1 = Math.min(t1, t);
    }
  }
  if (t0 > t1) return null;
  return [[a[0] + dx * t0, a[1] + dy * t0], [a[0] + dx * t1, a[1] + dy * t1]];
}

// The pieces of a polyline inside the box.
export function clipLine(points, box) {
  const pieces = [];
  let current = null;
  for (let index = 1; index < points.length; index += 1) {
    const clipped = clipSegment(points[index - 1], points[index], box);
    if (clipped == null) {
      current = null;
      continue;
    }
    const startsWhereLastEnded = current &&
      Math.abs(current.at(-1)[0] - clipped[0][0]) < 1e-9 && Math.abs(current.at(-1)[1] - clipped[0][1]) < 1e-9;
    if (startsWhereLastEnded) {
      current.push(clipped[1]);
    } else {
      current = [clipped[0], clipped[1]];
      pieces.push(current);
    }
  }
  return pieces;
}

// Sutherland-Hodgman: a ring clipped to the box (a filled area stays filled).
export function clipRing(ring, box) {
  let output = ring;
  const edges = [
    [(p) => p[0] >= box.minX, (a, b) => [box.minX, a[1] + ((b[1] - a[1]) * (box.minX - a[0])) / (b[0] - a[0])]],
    [(p) => p[0] <= box.maxX, (a, b) => [box.maxX, a[1] + ((b[1] - a[1]) * (box.maxX - a[0])) / (b[0] - a[0])]],
    [(p) => p[1] >= box.minY, (a, b) => [a[0] + ((b[0] - a[0]) * (box.minY - a[1])) / (b[1] - a[1]), box.minY]],
    [(p) => p[1] <= box.maxY, (a, b) => [a[0] + ((b[0] - a[0]) * (box.maxY - a[1])) / (b[1] - a[1]), box.maxY]],
  ];
  for (const [inside, cut] of edges) {
    const input = output;
    output = [];
    for (let index = 0; index < input.length; index += 1) {
      const current = input[index];
      const previous = input[(index - 1 + input.length) % input.length];
      if (inside(current)) {
        if (!inside(previous)) output.push(cut(previous, current));
        output.push(current);
      } else if (inside(previous)) {
        output.push(cut(previous, current));
      }
    }
    if (output.length === 0) return [];
  }
  return output;
}

// A rough width of text in pixels (DejaVu Sans averages about 0.6 em).
export function textWidth(text, size = 12) {
  return String(text).length * size * 0.6;
}

// Splits text into lines of at most `chars` characters at spaces.
export function wrapText(text, chars) {
  const lines = [];
  let line = "";
  for (const word of String(text).split(" ")) {
    if (line && (line.length + 1 + word.length) > chars) {
      lines.push(line);
      line = word;
    } else {
      line = line ? `${line} ${word}` : word;
    }
  }
  if (line) lines.push(line);
  return lines;
}
