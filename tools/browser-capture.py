#!/usr/bin/env python3
"""Guard Street View captures; optionally reopen one actual resolved panorama."""
import base64
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time
from urllib.parse import urlparse


def command(*args, script=None):
    result = subprocess.run(
        ["agent-browser", "--json", *args], input=script, text=True,
        capture_output=True, timeout=15, check=True,
    )
    response = json.loads(result.stdout)
    if not response.get("success"):
        raise RuntimeError(response.get("error", "browser command failed"))
    return response["data"]


def main():
    args = sys.argv[1:]
    recover = len(args) == 3 and args[-1] == "--recover-resolved"
    if recover:
        args = args[:-1]
    if len(args) != 2 or not re.fullmatch(r"[a-zA-Z0-9_-]+", args[0]):
        raise ValueError("usage: tools/browser capture SESSION /absolute/private/reference.png [--recover-resolved]")
    session, filename = args
    output = Path(filename)
    project = Path(__file__).resolve().parent.parent
    if not output.is_absolute() or output.suffix.lower() != ".png":
        raise ValueError("capture requires an absolute private PNG path")
    output = output.resolve()
    if output.is_relative_to(project):
        raise ValueError("reference photographs must remain outside the project")
    ancestor = output.parent
    while not ancestor.exists():
        ancestor = ancestor.parent
    repository = subprocess.run(
        ["git", "-C", str(ancestor), "rev-parse", "--show-toplevel"],
        capture_output=True, text=True, timeout=5,
    )
    if repository.returncode == 0:
        raise ValueError("reference photographs must remain outside every Git checkout")
    failed = output.with_name(output.stem + ".failed.png")
    recovery_failed = output.with_name(output.stem + ".recovery.failed.png")
    if any(p.exists() or p.is_symlink() for p in (output, failed, recovery_failed)):
        raise ValueError("use fresh output paths; retained captures are never overwritten")
    if not os.environ.get("XDG_RUNTIME_DIR") or session not in command("session", "list")["sessions"]:
        raise ValueError("use the printed runtime prefix of an already live tools/browser session")
    output.parent.mkdir(parents=True, exist_ok=True)

    def evaluate(script):
        return command("--session", session, "eval", "--stdin", script=script)["result"]

    deadline = time.monotonic() + 30
    reason = "unresolved viewer readiness"
    state = {}
    previous = None
    recovered = False
    while True:
        state = evaluate("({url:location.href, text:document.body.innerText, ready:document.readyState})")
        text = state["text"]
        url = urlparse(state["url"])
        if url.scheme != "https" or url.hostname != "www.google.com" or not url.path.startswith("/maps"):
            reason = "not a supported Google Maps Street View page"
            break
        if re.search(r"captcha|unusual traffic|verify (?:that )?you are human", text, re.I):
            reason = "access challenge; stop without workaround"
            break
        no_imagery = "No Street View imagery available here" in text
        date = re.search(r"Image capture:\s*([A-Za-z]+\s+\d{4})", text)
        panorama = re.search(r"!1s([^!/?&]+)", state["url"])
        current = (state["url"], date.group(1) if date else None)
        if state["ready"] == "complete" and date and panorama and current == previous:
            command("--session", session, "screenshot", str(failed))
            encoded = base64.b64encode(failed.read_bytes()).decode("ascii")
            # Decode the actual screenshot using the existing browser, not the
            # WebGL canvas (which may be cleared/tainted). Do not modify the page.
            pixels = evaluate("""(async () => {
                const image = new Image();
                image.src = 'data:image/png;base64,""" + encoded + """';
                await image.decode();
                const canvas = document.createElement('canvas');
                canvas.width = image.width; canvas.height = image.height;
                const ctx = canvas.getContext('2d'); ctx.drawImage(image, 0, 0);
                const p = ctx.getImageData(0, 0, canvas.width, canvas.height).data;
                let lit = 0, total = 0, low = 255, high = 0;
                // Central/lower viewer excludes the search/date panels and logo.
                for (let y = Math.floor(canvas.height*.3); y < canvas.height*.8; y += 8)
                  for (let x = Math.floor(canvas.width*.3); x < canvas.width*.8; x += 8) {
                    const i = (y*canvas.width+x)*4;
                    const v = Math.max(p[i],p[i+1],p[i+2]);
                    total++; if (v > 20) lit++; low = Math.min(low,v); high = Math.max(high,v);
                  }
                return {nonblack:lit/total, range:high-low};
            })()""")
            if pixels["nonblack"] > .1 and pixels["range"] > 15:
                # Guard against navigation during the screenshot/readback.
                if evaluate("location.href") != state["url"]:
                    reason = "navigation changed during capture; unresolved"
                    break
                failed.rename(output)
                print(f"CAPTURE READY (human target/side inspection still required): {output}")
                if no_imagery:
                    print("Conflicting Maps no-imagery text: inspect the saved dated panorama; do not infer absence.")
                print(f"Image capture: {date.group(1)}\nResolved URL: {state['url']}")
                return 0
            reason = "dated panorama UI present but screenshot viewer remains black/flat"
        expired = time.monotonic() >= deadline
        if expired or failed.exists():
            if no_imagery and not failed.exists():
                reason = "Maps no-imagery text without verified rendered panorama; availability unresolved"
            # Opt-in only: preserve the failed frame, then reopen the exact URL
            # Maps resolved. Never invent a pano ID, change pose, or retry twice.
            if recover and not recovered and panorama and re.match(r"/maps/@-?\d", url.path):
                if not failed.exists():
                    command("--session", session, "screenshot", str(failed))
                if evaluate("location.href") != state["url"]:
                    reason = "navigation changed before recovery; unresolved"
                    break
                print(f"Retained pre-recovery attempt: {failed}")
                print(f"Reopening actual resolved panorama once: {state['url']}")
                command("--session", session, "open", state["url"])
                recovered = True
                failed = recovery_failed
                deadline = time.monotonic() + 30
                previous = None
                reason = "unresolved viewer readiness after resolved-panorama recovery"
                continue
            break
        previous = current
        time.sleep(1)
    if not failed.exists():
        command("--session", session, "screenshot", str(failed))
    print(f"CAPTURE HOLD: {reason}\nFailed attempt: {failed}\nResolved URL: {state.get('url', '')}")
    return 1


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (ValueError, RuntimeError, KeyError, subprocess.SubprocessError) as error:
        print(f"CAPTURE HOLD: {error}", file=sys.stderr)
        sys.exit(1)
