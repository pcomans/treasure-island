#!/usr/bin/env bash
# Reference browsing; official CLI and its managed Chrome for Testing.
set -euo pipefail
export PATH="/usr/local/share/nvm/current/bin:${PATH}"
npm install --global agent-browser@0.38.2
agent-browser install --with-deps
