#!/usr/bin/env bash
# One-time setup: install the notebooklm CLI and sign in to Google.
# Needs Homebrew, uv, ffmpeg and Google Chrome (see docs/prerequisites.md).
set -euo pipefail

for tool in uv ffmpeg jq; do
  command -v "$tool" >/dev/null || { echo "Missing $tool. Install it with: brew install $tool" >&2; exit 1; }
done
[[ -d "/Applications/Google Chrome.app" ]] || { echo "Google Chrome is required for sign-in." >&2; exit 1; }

# The [browser] extra pulls in Playwright, which the login command drives.
uv tool install --upgrade 'notebooklm-py[browser]'
notebooklm --profile default doctor --fix

if notebooklm list >/dev/null 2>&1; then
  echo "Already signed in."
  exit 0
fi

# Bundled Chromium can crash on macOS 15+, so use the system Chrome.
# Leave the window open until NotebookLM has loaded; it closes by itself.
notebooklm login --browser chrome
notebooklm list >/dev/null && echo "Signed in."
