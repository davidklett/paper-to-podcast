# Prerequisites

Versions are what was installed on 2026-10-20 (macOS 15 / Darwin 24.6, Apple silicon).

| Tool | Version | Why | Install |
|---|---|---|---|
| Homebrew | - | installs the rest | https://brew.sh |
| Python | 3.13.7 | runtime for `notebooklm-py` | `brew install python` |
| uv | - | installs the CLI in its own environment | `brew install uv` |
| notebooklm-py | 0.8.5 | `notebooklm` CLI: notebooks, sources, audio | `uv tool install 'notebooklm-py[browser]'` |
| Playwright | via `[browser]` extra | drives the Google sign-in window | (comes with the extra) |
| Google Chrome | - | sign-in browser (bundled Chromium crashes on macOS 15+) | https://google.com/chrome |
| ffmpeg / ffprobe | - | convert NotebookLM's M4A to a real MP3, check duration | `brew install ffmpeg` |
| jq | - | read IDs from the CLI's `--json` output | `brew install jq` |
| pdftotext | - | optional: read a paper locally | `brew install poppler` |

Not needed: `gcloud`. The only official NotebookLM API is NotebookLM Enterprise on Google
Cloud, which needs a paid GCP project. `notebooklm-py` uses a normal Google account instead.

## About notebooklm-py

- Source: https://github.com/teng-lin/notebooklm-py (PyPI `notebooklm-py`).
- Unofficial. It signs in through a browser and stores Google session cookies in
  `~/.notebooklm/profiles/default/storage_state.json`. It can break when Google changes
  NotebookLM.
- Use a personal Google account; check company policy before using a work account.
- An alternative with the same features is `notebooklm-mcp-cli` (PyPI), which runs as an MCP
  server for Claude Code instead of a CLI.

## Useful commands

```sh
notebooklm list                          # notebooks
notebooklm source list -n <notebook>     # sources and their status
notebooklm artifact list -n <notebook>   # generated audio/video/reports
notebooklm artifact choices              # audio formats: deep-dive, brief, critique, debate
notebooklm language list                 # output languages (English is only "en")
notebooklm doctor                        # check sign-in and profile
```
