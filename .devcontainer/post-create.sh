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
# python3-yaml: required by the existing skill-creator quick_validate.py.
sudo apt-get install -y -qq tmux unzip file git-lfs weston osmium-tool python3-yaml \
  libgl1 libvulkan1 mesa-vulkan-drivers vulkan-tools mesa-utils

# Only evidence AVIs live in LFS; nothing at runtime needs them.
git lfs install --skip-smudge

# Agents commit as the project's bot account.
git config user.name pcomans-bot
git config user.email philipp.comans.agent@gmail.com

# Each workspace logs in to Codex on its own (codex login --device-auth).
curl -fsSL https://chatgpt.com/codex/install.sh | sh
# Codex's own (bubblewrap) sandbox can't start in this container: it needs
# CAP_SYS_ADMIN and SELinux container_t blocks it. The container is the
# sandbox, so Codex runs without its own. The key must sit above any [table].
mkdir -p ~/.codex
config=~/.codex/config.toml
if ! grep -q '^sandbox_mode' "${config}" 2>/dev/null; then
  if grep -q '^\[' "${config}" 2>/dev/null; then
    sed -i '0,/^\[/s//sandbox_mode = "danger-full-access"\n[/' "${config}"
  else
    printf 'sandbox_mode = "danger-full-access"\n' >> "${config}"
  fi
fi

# /opt/godot is a named volume, so Godot survives rebuilds and is shared by
# every checkout and worktree. It is created root-owned.
sudo chown vscode:vscode /opt/godot
bash .devcontainer/setup-godot.sh
npm ci
bash .devcontainer/setup-browser.sh
