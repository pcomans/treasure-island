#!/usr/bin/env bash
# Reference browsing; official CLI and its managed Chrome for Testing.
set -euo pipefail
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
npm install --global agent-browser@0.38.2
agent-browser install --with-deps
# WebKit, the engine of every iPhone browser, for measuring the web build in it
# (tools/web-memory/webkit-session.sh): Playwright's Linux build of WebKit main,
# whose GTK MiniBrowser runs headed on a private Weston (never xvfb). Its runtime
# libraries come from apt here, not from `playwright install --with-deps`, which
# would also install xvfb (deliberately absent, see post-create.sh).
npm install --global playwright@1.65.1
playwright install webkit
sudo apt-get install -y -qq --no-install-recommends libgtk-4-1 libgraphene-1.0-0 \
  libsecret-1-0 libsoup-3.0-0 libxslt1.1 libhyphen0 libharfbuzz-icu0 libenchant-2-2 \
  libavif16 libmanette-0.2-0 libgstreamer-gl1.0-0 libgstreamer-plugins-bad1.0-0 \
  gstreamer1.0-plugins-good
