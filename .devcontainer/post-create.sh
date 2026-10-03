#!/usr/bin/env bash
# One-time setup for the Linux devbox. Safe to re-run.
set -euo pipefail
cd "$(dirname "$0")/.."
# The node feature only puts npm on PATH for login shells.
export PATH="/usr/local/share/nvm/current/bin:${PATH}"

curl -fsSL https://claude.ai/install.sh | bash

sudo apt-get update -qq
# weston: headless Wayland compositor that lets Godot render on the GPU (see tools/godot).
# xvfb is deliberately absent: Godot silently falls back to llvmpipe (CPU) under it.
sudo apt-get install -y -qq tmux unzip git-lfs weston \
  libgl1 libvulkan1 mesa-vulkan-drivers vulkan-tools mesa-utils

# Only evidence AVIs live in LFS; nothing at runtime needs them.
git lfs install --skip-smudge

npm install -g @openai/codex@0.160.0
# The named volume for ~/.codex (login survives rebuilds) is created root-owned.
sudo chown vscode:vscode /home/vscode/.codex

bash .devcontainer/setup-godot.sh
npm ci
