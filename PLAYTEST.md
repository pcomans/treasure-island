# Owner playtest

1. Download the newest Mac build, which GitHub Actions publishes on every push to `main`: https://github.com/pcomans/treasure-island/releases/latest/download/treasure-island-mac.zip (older builds and the curl and `gh` commands are in the [README](README.md#build-for-the-mac)).
2. Unzip it on the Mac.
3. The app is not notarized, so after a browser download macOS blocks the first launch: open System Settings → Privacy & Security and click "Open Anyway". A zip fetched with curl or `gh` opens directly.
4. Walk around. Things worth reporting:
   - buildings that don't look like the real ones, or look out of place next to their neighbours;
   - spots where you fall through, get stuck, or walk through a wall;
   - whether walking (4 m/s), running (`Shift`, 20 m/s), the jetpack (`Space`) and the fast drop (`C`) feel right;

Controls are in the [README](README.md#controls).
