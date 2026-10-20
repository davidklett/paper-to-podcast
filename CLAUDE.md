# paper-to-podcast

Turn a research paper into a long, beginner-friendly audio walkthrough with NotebookLM: upload
the PDF, add background reading, generate a "deep dive" audio overview with a teaching prompt,
and download it as an MP3 to listen to on a walk or drive.

**Status:** Workflow works end to end (2026-10-20): "Attention Is All You Need" produced a
51-minute overview. Next: British/Australian English voices, which NotebookLM does not offer
(see `docs/accents.md`).

## Layout
- `scripts/setup.sh`: install the `notebooklm` CLI and sign in (one time)
- `scripts/paper-to-audio.sh`: the whole workflow for one paper
- `scripts/accent-test.py`: tries regional English codes (`en_GB`, `en_AU`) for audio voices
- `prompts/student-walkthrough.txt`: the audio prompt
- `sources/<paper>.txt`: background-reading URLs per paper, one per line
- `docs/prerequisites.md`: tools, versions, and why each is needed
- `docs/session-2026-10-20.md`: how this was first set up, including the problems hit
- `docs/accents.md`: findings on voice/accent control

## Environment
- `notebooklm` CLI from `notebooklm-py` (unofficial; drives NotebookLM through a browser
  sign-in). Installed with `uv tool`. Credentials live in
  `~/.notebooklm/profiles/default/storage_state.json`; never commit them.
- Account, notebook IDs and file locations are in the git-ignored `LOCAL.md`, if present.
- Fork of the CLI for accent work: `~/code/notebooklm-py` (github.com/davidklett/notebooklm-py,
  `upstream` = teng-lin/notebooklm-py).

## Gotchas
- NotebookLM's "MP3" download is really AAC in an MP4 container. `paper-to-audio.sh` saves it
  as `.m4a` and converts it with ffmpeg.
- In zsh, quote URLs that contain `?` (YouTube links), or the shell treats them as globs.
- On macOS 15+, sign in with `--browser chrome`; the bundled Chromium can crash. Leave the
  window open until NotebookLM has loaded; closing it early aborts the login.
- The `!` shell prefix in Claude Code only works as the first character of the message.
