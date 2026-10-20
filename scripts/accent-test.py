"""Check whether NotebookLM honors regional English codes for audio voices.

The notebooklm CLI only accepts codes from its built-in list (English is just "en"), but the
library sends any non-empty code to the server. This generates one short "brief" overview per
code into a scratch notebook and downloads each, so the voices can be compared by ear.

Run with the notebooklm tool's own Python:
  ~/.local/share/uv/tools/notebooklm-py/bin/python scripts/accent-test.py PAPER.pdf OUT_DIR [CODE...]
Codes default to en_GB en_AU. Each one uses audio quota (see `notebooklm usage --categories`).
"""

import asyncio
import sys
from pathlib import Path

from notebooklm import AudioFormat, AudioLength, NotebookLMClient

PROMPT = "Introduce yourselves briefly, then explain the paper's main idea in simple words."


async def main(pdf: Path, out_dir: Path, codes: list[str]) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    async with NotebookLMClient.from_storage() as client:
        nb = await client.notebooks.create("Accent test")
        print(f"Notebook: {nb.id}")
        await client.sources.add_file(nb.id, pdf, wait=True)

        for code in codes:
            print(f"{code}: requesting...")
            try:
                status = await client.artifacts.generate_audio(
                    nb.id,
                    language=code,
                    instructions=PROMPT,
                    audio_format=AudioFormat.BRIEF,
                    audio_length=AudioLength.SHORT,
                )
                await client.artifacts.wait_for_completion(nb.id, status.task_id, timeout=1200)
                path = await client.artifacts.download_audio(
                    nb.id, str(out_dir / f"accent-{code}.m4a"), artifact_id=status.task_id
                )
                print(f"{code}: saved {path}")
            except Exception as exc:  # report and keep testing the other codes
                print(f"{code}: failed: {type(exc).__name__}: {exc}")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    asyncio.run(main(Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3:] or ["en_GB", "en_AU"]))
