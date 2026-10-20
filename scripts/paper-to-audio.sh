#!/usr/bin/env bash
# Turn a paper into a NotebookLM audio overview and save it as an MP3 next to the PDF.
#
# Usage: paper-to-audio.sh PAPER.pdf "Notebook title" [SOURCES.txt] [PROMPT.txt]
#   SOURCES.txt  background-reading URLs, one per line; '#' lines are ignored
#   PROMPT.txt   defaults to prompts/student-walkthrough.txt
#
# Env: LENGTH (short|default|long, default long), FORMAT (deep-dive|brief|critique|debate,
#      default deep-dive), TIMEOUT (seconds to wait for audio, default 2400)
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")/.." && pwd)"
pdf="${1:?Usage: paper-to-audio.sh PAPER.pdf \"Notebook title\" [SOURCES.txt] [PROMPT.txt]}"
title="${2:?Notebook title required}"
sources="${3:-}"
prompt="${4:-$repo_dir/prompts/student-walkthrough.txt}"
length="${LENGTH:-long}"
format="${FORMAT:-deep-dive}"
timeout="${TIMEOUT:-2400}"

[[ -f "$pdf" ]] || { echo "No such PDF: $pdf" >&2; exit 1; }
[[ -f "$prompt" ]] || { echo "No such prompt file: $prompt" >&2; exit 1; }
[[ -z "$sources" || -f "$sources" ]] || { echo "No such sources file: $sources" >&2; exit 1; }

echo "Creating notebook \"$title\"..."
notebook_id="$(notebooklm create "$title" --json | jq -r '.notebook.id')"
export NOTEBOOKLM_NOTEBOOK="$notebook_id"
echo "Notebook: $notebook_id"

echo "Uploading $pdf..."
notebooklm source add "$pdf" --request-timeout 120

if [[ -n "$sources" ]]; then
  while IFS= read -r url || [[ -n "$url" ]]; do
    [[ -z "$url" || "$url" == \#* ]] && continue
    echo "Adding $url"
    notebooklm source add "$url" --request-timeout 90 || echo "  failed, skipping" >&2
  done < "$sources"
fi

echo "Generating $length $format audio (usually 10-20 minutes)..."
artifact_id="$(notebooklm generate audio --prompt-file "$prompt" --format "$format" \
  --length "$length" --json | jq -r '.task_id')"
notebooklm artifact wait "$artifact_id" --timeout "$timeout"

# NotebookLM serves AAC in an MP4 container, so save it as .m4a and convert.
base="${pdf%.*}_audio_overview"
notebooklm download audio -a "$artifact_id" --force "$base.m4a"
ffmpeg -v error -y -i "$base.m4a" -vn -c:a libmp3lame -q:a 4 "$base.mp3"

duration="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$base.mp3")"
printf 'Done: %s (%d min)\n' "$base.mp3" "$(( ${duration%.*} / 60 ))"
