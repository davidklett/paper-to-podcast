# paper-to-podcast

Turn a research paper into a ~50-minute audio lesson you can listen to on a walk or drive.

The workflow (from a LinkedIn post by a reader without a Ph.D. who found papers took 5 to 10
days to understand):

1. **Save the paper** to a NotebookLM notebook.
2. **Build the context**: add background reading (key concepts and related work) to the same
   notebook.
3. **Generate an audio overview** in the long format with a specific teaching prompt.
4. **Listen.**

This repo automates all four steps with the unofficial
[`notebooklm-py`](https://github.com/teng-lin/notebooklm-py) CLI.

## Quick start

```sh
scripts/setup.sh                 # one time: install the CLI and sign in to Google
scripts/paper-to-audio.sh ~/Documents/paper.pdf "Paper Title" sources/my-paper.txt
```

The MP3 is written next to the PDF. See `docs/prerequisites.md` for what gets installed.

## The prompt

> I have no idea about this topic. Consider me your student. Use the context material and walk
> through the entire paper step by step. Do not spend much time on the experiments. Whenever you
> introduce a new concept or term, explain it in simple words first, so I have the context
> before we go into details.
