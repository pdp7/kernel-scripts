---
name: tenstorrent-coworkers-podcast corpus
description: NotebookLM source dir for audio podcasts about Tenstorrent coworkers' upstream activity (Drew's own work excluded)
type: project
originSessionId: c53f53e3-4289-4b81-ae9d-3ff9183f47ca
---
`linux/tenstorrent-coworkers-podcast/` is a 6-month corpus (2025-11 to 2026-05) built for NotebookLM audio podcast generation about Drew's Tenstorrent coworkers' upstream activity.

Built 2026-05-10 by filtering `linux/tenstorrent-lore-6mo/` and extracting from `~/opensbi-mail-archive/`.

**Why:** Drew wants podcasts about his coworkers' kernel/QEMU/OpenSBI work, not his own (CBQRI/SSQOSID/RQSC/IOMMU bindings/his own pulls excluded).

**How to apply:** When asked to refresh, regenerate, or add new sources for the coworkers podcast, use this dir. When asked about coworker activity over the past months, start from `REPORT.md` here.

**Contents:**
- 26 lore mboxes/summaries (lkml + qemu-devel), filtered from tenstorrent-lore-6mo by dropping 11 Drew-as-primary threads
- 13 opensbi mboxes covering Nicholas Piggin, Evgeny Voevodin, Anirudh Srinivasan plus SiFive Smrnmi origin
- `REPORT.md` (~6000 words): 11 storylines plus per-contributor breakdown plus 8-episode listening guide
- `opensbi-list-broader-digest.md` copied from the OpenSBI archive for ecosystem context

**Coworkers covered:** Anirudh Srinivasan (PRCM, Blackhole DT, payload alignment), Joel Stanley (Atlantis QEMU machine v1-v4, tt-ascalon mvendorid), Nicholas Piggin (Atlantis QEMU v5, dbtr 18-patch, Sdtrig RFC, OpenSBI Atlantis platform, PMP refactor, IOMMU), Anton Blanchard (5 RVV correctness fixes), Evgeny Voevodin (Smrnmi v1/v2/v3), Michael Ellerman, Michael Neuling.
