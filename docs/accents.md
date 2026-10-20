# British / Australian English voices

Goal: audio overviews with British or Australian English hosts instead of NotebookLM's two
American voices.

## What NotebookLM offers (2026-10-20)

- No voice, speaker or accent setting in the web app, the CLI, or either protocol
  `notebooklm-py` speaks (web `batchexecute` and the Android app's protobuf).
- The only voice-adjacent input is the output language. The CLI's catalog
  (`src/notebooklm/_app/language.py`, 81 codes) has regional variants for other languages
  (`es_419`, `es_MX`, `pt_BR`, `fr_CA`, `zh_Hans`/`zh_Hant`) but only `en` for English.

## Findings from the fork

Fork: https://github.com/davidklett/notebooklm-py (clone at `~/code/notebooklm-py`, upstream
remote `teng-lin/notebooklm-py`, base commit `4d551830`, v0.8.5).

- **The language code is sent as-is.** Audio requests are built in
  `src/notebooklm/_web/params/creation.py`:
  `[None, [instructions, length_code, None, source_ids, language, None, format_code]]`.
  Positions 2 and 5 are always `None` and undocumented.
- **Only the CLI checks the code.** `cli/generate_cmd.py:resolve_language` rejects codes that
  are not in the catalog. The library checks only that it's non-empty, so the Python API can
  send `en_GB` or `en_AU` with no code change.
- Nothing in the repo, its docs or its changelog mentions voices or accents.

## Experiment

`scripts/accent-test.py` creates an "Accent test" notebook with the paper and generates one
short "brief" overview per code (default `en_GB`, `en_AU`), then downloads each for listening.

```sh
~/.local/share/uv/tools/notebooklm-py/bin/python scripts/accent-test.py \
  ~/Documents/Google_Attention_Is_All_You_Need.pdf ~/Documents/accent-test
```

Possible outcomes:
1. Server rejects the code: regional English is not supported; fall back to another
   text-to-speech service (below).
2. Server accepts it but the voices are unchanged: same conclusion.
3. Voices change: add `en_GB`/`en_AU` to the fork's catalog (and a CLI flag to pass unlisted
   codes), and offer it upstream.

Result: _not run yet._ Each overview uses audio quota (`notebooklm usage --categories`).

## Fallback: NotebookLM script + another text-to-speech service

Have NotebookLM write the two-host script (chat or a report), then voice it elsewhere and join
the clips with ffmpeg:
- ElevenLabs: most natural; many British/Australian voices; paid plan (about $5-22/month).
- Google Cloud Text-to-Speech: `en-GB` and `en-AU` voices; needs a billing-enabled project;
  likely a few dollars per 50-minute episode.
- macOS `say`: free; British voices Daniel, Flo, Reed and others, Australian voice Karen; sounds
  robotic over long listening.
